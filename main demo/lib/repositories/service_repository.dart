import '../models/service_model.dart';
import '../services/firestore_service.dart';

class ServiceRepository {
  final FirestoreService _firestoreService;

  ServiceRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Stream<List<ServiceModel>> streamServices() => _firestoreService.streamServices();

  Future<List<ServiceModel>> getServices() => _firestoreService.getServices();

  Future<void> saveService(ServiceModel service) => _firestoreService.saveService(service);

  Future<void> deleteService(String serviceId) => _firestoreService.deleteService(serviceId);
}
