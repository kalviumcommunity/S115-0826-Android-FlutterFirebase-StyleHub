import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_exceptions.dart';
import '../models/staff_dashboard_model.dart';
import '../services/firestore_service.dart';

class StaffRepository {
  final FirestoreService _firestoreService;
  StaffRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  /// Search customers by phone or email (indexed exact-match queries),
  /// falling back to name substring match on the result set.
  Future<List<Map<String, dynamic>>> searchCustomers(String query) async {
    try {
      // Try exact phone match first
      var snapshot = await _firestoreService.queryCollection(
        collection: 'users',
        queryBuilder: (ref) => ref
            .where('role', isEqualTo: 'customer')
            .where('phone', isEqualTo: query)
            .limit(20),
      );
      
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['uid'] = doc.id;
          return data;
        }).toList();
      }

      // Try exact email match
      snapshot = await _firestoreService.queryCollection(
        collection: 'users',
        queryBuilder: (ref) => ref
            .where('role', isEqualTo: 'customer')
            .where('email', isEqualTo: query)
            .limit(20),
      );

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['uid'] = doc.id;
          return data;
        }).toList();
      }

      // Fall back to loading customers and filtering by name client-side
      final allCustomers = await _firestoreService.queryCollection(
        collection: 'users',
        queryBuilder: (ref) => ref
            .where('role', isEqualTo: 'customer')
            .limit(100),
      );

      final lowerQuery = query.toLowerCase();
      return allCustomers.docs
          .map((doc) {
            final data = doc.data();
            data['uid'] = doc.id;
            return data;
          })
          .where((data) {
            final name = (data['name'] as String? ?? '').toLowerCase();
            return name.contains(lowerQuery);
          })
          .toList();
    } catch (e) {
      throw FirestoreException('Failed to search customers: $e', code: 'search-failed');
    }
  }

  /// Watch real-time dashboard stats for a branch
  Stream<StaffDashboardStats> watchDashboardStats(String branchId) {
    return FirebaseFirestore.instance
        .collection('appointments')
        .where('branchId', isEqualTo: branchId)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      int todayCount = 0;
      int pendingCount = 0;
      int completedCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String? ?? '';
        final scheduledAt = (data['scheduledAt'] as Timestamp?)?.toDate();

        if (scheduledAt != null &&
            scheduledAt.isAfter(todayStart) &&
            scheduledAt.isBefore(todayEnd)) {
          todayCount++;
        }
        if (status == 'pending') pendingCount++;
        if (status == 'completed') completedCount++;
      }

      return StaffDashboardStats(
        todayAppointments: todayCount,
        pendingAppointments: pendingCount,
        completedAppointments: completedCount,
      );
    });
  }
}
