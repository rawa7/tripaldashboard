import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/accommodation_availability.dart';
import '../../../core/services/supabase_service.dart';

// Provider for the AvailabilityService
final availabilityServiceProvider = Provider<AvailabilityService>((ref) {
  return AvailabilityService();
});

// Provider for fetching all availabilities for an accommodation
final accommodationAvailabilitiesProvider = FutureProvider.family<List<AccommodationAvailability>, String>((ref, accommodationId) async {
  final service = ref.watch(availabilityServiceProvider);
  return service.getAvailabilitiesForAccommodation(accommodationId);
});

// Provider for a single availability
final availabilityProvider = FutureProvider.family<AccommodationAvailability?, String>((ref, id) async {
  final service = ref.watch(availabilityServiceProvider);
  return service.getAvailability(id);
});

// Service class for handling availability operations
class AvailabilityService {
  final SupabaseClient _supabaseClient = SupabaseService.staticClient;
  
  // Fetch all availabilities for an accommodation
  Future<List<AccommodationAvailability>> getAvailabilitiesForAccommodation(String accommodationId) async {
    try {
      final response = await _supabaseClient
          .from('accommodation_availability')
          .select()
          .eq('accommodation_id', accommodationId)
          .order('start_time');
      
      final availabilities = response
          .map<AccommodationAvailability>((json) => AccommodationAvailability.fromJson(json))
          .toList();
      
      debugPrint('✅ Fetched ${availabilities.length} availabilities for accommodation $accommodationId');
      return availabilities;
    } catch (e) {
      debugPrint('❌ Error fetching availabilities: $e');
      return [];
    }
  }
  
  // Fetch a single availability by ID
  Future<AccommodationAvailability?> getAvailability(String id) async {
    try {
      final response = await _supabaseClient
          .from('accommodation_availability')
          .select()
          .eq('id', id)
          .single();
      
      final availability = AccommodationAvailability.fromJson(response);
      
      debugPrint('✅ Fetched availability: ${availability.id}');
      return availability;
    } catch (e) {
      debugPrint('❌ Error fetching availability: $e');
      return null;
    }
  }
  
  // Create a new availability period
  Future<AccommodationAvailability?> createAvailability(AccommodationAvailability availability) async {
    try {
      final response = await _supabaseClient
          .from('accommodation_availability')
          .insert(availability.toJson())
          .select()
          .single();
      
      final createdAvailability = AccommodationAvailability.fromJson(response);
      
      debugPrint('✅ Created availability: ${createdAvailability.id}');
      return createdAvailability;
    } catch (e) {
      debugPrint('❌ Error creating availability: $e');
      return null;
    }
  }
  
  // Update an existing availability period
  Future<AccommodationAvailability?> updateAvailability(AccommodationAvailability availability) async {
    if (availability.id == null) {
      debugPrint('❌ Cannot update availability without an ID');
      return null;
    }
    
    try {
      final response = await _supabaseClient
          .from('accommodation_availability')
          .update(availability.toJson())
          .eq('id', availability.requireId)
          .select()
          .single();
      
      final updatedAvailability = AccommodationAvailability.fromJson(response);
      
      debugPrint('✅ Updated availability: ${updatedAvailability.id}');
      return updatedAvailability;
    } catch (e) {
      debugPrint('❌ Error updating availability: $e');
      return null;
    }
  }
  
  // Delete an availability period
  Future<bool> deleteAvailability(String id) async {
    try {
      await _supabaseClient
          .from('accommodation_availability')
          .delete()
          .eq('id', id);
      
      debugPrint('✅ Deleted availability: $id');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting availability: $e');
      return false;
    }
  }
  
  // Check if a new availability period would overlap with existing ones
  Future<bool> wouldOverlap(
    AccommodationAvailability newAvailability, 
    {String? excludeId}
  ) async {
    try {
      final availabilities = await getAvailabilitiesForAccommodation(newAvailability.accommodationId);
      
      // Filter out the availability that's being updated (if any)
      final filteredAvailabilities = availabilities
          .where((a) => a.id != excludeId)
          .toList();
      
      // Check if any existing availability would overlap with the new one
      for (final availability in filteredAvailabilities) {
        if (newAvailability.overlaps(availability)) {
          debugPrint('⚠️ New availability would overlap with existing period: ${availability.id}');
          return true;
        }
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Error checking for overlap: $e');
      return true; // Assume overlap on error to be safe
    }
  }
} 