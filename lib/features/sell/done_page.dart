import 'package:flutter/material.dart';
import '../../core/widgets/motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/invoice_pdf.dart';
import '../../core/money.dart';
import '../../data/providers.dart';
import '../../data/repositories/document_repository.dart';
import '../../l10n/app_localizations.dart';

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
        appBar: AppBar(title: Text(l10n.invoiceIssued)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_docWithParty == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.invoiceIssued)),
        body: const Center(child: Text('Document not found')),
      );
    }

    final doc = _docWithParty!.document;
    final party = _docWithParty!.party;
    final isCancelled = doc.status == 'cancelled';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.invoiceIssued),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: staggered([
              PopIn(
                child: Icon(
                  isCancelled ? Icons.cancel : Icons.check_circle,
                  size: 88,
                  color: isCancelled ? Colors.red : Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isCancelled ? l10n.statusCancelled : l10n.invoiceIssued,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCancelled ? Colors.red : Colors.green,
                    ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.invoiceNumber, style: Theme.of(context).textTheme.titleSmall),
                          Text(
                            doc.number,
                            style: Theme.of(context).textTheme.titleMedium?.merge(tabularStyle).copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Party:', style: Theme.of(context).textTheme.titleSmall),
                          Text(
                            party?.name ?? l10n.walkIn,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.grandTotal, style: Theme.of(context).textTheme.titleLarge),
                          Text(
                            formatRupees(doc.totalPaise),
                            style: Theme.of(context).textTheme.headlineSmall?.merge(tabularStyle).copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                      ),
                      onPressed: () => printInvoicePdf(ref.read(databaseProvider), doc),
                      icon: const Icon(Icons.print),
                      label: const Text('Print'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                      ),
                      onPressed: () => shareInvoicePdf(ref.read(databaseProvider), doc, context),
                      icon: const Icon(Icons.share),
                      label: Text(l10n.share),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: () => context.go('/sell/new'),
                      icon: const Icon(Icons.add_shopping_cart),
                      label: Text(l10n.newBill),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!isCancelled)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(120, 48),
                    foregroundColor: Colors.red,
                  ),
                  onPressed: _isCancelling ? null : _showCancelDialog,
                  icon: const Icon(Icons.cancel_outlined),
                  label: _isCancelling
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                        )
                      : Text(l10n.cancelInvoice),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}
