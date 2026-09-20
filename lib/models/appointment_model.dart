import 'package:cloud_firestore/cloud_firestore.dart';

/// Immutable data model for an appointment in the StyleHub system.
///
/// Maps directly to the `appointments/{appointmentId}` Firestore collection schema
/// defined in the TRD (§2) and PRD (§8):
///   `customerId, customerName, branchId, branchName, stylistId, stylistName,
///   serviceId, serviceName, scheduledAt (Timestamp), status`
///
/// Design decisions:
/// - [id] is the Firestore document ID (appointmentId).
/// - [status] is one of: 'pending', 'confirmed', 'completed', 'cancelled', 'no_show'.
/// - Explicit [fromMap] and [toMap] methods guarantee clean Firestore
///   serialization and unit testability without mocking Firebase.
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
  final DateTime scheduledAt;
  final String status;

  const AppointmentModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.branchId,
    required this.branchName,
    required this.stylistId,
    required this.stylistName,
    required this.serviceId,
    required this.serviceName,
    required this.scheduledAt,
    required this.status,
  });

  /// Creates an [AppointmentModel] from a Firestore document snapshot.
  factory AppointmentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return AppointmentModel.fromMap(doc.data()!, doc.id);
  }

  /// Creates an [AppointmentModel] from a raw Map and a document ID.
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
      scheduledAt: (map['scheduledAt'] as Timestamp?)?.toDate() ??
          DateTime(1970),
      status: map['status'] as String? ?? 'pending',
    );
  }

  /// Converts this model to a Map for clean Firestore serialization.
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'branchId': branchId,
      'branchName': branchName,
      'stylistId': stylistId,
      'stylistName': stylistName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'status': status,
    };
  }

  /// Alias for [toMap] for Firestore write compatibility.
  Map<String, dynamic> toFirestore() => toMap();

  /// Creates a copy of this model with the given fields replaced.
  AppointmentModel copyWith({
    String? customerId,
    String? customerName,
    String? branchId,
    String? branchName,
    String? stylistId,
    String? stylistName,
    String? serviceId,
    String? serviceName,
    DateTime? scheduledAt,
    String? status,
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
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
    );
  }

  @override
  String toString() =>
      'AppointmentModel(id: $id, customerName: $customerName, status: $status)';

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
          scheduledAt == other.scheduledAt &&
          status == other.status;

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
        scheduledAt,
        status,
      );
}