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
  // ignore: use_super_parameters
  const SlotAlreadyBookedException([
    String message = 'This time slot is already booked. Please select another time.',
  ]) : super(message);

  @override
  String toString() => 'SlotAlreadyBookedException: $message';
}

/// Thrown when an appointment referenced by ID does not exist in Firestore.
class AppointmentNotFoundException extends AppException {
  // ignore: use_super_parameters
  const AppointmentNotFoundException([
    String message = 'The requested appointment was not found.',
  ]) : super(message);

  @override
  String toString() => 'AppointmentNotFoundException: $message';
}

/// Thrown when an appointment status transition is invalid
/// (e.g., cancelling an already completed appointment).
class InvalidStatusTransitionException extends AppException {
  // ignore: use_super_parameters
  const InvalidStatusTransitionException([
    String message = 'This appointment cannot be modified in its current state.',
  ]) : super(message);

  @override
  String toString() => 'InvalidStatusTransitionException: $message';
}
