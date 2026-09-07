import '../core/app_exceptions.dart';
import '../services/appointment_service.dart';

/// Repository Layer: Orchestrates appointment booking, cancellation, and
/// history operations.
///
/// Follows Layered Architecture (UI -> Providers -> Repositories -> Services).
/// This layer catches raw Firebase/platform exceptions from the Service layer
/// and re-throws typed [AppException] subclasses so that the Provider and UI
/// layers remain fully decoupled from Firebase error details.
class AppointmentRepository {
  final AppointmentService _appointmentService;

  AppointmentRepository({required AppointmentService appointmentService})
      : _appointmentService = appointmentService;

  /// Books an appointment by delegating to [AppointmentService].
  /// The service handles the atomic transaction and deterministic slot creation.
  ///
  /// Throws [SlotAlreadyBookedException] if the slot is already taken.
  /// Throws [FirestoreException] for unexpected Firestore failures.
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
    } on SlotAlreadyBookedException {
      rethrow;
    } catch (e) {
      throw FirestoreException(
        'Failed to book appointment: ${e.toString()}',
        code: 'booking-failed',
      );
    }
  }

  /// Cancels an appointment and atomically frees the associated slot.
  ///
  /// Delegates to [AppointmentService.cancelAppointment] which runs a
  /// Firestore transaction to ensure the appointment status update and
  /// slot deletion happen atomically.
  ///
  /// Throws [AppointmentNotFoundException] if the appointment does not exist.
  /// Throws [InvalidStatusTransitionException] if the appointment is in a
  /// terminal state (completed, cancelled, no_show).
  /// Throws [FirestoreException] for unexpected Firestore failures.
  Future<void> cancelAppointment({
    required String appointmentId,
  }) async {
    try {
      await _appointmentService.cancelAppointment(
        appointmentId: appointmentId,
      );
    } on AppointmentNotFoundException {
      rethrow;
    } on InvalidStatusTransitionException {
      rethrow;
    } catch (e) {
      throw FirestoreException(
        'Failed to cancel appointment: ${e.toString()}',
        code: 'cancellation-failed',
      );
    }
  }

  /// Completes an appointment using atomic batch writes.
  ///
  /// Throws [FirestoreException] for unexpected Firestore failures.
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
      throw FirestoreException(
        'Failed to complete appointment: ${e.toString()}',
        code: 'completion-failed',
      );
    }
  }
}
