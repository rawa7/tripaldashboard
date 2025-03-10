class City {
  final String id;
  final String regionId;
  final String name;
  final String? description;
  final String? thumbnailUrl;
  final DateTime createdAt;

  City({
    required this.id,
    required this.regionId,
    required this.name,
    this.description,
    this.thumbnailUrl,
    required this.createdAt,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      regionId: json['region_id'],
      name: json['name'],
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'region_id': regionId,
      'name': name,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 