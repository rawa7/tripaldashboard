import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

import '../models/accommodation.dart';
import '../models/accommodation_image.dart';
import '../models/accommodation_type.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/storage_service.dart';

// Provider for the AccommodationsService
final accommodationsServiceProvider = Provider<AccommodationsService>((ref) {
  return AccommodationsService();
});

// Provider for accommodations by area
final accommodationsByAreaProvider = FutureProvider.family<List<Accommodation>, String>((ref, areaId) async {
  final service = ref.watch(accommodationsServiceProvider);
  return service.getAccommodationsByArea(areaId);
});

// Provider for a single accommodation
final accommodationProvider = FutureProvider.family<Accommodation?, String>((ref, id) async {
  final service = ref.watch(accommodationsServiceProvider);
  return service.getAccommodation(id);
});

// Provider for accommodation types
final accommodationTypesProvider = FutureProvider<List<AccommodationType>>((ref) async {
  final service = ref.watch(accommodationsServiceProvider);
  return service.getAccommodationTypes();
});

// Provider for accommodation images
final accommodationImagesProvider = FutureProvider.family<List<AccommodationImage>, String>((ref, accommodationId) async {
  final service = ref.watch(accommodationsServiceProvider);
  return service.getAccommodationImages(accommodationId);
});

// Service class for accommodations
class AccommodationsService {
  final SupabaseClient _supabaseClient = SupabaseService.staticClient;
  final StorageService _storageService = StorageService(SupabaseService.staticClient);
  
  // Fetch accommodations for a specific area
  Future<List<Accommodation>> getAccommodationsByArea(String areaId) async {
    try {
      final response = await _supabaseClient
          .from('accommodations')
          .select('''
            *,
            areas (
              name
            ),
            accommodation_types (
              name
            )
          ''')
          .eq('area_id', areaId)
          .order('name');
      
      final List<Accommodation> accommodationList = response
          .map<Accommodation>((json) => Accommodation.fromJson(json))
          .toList();
      
      // Fetch primary images for each accommodation
      await _fetchAccommodationImages(accommodationList);
      
      debugPrint('✅ Fetched ${accommodationList.length} accommodations for area $areaId');
      return accommodationList;
    } catch (e) {
      debugPrint('❌ Error fetching accommodations: $e');
      rethrow;
    }
  }
  
