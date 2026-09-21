import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_exceptions.dart';
import '../services/firestore_service.dart';

class StylistRepository {
  final FirestoreService _firestoreService;
  StylistRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchAllStylists() {
    return _firestoreService.streamCollection(collection: 'stylists');
  }

  Future<List<Map<String, dynamic>>> getAllStylists() async {
    try {
      final snapshot = await _firestoreService.queryCollection(collection: 'stylists');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw FirestoreException('Failed to load stylists: $e', code: 'stylist-load-failed');
    }
  }

  Future<void> createStylist(Map<String, dynamic> data) async {
    try {
      final docRef = _firestoreService.autoIdDocRef('stylists');
      await _firestoreService.setDocument(collection: 'stylists', documentId: docRef.id, data: data);
    } catch (e) {
      throw FirestoreException('Failed to create stylist: $e', code: 'stylist-create-failed');
    }
  }

  Future<void> updateStylist(String stylistId, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateDocument(collection: 'stylists', documentId: stylistId, data: data);
    } catch (e) {
      throw FirestoreException('Failed to update stylist: $e', code: 'stylist-update-failed');
    }
  }

  Future<void> deleteStylist(String stylistId) async {
    try {
      await _firestoreService.deleteDocument(collection: 'stylists', documentId: stylistId);
    } catch (e) {
      throw FirestoreException('Failed to delete stylist: $e', code: 'stylist-delete-failed');
    }
  }
}
