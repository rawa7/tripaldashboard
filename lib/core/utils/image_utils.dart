import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripaldashboard/core/services/storage_service.dart';

class ImageUtils {
  /// Pick an image from the gallery or camera
  static Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      
      return image;
    } catch (e) {
      if (kDebugMode) {
        print('Error picking image: $e');
      }
      return null;
    }
  }
  
  /// Show an image picker dialog to choose between camera and gallery
  static Future<XFile?> showImagePickerDialog(BuildContext context) async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    
    if (source == null) return null;
    
    return await pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
  }
  
  /// Upload an image to Supabase storage
  static Future<String?> uploadImageToSupabase({
    required XFile image,
    required StorageService storageService,
    required String bucketName,
    String? directory,
  }) async {
    try {
      final imageUrl = await storageService.uploadImage(
        file: image,
        bucketName: bucketName,
        directory: directory,
      );
      
      return imageUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading image to Supabase: $e');
      }
      return null;
    }
  }
} 