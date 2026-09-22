import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exceptions.dart';
import '../models/user_model.dart';
import '../models/branch_model.dart';
import '../models/stylist_model.dart';
import '../models/service_model.dart';
import '../models/appointment_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection References
  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection(AppConstants.usersCollection);
  CollectionReference<Map<String, dynamic>> get _branchesCol =>
      _firestore.collection(AppConstants.branchesCollection);
  CollectionReference<Map<String, dynamic>> get _stylistsCol =>
      _firestore.collection(AppConstants.stylistsCollection);
  CollectionReference<Map<String, dynamic>> get _servicesCol =>
      _firestore.collection(AppConstants.servicesCollection);
  CollectionReference<Map<String, dynamic>> get _appointmentsCol =>
      _firestore.collection(AppConstants.appointmentsCollection);

  // ----------------------------------------------------
  // USER PROFILES (Centralized Identity)
  // ----------------------------------------------------
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _usersCol.doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw FirestoreException('Failed to retrieve user profile: $e');
    }
  }

  Stream<UserModel?> streamUserProfile(String uid) {
    return _usersCol.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  Future<void> createUserProfile(UserModel user) async {
    try {
      await _usersCol.doc(user.uid).set(user.toMap());
    } catch (e) {
      throw FirestoreException('Failed to create user record: $e');
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _usersCol.doc(uid).update(data);
    } catch (e) {
      throw FirestoreException('Failed to update user profile: $e');
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final snap = await _usersCol.get();
      return snap.docs.map((d) => UserModel.fromFirestore(d)).toList();
    } catch (e) {
      throw FirestoreException('Failed to fetch users: $e');
    }
  }

  // ----------------------------------------------------
  // BRANCHES
  // ----------------------------------------------------
  Stream<List<BranchModel>> streamBranches() {
    return _branchesCol.snapshots().map(
      (snap) => snap.docs.map((d) => BranchModel.fromFirestore(d)).toList(),
    );
  }

  Future<List<BranchModel>> getBranches() async {
    try {
      final snap = await _branchesCol.get();
      return snap.docs.map((d) => BranchModel.fromFirestore(d)).toList();
    } catch (e) {
      throw FirestoreException('Failed to fetch branches: $e');
    }
  }

  Future<void> saveBranch(BranchModel branch) async {
    try {
      await _branchesCol.doc(branch.branchId).set(branch.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException('Failed to save branch: $e');
    }
  }

  Future<void> deleteBranch(String branchId) async {
    try {
      await _branchesCol.doc(branchId).delete();
    } catch (e) {
      throw FirestoreException('Failed to delete branch: $e');
    }
  }

  // ----------------------------------------------------
  // STYLISTS
  // ----------------------------------------------------
  Stream<List<StylistModel>> streamStylists({String? branchId}) {
    Query<Map<String, dynamic>> query = _stylistsCol;
    if (branchId != null && branchId.isNotEmpty) {
      query = query.where('branchId', isEqualTo: branchId);
    }
    return query.snapshots().map(
      (snap) => snap.docs.map((d) => StylistModel.fromFirestore(d)).toList(),
    );
  }

  Future<List<StylistModel>> getStylists({String? branchId}) async {
    try {
      Query<Map<String, dynamic>> query = _stylistsCol;
      if (branchId != null && branchId.isNotEmpty) {
        query = query.where('branchId', isEqualTo: branchId);
      }
      final snap = await query.get();
      return snap.docs.map((d) => StylistModel.fromFirestore(d)).toList();
    } catch (e) {
      throw FirestoreException('Failed to fetch stylists: $e');
    }
  }

  Future<void> saveStylist(StylistModel stylist) async {
    try {
      await _stylistsCol.doc(stylist.stylistId).set(stylist.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException('Failed to save stylist: $e');
    }
  }

  Future<void> deleteStylist(String stylistId) async {
    try {
      await _stylistsCol.doc(stylistId).delete();
    } catch (e) {
      throw FirestoreException('Failed to delete stylist: $e');
    }
  }

  // ----------------------------------------------------
  // SERVICES
  // ----------------------------------------------------
  Stream<List<ServiceModel>> streamServices() {
    return _servicesCol.snapshots().map(
      (snap) => snap.docs.map((d) => ServiceModel.fromFirestore(d)).toList(),
    );
  }

  Future<List<ServiceModel>> getServices() async {
    try {
      final snap = await _servicesCol.get();
      return snap.docs.map((d) => ServiceModel.fromFirestore(d)).toList();
    } catch (e) {
      throw FirestoreException('Failed to fetch services: $e');
    }
  }

  Future<void> saveService(ServiceModel service) async {
    try {
      await _servicesCol.doc(service.serviceId).set(service.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException('Failed to save service: $e');
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      await _servicesCol.doc(serviceId).delete();
    } catch (e) {
      throw FirestoreException('Failed to delete service: $e');
    }
  }

  // ----------------------------------------------------
  // APPOINTMENTS & CENTRALIZED CROSS-BRANCH HISTORY
  // ----------------------------------------------------
  Stream<List<AppointmentModel>> streamCustomerAppointments(String customerUid) {
    return _appointmentsCol
        .where('customerId', isEqualTo: customerUid)
        .snapshots()
        .map((snap) => snap.docs.map((d) => AppointmentModel.fromFirestore(d)).toList());
  }

  Stream<List<AppointmentModel>> streamBranchAppointments(String branchId) {
    return _appointmentsCol
        .where('branchId', isEqualTo: branchId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => AppointmentModel.fromFirestore(d)).toList());
  }

  Stream<List<AppointmentModel>> streamAllAppointments() {
    return _appointmentsCol.snapshots().map(
      (snap) => snap.docs.map((d) => AppointmentModel.fromFirestore(d)).toList(),
    );
  }

  Future<void> createAppointment(AppointmentModel appointment) async {
    try {
      await _appointmentsCol.doc(appointment.appointmentId).set(appointment.toMap());
    } catch (e) {
      throw FirestoreException('Failed to create booking: $e');
    }
  }

  Future<void> updateAppointmentStatus(String appointmentId, String newStatus) async {
    try {
      await _appointmentsCol.doc(appointmentId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreException('Failed to update booking status: $e');
    }
  }
}