  // Fetch accommodation images
  Future<void> _fetchAccommodationImages(List<Accommodation> accommodations) async {
    try {
      for (final accommodation in accommodations) {
        if (accommodation.id == null) continue;
        
        final imageResponse = await _supabaseClient
            .from('accommodation_images')
            .select()
            .eq('accommodation_id', accommodation.requireId)
            .eq('is_primary', true)
            .limit(1);
        
        if (imageResponse.isNotEmpty) {
          final image = AccommodationImage.fromJson(imageResponse.first);
          // Update the accommodation with the primary image
          final index = accommodations.indexWhere((acc) => acc.id == accommodation.id);
          if (index != -1) {
            accommodations[index] = accommodation.copyWith(primaryImageUrl: image.imageUrl);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching accommodation images: $e');
    }
  }
  
  // Fetch a single accommodation by ID
  Future<Accommodation?> getAccommodation(String id) async {
    try {
      final response = await _supabaseClient
          .from('accommodations')
          .select('''
            *,
            areas (
              name
            ),
            accommodation_types (
              name
            )
          ''')
          .eq('id', id)
          .single();
      
      final accommodation = Accommodation.fromJson(response);
      
      // Fetch images for this accommodation
      final imageResponse = await _supabaseClient
          .from('accommodation_images')
          .select()
          .eq('accommodation_id', id)
          .order('is_primary', ascending: false);
      
      if (imageResponse.isNotEmpty) {
        // Get primary image
        final primaryImages = imageResponse.where((img) => img['is_primary'] == true);
        if (primaryImages.isNotEmpty) {
          return accommodation.copyWith(primaryImageUrl: primaryImages.first['image_url']);
        } else {
          // If no primary image, use the first one
          return accommodation.copyWith(primaryImageUrl: imageResponse.first['image_url']);
        }
      }
      
      return accommodation;
    } catch (e) {
      debugPrint('❌ Error fetching accommodation: $e');
      return null;
    }
  }
  
  // Fetch accommodation types
  Future<List<AccommodationType>> getAccommodationTypes() async {
    try {
      final response = await _supabaseClient
          .from('accommodation_types')
          .select()
          .order('name');
      
      final List<AccommodationType> types = response
          .map<AccommodationType>((json) => AccommodationType.fromJson(json))
          .toList();
      
      debugPrint('✅ Fetched ${types.length} accommodation types');
      return types;
    } catch (e) {
      debugPrint('❌ Error fetching accommodation types: $e');
      return [];
    }
  }
  
  // Fetch images for a specific accommodation
  Future<List<AccommodationImage>> getAccommodationImages(String accommodationId) async {
    try {
      final imageResponse = await _supabaseClient
          .from('accommodation_images')
          .select()
          .eq('accommodation_id', accommodationId)
          .order('is_primary', ascending: false);
      
      return imageResponse
          .map<AccommodationImage>((json) => AccommodationImage.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching accommodation images: $e');
      return [];
    }
  }
  
  // Create a new accommodation
  Future<Accommodation?> createAccommodation(Accommodation accommodation) async {
    try {
      final response = await _supabaseClient
          .from('accommodations')
          .insert(accommodation.toJson())
          .select()
          .single();
      
      final createdAccommodation = Accommodation.fromJson(response);
      
      debugPrint('✅ Created accommodation: ${createdAccommodation.id}');
      return createdAccommodation;
    } catch (e) {
      debugPrint('❌ Error creating accommodation: $e');
      return null;
    }
  }
  
  // Update an existing accommodation
  Future<Accommodation?> updateAccommodation(Accommodation accommodation) async {
    if (accommodation.id == null) {
      debugPrint('❌ Cannot update accommodation without an ID');
      return null;
    }
    
    try {
      final response = await _supabaseClient
          .from('accommodations')
          .update(accommodation.toJson())
          .eq('id', accommodation.requireId)
          .select()
          .single();
      
      final updatedAccommodation = Accommodation.fromJson(response);
      
      debugPrint('✅ Updated accommodation: ${updatedAccommodation.id}');
      return updatedAccommodation;
    } catch (e) {
      debugPrint('❌ Error updating accommodation: $e');
      return null;
    }
  }
  
  // Delete an accommodation
  Future<bool> deleteAccommodation(String? id) async {
    if (id == null) {
      debugPrint('❌ Cannot delete accommodation without an ID');
      return false;
    }
    
    try {
      // First delete all images
      await _deleteAccommodationImages(id);
      
      // Then delete the accommodation
      await _supabaseClient
          .from('accommodations')
          .delete()
          .eq('id', id);
      
      debugPrint('✅ Deleted accommodation: $id');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting accommodation: $e');
      return false;
    }
  }
  
  // Helper to delete all images for an accommodation
  Future<void> _deleteAccommodationImages(String accommodationId) async {
    try {
      // Get all images for this accommodation
      final images = await getAccommodationImages(accommodationId);
      
      // Delete each image from storage
      for (final image in images) {
        if (image.imageUrl.isNotEmpty) {
          await _storageService.deleteImage(
            imageUrl: image.imageUrl,
            bucketName: 'accommodation',
          );
        }
      }
      
      // Delete all image records from the database
      await _supabaseClient
          .from('accommodation_images')
          .delete()
          .eq('accommodation_id', accommodationId);
      
    } catch (e) {
      debugPrint('Error deleting accommodation images: $e');
    }
  }
  
  // Upload an image for an accommodation
  Future<AccommodationImage?> uploadAccommodationImage({
    required String accommodationId,
    required XFile imageFile,
    bool isPrimary = false,
    String? caption,
  }) async {
    try {
      // Upload the image to storage
      final imageUrl = await _storageService.uploadImage(
        file: imageFile,
        bucketName: 'accommodation',
        directory: accommodationId,
      );
      
      // If this is a primary image, ensure other images are not primary
      if (isPrimary) {
        await _supabaseClient
            .from('accommodation_images')
            .update({'is_primary': false})
            .eq('accommodation_id', accommodationId);
      }
      
      // Create the image record
      final imageData = {
        'accommodation_id': accommodationId,
        'image_url': imageUrl,
        'is_primary': isPrimary,
        if (caption != null) 'caption': caption,
      };
      
      final response = await _supabaseClient
          .from('accommodation_images')
          .insert(imageData)
          .select()
          .single();
      
      final createdImage = AccommodationImage.fromJson(response);
      
      debugPrint('✅ Uploaded accommodation image: ${createdImage.id}');
      return createdImage;
    } catch (e) {
      debugPrint('❌ Error uploading accommodation image: $e');
      return null;
    }
  }
  
  // Delete an accommodation image
  Future<bool> deleteAccommodationImage(AccommodationImage image) async {
    try {
      // Delete the image from storage
      await _storageService.deleteImage(
        imageUrl: image.imageUrl,
        bucketName: 'accommodation',
      );
      
      // Delete the image record
      await _supabaseClient
          .from('accommodation_images')
          .delete()
          .eq('id', image.requireId);
      
      debugPrint('✅ Deleted accommodation image: ${image.requireId}');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting accommodation image: $e');
      return false;
    }
  }
  
  // Set an image as primary
  Future<bool> setImageAsPrimary(AccommodationImage image) async {
    try {
      // First, reset all images for this accommodation to not primary
      await _supabaseClient
          .from('accommodation_images')
          .update({'is_primary': false})
          .eq('accommodation_id', image.accommodationId);
      
      // Then set the selected image as primary
      final response = await _supabaseClient
          .from('accommodation_images')
          .update({'is_primary': true})
          .eq('id', image.requireId)
          .select();
      
      return response.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error setting image as primary: $e');
      return false;
    }
  }
  
  // Update accommodation image (captions)
  Future<bool> updateAccommodationImage(AccommodationImage image) async {
    try {
      final response = await _supabaseClient
          .from('accommodation_images')
          .update({
            'caption': image.caption,
            'caption_ar': image.captionAr,
            'caption_ku': image.captionKu,
            'caption_bad': image.captionBad,
          })
          .eq('id', image.requireId)
          .select();
      
      return response.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error updating image captions: $e');
      return false;
    }
  }
  
  // Upload an accommodation video
  Future<AccommodationImage?> uploadAccommodationVideo(String accommodationId, File videoFile) async {
    try {
      final supabase = Supabase.instance.client;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExt = path.extension(videoFile.path);
      final videoName = 'accommodation_video_$accommodationId\_$timestamp$fileExt';
      
      // We're not generating thumbnails anymore, just using a placeholder
      final thumbnailUrl = null;
      
      // Upload the video file
      final videoStorageResponse = await supabase.storage
          .from('accommodation') // make sure this bucket exists
          .upload(videoName, videoFile);
          
      debugPrint('🎥 Video storage response: $videoStorageResponse');
      
      if (videoStorageResponse == null) {
        debugPrint('❌ Video upload failed: No storage response');
        return null;
      }
      
      // Get the public URL for video
      final videoUrl = supabase.storage.from('accommodation').getPublicUrl(videoName);
      debugPrint('🔗 Video URL: $videoUrl');
      
      // Insert record in accommodation_images table
      final response = await supabase.from('accommodation_images').insert({
        'accommodation_id': accommodationId,
        'image_url': videoUrl,
        'thumbnail_url': thumbnailUrl,
        'is_primary': false,
        'display_order': 0,
        'media_type': 'video',
        'created_at': DateTime.now().toIso8601String(),
      }).select();
      
      if (response.isEmpty) {
        debugPrint('❌ Failed to insert video record');
        return null;
      }
      
      // Return the newly created video entry
      return AccommodationImage.fromJson(response.first);
    } catch (e) {
      debugPrint('❌ Error in uploadAccommodationVideo: $e');
      return null;
    }
  }
} 