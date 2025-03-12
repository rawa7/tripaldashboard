import 'package:flutter/foundation.dart';

class Area {
  final String? id;
  final String name;
  final String description;
  final String? nameAr;
  final String? descriptionAr;
  final String? nameKu;
  final String? descriptionKu;
  final String? nameBad;
  final String? descriptionBad;
  final String? subCityId;
  final String? subCityName;
  final double? latitude;
  final double? longitude;
  final String? thumbnailUrl;
  final bool? isFeatured;
  final DateTime? createdAt;
  
  Area({
    this.id,
    required this.name,
    required this.description,
    this.nameAr,
    this.descriptionAr,
    this.nameKu,
    this.descriptionKu,
    this.nameBad,
    this.descriptionBad,
    this.subCityId,
    this.subCityName,
    this.latitude,
    this.longitude,
    this.thumbnailUrl,
    this.isFeatured,
    this.createdAt,
  });
  
  factory Area.fromJson(Map<String, dynamic> json) {
    // Debug log to trace json parsing
    debugPrint('🔍 Area.fromJson: ${json.keys.toList()}');
    
    try {
      // Helper function to parse double values safely
      double? parseDouble(dynamic value) {
        if (value == null) return null;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value);
        return null;
      }
      
      final area = Area(
        id: json['id'],
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        nameAr: json['name_ar'],
        descriptionAr: json['description_ar'],
        nameKu: json['name_ku'],
        descriptionKu: json['description_ku'],
        nameBad: json['name_bad'],
        descriptionBad: json['description_bad'],
        subCityId: json['sub_city_id'],
        subCityName: json['sub_cities'] != null ? json['sub_cities']['name'] : null,
        latitude: parseDouble(json['latitude']),
        longitude: parseDouble(json['longitude']),
        thumbnailUrl: json['thumbnail_url'],
        isFeatured: json['is_featured'],
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at'])
            : null,
      );
      
      debugPrint('✅ Successfully parsed Area: ${area.id}');
      return area;
    } catch (e, stackTrace) {
      debugPrint('❌ Error parsing Area from JSON: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      debugPrint('❌ JSON data: $json');
      
      // Return a minimum valid area to avoid crashes
      return Area(
        id: json['id'],
        name: json['name'] ?? 'Error parsing name',
        description: json['description'] ?? 'Error parsing description',
      );
    }
  }
  
  Map<String, dynamic> toJson() {
    final json = {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      if (nameAr != null && nameAr!.isNotEmpty) 'name_ar': nameAr,
      if (descriptionAr != null && descriptionAr!.isNotEmpty) 'description_ar': descriptionAr,
      if (nameKu != null && nameKu!.isNotEmpty) 'name_ku': nameKu,
      if (descriptionKu != null && descriptionKu!.isNotEmpty) 'description_ku': descriptionKu,
      if (nameBad != null && nameBad!.isNotEmpty) 'name_bad': nameBad,
      if (descriptionBad != null && descriptionBad!.isNotEmpty) 'description_bad': descriptionBad,
      if (subCityId != null) 'sub_city_id': subCityId,
      // Always include latitude and longitude since they're required in the database
      'latitude': latitude ?? 0.0,  // Default to 0.0 if null
      'longitude': longitude ?? 0.0, // Default to 0.0 if null
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (isFeatured != null) 'is_featured': isFeatured,
    };
    
    debugPrint('🔍 Area.toJson: ${json.keys.toList()}');
    return json;
  }
  
  Area copyWith({
    String? id,
    String? name,
    String? description,
    String? nameAr,
    String? descriptionAr,
    String? nameKu,
    String? descriptionKu,
    String? nameBad,
    String? descriptionBad,
    String? subCityId,
    String? subCityName,
    double? latitude,
    double? longitude,
    String? thumbnailUrl,
    bool? isFeatured,
    DateTime? createdAt,
  }) {
    return Area(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      nameAr: nameAr ?? this.nameAr,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      nameKu: nameKu ?? this.nameKu,
      descriptionKu: descriptionKu ?? this.descriptionKu,
      nameBad: nameBad ?? this.nameBad,
      descriptionBad: descriptionBad ?? this.descriptionBad,
      subCityId: subCityId ?? this.subCityId,
      subCityName: subCityName ?? this.subCityName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  @override
  String toString() {
    return 'Area(id: $id, name: $name, description: $description, subCityId: $subCityId, subCityName: $subCityName, latitude: $latitude, longitude: $longitude, thumbnailUrl: $thumbnailUrl, isFeatured: $isFeatured)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Area &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.nameAr == nameAr &&
        other.descriptionAr == descriptionAr &&
        other.nameKu == nameKu &&
        other.descriptionKu == descriptionKu &&
        other.nameBad == nameBad &&
        other.descriptionBad == descriptionBad &&
        other.subCityId == subCityId &&
        other.subCityName == subCityName &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.thumbnailUrl == thumbnailUrl &&
        other.isFeatured == isFeatured;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        nameAr.hashCode ^
        descriptionAr.hashCode ^
        nameKu.hashCode ^
        descriptionKu.hashCode ^
        nameBad.hashCode ^
        descriptionBad.hashCode ^
        subCityId.hashCode ^
        subCityName.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        thumbnailUrl.hashCode ^
        isFeatured.hashCode;
  }
} 