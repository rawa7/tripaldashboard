import 'package:flutter/foundation.dart';

enum MediaType {
  image,
  video,
}

class ActivityImage {
  final String? id;
  final String activityId;
  final String imageUrl;
  final bool isPrimary;
  final int displayOrder;
  final DateTime? createdAt;
  final MediaType mediaType;
  final String? thumbnailUrl;
  final String? caption;
  final String? captionAr;
  final String? captionKu;
  final String? captionBad;
  
  ActivityImage({
    this.id,
    required this.activityId,
    required this.imageUrl,
    this.isPrimary = false,
    this.displayOrder = 0,
    this.createdAt,
    this.mediaType = MediaType.image,
    this.thumbnailUrl,
    this.caption,
    this.captionAr,
    this.captionKu,
    this.captionBad,
  });
  
  // Helper to ensure id is not null, throws exception if it is
  String get requireId {
    if (id == null) {
      throw Exception('ActivityImage ID is null');
    }
    return id!;
  }
  
  // Create a copy with some fields updated
  ActivityImage copyWith({
    String? id,
    String? activityId,
    String? imageUrl,
    bool? isPrimary,
    int? displayOrder,
    DateTime? createdAt,
    MediaType? mediaType,
    String? thumbnailUrl,
    String? caption,
    String? captionAr,
    String? captionKu,
    String? captionBad,
  }) {
    return ActivityImage(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      imageUrl: imageUrl ?? this.imageUrl,
      isPrimary: isPrimary ?? this.isPrimary,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      mediaType: mediaType ?? this.mediaType,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      captionAr: captionAr ?? this.captionAr,
      captionKu: captionKu ?? this.captionKu,
      captionBad: captionBad ?? this.captionBad,
    );
  }
  
  // Convert from JSON to ActivityImage
  factory ActivityImage.fromJson(Map<String, dynamic> json) {
    try {
      return ActivityImage(
        id: json['id'],
        activityId: json['activity_id'] ?? '',
        imageUrl: json['image_url'] ?? '',
        isPrimary: json['is_primary'] == true,
        displayOrder: json['display_order'] != null 
            ? int.tryParse(json['display_order'].toString()) ?? 0 
            : 0,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
        mediaType: json['media_type'] == 'video' ? MediaType.video : MediaType.image,
        thumbnailUrl: json['thumbnail_url'],
        caption: json['caption'],
        captionAr: json['caption_ar'],
        captionKu: json['caption_ku'],
        captionBad: json['caption_bad'],
      );
    } catch (e) {
      debugPrint('Error parsing ActivityImage from JSON: $e');
      return ActivityImage(
        activityId: '',
        imageUrl: 'https://via.placeholder.com/300x200?text=Error+Loading+Image',
      );
    }
  }
  
  // Convert to JSON for database operations
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'activity_id': activityId,
      'image_url': imageUrl,
      'is_primary': isPrimary,
      'display_order': displayOrder,
      'media_type': mediaType == MediaType.video ? 'video' : 'image',
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (caption != null) 'caption': caption,
      if (captionAr != null) 'caption_ar': captionAr,
      if (captionKu != null) 'caption_ku': captionKu,
      if (captionBad != null) 'caption_bad': captionBad,
    };
  }
  
  @override
  String toString() {
    return 'ActivityImage(id: $id, activityId: $activityId, isPrimary: $isPrimary, mediaType: $mediaType)';
  }
} 