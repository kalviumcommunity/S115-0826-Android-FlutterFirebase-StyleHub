import 'dart:async';
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

  StreamSubscription? _customerSub;
  StreamSubscription? _branchSub;
  StreamSubscription? _allSub;

  String? _currentCustomerUid;
  String? _currentBranchId;
  bool _isAllListening = false;

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
    if (_currentCustomerUid == customerUid && _customerSub != null) return;
    
    debugPrint('\n==================================================');
    debugPrint('FIRESTORE LISTENER START');
    debugPrint('source = BookingProvider.listenToCustomerAppointments');
    debugPrint('collection = appointments');
    debugPrint('query = where("customerId", isEqualTo: $customerUid)');
    debugPrint('==================================================\n');

    _currentCustomerUid = customerUid;
    _errorMessage = null; // Clear old ghost errors
    _customerSub?.cancel();
    _customerSub = _bookingRepository.streamCustomerHistory(customerUid).listen(
      (data) {
        debugPrint('\n==================================================');
        debugPrint('CUSTOMER APPOINTMENT UPDATE');
        debugPrint('documentCount = ${data.length}');
        for (var apt in data) {
           debugPrint('appointmentId = ${apt.appointmentId}, status = ${apt.status}');
        }
        debugPrint('==================================================\n');
        
        _customerAppointments = data;
        notifyListeners();
      },
      onError: (err) {
        debugPrint('\n==================================================');
        debugPrint('FIRESTORE LISTENER FAILED');
        debugPrint('source = BookingProvider.listenToCustomerAppointments');
        debugPrint('collection = appointments (where customerId == $customerUid)');
        debugPrint('message = $err');
        debugPrint('==================================================\n');
        
        _errorMessage = err.toString();
        notifyListeners();
      },
    );
  }

  // Real-time listener for a staff's assigned salon branch
  void listenToBranchAppointments(String branchId) {
    if (_currentBranchId == branchId && _branchSub != null) return;
    
    debugPrint('\n==================================================');
    debugPrint('FIRESTORE LISTENER START');
    debugPrint('source = BookingProvider.listenToBranchAppointments');
    debugPrint('collection = appointments');
    debugPrint('query = where("branchId", isEqualTo: $branchId)');
    debugPrint('==================================================\n');

    _currentBranchId = branchId;
    _errorMessage = null; // Clear old ghost errors
    _branchSub?.cancel();
    _branchSub = _bookingRepository.streamBranchAppointments(branchId).listen(
      (data) {
        debugPrint('\n==================================================');
        debugPrint('STAFF LISTENER SNAPSHOT');
        debugPrint('documentCount = ${data.length}');
        for (var apt in data) {
           debugPrint('appointmentId: ${apt.appointmentId}, branchId: ${apt.branchId}, customerId: ${apt.customerId}, status: ${apt.status}, date: ${apt.appointmentDate}, time: ${apt.startTime}');
        }
        debugPrint('==================================================\n');
        
        _branchAppointments = data;
        notifyListeners();
      },
      onError: (err) {
        debugPrint('\n==================================================');
        debugPrint('FIRESTORE LISTENER FAILED');
        debugPrint('source = BookingProvider.listenToBranchAppointments');
        debugPrint('collection = appointments (where branchId == $branchId)');
        debugPrint('message = $err');
        debugPrint('==================================================\n');
        
        _errorMessage = err.toString();
        notifyListeners();
      },
    );
  }

  // Real-time listener for headquarters / network analytics
  void listenToAllAppointments() {
    if (_isAllListening && _allSub != null) return;
    
    debugPrint('\n==================================================');
    debugPrint('FIRESTORE LISTENER START');
    debugPrint('source = BookingProvider.listenToAllAppointments');
    debugPrint('collection = appointments');
    debugPrint('query = (all documents)');
    debugPrint('==================================================\n');

    _isAllListening = true;
    _errorMessage = null; // Clear old ghost errors
    _allSub?.cancel();
    _allSub = _bookingRepository.streamAllAppointments().listen(
      (data) {
        debugPrint('\n==================================================');
        debugPrint('ADMIN APPOINTMENT UPDATE');
        debugPrint('documentCount = ${data.length}');
        debugPrint('==================================================\n');
        
        _allAppointments = data;
        notifyListeners();
      },
      onError: (err) {
        debugPrint('\n==================================================');
        debugPrint('FIRESTORE LISTENER FAILED');
        debugPrint('source = BookingProvider.listenToAllAppointments');
        debugPrint('collection = appointments (all)');
        debugPrint('message = $err');
        debugPrint('==================================================\n');
        
        _errorMessage = err.toString();
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    clearAllListeners();
    super.dispose();
  }

  void clearAllListeners() {
    _customerSub?.cancel();
    _customerSub = null;
    _branchSub?.cancel();
    _branchSub = null;
    _allSub?.cancel();
    _allSub = null;
    
    _currentCustomerUid = null;
    _currentBranchId = null;
    _isAllListening = false;
    
    _errorMessage = null;
    _successMessage = null;
    
    _customerAppointments = [];
    _branchAppointments = [];
    _allAppointments = [];
    
    notifyListeners();
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
      rethrow;
    }
  }
}
