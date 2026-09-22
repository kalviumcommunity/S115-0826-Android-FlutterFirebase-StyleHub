import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../repositories/service_repository.dart';

class ServiceProvider extends ChangeNotifier {
  final ServiceRepository _serviceRepository;

  List<ServiceModel> _services = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  ServiceModel? _selectedService;
  bool _isLoading = false;
  String? _errorMessage;

  ServiceProvider({ServiceRepository? serviceRepository})
      : _serviceRepository = serviceRepository ?? ServiceRepository() {
    listenToServices();
  }

  List<ServiceModel> get services {
    return _services.where((s) {
      final matchesCat = _selectedCategory == 'All' || s.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();
  }

  List<String> get categories => [
    'All',
    'Hair',
    'Skin & Facial',
    'Spa & Wellness',
    'Nails',
    'Grooming',
  ];

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  ServiceModel? get selectedService => _selectedService;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void selectCategory(String cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectService(ServiceModel? service) {
    _selectedService = service;
    notifyListeners();
  }

  void listenToServices() {
    _isLoading = true;
    notifyListeners();
    _serviceRepository.streamServices().listen(
      (data) {
        _services = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        _errorMessage = err.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> saveService(ServiceModel service) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _serviceRepository.saveService(service);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      await _serviceRepository.deleteService(serviceId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
