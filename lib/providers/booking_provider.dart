import 'package:flutter/material.dart';
import '../models/appointment_model.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../models/branch_model.dart';
import '../models/service_model.dart';
import '../models/stylist_model.dart';
import '../repositories/booking_repository.dart';

class BookingProvider extends ChangeNotifier {
  final BookingRepository _bookingRepository;

  BookingModel _draft = const BookingModel();
  List<AppointmentModel> _customerAppointments = [];
  List<AppointmentModel> _branchAppointments = [];
  List<AppointmentModel> _allAppointments = [];

  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  BookingProvider({BookingRepository? bookingRepository})
      : _bookingRepository = bookingRepository ?? BookingRepository();

  BookingModel get draft => _draft;
  List<AppointmentModel> get customerAppointments => _customerAppointments;
  List<AppointmentModel> get branchAppointments => _branchAppointments;
  List<AppointmentModel> get allAppointments => _allAppointments;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Filter helpers
  List<AppointmentModel> get upcomingAppointments => _customerAppointments
      .where((a) => a.isPending || a.isConfirmed)
      .toList();

  List<AppointmentModel> get historyAppointments => _customerAppointments
      .where((a) => a.isCompleted || a.isCancelled)
      .toList();

  // Centralized Cross-Branch History: all branches visited by this unified customer UID
  Set<String> get customerBranchesVisited =>
      _customerAppointments.map((a) => a.branchName).toSet();

  void selectBranch(BranchModel branch) {
    _draft = _draft.copyWith(
      branchId: branch.branchId,
      branchName: branch.name,
    );
    notifyListeners();
  }

  void selectService(ServiceModel service) {
    _draft = _draft.copyWith(
      serviceId: service.serviceId,
      serviceName: service.name,
      servicePrice: service.price,
      serviceDuration: service.duration,
    );
    notifyListeners();
  }

  void selectStylist(StylistModel stylist) {
    _draft = _draft.copyWith(
      stylistId: stylist.stylistId,
      stylistName: stylist.name,
    );
    notifyListeners();
  }

  void selectDateTime(String date, String time) {
    _draft = _draft.copyWith(
      appointmentDate: date,
      startTime: time,
    );
    notifyListeners();
  }

  void setNotes(String notes) {
    _draft = _draft.copyWith(notes: notes);
    notifyListeners();
  }

  void resetDraft() {
    _draft = const BookingModel();
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // Real-time listener for customer's cross-branch appointments using their centralized UID
  void listenToCustomerAppointments(String customerUid) {
    _bookingRepository.streamCustomerHistory(customerUid).listen(
      (data) {
        _customerAppointments = data;
        notifyListeners();
      },
      onError: (err) {
        _errorMessage = err.toString();
        notifyListeners();
      },
    );
  }

  // Real-time listener for a staff's assigned salon branch
  void listenToBranchAppointments(String branchId) {
    _bookingRepository.streamBranchAppointments(branchId).listen(
      (data) {
        _branchAppointments = data;
        notifyListeners();
      },
      onError: (err) {
        _errorMessage = err.toString();
        notifyListeners();
      },
    );
  }

  // Real-time listener for headquarters / network analytics
  void listenToAllAppointments() {
    _bookingRepository.streamAllAppointments().listen(
      (data) {
        _allAppointments = data;
        notifyListeners();
      },
      onError: (err) {
        _errorMessage = err.toString();
        notifyListeners();
      },
    );
  }

  Future<AppointmentModel?> confirmBooking(UserModel customer) async {
    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final apt = await _bookingRepository.confirmBooking(
        draft: _draft,
        customer: customer,
      );
      _successMessage = 'Appointment booked successfully at ${apt.branchName}!';
      _isSubmitting = false;
      resetDraft();
      return apt;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> updateStatus(String appointmentId, String newStatus) async {
    try {
      await _bookingRepository.updateStatus(appointmentId, newStatus);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
