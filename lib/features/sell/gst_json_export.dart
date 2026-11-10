import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/einvoice.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../core/tr_text.dart';
import '../../core/tr.dart';

Future<void> _shareJson(BuildContext context, String name, Object json) async {
  final dir = await getTemporaryDirectory();
  final f = File('${dir.path}/$name');
  await f.writeAsString(prettyJson(json));
  await Share.shareXFiles([XFile(f.path, mimeType: 'application/json')], text: name);
}

/// Exports the IRP e-invoice JSON of [doc] (B2B only).
Future<void> exportEinvoice(BuildContext context, WidgetRef ref, Document doc) async {
  final db = ref.read(databaseProvider);
  final snap = (jsonDecode(doc.snapshotJson) as Map).cast<String, dynamic>();
  final problem = einvoiceProblem(doc, snap);
  if (problem != null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(problem)));
    return;
  }
  final lines = await (db.select(db.documentLines)..where((t) => t.documentId.equals(doc.id))).get();
  if (!context.mounted) return;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('E-invoice JSON'),
      content: const Text(
        'Ye file IRP portal (einvoice1.gst.gov.in) par upload karne ke liye hai, Belling khud IRN nahi banata.\n\n'
        'Upload se pehle file mein seller/buyer ka PIN code aur location sahi bhar lena ("CHECK ..." wali jagah).',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('File banao')),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  await _shareJson(context, 'einvoice_${doc.number.replaceAll('/', '-')}.json', [buildEinvoiceJson(doc, lines, snap)]);
}

/// Exports the e-way bill bulk-upload JSON after asking for transport details.
Future<void> exportEwayBill(BuildContext context, WidgetRef ref, Document doc) async {
  final db = ref.read(databaseProvider);
  final snap = (jsonDecode(doc.snapshotJson) as Map).cast<String, dynamic>();
  final seller = (snap['seller'] as Map?) ?? const {};
  if (((seller['gstin'] as String?) ?? '').length != 15) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pehle apna GSTIN set karo (More > Business settings)')));
    return;
  }
  final lines = await (db.select(db.documentLines)..where((t) => t.documentId.equals(doc.id))).get();
  if (!context.mounted) return;
  final dist = TextEditingController();
  final veh = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('E-way bill JSON'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: dist, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: tr(context, 'Distance (km)'))),
        TextField(controller: veh, textCapitalization: TextCapitalization.characters, decoration: InputDecoration(labelText: tr(context, 'Gaadi number (MH12AB1234)'))),
        const SizedBox(height: 8),
        const Text('File ewaybillgst.gov.in > Bulk generate mein upload karo.', style: TextStyle(fontSize: 12)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('File banao')),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  final km = int.tryParse(dist.text.trim());
  if (km == null || km <= 0 || veh.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Distance aur gaadi number daalo')));
    return;
  }
  await _shareJson(
    context,
    'ewaybill_${doc.number.replaceAll('/', '-')}.json',
    buildEwayBillJson(doc, lines, snap, distanceKm: km, vehicleNo: veh.text),
  );
}
