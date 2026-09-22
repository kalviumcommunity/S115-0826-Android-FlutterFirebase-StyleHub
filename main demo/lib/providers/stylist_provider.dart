import 'package:flutter/material.dart';
import '../models/stylist_model.dart';
import '../repositories/stylist_repository.dart';

class StylistProvider extends ChangeNotifier {
  final StylistRepository _stylistRepository;

  List<StylistModel> _stylists = [];
  StylistModel? _selectedStylist;
  bool _isLoading = false;
  String? _errorMessage;
  String? _filterBranchId;

  StylistProvider({StylistRepository? stylistRepository})
      : _stylistRepository = stylistRepository ?? StylistRepository() {
    listenToStylists();
  }

  List<StylistModel> get stylists => _stylists;
  StylistModel? get selectedStylist => _selectedStylist;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void filterByBranch(String? branchId) {
    _filterBranchId = branchId;
    listenToStylists();
  }

  void selectStylist(StylistModel? stylist) {
    _selectedStylist = stylist;
    notifyListeners();
  }

  void listenToStylists() {
    _isLoading = true;
    notifyListeners();
    _stylistRepository.streamStylists(branchId: _filterBranchId).listen(
      (data) {
        _stylists = data;
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

  Future<void> saveStylist(StylistModel stylist) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _stylistRepository.saveStylist(stylist);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteStylist(String stylistId) async {
    try {
      await _stylistRepository.deleteStylist(stylistId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
