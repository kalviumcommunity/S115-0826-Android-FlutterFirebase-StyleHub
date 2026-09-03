import 'package:firebase_auth/firebase_auth.dart';

import '../core/app_exceptions.dart';
import '../core/constants.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// Repository Layer: Orchestrates authentication and user-profile operations.
///
/// This class sits between the Provider and Service layers (TRD §1):
///   Provider → AuthRepository → AuthService + FirestoreService
///
/// Responsibilities:
/// - Coordinates multi-step flows (e.g., sign-up = create auth user + create
///   Firestore profile in a single logical operation).
/// - Maps raw Firebase exceptions to typed [AppException] subclasses so the
///   Provider/UI layers are fully decoupled from Firebase error details.
/// - Converts Firebase data (DocumentSnapshot, User) to domain [UserModel].
///
/// Design decisions:
/// - Constructor injection of both services for testability.
/// - Sign-up enforces FR-02: "UID used as document ID at users/{uid}".
/// - On sign-up failure after auth creation, the auth user is deleted to
///   avoid orphaned accounts (compensating action).
class AuthRepository {
  final AuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepository({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService;

  // ---------------------------------------------------------------------------
  // Auth State
  // ---------------------------------------------------------------------------

  /// Stream of auth state changes, mapped to [UserModel?].
  ///
  /// Emits null when signed out, or fetches the full profile when signed in.
  /// Used by [AuthProvider] for persistent login (FR-01).
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  /// Returns the currently signed-in user's UID, or null.
  String? get currentUserId => _authService.currentUser?.uid;

  // ---------------------------------------------------------------------------
  // Sign Up
  // ---------------------------------------------------------------------------

  /// Registers a new user with email/password and creates their Firestore
  /// profile document at `users/{uid}`.
  ///
  /// This enforces FR-02: one Firebase Auth UID = one profile document.
  /// If the Firestore write fails, the auth user is cleaned up to prevent
  /// orphaned accounts.
  ///
  /// Returns the created [UserModel].
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    User? authUser;

    try {
      // Step 1: Create the Firebase Auth account
      final credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );
      authUser = credential.user;

      if (authUser == null) {
        throw const AuthException(
          'Account creation failed. Please try again.',
          code: 'null-user',
        );
      }

      // Step 2: Build the user profile matching the TRD schema
      final userModel = UserModel(
        uid: authUser.uid,
        name: name,
        email: email,
        phone: phone,
        role: UserRoles.customer, // New sign-ups are always customers
      );

      // Step 3: Write profile to Firestore at users/{uid}
      await _firestoreService.setDocument(
        collection: FirestoreCollections.users,
        documentId: authUser.uid,
        data: userModel.toFirestore(),
      );

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      // If Firestore write failed but auth user was created, clean up
      if (authUser != null && e is! AuthException) {
        try {
          await authUser.delete();
        } catch (_) {
          // Best-effort cleanup; log in production
        }
      }

      if (e is AppException) rethrow;
      throw AuthException(
        'Registration failed. Please try again.',
        code: e.toString(),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Sign In
  // ---------------------------------------------------------------------------

  /// Signs in an existing user and fetches their Firestore profile.
  ///
  /// Returns the [UserModel] for the authenticated user.
  /// Throws [AuthException] with user-friendly messages on failure.
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException(
          'Sign-in failed. Please try again.',
          code: 'null-user',
        );
      }

      // Fetch the user profile from Firestore
      return await getUserProfile(user.uid);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException(
        'Sign-in failed. Please try again.',
        code: e.toString(),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Sign Out
  // ---------------------------------------------------------------------------

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      throw const AuthException(
        'Sign-out failed. Please try again.',
        code: 'sign-out-failed',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // User Profile
  // ---------------------------------------------------------------------------

  /// Fetches the user profile document from Firestore.
  ///
  /// Throws [NotFoundException] if the profile doesn't exist.
  Future<UserModel> getUserProfile(String uid) async {
    try {
      final doc = await _firestoreService.getDocument(
        collection: FirestoreCollections.users,
        documentId: uid,
      );

      if (!doc.exists || doc.data() == null) {
        throw NotFoundException(
          'User profile not found.',
          code: 'profile-not-found',
        );
      }

      return UserModel.fromFirestore(doc);
    } on AppException {
      rethrow;
    } catch (e) {
      throw FirestoreException(
        'Failed to load user profile.',
        code: e.toString(),
      );
    }
  }

  /// Updates the user profile document in Firestore.
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestoreService.setDocument(
        collection: FirestoreCollections.users,
        documentId: user.uid,
        data: user.toFirestore(),
        merge: true,
      );
    } catch (e) {
      throw FirestoreException(
        'Failed to update profile.',
        code: e.toString(),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Error Mapping
  // ---------------------------------------------------------------------------

  /// Maps [FirebaseAuthException] codes to user-friendly [AuthException] messages.
  ///
  /// This is the single place where Firebase error codes are translated into
  /// messages suitable for display in the UI.
  AuthException _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return const AuthException(
          'This email is already registered. Please sign in instead.',
          code: 'email-already-in-use',
        );
      case 'invalid-email':
        return const AuthException(
          'The email address is not valid.',
          code: 'invalid-email',
        );
      case 'weak-password':
        return const AuthException(
          'Password is too weak. Please use at least 6 characters.',
          code: 'weak-password',
        );
      case 'user-not-found':
        return const AuthException(
          'No account found with this email.',
          code: 'user-not-found',
        );
      case 'wrong-password':
        return const AuthException(
          'Incorrect password. Please try again.',
          code: 'wrong-password',
        );
      case 'user-disabled':
        return const AuthException(
          'This account has been disabled. Contact support.',
          code: 'user-disabled',
        );
      case 'too-many-requests':
        return const AuthException(
          'Too many attempts. Please try again later.',
          code: 'too-many-requests',
        );
      case 'invalid-credential':
        return const AuthException(
          'Invalid email or password. Please try again.',
          code: 'invalid-credential',
        );
      default:
        return AuthException(
          'Authentication failed. Please try again.',
          code: e.code,
        );
    }
  }
}
