import 'package:cloud_firestore/cloud_firestore.dart';

/// Immutable data model for a stylist working at a StyleHub branch.
///
/// Maps directly to the `stylists/{stylistId}` Firestore collection schema
/// defined in the PRD (§8):
///   `name, branchId, specialization[], photoUrl, workingDays[]`
///
/// Design decisions:
/// - [branchId] links the stylist to their home branch.
/// - [specialization] and [workingDays] are stored as Firestore arrays.
/// - Explicit [fromMap] and [toMap] handle safe array casting (`List<dynamic>` -> `List<String>`).
class StylistModel {
  final String id;
  final String name;
  final String branchId;
  final List<String> specialization;
  final String? photoUrl;
  final List<String> workingDays;

  const StylistModel({
    required this.id,
    required this.name,
    required this.branchId,
    this.specialization = const [],
    this.photoUrl,
    this.workingDays = const [],
  });

  /// Creates a [StylistModel] from a Firestore document snapshot.
  factory StylistModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return StylistModel.fromMap(doc.data()!, doc.id);
  }

  /// Creates a [StylistModel] from a raw Map and a document ID.
  factory StylistModel.fromMap(Map<String, dynamic> map, String documentId) {
    return StylistModel(
      id: documentId,
      name: map['name'] as String? ?? '',
      branchId: map['branchId'] as String? ?? '',
      specialization: _parseStringList(map['specialization']),
      photoUrl: map['photoUrl'] as String?,
      workingDays: _parseStringList(map['workingDays']),
    );
  }

  /// Converts this model to a Map for clean Firestore serialization.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'branchId': branchId,
      'specialization': specialization,
      'photoUrl': photoUrl,
      'workingDays': workingDays,
    };
  }

  /// Alias for [toMap] for Firestore write compatibility.
  Map<String, dynamic> toFirestore() => toMap();

  /// Safely parses a Firestore `List<dynamic>` to `List<String>`.
  static List<String> _parseStringList(dynamic raw) {
    if (raw == null || raw is! List) return [];
    return raw.map((e) => e.toString()).toList();
  }

  /// Creates a copy of this model with the given fields replaced.
  StylistModel copyWith({
    String? name,
    String? branchId,
    List<String>? specialization,
    String? photoUrl,
    List<String>? workingDays,
  }) {
    return StylistModel(
      id: id,
      name: name ?? this.name,
      branchId: branchId ?? this.branchId,
      specialization: specialization ?? this.specialization,
      photoUrl: photoUrl ?? this.photoUrl,
      workingDays: workingDays ?? this.workingDays,
    );
  }

  @override
  String toString() =>
      'StylistModel(id: $id, name: $name, branchId: $branchId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StylistModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          branchId == other.branchId &&
          photoUrl == other.photoUrl;

  @override
  int get hashCode => Object.hash(id, name, branchId, photoUrl);
}
