import 'package:flutter/foundation.dart';

class Activity {
  final String? id;
  final String areaId;
  final String? typeId;
  final String name;
  final String description;
  // Multilingual fields
  final String? nameAr;
  final String? nameKu;
  final String? nameBad;
  final String? descriptionAr;
  final String? descriptionKu;
  final String? descriptionBad;
  final double? pricePerPerson;
  final double? groupPrice;
  final double? flatRate;
  final double? discountPercent;
  final int? capacity;
  final int? durationMinutes;
  final String? thumbnailUrl;
  final bool isActive;
  final bool isFeatured;
  final bool isNew;
  final DateTime? createdAt;
  
  Activity({
    this.id,
    required this.areaId,
    this.typeId,
    required this.name,
    required this.description,
    this.nameAr,
    this.nameKu,
    this.nameBad,
    this.descriptionAr,
    this.descriptionKu,
    this.descriptionBad,
    this.pricePerPerson,
    this.groupPrice,
    this.flatRate,
    this.discountPercent,
    this.capacity,
    this.durationMinutes,
    this.thumbnailUrl,
    this.isActive = true,
    this.isFeatured = false,
    this.isNew = true,
    this.createdAt,
  });
  
  // Helper to ensure id is not null, throws exception if it is
  String get requireId {
    if (id == null) {
      throw Exception('Activity ID is null');
    }
    return id!;
  }
  
  // Create a copy of this Activity with the given fields replaced with the new values
  Activity copyWith({
    String? id,
    String? areaId,
    String? typeId,
    String? name,
    String? description,
    String? nameAr,
    String? nameKu,
    String? nameBad,
    String? descriptionAr,
    String? descriptionKu,
    String? descriptionBad,
    double? pricePerPerson,
    double? groupPrice,
    double? flatRate,
    double? discountPercent,
    int? capacity,
    int? durationMinutes,
    String? thumbnailUrl,
    bool? isActive,
    bool? isFeatured,
    bool? isNew,
    DateTime? createdAt,
  }) {
    return Activity(
      id: id ?? this.id,
      areaId: areaId ?? this.areaId,
      typeId: typeId ?? this.typeId,
      name: name ?? this.name,
      description: description ?? this.description,
      nameAr: nameAr ?? this.nameAr,
      nameKu: nameKu ?? this.nameKu,
      nameBad: nameBad ?? this.nameBad,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      descriptionKu: descriptionKu ?? this.descriptionKu,
      descriptionBad: descriptionBad ?? this.descriptionBad,
      pricePerPerson: pricePerPerson ?? this.pricePerPerson,
      groupPrice: groupPrice ?? this.groupPrice,
      flatRate: flatRate ?? this.flatRate,
      discountPercent: discountPercent ?? this.discountPercent,
      capacity: capacity ?? this.capacity,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      isNew: isNew ?? this.isNew,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  // Helper method to get display price
  String get displayPrice {
    if (flatRate != null && flatRate! > 0) {
      return '\$${flatRate!.toStringAsFixed(2)} flat rate';
    } else if (groupPrice != null && groupPrice! > 0) {
      return '\$${groupPrice!.toStringAsFixed(2)} per group';
    } else if (pricePerPerson != null && pricePerPerson! > 0) {
      return '\$${pricePerPerson!.toStringAsFixed(2)} per person';
    } else {
      return 'Price not set';
    }
  }
  
  // Helper method to get duration as a readable string
  String get durationFormatted {
    if (durationMinutes == null || durationMinutes! <= 0) {
      return 'Duration not set';
    }
    
    final hours = durationMinutes! ~/ 60;
    final minutes = durationMinutes! % 60;
    
    if (hours > 0 && minutes > 0) {
      return '$hours hr ${minutes} min';
    } else if (hours > 0) {
      return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    } else {
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    }
  }
  
  // Convert from JSON to Activity
  factory Activity.fromJson(Map<String, dynamic> json) {
    try {
      return Activity(
        id: json['id'],
        areaId: json['area_id'] ?? '',
        typeId: json['type_id'],
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        nameAr: json['name_ar'],
        nameKu: json['name_ku'],
        nameBad: json['name_bad'],
        descriptionAr: json['description_ar'],
        descriptionKu: json['description_ku'],
        descriptionBad: json['description_bad'],
        pricePerPerson: json['price_per_person'] != null
            ? double.tryParse(json['price_per_person'].toString())
            : null,
        groupPrice: json['group_price'] != null
            ? double.tryParse(json['group_price'].toString())
            : null,
        flatRate: json['flat_rate'] != null
            ? double.tryParse(json['flat_rate'].toString())
            : null,
        discountPercent: json['discount_percent'] != null
            ? double.tryParse(json['discount_percent'].toString())
            : null,
        capacity: json['capacity'] != null
            ? int.tryParse(json['capacity'].toString())
            : null,
        durationMinutes: json['duration_minutes'] != null
            ? int.tryParse(json['duration_minutes'].toString())
            : null,
        thumbnailUrl: json['thumbnail_url'],
        isActive: json['is_active'] == true,
        isFeatured: json['is_featured'] == true,
        isNew: json['is_new'] == true,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
      );
    } catch (e) {
      debugPrint('Error parsing Activity from JSON: $e');
      return Activity(
        areaId: '',
        name: 'Error Loading Activity',
        description: 'There was an error loading this activity.',
      );
    }
  }
  
  // Convert to JSON from Activity
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'area_id': areaId,
      'type_id': typeId,
      'name': name,
      'description': description,
      if (nameAr != null) 'name_ar': nameAr,
      if (nameKu != null) 'name_ku': nameKu,
      if (nameBad != null) 'name_bad': nameBad,
      if (descriptionAr != null) 'description_ar': descriptionAr,
      if (descriptionKu != null) 'description_ku': descriptionKu,
      if (descriptionBad != null) 'description_bad': descriptionBad,
      if (pricePerPerson != null) 'price_per_person': pricePerPerson,
      if (groupPrice != null) 'group_price': groupPrice,
      if (flatRate != null) 'flat_rate': flatRate,
      if (discountPercent != null) 'discount_percent': discountPercent,
      if (capacity != null) 'capacity': capacity,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      'is_active': isActive,
      'is_featured': isFeatured,
      'is_new': isNew,
    };
  }
  
  @override
  String toString() {
    return 'Activity(id: $id, name: $name, areaId: $areaId)';
  }
} 