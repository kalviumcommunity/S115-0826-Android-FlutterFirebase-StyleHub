import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String serviceId;
  final String name;
  final String description;
  final String category; // 'Hair', 'Skin & Facial', 'Spa & Wellness', 'Nails', 'Grooming'
  final double price;
  final int duration; // in minutes
  final String image;
  final List<String> branchAvailability;
  final bool active;

  const ServiceModel({
    required this.serviceId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.duration,
    required this.image,
    this.branchAvailability = const ['all'],
    this.active = true,
  });

  factory ServiceModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ServiceModel(
      serviceId: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'Hair',
      price: (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0,
      duration: (data['duration'] is num) ? (data['duration'] as num).toInt() : 45,
      image: data['image'] ?? '',
      branchAvailability: (data['branchAvailability'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['all'],
      active: data['active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'duration': duration,
      'image': image,
      'branchAvailability': branchAvailability,
      'active': active,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
