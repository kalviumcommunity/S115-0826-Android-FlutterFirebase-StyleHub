import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../core/exceptions/app_exceptions.dart';

class AuthRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepository({
    AuthService? authService,
    FirestoreService? firestoreService,
  })  : _authService = authService ?? AuthService(),
        _firestoreService = firestoreService ?? FirestoreService();

  User? get currentFirebaseUser => _authService.currentUser;

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    UserCredential cred;
    try {
      cred = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // Auto-create demo accounts if they don't exist (invalid credentials)
      if (email.contains('@stylehub.com')) {
        try {
          cred = await _authService.signUpWithEmailAndPassword(
            email: email,
            password: password,
          );
        } catch (_) {
          rethrow; // throw original error if signup also fails
        }
      } else {
        rethrow;
      }
    }

    final uid = cred.user!.uid;

    UserModel? profile;
    try {
      profile = await _firestoreService.getUserProfile(uid);
    } catch (e) {
      if (e.toString().contains('unavailable')) {
        // Fallback to a locally generated profile if Firestore is down/missing
        String assignedRole = 'customer';
        String? assignedBranchId;
        if (email.contains('staff')) {
          assignedRole = 'staff';
          assignedBranchId = 'branch_1';
        } else if (email.contains('admin')) {
          assignedRole = 'admin';
        }
        return UserModel(
          uid: uid,
          name: cred.user?.displayName ?? email.split('@').first,
          email: email,
          phone: '',
          role: assignedRole,
          assignedBranchId: assignedBranchId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      rethrow;
    }

    if (profile == null) {
      // Create default profile if not yet created in firestore
      String assignedRole = 'customer';
      String? assignedBranchId;
      
      if (email.contains('staff')) {
        assignedRole = 'staff';
        assignedBranchId = 'branch_1';
      } else if (email.contains('admin')) {
        assignedRole = 'admin';
      }

      profile = UserModel(
        uid: uid,
        name: cred.user?.displayName ?? email.split('@').first,
        email: email,
        phone: '',
        role: assignedRole,
        assignedBranchId: assignedBranchId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      try {
        await _firestoreService.createUserProfile(profile);
      } catch (e) {
         if (e.toString().contains('unavailable')) {
           throw AuthException('Firestore is unavailable. Please ensure your database is created in Firebase Console and press "R" in your terminal to hot restart.');
         }
         rethrow;
      }
    }
    return profile;
  }

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
    String role = 'customer',
    String? branchId,
  }) async {
    final cred = await _authService.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;

    final profile = UserModel(
      uid: uid,
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      role: role,
      branchId: branchId,
      assignedBranchId: branchId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestoreService.createUserProfile(profile);
    return profile;
  }

  Future<UserModel?> getProfile(String uid) => _firestoreService.getUserProfile(uid);

  Stream<UserModel?> streamProfile(String uid) => _firestoreService.streamUserProfile(uid);

  Future<void> updateProfile(String uid, Map<String, dynamic> data) =>
      _firestoreService.updateUserProfile(uid, data);

  Future<void> signOut() => _authService.signOut();
}
