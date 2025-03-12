import 'package:flutter/foundation.dart';

class AccommodationVideo {
  final String? id;
  final String accommodationId;
  final String videoUrl;
  final String? title;
  final String? description;
  final String? titleAr;
  final String? descriptionAr;
  final String? titleKu;
  final String? descriptionKu;
  final String? titleBad;
  final String? descriptionBad;
  final bool isPrimary;
  final DateTime? createdAt;
  final String? thumbnailUrl;

  AccommodationVideo({
    this.id,
    required this.accommodationId,
    required this.videoUrl,
    this.title,
    this.description,
    this.titleAr,
    this.descriptionAr,
    this.titleKu,
    this.descriptionKu,
    this.titleBad,
    this.descriptionBad,
    this.isPrimary = false,
    this.createdAt,
    this.thumbnailUrl,
  });

  factory AccommodationVideo.fromJson(Map<String, dynamic> json) {
    return AccommodationVideo(
      id: json['id'],
      accommodationId: json['accommodation_id'],
      videoUrl: json['video_url'],
      title: json['title'],
      description: json['description'],
      titleAr: json['title_ar'],
      descriptionAr: json['description_ar'],
      titleKu: json['title_ku'],
      descriptionKu: json['description_ku'],
      titleBad: json['title_bad'],
      descriptionBad: json['description_bad'],
      isPrimary: json['is_primary'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : null,
      thumbnailUrl: json['thumbnail_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'accommodation_id': accommodationId,
      'video_url': videoUrl,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (titleAr != null) 'title_ar': titleAr,
      if (descriptionAr != null) 'description_ar': descriptionAr,
      if (titleKu != null) 'title_ku': titleKu,
      if (descriptionKu != null) 'description_ku': descriptionKu,
      if (titleBad != null) 'title_bad': titleBad,
      if (descriptionBad != null) 'description_bad': descriptionBad,
      'is_primary': isPrimary,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
    };
  }
} 