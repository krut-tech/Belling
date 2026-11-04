import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/gst_states.dart';
import '../../core/money.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

class PartyFormDialog extends ConsumerStatefulWidget {
  final Party? party;

  const PartyFormDialog({super.key, this.party});

  static Future<Party?> show(BuildContext context, {Party? party}) {
    return showDialog<Party?>(
      context: context,
      builder: (context) => PartyFormDialog(party: party),
    );
  }

  @override
  ConsumerState<PartyFormDialog> createState() => _PartyFormDialogState();
}

class _PartyFormDialogState extends ConsumerState<PartyFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _gstinController;
  late TextEditingController _creditLimitController;
  late String _stateCode;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.party;
    _nameController = TextEditingController(text: p?.name ?? '');
    _phoneController = TextEditingController(text: p?.phone ?? '');
    _gstinController = TextEditingController(text: p?.gstin ?? '');
    final limitRupees = (p != null && p.creditLimitPaise > 0)
        ? formatPaiseToRupeesInput(p.creditLimitPaise, forceDecimals: false)
        : '';
    _creditLimitController = TextEditingController(text: limitRupees);
    _stateCode = p?.stateCode ?? '27'; // Default Maharashtra
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _gstinController.dispose();
    _creditLimitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(partyRepositoryProvider);

    setState(() {
      _isSaving = true;
    });

    try {
      final creditLimitPaise = parseRupeesToPaise(_creditLimitController.text.trim()) ?? 0;

      final savedParty = await repo.save(
        id: widget.party?.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        gstin: _gstinController.text.trim().isEmpty ? null : _gstinController.text.trim(),
        stateCode: _stateCode,
        creditLimitPaise: creditLimitPaise < 0 ? 0 : creditLimitPaise,
      );

      if (mounted) {
        Navigator.of(context).pop(savedParty);
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
    final isEditing = widget.party != null;

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
                  isEditing ? l10n.editParty : l10n.addParty,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.itemName.replaceAll('Item', 'Party').replaceAll('सामान', 'पार्टी').replaceAll('વસ્તુ', 'પાર્ટી'),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? l10n.nameRequired : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.phone,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _gstinController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: l10n.gstin,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _creditLimitController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.creditLimit,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _stateCode,
                  decoration: InputDecoration(
                    labelText: l10n.state,
                    border: const OutlineInputBorder(),
                  ),
                  items: kGstStates.map((s) {
                    return DropdownMenuItem<String>(
                      value: s.code,
                      child: Text('${s.name} (${s.code})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _stateCode = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
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
                        minimumSize: const Size(100, 48),
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
