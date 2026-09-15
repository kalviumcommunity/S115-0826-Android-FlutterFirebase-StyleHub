import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String customerId;
  final String customerName;
  final String branchId;
  final String stylistId;
  final String serviceId;
  final String status;
  final DateTime scheduledAt;

  const AppointmentModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.branchId,
    required this.stylistId,
    required this.serviceId,
    required this.status,
    required this.scheduledAt,
  });

  factory AppointmentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return AppointmentModel(
      id: doc.id,
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      branchId: data['branchId'] as String? ?? '',
      stylistId: data['stylistId'] as String? ?? '',
      serviceId: data['serviceId'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      scheduledAt: (data['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'customerId': customerId,
    'customerName': customerName,
    'branchId': branchId,
    'stylistId': stylistId,
    'serviceId': serviceId,
    'status': status,
    'scheduledAt': Timestamp.fromDate(scheduledAt),
  };
}
