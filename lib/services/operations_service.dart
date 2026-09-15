import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants.dart';
import '../models/branch_model.dart';
import '../models/service_model.dart';
import '../models/stylist_model.dart';
import 'firestore_service.dart';

class CustomerInsight {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> history;
  final String? preferredStylist;
  final String? mostBookedService;

  const CustomerInsight({
    required this.history,
    required this.preferredStylist,
    required this.mostBookedService,
  });

  bool get isReturning => history.isNotEmpty;
}

class OperationsService {
  final FirestoreService _firestore;

  OperationsService({FirestoreService? firestore})
    : _firestore = firestore ?? FirestoreService();

  Stream<QuerySnapshot<Map<String, dynamic>>> streamCustomers() {
    return _firestore.streamCollection(
      collection: FirestoreCollections.users,
      queryBuilder: (ref) => ref.where('role', isEqualTo: UserRoles.customer),
    );
  }

  Future<CustomerInsight> getCustomerInsight(String customerId) async {
    final result = await _firestore.queryCollection(
      collection: FirestoreCollections.serviceHistory,
      queryBuilder: (ref) => ref
          .where('customerId', isEqualTo: customerId)
          .orderBy('completedAt', descending: true),
    );

    final stylistCounts = <String, int>{};
    final serviceCounts = <String, int>{};
    for (final document in result.docs) {
      final data = document.data();
      final stylistId = data['stylistId'] as String?;
      final serviceId = data['serviceId'] as String?;
      if (stylistId != null) {
        stylistCounts[stylistId] = (stylistCounts[stylistId] ?? 0) + 1;
      }
      if (serviceId != null) {
        serviceCounts[serviceId] = (serviceCounts[serviceId] ?? 0) + 1;
      }
    }

    final stylistId = _mostFrequent(stylistCounts);
    final serviceId = _mostFrequent(serviceCounts);
    return CustomerInsight(
      history: result.docs,
      preferredStylist: await _lookupName(
        FirestoreCollections.stylists,
        stylistId,
      ),
      mostBookedService: await _lookupName(
        FirestoreCollections.services,
        serviceId,
      ),
    );
  }

  Future<String?> _lookupName(String collection, String? id) async {
    if (id == null) return null;
    final document = await _firestore.getDocument(
      collection: collection,
      documentId: id,
    );
    return document.data()?['name'] as String?;
  }

  String? _mostFrequent(Map<String, int> counts) {
    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(
    String collection, {
    Query<Map<String, dynamic>> Function(CollectionReference<Map<String, dynamic>>)? queryBuilder,
  }) {
    return _firestore.streamCollection(
      collection: collection,
      queryBuilder: queryBuilder,
    );
  }

  Future<void> save({
    required String collection,
    String? documentId,
    required Map<String, dynamic> data,
  }) async {
    final id = documentId ?? _firestore.autoIdDocRef(collection).id;
    await _firestore.setDocument(
      collection: collection,
      documentId: id,
      data: data,
    );
  }

  Future<void> delete({
    required String collection,
    required String documentId,
  }) {
    return _firestore.deleteDocument(
      collection: collection,
      documentId: documentId,
    );
  }

  BranchModel branchFrom(DocumentSnapshot<Map<String, dynamic>> doc) =>
      BranchModel.fromFirestore(doc);

  StylistModel stylistFrom(DocumentSnapshot<Map<String, dynamic>> doc) =>
      StylistModel.fromFirestore(doc);

  ServiceModel serviceFrom(DocumentSnapshot<Map<String, dynamic>> doc) =>
      ServiceModel.fromFirestore(doc);
}
