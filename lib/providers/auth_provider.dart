import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/app_exceptions.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

/// Provider Layer: Manages authentication state for the entire application.
///
/// Per the Layered Architecture (TRD §1), this provider:
/// - Listens to the auth state stream for persistent login (FR-01).
/// - Delegates all business logic to [AuthRepository].
/// - Never imports or calls Firebase APIs directly.
/// - Exposes four UI states: Loading, Error, Success, Empty (PRD §11).
///
/// Widgets consume this via `context.watch<AuthProvider>()` or
/// `context.read<AuthProvider>()` and react to state changes.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  // ---------------------------------------------------------------------------
  // State Fields
  // ---------------------------------------------------------------------------

  /// The currently authenticated user's profile, or null if signed out.
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  /// Whether an async operation (sign-in, sign-up, profile fetch) is in progress.
  bool _isLoading = true; // Starts true during initial auth check
  bool get isLoading => _isLoading;

  /// The last error message, or null if no error.
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Derived convenience getters for UI state management.
  bool get isAuthenticated => _currentUser != null;
  String? get userRole => _currentUser?.role;

  /// Subscription to the Firebase auth state stream.
  StreamSubscription<User?>? _authSubscription;

  // ---------------------------------------------------------------------------
  // Constructor & Initialization
  // ---------------------------------------------------------------------------

  AuthProvider({required AuthRepository authRepository})
      : _authRepository = authRepository {
    _listenToAuthState();
  }

  /// Subscribes to the auth state stream from [AuthRepository].
  ///
  /// When a user signs in (from any source, including persistent session),
  /// their profile is fetched from Firestore. When they sign out, state
  /// is cleared.
  void _listenToAuthState() {
    _authSubscription = _authRepository.authStateChanges.listen(
      (User? firebaseUser) async {
        if (firebaseUser != null) {
          // User is signed in — fetch their full Firestore profile
          try {
            _currentUser = await _authRepository.getUserProfile(
              firebaseUser.uid,
            );
            _errorMessage = null;
          } on AppException catch (e) {
            _errorMessage = e.message;
            _currentUser = null;
          } catch (_) {
            _errorMessage = 'Failed to load profile.';
            _currentUser = null;
          }
        } else {
          // User is signed out
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

  // ---------------------------------------------------------------------------
  // Sign Up
  // ---------------------------------------------------------------------------

  /// Registers a new customer account.
  ///
  /// On success, the auth state listener will automatically pick up the
  /// new session and update [currentUser].
  Future<bool> signUp({
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
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Sign In
  // ---------------------------------------------------------------------------

  /// Signs in an existing user with email and password.
  ///
  /// Returns `true` on success, `false` on failure. On failure,
  /// [errorMessage] contains a user-friendly description.
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _authRepository.signIn(
        email: email,
        password: password,
      );
      _errorMessage = null;
      _setLoading(false);
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _setLoading(false);
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Sign Out
  // ---------------------------------------------------------------------------

  /// Signs out the current user. The auth state listener will
  /// automatically clear [currentUser].
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

  // ---------------------------------------------------------------------------
  // Error Handling
  // ---------------------------------------------------------------------------

  /// Clears the current error message. Useful after the UI has displayed
  /// the error via a SnackBar or dialog.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

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
