import '../services/appointment_service.dart';

/// Repository Layer: Orchestrates appointment booking and history operations.
/// Follows Layered Architecture (UI -> Providers -> Repositories -> Services).
class AppointmentRepository {
  final AppointmentService _appointmentService;

  AppointmentRepository({required AppointmentService appointmentService})
      : _appointmentService = appointmentService;

  /// Books an appointment by delegating to [AppointmentService].
  /// The service handles the atomic transaction and deterministic slot creation.
  Future<void> bookAppointment({
    required String appointmentId,
    required String customerId,
    required String customerName,
    required String branchId,
    required String stylistId,
    required String serviceId,
    required DateTime scheduledAt,
  }) async {
    try {
      await _appointmentService.bookAppointment(
        appointmentId: appointmentId,
        customerId: customerId,
        customerName: customerName,
        branchId: branchId,
        stylistId: stylistId,
        serviceId: serviceId,
        scheduledAt: scheduledAt,
      );
    } catch (e) {
      // Re-throw or map to a custom AppException for the provider to catch
      rethrow;
    }
  }

  /// Completes an appointment using atomic batch writes.
  Future<void> completeAppointment({
    required String appointmentId,
    required String customerId,
    required String branchId,
    required String stylistId,
    required String serviceId,
  }) async {
    try {
      await _appointmentService.completeAppointment(
        appointmentId: appointmentId,
        customerId: customerId,
        branchId: branchId,
        stylistId: stylistId,
        serviceId: serviceId,
      );
    } catch (e) {
      rethrow;
    }
  }
}
