import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // 'customer', 'staff', 'admin'
  final String? branchId;
  final String? assignedBranchId;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.branchId,
    this.assignedBranchId,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCustomer => role == 'customer';
  bool get isStaff => role == 'staff';
  bool get isAdmin => role == 'admin';

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'customer',
      branchId: data['branchId'],
      assignedBranchId: data['assignedBranchId'] ?? data['branchId'],
      profileImage: data['profileImage'],
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

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'customer',
      branchId: data['branchId'],
      assignedBranchId: data['assignedBranchId'] ?? data['branchId'],
      profileImage: data['profileImage'],
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
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      if (branchId != null) 'branchId': branchId,
      if (assignedBranchId != null) 'assignedBranchId': assignedBranchId,
      if (profileImage != null) 'profileImage': profileImage,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? role,
    String? branchId,
    String? assignedBranchId,
    String? profileImage,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      branchId: branchId ?? this.branchId,
      assignedBranchId: assignedBranchId ?? this.assignedBranchId,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
