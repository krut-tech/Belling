import '../../core/activity_log.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/categories.dart';
import '../../core/money.dart';
import '../../data/providers.dart';
import '../../data/repositories/product_repository.dart';
import '../../l10n/app_localizations.dart';
import 'barcode_scanner_dialog.dart';
import '../../core/tr_text.dart';

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
  late TextEditingController _categoryController;
  List<String> _knownCategories = const [];

  late int _gstRateBp;
  late bool _trackStock;
  bool _isSaving = false;
  bool _savedAny = false;
  late bool _moreOpen;
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

    _moreOpen = (widget.initialBarcode ?? p?.barcode ?? '').isNotEmpty ||
        (p?.hsn ?? '').isNotEmpty ||
        (p?.costPaise ?? 0) > 0;
    _gstRateBp = p?.gstRateBp ?? 500; // Default 5%
    _trackStock = p?.trackStock ?? true;

    _categoryController = TextEditingController();
    _loadCategories(p?.id);

    _openingStockController = TextEditingController(text: '');
    _reorderLevelController =
        TextEditingController(text: p != null ? formatMilliUnits(p.reorderLevel) : '0');
  }

  Future<void> _loadCategories(String? productId) async {
    try {
      final metas = await ref.read(businessRepositoryProvider).itemMetas();
      final all = <String>{
        for (final m in metas.values)
          if (m.str('category').trim().isNotEmpty) m.str('category').trim(),
      }.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      if (!mounted) return;
      setState(() {
        _knownCategories = all;
        if (productId != null && _categoryController.text.isEmpty) {
          _categoryController.text = metas[productId]?.str('category') ?? '';
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _nameController.dispose();
    _barcodeController.dispose();
    _hsnController.dispose();
    _sellingPriceController.dispose();
    _costPriceController.dispose();
    _openingStockController.dispose();
    _reorderLevelController.dispose();
    super.dispose();
  }

  Future<void> _openCategorySheet() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CategorySheet(
        known: _knownCategories,
        current: _categoryController.text,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _categoryController.text = picked;
        if (picked.isNotEmpty && !_knownCategories.contains(picked)) {
          _knownCategories = [..._knownCategories, picked];
        }
      });
    }
  }

  Widget _categorySection() {
    final cur = splitCategory(_categoryController.text);
    final parents = <String>{
      for (final c in _knownCategories) splitCategory(c).parent,
      if (cur.parent.isNotEmpty) cur.parent,
    }.where((e) => e.isNotEmpty).toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final children = <String>{
      for (final c in _knownCategories)
        if (splitCategory(c).parent == cur.parent && splitCategory(c).child != null)
          splitCategory(c).child!,
    }.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Category', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            TextButton.icon(
              onPressed: _openCategorySheet,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New'),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final c in parents)
              ChoiceChip(
                label: Text(c),
                selected: cur.parent == c,
                onSelected: (sel) => setState(
                    () => _categoryController.text = sel ? c : ''),
              ),
          ],
        ),
        if (cur.parent.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Inside ${cur.parent}:',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              for (final c in children)
                ChoiceChip(
                  label: Text(c),
                  visualDensity: VisualDensity.compact,
                  selected: cur.child == c,
                  onSelected: (sel) => setState(() =>
                      _categoryController.text = joinCategory(cur.parent, sel ? c : null)),
                ),
              ActionChip(
                avatar: const Icon(Icons.add, size: 16),
                label: const Text('Sub'),
                visualDensity: VisualDensity.compact,
                onPressed: _openCategorySheet,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _scanBarcode() async {
    final code = await BarcodeScannerDialog.show(context);
    if (code != null && code.isNotEmpty) {
      setState(() {
        _barcodeController.text = code;
      });
    }
  }

  Future<void> _save({bool addNext = false}) async {
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
      final saved = await repo.save(
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

      final cat = _categoryController.text.trim();
      if (cat.isNotEmpty || widget.item != null) {
        try {
          await ref.read(businessRepositoryProvider).saveItemCategory(saved.id, cat);
        } catch (_) {}
      }

      _savedAny = true;
      if (!mounted) return;
      if (addNext) {
        setState(() {
          _isSaving = false;
          _nameController.clear();
          _barcodeController.clear();
          _sellingPriceController.clear();
          _costPriceController.clear();
          _openingStockController.clear();
        });
        _loadCategories(null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved: $name'), duration: const Duration(seconds: 1)),
        );
      } else {
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
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
                            await logActivity(ref.read(recordsRepositoryProvider), 'Item deleted', widget.item!.product.name);
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
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: l10n.itemName,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? l10n.nameRequired : null,
                ),
                const SizedBox(height: 16),

                // Selling price
                TextFormField(
                  controller: _sellingPriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.sellingPrice,
                    hintText: '0.00',
                    prefixText: '₹ ',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || parseRupeesToPaise(v) == null) {
                      return l10n.priceRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // GST rate chips
                Text(l10n.gstRate, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final bp in _gstOptions)
                      ChoiceChip(
                        label: Text('${formatGstRateBp(bp)}%'),
                        selected: _gstRateBp == bp,
                        onSelected: (_) => setState(() => _gstRateBp = bp),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Category chips + "New" sheet
                _categorySection(),
                const SizedBox(height: 8),

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

                const SizedBox(height: 8),
                // More details (barcode, HSN, cost price)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: _moreOpen,
                      title: const Text('More details'),
                      subtitle: const Text('Barcode · HSN · Cost price'),
                      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      children: [
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
                              style: OutlinedButton.styleFrom(minimumSize: const Size(88, 48)),
                              onPressed: _scanBarcode,
                              icon: const Icon(Icons.qr_code_scanner),
                              label: Text(l10n.scanBarcode),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
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
                              child: TextFormField(
                                controller: _costPriceController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  labelText: l10n.costPrice,
                                  hintText: '0.00',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

              ],
            ),
          ),
        ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: const Size(80, 48),
                      ),
                      onPressed: () => Navigator.of(context).pop(_savedAny ? true : null),
                      child: Text(l10n.cancel),
                    ),
                    if (!isEditing) ...[
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(minimumSize: const Size(80, 48)),
                        onPressed: _isSaving ? null : () => _save(addNext: true),
                        child: const Text('Save & next'),
                      ),
                    ],
                    const SizedBox(width: 8),
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
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet to pick or create a category / sub-category.
class _CategorySheet extends StatefulWidget {
  final List<String> known;
  final String current;
  const _CategorySheet({required this.known, required this.current});

  @override
  State<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends State<_CategorySheet> {
  late String _parent;
  String? _child;
  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final c = splitCategory(widget.current);
    _parent = c.parent;
    _child = c.child;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  List<String> get _parents => <String>{
        for (final c in widget.known) splitCategory(c).parent,
        if (_parent.isNotEmpty) _parent,
      }.where((e) => e.isNotEmpty).toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  List<String> get _children => <String>{
        for (final c in widget.known)
          if (splitCategory(c).parent == _parent && splitCategory(c).child != null)
            splitCategory(c).child!,
        if (_child != null) _child!,
      }.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  void _addTyped({required bool asChild}) {
    final t = _nameCtrl.text.trim().replaceAll('>', ' ').trim();
    if (t.isEmpty) return;
    setState(() {
      if (asChild && _parent.isNotEmpty) {
        _child = t;
      } else {
        _parent = t;
        _child = null;
      }
      _nameCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final result = joinCategory(_parent, _child);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Category chuno', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Flexible(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final c in _parents)
                        ChoiceChip(
                          label: Text(c),
                          selected: _parent == c,
                          onSelected: (_) => setState(() {
                            _parent = c;
                            _child = null;
                          }),
                        ),
                    ],
                  ),
                  if (_parent.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text('Inside $_parent',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        for (final c in _children)
                          ChoiceChip(
                            label: Text(c),
                            selected: _child == c,
                            onSelected: (sel) => setState(() => _child = sel ? c : null),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nayi category / sub-category ka naam',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTyped(asChild: false),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _addTyped(asChild: false),
                          child: const Text('+ Category'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _parent.isEmpty ? null : () => _addTyped(asChild: true),
                          child: Text(_parent.isEmpty ? '+ Sub' : '+ Sub in $_parent'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, ''),
                child: const Text('Koi nahi'),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(120, 48)),
                onPressed: () => Navigator.pop(context, result),
                child: Text(result.isEmpty ? 'Done' : 'Chuno: ${result.replaceAll(kCategorySeparator, ' › ')}'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
