abstract class SyncRemote {
  Future<void> upsertBusiness(Map<String, dynamic> data);
  Future<void> upsertDevice(Map<String, dynamic> data);
  Future<void> upsertParty(Map<String, dynamic> data);
  Future<void> upsertProduct(Map<String, dynamic> data);

  Future<void> issueDocument({
    required Map<String, dynamic> business,
    required Map<String, dynamic> device,
    Map<String, dynamic>? party,
    required List<Map<String, dynamic>> products,
    required Map<String, dynamic> document,
    required List<Map<String, dynamic>> lines,
    required List<Map<String, dynamic>> payments,
    required List<Map<String, dynamic>> stockMovements,
    required String commandId,
  });

  Future<void> cancelDocument(String documentId);
}

/// Optional capabilities of a remote. Kept in a separate interface so existing
/// [SyncRemote] implementations (and test fakes) keep compiling.
abstract class SyncRemoteExtras {
  /// False while there is no signed-in session: nothing may be pushed (and
  /// nothing may be marked rejected) until the user signs in.
  bool get isReady;

  /// Appends a payment that is not part of an issue_document command
  /// (receive payment, advance). [party] is upserted first when present.
  Future<void> insertPayment({
    required Map<String, dynamic> payment,
    Map<String, dynamic>? party,
  });

  /// Appends a stock movement that is not part of an issue_document command
  /// (opening stock).
  Future<void> insertStockMovement(Map<String, dynamic> stockMovement);
}

/// Generic record store (suppliers, purchases, expenses ...). Separate
/// interface so existing fakes keep compiling.
abstract class SyncRemoteRecords {
  Future<void> upsertRecord(Map<String, dynamic> record);
}
