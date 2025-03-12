import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../models/accommodation.dart';
import '../models/accommodation_image.dart';
import '../models/accommodation_type.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/storage_service.dart';

// Provider for the simplified service
final accommodationsSimpleServiceProvider = Provider<AccommodationsSimpleService>((ref) {
  return AccommodationsSimpleService();
});

// Provider for accommodations by area
final accommodationsByAreaSimpleProvider = FutureProvider.family<List<Accommodation>, String>((ref, areaId) async {
  final service = ref.watch(accommodationsSimpleServiceProvider);
  return service.getAccommodationsByArea(areaId);
});

// Provider for a single accommodation
final accommodationSimpleProvider = FutureProvider.family<Accommodation?, String>((ref, id) async {
  final service = ref.watch(accommodationsSimpleServiceProvider);
  return service.getAccommodation(id);
});

// Provider for accommodation types
final accommodationTypesSimpleProvider = FutureProvider<List<AccommodationType>>((ref) async {
  final service = ref.watch(accommodationsSimpleServiceProvider);
  return service.getAccommodationTypes();
});

// Provider for accommodation images
final accommodationImagesSimpleProvider = FutureProvider.family<List<AccommodationImage>, String>((ref, accommodationId) async {
  final service = ref.watch(accommodationsSimpleServiceProvider);
  return service.getAccommodationImages(accommodationId);
});

// Simplified service class for accommodations
class AccommodationsSimpleService {
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
      return [];
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
      final imageResponse = await _supabaseClient
          .from('accommodation_images')
          .select()
          .eq('accommodation_id', accommodationId);
      
