import 'package:cloud_firestore/cloud_firestore.dart';

/// Immutable data model for a salon branch in the StyleHub network.
///
/// Maps directly to the `branches/{branchId}` Firestore collection schema
/// defined in the PRD (§8):
///   `name, city, address, phone, imageUrl, openingHours`
///
/// Design decisions:
/// - [id] is the Firestore document ID (auto-generated or custom).
/// - [openingHours] is stored as a Map<String, String> keyed by day name
///   (e.g., `{"Monday": "09:00-18:00", "Sunday": "Closed"}`).
/// - Explicit [fromMap] and [toMap] methods guarantee clean Firestore
///   serialization and unit testability without mocking Firebase.
class BranchModel {
  final String id;
  final String name;
  final String city;
  final String address;
  final String phone;
  final String? imageUrl;
  final Map<String, String> openingHours;

  const BranchModel({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.phone,
    this.imageUrl,
    this.openingHours = const {},
  });

  /// Creates a [BranchModel] from a Firestore document snapshot.
  factory BranchModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return BranchModel.fromMap(doc.data()!, doc.id);
  }

  /// Creates a [BranchModel] from a raw Map and a document ID.
  factory BranchModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BranchModel(
      id: documentId,
      name: map['name'] as String? ?? '',
      city: map['city'] as String? ?? '',
      address: map['address'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      openingHours: _parseOpeningHours(map['openingHours']),
    );
  }

  /// Converts this model to a Map for clean Firestore serialization.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'city': city,
      'address': address,
      'phone': phone,
      'imageUrl': imageUrl,
      'openingHours': openingHours,
    };
  }

  /// Alias for [toMap] for Firestore write compatibility.
  Map<String, dynamic> toFirestore() => toMap();

  /// Safely parses the openingHours field from Firestore's dynamic map.
  static Map<String, String> _parseOpeningHours(dynamic raw) {
    if (raw == null || raw is! Map) return {};
    return raw.map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );
  }

  /// Creates a copy of this model with the given fields replaced.
  BranchModel copyWith({
    String? name,
    String? city,
    String? address,
    String? phone,
    String? imageUrl,
    Map<String, String>? openingHours,
  }) {
    return BranchModel(
      id: id,
      name: name ?? this.name,
      city: city ?? this.city,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      openingHours: openingHours ?? this.openingHours,
    );
  }

  @override
  String toString() => 'BranchModel(id: $id, name: $name, city: $city)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BranchModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          city == other.city &&
          address == other.address &&
          phone == other.phone &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode => Object.hash(id, name, city, address, phone, imageUrl);
}
