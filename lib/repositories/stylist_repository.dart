import '../services/firestore_service.dart';

/// Repository Layer: Handles fetching stylist data for reference.
class StylistRepository {
  final FirestoreService _firestoreService;

  StylistRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  /// Fetches all stylists from the `stylists` collection.
  Future<List<Map<String, dynamic>>> getAllStylists() async {
    final result = await _firestoreService.queryCollection(
      collection: 'stylists',
    );
    return result.docs.map((doc) => doc.data()).toList();
  }
}