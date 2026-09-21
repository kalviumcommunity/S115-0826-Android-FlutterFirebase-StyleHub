import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_exceptions.dart';
import '../services/firestore_service.dart';

class BranchRepository {
  final FirestoreService _firestoreService;
  BranchRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchAllBranches() {
    return _firestoreService.streamCollection(collection: 'branches');
  }

  Future<List<Map<String, dynamic>>> getAllBranches() async {
    try {
      final snapshot = await _firestoreService.queryCollection(collection: 'branches');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw FirestoreException('Failed to load branches: $e', code: 'branch-load-failed');
    }
  }

  Future<void> createBranch(Map<String, dynamic> data) async {
    try {
      final docRef = _firestoreService.autoIdDocRef('branches');
      await _firestoreService.setDocument(collection: 'branches', documentId: docRef.id, data: data);
    } catch (e) {
      throw FirestoreException('Failed to create branch: $e', code: 'branch-create-failed');
    }
  }

  Future<void> updateBranch(String branchId, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateDocument(collection: 'branches', documentId: branchId, data: data);
    } catch (e) {
      throw FirestoreException('Failed to update branch: $e', code: 'branch-update-failed');
    }
  }

  Future<void> deleteBranch(String branchId) async {
    try {
      await _firestoreService.deleteDocument(collection: 'branches', documentId: branchId);
    } catch (e) {
      throw FirestoreException('Failed to delete branch: $e', code: 'branch-delete-failed');
    }
  }
}
