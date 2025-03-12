import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripaldashboard/core/providers/supabase_provider.dart';

class StorageService {
  final SupabaseClient _supabase;

  StorageService(this._supabase);

  /// Upload a file to Supabase storage and return the public URL
  Future<String?> uploadFile({
    required String bucket,
    required String path,
    required File file,
    String? contentType,
  }) async {
    try {
      // Upload the file
      await _supabase.storage.from(bucket).upload(
        path,
        file,
        fileOptions: FileOptions(
          contentType: contentType,
          upsert: true,
        ),
      );

      // Get the public URL
      final url = _supabase.storage.from(bucket).getPublicUrl(path);
      return url;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  /// Upload a data buffer to Supabase storage and return the public URL
  Future<String?> uploadData({
    required String bucket,
    required String path,
    required Uint8List data,
    String? contentType,
  }) async {
    try {
      // Upload the data
      await _supabase.storage.from(bucket).uploadBinary(
        path,
        data,
        fileOptions: FileOptions(
          contentType: contentType,
          upsert: true,
        ),
      );

      // Get the public URL
      final url = _supabase.storage.from(bucket).getPublicUrl(path);
      return url;
    } catch (e) {
      debugPrint('Error uploading data: $e');
      return null;
    }
  }

  /// Delete a file from Supabase storage
  Future<bool> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _supabase.storage.from(bucket).remove([path]);
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  /// Extract the path from a Supabase storage URL
  String? getPathFromUrl(String url) {
    try {
      // This is a simplistic approach, you might need to adjust based on your URL format
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      
      // Skip 'storage/v1/object/public/' or similar prefixes
      if (segments.length > 4) {
        // The bucket name is typically the 4th segment
        final bucketIndex = segments.indexOf('public') + 1;
        if (bucketIndex > 0 && bucketIndex < segments.length) {
          // Join all segments after the bucket name
          return segments.sublist(bucketIndex + 1).join('/');
        }
      }
      return null;
    } catch (e) {
      print('Error parsing URL: $e');
      return null;
    }
  }
  
  /// Uploads an image file to Supabase storage and returns the public URL
  /// [file] - The XFile object from image_picker
  /// [bucketName] - The name of the storage bucket (will be created if it doesn't exist)
  /// [directory] - Optional subdirectory within the bucket
  Future<String> uploadImage({
    required XFile file,
    required String bucketName,
    String? directory,
  }) async {
    try {
      // Read file as bytes
      final bytes = await file.readAsBytes();
      
      // Create a unique file name using UUID and original extension
      final fileExt = path.extension(file.path);
      final fileName = '${const Uuid().v4()}$fileExt';
      
      // Create the full file path including optional directory
      final filePath = directory != null 
          ? '$directory/$fileName' 
          : fileName;
      
      // Define file options - make it publicly accessible
      final fileOptions = FileOptions(
        contentType: 'image/${fileExt.replaceFirst('.', '')}',
        upsert: true,
      );
      
      // Upload the file
      await _supabase
          .storage
          .from(bucketName)
          .uploadBinary(filePath, bytes, fileOptions: fileOptions);
      
      // Get the public URL
      final imageUrl = _supabase
          .storage
          .from(bucketName)
          .getPublicUrl(filePath);
      
      return imageUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image: $e');
      }
      rethrow;
    }
  }

  /// Deletes an image from Supabase storage
  /// [imageUrl] - The full URL of the image to delete
  /// [bucketName] - The name of the storage bucket
  Future<void> deleteImage({
    required String imageUrl,
    required String bucketName,
  }) async {
    try {
      // Extract the file path from the URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      // The file path is typically after "object/public/bucketName/"
      final filePath = pathSegments.skipWhile((s) => s != bucketName).skip(1).join('/');
      
      // Delete the file
      await _supabase.storage.from(bucketName).remove([filePath]);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting image: $e');
      }
      rethrow;
    }
  }
}

// Provider for the storage service
final storageServiceProvider = Provider<StorageService>((ref) {
  final supabase = ref.read(supabaseProvider);
  return StorageService(supabase);
}); 