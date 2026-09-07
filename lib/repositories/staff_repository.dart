import '../core/constants.dart';
import '../models/staff_dashboard_model.dart';
import '../models/user_model.dart';
import '../services/operations_service.dart';

class StaffRepository {
  final OperationsService _operationsService;

  StaffRepository({required OperationsService operationsService})
    : _operationsService = operationsService;

  Stream<List<UserModel>> watchCustomers() {
    return _operationsService.streamCustomers().map(
      (snapshot) => snapshot.docs.map(UserModel.fromFirestore).toList(),
    );
  }

  Stream<List<UserModel>> searchCustomers(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    return watchCustomers().map(
      (customers) => customers.where((customer) {
        if (normalizedQuery.isEmpty) return true;
        return customer.name.toLowerCase().contains(normalizedQuery) ||
            customer.email.toLowerCase().contains(normalizedQuery) ||
            customer.phone.toLowerCase().contains(normalizedQuery);
      }).toList(),
    );
  }

  Stream<StaffDashboardStats> watchDashboardStats(String branchId) {
    return _operationsService
        .streamCollection(
          FirestoreCollections.appointments,
          queryBuilder: (ref) =>
              ref.where('branchId', isEqualTo: branchId).orderBy('scheduledAt'),
        )
        .map((snapshot) {
          final appointments = snapshot.docs
              .map(AppointmentSummary.fromFirestore)
              .toList();
          final now = DateTime.now();
          final startOfDay = DateTime(now.year, now.month, now.day);
          final endOfDay = startOfDay.add(const Duration(days: 1));
          return StaffDashboardStats(
            todayAppointments: appointments
                .where(
                  (appointment) =>
                      !appointment.scheduledAt.isBefore(startOfDay) &&
                      appointment.scheduledAt.isBefore(endOfDay),
                )
                .length,
            pendingAppointments: appointments
                .where(
                  (appointment) =>
                      appointment.status == AppointmentStatuses.pending,
                )
                .length,
          );
        });
  }

  Future<CustomerInsight> getCustomerInsight(String customerId) {
    return _operationsService.getCustomerInsight(customerId);
  }
}
