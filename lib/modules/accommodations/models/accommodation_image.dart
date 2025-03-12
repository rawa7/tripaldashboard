import 'package:flutter/foundation.dart';

enum MediaType {
  image,
  video
}

extension MediaTypeExtension on MediaType {
  String get value {
    switch (this) {
      case MediaType.image:
        return 'image';
      case MediaType.video:
        return 'video';
    }
  }
  
  static MediaType fromString(String? value) {
    switch (value) {
      case 'video':
        return MediaType.video;
      case 'image':
      default:
        return MediaType.image;
    }
  }
}

class AccommodationImage {
  final String? id;
  final String accommodationId;
  final String imageUrl;
  final bool isPrimary;
  final String? caption;
  final String? captionAr;
  final String? captionKu;
  final String? captionBad;
  final DateTime? createdAt;
  final MediaType mediaType;
  final String? thumbnailUrl;
  final int displayOrder;
  
  AccommodationImage({
    this.id,
    required this.accommodationId,
    required this.imageUrl,
    this.isPrimary = false,
    this.caption,
    this.captionAr,
    this.captionKu,
    this.captionBad,
    this.createdAt,
    this.mediaType = MediaType.image,
    this.thumbnailUrl,
    this.displayOrder = 0,
  });
  
  String get requireId {
    if (id == null) {
      throw Exception('Image ID is required but was null');
    }
    return id!;
  }
  
  factory AccommodationImage.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 AccommodationImage.fromJson: ${json.keys.toList()}');
    
    try {
      final image = AccommodationImage(
        id: json['id'],
        accommodationId: json['accommodation_id'] ?? '',
        imageUrl: json['image_url'] ?? '',
        isPrimary: json['is_primary'] ?? false,
        caption: json['caption'],
        captionAr: json['caption_ar'],
        captionKu: json['caption_ku'],
        captionBad: json['caption_bad'],
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at'])
            : null,
        mediaType: MediaTypeExtension.fromString(json['media_type']),
        thumbnailUrl: json['thumbnail_url'],
        displayOrder: json['display_order'] ?? 0,
      );
      
      debugPrint('✅ Successfully parsed AccommodationImage: ${image.id}');
      return image;
    } catch (e, stackTrace) {
      debugPrint('❌ Error parsing AccommodationImage from JSON: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      debugPrint('❌ JSON data: $json');
      
      // Return a minimum valid image to avoid crashes
      return AccommodationImage(
        id: json['id'],
        accommodationId: json['accommodation_id'] ?? '',
        imageUrl: json['image_url'] ?? '',
      );
    }
  }
  
  Map<String, dynamic> toJson() {
    final json = {
      if (id != null) 'id': id,
      'accommodation_id': accommodationId,
      'image_url': imageUrl,
      'is_primary': isPrimary,
      if (caption != null) 'caption': caption,
      if (captionAr != null) 'caption_ar': captionAr,
      if (captionKu != null) 'caption_ku': captionKu,
      if (captionBad != null) 'caption_bad': captionBad,
      'media_type': mediaType.value,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      'display_order': displayOrder,
    };
    
    debugPrint('🔍 AccommodationImage.toJson: ${json.keys.toList()}');
    return json;
  }
  
  AccommodationImage copyWith({
    String? id,
    String? accommodationId,
    String? imageUrl,
    bool? isPrimary,
    String? caption,
    String? captionAr,
    String? captionKu,
    String? captionBad,
    DateTime? createdAt,
    MediaType? mediaType,
    String? thumbnailUrl,
    int? displayOrder,
  }) {
    return AccommodationImage(
      id: id ?? this.id,
      accommodationId: accommodationId ?? this.accommodationId,
      imageUrl: imageUrl ?? this.imageUrl,
      isPrimary: isPrimary ?? this.isPrimary,
      caption: caption ?? this.caption,
      captionAr: captionAr ?? this.captionAr,
      captionKu: captionKu ?? this.captionKu,
      captionBad: captionBad ?? this.captionBad,
      createdAt: createdAt ?? this.createdAt,
      mediaType: mediaType ?? this.mediaType,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }
  
  @override
  String toString() {
    return 'AccommodationImage(id: $id, accommodationId: $accommodationId, imageUrl: $imageUrl, isPrimary: $isPrimary, mediaType: $mediaType)';
  }
} 