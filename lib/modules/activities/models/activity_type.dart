import 'package:flutter/foundation.dart';

class ActivityType {
  final String? id;
  final String name;
  final String description;
  // Multilingual fields
  final String? nameAr;
  final String? nameKu;
  final String? nameBad;
  final String? descriptionAr;
  final String? descriptionKu;
  final String? descriptionBad;
  final DateTime? createdAt;
  
  ActivityType({
    this.id,
    required this.name,
    required this.description,
    this.nameAr,
    this.nameKu,
    this.nameBad,
    this.descriptionAr,
    this.descriptionKu,
    this.descriptionBad,
    this.createdAt,
  });
  
  // Helper method to ensure ID is available
  String get requireId {
    if (id == null) {
      throw Exception('Activity Type ID cannot be null');
    }
    return id!;
  }
  
  // Create a copy with some field updates
  ActivityType copyWith({
    String? id,
    String? name,
    String? description,
    String? nameAr,
    String? nameKu,
    String? nameBad,
    String? descriptionAr,
    String? descriptionKu,
    String? descriptionBad,
    DateTime? createdAt,
  }) {
    return ActivityType(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      nameAr: nameAr ?? this.nameAr,
      nameKu: nameKu ?? this.nameKu,
      nameBad: nameBad ?? this.nameBad,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionKu: descriptionKu ?? this.descriptionKu,
      descriptionBad: descriptionBad ?? this.descriptionBad,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  // Convert from JSON (database response)
  factory ActivityType.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 ActivityType.fromJson: ${json.keys.toList()}');
    
    try {
      return ActivityType(
        id: json['id'],
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        nameAr: json['name_ar'],
        nameKu: json['name_ku'],
        nameBad: json['name_bad'],
        descriptionAr: json['description_ar'],
        descriptionKu: json['description_ku'],
        descriptionBad: json['description_bad'],
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at']) 
            : null,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error parsing ActivityType from JSON: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      debugPrint('❌ JSON data: $json');
      
      // Return a minimum valid type to avoid crashes
      return ActivityType(
        id: json['id'],
        name: json['name'] ?? 'Unknown Type',
        description: json['description'] ?? 'Unknown Description',
      );
    }
  }
  
  // Convert to JSON (for database operations)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      if (nameAr != null) 'name_ar': nameAr,
      if (nameKu != null) 'name_ku': nameKu,
      if (nameBad != null) 'name_bad': nameBad,
      if (descriptionAr != null) 'description_ar': descriptionAr,
      if (descriptionKu != null) 'description_ku': descriptionKu,
      if (descriptionBad != null) 'description_bad': descriptionBad,
    };
  }
  
  @override
  String toString() {
    return 'ActivityType(id: $id, name: $name)';
  }
} 