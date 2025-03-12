import 'package:flutter/foundation.dart';

class AccommodationType {
  final String? id;
  final String name;
  final String? description;
  final String? nameAr;
  final String? nameKu;
  final String? nameBad;
  final String? descriptionAr;
  final String? descriptionKu;
  final String? descriptionBad;
  final String? bookingUnit; // How the accommodation is booked (per night, per hour, etc.)
  final DateTime? createdAt;
  
  AccommodationType({
    this.id,
    required this.name,
    this.description,
    this.nameAr,
    this.nameKu,
    this.nameBad,
    this.descriptionAr,
    this.descriptionKu,
    this.descriptionBad,
    this.bookingUnit,
    this.createdAt,
  });
  
  factory AccommodationType.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 AccommodationType.fromJson: ${json.keys.toList()}');
    
    try {
      final type = AccommodationType(
        id: json['id'],
        name: json['name'] ?? '',
        description: json['description'],
        nameAr: json['name_ar'],
        nameKu: json['name_ku'],
        nameBad: json['name_bad'],
        descriptionAr: json['description_ar'],
        descriptionKu: json['description_ku'],
        descriptionBad: json['description_bad'],
        bookingUnit: json['booking_unit'],
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at'])
            : null,
      );
      
      debugPrint('✅ Successfully parsed AccommodationType: ${type.id}');
      return type;
    } catch (e, stackTrace) {
      debugPrint('❌ Error parsing AccommodationType from JSON: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      debugPrint('❌ JSON data: $json');
      
      // Return a minimum valid type to avoid crashes
      return AccommodationType(
        id: json['id'],
        name: json['name'] ?? 'Error parsing name',
      );
    }
  }
  
  Map<String, dynamic> toJson() {
    final json = {
      if (id != null) 'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (nameAr != null) 'name_ar': nameAr,
      if (nameKu != null) 'name_ku': nameKu,
      if (nameBad != null) 'name_bad': nameBad,
      if (descriptionAr != null) 'description_ar': descriptionAr,
      if (descriptionKu != null) 'description_ku': descriptionKu,
      if (descriptionBad != null) 'description_bad': descriptionBad,
      if (bookingUnit != null) 'booking_unit': bookingUnit,
    };
    
    debugPrint('🔍 AccommodationType.toJson: ${json.keys.toList()}');
    return json;
  }
  
  AccommodationType copyWith({
    String? id,
    String? name,
    String? description,
    String? nameAr,
    String? nameKu,
    String? nameBad,
    String? descriptionAr,
    String? descriptionKu,
    String? descriptionBad,
    String? bookingUnit,
    DateTime? createdAt,
  }) {
    return AccommodationType(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      nameAr: nameAr ?? this.nameAr,
      nameKu: nameKu ?? this.nameKu,
      nameBad: nameBad ?? this.nameBad,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionKu: descriptionKu ?? this.descriptionKu,
      descriptionBad: descriptionBad ?? this.descriptionBad,
      bookingUnit: bookingUnit ?? this.bookingUnit,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  @override
  String toString() {
    return 'AccommodationType(id: $id, name: $name)';
  }
} 