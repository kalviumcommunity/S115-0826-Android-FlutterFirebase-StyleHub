import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exceptions.dart';
import '../models/appointment_model.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import 'firestore_repository.dart';

class BookingRepository {
  final FirestoreRepository _firestoreRepository;

  BookingRepository({
    FirestoreRepository? firestoreRepository,
  })  : _firestoreRepository = firestoreRepository ?? FirestoreRepository();

  Stream<List<AppointmentModel>> streamCustomerHistory(String customerUid) {
    return _firestoreRepository.getCustomerAppointments(customerUid);
  }

  Stream<List<AppointmentModel>> streamBranchAppointments(String branchId) {
    return _firestoreRepository.getBranchAppointments(branchId);
  }

  Stream<List<AppointmentModel>> streamAllAppointments() {
    return _firestoreRepository.getAllAppointments();
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
    
    return _firestoreRepository.bookAppointment(
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
      notes: draft.notes ?? '',
    );
  }

  Future<void> updateStatus(String appointmentId, String newStatus) async {
    final statusLower = newStatus.toLowerCase();
    if (statusLower == AppConstants.statusCancelled || statusLower == AppConstants.statusRejected) {
      final doc = await FirebaseFirestore.instance.collection('appointments').doc(appointmentId).get();
      if (doc.exists) {
        final apt = AppointmentModel.fromFirestore(doc);
        return _firestoreRepository.cancelAppointment(apt, status: statusLower);
      }
    }
    return _firestoreRepository.updateAppointmentStatus(appointmentId, statusLower);
  }

  String _calculateEndTime(String startTime, int durationMinutes) {
    // Simple time offset calculation
    return '$startTime (+${durationMinutes}m)';
  }
}
