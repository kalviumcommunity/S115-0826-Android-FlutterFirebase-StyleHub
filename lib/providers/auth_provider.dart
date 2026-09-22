import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/firestore_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository() {
    _init();
  }

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get role => _currentUser?.role ?? 'customer';

  void _init() {
    _authRepository.authStateChanges.listen((user) async {
      if (user != null) {
        try {
          _currentUser = await _authRepository.getProfile(user.uid);
          try {
            await FirestoreRepository().seedDatabaseIfEmpty();
          } catch (_) {} // ignore seeding errors
          notifyListeners();
        } catch (_) {}
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _authRepository.login(email: email, password: password);
      try {
        await FirestoreRepository().seedDatabaseIfEmpty();
      } catch (_) {} // ignore seeding errors
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    String role = 'customer',
    String? branchId,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _authRepository.signUp(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
        branchId: branchId,
      );
      try {
        await FirestoreRepository().seedDatabaseIfEmpty();
      } catch (_) {} // ignore seeding errors
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? profileImage,
  }) async {
    if (_currentUser == null) return;
    _setLoading(true);
    try {
      final updates = <String, dynamic>{
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (profileImage != null) 'profileImage': profileImage,
      };
      await _authRepository.updateProfile(_currentUser!.uid, updates);
      _currentUser = _currentUser!.copyWith(
        name: name,
        phone: phone,
        profileImage: profileImage,
      );
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  // Demo role switch helper for seamless multi-branch verification
  void switchRole(String newRole) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: newRole);
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authRepository.signOut();
      _currentUser = null;
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
