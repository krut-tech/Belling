import 'package:flutter/material.dart';
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
import 'new_bill_notifier.dart';

class NewBillPage extends ConsumerStatefulWidget {
  const NewBillPage({super.key});

  @override
  ConsumerState<NewBillPage> createState() => _NewBillPageState();
}

class _NewBillPageState extends ConsumerState<NewBillPage> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _searchQuery = '';

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

    const tabularStyle = TextStyle(
      fontFeatures: [FontFeature.tabularFigures()],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newBill),
        actions: [
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: l10n.searchOrScan,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              tooltip: 'Clear',
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
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(88, 56), // Touch target 48px+
                  ),
                  onPressed: _scanBarcode,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(l10n.scanBarcode),
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
            // Party Selector Bar
            InkWell(
              onTap: _showSelectPartyDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(80),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            billState.party != null
                                ? billState.party!.name
                                : l10n.walkIn,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            billState.isInterState
                                ? 'Dusre state ka grahak · IGST lagega'
                                : (billState.party == null
                                    ? 'Bina party (cash) · CGST + SGST'
                                    : 'Same state · CGST + SGST'),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: billState.isInterState ? Colors.orange.shade800 : Colors.grey.shade700,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),

            if (billState.error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Colors.red.shade100,
                child: Text(
                  billState.error!,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

            // Cart Items List
            Expanded(
              child: billState.lines.isEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Text(
                            'Item par tap karke bill mein jodo',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey.shade700),
                          ),
                        ),
                        Expanded(
                          child: _SearchResultsList(
                            searchQuery: '',
                            onProductSelected: (product) {
                              ref.read(newBillProvider.notifier).addProduct(product);
                            },
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: billState.lines.length,
                      separatorBuilder: (ctx, idx) => const Divider(height: 1),
                      itemBuilder: (ctx, index) {
                        final line = billState.lines[index];
                        final lineTotal = divideRoundHalfUp(line.qtyMilli * line.ratePaise, 1000) - line.discountPaise;

                        return FadeSlideIn(key: ValueKey('fs_${line.product.product.id}_$index'), index: index, child: Dismissible(
                          key: ValueKey('${line.product.product.id}_$index'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            ref.read(newBillProvider.notifier).removeLine(index);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row 1: full-width name + line total
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        line.product.product.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      formatRupees(lineTotal),
                                      textAlign: TextAlign.right,
                                      style: Theme.of(context).textTheme.titleMedium?.merge(tabularStyle).copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                // Row 2: rate / discount on the left, controls on the right
                                Row(
                                  children: [
                                    Expanded(
                                      child: Wrap(
                                        spacing: 8,
                                        children: [
                                          Text(
                                            '${formatRupees(line.ratePaise)} / unit',
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                          if (line.discountPaise > 0)
                                            Text(
                                              'Disc: ${formatRupees(line.discountPaise)}',
                                              style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                                            ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                                      tooltip: 'Quantity kam karo',
                                      icon: const Icon(Icons.remove_circle_outline),
                                      onPressed: () {
                                        final newQty = line.qtyMilli - 1000;
                                        ref.read(newBillProvider.notifier).updateLineQty(index, newQty);
                                      },
                                    ),
                                    InkWell(
                                      onTap: () => _showEditQtyDialog(index, line),
                                      child: Container(
                                        constraints: const BoxConstraints(minWidth: 36),
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey.shade400),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          formatMilliUnits(line.qtyMilli),
                                          style: Theme.of(context).textTheme.titleSmall?.merge(tabularStyle),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                                      tooltip: 'Quantity badhao',
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: () {
                                        ref.read(newBillProvider.notifier).updateLineQty(index, line.qtyMilli + 1000);
                                      },
                                    ),
                                    IconButton(
                                      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                                      tooltip: 'Discount',
                                      icon: Icon(
                                        Icons.discount,
                                        color: line.discountPaise > 0 ? Colors.green : Colors.grey,
                                      ),
                                      onPressed: () => _showEditDiscountDialog(index, line),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ));
                      },
                    ),
            ),

            // Bottom Summary & Payment Section
            if (billState.lines.isNotEmpty) const _BottomTaxAndPaymentSection(tabularStyle: tabularStyle),
          ],
        ],
      ),
    );
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

class _BottomTaxAndPaymentSection extends ConsumerStatefulWidget {
  final TextStyle tabularStyle;

  const _BottomTaxAndPaymentSection({required this.tabularStyle});

  @override
  ConsumerState<_BottomTaxAndPaymentSection> createState() => _BottomTaxAndPaymentSectionState();
}

class _BottomTaxAndPaymentSectionState extends ConsumerState<_BottomTaxAndPaymentSection> {
  final _paidAmountController = TextEditingController();

  @override
  void dispose() {
    _paidAmountController.dispose();
    super.dispose();
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

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
              Row(
                children: [
                  Text('${l10n.paymentMethod}: ', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                          _PaymentChip(
                            label: l10n.cash,
                            selected: billState.paymentMethod == 'cash',
                            onSelected: () => ref.read(newBillProvider.notifier).setPaymentMethod('cash'),
                          ),
                          _PaymentChip(
                            label: l10n.upi,
                            selected: billState.paymentMethod == 'upi',
                            onSelected: () => ref.read(newBillProvider.notifier).setPaymentMethod('upi'),
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
                        final valPaise = parseRupeesToPaise(v);
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
              const SizedBox(height: 16),

              // Issue Invoice Button (Disabled when saving to prevent double-tap)
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
