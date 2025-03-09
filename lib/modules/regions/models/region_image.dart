import 'package:uuid/uuid.dart';

class RegionImage {
  final String id;
  final String regionId;
  final String imageUrl;
  final bool isPrimary;
  final String? caption;
  final DateTime createdAt;

  RegionImage({
    required this.id,
    required this.regionId,
    required this.imageUrl,
    required this.isPrimary,
    this.caption,
    required this.createdAt,
  });

  // Create a new region image with a generated UUID
  factory RegionImage.create({
    required String regionId,
    required String imageUrl,
    bool isPrimary = false,
    String? caption,
  }) {
    return RegionImage(
      id: const Uuid().v4(),
      regionId: regionId,
      imageUrl: imageUrl,
      isPrimary: isPrimary,
      caption: caption,
      createdAt: DateTime.now().toUtc(),
    );
  }

  // Create a region image from a JSON map (from Supabase)
  factory RegionImage.fromJson(Map<String, dynamic> json) {
    return RegionImage(
      id: json['id'],
      regionId: json['region_id'],
      imageUrl: json['image_url'],
      isPrimary: json['is_primary'] ?? false,
      caption: json['caption'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Convert region image to a JSON map (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'region_id': regionId,
      'image_url': imageUrl,
      'is_primary': isPrimary,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create a copy of this region image with updated fields
  RegionImage copyWith({
    String? imageUrl,
    bool? isPrimary,
    String? caption,
  }) {
    return RegionImage(
      id: id,
      regionId: regionId,
      imageUrl: imageUrl ?? this.imageUrl,
      isPrimary: isPrimary ?? this.isPrimary,
      caption: caption ?? this.caption,
      createdAt: createdAt,
    );
  }
} 