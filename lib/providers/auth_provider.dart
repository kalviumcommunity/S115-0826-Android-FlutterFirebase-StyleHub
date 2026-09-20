import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/app_exceptions.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

/// Provider Layer: Manages authentication state for the entire application.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _currentUser != null;
  String? get userRole => _currentUser?.role;

  StreamSubscription<User?>? _authSubscription;

  AuthProvider({required AuthRepository authRepository})
      : _authRepository = authRepository {
    _listenToAuthState();
  }

  void _listenToAuthState() {
    _authSubscription = _authRepository.authStateChanges.listen(
      (User? firebaseUser) async {
        if (firebaseUser != null) {
          try {
            _currentUser = await _authRepository.getUserProfile(firebaseUser.uid);
            _errorMessage = null;
          } on AppException catch (e) {
            _errorMessage = e.message;
            _currentUser = null;
          } catch (_) {
            _errorMessage = 'Failed to load profile.';
            _currentUser = null;
          }
        } else {
          _currentUser = null;
          _errorMessage = null;
        }
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Authentication service unavailable.';
        notifyListeners();
      },
    );
  }

  /// UI-friendly login method
  Future<bool> login(String email, String password) async {
    return await signIn(email: email, password: password);
  }

  /// UI-friendly sign-up method
  Future<bool> signUp({
    required String name, 
    required String email, 
    required String password, 
    required String phone,
  }) async {
    return await _performSignUp(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _authRepository.signIn(email: email, password: password);
      _errorMessage = null;
      _setLoading(false);
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> _performSignUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _authRepository.signUp(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      _errorMessage = null;
      _setLoading(false);
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred.';
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authRepository.signOut();
      _currentUser = null;
      _errorMessage = null;
    } on AppException catch (e) {
      _errorMessage = e.message;
    }
    _setLoading(false);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
