import 'dart:async';
import 'package:flutter/material.dart';
import '../core/app_exceptions.dart';
import '../models/staff_dashboard_model.dart';
import '../models/user_model.dart';
import '../repositories/staff_repository.dart';
import '../services/operations_service.dart';

class StaffDashboardProvider extends ChangeNotifier {
  final StaffRepository _staffRepository;
  final OperationsService _operationsService;

  StaffDashboardStats? _stats;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _statsSub;

  StaffDashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  StaffDashboardProvider({
    required StaffRepository staffRepository,
    required OperationsService operationsService,
  })  : _staffRepository = staffRepository,
        _operationsService = operationsService;

  void initialize(String branchId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _statsSub?.cancel();
    _statsSub = _staffRepository.watchDashboardStats(branchId).listen(
      (stats) {
        _stats = stats;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to load dashboard stats';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<List<Map<String, dynamic>>> searchCustomers(String query) async {
    try {
      return await _staffRepository.searchCustomers(query);
    } on AppException {
      rethrow;
    } catch (e) {
      throw FirestoreException('Search failed: $e');
    }
  }

  Future<CustomerInsight> loadCustomerInsight(String customerId) async {
    try {
      return await _operationsService.getCustomerInsight(customerId);
    } catch (e) {
      throw FirestoreException('Failed to load customer insight: $e');
    }
  }

  @override
  void dispose() {
    _statsSub?.cancel();
    super.dispose();
  }
}
