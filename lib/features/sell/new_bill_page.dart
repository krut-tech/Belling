import 'package:qr_flutter/qr_flutter.dart';
import '../../core/invoice_pdf.dart' show buildUpiQrUri;
import 'package:flutter/material.dart' hide Text;
import '../../core/theme/app_colors.dart';
import '../../core/widgets/belling_ui.dart';
import '../../core/widgets/motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money.dart';
import '../../core/tax.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../data/repositories/product_repository.dart';
import '../../l10n/app_localizations.dart';
import '../items/barcode_scanner_dialog.dart';
import '../items/item_form_dialog.dart';
import '../parties/party_form_dialog.dart';
import 'category_picker.dart';
import 'new_bill_notifier.dart';
import '../../core/tr_text.dart';
import '../../core/tr.dart';

class NewBillPage extends ConsumerStatefulWidget {
  const NewBillPage({super.key});

  @override
  ConsumerState<NewBillPage> createState() => _NewBillPageState();
}

class _NewBillPageState extends ConsumerState<NewBillPage> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _showBill = false; // false = pick items (category rail + grid)

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleBarcodeScanOrSubmit(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) return;

    final productRepo = ref.read(productRepositoryProvider);
    final foundProduct = await productRepo.getByBarcode(trimmed);

    if (foundProduct != null) {
      ref.read(newBillProvider.notifier).addProduct(foundProduct);
      _searchController.clear();
      setState(() {
        _searchQuery = '';
      });
    } else {
      _showUnknownBarcodeDialog(trimmed);
    }
  }

  Future<void> _scanBarcode() async {
    final code = await BarcodeScannerDialog.show(context);
    if (code != null && code.isNotEmpty) {
      await _handleBarcodeScanOrSubmit(code);
    }
  }

  Future<void> _showUnknownBarcodeDialog(String barcode) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.itemNotFound),
        content: Text('${l10n.itemNotFoundAddPrompt}\n\nBarcode: $barcode'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.add),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final created = await ItemFormDialog.show(context, initialBarcode: barcode);
      if (created == true && mounted) {
        final productRepo = ref.read(productRepositoryProvider);
        final newProduct = await productRepo.getByBarcode(barcode);
        if (newProduct != null && mounted) {
          ref.read(newBillProvider.notifier).addProduct(newProduct);
          _searchController.clear();
          setState(() {
            _searchQuery = '';
          });
        }
      }
    }
  }

  void _showSelectPartyDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _SelectPartySheet(
        onPartySelected: (party) {
          ref.read(newBillProvider.notifier).setParty(party);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showEditQtyDialog(int index, CartLine line) {
    final controller = TextEditingController(text: formatMilliUnits(line.qtyMilli));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${line.product.product.name} - Qty'),
        content: TextFormField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Quantity (units)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = parseUnitsToMilli(controller.text);
              if (val != null && val > 0) {
                ref.read(newBillProvider.notifier).updateLineQty(index, val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBillDiscountDialog() {
    final notifier = ref.read(newBillProvider.notifier);
    final bill = ref.read(newBillProvider);
    final gross = bill.lines.fold<int>(0, (a, l) => a + l.grossPaise);
    final c = TextEditingController(
      text: notifier.currentDiscountPaise > 0 ? formatPaiseToRupeesInput(notifier.currentDiscountPaise) : '',
    );
    var percent = false;
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Poore bill par discount'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Bill ka amount (GST se pehle): ${formatRupees(gross)}'),
            const SizedBox(height: 8),
            TextField(
              controller: c,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: percent ? 'Discount %' : 'Discount ₹'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Percent mein'),
              value: percent,
              onChanged: (v) => setS(() => percent = v),
            ),
            const Text('Ye sab items par barabar (amount ke hisaab se) baant diya jayega. Pehle ke item discount hat jayenge.', style: TextStyle(fontSize: 12)),
          ]),
          actions: [
            TextButton(
              onPressed: () {
                notifier.applyBillDiscount(0);
                Navigator.pop(ctx);
              },
              child: const Text('Hatao'),
            ),
            FilledButton(
              onPressed: () {
                int? paise;
                if (percent) {
                  final pct = double.tryParse(c.text.trim());
                  if (pct != null && pct >= 0 && pct <= 100) paise = (gross * pct / 100).round();
                } else {
                  paise = parseRupeesToPaise(c.text);
                }
                if (paise != null) notifier.applyBillDiscount(paise);
                Navigator.pop(ctx);
              },
              child: const Text('Lagao'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDiscountDialog(int index, CartLine line) {
    final currentRupees = line.discountPaise == 0
        ? ''
        : formatPaiseToRupeesInput(line.discountPaise);
    final controller = TextEditingController(text: currentRupees);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${line.product.product.name} - Discount'),
        content: TextFormField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Discount in ₹',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = parseRupeesToPaise(controller.text) ?? 0;
              ref.read(newBillProvider.notifier).updateLineDiscount(index, val);
              Navigator.pop(ctx);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final billState = ref.watch(newBillProvider);
    final showPicker = !_showBill || billState.lines.isEmpty;

    const tabularStyle = TextStyle(
      fontFeatures: [FontFeature.tabularFigures()],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newBill),
        actions: [
          if (billState.lines.isNotEmpty)
            IconButton(
              constraints: BoxConstraints(minWidth: 48, minHeight: 48),
              icon: Icon(Icons.percent),
              tooltip: tr(context, 'Poore bill par discount'),
              onPressed: _showBillDiscountDialog,
            ),
          if (billState.lines.isNotEmpty)
            IconButton(
              constraints: BoxConstraints(minWidth: 48, minHeight: 48),
              icon: Icon(Icons.request_quote_outlined),
              tooltip: tr(context, 'Estimate save karo'),
              onPressed: () async {
                final ok = await ref.read(newBillProvider.notifier).saveAsEstimate();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok ? 'Estimate save ho gaya (More > Estimates mein dekho)' : 'Cart khali hai'),
                ));
              },
            ),
          if (billState.lines.isNotEmpty && !showPicker)
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: AppColors.accent, textStyle: const TextStyle(fontWeight: FontWeight.w800)),
              onPressed: () => setState(() => _showBill = false),
              icon: const Icon(Icons.add),
              label: const Text('Add items'),
            ),
          if (billState.lines.isNotEmpty)
            IconButton(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear Cart',
              onPressed: () {
                ref.read(newBillProvider.notifier).clearCart();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search & Scan Box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: l10n.searchOrScan,
                      prefixIcon: const Icon(Icons.search),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: AppColors.lightBorder),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              tooltip: tr(context, 'Clear'),
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (v) {
                      setState(() {
                        _searchQuery = v;
                      });
                    },
                    onSubmitted: (v) => _handleBarcodeScanOrSubmit(v),
                  ),
                ),
                const SizedBox(width: 10),
                Tooltip(
                  message: l10n.scanBarcode,
                  child: Material(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _scanBarcode,
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(Icons.qr_code_scanner, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Dropdown Results if searching
          if (_searchQuery.trim().isNotEmpty)
            Expanded(
              child: _SearchResultsList(
                searchQuery: _searchQuery,
                onProductSelected: (product) {
                  ref.read(newBillProvider.notifier).addProduct(product);
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
              ),
            )
          else ...[
            // Picker mode: category rail + item grid with a slim cart bar.
            if (showPicker) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _partyBar(billState, l10n),
              ),
              if (billState.error != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: _errorBanner(billState),
                ),
              Expanded(
                child: CategoryPicker(
                  onAdd: (product) => ref.read(newBillProvider.notifier).addProduct(product),
                ),
              ),
              if (billState.lines.isNotEmpty)
                _CompactCartBar(
                  count: billState.lines.length,
                  totalPaise: billState.grandTotalPaise,
                  onReview: () => setState(() => _showBill = true),
                ),
            ] else ...[
              // Bill mode: everything scrolls, only the Issue button stays pinned.
              Expanded(
                child: ListView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  children: [
                    _partyBar(billState, l10n),
                    if (billState.party == null) ...[
                      const SizedBox(height: 10),
                      const _CustomerNameField(),
                    ],
                    if (billState.error != null) ...[
                      const SizedBox(height: 10),
                      _errorBanner(billState),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      'Bill (${billState.lines.length} items)',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    for (var i = 0; i < billState.lines.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _cartLine(billState, i, tabularStyle),
                      ),
                    const SizedBox(height: 6),
                    const _BillSummary(tabularStyle: tabularStyle),
                  ],
                ),
              ),
              const _IssueBar(),
            ],
          ],
        ],
      ),
    );
  }

  Widget _partyBar(NewBillState billState, AppLocalizations l10n) {
    return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _showSelectPartyDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.lightBorder),
                    ),
                    child: Row(
                      children: [
                        billState.party != null
                            ? MonoTile(initialsOf(billState.party!.name), color: tileColorFor(billState.party!.name), size: 36)
                            : const IconTile(icon: Icons.person_outline, color: AppColors.blue, background: AppColors.blueBg, size: 36),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                billState.party != null
                                    ? billState.party!.name
                                    : l10n.walkIn,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                              ),
                              Text(
                                billState.isInterState
                                    ? 'Dusre state ka grahak · IGST lagega'
                                    : (billState.party == null
                                        ? 'Bina party (cash) · CGST + SGST'
                                        : 'Same state · CGST + SGST'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: billState.isInterState ? AppColors.lightWarning : AppColors.lightMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.lightMuted),
                      ],
                    ),
                  ),
                ),
              );
  }

  Widget _errorBanner(NewBillState billState) {
    return Container(
                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.dueBg, borderRadius: BorderRadius.circular(14)),
                child: Text(
                  billState.error!,
                  style: const TextStyle(color: AppColors.lightDanger, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
              );
  }

  Widget _cartLine(NewBillState billState, int index, TextStyle tabularStyle) {
                        final line = billState.lines[index];
                        final lineTotal = divideRoundHalfUp(line.qtyMilli * line.ratePaise, 1000) - line.discountPaise;

                        return FadeSlideIn(key: ValueKey('fs_${line.product.product.id}_$index'), index: index, child: Dismissible(
                          key: ValueKey('${line.product.product.id}_$index'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            decoration: BoxDecoration(color: AppColors.lightDanger, borderRadius: BorderRadius.circular(18)),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            ref.read(newBillProvider.notifier).removeLine(index);
                          },
                          child: SoftCard(
                            padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        line.product.product.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, height: 1.2),
                                      ),
                                      const SizedBox(height: 2),
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          Text(
                                            '${formatRupees(line.ratePaise)} / unit',
                                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.lightMuted),
                                          ),
                                          if (line.discountPaise > 0)
                                            Text(
                                              'Disc: ${formatRupees(line.discountPaise)}',
                                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.lightSuccess),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Qty stepper pill
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.lightBackground,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                                        padding: EdgeInsets.zero,
                                        tooltip: tr(context, 'Quantity kam karo'),
                                        icon: const Icon(Icons.remove, size: 18),
                                        onPressed: () {
                                          final newQty = line.qtyMilli - 1000;
                                          ref.read(newBillProvider.notifier).updateLineQty(index, newQty);
                                        },
                                      ),
                                      InkWell(
                                        onTap: () => _showEditQtyDialog(index, line),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          constraints: const BoxConstraints(minWidth: 22),
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: Text(
                                            formatMilliUnits(line.qtyMilli),
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800).merge(tabularStyle),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                                        padding: EdgeInsets.zero,
                                        tooltip: 'Quantity badhao',
                                        icon: const Icon(Icons.add, size: 18),
                                        onPressed: () {
                                          ref.read(newBillProvider.notifier).updateLineQty(index, line.qtyMilli + 1000);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  constraints: const BoxConstraints(minWidth: 36, minHeight: 40),
                                  padding: EdgeInsets.zero,
                                  tooltip: 'Discount',
                                  icon: Icon(
                                    Icons.discount_outlined,
                                    size: 20,
                                    color: line.discountPaise > 0 ? AppColors.lightSuccess : AppColors.lightMuted,
                                  ),
                                  onPressed: () => _showEditDiscountDialog(index, line),
                                ),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(minWidth: 58),
                                  child: Text(
                                    formatRupees(lineTotal),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800).merge(tabularStyle),
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                            ),
                          ),
                        ));
  }
}

