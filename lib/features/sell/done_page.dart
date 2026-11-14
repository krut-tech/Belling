import '../../core/activity_log.dart';
import 'package:flutter/material.dart' hide Text;
import '../../core/widgets/motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/invoice_pdf.dart';
import '../../core/money.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/belling_ui.dart';
import '../../data/providers.dart';
import '../../data/repositories/document_repository.dart';
import '../../l10n/app_localizations.dart';
import 'gst_json_export.dart';
import 'return_dialog.dart';
import '../../core/tr_text.dart';

class DonePage extends ConsumerStatefulWidget {
  final String documentId;

  const DonePage({super.key, required this.documentId});

  @override
  ConsumerState<DonePage> createState() => _DonePageState();
}

class _DonePageState extends ConsumerState<DonePage> {
  DocumentWithParty? _docWithParty;
  bool _isLoading = true;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    final docRepo = ref.read(documentRepositoryProvider);
    final data = await docRepo.getDocumentWithParty(widget.documentId);
    if (mounted) {
      setState(() {
        _docWithParty = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _showCancelDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cancelInvoice),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.confirmCancelInvoice),
              const SizedBox(height: 16),
              TextFormField(
                controller: reasonController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.cancellationReason,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.reasonRequired : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, true);
              }
            },
            child: Text(l10n.cancelInvoice),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isCancelling = true;
      });

      try {
        final docRepo = ref.read(documentRepositoryProvider);
        await docRepo.cancelInvoice(
          documentId: widget.documentId,
          reason: reasonController.text.trim(),
        );

        await logActivity(
          ref.read(recordsRepositoryProvider),
          'Bill cancelled',
          '${_docWithParty?.document.number ?? ''} · ${reasonController.text.trim()}',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.invoiceCancelled)),
          );
          await _loadDocument();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isCancelling = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const tabularStyle = TextStyle(
      fontFeatures: [FontFeature.tabularFigures()],
    );

    if (_isLoading) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              BellingHeader(title: l10n.invoiceIssued),
              const Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          ),
        ),
      );
    }

    if (_docWithParty == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              BellingHeader(title: l10n.invoiceIssued),
              const Expanded(child: Center(child: Text('Document not found'))),
            ],
          ),
        ),
      );
    }

    final doc = _docWithParty!.document;
    final party = _docWithParty!.party;
    final isCancelled = doc.status == 'cancelled';
    final statusColor = isCancelled ? AppColors.lightDanger : AppColors.lightSuccess;
    final partyName = party?.name ?? l10n.walkIn;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: staggered([
                    Center(
                      child: PopIn(
                        child: Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor.withValues(alpha: 0.14),
                          ),
                          alignment: Alignment.center,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
                            child: Icon(
                              isCancelled ? Icons.close_rounded : Icons.check_rounded,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isCancelled ? l10n.statusCancelled : l10n.invoiceIssued,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: isCancelled ? AppColors.lightDanger : AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${doc.number} • $partyName',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.lightMuted),
                    ),
                    const SizedBox(height: 20),
                    SoftCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.invoiceNumber,
                                  style: const TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.lightMuted)),
                              Text(
                                doc.number,
                                style: tabularStyle.copyWith(fontSize: 15, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Party:',
                                  style: TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.lightMuted)),
                              Flexible(
                                child: Text(
                                  partyName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 28, color: AppColors.lightBorder),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.grandTotal,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                              Text(
                                formatRupees(doc.totalPaise),
                                style: tabularStyle.copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action tiles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ActionTile(
                          icon: Icons.print_outlined,
                          color: AppColors.blue,
                          background: AppColors.blueBg,
                          label: 'Print',
                          onTap: () => printInvoicePdf(ref.read(databaseProvider), doc),
                        ),
                        _ActionTile(
                          icon: Icons.share_outlined,
                          color: AppColors.violet,
                          background: AppColors.violetBg,
                          label: l10n.share,
                          onTap: () => shareInvoicePdf(ref.read(databaseProvider), doc, context),
                        ),
                        if (doc.docType == 'invoice' || doc.docType == 'credit_note') ...[
                          _ActionTile(
                            icon: Icons.data_object,
                            color: AppColors.warn,
                            background: AppColors.warnBg,
                            label: 'E-invoice JSON',
                            onTap: () => exportEinvoice(context, ref, doc),
                          ),
                          _ActionTile(
                            icon: Icons.local_shipping_outlined,
                            color: AppColors.lightSuccess,
                            background: AppColors.goodBg,
                            label: 'E-way bill JSON',
                            onTap: () => exportEwayBill(context, ref, doc),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (!isCancelled && doc.docType == 'invoice')
                          Expanded(
                            child: _OutlineAction(
                              icon: Icons.assignment_return_outlined,
                              label: 'Maal wapas (return)',
                              onTap: () => showReturnDialog(context, ref, doc),
                            ),
                          ),
                        if (!isCancelled && doc.docType == 'invoice') const SizedBox(width: 10),
                        if (!isCancelled)
                          Expanded(
                            child: _OutlineAction(
                              icon: Icons.close_rounded,
                              label: l10n.cancelInvoice,
                              color: AppColors.lightDanger,
                              loading: _isCancelling,
                              onTap: _isCancelling ? null : _showCancelDialog,
                            ),
                          ),
                      ],
                    ),
                  ]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: GradientButton(
                label: l10n.newBill,
                icon: Icons.add,
                expand: true,
                onPressed: () => context.go('/sell/new'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String label;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon,
    required this.color,
    required this.background,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            IconTile(icon: icon, color: color, background: background, size: 56),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlineAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final bool loading;
  const _OutlineAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.lightText,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: color),
                )
              else
                Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
