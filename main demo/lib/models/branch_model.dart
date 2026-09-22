import 'package:cloud_firestore/cloud_firestore.dart';

class BranchModel {
  final String branchId;
  final String name;
  final String address;
  final String city;
  final String phone;
  final String openingHours;
  final String description;
  final String image;
  final bool active;
  final double rating;
  final int totalReviews;
  final DateTime? createdAt;

  const BranchModel({
    required this.branchId,
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    required this.openingHours,
    required this.description,
    required this.image,
    this.active = true,
    this.rating = 4.8,
    this.totalReviews = 0,
    this.createdAt,
  });

  factory BranchModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return BranchModel(
      branchId: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      phone: data['phone'] ?? '',
      openingHours: data['openingHours'] ?? '',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      active: data['active'] ?? true,
      rating: (data['rating'] is num) ? (data['rating'] as num).toDouble() : 4.8,
      totalReviews: (data['totalReviews'] is num) ? (data['totalReviews'] as num).toInt() : 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(data['createdAt'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'branchId': branchId,
      'name': name,
      'address': address,
      'city': city,
      'phone': phone,
      'openingHours': openingHours,
      'description': description,
      'image': image,
      'active': active,
      'rating': rating,
      'totalReviews': totalReviews,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
