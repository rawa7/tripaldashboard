import 'package:flutter/foundation.dart';
import 'package:tripaldashboard/core/models/translation.dart';

class AreaVideo {
  final String? id;
  final String areaId;
  final String videoUrl;
  final String? thumbnailUrl;
  final bool isPrimary;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String mediaType;

  AreaVideo({
    this.id,
    required this.areaId,
    required this.videoUrl,
    this.thumbnailUrl,
    this.isPrimary = false,
    this.createdAt,
    this.updatedAt,
    this.mediaType = 'video',
  });

  factory AreaVideo.fromJson(Map<String, dynamic> json) {
    return AreaVideo(
      id: json['id'],
      areaId: json['area_id'],
      videoUrl: json['video_url'] ?? json['image_url'],
      thumbnailUrl: json['thumbnail_url'],
      isPrimary: json['is_primary'] ?? false,
      mediaType: json['media_type'] ?? 'video',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'area_id': areaId,
      'video_url': videoUrl,
      'image_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'is_primary': isPrimary,
      'media_type': mediaType,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  AreaVideo copyWith({
    String? id,
    String? areaId,
    String? videoUrl,
    String? thumbnailUrl,
    bool? isPrimary,
    String? mediaType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AreaVideo(
      id: id ?? this.id,
      areaId: areaId ?? this.areaId,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isPrimary: isPrimary ?? this.isPrimary,
      mediaType: mediaType ?? this.mediaType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AreaVideo(id: $id, areaId: $areaId)';
  }
} 