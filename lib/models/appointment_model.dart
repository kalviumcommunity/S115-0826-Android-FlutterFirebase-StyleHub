import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String customerId;
  final String customerName;
  final String branchId;
  final String branchName;
  final String stylistId;
  final String stylistName;
  final String serviceId;
  final String serviceName;
  final String status;
  final DateTime scheduledAt;
  final double price;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AppointmentModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.branchId,
    this.branchName = '',
    required this.stylistId,
    this.stylistName = '',
    required this.serviceId,
    this.serviceName = '',
    required this.status,
    required this.scheduledAt,
    this.price = 0.0,
    this.notes = '',
    this.createdAt,
    this.updatedAt,
  });

  factory AppointmentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return AppointmentModel.fromMap(doc.data()!, doc.id);
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AppointmentModel(
      id: documentId,
      customerId: map['customerId'] as String? ?? '',
      customerName: map['customerName'] as String? ?? '',
      branchId: map['branchId'] as String? ?? '',
      branchName: map['branchName'] as String? ?? '',
      stylistId: map['stylistId'] as String? ?? '',
      stylistName: map['stylistName'] as String? ?? '',
      serviceId: map['serviceId'] as String? ?? '',
      serviceName: map['serviceName'] as String? ?? '',
      status: map['status'] as String? ?? '',
      scheduledAt: (map['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'customerId': customerId,
      'customerName': customerName,
      'branchId': branchId,
      'branchName': branchName,
      'stylistId': stylistId,
      'stylistName': stylistName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'status': status,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'price': price,
      'notes': notes,
    };
    
    if (createdAt != null) {
      map['createdAt'] = Timestamp.fromDate(createdAt!);
    }
    if (updatedAt != null) {
      map['updatedAt'] = Timestamp.fromDate(updatedAt!);
    }
    
    return map;
  }

  Map<String, dynamic> toFirestore() => toMap();

  AppointmentModel copyWith({
    String? customerId,
    String? customerName,
    String? branchId,
    String? branchName,
    String? stylistId,
    String? stylistName,
    String? serviceId,
    String? serviceName,
    String? status,
    DateTime? scheduledAt,
    double? price,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppointmentModel(
      id: id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      stylistId: stylistId ?? this.stylistId,
      stylistName: stylistName ?? this.stylistName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      price: price ?? this.price,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'AppointmentModel(id: $id, customerId: $customerId, serviceId: $serviceId, status: $status, scheduledAt: $scheduledAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          customerId == other.customerId &&
          customerName == other.customerName &&
          branchId == other.branchId &&
          branchName == other.branchName &&
          stylistId == other.stylistId &&
          stylistName == other.stylistName &&
          serviceId == other.serviceId &&
          serviceName == other.serviceName &&
          status == other.status &&
          scheduledAt == other.scheduledAt &&
          price == other.price &&
          notes == other.notes &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        customerId,
        customerName,
        branchId,
        branchName,
        stylistId,
        stylistName,
        serviceId,
        serviceName,
        status,
        scheduledAt,
        price,
        notes,
        createdAt,
        updatedAt,
      );
}
