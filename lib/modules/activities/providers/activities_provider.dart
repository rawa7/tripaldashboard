import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/activity.dart';
import '../models/activity_image.dart';
import '../models/activity_type.dart';
import '../models/activity_time_slot.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/storage_service.dart';

// Provider for the Activities Service
final activitiesServiceProvider = Provider<ActivitiesService>((ref) {
  return ActivitiesService();
});

// Provider for activities by area
final activitiesByAreaProvider = FutureProvider.family<List<Activity>, String>((ref, areaId) async {
  final service = ref.watch(activitiesServiceProvider);
  return service.getActivitiesByArea(areaId);
});

// Provider for getting a single activity
final activityProvider = FutureProvider.family<Activity?, String>((ref, id) async {
  final service = ref.watch(activitiesServiceProvider);
  return service.getActivity(id);
});

// Provider for all activity types
final activityTypesProvider = FutureProvider<List<ActivityType>>((ref) async {
  final service = ref.watch(activitiesServiceProvider);
  return service.getActivityTypes();
});

// Provider for activity images
final activityImagesProvider = FutureProvider.family<List<ActivityImage>, String>((ref, activityId) async {
  final service = ref.watch(activitiesServiceProvider);
  return service.getActivityImages(activityId);
});

// Provider for activity time slots
final activityTimeSlotsProvider = FutureProvider.family<List<ActivityTimeSlot>, String>((ref, activityId) async {
  final service = ref.watch(activitiesServiceProvider);
  return service.getActivityTimeSlots(activityId);
});

// Service class for activities
class ActivitiesService {
  final SupabaseClient _supabaseClient = SupabaseService.staticClient;
  final StorageService _storageService = StorageService(SupabaseService.staticClient);
  
  // Fetch activities for an area
  Future<List<Activity>> getActivitiesByArea(String areaId) async {
    try {
      final response = await _supabaseClient
          .from('activities')
          .select('''
            *,
            areas (
              name
            ),
            activity_types (
              name
            )
          ''')
          .eq('area_id', areaId)
          .order('name');
      
      final List<Activity> activities = response
          .map<Activity>((json) => Activity.fromJson(json))
          .toList();
      
      debugPrint('✅ Fetched ${activities.length} activities for area $areaId');
      return activities;
    } catch (e) {
      debugPrint('❌ Error fetching activities: $e');
      return [];
    }
  }
  
  // Fetch a single activity by ID
  Future<Activity?> getActivity(String id) async {
    try {
      final response = await _supabaseClient
          .from('activities')
          .select('''
            *,
            areas (
              name
            ),
            activity_types (
              name
            )
          ''')
          .eq('id', id)
          .single();
      
      final activity = Activity.fromJson(response);
      
      debugPrint('✅ Fetched activity: ${activity.id}');
      return activity;
    } catch (e) {
      debugPrint('❌ Error fetching activity: $e');
      return null;
    }
  }
  
  // Create a new activity
  Future<Activity?> createActivity(Activity activity) async {
    try {
      final response = await _supabaseClient
          .from('activities')
          .insert(activity.toJson())
          .select()
          .single();
      
      final createdActivity = Activity.fromJson(response);
      
      debugPrint('✅ Created activity: ${createdActivity.id}');
      return createdActivity;
    } catch (e) {
      debugPrint('❌ Error creating activity: $e');
      return null;
    }
  }
  
  // Update an existing activity
  Future<Activity?> updateActivity(Activity activity) async {
    if (activity.id == null) {
      debugPrint('❌ Cannot update activity without an ID');
      return null;
    }
    
    try {
      final response = await _supabaseClient
          .from('activities')
          .update(activity.toJson())
          .eq('id', activity.requireId)
          .select()
          .single();
      
      final updatedActivity = Activity.fromJson(response);
      
      debugPrint('✅ Updated activity: ${updatedActivity.id}');
      return updatedActivity;
    } catch (e) {
      debugPrint('❌ Error updating activity: $e');
      return null;
    }
  }
  
