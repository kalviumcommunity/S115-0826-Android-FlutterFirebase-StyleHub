import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_exceptions.dart';
import '../services/firestore_service.dart';

class ServiceRepository {
  final FirestoreService _firestoreService;
  ServiceRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchAllServices() {
    return _firestoreService.streamCollection(collection: 'services');
  }

  Future<List<Map<String, dynamic>>> getAllServices() async {
    try {
      final snapshot = await _firestoreService.queryCollection(collection: 'services');
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw FirestoreException('Failed to load services: $e', code: 'service-load-failed');
    }
  }

  Future<void> createService(Map<String, dynamic> data) async {
    try {
      final docRef = _firestoreService.autoIdDocRef('services');
      await _firestoreService.setDocument(collection: 'services', documentId: docRef.id, data: data);
    } catch (e) {
      throw FirestoreException('Failed to create service: $e', code: 'service-create-failed');
    }
  }

  Future<void> updateService(String serviceId, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateDocument(collection: 'services', documentId: serviceId, data: data);
    } catch (e) {
      throw FirestoreException('Failed to update service: $e', code: 'service-update-failed');
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      await _firestoreService.deleteDocument(collection: 'services', documentId: serviceId);
    } catch (e) {
      throw FirestoreException('Failed to delete service: $e', code: 'service-delete-failed');
    }
  }
}