class _SearchResultsList extends ConsumerWidget {
  final String searchQuery;
  final ValueChanged<ProductWithStock> onProductSelected;

  const _SearchResultsList({
    required this.searchQuery,
    required this.onProductSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider(searchQuery));

    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                searchQuery.trim().isEmpty
                    ? 'Abhi koi item nahi hai. Items tab mein item add karo.'
                    : 'No matching items found',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return ListView.separated(
          itemCount: products.length,
          separatorBuilder: (ctx, idx) => const Divider(height: 1),
          itemBuilder: (ctx, index) {
            final p = products[index];
            return FadeSlideIn(index: index, child: ListTile(
              minVerticalPadding: 12, // 48px touch target
              title: Text(p.product.name),
              subtitle: Text(
                'Barcode: ${p.product.barcode ?? '-'} | Stock: ${formatMilliUnits(p.stockMilli)}',
              ),
              trailing: Text(
                formatRupees(p.product.pricePaise),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () => onProductSelected(p),
            ));
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}

class _SelectPartySheet extends ConsumerStatefulWidget {
  final ValueChanged<Party?> onPartySelected;

  const _SelectPartySheet({required this.onPartySelected});

  @override
  ConsumerState<_SelectPartySheet> createState() => _SelectPartySheetState();
}

class _SelectPartySheetState extends ConsumerState<_SelectPartySheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final partiesAsync = ref.watch(partiesWithBalanceStreamProvider(_search));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      builder: (ctx, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.selectParty,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(110, 48),
                  ),
                  onPressed: () async {
                    final party = await PartyFormDialog.show(context);
                    if (party != null) {
                      widget.onPartySelected(party);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addParty),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search party name or phone...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                setState(() {
                  _search = v;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            minVerticalPadding: 12,
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.walkIn, style: const TextStyle(fontWeight: FontWeight.bold)),
            onTap: () => widget.onPartySelected(null),
          ),
          const Divider(height: 1),
          Expanded(
            child: partiesAsync.when(
              data: (parties) {
                if (parties.isEmpty) {
                  return const Center(child: Text('No parties found'));
                }
                return ListView.separated(
                  controller: scrollController,
                  itemCount: parties.length,
                  separatorBuilder: (c, i) => const Divider(height: 1),
                  itemBuilder: (c, i) {
                    final item = parties[i];
                    final party = item.party;
                    final balancePaise = item.balancePaise;
                    return FadeSlideIn(index: i, child: ListTile(
                      minVerticalPadding: 12,
                      title: Text(party.name),
                      subtitle: Text('${party.phone}${party.gstin != null && party.gstin!.isNotEmpty ? " | GSTIN: ${party.gstin}" : ""}'),
                      trailing: balancePaise > 0
                          ? Text(
                              'You get ${formatRupees(balancePaise)}',
                              style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 13),
                            )
                          : (balancePaise < 0
                              ? Text(
                                  'You give ${formatRupees(balancePaise.abs())}',
                                  style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 13),
                                )
                              : null),
                      onTap: () => widget.onPartySelected(party),
                    ));
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _BillSummary extends ConsumerStatefulWidget {
  final TextStyle tabularStyle;

  const _BillSummary({required this.tabularStyle});

  @override
  ConsumerState<_BillSummary> createState() => _BillSummaryState();
}

class _BillSummaryState extends ConsumerState<_BillSummary> {
  final _paidAmountController = TextEditingController();

  @override
  void dispose() {
    _paidAmountController.dispose();
    super.dispose();
  }

  /// Shows the shop's UPI QR with the exact amount, so the customer can scan
  /// it and pay right away.
  void _showUpiQr() {
    final business = ref.read(activeBusinessProvider).valueOrNull;
    final upiId = business?.upiId?.trim() ?? '';
    final bill = ref.read(newBillProvider);
    final amount = bill.paidAmountPaise > 0 ? bill.paidAmountPaise : bill.grandTotalPaise;

    if (upiId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('UPI ID set nahi hai. More > Business settings mein UPI ID daalo.')),
      );
      return;
    }
    if (amount <= 0) return;

    final uri = buildUpiQrUri(
      upiId: upiId,
      sellerName: business?.name ?? 'Shop',
      number: 'Bill',
      balancePaise: amount,
      docType: 'invoice',
    );
    if (uri == null) return;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(business?.name ?? 'Pay via UPI', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              child: QrImageView(data: uri, size: 240, backgroundColor: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              formatRupees(amount),
              style: Theme.of(ctx).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('UPI ID: $upiId', style: Theme.of(ctx).textTheme.bodySmall),
            const SizedBox(height: 8),
            const Text(
              'Customer scan karke yahi amount pay kare. Payment aane ke baad Issue Invoice dabao.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final billState = ref.watch(newBillProvider);
    final taxRes = billState.taxResult;

    final defaultPaidRupees = formatPaiseToRupeesInput(billState.paidAmountPaise);
    if (_paidAmountController.text.isEmpty && billState.customPaidAmountPaise == null) {
      _paidAmountController.text = defaultPaidRupees;
    }

    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tax Breakdown Summary (Live calculateTax)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.taxableAmount, style: Theme.of(context).textTheme.bodySmall),
                  Text(formatRupees(taxRes.taxablePaise), style: widget.tabularStyle),
                ],
              ),
              const SizedBox(height: 2),
              if (!billState.isInterState) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.cgst, style: Theme.of(context).textTheme.bodySmall),
                    Text(formatRupees(taxRes.cgstPaise), style: widget.tabularStyle),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.sgst, style: Theme.of(context).textTheme.bodySmall),
                    Text(formatRupees(taxRes.sgstPaise), style: widget.tabularStyle),
                  ],
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.igst, style: Theme.of(context).textTheme.bodySmall),
                    Text(formatRupees(taxRes.igstPaise), style: widget.tabularStyle),
                  ],
                ),
              ],
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.roundOff, style: Theme.of(context).textTheme.bodySmall),
                  Text(formatRupees(taxRes.roundOffPaise), style: widget.tabularStyle),
                ],
              ),
              const Divider(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.grandTotal,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatRupees(billState.grandTotalPaise),
                    style: Theme.of(context).textTheme.titleLarge?.merge(widget.tabularStyle).copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Payment Method Chips
              Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.paymentMethod, style: Theme.of(context).textTheme.bodySmall),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                          _PaymentChip(
                            label: l10n.cash,
                            selected: billState.paymentMethod == 'cash',
                            onSelected: () => ref.read(newBillProvider.notifier).setPaymentMethod('cash'),
                          ),
                          _PaymentChip(
                            label: l10n.upi,
                            selected: billState.paymentMethod == 'upi',
                            onSelected: () {
                              ref.read(newBillProvider.notifier).setPaymentMethod('upi');
                              _showUpiQr();
                            },
                          ),
                          _PaymentChip(
                            label: l10n.card,
                            selected: billState.paymentMethod == 'card',
                            onSelected: () => ref.read(newBillProvider.notifier).setPaymentMethod('card'),
                          ),
                          _PaymentChip(
                            label: l10n.credit,
                            selected: billState.paymentMethod == 'credit',
                            onSelected: () => ref.read(newBillProvider.notifier).setPaymentMethod('credit'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (billState.paymentMethod == 'upi')
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _showUpiQr,
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text('UPI QR dikhao'),
                  ),
                ),
              const SizedBox(height: 12),

              // Paid Amount Input (Partial Payment)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _paidAmountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: l10n.paidAmount,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (v) {
                        final clean = v.replaceAll(RegExp(r'[,₹\s]'), '');
                        var valPaise = parseRupeesToPaise(clean);
                        // Typed but unreadable (e.g. "abc"): never fall back to "paid in full".
                        if (valPaise == null && clean.isNotEmpty) valPaise = 0;
                        ref.read(newBillProvider.notifier).setPaidAmountPaise(valPaise);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (billState.unpaidBalancePaise > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(l10n.unpaidBalance, style: Theme.of(context).textTheme.bodySmall),
                        Text(
                          formatRupees(billState.unpaidBalancePaise),
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
      ),
    );
  }
}

