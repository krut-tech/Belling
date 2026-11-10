import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/items_import.dart';
import '../../data/providers.dart';
import '../../core/tr_text.dart';

/// "Import items from CSV/Excel": pick a file, review, import. Skips rows that
/// are wrong or whose barcode already exists and tells exactly why.
class ItemsImportCard extends ConsumerStatefulWidget {
  const ItemsImportCard({super.key});

  @override
  ConsumerState<ItemsImportCard> createState() => _ItemsImportCardState();
}

class _ItemsImportCardState extends ConsumerState<ItemsImportCard> {
  bool _busy = false;

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _shareTemplate() async {
    try {
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}/belling_items_sample.csv');
      await f.writeAsString('﻿$kItemsCsvTemplate', flush: true);
      await Share.shareXFiles([XFile(f.path, mimeType: 'text/csv')], text: 'Belling items sample CSV');
    } catch (e) {
      _toast('Sample file nahi ban payi: $e');
    }
  }

  Future<void> _pickAndImport() async {
    setState(() => _busy = true);
    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv', 'txt'],
        withData: true,
      );
      if (res == null || res.files.isEmpty) return;
      final bytes = res.files.first.bytes;
      if (bytes == null) {
        _toast('File padhi nahi ja saki. Dobara try karo.');
        return;
      }
      final parsed = parseItemsCsv(utf8.decode(bytes, allowMalformed: true));
      if (!mounted) return;

      final go = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Items import'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${parsed.items.length} items import honge.', style: const TextStyle(fontWeight: FontWeight.bold)),
                if (parsed.problems.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text('${parsed.problems.length} rows chhod di jayengi:'),
                  const SizedBox(height: 4),
                  for (final p in parsed.problems.take(8)) Text('• Line ${p.line}: ${p.message}', style: const TextStyle(fontSize: 12.5)),
                  if (parsed.problems.length > 8) Text('... aur ${parsed.problems.length - 8}', style: const TextStyle(fontSize: 12.5)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              onPressed: parsed.items.isEmpty ? null : () => Navigator.pop(ctx, true),
              child: const Text('Import karo'),
            ),
          ],
        ),
      );
      if (go != true) return;

      final repo = ref.read(productRepositoryProvider);
      var added = 0;
      final skipped = <String>[];
      for (final it in parsed.items) {
        try {
          await repo.save(
            name: it.name,
            barcode: it.barcode,
            hsn: it.hsn,
            gstRateBp: it.gstRateBp,
            pricePaise: it.pricePaise,
            costPaise: it.costPaise,
            trackStock: true,
            openingStockMilli: it.openingStockMilli,
            reorderLevel: it.reorderLevel,
          );
          added++;
        } catch (e) {
          final msg = e.toString().contains('Barcode already exists') ? 'barcode pehle se hai' : e.toString();
          skipped.add('Line ${it.line} "${it.name}": $msg');
        }
      }
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Import ho gaya'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$added items add hue.', style: const TextStyle(fontWeight: FontWeight.bold)),
                if (skipped.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('${skipped.length} skip hue:'),
                  for (final s in skipped.take(8)) Text('• $s', style: const TextStyle(fontSize: 12.5)),
                ],
              ],
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Theek hai'))],
        ),
      );
    } catch (e) {
      _toast('Import nahi hua: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.upload_file, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('Items import (CSV / Excel)', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Saare items ek saath daalo. Excel mein banao aur "CSV" save karo. Columns: name, barcode, hsn, gst_percent, price, cost, stock, reorder_level.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _shareTemplate,
                    icon: const Icon(Icons.description_outlined),
                    label: const Text('Sample file'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _pickAndImport,
                    icon: _busy
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.folder_open),
                    label: const Text('File chuno'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
