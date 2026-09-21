import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_exceptions.dart';
import '../repositories/appointment_repository.dart';
import '../models/branch_model.dart';
import '../models/stylist_model.dart';
import '../models/service_model.dart';
import '../models/appointment_model.dart';

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

  BranchModel? _selectedBranch;
  BranchModel? get selectedBranch => _selectedBranch;

  StylistModel? _selectedStylist;
  StylistModel? get selectedStylist => _selectedStylist;

  ServiceModel? _selectedService;
  ServiceModel? get selectedService => _selectedService;

  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  String? _selectedTimeSlot;
  String? get selectedTimeSlot => _selectedTimeSlot;

  Stream<QuerySnapshot<Map<String, dynamic>>>? _customerAppointmentsStream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? get customerAppointmentsStream => _customerAppointmentsStream;

  String? _customerId;
  String? _customerName;

  void setCustomerInfo(String id, String name) {
    _customerId = id;
    _customerName = name;
  }

  void selectBranch(BranchModel branch) { _selectedBranch = branch; notifyListeners(); }
  void selectStylist(StylistModel stylist) { _selectedStylist = stylist; notifyListeners(); }
  void selectService(ServiceModel service) { _selectedService = service; notifyListeners(); }
  void selectDate(DateTime date) { _selectedDate = date; notifyListeners(); }
  void selectTimeSlot(String slot) { _selectedTimeSlot = slot; notifyListeners(); }

  void loadCustomerAppointments(String customerId) {
    _customerAppointmentsStream = _appointmentRepository.getCustomerAppointmentsStream(customerId);
    notifyListeners();
  }

  /// Initiate an appointment booking. Enforces atomic constraints via Repository.
  Future<void> bookAppointment() async {
    if (_selectedBranch == null || _selectedStylist == null || 
        _selectedService == null || _selectedDate == null || _selectedTimeSlot == null) {
      _errorMessage = 'Please complete all booking steps.';
      notifyListeners();
      return;
    }
    
    _setLoading(true);
    _errorMessage = null;
    _isSuccess = false;
    
    try {
      final appointmentId = FirebaseFirestore.instance.collection('appointments').doc().id;
      
      // Parse time slot (format: "HH:mm")
      final timeParts = _selectedTimeSlot!.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final scheduledAt = DateTime(
        _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
        hour, minute,
      );
      
      await _appointmentRepository.bookAppointment(
        appointmentId: appointmentId,
        customerId: _customerId ?? '',
        customerName: _customerName ?? '',
        branchId: _selectedBranch!.id,
        branchName: _selectedBranch!.name,
        stylistId: _selectedStylist!.id,
        stylistName: _selectedStylist!.name,
        serviceId: _selectedService!.id,
        serviceName: _selectedService!.name,
        price: _selectedService!.price,
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

  Future<void> rescheduleAppointment({required String appointmentId, required DateTime newDateTime}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _appointmentRepository.rescheduleAppointment(appointmentId: appointmentId, newDateTime: newDateTime);
      _isSuccess = true;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> completeAppointment({
    required String appointmentId,
    required String customerId,
    required String branchId,
    required String branchName,
    required String stylistId,
    required String stylistName,
    required String serviceId,
    required String serviceName,
    required double price,
    String notes = '',
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _appointmentRepository.completeAppointment(
        appointmentId: appointmentId,
        customerId: customerId,
        branchId: branchId,
        branchName: branchName,
        stylistId: stylistId,
        stylistName: stylistName,
        serviceId: serviceId,
        serviceName: serviceName,
        price: price,
        notes: notes,
      );
      _isSuccess = true;
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
    _selectedStylist = null;
    _selectedService = null;
    _selectedDate = null;
    _selectedTimeSlot = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