class _IssueBar extends ConsumerWidget {
  const _IssueBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final billState = ref.watch(newBillProvider);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 52, // 48px+ touch target
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: billState.isSaving
                      ? null
                      : () async {
                          final notifier = ref.read(newBillProvider.notifier);
                          final isExceeded = await notifier.checkCreditLimitExceeded();

                          if (isExceeded) {
                            if (!context.mounted) return;
                            final party = billState.party!;
                            final partyRepo = ref.read(partyRepositoryProvider);
                            final currentBalance = await partyRepo.getPartyBalancePaise(party.id);
                            final newBalance = currentBalance + billState.unpaidBalancePaise;

                            if (!context.mounted) return;
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(l10n.creditLimitExceeded),
                                content: Text(
                                  l10n.creditLimitWarningMsg(
                                    party.name,
                                    formatRupees(party.creditLimitPaise),
                                    formatRupees(newBalance),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(false),
                                    child: Text(l10n.cancel),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                    child: Text(l10n.proceedAnyway),
                                  ),
                                ],
                              ),
                            );

                            if (confirm != true) return;
                          }

                          final doc = await notifier.issueInvoice();
                          if (doc != null && context.mounted) {
                            context.go('/sell/done/${doc.id}');
                          }
                        },
                  child: billState.isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          l10n.issueInvoice,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _PaymentChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
    );
  }
}


