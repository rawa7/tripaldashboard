import 'package:uuid/uuid.dart';

class Region {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final String? thumbnailUrl;

  Region({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    this.thumbnailUrl,
  });

  // Create a new region with a generated UUID
  factory Region.create({
    required String name,
    required String description,
    String? thumbnailUrl,
  }) {
    return Region(
      id: const Uuid().v4(),
      name: name,
      description: description,
      createdAt: DateTime.now().toUtc(),
      thumbnailUrl: thumbnailUrl,
    );
  }

  // Create a region from a JSON map (from Supabase)
  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      thumbnailUrl: json['thumbnail_url'],
    );
  }

  // Convert region to a JSON map (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'thumbnail_url': thumbnailUrl,
    };
  }

  // Create a copy of this region with updated fields
  Region copyWith({
    String? name,
    String? description,
    String? thumbnailUrl,
  }) {
    return Region(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
} 