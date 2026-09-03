import 'package:firebase_auth/firebase_auth.dart';

/// Service Layer: Thin wrapper around [FirebaseAuth].
///
/// This is the ONLY class in the application that imports `firebase_auth`.
/// Per the Layered Architecture (TRD §1), UI and Provider layers must
/// never interact with Firebase APIs directly — they go through
/// Repository → Service.
///
/// Design decisions:
/// - Constructor injection for testability (pass a mock [FirebaseAuth]).
/// - Methods return raw [User?] — the Repository layer converts these
///   to domain [UserModel] objects.
/// - Exceptions are NOT caught here; they bubble up to the Repository
///   layer which maps them to typed [AppException] subclasses.
class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// The currently signed-in Firebase user, or null.
  User? get currentUser => _firebaseAuth.currentUser;

  /// A reactive stream that emits whenever the auth state changes.
  /// Used by [AuthProvider] for persistent login (FR-01).
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Creates a new user with email and password.
  ///
  /// Returns the [UserCredential] containing the new [User].
  /// Throws [FirebaseAuthException] on failure (e.g., email-already-in-use).
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Signs in an existing user with email and password.
  ///
  /// Returns the [UserCredential] containing the authenticated [User].
  /// Throws [FirebaseAuthException] on failure (e.g., wrong-password).
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
