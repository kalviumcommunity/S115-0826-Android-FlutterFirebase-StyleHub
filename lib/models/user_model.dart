import 'package:cloud_firestore/cloud_firestore.dart';

/// Immutable data model for a StyleHub user.
///
/// Maps directly to the `users/{uid}` Firestore collection schema
/// defined in the TRD (§2) and PRD (§8).
///
/// Fields:
/// - [uid]: Maps directly to Firebase Auth UID (FR-02).
/// - [role]: One of "customer", "staff", or "admin".
/// - [branchId]: Assigned branch for staff; null for customers.
/// - [phone]: Used for cross-branch customer lookup.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? branchId;
  final String? profileImageUrl;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.branchId,
    this.profileImageUrl,
  });

  /// Creates a [UserModel] from a Firestore document snapshot.
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  /// Creates a [UserModel] from a raw Map and a document ID.
  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      role: map['role'] as String? ?? 'customer',
      branchId: map['branchId'] as String?,
      profileImageUrl: map['profileImageUrl'] as String?,
    );
  }

  /// Converts this model to a Map for clean Firestore serialization.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'branchId': branchId,
      'profileImageUrl': profileImageUrl,
    };
  }

  /// Alias for [toMap] for compatibility with Firestore write callers.
  Map<String, dynamic> toFirestore() => toMap();

  /// Creates a copy of this model with the given fields replaced.
  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    String? branchId,
    String? profileImageUrl,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      branchId: branchId ?? this.branchId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  @override
  String toString() => 'UserModel(uid: $uid, name: $name, role: $role)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          name == other.name &&
          email == other.email &&
          phone == other.phone &&
          role == other.role &&
          branchId == other.branchId &&
          profileImageUrl == other.profileImageUrl;

  @override
  int get hashCode => Object.hash(
        uid,
        name,
        email,
        phone,
        role,
        branchId,
        profileImageUrl,
      );
}
