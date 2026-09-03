/// Custom exception types for the StyleHub application.
///
/// The Repository layer catches raw Firebase/platform exceptions and
/// re-throws these typed exceptions. This ensures the Provider and UI
/// layers are completely decoupled from Firebase error details.
library;

/// Base exception class for all StyleHub application errors.
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException($code): $message';
}

/// Thrown when authentication operations fail (sign-in, sign-up, sign-out).
class AuthException extends AppException {
  const AuthException(super.message, {super.code});

  @override
  String toString() => 'AuthException($code): $message';
}

/// Thrown when Firestore read/write operations fail.
class FirestoreException extends AppException {
  const FirestoreException(super.message, {super.code});

  @override
  String toString() => 'FirestoreException($code): $message';
}

/// Thrown when a requested resource is not found in Firestore.
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code});

  @override
  String toString() => 'NotFoundException($code): $message';
}

/// Thrown when a booking slot is already taken (double-booking prevention).
class SlotAlreadyBookedException extends AppException {
  const SlotAlreadyBookedException(
    [super.message = 'This time slot is already booked. Please select another time.'],
  );

  @override
  String toString() => 'SlotAlreadyBookedException: $message';
}
