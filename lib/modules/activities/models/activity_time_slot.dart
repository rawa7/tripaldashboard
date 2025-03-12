import 'package:flutter/foundation.dart';

class ActivityTimeSlot {
  final String? id;
  final String activityId;
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final String startTime; // Format: HH:MM:SS
  final String endTime; // Format: HH:MM:SS
  final DateTime? createdAt;
  
  ActivityTimeSlot({
    this.id,
    required this.activityId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.createdAt,
  });
  
  // Helper method to ensure ID is available
  String get requireId {
    if (id == null) {
      throw Exception('Activity Time Slot ID cannot be null');
    }
    return id!;
  }
  
  // Create a copy with some field updates
  ActivityTimeSlot copyWith({
    String? id,
    String? activityId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    DateTime? createdAt,
  }) {
    return ActivityTimeSlot(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  // Get a formatted version of the day of week
  String get dayOfWeekName {
    switch (dayOfWeek) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Unknown';
    }
  }
  
  // Format time from HH:MM:SS to more readable format (e.g., "9:00 AM")
  String formatTimeString(String timeString) {
    try {
      final timeParts = timeString.split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      
      // Convert to 12-hour format
      hour = hour % 12;
      hour = hour == 0 ? 12 : hour;
      
      return '$hour:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return timeString;
    }
  }
  
  // Get formatted start time
  String get formattedStartTime => formatTimeString(startTime);
  
  // Get formatted end time
  String get formattedEndTime => formatTimeString(endTime);
  
  // Get a formatted time range
  String get formattedTimeRange => '$formattedStartTime - $formattedEndTime';
  
  // Convert from JSON (database response)
  factory ActivityTimeSlot.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 ActivityTimeSlot.fromJson: ${json.keys.toList()}');
    
    try {
      return ActivityTimeSlot(
        id: json['id'],
        activityId: json['activity_id'] ?? '',
        dayOfWeek: json['day_of_week'] ?? 1,
        startTime: json['start_time'] ?? '00:00:00',
        endTime: json['end_time'] ?? '00:00:00',
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at']) 
            : null,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error parsing ActivityTimeSlot from JSON: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      debugPrint('❌ JSON data: $json');
      
      // Return a minimum valid time slot to avoid crashes
      return ActivityTimeSlot(
        id: json['id'],
        activityId: json['activity_id'] ?? '',
        dayOfWeek: 1,
        startTime: '00:00:00',
        endTime: '00:00:00',
      );
    }
  }
  
  // Convert to JSON (for database operations)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'activity_id': activityId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
  
  @override
  String toString() {
    return 'ActivityTimeSlot(id: $id, activityId: $activityId, day: $dayOfWeekName, timeRange: $formattedTimeRange)';
  }
} 