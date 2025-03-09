import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final SupabaseClient _supabaseClient;

  StorageService(this._supabaseClient);

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
      await _supabaseClient
          .storage
          .from(bucketName)
          .uploadBinary(filePath, bytes, fileOptions: fileOptions);
      
      // Get the public URL
      final imageUrl = _supabaseClient
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
      await _supabaseClient.storage.from(bucketName).remove([filePath]);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting image: $e');
      }
      rethrow;
    }
  }
} 