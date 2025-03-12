import 'package:uuid/uuid.dart';

class SubCity {
  final String id;
  final String cityId;
  final String name;
  final String description;
  final String? nameAr;
  final String? nameKu;
  final String? nameBad;
  final String? descriptionAr;
  final String? descriptionKu;
  final String? descriptionBad;
  final DateTime createdAt;
  final String? thumbnailUrl;

  SubCity({
    required this.id,
    required this.cityId,
    required this.name,
    required this.description,
    this.nameAr,
    this.nameKu,
    this.nameBad,
    this.descriptionAr,
    this.descriptionKu,
    this.descriptionBad,
    required this.createdAt,
    this.thumbnailUrl,
  });

  // Create a new sub_city with a generated UUID
  factory SubCity.create({
    required String cityId,
    required String name,
    required String description,
    String? nameAr,
    String? nameKu,
    String? nameBad,
    String? descriptionAr,
    String? descriptionKu,
    String? descriptionBad,
    String? thumbnailUrl,
  }) {
    return SubCity(
      id: const Uuid().v4(),
      cityId: cityId,
      name: name,
      description: description,
      nameAr: nameAr,
      nameKu: nameKu,
      nameBad: nameBad,
      descriptionAr: descriptionAr,
      descriptionKu: descriptionKu,
      descriptionBad: descriptionBad,
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
      nameAr: json['name_ar'],
      nameKu: json['name_ku'],
      nameBad: json['name_bad'],
      descriptionAr: json['description_ar'],
      descriptionKu: json['description_ku'],
      descriptionBad: json['description_bad'],
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
      'name_ar': nameAr,
      'name_ku': nameKu,
      'name_bad': nameBad,
      'description_ar': descriptionAr,
      'description_ku': descriptionKu,
      'description_bad': descriptionBad,
      'created_at': createdAt.toIso8601String(),
      'thumbnail_url': thumbnailUrl,
    };
  }

  // Create a copy of this sub_city with updated fields
  SubCity copyWith({
    String? cityId,
    String? name,
    String? description,
    String? nameAr,
    String? nameKu,
    String? nameBad,
    String? descriptionAr,
    String? descriptionKu,
    String? descriptionBad,
    String? thumbnailUrl,
  }) {
    return SubCity(
      id: id,
      cityId: cityId ?? this.cityId,
      name: name ?? this.name,
      description: description ?? this.description,
      nameAr: nameAr ?? this.nameAr,
      nameKu: nameKu ?? this.nameKu,
      nameBad: nameBad ?? this.nameBad,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionKu: descriptionKu ?? this.descriptionKu,
      descriptionBad: descriptionBad ?? this.descriptionBad,
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