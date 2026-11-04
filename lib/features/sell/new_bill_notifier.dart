import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/tax.dart';
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

  NewBillState({
    this.lines = const [],
    this.party,
    this.businessStateCode = '27',
    this.paymentMethod = 'cash',
    this.customPaidAmountPaise,
    this.isSaving = false,
    this.error,
    this.isLoaded = false,
  });

  bool get isInterState => party != null && party!.stateCode != businessStateCode;

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
        final linesList = (map['lines'] as List<dynamic>?)
                ?.map((l) => CartLine.fromJson(l as Map<String, dynamic>))
                .toList() ??
            [];

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
    } catch (_) {}

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
    newLines[index] = newLines[index].copyWith(qtyMilli: qtyMilli);
    state = state.copyWith(lines: newLines, clearError: true);
    _persistDraft();
  }

  void updateLineDiscount(int index, int discountPaise) {
    if (index < 0 || index >= state.lines.length) return;
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
    state = state.copyWith(
      customPaidAmountPaise: amountPaise,
      clearError: true,
    );
    _persistDraft();
  }

  Future<void> clearCart() async {
    final docRepo = ref.read(documentRepositoryProvider);
    await docRepo.clearDraftCart();
    state = NewBillState(isLoaded: true);
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
      );

      await docRepo.clearDraftCart();

      state = NewBillState(isLoaded: true);

      return issuedDoc;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return null;
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
  return NewBillNotifier(ref);
});
