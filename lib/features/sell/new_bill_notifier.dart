import '../../core/activity_log.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/business_math.dart';
import '../../core/money.dart';
import '../../core/tax.dart';
import '../../data/records.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../data/repositories/product_repository.dart';

class CartLine {
  final ProductWithStock product;
  final int qtyMilli;
  final int ratePaise;
  final int discountPaise;
  final int gstRateBp;

  CartLine({
    required this.product,
    required this.qtyMilli,
    required this.ratePaise,
    this.discountPaise = 0,
    required this.gstRateBp,
  });

  int get grossPaise => divideRoundHalfUp(qtyMilli * ratePaise, 1000);
  int get amountAfterDiscount => grossPaise - discountPaise;

  CartLine copyWith({
    ProductWithStock? product,
    int? qtyMilli,
    int? ratePaise,
    int? discountPaise,
    int? gstRateBp,
  }) {
    return CartLine(
      product: product ?? this.product,
      qtyMilli: qtyMilli ?? this.qtyMilli,
      ratePaise: ratePaise ?? this.ratePaise,
      discountPaise: discountPaise ?? this.discountPaise,
      gstRateBp: gstRateBp ?? this.gstRateBp,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': product.product.id,
        'name': product.product.name,
        'hsn': product.product.hsn,
        'barcode': product.product.barcode,
        'costPaise': product.product.costPaise,
        'trackStock': product.product.trackStock,
        'reorderLevel': product.product.reorderLevel,
        'stockMilli': product.stockMilli,
        'qtyMilli': qtyMilli,
        'ratePaise': ratePaise,
        'discountPaise': discountPaise,
        'gstRateBp': gstRateBp,
      };

  factory CartLine.fromJson(Map<String, dynamic> json) {
    final p = Product(
      id: json['productId'] as String,
      businessId: kLocalBusinessId,
      name: json['name'] as String,
      barcode: json['barcode'] as String?,
      hsn: json['hsn'] as String,
      gstRateBp: json['gstRateBp'] as int,
      pricePaise: json['ratePaise'] as int,
      costPaise: json['costPaise'] as int? ?? 0,
      trackStock: json['trackStock'] as bool? ?? true,
      reorderLevel: json['reorderLevel'] as int? ?? 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final pws = ProductWithStock(
      product: p,
      stockMilli: json['stockMilli'] as int? ?? 0,
    );
    return CartLine(
      product: pws,
      qtyMilli: json['qtyMilli'] as int,
      ratePaise: json['ratePaise'] as int,
      discountPaise: json['discountPaise'] as int? ?? 0,
      gstRateBp: json['gstRateBp'] as int,
    );
  }
}

class NewBillState {
  final List<CartLine> lines;
  final Party? party;
  final String businessStateCode;
  final String paymentMethod; // 'cash', 'upi', 'card', 'credit'
  final int? customPaidAmountPaise;
  final bool isSaving;
  final String? error;
  final bool isLoaded;
  final String customerName; // optional, for walk-in bills

  NewBillState({
    this.lines = const [],
    this.party,
    this.businessStateCode = '',
    this.paymentMethod = 'cash',
    this.customPaidAmountPaise,
    this.isSaving = false,
    this.error,
    this.isLoaded = false,
    this.customerName = '',
  });

  /// Walk-in customers (no party) and parties without a state are billed as
  /// intra-state. Otherwise IGST applies only when the party's state differs
  /// from the business's own state.
  bool get isInterState =>
      party != null &&
      party!.stateCode.isNotEmpty &&
      businessStateCode.isNotEmpty &&
      party!.stateCode != businessStateCode;

  TaxCalculationResult get taxResult {
    return calculateTax(
      lines: lines
          .map((l) => TaxLineInput(
                qtyMilli: l.qtyMilli,
                ratePaise: l.ratePaise,
                discountPaise: l.discountPaise,
                gstRateBp: l.gstRateBp,
              ))
          .toList(),
      isInterState: isInterState,
    );
  }

  int get grandTotalPaise => taxResult.totalPaise;

  int get paidAmountPaise {
    if (customPaidAmountPaise != null) {
      return customPaidAmountPaise!;
    }
    if (paymentMethod == 'credit') {
      return 0;
    }
    return grandTotalPaise;
  }

  int get unpaidBalancePaise {
    final balance = grandTotalPaise - paidAmountPaise;
    return balance > 0 ? balance : 0;
  }

  NewBillState copyWith({
    List<CartLine>? lines,
    Party? party,
    bool clearParty = false,
    String? businessStateCode,
    String? paymentMethod,
    int? customPaidAmountPaise,
    bool clearCustomPaidAmount = false,
    bool? isSaving,
    String? error,
    bool clearError = false,
    bool? isLoaded,
    String? customerName,
  }) {
    return NewBillState(
      lines: lines ?? this.lines,
      party: clearParty ? null : (party ?? this.party),
      businessStateCode: businessStateCode ?? this.businessStateCode,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      customPaidAmountPaise: clearCustomPaidAmount
          ? null
          : (customPaidAmountPaise ?? this.customPaidAmountPaise),
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
      isLoaded: isLoaded ?? this.isLoaded,
      customerName: customerName ?? this.customerName,
    );
  }

  Map<String, dynamic> toDraftJson() {
    return {
      'lines': lines.map((l) => l.toJson()).toList(),
      'partyId': party?.id,
      'paymentMethod': paymentMethod,
      'customPaidAmountPaise': customPaidAmountPaise,
    };
  }
}

class NewBillNotifier extends StateNotifier<NewBillState> {
  final Ref ref;

  NewBillNotifier(this.ref) : super(NewBillState()) {
    loadDraft();
  }

  Future<void> loadDraft() async {
    final docRepo = ref.read(documentRepositoryProvider);
    final partyRepo = ref.read(partyRepositoryProvider);

    try {
      final draft = await docRepo.getDraftCart();
      if (draft != null && draft.cartJson.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(draft.cartJson);
        final savedLines = (map['lines'] as List<dynamic>?)
                ?.map((l) => CartLine.fromJson(l as Map<String, dynamic>))
                .toList() ??
            [];

        // Refresh each line from the live product: price, GST and stock may
        // have changed, and a deleted/archived product must not reach issue.
        final productRepo = ref.read(productRepositoryProvider);
        final linesList = <CartLine>[];
        for (final saved in savedLines) {
          final fresh = await productRepo.getById(saved.product.product.id);
          if (fresh == null) continue;
          var discount = saved.discountPaise;
          final gross = divideRoundHalfUp(saved.qtyMilli * fresh.product.pricePaise, 1000);
          if (discount > gross) discount = gross;
          linesList.add(CartLine(
            product: fresh,
            qtyMilli: saved.qtyMilli,
            ratePaise: fresh.product.pricePaise,
            discountPaise: discount,
            gstRateBp: fresh.product.gstRateBp,
          ));
        }

        Party? loadedParty;
        final partyId = draft.partyId ?? (map['partyId'] as String?);
        if (partyId != null) {
          loadedParty = await partyRepo.getById(partyId);
        }

        final paymentMethod = map['paymentMethod'] as String? ?? 'cash';
        final customPaidAmountPaise = map['customPaidAmountPaise'] as int?;

        if (!mounted) return;
        state = state.copyWith(
          lines: linesList,
          party: loadedParty,
          paymentMethod: paymentMethod,
          customPaidAmountPaise: customPaidAmountPaise,
          isLoaded: true,
        );
        return;
      }
    } catch (e) {
      debugPrint('Draft cart could not be restored: $e');
    }

    if (!mounted) return;
    state = state.copyWith(isLoaded: true);
  }

  Future<void> _persistDraft() async {
    if (!mounted) return;
    final docRepo = ref.read(documentRepositoryProvider);
    if (state.lines.isEmpty && state.party == null) {
      await docRepo.clearDraftCart();
    } else {
      await docRepo.saveDraftCart(
        partyId: state.party?.id,
        cartJson: jsonEncode(state.toDraftJson()),
      );
    }
  }

  void addProduct(ProductWithStock product) {
    final existingIndex = state.lines.indexWhere((l) => l.product.product.id == product.product.id);
    List<CartLine> newLines;
    if (existingIndex >= 0) {
      newLines = List.from(state.lines);
      final existingLine = newLines[existingIndex];
      newLines[existingIndex] = existingLine.copyWith(
        qtyMilli: existingLine.qtyMilli + 1000,
      );
    } else {
      newLines = [
        ...state.lines,
        CartLine(
          product: product,
          qtyMilli: 1000, // Default 1 unit
          ratePaise: product.product.pricePaise,
          gstRateBp: product.product.gstRateBp,
        ),
      ];
    }
    state = state.copyWith(lines: newLines, clearError: true);
    _persistDraft();
  }

  void updateLineQty(int index, int qtyMilli) {
    if (index < 0 || index >= state.lines.length) return;
    if (qtyMilli <= 0) {
      removeLine(index);
      return;
    }
    final newLines = List<CartLine>.from(state.lines);
    var updated = newLines[index].copyWith(qtyMilli: qtyMilli);
    if (updated.discountPaise > updated.grossPaise) {
      updated = updated.copyWith(discountPaise: updated.grossPaise);
    }
    newLines[index] = updated;
    state = state.copyWith(lines: newLines, clearError: true);
    _persistDraft();
  }

  void updateLineDiscount(int index, int discountPaise) {
    if (index < 0 || index >= state.lines.length) return;
    if (discountPaise < 0) {
      state = state.copyWith(error: 'Discount cannot be negative');
      return;
    }
    if (discountPaise > state.lines[index].grossPaise) {
      state = state.copyWith(error: 'Discount cannot be more than the item amount');
      return;
    }
    final newLines = List<CartLine>.from(state.lines);
    newLines[index] = newLines[index].copyWith(discountPaise: discountPaise);
    state = state.copyWith(lines: newLines, clearError: true);
    _persistDraft();
  }

  void removeLine(int index) {
    if (index < 0 || index >= state.lines.length) return;
    final newLines = List<CartLine>.from(state.lines);
    newLines.removeAt(index);
    state = state.copyWith(lines: newLines, clearError: true);
    _persistDraft();
  }

  void setCustomerName(String name) {
    state = state.copyWith(customerName: name);
  }

  void setParty(Party? party) {
    if (party == null) {
      state = state.copyWith(clearParty: true, clearError: true);
    } else {
      state = state.copyWith(party: party, clearError: true);
    }
    _persistDraft();
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(
      paymentMethod: method,
      clearCustomPaidAmount: true,
      clearError: true,
    );
    _persistDraft();
  }

  void setPaidAmountPaise(int? amountPaise) {
    if (amountPaise != null && amountPaise < 0) {
      state = state.copyWith(error: 'Paid amount cannot be negative');
      return;
    }
    state = state.copyWith(
      customPaidAmountPaise: amountPaise,
      clearError: true,
    );
    _persistDraft();
  }

  void setBusinessStateCode(String code) {
    if (code == state.businessStateCode) return;
    state = state.copyWith(businessStateCode: code);
  }

  /// Bill-level discount: spreads [totalDiscountPaise] over the lines in
  /// proportion to their amount (replaces any per-item discounts). 0 clears.
  void applyBillDiscount(int totalDiscountPaise) {
    if (state.lines.isEmpty) return;
    final gross = state.lines.map((l) => l.grossPaise).toList();
    final sum = gross.fold<int>(0, (a, b) => a + b);
    if (totalDiscountPaise < 0 || totalDiscountPaise > sum) {
      state = state.copyWith(error: 'Discount bill ke amount se zyada nahi ho sakta');
      return;
    }
    final parts = distributeDiscount(gross, totalDiscountPaise);
    final newLines = <CartLine>[
      for (var i = 0; i < state.lines.length; i++) state.lines[i].copyWith(discountPaise: parts[i]),
    ];
    state = state.copyWith(lines: newLines, clearError: true);
    _persistDraft();
  }

  int get currentDiscountPaise => state.lines.fold<int>(0, (a, l) => a + l.discountPaise);

  /// Saves the current cart as an estimate / quotation (no stock, no invoice
  /// number, no GST filing). Returns false if the cart is empty.
  Future<bool> saveAsEstimate() async {
    if (state.lines.isEmpty) return false;
    await ref.read(recordsRepositoryProvider).save(RecordKinds.estimate, {
      'party_id': state.party?.id,
      'party_name': state.party?.name ?? '',
      'lines': state.lines.map((l) => l.toJson()).toList(),
      'total_paise': state.grandTotalPaise,
    });
    return true;
  }

  /// Estimate that is being converted to a bill (marked 'billed' once issued).
  String? _estimateId;

  /// Replaces the cart with the lines of a saved estimate.
  Future<void> loadEstimate(AppRecord estimate) async {
    _estimateId = estimate.id;
    final docRepo = ref.read(documentRepositoryProvider);
    await docRepo.saveDraftCart(
      partyId: estimate.data['party_id'] as String?,
      cartJson: jsonEncode({
        'lines': estimate.data['lines'],
        'partyId': estimate.data['party_id'],
        'paymentMethod': 'cash',
        'customPaidAmountPaise': null,
      }),
    );
    await loadDraft();
  }

  Future<void> clearCart() async {
    final docRepo = ref.read(documentRepositoryProvider);
    await docRepo.clearDraftCart();
    _estimateId = null;
    state = NewBillState(isLoaded: true, businessStateCode: state.businessStateCode);
  }

  Future<Document?> issueInvoice() async {
    // Prevent double tap
    if (state.isSaving) return null;

    if (state.lines.isEmpty) {
      state = state.copyWith(error: 'Cart is empty');
      return null;
    }

    final totalPaise = state.grandTotalPaise;
    final paidPaise = state.paidAmountPaise;
    final unpaidBalance = totalPaise - paidPaise;

    if (paidPaise < 0) {
      state = state.copyWith(error: 'Paid amount cannot be negative');
      return null;
    }
    if (paidPaise > totalPaise) {
      state = state.copyWith(error: 'Paid amount cannot be more than the bill total');
      return null;
    }
    for (final l in state.lines) {
      if (l.qtyMilli <= 0 || l.discountPaise < 0 || l.discountPaise > l.grossPaise) {
        state = state.copyWith(error: 'Check quantity and discount of ${l.product.product.name}');
        return null;
      }
    }

    // Credit validation: party required if paymentMethod is 'credit' or unpaidBalance > 0
    if ((state.paymentMethod == 'credit' || unpaidBalance > 0) && state.party == null) {
      state = state.copyWith(error: 'Party is required for credit or unpaid balance');
      return null;
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final docRepo = ref.read(documentRepositoryProvider);

      final issueLines = state.lines.map((l) {
        return IssueDocumentLineParam(
          productId: l.product.product.id,
          name: l.product.product.name,
          hsn: l.product.product.hsn,
          qtyMilli: l.qtyMilli,
          ratePaise: l.ratePaise,
          discountPaise: l.discountPaise,
          gstRateBp: l.gstRateBp,
        );
      }).toList();

      final paymentsList = <PaymentParam>[];
      if (paidPaise > 0) {
        paymentsList.add(PaymentParam(
          method: state.paymentMethod,
          amountPaise: paidPaise,
        ));
      }

      final issuedDoc = await docRepo.issueInvoice(
        lines: issueLines,
        partyId: state.party?.id,
        isInterState: state.isInterState,
        payments: paymentsList,
        customerName: state.party == null ? state.customerName : null,
      );

      // The invoice is already saved. A failure while clearing the cart must not
      // show an error (a retry would issue the same bill twice).
      try {
        await docRepo.clearDraftCart();
      } catch (_) {}

      await _markEstimateBilled(issuedDoc.id);

      final discountPaise = issueLines.fold<int>(0, (a, l) => a + l.discountPaise);
      if (discountPaise > 0) {
        await logActivity(
          ref.read(recordsRepositoryProvider),
          'Discount given',
          '${issuedDoc.number} · ${formatRupees(discountPaise)} off',
        );
      }

      state = NewBillState(isLoaded: true, businessStateCode: state.businessStateCode);

      return issuedDoc;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return null;
    }
  }

  Future<void> _markEstimateBilled(String documentId) async {
    final id = _estimateId;
    _estimateId = null;
    if (id == null) return;
    try {
      final repo = ref.read(recordsRepositoryProvider);
      final e = await repo.get(id);
      if (e == null) return;
      await repo.save(
        RecordKinds.estimate,
        {...e.data, 'status': 'billed', 'billed_doc_id': documentId},
        id: id,
        createdAt: e.createdAt,
      );
    } catch (_) {
      // The bill is already issued; the estimate just stays 'open'.
    }
  }

  Future<bool> checkCreditLimitExceeded() async {
    final party = state.party;
    if (party == null || party.creditLimitPaise <= 0) return false;

    final partyRepo = ref.read(partyRepositoryProvider);
    final currentBalance = await partyRepo.getPartyBalancePaise(party.id);
    final newBalance = currentBalance + state.unpaidBalancePaise;

    return newBalance > party.creditLimitPaise;
  }
}

final newBillProvider = StateNotifierProvider<NewBillNotifier, NewBillState>((ref) {
  final notifier = NewBillNotifier(ref);
  // Keep the seller's own state code in sync with the business settings, so
  // CGST+SGST vs IGST is decided against the real business state.
  ref.listen<AsyncValue<Business?>>(activeBusinessProvider, (_, next) {
    final code = next.valueOrNull?.stateCode;
    if (code != null && code.isNotEmpty) notifier.setBusinessStateCode(code);
  }, fireImmediately: true);
  return notifier;
});
