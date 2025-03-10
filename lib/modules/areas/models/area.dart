import 'package:flutter/foundation.dart';

class Area {
  final String? id;
  final String name;
  final String description;
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
    this.subCityId,
    this.subCityName,
    this.latitude,
    this.longitude,
    this.thumbnailUrl,
    this.isFeatured,
    this.createdAt,
  });
  
  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      subCityId: json['sub_city_id'],
      subCityName: json['sub_cities'] != null ? json['sub_cities']['name'] : null,
      latitude: json['latitude'],
      longitude: json['longitude'],
      thumbnailUrl: json['thumbnail_url'],
      isFeatured: json['is_featured'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      if (subCityId != null) 'sub_city_id': subCityId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (isFeatured != null) 'is_featured': isFeatured,
    };
  }
  
  Area copyWith({
    String? id,
    String? name,
    String? description,
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
        subCityId.hashCode ^
        subCityName.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        thumbnailUrl.hashCode ^
        isFeatured.hashCode;
  }
} 