import 'package:flutter/material.dart';
import '../repositories/branch_repository.dart';
import '../repositories/service_repository.dart';
import '../repositories/stylist_repository.dart';
import '../models/branch_model.dart';
import '../models/service_model.dart';
import '../models/stylist_model.dart';

/// Provider Layer: Manages reference data (branches, stylists, services) for UI selection.
class ReferenceDataProvider extends ChangeNotifier {
  final BranchRepository _branchRepository;
  final StylistRepository _stylistRepository;
  final ServiceRepository _serviceRepository;

  ReferenceDataProvider({
    required BranchRepository branchRepository,
    required StylistRepository stylistRepository,
    required ServiceRepository serviceRepository,
  })  : _branchRepository = branchRepository,
        _stylistRepository = stylistRepository,
        _serviceRepository = serviceRepository;

  // Branches
  List<BranchModel> _branches = const [];
  List<BranchModel> get branches => _branches;
  bool _branchesLoading = false;
  bool get branchesLoading => _branchesLoading;
  String? _branchesError;
  String? get branchesError => _branchesError;

  // Stylists
  List<StylistModel> _stylists = const [];
  List<StylistModel> get stylists => _stylists;
  bool _stylistsLoading = false;
  bool get stylistsLoading => _stylistsLoading;
  String? _stylistsError;
  String? get stylistsError => _stylistsError;

  // Services
  List<ServiceModel> _services = const [];
  List<ServiceModel> get services => _services;
  bool _servicesLoading = false;
  bool get servicesLoading => _servicesLoading;
  String? _servicesError;
  String? get servicesError => _servicesError;

  Future<void> initialize() async {
    await _loadBranches();
    await _loadStylists();
    await _loadServices();
  }

  Future<void> _loadBranches() async {
    _branchesLoading = true;
    _branchesError = null;
    notifyListeners();
    try {
      final data = await _branchRepository.getAllBranches();
      // Ensure data is cast to BranchModel.
      // If the repo returns Map, we'd use BranchModel.fromMap(data) here.
      _branches = data.cast<BranchModel>();
    } catch (e) {
      _branchesError = e.toString();
    } finally {
      _branchesLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadStylists() async {
    _stylistsLoading = true;
    _stylistsError = null;
    notifyListeners();
    try {
      final data = await _stylistRepository.getAllStylists();
      _stylists = data.cast<StylistModel>();
    } catch (e) {
      _stylistsError = e.toString();
    } finally {
      _stylistsLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadServices() async {
    _servicesLoading = true;
    _servicesError = null;
    notifyListeners();
    try {
      final data = await _serviceRepository.getAllServices();
      _services = data.cast<ServiceModel>();
    } catch (e) {
      _servicesError = e.toString();
    } finally {
      _servicesLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _branches = const [];
    _stylists = const [];
    _services = const [];
    _branchesLoading = false;
    _stylistsLoading = false;
    _servicesLoading = false;
    _branchesError = null;
    _stylistsError = null;
    _servicesError = null;
    notifyListeners();
  }
}
