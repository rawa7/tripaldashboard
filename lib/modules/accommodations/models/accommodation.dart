import 'package:flutter/foundation.dart';

class Accommodation {
  final String? id;
  final String? areaId;
  final String? areaName; // For easy display, not in DB schema
  final String? typeId;
  final String? typeName; // For easy display, not in DB schema
  final String? ownerId;
  final String name;
  final String description;
  final String? nameAr;
  final String? nameKu;
  final String? nameBad;
  final String? descriptionAr;
  final String? descriptionKu;
  final String? descriptionBad;
  final int capacity;
  final double? sizeSqm;
  final double price;
  final double? discountPercent;
  final Map<String, dynamic>? amenities;
  final double? latitude;
  final double? longitude;
  final bool? isActive;
  final bool? isFeatured;
  final bool? isNew;
  final DateTime? createdAt;
  final String? primaryImageUrl; // Not in DB schema but useful for UI
  
  Accommodation({
    this.id,
    this.areaId,
    this.areaName,
    this.typeId,
    this.typeName,
    this.ownerId,
    required this.name,
    required this.description,
    this.nameAr,
    this.nameKu,
    this.nameBad,
    this.descriptionAr,
    this.descriptionKu,
    this.descriptionBad,
    required this.capacity,
    this.sizeSqm,
    required this.price,
    this.discountPercent,
    this.amenities,
    this.latitude,
    this.longitude,
    this.isActive = true,
    this.isFeatured = false,
    this.isNew = true,
    this.createdAt,
    this.primaryImageUrl,
  });
  
  // Safely get the ID, throws exception if null
  String get requireId {
    if (id == null) {
      throw Exception('Accommodation ID cannot be null');
    }
    return id!;
  }
  
  factory Accommodation.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 Accommodation.fromJson: ${json.keys.toList()}');
    
    try {
      // Helper function to parse double values safely
      double? parseDouble(dynamic value) {
        if (value == null) return null;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value);
        return null;
      }
      
      final accommodation = Accommodation(
        id: json['id'],
        areaId: json['area_id'],
        areaName: json['areas'] != null ? json['areas']['name'] : null,
        typeId: json['type_id'],
        typeName: json['accommodation_types'] != null ? json['accommodation_types']['name'] : null,
        ownerId: json['owner_id'],
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        nameAr: json['name_ar'],
        nameKu: json['name_ku'],
        nameBad: json['name_bad'],
        descriptionAr: json['description_ar'],
        descriptionKu: json['description_ku'],
        descriptionBad: json['description_bad'],
        capacity: json['capacity'] ?? 0,
        sizeSqm: parseDouble(json['size_sqm']),
        price: parseDouble(json['price']) ?? 0.0,
        discountPercent: parseDouble(json['discount_percent']),
        amenities: json['amenities'] as Map<String, dynamic>?,
        latitude: parseDouble(json['latitude']),
        longitude: parseDouble(json['longitude']),
        isActive: json['is_active'],
        isFeatured: json['is_featured'],
        isNew: json['is_new'],
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at'])
            : null,
        primaryImageUrl: null,
      );
      
      debugPrint('✅ Successfully parsed Accommodation: ${accommodation.id}');
      return accommodation;
    } catch (e, stackTrace) {
      debugPrint('❌ Error parsing Accommodation from JSON: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      debugPrint('❌ JSON data: $json');
      
      // Return a minimum valid accommodation to avoid crashes
      return Accommodation(
        id: json['id'],
        name: json['name'] ?? 'Error parsing name',
        description: json['description'] ?? 'Error parsing description',
        capacity: json['capacity'] ?? 0,
        price: 0.0,
      );
    }
  }
  
  Map<String, dynamic> toJson() {
    final json = {
      if (id != null) 'id': id,
      if (areaId != null) 'area_id': areaId,
      if (typeId != null) 'type_id': typeId,
      if (ownerId != null) 'owner_id': ownerId,
      'name': name,
      'description': description,
      if (nameAr != null) 'name_ar': nameAr,
      if (nameKu != null) 'name_ku': nameKu,
      if (nameBad != null) 'name_bad': nameBad,
      if (descriptionAr != null) 'description_ar': descriptionAr,
      if (descriptionKu != null) 'description_ku': descriptionKu,
      if (descriptionBad != null) 'description_bad': descriptionBad,
      'capacity': capacity,
      'size_sqm': sizeSqm ?? 0.0,
      'price': price,
      if (discountPercent != null) 'discount_percent': discountPercent,
      if (amenities != null) 'amenities': amenities,
      'latitude': latitude ?? 0.0,
      'longitude': longitude ?? 0.0,
      'is_active': isActive ?? true,
      'is_featured': isFeatured ?? false,
      'is_new': isNew ?? true,
    };
    
    debugPrint('🔍 Accommodation.toJson: ${json.keys.toList()}');
    return json;
  }
  
  Accommodation copyWith({
    String? id,
    String? areaId,
    String? areaName,
    String? typeId,
    String? typeName,
    String? ownerId,
    String? name,
    String? description,
    String? nameAr,
    String? nameKu,
    String? nameBad,
    String? descriptionAr,
    String? descriptionKu,
    String? descriptionBad,
    int? capacity,
    double? sizeSqm,
    double? price,
    double? discountPercent,
    Map<String, dynamic>? amenities,
    double? latitude,
    double? longitude,
    bool? isActive,
    bool? isFeatured,
    bool? isNew,
    DateTime? createdAt,
    String? primaryImageUrl,
  }) {
    return Accommodation(
      id: id ?? this.id,
      areaId: areaId ?? this.areaId,
      areaName: areaName ?? this.areaName,
      typeId: typeId ?? this.typeId,
      typeName: typeName ?? this.typeName,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      nameAr: nameAr ?? this.nameAr,
      nameKu: nameKu ?? this.nameKu,
      nameBad: nameBad ?? this.nameBad,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionKu: descriptionKu ?? this.descriptionKu,
      descriptionBad: descriptionBad ?? this.descriptionBad,
      capacity: capacity ?? this.capacity,
      sizeSqm: sizeSqm ?? this.sizeSqm,
      price: price ?? this.price,
      discountPercent: discountPercent ?? this.discountPercent,
      amenities: amenities ?? this.amenities,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      isNew: isNew ?? this.isNew,
      createdAt: createdAt ?? this.createdAt,
      primaryImageUrl: primaryImageUrl ?? this.primaryImageUrl,
    );
  }
  
  @override
  String toString() {
    return 'Accommodation(id: $id, name: $name, areaId: $areaId, typeId: $typeId, price: $price)';
  }
} 