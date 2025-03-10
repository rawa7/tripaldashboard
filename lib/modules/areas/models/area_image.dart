import 'package:flutter/foundation.dart';

class AreaImage {
  final String? id;
  final String areaId;
  final String imageUrl;
  final bool isPrimary;
  final String? caption;
  final DateTime? createdAt;
  
  AreaImage({
    this.id,
    required this.areaId,
    required this.imageUrl,
    this.isPrimary = false,
    this.caption,
    this.createdAt,
  });
  
  factory AreaImage.fromJson(Map<String, dynamic> json) {
    return AreaImage(
      id: json['id'],
      areaId: json['area_id'] ?? '',
      imageUrl: json['image_url'] ?? '',
      isPrimary: json['is_primary'] ?? false,
      caption: json['caption'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'area_id': areaId,
      'image_url': imageUrl,
      'is_primary': isPrimary,
      if (caption != null) 'caption': caption,
    };
  }
  
  AreaImage copyWith({
    String? id,
    String? areaId,
    String? imageUrl,
    bool? isPrimary,
    String? caption,
    DateTime? createdAt,
  }) {
    return AreaImage(
      id: id ?? this.id,
      areaId: areaId ?? this.areaId,
      imageUrl: imageUrl ?? this.imageUrl,
      isPrimary: isPrimary ?? this.isPrimary,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  @override
  String toString() {
    return 'AreaImage(id: $id, areaId: $areaId, imageUrl: $imageUrl, isPrimary: $isPrimary)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AreaImage &&
        other.id == id &&
        other.areaId == areaId &&
        other.imageUrl == imageUrl &&
        other.isPrimary == isPrimary;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        areaId.hashCode ^
        imageUrl.hashCode ^
        isPrimary.hashCode;
  }
} 