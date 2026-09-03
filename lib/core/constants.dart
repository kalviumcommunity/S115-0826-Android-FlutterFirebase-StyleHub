/// Centralized constants for Firestore collection names and field values.
///
/// Using constants eliminates magic strings and provides a single source
/// of truth for the database schema defined in the TRD.
library;

class FirestoreCollections {
  FirestoreCollections._(); // Prevent instantiation

  static const String users = 'users';
  static const String appointments = 'appointments';
  static const String appointmentSlots = 'appointmentSlots';
  static const String serviceHistory = 'serviceHistory';
  static const String branches = 'branches';
  static const String stylists = 'stylists';
  static const String services = 'services';
}

/// Valid values for the `role` field on user documents.
class UserRoles {
  UserRoles._();

  static const String customer = 'customer';
  static const String staff = 'staff';
  static const String admin = 'admin';

  static const List<String> all = [customer, staff, admin];
}

/// Valid values for the `status` field on appointment documents.
class AppointmentStatuses {
  AppointmentStatuses._();

  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
  static const String noShow = 'no_show';

  static const List<String> all = [
    pending,
    confirmed,
    completed,
    cancelled,
    noShow,
  ];
}