/// Optional customer name for bills without a saved party.
class _CustomerNameField extends ConsumerStatefulWidget {
  const _CustomerNameField();

  @override
  ConsumerState<_CustomerNameField> createState() => _CustomerNameFieldState();
}

class _CustomerNameFieldState extends ConsumerState<_CustomerNameField> {
  late final TextEditingController _c = TextEditingController(text: ref.read(newBillProvider).customerName);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The cart was cleared (bill issued): clear the field too.
    ref.listen<String>(newBillProvider.select((s) => s.customerName), (_, next) {
      if (next.isEmpty && _c.text.isNotEmpty) _c.clear();
    });
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: TextField(
        controller: _c,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Customer name (optional)',
          prefixIcon: Icon(Icons.badge_outlined),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          border: OutlineInputBorder(),
        ),
        onChanged: (v) => ref.read(newBillProvider.notifier).setCustomerName(v),
      ),
    );
  }
}


/// Slim cart summary shown while picking items.
class _CompactCartBar extends StatelessWidget {
  const _CompactCartBar({required this.count, required this.totalPaise, required this.onReview});

  final int count;
  final int totalPaise;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEADFCB))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$count items', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6B6894))),
                  Text(formatRupees(totalPaise), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(140, 52), backgroundColor: const Color(0xFF1F1B4B)),
              onPressed: onReview,
              child: const Text('Review bill', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}
