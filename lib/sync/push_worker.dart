import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/database.dart';
import 'sync_remote.dart';

class PushWorker {
  final AppDatabase db;
  final SyncRemote remote;
  final Connectivity connectivity;

  Timer? _periodicTimer;
  Timer? _debounceTimer;
  Timer? _backoffTimer;

  bool _isPushing = false;
  int _backoffSeconds = 5;
  StreamSubscription? _connectivitySubscription;

  PushWorker({
    required this.db,
    required this.remote,
    Connectivity? connectivity,
  }) : connectivity = connectivity ?? Connectivity();

  void start() {
    _connectivitySubscription = connectivity.onConnectivityChanged.listen((results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        triggerPush();
      }
    });

    _periodicTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      triggerPush();
    });

    triggerPush();
  }

  void stop() {
    _connectivitySubscription?.cancel();
    _periodicTimer?.cancel();
    _debounceTimer?.cancel();
    _backoffTimer?.cancel();
  }

  void triggerPush() {
    _backoffTimer?.cancel();
    pushPending();
  }

  void triggerDebouncedPush([Duration duration = const Duration(seconds: 3)]) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, () {
      triggerPush();
    });
  }

  Future<void> pushPending() async {
    if (_isPushing) return;
    _isPushing = true;

    try {
      final pendingCommands = await (db.select(db.outboxCommands)
            ..where((t) => t.status.equals('pending'))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

      for (final cmd in pendingCommands) {
        try {
          await _processCommand(cmd);
          await (db.update(db.outboxCommands)..where((t) => t.id.equals(cmd.id))).write(
            const OutboxCommandsCompanion(
              status: Value('applied'),
              lastError: Value(null),
            ),
          );
          _backoffSeconds = 5; // Reset backoff on success
        } catch (e) {
          if (_isClientOrConstraintError(e)) {
            // Mark rejected, do not retry automatically
            await (db.update(db.outboxCommands)..where((t) => t.id.equals(cmd.id))).write(
              OutboxCommandsCompanion(
                status: const Value('rejected'),
                lastError: Value(e.toString()),
              ),
            );
          } else {
            // Network or server 5xx error: leave pending and schedule backoff
            await (db.update(db.outboxCommands)..where((t) => t.id.equals(cmd.id))).write(
              OutboxCommandsCompanion(
                lastError: Value(e.toString()),
              ),
            );
            _scheduleBackoff();
            break; // Stop processing remaining queue for this run
          }
        }
      }
    } finally {
      _isPushing = false;
    }
  }

  bool _isClientOrConstraintError(dynamic e) {
    if (e is PostgrestException) {
      final code = e.code ?? '';
      final msg = e.message.toLowerCase();
      if (code == '401' ||
          code == '403' ||
          code == 'PGRST301' ||
          code.toLowerCase().contains('jwt') ||
          msg.contains('jwt') ||
          msg.contains('expired') ||
          msg.contains('unauthorized') ||
          msg.contains('forbidden')) {
        return false;
      }
      if (code.startsWith('23') || code.startsWith('4')) {
        return true;
      }
    }
    final msg = e.toString().toLowerCase();
    if (msg.contains('jwt') ||
        msg.contains('expired') ||
        msg.contains('401') ||
        msg.contains('403') ||
        msg.contains('unauthorized') ||
        msg.contains('forbidden')) {
      return false;
    }
    if (msg.contains('4xx') ||
        msg.contains('400') ||
        msg.contains('409') ||
        msg.contains('duplicate') ||
        msg.contains('constraint') ||
        msg.contains('violates') ||
        msg.contains('rejected')) {
      return true;
    }
    return false;
  }

  void _scheduleBackoff() {
    _backoffTimer?.cancel();
    _backoffTimer = Timer(Duration(seconds: _backoffSeconds), () {
      pushPending();
    });
    _backoffSeconds = (_backoffSeconds * 2).clamp(5, 300); // Exponential backoff capped at 5 mins
  }

  Future<void> _processCommand(OutboxCommand cmd) async {
    final payload = jsonDecode(cmd.payloadJson) as Map<String, dynamic>;

    switch (cmd.commandType) {
      case 'upsert_business':
        await remote.upsertBusiness(payload);
        break;

      case 'upsert_device':
        await remote.upsertDevice(payload);
        break;

      case 'upsert_party':
        await remote.upsertParty(payload);
        break;

      case 'upsert_product':
        await remote.upsertProduct(payload);
        break;

      case 'cancel_document':
        final docId = payload['document_id'] as String;
        await remote.cancelDocument(docId);
        break;

      case 'issue_document':
        final docId = payload['document_id'] as String;
        final doc = await (db.select(db.documents)..where((t) => t.id.equals(docId))).getSingleOrNull();
        if (doc == null) {
          throw StateError('Document $docId not found for issue_document push');
        }
        final bus = await (db.select(db.businesses)..where((t) => t.id.equals(doc.businessId))).getSingleOrNull();
        if (bus == null) {
          throw StateError('Business ${doc.businessId} not found for issue_document push');
        }
        final dev = await (db.select(db.devices)..where((t) => t.id.equals(doc.deviceId))).getSingleOrNull();
        if (dev == null) {
          throw StateError('Device ${doc.deviceId} not found for issue_document push');
        }

        Party? party;
        if (doc.partyId != null) {
          party = await (db.select(db.parties)..where((t) => t.id.equals(doc.partyId!))).getSingleOrNull();
        }

        final lines = await (db.select(db.documentLines)..where((t) => t.documentId.equals(doc.id))).get();
        final productIds = lines.map((l) => l.productId).toSet();
        final products = await (db.select(db.products)..where((t) => t.id.isIn(productIds))).get();
        final payments = await (db.select(db.payments)..where((t) => t.documentId.equals(doc.id))).get();
        final stockMovements = await (db.select(db.stockMovements)..where((t) => t.documentId.equals(doc.id))).get();

        await remote.issueDocument(
          business: _busMap(bus),
          device: _devMap(dev),
          party: party != null ? _partyMap(party) : null,
          products: products.map(_prodMap).toList(),
          document: _docMap(doc),
          lines: lines.map(_lineMap).toList(),
          payments: payments.map(_payMap).toList(),
          stockMovements: stockMovements.map(_smMap).toList(),
          commandId: cmd.id,
        );
        break;

      default:
        throw UnimplementedError('Unknown command type: ${cmd.commandType}');
    }
  }

  Map<String, dynamic> _busMap(Business b) => {
        'id': b.id,
        'business_id': b.businessId,
        'name': b.name,
        'gstin': b.gstin,
        'state_code': b.stateCode,
        'address': b.address,
        'upi_id': b.upiId,
        'invoice_terms': b.invoiceTerms,
        'created_at': b.createdAt.toUtc().toIso8601String(),
        'updated_at': b.updatedAt.toUtc().toIso8601String(),
      };

  Map<String, dynamic> _devMap(Device d) => {
        'id': d.id,
        'business_id': d.businessId,
        'name': d.name,
        'series_prefix': d.seriesPrefix,
        'created_at': d.createdAt.toUtc().toIso8601String(),
        'updated_at': d.updatedAt.toUtc().toIso8601String(),
      };

  Map<String, dynamic> _partyMap(Party p) => {
        'id': p.id,
        'business_id': p.businessId,
        'name': p.name,
        'phone': p.phone,
        'gstin': p.gstin,
        'state_code': p.stateCode,
        'credit_limit_paise': p.creditLimitPaise,
        'created_at': p.createdAt.toUtc().toIso8601String(),
        'updated_at': p.updatedAt.toUtc().toIso8601String(),
        'archived_at': p.archivedAt?.toUtc().toIso8601String(),
      };

  Map<String, dynamic> _prodMap(Product p) => {
        'id': p.id,
        'business_id': p.businessId,
        'name': p.name,
        'barcode': p.barcode,
        'hsn': p.hsn,
        'gst_rate_bp': p.gstRateBp,
        'price_paise': p.pricePaise,
        'cost_paise': p.costPaise,
        'track_stock': p.trackStock,
        'reorder_level': p.reorderLevel,
        'created_at': p.createdAt.toUtc().toIso8601String(),
        'updated_at': p.updatedAt.toUtc().toIso8601String(),
      };

  Map<String, dynamic> _docMap(Document d) => {
        'id': d.id,
        'business_id': d.businessId,
        'device_id': d.deviceId,
        'doc_type': d.docType,
        'number': d.number,
        'party_id': d.partyId,
        'issued_at': d.issuedAt.toUtc().toIso8601String(),
        'status': d.status,
        'taxable_paise': d.taxablePaise,
        'cgst_paise': d.cgstPaise,
        'sgst_paise': d.sgstPaise,
        'igst_paise': d.igstPaise,
        'round_off_paise': d.roundOffPaise,
        'total_paise': d.totalPaise,
        'snapshot_json': jsonDecode(d.snapshotJson),
        'ref_document_id': d.refDocumentId,
        'created_at': d.createdAt.toUtc().toIso8601String(),
      };

  Map<String, dynamic> _lineMap(DocumentLine l) => {
        'id': l.id,
        'document_id': l.documentId,
        'business_id': l.businessId,
        'product_id': l.productId,
        'name': l.name,
        'hsn': l.hsn,
        'qty_milli': l.qtyMilli,
        'rate_paise': l.ratePaise,
        'discount_paise': l.discountPaise,
        'gst_rate_bp': l.gstRateBp,
        'taxable_paise': l.taxablePaise,
        'cgst_paise': l.cgstPaise,
        'sgst_paise': l.sgstPaise,
        'igst_paise': l.igstPaise,
        'line_total_paise': l.lineTotalPaise,
        'created_at': l.createdAt.toUtc().toIso8601String(),
      };

  Map<String, dynamic> _payMap(Payment p) => {
        'id': p.id,
        'business_id': p.businessId,
        'document_id': p.documentId,
        'party_id': p.partyId,
        'method': p.method,
        'amount_paise': p.amountPaise,
        'note': p.note,
        'paid_at': p.paidAt.toUtc().toIso8601String(),
        'created_at': p.createdAt.toUtc().toIso8601String(),
      };

  Map<String, dynamic> _smMap(StockMovement sm) => {
        'id': sm.id,
        'business_id': sm.businessId,
        'product_id': sm.productId,
        'qty_milli': sm.qtyMilli,
        'reason': sm.reason,
        'document_id': sm.documentId,
        'created_at': sm.createdAt.toUtc().toIso8601String(),
      };
}
