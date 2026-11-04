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
