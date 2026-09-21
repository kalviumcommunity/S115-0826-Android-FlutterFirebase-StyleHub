import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final int durationMinutes;
  final String branchId;

  const ServiceModel({
    required this.id,
    required this.name,
    this.category = '',
    this.description = '',
    required this.price,
    required this.durationMinutes,
    required this.branchId,
  });

  factory ServiceModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return ServiceModel.fromMap(doc.data()!, doc.id);
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ServiceModel(
      id: documentId,
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: map['durationMinutes'] as int? ?? 0,
      branchId: map['branchId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'durationMinutes': durationMinutes,
      'branchId': branchId,
    };
  }

  Map<String, dynamic> toFirestore() => toMap();

  ServiceModel copyWith({
    String? name,
    String? category,
    String? description,
    double? price,
    int? durationMinutes,
    String? branchId,
  }) {
    return ServiceModel(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      branchId: branchId ?? this.branchId,
    );
  }

  @override
  String toString() => 'ServiceModel(id: $id, name: $name, price: $price, durationMinutes: $durationMinutes)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          category == other.category &&
          description == other.description &&
          price == other.price &&
          durationMinutes == other.durationMinutes &&
          branchId == other.branchId;

  @override
  int get hashCode => Object.hash(id, name, category, description, price, durationMinutes, branchId);
}
