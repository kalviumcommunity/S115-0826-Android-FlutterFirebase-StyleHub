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
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      role: data['role'] as String? ?? 'customer',
      branchId: data['branchId'] as String?,
      profileImageUrl: data['profileImageUrl'] as String?,
    );
  }

  /// Creates a [UserModel] from a raw Map (useful for query results).
  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      role: data['role'] as String? ?? 'customer',
      branchId: data['branchId'] as String?,
      profileImageUrl: data['profileImageUrl'] as String?,
    );
  }

  /// Converts this model to a Firestore-compatible map for writes.
  Map<String, dynamic> toFirestore() {
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
