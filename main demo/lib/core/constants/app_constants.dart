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
  static const String statusPending = 'Pending';
  static const String statusConfirmed = 'Confirmed';
  static const String statusCompleted = 'Completed';
  static const String statusCancelled = 'Cancelled';

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
