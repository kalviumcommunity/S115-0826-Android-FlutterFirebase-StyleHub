import 'package:flutter/material.dart';
import '../repositories/appointment_repository.dart';

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
    } catch (e) {
      // Handle error state gracefully to display in the UI layer
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
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
