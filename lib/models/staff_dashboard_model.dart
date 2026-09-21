import 'package:cloud_firestore/cloud_firestore.dart';

class PopularService {
  final String serviceId;
  final String name;
  final int count;
  const PopularService({required this.serviceId, required this.name, required this.count});
}

class TopStylist {
  final String stylistId;
  final String name;
  final int appointmentCount;
  const TopStylist({required this.stylistId, required this.name, required this.appointmentCount});
}

class StaffDashboardStats {
  final int todayAppointments;
  final int pendingAppointments;
  final int completedAppointments;
  final List<PopularService> popularServices;
  final List<TopStylist> topStylists;
  
  const StaffDashboardStats({
    this.todayAppointments = 0,
    this.pendingAppointments = 0,
    this.completedAppointments = 0,
    this.popularServices = const [],
    this.topStylists = const [],
  });
}
