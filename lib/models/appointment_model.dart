import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String appointmentId;
  final String customerId; // Unified Firebase Auth UID across all branches
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String branchId;
  final String branchName;
  final String stylistId;
  final String stylistName;
  final String serviceId;
  final String serviceName;
  final double servicePrice;
  final String appointmentDate; // YYYY-MM-DD
  final String startTime; // e.g. "11:00 AM"
  final String endTime; // e.g. "12:00 PM"
  final String status; // 'Pending', 'Confirmed', 'Completed', 'Cancelled'
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppointmentModel({
    required this.appointmentId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.branchId,
    required this.branchName,
    required this.stylistId,
    required this.stylistName,
    required this.serviceId,
    required this.serviceName,
    required this.servicePrice,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == 'Pending';
  bool get isConfirmed => status == 'Confirmed';
  bool get isCompleted => status == 'Completed';
  bool get isCancelled => status == 'Cancelled';

  factory AppointmentModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppointmentModel(
      appointmentId: doc.id,
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      customerEmail: data['customerEmail'] ?? '',
      branchId: data['branchId'] ?? '',
      branchName: data['branchName'] ?? '',
      stylistId: data['stylistId'] ?? '',
      stylistName: data['stylistName'] ?? '',
      serviceId: data['serviceId'] ?? '',
      serviceName: data['serviceName'] ?? '',
      servicePrice: (data['servicePrice'] is num) ? (data['servicePrice'] as num).toDouble() : 0.0,
      appointmentDate: data['appointmentDate'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      status: data['status'] ?? 'Pending',
      notes: data['notes'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] is Timestamp
              ? (data['updatedAt'] as Timestamp).toDate()
              : DateTime.tryParse(data['updatedAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'branchId': branchId,
      'branchName': branchName,
      'stylistId': stylistId,
      'stylistName': stylistName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'servicePrice': servicePrice,
      'appointmentDate': appointmentDate,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      if (notes != null) 'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  AppointmentModel copyWith({
    String? status,
    String? notes,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      appointmentId: appointmentId,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      customerEmail: customerEmail,
      branchId: branchId,
      branchName: branchName,
      stylistId: stylistId,
      stylistName: stylistName,
      serviceId: serviceId,
      serviceName: serviceName,
      servicePrice: servicePrice,
      appointmentDate: appointmentDate,
      startTime: startTime,
      endTime: endTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
