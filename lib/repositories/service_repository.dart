import '../services/firestore_service.dart';

/// Repository Layer: Handles fetching service data for reference.
class ServiceRepository {
  final FirestoreService _firestoreService;

  ServiceRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  /// Fetches all services from the `services` collection.
  Future<List<Map<String, dynamic>>> getAllServices() async {
    final result = await _firestoreService.queryCollection(
      collection: 'services',
    );
    return result.docs.map((doc) => doc.data()).toList();
  }
}