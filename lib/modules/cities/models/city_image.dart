import 'package:uuid/uuid.dart';

class CityImage {
  final String id;
  final String cityId;
  final String imageUrl;
  final bool isPrimary;
  final String? caption;
  final DateTime createdAt;

  CityImage({
    required this.id,
    required this.cityId,
    required this.imageUrl,
    required this.isPrimary,
    this.caption,
    required this.createdAt,
  });

  // Create a new city image with a generated UUID
  factory CityImage.create({
    required String cityId,
    required String imageUrl,
    bool isPrimary = false,
    String? caption,
  }) {
    return CityImage(
      id: const Uuid().v4(),
      cityId: cityId,
      imageUrl: imageUrl,
      isPrimary: isPrimary,
      caption: caption,
      createdAt: DateTime.now().toUtc(),
    );
  }

  // Create a city image from a JSON map (from Supabase)
  factory CityImage.fromJson(Map<String, dynamic> json) {
    return CityImage(
      id: json['id'],
      cityId: json['city_id'],
      imageUrl: json['image_url'],
      isPrimary: json['is_primary'] ?? false,
      caption: json['caption'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Convert city image to a JSON map (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city_id': cityId,
      'image_url': imageUrl,
      'is_primary': isPrimary,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create a copy of this city image with updated fields
  CityImage copyWith({
    String? imageUrl,
    bool? isPrimary,
    String? caption,
  }) {
    return CityImage(
      id: id,
      cityId: cityId,
      imageUrl: imageUrl ?? this.imageUrl,
      isPrimary: isPrimary ?? this.isPrimary,
      caption: caption ?? this.caption,
      createdAt: createdAt,
    );
  }
} 