import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../data/providers.dart';
import '../../data/repositories/product_repository.dart';
import '../../l10n/app_localizations.dart';
import 'barcode_scanner_dialog.dart';

class ItemFormDialog extends ConsumerStatefulWidget {
  final ProductWithStock? item;
  final String? initialBarcode;

  const ItemFormDialog({super.key, this.item, this.initialBarcode});

  static Future<bool?> show(BuildContext context, {ProductWithStock? item, String? initialBarcode}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ItemFormDialog(item: item, initialBarcode: initialBarcode),
    );
  }

  @override
  ConsumerState<ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends ConsumerState<ItemFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _barcodeController;
  late TextEditingController _hsnController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _costPriceController;
  late TextEditingController _openingStockController;
  late TextEditingController _reorderLevelController;

  late int _gstRateBp;
  late bool _trackStock;
  bool _isSaving = false;
  String? _errorMessage;

  static const _gstOptions = [
    0, // 0%
    25, // 0.25%
    300, // 3%
    500, // 5%
    1200, // 12%
    1800, // 18%
    2800, // 28%
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.item?.product;

    _nameController = TextEditingController(text: p?.name ?? '');
    _barcodeController = TextEditingController(text: widget.initialBarcode ?? p?.barcode ?? '');
    _hsnController = TextEditingController(text: p?.hsn ?? '');

    // Format initial prices
    final sellingRupeesStr = p != null ? formatPaiseToRupeesInput(p.pricePaise) : '';
    final costRupeesStr = p != null ? formatPaiseToRupeesInput(p.costPaise) : '';

    _sellingPriceController = TextEditingController(text: sellingRupeesStr);
    _costPriceController = TextEditingController(text: costRupeesStr);

    _gstRateBp = p?.gstRateBp ?? 500; // Default 5%
    _trackStock = p?.trackStock ?? true;

    _openingStockController = TextEditingController(text: '');
    _reorderLevelController =
        TextEditingController(text: p != null ? formatMilliUnits(p.reorderLevel) : '0');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _hsnController.dispose();
    _sellingPriceController.dispose();
    _costPriceController.dispose();
    _openingStockController.dispose();
    _reorderLevelController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    final code = await BarcodeScannerDialog.show(context);
    if (code != null && code.isNotEmpty) {
      setState(() {
        _barcodeController.text = code;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(productRepositoryProvider);

    final name = _nameController.text.trim();
    final sellingPricePaise = parseRupeesToPaise(_sellingPriceController.text);
    if (sellingPricePaise == null || sellingPricePaise < 0) {
      setState(() {
        _errorMessage = l10n.priceRequired;
      });
      return;
    }

    final costPricePaise = parseRupeesToPaise(_costPriceController.text) ?? 0;
    final openingStockMilli = parseUnitsToMilli(_openingStockController.text) ?? 0;
    final reorderLevelMilli = parseUnitsToMilli(_reorderLevelController.text) ?? 0;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await repo.save(
        id: widget.item?.product.id,
        name: name,
        barcode: _barcodeController.text,
        hsn: _hsnController.text,
        gstRateBp: _gstRateBp,
        pricePaise: sellingPricePaise,
        costPaise: costPricePaise,
        trackStock: _trackStock,
        openingStockMilli: openingStockMilli,
        reorderLevel: reorderLevelMilli,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = e.toString().contains('Barcode already exists')
              ? l10n.duplicateBarcode
              : e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = widget.item != null;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? l10n.editItem : l10n.addItem,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (isEditing)
                      IconButton(
                        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        tooltip: l10n.archive,
                        onPressed: () async {
                          final nav = Navigator.of(context);
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(l10n.archive),
                              content: Text(l10n.confirmArchive),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: Text(l10n.cancel),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(
                                    l10n.archive,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && mounted) {
                            final repo = ref.read(productRepositoryProvider);
                            final productId = widget.item!.product.id;
                            await repo.archive(productId);
                            nav.pop(true);
                          }
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Item Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.itemName,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? l10n.nameRequired : null,
                ),
                const SizedBox(height: 16),

                // Barcode + Scan button
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _barcodeController,
                        decoration: InputDecoration(
                          labelText: l10n.barcode,
                          hintText: l10n.typeOrScanBarcode,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(88, 48), // min 48px touch height
                      ),
                      onPressed: _scanBarcode,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: Text(l10n.scanBarcode),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // HSN and GST Rate
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _hsnController,
                        decoration: InputDecoration(
                          labelText: l10n.hsn,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _gstRateBp,
                        decoration: InputDecoration(
                          labelText: l10n.gstRate,
                          border: const OutlineInputBorder(),
                        ),
                        items: _gstOptions.map((bp) {
                          final percentStr = formatGstRateBp(bp);
                          return DropdownMenuItem<int>(
                            value: bp,
                            child: Text('$percentStr%'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _gstRateBp = val;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Selling Price and Cost Price
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _sellingPriceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: l10n.sellingPrice,
                          hintText: '0.00',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || parseRupeesToPaise(v) == null) {
                            return l10n.priceRequired;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _costPriceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: l10n.costPrice,
                          hintText: '0.00',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Track Inventory Switch
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.trackStock),
                  value: _trackStock,
                  onChanged: (val) {
                    setState(() {
                      _trackStock = val;
                    });
                  },
                ),

                if (_trackStock) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (!isEditing)
                        Expanded(
                          child: TextFormField(
                            controller: _openingStockController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: l10n.openingStock,
                              hintText: '0',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      if (!isEditing) const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _reorderLevelController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: l10n.reorderLevel,
                            hintText: '0',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                // Action Buttons
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