  // Delete an activity
  Future<bool> deleteActivity(String? id) async {
    if (id == null) {
      debugPrint('❌ Cannot delete activity without an ID');
      return false;
    }
    
    try {
      // First, delete all related entities
      await _deleteActivityTimeSlots(id);
      await _deleteActivityImages(id);
      
      // Then delete the activity
      await _supabaseClient
          .from('activities')
          .delete()
          .eq('id', id);
      
      debugPrint('✅ Deleted activity: $id');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting activity: $e');
      return false;
    }
  }
  
  // Fetch activity types
  Future<List<ActivityType>> getActivityTypes() async {
    try {
      final response = await _supabaseClient
          .from('activity_types')
          .select()
          .order('name');
      
      final List<ActivityType> types = response
          .map<ActivityType>((json) => ActivityType.fromJson(json))
          .toList();
      
      debugPrint('✅ Fetched ${types.length} activity types');
      return types;
    } catch (e) {
      debugPrint('❌ Error fetching activity types: $e');
      return [];
    }
  }
  
  // Fetch activity images
  Future<List<ActivityImage>> getActivityImages(String activityId) async {
    try {
      final response = await _supabaseClient
          .from('activity_images')
          .select()
          .eq('activity_id', activityId)
          .order('is_primary', ascending: false);
      
      final List<ActivityImage> images = response
          .map<ActivityImage>((json) => ActivityImage.fromJson(json))
          .toList();
      
      debugPrint('✅ Fetched ${images.length} images for activity $activityId');
      return images;
    } catch (e) {
      debugPrint('❌ Error fetching activity images: $e');
      return [];
    }
  }
  
  // Fetch activity time slots
  Future<List<ActivityTimeSlot>> getActivityTimeSlots(String activityId) async {
    try {
      final response = await _supabaseClient
          .from('activity_time_slots')
          .select()
          .eq('activity_id', activityId)
          .order('day_of_week')
          .order('start_time');
      
      final List<ActivityTimeSlot> timeSlots = response
          .map<ActivityTimeSlot>((json) => ActivityTimeSlot.fromJson(json))
          .toList();
      
      debugPrint('✅ Fetched ${timeSlots.length} time slots for activity $activityId');
      return timeSlots;
    } catch (e) {
      debugPrint('❌ Error fetching activity time slots: $e');
      return [];
    }
  }
  
  // Upload an activity image
  Future<ActivityImage?> uploadActivityImage(String activityId, File imageFile) async {
    try {
      final supabase = Supabase.instance.client;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imageName = 'activity_$activityId\_$timestamp.jpg';
      
      // Upload to Supabase Storage - updated path format
      final storageResponse = await supabase.storage
          .from('activity') // make sure this bucket exists
          .upload(imageName, imageFile);
          
      debugPrint('📸 Storage response: $storageResponse');
      
      if (storageResponse == null) {
        debugPrint('❌ Image upload failed: No storage response');
        return null;
      }
      
      // Get the public URL
      final imageUrl = supabase.storage.from('activity').getPublicUrl(imageName);
      debugPrint('🔗 Image URL: $imageUrl');
      
      // Insert record in activity_images table
      final response = await supabase.from('activity_images').insert({
        'activity_id': activityId,
        'image_url': imageUrl,
        'is_primary': false,
        'display_order': 0,
        'media_type': 'image',
        'created_at': DateTime.now().toIso8601String(),
      }).select();
      
      if (response.isEmpty) {
        debugPrint('❌ Failed to insert image record');
        return null;
      }
      
      // Return the newly created image
      return ActivityImage.fromJson(response.first);
    } catch (e) {
      debugPrint('❌ Error in uploadActivityImage: $e');
      return null;
    }
  }
  
