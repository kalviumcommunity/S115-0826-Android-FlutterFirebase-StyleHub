import 'package:cloud_firestore/cloud_firestore.dart';

class StaffDashboardStats {
  final int todayAppointments;
  final int pendingAppointments;

  const StaffDashboardStats({
    required this.todayAppointments,
    required this.pendingAppointments,
  });
}

class AppointmentSummary {
  final String status;
  final DateTime scheduledAt;

  const AppointmentSummary({required this.status, required this.scheduledAt});

  factory AppointmentSummary.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};
    final timestamp = data['scheduledAt'];
    return AppointmentSummary(
      status: data['status'] as String? ?? '',
      scheduledAt: timestamp is Timestamp ? timestamp.toDate() : DateTime(1970),
    );
  }
}
