import 'package:flutter/material.dart';
import '../models/branch_model.dart';
import '../repositories/branch_repository.dart';

class BranchProvider extends ChangeNotifier {
  final BranchRepository _branchRepository;

  List<BranchModel> _branches = [];
  BranchModel? _selectedBranch;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  BranchProvider({BranchRepository? branchRepository})
      : _branchRepository = branchRepository ?? BranchRepository() {
    listenToBranches();
  }

  List<BranchModel> get branches {
    if (_searchQuery.isEmpty) return _branches;
    final q = _searchQuery.toLowerCase();
    return _branches.where((b) =>
      b.name.toLowerCase().contains(q) ||
      b.city.toLowerCase().contains(q) ||
      b.address.toLowerCase().contains(q)
    ).toList();
  }

  BranchModel? get selectedBranch => _selectedBranch;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectBranch(BranchModel? branch) {
    _selectedBranch = branch;
    notifyListeners();
  }

  void listenToBranches() {
    _isLoading = true;
    notifyListeners();
    _branchRepository.streamBranches().listen(
      (data) {
        _branches = data;
        _isLoading = false;
        if (_selectedBranch == null && _branches.isNotEmpty) {
          _selectedBranch = _branches.first;
        }
        notifyListeners();
      },
      onError: (err) {
        _errorMessage = err.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> saveBranch(BranchModel branch) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _branchRepository.saveBranch(branch);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBranch(String branchId) async {
    try {
      await _branchRepository.deleteBranch(branchId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
