import 'package:uuid/uuid.dart';

class SubCityImage {
  final String id;
  final String subCityId;
  final String imageUrl;
  final bool isPrimary;
  final String? caption;
  final DateTime createdAt;

  SubCityImage({
    required this.id,
    required this.subCityId,
    required this.imageUrl,
    required this.isPrimary,
    this.caption,
    required this.createdAt,
  });

  // Create a new image with a generated UUID
  factory SubCityImage.create({
    required String subCityId,
    required String imageUrl,
    bool isPrimary = false,
    String? caption,
  }) {
    return SubCityImage(
      id: const Uuid().v4(),
      subCityId: subCityId,
      imageUrl: imageUrl,
      isPrimary: isPrimary,
      caption: caption,
      createdAt: DateTime.now().toUtc(),
    );
  }

  // Create an image from a JSON map (from Supabase)
  factory SubCityImage.fromJson(Map<String, dynamic> json) {
    return SubCityImage(
      id: json['id'],
      subCityId: json['sub_city_id'],
      imageUrl: json['image_url'],
      isPrimary: json['is_primary'] ?? false,
      caption: json['caption'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Convert image to a JSON map (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sub_city_id': subCityId,
      'image_url': imageUrl,
      'is_primary': isPrimary,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create a copy of this image with updated fields
  SubCityImage copyWith({
    String? subCityId,
    String? imageUrl,
    bool? isPrimary,
    String? caption,
  }) {
    return SubCityImage(
      id: id,
      subCityId: subCityId ?? this.subCityId,
      imageUrl: imageUrl ?? this.imageUrl,
      isPrimary: isPrimary ?? this.isPrimary,
      caption: caption ?? this.caption,
      createdAt: createdAt,
    );
  }
} 