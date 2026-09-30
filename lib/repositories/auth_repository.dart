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
      rethrow;
    }

    final uid = cred.user!.uid;

    UserModel? profile = await _firestoreService.getUserProfile(uid);

    if (profile == null) {
      throw AuthException('Profile not found for this user.');
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
    String gender = 'Prefer not to say',
    bool mustChangePassword = false,
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
      profileImage: null,
      gender: gender,
      mustChangePassword: mustChangePassword,
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
