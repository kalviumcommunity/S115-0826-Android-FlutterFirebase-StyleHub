import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../core/app_exceptions.dart';
import '../models/branch_model.dart';
import '../models/stylist_model.dart';
import '../models/service_model.dart';
import '../repositories/branch_repository.dart';
import '../repositories/stylist_repository.dart';
import '../repositories/service_repository.dart';
import 'dart:async';

class ReferenceDataProvider extends ChangeNotifier {
  final BranchRepository _branchRepository;
  final StylistRepository _stylistRepository;
  final ServiceRepository _serviceRepository;

  List<BranchModel> _branches = [];
  List<StylistModel> _stylists = [];
  List<ServiceModel> _services = [];
  bool _isLoading = true;
  String? _error;

  StreamSubscription? _branchSub;
  StreamSubscription? _stylistSub;
  StreamSubscription? _serviceSub;

  List<BranchModel> get branches => _branches;
  List<StylistModel> get stylists => _stylists;
  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ReferenceDataProvider({
    required BranchRepository branchRepository,
    required StylistRepository stylistRepository,
    required ServiceRepository serviceRepository,
  })  : _branchRepository = branchRepository,
        _stylistRepository = stylistRepository,
        _serviceRepository = serviceRepository;

  void initialize() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _branchSub = _branchRepository.watchAllBranches().listen((snapshot) {
      _branches = snapshot.docs
          .map((doc) => BranchModel.fromFirestore(doc))
          .toList();
      _checkLoadingComplete();
    }, onError: (e) { _error = 'Failed to load branches'; _isLoading = false; notifyListeners(); });

    _stylistSub = _stylistRepository.watchAllStylists().listen((snapshot) {
      _stylists = snapshot.docs
          .map((doc) => StylistModel.fromFirestore(doc))
          .toList();
      _checkLoadingComplete();
    }, onError: (e) { _error = 'Failed to load stylists'; _isLoading = false; notifyListeners(); });

    _serviceSub = _serviceRepository.watchAllServices().listen((snapshot) {
      _services = snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
      _checkLoadingComplete();
    }, onError: (e) { _error = 'Failed to load services'; _isLoading = false; notifyListeners(); });
  }

  void _checkLoadingComplete() {
    if (_branches.isNotEmpty || _stylists.isNotEmpty || _services.isNotEmpty) {
      _isLoading = false;
    }
    // After first data arrives, mark loading as done
    _isLoading = false;
    notifyListeners();
  }

  // CRUD pass-through methods
  Future<void> createBranch(Map<String, dynamic> data) async {
    try { await _branchRepository.createBranch(data); }
    on AppException { rethrow; } catch (e) { throw FirestoreException('Failed to create branch'); }
  }
  Future<void> updateBranch(String id, Map<String, dynamic> data) async {
    try { await _branchRepository.updateBranch(id, data); }
    on AppException { rethrow; } catch (e) { throw FirestoreException('Failed to update branch'); }
  }
  Future<void> deleteBranch(String id) async {
    try { await _branchRepository.deleteBranch(id); }
    on AppException { rethrow; } catch (e) { throw FirestoreException('Failed to delete branch'); }
  }

  Future<void> createStylist(Map<String, dynamic> data) async {
    try { await _stylistRepository.createStylist(data); }
    on AppException { rethrow; } catch (e) { throw FirestoreException('Failed to create stylist'); }
  }
  Future<void> updateStylist(String id, Map<String, dynamic> data) async {
    try { await _stylistRepository.updateStylist(id, data); }
    on AppException { rethrow; } catch (e) { throw FirestoreException('Failed to update stylist'); }
  }
  Future<void> deleteStylist(String id) async {
    try { await _stylistRepository.deleteStylist(id); }
    on AppException { rethrow; } catch (e) { throw FirestoreException('Failed to delete stylist'); }
  }

  Future<void> createService(Map<String, dynamic> data) async {
    try { await _serviceRepository.createService(data); }
    on AppException { rethrow; } catch (e) { throw FirestoreException('Failed to create service'); }
  }
  Future<void> updateService(String id, Map<String, dynamic> data) async {
    try { await _serviceRepository.updateService(id, data); }
    on AppException { rethrow; } catch (e) { throw FirestoreException('Failed to update service'); }
  }
  Future<void> deleteService(String id) async {
    try { await _serviceRepository.deleteService(id); }
    on AppException { rethrow; } catch (e) { throw FirestoreException('Failed to delete service'); }
  }

  @override
  void dispose() {
    _branchSub?.cancel();
    _stylistSub?.cancel();
    _serviceSub?.cancel();
    super.dispose();
  }
}