  // Upload an activity video
  Future<ActivityImage?> uploadActivityVideo(String activityId, File videoFile) async {
    try {
      final supabase = Supabase.instance.client;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExt = path.extension(videoFile.path);
      final videoName = 'activity_video_$activityId\_$timestamp$fileExt';
      
      // No longer generating thumbnail
      // Setting a default/placeholder thumbnail or null
      final thumbnailUrl = null; // We're no longer generating thumbnails
      
      // Upload the video file
      final videoStorageResponse = await supabase.storage
          .from('activity')
          .upload(videoName, videoFile);
          
      debugPrint('🎥 Video storage response: $videoStorageResponse');
      
      if (videoStorageResponse == null) {
        debugPrint('❌ Video upload failed: No storage response');
        return null;
      }
      
      // Get the public URL for video
      final videoUrl = supabase.storage.from('activity').getPublicUrl(videoName);
      debugPrint('🔗 Video URL: $videoUrl');
      
      // Insert record in activity_images table
      final response = await supabase.from('activity_images').insert({
        'activity_id': activityId,
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
      return ActivityImage.fromJson(response.first);
    } catch (e) {
      debugPrint('❌ Error in uploadActivityVideo: $e');
      return null;
    }
  }
  
  // Upload a thumbnail for an activity video
  Future<bool> uploadVideoThumbnail(String activityId, String videoId, File thumbnailFile) async {
    try {
      final supabase = Supabase.instance.client;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final thumbnailName = 'activity_thumbnail_${activityId}_${timestamp}.jpg';
      
      // Upload the thumbnail image
      final storageResponse = await supabase.storage
          .from('activity')
          .upload(thumbnailName, thumbnailFile);
          
      debugPrint('🖼️ Thumbnail storage response: $storageResponse');
      
      if (storageResponse == null) {
        debugPrint('❌ Thumbnail upload failed: No storage response');
        return false;
      }
      
      // Get the public URL for thumbnail
      final thumbnailUrl = supabase.storage.from('activity').getPublicUrl(thumbnailName);
      debugPrint('🔗 Thumbnail URL: $thumbnailUrl');
      
      // Update the video record with the thumbnail URL
      final response = await supabase
          .from('activity_images')
          .update({'thumbnail_url': thumbnailUrl})
          .eq('id', videoId)
          .select();
      
      if (response.isEmpty) {
        debugPrint('❌ Failed to update video record with thumbnail');
        return false;
      }
      
      debugPrint('✅ Updated video $videoId with thumbnail: $thumbnailUrl');
      return true;
    } catch (e) {
      debugPrint('❌ Error in uploadVideoThumbnail: $e');
      return false;
    }
  }
  
  // Upload a video with a custom thumbnail simultaneously
  Future<ActivityImage?> uploadActivityVideoWithThumbnail(
    String activityId, 
    File videoFile, 
    File thumbnailFile
  ) async {
    try {
      final supabase = Supabase.instance.client;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Upload the video
      final fileExt = path.extension(videoFile.path);
      final videoName = 'activity_video_${activityId}_${timestamp}$fileExt';
      
      final videoStorageResponse = await supabase.storage
          .from('activity')
          .upload(videoName, videoFile);
          
      if (videoStorageResponse == null) {
        debugPrint('❌ Video upload failed: No storage response');
        return null;
      }
      
      final videoUrl = supabase.storage.from('activity').getPublicUrl(videoName);
      
      // Upload the thumbnail
      final thumbnailName = 'activity_thumbnail_${activityId}_${timestamp}.jpg';
      
      final thumbnailStorageResponse = await supabase.storage
          .from('activity')
          .upload(thumbnailName, thumbnailFile);
          
      if (thumbnailStorageResponse == null) {
        debugPrint('⚠️ Thumbnail upload failed, but video uploaded successfully');
        // Continue without thumbnail
      }
      
      // Get thumbnail URL if upload succeeded
      String? thumbnailUrl;
      if (thumbnailStorageResponse != null) {
        thumbnailUrl = supabase.storage.from('activity').getPublicUrl(thumbnailName);
        debugPrint('🔗 Thumbnail URL: $thumbnailUrl');
      }
      
      // Insert record in activity_images table
      final response = await supabase.from('activity_images').insert({
        'activity_id': activityId,
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
      
      debugPrint('✅ Uploaded activity video with custom thumbnail');
      return ActivityImage.fromJson(response.first);
    } catch (e) {
      debugPrint('❌ Error in uploadActivityVideoWithThumbnail: $e');
      return null;
    }
  }
  
  // Set an image as primary
  Future<bool> setImageAsPrimary(ActivityImage image) async {
    if (image.isPrimary) {
      debugPrint('⚠️ Image is already primary');
      return true;
    }
    
    try {
      // Set all other images to not primary
      await _supabaseClient
          .from('activity_images')
          .update({'is_primary': false})
          .eq('activity_id', image.activityId);
      
      // Set this image as primary
      await _supabaseClient
          .from('activity_images')
          .update({'is_primary': true})
          .eq('id', image.requireId);
      
      // Update the activity's thumbnail_url
      await _supabaseClient
          .from('activities')
          .update({'thumbnail_url': image.imageUrl})
          .eq('id', image.activityId);
      
      debugPrint('✅ Set image as primary: ${image.requireId}');
      return true;
    } catch (e) {
      debugPrint('❌ Error setting image as primary: $e');
      return false;
    }
  }
  
  // Delete an activity image
  Future<bool> deleteActivityImage(ActivityImage image) async {
    try {
      // Delete the image from storage
      await _storageService.deleteImage(
        imageUrl: image.imageUrl,
        bucketName: 'activity',
      );
      
      // Delete the image record
      await _supabaseClient
          .from('activity_images')
          .delete()
          .eq('id', image.requireId);
      
      // If this was a primary image, check if there are other images to make primary
      if (image.isPrimary) {
        final remainingImages = await getActivityImages(image.activityId);
        if (remainingImages.isNotEmpty) {
          // Make the first remaining image primary
          await setImageAsPrimary(remainingImages.first);
        } else {
          // Clear the thumbnail_url on the activity
          await _supabaseClient
              .from('activities')
              .update({'thumbnail_url': null})
              .eq('id', image.activityId);
        }
      }
      
      debugPrint('✅ Deleted activity image: ${image.requireId}');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting activity image: $e');
      return false;
    }
  }
  
  // Helper to delete all images for an activity
  Future<void> _deleteActivityImages(String activityId) async {
    try {
      // Get all images for this activity
      final images = await getActivityImages(activityId);
      
      // Delete each image from storage
      for (final image in images) {
        if (image.imageUrl.isNotEmpty) {
          await _storageService.deleteImage(
            imageUrl: image.imageUrl,
            bucketName: 'activity',
          );
        }
      }
      
      // Delete all image records from the database
      await _supabaseClient
          .from('activity_images')
          .delete()
          .eq('activity_id', activityId);
      
    } catch (e) {
      debugPrint('Error deleting activity images: $e');
    }
  }
  
  // Create a time slot for an activity
  Future<ActivityTimeSlot?> createTimeSlot(ActivityTimeSlot timeSlot) async {
    try {
      final response = await _supabaseClient
          .from('activity_time_slots')
          .insert(timeSlot.toJson())
          .select()
          .single();
      
      final createdTimeSlot = ActivityTimeSlot.fromJson(response);
      
      debugPrint('✅ Created time slot: ${createdTimeSlot.id}');
      return createdTimeSlot;
    } catch (e) {
      debugPrint('❌ Error creating time slot: $e');
      return null;
    }
  }
  
  // Update a time slot
  Future<ActivityTimeSlot?> updateTimeSlot(ActivityTimeSlot timeSlot) async {
    if (timeSlot.id == null) {
      debugPrint('❌ Cannot update time slot without an ID');
      return null;
    }
    
    try {
      final response = await _supabaseClient
          .from('activity_time_slots')
          .update(timeSlot.toJson())
          .eq('id', timeSlot.requireId)
          .select()
          .single();
      
      final updatedTimeSlot = ActivityTimeSlot.fromJson(response);
      
      debugPrint('✅ Updated time slot: ${updatedTimeSlot.id}');
      return updatedTimeSlot;
    } catch (e) {
      debugPrint('❌ Error updating time slot: $e');
      return null;
    }
  }
  
  // Delete a time slot
  Future<bool> deleteTimeSlot(String id) async {
    try {
      await _supabaseClient
          .from('activity_time_slots')
          .delete()
          .eq('id', id);
      
      debugPrint('✅ Deleted time slot: $id');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting time slot: $e');
      return false;
    }
  }
  
  // Helper to delete all time slots for an activity
  Future<void> _deleteActivityTimeSlots(String activityId) async {
    try {
      await _supabaseClient
          .from('activity_time_slots')
          .delete()
          .eq('activity_id', activityId);
      
      debugPrint('✅ Deleted all time slots for activity: $activityId');
    } catch (e) {
      debugPrint('❌ Error deleting time slots: $e');
    }
  }
} 