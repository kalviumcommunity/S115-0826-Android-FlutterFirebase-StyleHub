import 'dart:async';

import 'package:flutter/material.dart';

import '../models/staff_dashboard_model.dart';
import '../models/user_model.dart';
import '../repositories/staff_repository.dart';
import '../services/operations_service.dart';

class StaffDashboardProvider extends ChangeNotifier {
  final StaffRepository _repository;

  StaffDashboardProvider({required StaffRepository repository})
    : _repository = repository;

  StreamSubscription<List<UserModel>>? _customerSubscription;
  StreamSubscription<StaffDashboardStats>? _statsSubscription;
  List<UserModel> _customers = const [];
  StaffDashboardStats? _stats;
  bool _isLoading = true;
  String? _errorMessage;
  String _query = '';

  List<UserModel> get customers => _customers;
  StaffDashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEmpty =>
      !_isLoading && _errorMessage == null && _customers.isEmpty;

  void initialize(String? branchId) {
    if (_customerSubscription != null) {
      return;
    }
    _errorMessage = null;
    _customerSubscription = _repository.searchCustomers(_query).listen((
      customers,
    ) {
      _customers = customers;
      _isLoading = false;
      notifyListeners();
    }, onError: (_) => _setError('Unable to load customers.'));
    if (branchId != null && branchId.isNotEmpty) {
      _statsSubscription = _repository.watchDashboardStats(branchId).listen((
        stats,
      ) {
        _stats = stats;
        notifyListeners();
      }, onError: (_) => _setError('Unable to load branch appointments.'));
    }
  }

  void updateSearch(String query) {
    _query = query;
    _customerSubscription?.cancel();
    _isLoading = true;
    notifyListeners();
    _customerSubscription = _repository.searchCustomers(query).listen((
      customers,
    ) {
      _customers = customers;
      _isLoading = false;
      notifyListeners();
    }, onError: (_) => _setError('Unable to search customers.'));
  }

  Future<CustomerInsight> loadCustomerInsight(String customerId) {
    return _repository.getCustomerInsight(customerId);
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _customerSubscription?.cancel();
    _statsSubscription?.cancel();
    super.dispose();
  }
}
