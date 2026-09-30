import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
class AdminProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  List<UserModel> _staffMembers = [];
  List<UserModel> get staffMembers => _staffMembers;
  List<UserModel> _customers = [];
  List<UserModel> get customers => _customers;
  StreamSubscription? _staffSub;
  StreamSubscription? _customerSub;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  AdminProvider({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();
  void listenToStaff() {
    _staffSub?.cancel();
    _staffSub = _firestoreService.streamUsersByRole('staff').listen(
      (data) {
        _staffMembers = data;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        notifyListeners();
      },
    );
  }

  void listenToCustomers() {
    _customerSub?.cancel();
    _customerSub = _firestoreService.streamUsersByRole('customer').listen(
      (data) {
        _customers = data;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        notifyListeners();
      },
    );
  }

  Future<void> updateStaffBranch(String uid, String? branchId) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();
      if (branchId != null) {
        // We are assigning a branch to the staff member
        // Need to check if there is an active staff member there if this user is active
        final userDoc = await _firestoreService.getUserProfile(uid);
        if (userDoc != null && (userDoc.toMap()['isActive'] == true || userDoc.toMap()['active'] == true)) {
          final activeStaff = _staffMembers.where((s) => s.assignedBranchId == branchId && s.uid != uid && (s.toMap()['isActive'] == true || s.toMap()['active'] == true)).toList();
          if (activeStaff.isNotEmpty) {
            throw Exception('This branch already has an active Staff member. Please deactivate them first.');
          }
        }
      }

      await _firestoreService.updateUserProfile(uid, {
        'assignedBranchId': branchId,
      });
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateStaffDetails(String uid, String name, String phone) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();
      await _firestoreService.updateUserProfile(uid, {
        'name': name,
        'phone': phone,
      });
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleUserStatus(String uid, bool currentStatus) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      if (!currentStatus) {
        // We are trying to activate the user
        final userDoc = await _firestoreService.getUserProfile(uid);
        if (userDoc != null && userDoc.role == 'staff' && userDoc.assignedBranchId != null) {
          final activeStaff = _staffMembers.where((s) => s.assignedBranchId == userDoc.assignedBranchId && s.uid != uid && (s.toMap()['isActive'] == true || s.toMap()['active'] == true)).toList();
          if (activeStaff.isNotEmpty) {
            throw Exception('This branch already has an active Staff member. Please deactivate them first.');
          }
        }
      }

      await _firestoreService.updateUserProfile(uid, {
        'isActive': !currentStatus,
      });
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createStaffAccount({
    required String name,
    required String email,
    required String phone,
    required String gender,
    required String assignedBranchId,
    required String password,
  }) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      // Check One Active Staff Per Branch rule locally
      final activeStaff = _staffMembers.where((s) =>
          s.assignedBranchId == assignedBranchId &&
          s.isActive == true).toList();
      
      if (activeStaff.isNotEmpty) {
        throw Exception('This branch already has an active Staff member. Only one active staff is allowed per branch.');
      }

      // Initialize secondary app to prevent logging out the current admin
      FirebaseApp secondaryApp;
      try {
        secondaryApp = Firebase.app('SecondaryApp');
      } catch (e) {
        secondaryApp = await Firebase.initializeApp(
          name: 'SecondaryApp',
          options: Firebase.app().options,
        );
      }

      // Create Auth user on secondary app
      final UserCredential userCredential = await FirebaseAuth.instanceFor(app: secondaryApp)
          .createUserWithEmailAndPassword(email: email, password: password);
          
      final uid = userCredential.user!.uid;

      // Write to Firestore using the secondary app (since rules allow a user to create their own profile)
      await FirebaseFirestore.instanceFor(app: secondaryApp).collection('users').doc(uid).set({
        'uid': uid,
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'gender': gender,
        'role': 'staff',
        'assignedBranchId': assignedBranchId,
        'branchId': assignedBranchId,
        'isActive': true,
        'mustChangePassword': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Sign out from secondary app
      await FirebaseAuth.instanceFor(app: secondaryApp).signOut();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _staffSub?.cancel();
    _customerSub?.cancel();
    super.dispose();
  }
}
