import 'dart:io';

import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/dues_pdf.dart';
import '../../core/invoice_pdf.dart' show buildUpiQrUri;
import '../../core/invoice_style.dart';
import '../../core/money.dart';
import '../../data/providers.dart';
import '../../data/repositories/dues_repository.dart';
import '../../core/tr_text.dart';

/// One-tap payment reminder for a customer with unpaid bills: shows every open
/// bill (items, paid, due), the total, and a UPI QR for exactly that amount,
/// then sends it on WhatsApp or shares a PDF.
Future<void> showDuesReminderSheet(BuildContext context, {required String partyId}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => DuesReminderSheet(partyId: partyId),
  );
}

class DuesReminderSheet extends ConsumerStatefulWidget {
  const DuesReminderSheet({super.key, required this.partyId});
  final String partyId;

  @override
  ConsumerState<DuesReminderSheet> createState() => _DuesReminderSheetState();
}

class _DuesReminderSheetState extends ConsumerState<DuesReminderSheet> {
  late Future<PartyDues?> _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _future = ref.read(duesRepositoryProvider).getPartyDues(widget.partyId);
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// One short line that travels with the PDF (WhatsApp shows it as the caption).
  String _caption(PartyDues d) =>
      '${d.business?.name ?? 'Store'} - payment reminder. Total due: ${formatRupees(d.dues.totalDuePaise)}';

  Future<void> _sharePdf(PartyDues d) async {
    setState(() => _busy = true);
    try {
      final db = ref.read(databaseProvider);
      final style = await InvoiceStyleStore.load(db);
      final assets = await InvoiceStyleStore.loadAssets(style);
      final bytes = await generateDuesPdf(
        partyName: d.party.name,
        partyPhone: d.party.phone,
        shopName: d.business?.name ?? 'Store',
        shopGstin: d.business?.gstin,
        shopAddress: d.business?.address,
        upiId: d.business?.upiId,
        dues: d.dues,
        style: style,
        assets: assets,
      );
      final dir = await getTemporaryDirectory();
      final safe = d.party.name.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
      final file = File('${dir.path}/Payment_reminder_$safe.pdf');
      await file.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf', name: 'Payment_reminder_$safe.pdf')],
        text: _caption(d),
        subject: 'Payment reminder',
      );
    } catch (e) {
      _toast('PDF nahi ban paya: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<PartyDues?>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const SizedBox(height: 220, child: Center(child: CircularProgressIndicator()));
        }
        final d = snap.data;
        if (snap.hasError || d == null) {
          return SizedBox(height: 180, child: Center(child: Text('Data load nahi hua: ${snap.error ?? ''}')));
        }
        final dues = d.dues;
        if (!dues.hasDues) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 48, color: Colors.green),
                const SizedBox(height: 12),
                Text('${d.party.name} ka koi bakaya nahi hai', style: theme.textTheme.titleMedium),
                if (dues.advancePaise > 0) ...[
                  const SizedBox(height: 6),
                  Text('Advance jama: ${formatRupees(dues.advancePaise)}', style: theme.textTheme.bodyMedium),
                ],
              ],
            ),
          );
        }

        final upi = d.business?.upiId?.trim() ?? '';
        final qr = upi.isEmpty
            ? null
            : buildUpiQrUri(
                upiId: upi,
                sellerName: d.business?.name ?? 'Shop',
                number: 'Dues',
                balancePaise: dues.totalDuePaise,
                docType: 'invoice',
              );
        final dateFmt = DateFormat('dd MMM yyyy');

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, controller) => Column(
            children: [
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  children: [
                    Text(d.party.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('Total bakaya', style: theme.textTheme.bodySmall),
                    Text(
                      formatRupees(dues.totalDuePaise),
                      style: theme.textTheme.headlineMedium?.copyWith(color: Colors.red.shade700, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    for (final inv in dues.openInvoices)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          shape: const Border(),
                          title: Text('Bill ${inv.number}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            inv.isPartlyPaid
                                ? '${dateFmt.format(inv.issuedAt)} · Total ${formatRupees(inv.totalPaise)} · Paid ${formatRupees(inv.paidPaise)}'
                                : '${dateFmt.format(inv.issuedAt)} · Total ${formatRupees(inv.totalPaise)}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Baaki', style: TextStyle(fontSize: 11)),
                              Text(
                                formatRupees(inv.duePaise),
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700),
                              ),
                            ],
                          ),
                          children: [
                            for (final l in inv.lines)
                              ListTile(
                                dense: true,
                                title: Text(l.name),
                                subtitle: Text('${formatMilliUnits(l.qtyMilli)} × ${formatRupees(l.ratePaise)}'),
                                trailing: Text(formatRupees(l.lineTotalPaise)),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (qr != null)
                      Center(
                        child: Column(
                          children: [
                            Container(
                              color: Colors.white,
                              padding: const EdgeInsets.all(8),
                              child: QrImageView(data: qr, size: 160, backgroundColor: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            Text('Scan karke ${formatRupees(dues.totalDuePaise)} pay karo', style: theme.textTheme.bodySmall),
                            Text('UPI ID: $upi', style: theme.textTheme.bodySmall),
                          ],
                        ),
                      )
                    else
                      Text(
                        'UPI ID set nahi hai, isliye QR nahi banega. More > Business settings mein UPI ID daalo.',
                        style: theme.textTheme.bodySmall,
                      ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.picture_as_pdf, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Customer ko ek PDF jaayega: har bill ke items, paid / baaki, total aur UPI QR. '
                              'Button dabane par WhatsApp chuno, phir ${d.party.name}'
                              '${d.party.phone.trim().isEmpty ? '' : ' (${d.party.phone.trim()})'} select karo.',
                              style: const TextStyle(fontSize: 12.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(minimumSize: const Size(48, 54), backgroundColor: const Color(0xFF16A34A)),
                      onPressed: _busy ? null : () => _sharePdf(d),
                      icon: _busy
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send),
                      label: const Text('WhatsApp pe PDF bhejo'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
