import '../services/firestore_service.dart';

/// Repository Layer: Handles fetching branch data for reference.
class BranchRepository {
  final FirestoreService _firestoreService;

  BranchRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  /// Fetches all branches from the `branches` collection.
  Future<List<Map<String, dynamic>>> getAllBranches() async {
    final result = await _firestoreService.queryCollection(
      collection: 'branches',
    );
    return result.docs.map((doc) => doc.data()).toList();
  }
}