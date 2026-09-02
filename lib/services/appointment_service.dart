import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentService {
  final FirebaseFirestore _firestore;

  AppointmentService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Books an appointment using a deterministic transaction to prevent double-booking.
  /// Follows the TRD logic for generating slotId: {stylistId}_{yyyyMMdd}_{HHmm}
  Future<void> bookAppointment({
    required String appointmentId,
    required String customerId,
    required String customerName,
    required String branchId,
    required String stylistId,
    required String serviceId,
    required DateTime scheduledAt,
  }) async {
    // Generate deterministic slotId
    final String year = scheduledAt.year.toString();
    final String month = scheduledAt.month.toString().padLeft(2, '0');
    final String day = scheduledAt.day.toString().padLeft(2, '0');
    final String hour = scheduledAt.hour.toString().padLeft(2, '0');
    final String minute = scheduledAt.minute.toString().padLeft(2, '0');
    
    final String slotId = '${stylistId}_$year$month${day}_$hour$minute';

    final slotRef = _firestore.collection('appointmentSlots').doc(slotId);
    final appointmentRef = _firestore.collection('appointments').doc(appointmentId);

    // Run strict transaction
    await _firestore.runTransaction((transaction) async {
      final slotSnapshot = await transaction.get(slotRef);

      // Abort if the document already exists
      if (slotSnapshot.exists) {
        throw Exception('This time slot is already booked. Please select another time.');
      }

      // Atomically write the appointment slot
      transaction.set(slotRef, {
        'slotId': slotId,
        'appointmentId': appointmentId,
        'stylistId': stylistId,
        'scheduledAt': Timestamp.fromDate(scheduledAt),
      });

      // Atomically write the main appointment document
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

  /// Completes an appointment using an atomic batch write.
  /// Follows the TRD logic to update status and create service history simultaneously.
  Future<void> completeAppointment({
    required String appointmentId,
    required String customerId,
    required String branchId,
    required String stylistId,
    required String serviceId,
  }) async {
    final batch = _firestore.batch();

    final appointmentRef = _firestore.collection('appointments').doc(appointmentId);
    final historyRef = _firestore.collection('serviceHistory').doc(); // Auto-generates ID

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
