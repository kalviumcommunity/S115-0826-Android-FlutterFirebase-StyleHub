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

/// Firebase Cloud Storage path constants.
///
/// Organizes uploads into predictable, role-scoped directories
/// so security rules and cleanup operations can target paths precisely.
class StoragePaths {
  StoragePaths._();

  /// Customer profile photos: `profile_photos/{uid}/profile.jpg`
  static String customerProfilePhoto(String uid) =>
      'profile_photos/$uid/profile.jpg';

  /// Stylist images: `stylist_images/{stylistId}/photo.jpg`
  static String stylistPhoto(String stylistId) =>
      'stylist_images/$stylistId/photo.jpg';

  /// Branch images: `branch_images/{branchId}/cover.jpg`
  static String branchImage(String branchId) =>
      'branch_images/$branchId/cover.jpg';
}
