import 'package:supabase_flutter/supabase_flutter.dart';
import 'pull_service.dart';
import 'sync_remote.dart';

class SupabaseSyncRemote implements SyncRemote, SyncRemoteExtras, PullRemote {
  final SupabaseClient client;

  SupabaseSyncRemote(this.client);

  @override
  bool get canPull => client.auth.currentSession != null;

  @override
  Future<List<Map<String, dynamic>>> fetchChanges({
    required String table,
    required String businessId,
    required int afterSeq,
    required int limit,
  }) async {
    return _withAuthRetry(() async {
      final key = table == 'businesses' ? 'id' : 'business_id';
      final rows = await client
          .from(table)
          .select()
          .eq(key, businessId)
          .gt('server_seq', afterSeq)
          .order('server_seq', ascending: true)
          .limit(limit);
      return List<Map<String, dynamic>>.from(rows);
    });
  }

  @override
  bool get isReady => client.auth.currentSession != null;

  @override
  Future<void> insertPayment({
    required Map<String, dynamic> payment,
    Map<String, dynamic>? party,
  }) async {
    await _withAuthRetry(() async {
      if (party != null) {
        await _upsertMutableRowRaw('parties', party);
      }
      await client.from('payments').upsert(payment, onConflict: 'id', ignoreDuplicates: true);
    });
  }

  @override
  Future<void> insertStockMovement(Map<String, dynamic> stockMovement) async {
    await _withAuthRetry(() async {
      await client.from('stock_movements').upsert(stockMovement, onConflict: 'id', ignoreDuplicates: true);
    });
  }

  @override
  Future<void> upsertBusiness(Map<String, dynamic> data) async {
    await _updateBusiness(data);
  }

  @override
  Future<void> upsertDevice(Map<String, dynamic> data) async {
    await _upsertMutableRow('devices', data);
  }

  @override
  Future<void> upsertParty(Map<String, dynamic> data) async {
    await _upsertMutableRow('parties', data);
  }

  @override
  Future<void> upsertProduct(Map<String, dynamic> data) async {
    await _upsertMutableRow('products', data);
  }

  @override
  Future<void> issueDocument({
    required Map<String, dynamic> business,
    required Map<String, dynamic> device,
    Map<String, dynamic>? party,
    required List<Map<String, dynamic>> products,
    required Map<String, dynamic> document,
    required List<Map<String, dynamic>> lines,
    required List<Map<String, dynamic>> payments,
    required List<Map<String, dynamic>> stockMovements,
    required String commandId,
  }) async {
    await _withAuthRetry(() async {
      // 1. Business: update only
      await _updateBusinessRaw(business);

      // 2. Device
      await _upsertMutableRowRaw('devices', device);

      // 3. Party
      if (party != null) {
        await _upsertMutableRowRaw('parties', party);
      }

      // 4. Products used
      for (final p in products) {
        await _upsertMutableRowRaw('products', p);
      }

      // 5. Document
      await _upsertDocument(document);

      // 6. Lines
      if (lines.isNotEmpty) {
        await client.from('document_lines').upsert(lines, onConflict: 'id', ignoreDuplicates: true);
      }

      // 7. Payments
      if (payments.isNotEmpty) {
        await client.from('payments').upsert(payments, onConflict: 'id', ignoreDuplicates: true);
      }

      // 8. Stock Movements
      if (stockMovements.isNotEmpty) {
        await client.from('stock_movements').upsert(stockMovements, onConflict: 'id', ignoreDuplicates: true);
      }

      // 9. Applied Command
      await client.from('applied_commands').upsert({
        'id': commandId,
        'business_id': business['id'],
        'device_id': device['id'],
        'command_type': 'issue_document',
      }, onConflict: 'id', ignoreDuplicates: true);
    });
  }

  @override
  Future<void> cancelDocument(String documentId) async {
    await _withAuthRetry(() async {
      await client.from('documents').update({'status': 'cancelled'}).eq('id', documentId).eq('status', 'issued');
    });
  }

  Future<void> _updateBusiness(Map<String, dynamic> data) async {
    await _withAuthRetry(() async {
      await _updateBusinessRaw(data);
    });
  }

  Future<void> _updateBusinessRaw(Map<String, dynamic> data) async {
    final id = data['id'] as String;
    final updated = await client.from('businesses').update(data).eq('id', id).select();
    if (updated.isEmpty) {
      final existing = await client.from('businesses').select('id').eq('id', id).maybeSingle();
      if (existing == null) {
        throw const PostgrestException(
          message: 'Business does not exist on server',
          code: '404',
        );
      }
    }
  }

  Future<void> _upsertMutableRow(String table, Map<String, dynamic> data) async {
    await _withAuthRetry(() async {
      await _upsertMutableRowRaw(table, data);
    });
  }

  Future<void> _upsertMutableRowRaw(String table, Map<String, dynamic> data) async {
    final id = data['id'] as String;
    await client.from(table).upsert(data, onConflict: 'id', ignoreDuplicates: true);
    if (data.containsKey('updated_at') && data['updated_at'] != null) {
      await client
          .from(table)
          .update(data)
          .eq('id', id)
          .lte('updated_at', data['updated_at'] as String);
    }
  }

  Future<void> _upsertDocument(Map<String, dynamic> document) async {
    try {
      await client.from('documents').upsert(document, onConflict: 'id', ignoreDuplicates: true);
    } catch (e) {
      if (e is PostgrestException && e.code == '23505') {
        final docId = document['id'] as String;
        final businessId = document['business_id'];
        final docType = document['doc_type'];
        final number = document['number'];

        final existingById = await client.from('documents').select('id').eq('id', docId).maybeSingle();
        if (existingById != null) {
          return;
        }

        final existingByNum = await client.from('documents')
            .select('id')
            .eq('business_id', businessId)
            .eq('doc_type', docType)
            .eq('number', number)
            .maybeSingle();

        if (existingByNum != null && existingByNum['id'] != docId) {
          rethrow;
        }
        if (existingByNum != null && existingByNum['id'] == docId) {
          return;
        }
        rethrow;
      }
      rethrow;
    }
  }

  Future<T> _withAuthRetry<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e) {
      if (_isAuthOrExpired(e)) {
        try {
          await client.auth.refreshSession();
          return await action();
        } catch (_) {
          rethrow;
        }
      }
      rethrow;
    }
  }

  bool _isAuthOrExpired(dynamic e) {
    if (e is PostgrestException) {
      final code = e.code ?? '';
      final msg = e.message.toLowerCase();
      if (code == '401' ||
          code == '403' ||
          code == 'PGRST301' ||
          code.toLowerCase().contains('jwt') ||
          msg.contains('jwt') ||
          msg.contains('expired') ||
          msg.contains('401') ||
          msg.contains('403') ||
          msg.contains('unauthorized') ||
          msg.contains('forbidden')) {
        return true;
      }
    }
    final s = e.toString().toLowerCase();
    if (s.contains('jwt') || s.contains('expired') || s.contains('401') || s.contains('403')) {
      return true;
    }
    return false;
  }
}
