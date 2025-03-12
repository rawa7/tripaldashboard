import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../models/area_video.dart';
import 'package:tripaldashboard/core/models/translation.dart';
import 'package:tripaldashboard/core/providers/supabase_provider.dart';
import 'package:tripaldashboard/core/services/storage_service.dart';

// Provider to fetch videos for a specific area
final areaVideosProvider = FutureProvider.family<List<AreaVideo>, String>((ref, areaId) async {
  try {
    final supabase = ref.read(supabaseProvider);
    final response = await supabase
        .from('area_videos')
        .select()
        .eq('area_id', areaId)
        .order('is_primary', ascending: false)
        .order('created_at', ascending: false);
    
    return response.map<AreaVideo>((json) => AreaVideo.fromJson(json)).toList();
  } catch (e) {
    debugPrint('❌ Error fetching area videos: $e');
    return [];
  }
});

// Provider for area video operations
class AreaVideoNotifier extends StateNotifier<List<AreaVideo>> {
  final String areaId;
  final SupabaseClient _supabase;
  final StorageService _storageService;
  
  AreaVideoNotifier(this.areaId, this._supabase, this._storageService) : super([]) {
    loadVideos();
  }
  
  Future<void> loadVideos() async {
    try {
      final response = await _supabase
          .from('area_images')
          .select()
          .eq('area_id', areaId)
          .eq('media_type', 'video')
          .order('is_primary', ascending: false)
          .order('created_at', ascending: false);
      
      final videos = response.map<AreaVideo>((json) => AreaVideo.fromJson(json)).toList();
      state = videos;
    } catch (e) {
      debugPrint('❌ Error loading area videos: $e');
      // Keep current state on error
    }
  }
  
  Future<AreaVideo?> uploadVideo(
    File videoFile, {
    bool isPrimary = false,
    File? thumbnailFile,
  }) async {
    try {
      // Generate unique filename for the video
      final videoFileName = '${const Uuid().v4()}${p.extension(videoFile.path)}';
      final videoPath = 'areas/$areaId/videos/$videoFileName';
      
      // Upload the video to storage
      final videoUrl = await _storageService.uploadFile(
        bucket: 'area',
        path: videoPath,
        file: videoFile,
        contentType: 'video/${p.extension(videoFile.path).replaceAll('.', '')}',
      );
      
      if (videoUrl == null) {
        throw Exception('Failed to upload video file');
      }
      
      // Upload thumbnail if provided
      String? thumbnailUrl;
      if (thumbnailFile != null) {
        final thumbnailFileName = '${const Uuid().v4()}${p.extension(thumbnailFile.path)}';
        final thumbnailPath = 'areas/$areaId/thumbnails/$thumbnailFileName';
        
        thumbnailUrl = await _storageService.uploadFile(
          bucket: 'area',
          path: thumbnailPath,
          file: thumbnailFile,
          contentType: 'image/${p.extension(thumbnailFile.path).replaceAll('.', '')}',
        );
      }
      
      // Create video database record with only necessary fields
      Map<String, dynamic> videoData = {
        'area_id': areaId,
        'video_url': videoUrl,
        'image_url': videoUrl,
        'media_type': 'video',
        'thumbnail_url': thumbnailUrl,
        'is_primary': isPrimary,
      };
      
      // Insert the record
      final response = await _supabase
          .from('area_images')
          .insert(videoData)
          .select()
          .single();
      
      // Create and add the new video to state
      final newVideo = AreaVideo.fromJson(response);
      state = [newVideo, ...state];
      
      return newVideo;
    } catch (e) {
      debugPrint('❌ Error uploading area video: $e');
      return null;
    }
  }
  
  Future<bool> deleteVideo(String videoId) async {
    try {
      // Find the video in state
      final videoToDelete = state.firstWhere((v) => v.id == videoId);
      
      // Delete the video file from storage if we have a URL
      if (videoToDelete.videoUrl.isNotEmpty) {
        final videoPath = _storageService.getPathFromUrl(videoToDelete.videoUrl);
        if (videoPath != null) {
          await _storageService.deleteFile(
            bucket: 'area',
            path: videoPath,
          );
        }
      }
      
      // Delete the thumbnail if it exists
      if (videoToDelete.thumbnailUrl != null && videoToDelete.thumbnailUrl!.isNotEmpty) {
        final thumbnailPath = _storageService.getPathFromUrl(videoToDelete.thumbnailUrl!);
        if (thumbnailPath != null) {
          await _storageService.deleteFile(
            bucket: 'area',
            path: thumbnailPath,
          );
        }
      }
      
      // Delete from database
      await _supabase
          .from('area_images')
          .delete()
          .eq('id', videoId);
      
      // Update state
      state = state.where((v) => v.id != videoId).toList();
      
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting area video: $e');
      return false;
    }
  }
  
  Future<bool> setVideoAsPrimary(String videoId) async {
    try {
      // Update the video in the database
      await _supabase
          .from('area_images')
          .update({'is_primary': true})
          .eq('id', videoId)
          .eq('media_type', 'video');
      
      // Reload the videos to get the updated state
      await loadVideos();
      
      return true;
    } catch (e) {
      debugPrint('❌ Error setting primary area video: $e');
      return false;
    }
  }
}

// Provider for the area video notifier
final areaVideoNotifierProvider = StateNotifierProvider.family<AreaVideoNotifier, List<AreaVideo>, String>(
  (ref, areaId) {
    final supabase = ref.read(supabaseProvider);
    final storageService = ref.read(storageServiceProvider);
    return AreaVideoNotifier(areaId, supabase, storageService);
  },
); 