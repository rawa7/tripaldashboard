import 'package:uuid/uuid.dart';

class SubCity {
  final String id;
  final String cityId;
  final String name;
  final String description;
  final DateTime createdAt;
  final String? thumbnailUrl;

  SubCity({
    required this.id,
    required this.cityId,
    required this.name,
    required this.description,
    required this.createdAt,
    this.thumbnailUrl,
  });

  // Create a new sub_city with a generated UUID
  factory SubCity.create({
    required String cityId,
    required String name,
    required String description,
    String? thumbnailUrl,
  }) {
    return SubCity(
      id: const Uuid().v4(),
      cityId: cityId,
      name: name,
      description: description,
      createdAt: DateTime.now().toUtc(),
      thumbnailUrl: thumbnailUrl,
    );
  }

  // Create a sub_city from a JSON map (from Supabase)
  factory SubCity.fromJson(Map<String, dynamic> json) {
    return SubCity(
      id: json['id'],
      cityId: json['city_id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      thumbnailUrl: json['thumbnail_url'],
    );
  }

  // Convert sub_city to a JSON map (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city_id': cityId,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'thumbnail_url': thumbnailUrl,
    };
  }

  // Create a copy of this sub_city with updated fields
  SubCity copyWith({
    String? cityId,
    String? name,
    String? description,
    String? thumbnailUrl,
  }) {
    return SubCity(
      id: id,
      cityId: cityId ?? this.cityId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubCity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 