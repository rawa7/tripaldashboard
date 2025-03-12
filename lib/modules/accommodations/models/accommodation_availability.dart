import 'package:flutter/foundation.dart';

class AccommodationAvailability {
  final String? id;
  final String accommodationId;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final DateTime? createdAt;
  
  AccommodationAvailability({
    this.id,
    required this.accommodationId,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.createdAt,
  });
  
  // Helper method to ensure ID is available
  String get requireId {
    if (id == null) {
      throw Exception('Availability ID cannot be null');
    }
    return id!;
  }
  
  // Create a copy with some field updates
  AccommodationAvailability copyWith({
    String? id,
    String? accommodationId,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return AccommodationAvailability(
      id: id ?? this.id,
      accommodationId: accommodationId ?? this.accommodationId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  // Convert from JSON (database response)
  factory AccommodationAvailability.fromJson(Map<String, dynamic> json) {
    try {
      return AccommodationAvailability(
        id: json['id'],
        accommodationId: json['accommodation_id'],
        startTime: DateTime.parse(json['start_time']),
        endTime: DateTime.parse(json['end_time']),
        isAvailable: json['is_available'] ?? true,
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at']) 
            : null,
      );
    } catch (e) {
      debugPrint('Error parsing AccommodationAvailability: $e');
      rethrow;
    }
  }
  
  // Convert to JSON (for database operations)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'accommodation_id': accommodationId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'is_available': isAvailable,
    };
  }
  
  // Get duration in days
  int get durationInDays => endTime.difference(startTime).inDays;
  
  // Check if availability period contains a specific date
  bool containsDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startDateOnly = DateTime(startTime.year, startTime.month, startTime.day);
    final endDateOnly = DateTime(endTime.year, endTime.month, endTime.day);
    
    return (dateOnly.isAtSameMomentAs(startDateOnly) || dateOnly.isAfter(startDateOnly)) && 
           (dateOnly.isAtSameMomentAs(endDateOnly) || dateOnly.isBefore(endDateOnly));
  }
  
  // Check if availability period overlaps with another period
  bool overlaps(AccommodationAvailability other) {
    return (startTime.isBefore(other.endTime) || startTime.isAtSameMomentAs(other.endTime)) && 
           (endTime.isAfter(other.startTime) || endTime.isAtSameMomentAs(other.startTime));
  }
  
  @override
  String toString() {
    return 'AccommodationAvailability(id: $id, accommodationId: $accommodationId, startTime: $startTime, endTime: $endTime, isAvailable: $isAvailable)';
  }
} 