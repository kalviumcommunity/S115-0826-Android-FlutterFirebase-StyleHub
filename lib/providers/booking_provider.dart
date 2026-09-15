import 'package:flutter/material.dart';
import '../core/app_exceptions.dart';
import '../repositories/appointment_repository.dart';
import '../models/branch_model.dart';
import '../models/service_model.dart';
import '../models/stylist_model.dart';

/// Provider Layer: Manages in-progress booking state and UI representation.
/// Prevents the UI from interacting with Firebase APIs directly.
/// Handles Loading, Empty, Error, and Success states.
class BookingProvider extends ChangeNotifier {
  final AppointmentRepository _appointmentRepository;

  BookingProvider({required AppointmentRepository appointmentRepository})
      : _appointmentRepository = appointmentRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Booking Flow State
  BranchModel? _selectedBranch;
  BranchModel? get selectedBranch => _selectedBranch;

  ServiceModel? _selectedService;
  ServiceModel? get selectedService => _selectedService;

  StylistModel? _selectedStylist;
  StylistModel? get selectedStylist => _selectedStylist;

  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  DateTime? _selectedTime;
  DateTime? get selectedTime => _selectedTime;

  void setBranch(BranchModel branch) {
    _selectedBranch = branch;
    notifyListeners();
  }

  void setService(ServiceModel service) {
    _selectedService = service;
    notifyListeners();
  }

  void setStylist(StylistModel stylist) {
    _selectedStylist = stylist;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setTime(DateTime time) {
    _selectedTime = time;
    notifyListeners();
  }

  void clearBookingState() {
    _selectedBranch = null;
    _selectedService = null;
    _selectedStylist = null;
    _selectedDate = null;
    _selectedTime = null;
    resetState();
  }

  /// Initiate an appointment booking. Enforces atomic constraints via Repository.
  Future<void> bookAppointment({
    required String customerId,
    required String customerName,
    required String branchId,
    required String stylistId,
    required String serviceId,
    required DateTime scheduledAt,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _isSuccess = false;

    try {
      // In a real implementation, we would generate a robust UUID here.
      // For now, generating a millisecond-based ID for simplicity.
      final appointmentId = DateTime.now().millisecondsSinceEpoch.toString();

      await _appointmentRepository.bookAppointment(
        appointmentId: appointmentId,
        customerId: customerId,
        customerName: customerName,
        branchId: branchId,
        stylistId: stylistId,
        serviceId: serviceId,
        scheduledAt: scheduledAt,
      );

      _isSuccess = true;
    } on SlotAlreadyBookedException catch (e) {
      _errorMessage = e.message;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  /// Cancel an appointment and free the associated time slot.
  ///
  /// Delegates to [AppointmentRepository.cancelAppointment] which runs
  /// a Firestore transaction to atomically update the appointment status
  /// and delete the slot lock document.
  Future<void> cancelAppointment({
    required String appointmentId,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _isSuccess = false;

    try {
      await _appointmentRepository.cancelAppointment(
        appointmentId: appointmentId,
      );

      _isSuccess = true;
    } on AppointmentNotFoundException catch (e) {
      _errorMessage = e.message;
    } on InvalidStatusTransitionException catch (e) {
      _errorMessage = e.message;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  /// Reschedule an appointment and update its time slot.
  Future<void> rescheduleAppointment({
    required String appointmentId,
    required DateTime newScheduledAt,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _isSuccess = false;

    try {
      await _appointmentRepository.rescheduleAppointment(
        appointmentId: appointmentId,
        newScheduledAt: newScheduledAt,
      );

      _isSuccess = true;
    } on AppointmentNotFoundException catch (e) {
      _errorMessage = e.message;
    } on InvalidStatusTransitionException catch (e) {
      _errorMessage = e.message;
    } on SlotAlreadyBookedException catch (e) {
      _errorMessage = e.message;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  void resetState() {
    _isLoading = false;
    _isSuccess = false;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
