import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_exceptions.dart';

class AppointmentService {
  final FirebaseFirestore _firestore;

  AppointmentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // Shared Helpers
  // ---------------------------------------------------------------------------

  /// Generates a deterministic slot ID from a stylist ID and scheduled time.
  ///
  /// Format: `{stylistId}_{yyyyMMdd}_{HHmm}`
  /// This format guarantees that any two bookings for the same stylist at the
  /// same date/time will produce an identical document key, enabling the
  /// Firestore transaction to detect the collision.
  static String generateSlotId(String stylistId, DateTime scheduledAt) {
    final String year = scheduledAt.year.toString();
    final String month = scheduledAt.month.toString().padLeft(2, '0');
    final String day = scheduledAt.day.toString().padLeft(2, '0');
    final String hour = scheduledAt.hour.toString().padLeft(2, '0');
    final String minute = scheduledAt.minute.toString().padLeft(2, '0');

    return '${stylistId}_$year$month${day}_$hour$minute';
  }

  // ---------------------------------------------------------------------------
  // Booking Transaction (FR-08 / TRD §3)
  // ---------------------------------------------------------------------------

  /// Books an appointment using a deterministic Firestore transaction to
  /// prevent double-booking.
  ///
  /// The transaction performs a read-then-write:
  /// 1. Generate the deterministic [slotId] from [stylistId] + [scheduledAt].
  /// 2. Read `appointmentSlots/{slotId}` inside the transaction.
  /// 3. If the document exists → abort with [SlotAlreadyBookedException].
  /// 4. If missing → atomically write both the slot document and the main
  ///    appointment document.
  ///
  /// Throws [SlotAlreadyBookedException] if the slot is already taken.
  Future<void> bookAppointment({
    required String appointmentId,
    required String customerId,
    required String customerName,
    required String branchId,
    required String stylistId,
    required String serviceId,
    required DateTime scheduledAt,
  }) async {
    final String slotId = generateSlotId(stylistId, scheduledAt);

    final slotRef = _firestore.collection('appointmentSlots').doc(slotId);
    final appointmentRef =
        _firestore.collection('appointments').doc(appointmentId);

    await _firestore.runTransaction((transaction) async {
      final slotSnapshot = await transaction.get(slotRef);

      if (slotSnapshot.exists) {
        throw const SlotAlreadyBookedException();
      }

      // Atomically write the appointment slot lock document.
      transaction.set(slotRef, {
        'slotId': slotId,
        'appointmentId': appointmentId,
        'stylistId': stylistId,
        'branchId': branchId,
        'scheduledAt': Timestamp.fromDate(scheduledAt),
      });

      // Atomically write the main appointment document.
      transaction.set(appointmentRef, {
        'customerId': customerId,
        'customerName': customerName,
        'branchId': branchId,
        'stylistId': stylistId,
        'serviceId': serviceId,
        'status': 'pending',
        'scheduledAt': Timestamp.fromDate(scheduledAt),
      });
    });
  }

  // ---------------------------------------------------------------------------
  // Cancellation Transaction
  // ---------------------------------------------------------------------------

  /// Cancels an appointment and atomically frees the associated slot.
  ///
  /// Transaction steps:
  /// 1. Read the appointment document — abort if missing or already in a
  ///    terminal state (`completed`, `cancelled`, `no_show`).
  /// 2. Regenerate the deterministic [slotId] from the appointment's stored
  ///    `stylistId` and `scheduledAt`.
  /// 3. Atomically update the appointment status to `cancelled` and delete
  ///    the corresponding `appointmentSlots/{slotId}` document.
  ///
  /// Throws [AppointmentNotFoundException] if the appointment does not exist.
  /// Throws [InvalidStatusTransitionException] if the appointment is already
  /// in a terminal state.
  Future<void> cancelAppointment({
    required String appointmentId,
  }) async {
    final appointmentRef =
        _firestore.collection('appointments').doc(appointmentId);

    await _firestore.runTransaction((transaction) async {
      final appointmentSnapshot = await transaction.get(appointmentRef);

      if (!appointmentSnapshot.exists) {
        throw const AppointmentNotFoundException();
      }

      final data = appointmentSnapshot.data()!;
      final currentStatus = data['status'] as String;

      // Only pending or confirmed appointments can be cancelled.
      const cancellableStatuses = {'pending', 'confirmed'};
      if (!cancellableStatuses.contains(currentStatus)) {
        throw const InvalidStatusTransitionException(
          'Only pending or confirmed appointments can be cancelled.',
        );
      }

      // Regenerate the deterministic slotId to find the lock document.
      final stylistId = data['stylistId'] as String;
      final scheduledAt = (data['scheduledAt'] as Timestamp).toDate();
      final slotId = generateSlotId(stylistId, scheduledAt);
      final slotRef = _firestore.collection('appointmentSlots').doc(slotId);

      // Atomically cancel the appointment and free the slot.
      transaction.update(appointmentRef, {'status': 'cancelled'});
      transaction.delete(slotRef);
    });
  }

  // ---------------------------------------------------------------------------
  // Appointment Completion (TRD §3 — Batch Write)
  // ---------------------------------------------------------------------------

  /// Completes an appointment using an atomic batch write.
  ///
  /// Batch operations:
  /// 1. Update `appointments/{appointmentId}` status to `completed`.
  /// 2. Create a new document in `serviceHistory` with all required fields.
  ///
  /// The batch guarantees both writes succeed or neither does.
  Future<void> completeAppointment({
    required String appointmentId,
    required String customerId,
    required String branchId,
    required String stylistId,
    required String serviceId,
  }) async {
    final batch = _firestore.batch();

    final appointmentRef =
        _firestore.collection('appointments').doc(appointmentId);
    final historyRef =
        _firestore.collection('serviceHistory').doc(); // Auto-generates ID

    // 1. Update appointment status to 'completed'
    batch.update(appointmentRef, {'status': 'completed'});

    // 2. Create new document in serviceHistory
    batch.set(historyRef, {
      'customerId': customerId,
      'appointmentId': appointmentId,
      'branchId': branchId,
      'stylistId': stylistId,
      'serviceId': serviceId,
      'completedAt': FieldValue.serverTimestamp(),
    });

    // Commit both operations atomically
    await batch.commit();
  }
}
