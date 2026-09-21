import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

class CustomerInsight {
  final int totalVisits;
  final String? preferredStylist;
  final String? mostBookedService;
  final int branchesVisited;
  final List<Map<String, dynamic>> history;

  const CustomerInsight({
    this.totalVisits = 0,
    this.preferredStylist,
    this.mostBookedService,
    this.branchesVisited = 0,
    this.history = const [],
  });
}

class OperationsService {
  final FirestoreService _firestoreService;

  OperationsService({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  Future<CustomerInsight> getCustomerInsight(String customerId) async {
    final snapshot = await _firestoreService.queryCollection(
      collection: 'serviceHistory',
      queryBuilder: (ref) => ref.where('customerId', isEqualTo: customerId)
          .orderBy('completedAt', descending: true),
    );

    final docs = snapshot.docs;
    if (docs.isEmpty) {
      return const CustomerInsight();
    }

    final history = docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    // Compute preferred stylist (most frequent)
    final stylistCounts = <String, int>{};
    final stylistNames = <String, String>{};
    final serviceCounts = <String, int>{};
    final serviceNames = <String, String>{};
    final branchIds = <String>{};

    for (final entry in history) {
      final stylistId = entry['stylistId'] as String? ?? '';
      final stylistName = entry['stylistName'] as String? ?? '';
      final serviceId = entry['serviceId'] as String? ?? '';
      final serviceName = entry['serviceName'] as String? ?? '';
      final branchId = entry['branchId'] as String? ?? '';

      if (stylistId.isNotEmpty) {
        stylistCounts[stylistId] = (stylistCounts[stylistId] ?? 0) + 1;
        if (stylistName.isNotEmpty) stylistNames[stylistId] = stylistName;
      }
      if (serviceId.isNotEmpty) {
        serviceCounts[serviceId] = (serviceCounts[serviceId] ?? 0) + 1;
        if (serviceName.isNotEmpty) serviceNames[serviceId] = serviceName;
      }
      if (branchId.isNotEmpty) branchIds.add(branchId);
    }

    String? preferredStylist;
    if (stylistCounts.isNotEmpty) {
      final topStylistId = stylistCounts.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      preferredStylist = stylistNames[topStylistId] ?? topStylistId;
    }

    String? mostBookedService;
    if (serviceCounts.isNotEmpty) {
      final topServiceId = serviceCounts.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
      mostBookedService = serviceNames[topServiceId] ?? topServiceId;
    }

    return CustomerInsight(
      totalVisits: docs.length,
      preferredStylist: preferredStylist,
      mostBookedService: mostBookedService,
      branchesVisited: branchIds.length,
      history: history,
    );
  }
}
