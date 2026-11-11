import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/money.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../core/tr_text.dart';

class ReceivePaymentDialog extends ConsumerStatefulWidget {
  final Party party;

  const ReceivePaymentDialog({super.key, required this.party});

  static Future<Payment?> show(BuildContext context, {required Party party}) {
    return showDialog<Payment?>(
      context: context,
      builder: (context) => ReceivePaymentDialog(party: party),
    );
  }

  @override
  ConsumerState<ReceivePaymentDialog> createState() => _ReceivePaymentDialogState();
}

class _ReceivePaymentDialogState extends ConsumerState<ReceivePaymentDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _amountController;
  late TextEditingController _noteController;
  String _method = 'cash';
  DateTime _paidAt = DateTime.now();
  String? _selectedDocumentId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// Shows what this payment will do: settle oldest bills first, extra = advance.
  String? _helper() {
    final balance = ref.watch(partyBalanceStreamProvider(widget.party.id)).valueOrNull;
    if (balance == null) return null;
    final entered = parseRupeesToPaise(_amountController.text.replaceAll(RegExp(r'[,₹\s]'), '')) ?? 0;
    if (balance <= 0) {
      return entered > 0 ? 'Koi baaki nahi, ye ${formatRupees(entered)} advance ke roop mein jama hoga' : 'Koi baaki nahi hai';
    }
    if (entered <= 0) return 'Abhi baaki: ${formatRupees(balance)} (purane bill pehle settle honge)';
    if (entered > balance) {
      return 'Baaki ${formatRupees(balance)} clear hoga, extra ${formatRupees(entered - balance)} advance jama hoga';
    }
    return 'Baaki ${formatRupees(balance)} → ${formatRupees(balance - entered)} bachega';
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _paidAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final now = DateTime.now();
      setState(() {
        _paidAt = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          now.hour,
          now.minute,
          now.second,
        );
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amountPaise = parseRupeesToPaise(_amountController.text.trim());
    if (amountPaise == null || amountPaise <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repo = ref.read(partyRepositoryProvider);
      final payment = await repo.addPayment(
        partyId: widget.party.id,
        amountPaise: amountPaise,
        method: _method,
        paidAt: _paidAt,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        documentId: _selectedDocumentId,
      );

      if (mounted) {
        Navigator.of(context).pop(payment);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.watch(databaseProvider);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${l10n.receivePayment} - ${widget.party.name}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Amount (₹)
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: l10n.amount,
                    border: const OutlineInputBorder(),
                    helperMaxLines: 3,
                    helperText: _helper(),
                  ),
                  validator: (v) {
                    final paise = parseRupeesToPaise(v ?? '');
                    if (paise == null || paise <= 0) {
                      return l10n.priceRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Payment Method
                DropdownButtonFormField<String>(
                  initialValue: _method,
                  decoration: InputDecoration(
                    labelText: l10n.paymentMethod,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'cash', child: Text(l10n.cash)),
                    DropdownMenuItem(value: 'upi', child: Text(l10n.upi)),
                    DropdownMenuItem(value: 'card', child: Text(l10n.card)),
                    DropdownMenuItem(value: 'credit', child: Text(l10n.credit)),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _method = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Date Picker
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.date,
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(DateFormat('dd MMM yyyy').format(_paidAt)),
                  ),
                ),
                const SizedBox(height: 16),

                // Document allocation
                FutureBuilder<List<Document>>(
                  future: (db.select(db.documents)
                        ..where((t) => t.partyId.equals(widget.party.id))
                        ..where((t) => t.docType.equals('invoice'))
                        ..orderBy([(t) => OrderingTerm.desc(t.issuedAt)]))
                      .get(),
                  builder: (context, snapshot) {
                    final docs = snapshot.data ?? [];
                    return DropdownButtonFormField<String?>(
                      initialValue: _selectedDocumentId,
                      decoration: InputDecoration(
                        labelText: l10n.allocateToDocument,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(l10n.none),
                        ),
                        ...docs.map((doc) => DropdownMenuItem<String?>(
                              value: doc.id,
                              child: Text('${l10n.invoice} #${doc.number} (${formatRupees(doc.totalPaise)})'),
                            )),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedDocumentId = val;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Optional Note
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: l10n.optionalNote,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: const Size(80, 48),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(120, 48),
                      ),
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.save),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
