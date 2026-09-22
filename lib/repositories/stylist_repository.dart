import '../models/stylist_model.dart';
import '../services/firestore_service.dart';

class StylistRepository {
  final FirestoreService _firestoreService;

  StylistRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Stream<List<StylistModel>> streamStylists({String? branchId}) =>
      _firestoreService.streamStylists(branchId: branchId);

  Future<List<StylistModel>> getStylists({String? branchId}) =>
      _firestoreService.getStylists(branchId: branchId);

  Future<void> saveStylist(StylistModel stylist) =>
      _firestoreService.saveStylist(stylist);

  Future<void> deleteStylist(String stylistId) =>
      _firestoreService.deleteStylist(stylistId);
}
