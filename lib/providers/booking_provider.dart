import 'package:flutter/material.dart';
import '../core/app_exceptions.dart';
import '../repositories/appointment_repository.dart';
import '../models/appointment_model.dart';
import '../models/service_model.dart';
import '../models/stylist_model.dart';
import '../models/branch_model.dart';

/// Provider Layer: Manages in-progress booking state and UI representation.
class BookingProvider extends ChangeNotifier {
  final AppointmentRepository _appointmentRepository;

  BookingProvider({
    required AppointmentRepository appointmentRepository,
  }) : _appointmentRepository = appointmentRepository;

  // ---------------------------------------------------------------------------
  // Booking State (for the multi-step flow)
  // ---------------------------------------------------------------------------
  BranchModel? _selectedBranch;
  BranchModel? get selectedBranch => _selectedBranch;
  void setBranch(BranchModel branch) {
    _selectedBranch = branch;
    notifyListeners();
  }

  ServiceModel? _selectedService;
  ServiceModel? get selectedService => _selectedService;
  void setService(ServiceModel service) {
    _selectedService = service;
    notifyListeners();
  }

  StylistModel? _selectedStylist;
  StylistModel? get selectedStylist => _selectedStylist;
  void setStylist(StylistModel stylist) {
    _selectedStylist = stylist;
    notifyListeners();
  }

  DateTime? _selectedSlot;
  DateTime? get selectedSlot => _selectedSlot;
  void setSlot(DateTime slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Operation State
  // ---------------------------------------------------------------------------
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Mock lists for UI testing (since these are usually fetched via Repositories)
  List<AppointmentModel> _upcomingAppointments = [];
  List<AppointmentModel> get upcomingAppointments => _upcomingAppointments;

  List<AppointmentModel> _pastAppointments = [];
  List<AppointmentModel> get pastAppointments => _pastAppointments;

  /// Initiate an appointment booking.
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

  Future<void> cancelAppointment({
    required String appointmentId,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _isSuccess = false;

    try {
      await _appointmentRepository.cancelAppointment(appointmentId: appointmentId);
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

  void resetState() {
    _isLoading = false;
    _isSuccess = false;
    _errorMessage = null;
    _selectedBranch = null;
    _selectedService = null;
    _selectedStylist = null;
    _selectedSlot = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