      final images = imageResponse
          .map<AccommodationImage>((json) => AccommodationImage.fromJson(json))
          .toList();
      
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
  Future<AccommodationImage?> uploadAccommodationImage(String accommodationId, File file) async {
    try {
      // Upload the image to storage
      final imageUrl = await _storageService.uploadImage(
        file: XFile(file.path),
        bucketName: 'accommodation',
        directory: accommodationId,
      );
      
      // Create the image record
      final imageData = {
        'accommodation_id': accommodationId,
        'image_url': imageUrl,
        'is_primary': false,
        'media_type': 'image',
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

  // Upload a video for an accommodation
  Future<AccommodationImage?> uploadAccommodationVideo(String accommodationId, File file) async {
    try {
      // Generate a unique name for the video
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final videoName = '$accommodationId/$timestamp.mp4';
      
      // Upload the video to storage
      final videoUrl = await _storageService.uploadFile(
        bucket: 'accommodation',
        path: videoName,
        file: file,
      );
      
      if (videoUrl == null) {
        throw Exception('Failed to upload video');
      }

      // Generate a default thumbnail URL (optional)
      // Note: In a real implementation, you would generate an actual thumbnail
      // from the video file, but this requires additional packages
      final thumbnailName = '$accommodationId/${timestamp}_thumbnail.jpg';
      String? thumbnailUrl;

      // Create a default thumbnail (a 1x1 transparent pixel) 
      // This is just a placeholder - in production you'd extract a real thumbnail
      try {
        // This is a minimal 1x1 transparent JPG (base64 encoded)
        final defaultThumbnailBytes = base64Decode(
          '/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/2wBDAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH/wAARCAABAAEDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD+/iiiigD/2Q=='
        );
        
        // Upload the default thumbnail to Supabase
        thumbnailUrl = await _storageService.uploadData(
          bucket: 'accommodation',
          path: thumbnailName,
          data: defaultThumbnailBytes,
          contentType: 'image/jpeg',
        );
        
        debugPrint('✅ Uploaded default video thumbnail: $thumbnailUrl');
      } catch (e) {
        // If thumbnail upload fails, just log it but continue
        debugPrint('❌ Error uploading thumbnail: $e');
      }
      
      // Create the video record
      final videoData = {
        'accommodation_id': accommodationId,
        'image_url': videoUrl,
        'is_primary': false,
        'media_type': 'video',
        'display_order': timestamp % 2147483647,
        'thumbnail_url': thumbnailUrl, // Add thumbnail URL to database
      };
      
      final response = await _supabaseClient
          .from('accommodation_images')
          .insert(videoData)
          .select()
          .single();
      
      final createdVideo = AccommodationImage.fromJson(response);
      
      debugPrint('✅ Uploaded accommodation video: ${createdVideo.id}');
      return createdVideo;
    } catch (e) {
      debugPrint('❌ Error uploading accommodation video: $e');
      return null;
    }
  }

  // Fetch accommodation images
  Future<List<AccommodationImage>> getAccommodationImages(String accommodationId) async {
    try {
      final response = await _supabaseClient
          .from('accommodation_images')
          .select()
          .eq('accommodation_id', accommodationId)
          .order('is_primary', ascending: false);
      
      final List<AccommodationImage> images = response
          .map<AccommodationImage>((json) => AccommodationImage.fromJson(json))
          .toList();
      
      debugPrint('✅ Fetched ${images.length} images for accommodation $accommodationId');
      return images;
    } catch (e) {
      debugPrint('❌ Error fetching accommodation images: $e');
      return [];
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

  // Upload a thumbnail for a video
  Future<bool> uploadVideoThumbnail(String accommodationId, String videoId, File thumbnailFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final thumbnailName = '$accommodationId/${timestamp}_custom_thumbnail.jpg';
      
      // Upload the thumbnail image to storage
      final thumbnailUrl = await _storageService.uploadImage(
        file: XFile(thumbnailFile.path),
        bucketName: 'accommodation',
        directory: accommodationId,
      );
      
      // Update the video record with the new thumbnail URL
      final response = await _supabaseClient
          .from('accommodation_images')
          .update({'thumbnail_url': thumbnailUrl})
          .eq('id', videoId)
          .select();
      
      debugPrint('✅ Updated video thumbnail: $thumbnailUrl for video $videoId');
      return response.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error uploading video thumbnail: $e');
      return false;
    }
  }

  // Upload a video with a custom thumbnail
  Future<AccommodationImage?> uploadAccommodationVideoWithThumbnail(
    String accommodationId, 
    File videoFile, 
    File thumbnailFile
  ) async {
    try {
      // Generate a unique name for the video
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final videoName = '$accommodationId/$timestamp.mp4';
      
      // Upload the video to storage
      final videoUrl = await _storageService.uploadFile(
        bucket: 'accommodation',
        path: videoName,
        file: videoFile,
      );
      
      if (videoUrl == null) {
        throw Exception('Failed to upload video');
      }

      // Upload the thumbnail image
      String? thumbnailUrl;
      try {
        thumbnailUrl = await _storageService.uploadImage(
          file: XFile(thumbnailFile.path),
          bucketName: 'accommodation',
          directory: accommodationId,
        );
        
        debugPrint('✅ Uploaded custom video thumbnail: $thumbnailUrl');
      } catch (e) {
        debugPrint('❌ Error uploading thumbnail image: $e');
        // If thumbnail upload fails, continue without a thumbnail
      }
      
      // Create the video record
      final videoData = {
        'accommodation_id': accommodationId,
        'image_url': videoUrl,
        'is_primary': false,
        'media_type': 'video',
        'display_order': timestamp % 2147483647,
        'thumbnail_url': thumbnailUrl,
      };
      
      final response = await _supabaseClient
          .from('accommodation_images')
          .insert(videoData)
          .select()
          .single();
      
      final createdVideo = AccommodationImage.fromJson(response);
      
      debugPrint('✅ Uploaded accommodation video with custom thumbnail: ${createdVideo.id}');
      return createdVideo;
    } catch (e) {
      debugPrint('❌ Error uploading accommodation video with thumbnail: $e');
      return null;
    }
  }
} 