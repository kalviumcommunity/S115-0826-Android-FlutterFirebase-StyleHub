import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final int durationMinutes;
  final String branchId;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.durationMinutes,
    required this.branchId,
  });

  factory ServiceModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return ServiceModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      durationMinutes: (data['durationMinutes'] as num?)?.toInt() ?? 0,
      branchId: data['branchId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'category': category,
    'price': price,
    'durationMinutes': durationMinutes,
    'branchId': branchId,
  };
}
