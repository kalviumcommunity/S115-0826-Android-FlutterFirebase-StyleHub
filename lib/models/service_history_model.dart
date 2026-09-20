import 'package:cloud_firestore/cloud_firestore.dart';

/// Immutable data model for a service history record in the StyleHub system.
///
/// Maps directly to the `serviceHistory/{historyId}` Firestore collection schema
/// defined in the TRD (§2) and PRD (§8):
///   `customerId, appointmentId, branchId, branchName, stylistId, stylistName,
///   completedAt (Timestamp)`
///
/// Design decisions:
/// - [id] is the Firestore document ID (historyId).
/// - [completedAt] is a server timestamp indicating when the service was completed.
/// - Explicit [fromMap] and [toMap] methods guarantee clean Firestore
///   serialization and unit testability without mocking Firebase.
class ServiceHistoryModel {
  final String id;
  final String customerId;
  final String appointmentId;
  final String branchId;
  final String branchName;
  final String stylistId;
  final String stylistName;
  final DateTime completedAt;

  const ServiceHistoryModel({
    required this.id,
    required this.customerId,
    required this.appointmentId,
    required this.branchId,
    required this.branchName,
    required this.stylistId,
    required this.stylistName,
    required this.completedAt,
  });

  /// Creates a [ServiceHistoryModel] from a Firestore document snapshot.
  factory ServiceHistoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return ServiceHistoryModel.fromMap(doc.data()!, doc.id);
  }

  /// Creates a [ServiceHistoryModel] from a raw Map and a document ID.
  factory ServiceHistoryModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ServiceHistoryModel(
      id: documentId,
      customerId: map['customerId'] as String? ?? '',
      appointmentId: map['appointmentId'] as String? ?? '',
      branchId: map['branchId'] as String? ?? '',
      branchName: map['branchName'] as String? ?? '',
      stylistId: map['stylistId'] as String? ?? '',
      stylistName: map['stylistName'] as String? ?? '',
      completedAt: (map['completedAt'] as Timestamp?)?.toDate() ??
          DateTime(1970),
    );
  }

  /// Converts this model to a Map for clean Firestore serialization.
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'appointmentId': appointmentId,
      'branchId': branchId,
      'branchName': branchName,
      'stylistId': stylistId,
      'stylistName': stylistName,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }

  /// Alias for [toMap] for Firestore write compatibility.
  Map<String, dynamic> toFirestore() => toMap();

  /// Creates a copy of this model with the given fields replaced.
  ServiceHistoryModel copyWith({
    String? customerId,
    String? appointmentId,
    String? branchId,
    String? branchName,
    String? stylistId,
    String? stylistName,
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
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  String toString() =>
      'ServiceHistoryModel(id: $id, customerId: $customerId, completedAt: $completedAt)';

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
        completedAt,
      );
}