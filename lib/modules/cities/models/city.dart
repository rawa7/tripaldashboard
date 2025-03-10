import 'package:uuid/uuid.dart';

class City {
  final String id;
  final String regionId;
  final String name;
  final String description;
  final DateTime createdAt;
  final String? thumbnailUrl;

  City({
    required this.id,
    required this.regionId,
    required this.name,
    required this.description,
    required this.createdAt,
    this.thumbnailUrl,
  });

  // Create a new city with a generated UUID
  factory City.create({
    required String regionId,
    required String name,
    required String description,
    String? thumbnailUrl,
  }) {
    return City(
      id: const Uuid().v4(),
      regionId: regionId,
      name: name,
      description: description,
      createdAt: DateTime.now().toUtc(),
      thumbnailUrl: thumbnailUrl,
    );
  }

  // Create a city from a JSON map (from Supabase)
  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      regionId: json['region_id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      thumbnailUrl: json['thumbnail_url'],
    );
  }

  // Convert city to a JSON map (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'region_id': regionId,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'thumbnail_url': thumbnailUrl,
    };
  }

  // Create a copy of this city with updated fields
  City copyWith({
    String? regionId,
    String? name,
    String? description,
    String? thumbnailUrl,
  }) {
    return City(
      id: id,
      regionId: regionId ?? this.regionId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
} 