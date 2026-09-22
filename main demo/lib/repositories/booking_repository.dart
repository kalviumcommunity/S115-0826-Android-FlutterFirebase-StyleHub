import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exceptions.dart';
import '../models/appointment_model.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class BookingRepository {
  final FirestoreService _firestoreService;

  BookingRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  Stream<List<AppointmentModel>> streamCustomerHistory(String customerUid) {
    return _firestoreService.streamCustomerAppointments(customerUid);
  }

  Stream<List<AppointmentModel>> streamBranchAppointments(String branchId) {
    return _firestoreService.streamBranchAppointments(branchId);
  }

  Stream<List<AppointmentModel>> streamAllAppointments() {
    return _firestoreService.streamAllAppointments();
  }

  Future<AppointmentModel> confirmBooking({
    required BookingModel draft,
    required UserModel customer,
  }) async {
    if (!draft.isComplete) {
      throw const BookingValidationException(
        'Please complete all booking steps before confirming.',
      );
    }

    final appointmentId = 'apt_${const Uuid().v4().substring(0, 8)}';
    
    final appointment = AppointmentModel(
      appointmentId: appointmentId,
      customerId: customer.uid,
      customerName: customer.name,
      customerPhone: customer.phone,
      customerEmail: customer.email,
      branchId: draft.branchId!,
      branchName: draft.branchName ?? 'StyleHub Outlet',
      stylistId: draft.stylistId!,
      stylistName: draft.stylistName ?? 'Stylist Specialist',
      serviceId: draft.serviceId!,
      serviceName: draft.serviceName ?? 'Salon Service',
      servicePrice: draft.servicePrice ?? 0.0,
      appointmentDate: draft.appointmentDate!,
      startTime: draft.startTime!,
      endTime: _calculateEndTime(draft.startTime!, draft.serviceDuration ?? 45),
      status: AppConstants.statusPending,
      notes: draft.notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestoreService.createAppointment(appointment);
    return appointment;
  }

  Future<void> updateStatus(String appointmentId, String newStatus) {
    return _firestoreService.updateAppointmentStatus(appointmentId, newStatus);
  }

  String _calculateEndTime(String startTime, int durationMinutes) {
    // Simple time offset calculation
    return '$startTime (+${durationMinutes}m)';
  }
}
