import 'package:cloud_firestore/cloud_firestore.dart';

class StylistModel {
  final String stylistId;
  final String name;
  final String profileImage;
  final String branchId;
  final String? branchName;
  final String bio;
  final String experience;
  final String specialization;
  final List<String> services;
  final List<String> availability;
  final bool active;
  final double rating;
  final int totalReviews;

  const StylistModel({
    required this.stylistId,
    required this.name,
    required this.profileImage,
    required this.branchId,
    this.branchName,
    required this.bio,
    required this.experience,
    required this.specialization,
    this.services = const [],
    this.availability = const [],
    this.active = true,
    this.rating = 4.9,
    this.totalReviews = 0,
  });

  factory StylistModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return StylistModel(
      stylistId: doc.id,
      name: data['name'] ?? '',
      profileImage: data['profileImage'] ?? '',
      branchId: data['branchId'] ?? '',
      branchName: data['branchName'],
      bio: data['bio'] ?? '',
      experience: data['experience'] ?? '',
      specialization: data['specialization'] ?? '',
      services: (data['services'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      availability: (data['availability'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      active: data['active'] ?? true,
      rating: (data['rating'] is num) ? (data['rating'] as num).toDouble() : 4.9,
      totalReviews: (data['totalReviews'] is num) ? (data['totalReviews'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stylistId': stylistId,
      'name': name,
      'profileImage': profileImage,
      'branchId': branchId,
      if (branchName != null) 'branchName': branchName,
      'bio': bio,
      'experience': experience,
      'specialization': specialization,
      'services': services,
      'availability': availability,
      'active': active,
      'rating': rating,
      'totalReviews': totalReviews,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
