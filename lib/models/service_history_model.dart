import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceHistoryModel {
  final String id;
  final String customerId;
  final String appointmentId;
  final String branchId;
  final String branchName;
  final String stylistId;
  final String stylistName;
  final String serviceId;
  final String serviceName;
  final double price;
  final String notes;
  final DateTime completedAt;

  const ServiceHistoryModel({
    required this.id,
    required this.customerId,
    required this.appointmentId,
    required this.branchId,
    this.branchName = '',
    required this.stylistId,
    this.stylistName = '',
    required this.serviceId,
    this.serviceName = '',
    this.price = 0.0,
    this.notes = '',
    required this.completedAt,
  });

  factory ServiceHistoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return ServiceHistoryModel.fromMap(doc.data()!, doc.id);
  }

  factory ServiceHistoryModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ServiceHistoryModel(
      id: documentId,
      customerId: map['customerId'] as String? ?? '',
      appointmentId: map['appointmentId'] as String? ?? '',
      branchId: map['branchId'] as String? ?? '',
      branchName: map['branchName'] as String? ?? '',
      stylistId: map['stylistId'] as String? ?? '',
      stylistName: map['stylistName'] as String? ?? '',
      serviceId: map['serviceId'] as String? ?? '',
      serviceName: map['serviceName'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] as String? ?? '',
      completedAt: (map['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'appointmentId': appointmentId,
      'branchId': branchId,
      'branchName': branchName,
      'stylistId': stylistId,
      'stylistName': stylistName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'price': price,
      'notes': notes,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }

  Map<String, dynamic> toFirestore() => toMap();

  ServiceHistoryModel copyWith({
    String? customerId,
    String? appointmentId,
    String? branchId,
    String? branchName,
    String? stylistId,
    String? stylistName,
    String? serviceId,
    String? serviceName,
    double? price,
    String? notes,
    DateTime? completedAt,
  }) {
    return ServiceHistoryModel(
      id: id,
      customerId: customerId ?? this.customerId,
      appointmentId: appointmentId ?? this.appointmentId,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      stylistId: stylistId ?? this.stylistId,
      stylistName: stylistName ?? this.stylistName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      price: price ?? this.price,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  String toString() => 'ServiceHistoryModel(id: $id, customerId: $customerId, serviceId: $serviceId, completedAt: $completedAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceHistoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          customerId == other.customerId &&
          appointmentId == other.appointmentId &&
          branchId == other.branchId &&
          branchName == other.branchName &&
          stylistId == other.stylistId &&
          stylistName == other.stylistName &&
          serviceId == other.serviceId &&
          serviceName == other.serviceName &&
          price == other.price &&
          notes == other.notes &&
          completedAt == other.completedAt;

  @override
  int get hashCode => Object.hash(
        id,
        customerId,
        appointmentId,
        branchId,
        branchName,
        stylistId,
        stylistName,
        serviceId,
        serviceName,
        price,
        notes,
        completedAt,
      );
}
