import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  // TODO: Inject AuthRepository and handle Firebase Auth state
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  // Placeholder for initialization
  Future<void> initialize() async {
    // Check auth state from repository
    notifyListeners();
  }
}
