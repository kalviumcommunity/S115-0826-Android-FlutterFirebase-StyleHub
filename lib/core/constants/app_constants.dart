class AppConstants {
  static const String appName = 'StyleHub';
  static const String appTagline = 'Centralized Salon Network';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String branchesCollection = 'branches';
  static const String stylistsCollection = 'stylists';
  static const String servicesCollection = 'services';
  static const String appointmentsCollection = 'appointments';

  // Storage Folders
  static const String profileImagesPath = 'profile_images';
  static const String serviceImagesPath = 'service_images';
  static const String branchImagesPath = 'branch_images';

  // Appointment Statuses
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
  static const String statusRejected = 'rejected';

  // User Roles
  static const String roleCustomer = 'customer';
  static const String roleStaff = 'staff';
  static const String roleAdmin = 'admin';

  // Default Time Slots
  static const List<String> defaultTimeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
    '07:00 PM',
  ];
}
