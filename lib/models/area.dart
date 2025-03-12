class Area {
  final String id;
  final String subCityId;
  final String name;
  final String description;
  final String? nameAr;
  final String? descriptionAr;
  final String? nameKu;
  final String? descriptionKu;
  final String? nameBad;
  final String? descriptionBad;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final bool? isFeatured;
  final String? thumbnailUrl;

  Area({
    required this.id,
    required this.subCityId,
    required this.name,
    required this.description,
    this.nameAr,
    this.descriptionAr,
    this.nameKu,
    this.descriptionKu,
    this.nameBad,
    this.descriptionBad,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.isFeatured,
    this.thumbnailUrl,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'],
      subCityId: json['sub_city_id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      nameAr: json['name_ar'],
      descriptionAr: json['description_ar'],
      nameKu: json['name_ku'],
      descriptionKu: json['description_ku'],
      nameBad: json['name_bad'],
      descriptionBad: json['description_bad'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      createdAt: DateTime.parse(json['created_at']),
      isFeatured: json['is_featured'],
      thumbnailUrl: json['thumbnail_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sub_city_id': subCityId,
      'name': name,
      'description': description,
      'name_ar': nameAr,
      'description_ar': descriptionAr,
      'name_ku': nameKu,
      'description_ku': descriptionKu,
      'name_bad': nameBad,
      'description_bad': descriptionBad,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'is_featured': isFeatured,
      'thumbnail_url': thumbnailUrl,
    };
  }
} 