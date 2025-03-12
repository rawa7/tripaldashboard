import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tripaldashboard/core/services/supabase_service.dart';
import 'package:tripaldashboard/modules/areas/models/area.dart';
import 'package:tripaldashboard/modules/areas/models/area_image.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class AreaService {
  final _supabase = SupabaseService.staticClient;
  final _uuid = Uuid();
  
  // Helper to join areas and sub_cities tables
  List<Area> _processAreaResults(List<dynamic> data) {
    return data.map((item) {
      return Area.fromJson({
        ...item,
        'sub_cities': item['sub_cities'],
      });
    }).toList();
  }
  
  // Get all areas with optional pagination and filtering
  Future<List<Area>> getAreas({
    int? page,
    int? limit,
    String? subCityId,
    String? searchQuery,
  }) async {
    try {
      debugPrint('🔍 getAreas called with: page=$page, limit=$limit, subCityId=$subCityId, searchQuery=$searchQuery');
      
      final query = _supabase
          .from('areas')
          .select('*, sub_cities(name)');
      
      // Apply filters if provided
      var filteredQuery = query;
      
      if (subCityId != null) {
        filteredQuery = filteredQuery.filter('sub_city_id', 'eq', subCityId);
      }
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        filteredQuery = filteredQuery.filter('name', 'ilike', '%$searchQuery%');
      }
      
      // Apply ordering
      var orderedQuery = filteredQuery.order('name', ascending: true);
      
      // Apply pagination if provided
      if (page != null && limit != null) {
        final int offset = (page - 1) * limit;
        orderedQuery = orderedQuery.range(offset, offset + limit - 1);
      }
      
      debugPrint('🔍 Executing Supabase query for areas...');
      final data = await orderedQuery;
      debugPrint('🔍 Areas data received: ${data.length} items');
      
      final areas = _processAreaResults(data);
      debugPrint('🔍 Processed areas: ${areas.length} items');
      return areas;
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching areas: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      return [];
    }
  }
  
  // Get the total count of areas with applied filters
  Future<int> getAreasCount({String? subCityId, String? searchQuery}) async {
    try {
      final query = _supabase.from('areas').select('*');
      
      var filteredQuery = query;
      
      if (subCityId != null) {
        filteredQuery = filteredQuery.filter('sub_city_id', 'eq', subCityId);
      }
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        filteredQuery = filteredQuery.filter('name', 'ilike', '%$searchQuery%');
      }
      
      final result = await filteredQuery.count(CountOption.exact);
      return result.count ?? 0;
    } catch (e) {
      debugPrint('Error counting areas: $e');
      return 0;
    }
  }
  
  // Get a single area by ID
  Future<Area?> getAreaById(String id) async {
    try {
      final data = await _supabase
          .from('areas')
          .select('*, sub_cities(name)')
          .filter('id', 'eq', id)
          .single();
      
      return Area.fromJson({
        ...data,
        'sub_cities': data['sub_cities'],
      });
    } catch (e) {
      debugPrint('Error fetching area by ID: $e');
      return null;
    }
  }
  
  // Create a new area
  Future<Area?> createArea(Area area) async {
    try {
      debugPrint('🔍 createArea called with: ${area.toJson()}');
      
      // Log all fields to check for missing required data
      debugPrint('🔍 Validating area data:');
      debugPrint('  - name: ${area.name}');
      debugPrint('  - description: ${area.description}');
      debugPrint('  - subCityId: ${area.subCityId}');
      
      // Ensure required fields are present
      if (area.name.isEmpty) {
        throw Exception('Area name cannot be empty');
      }
      
      if (area.description.isEmpty) {
        throw Exception('Area description cannot be empty');
      }
      
      if (area.subCityId == null) {
        throw Exception('Sub-city ID cannot be null');
      }
      
      // Verify the sub-city exists
      try {
        final subCityCheck = await _supabase
            .from('sub_cities')
            .select('id')
            .eq('id', area.subCityId!)  // Use non-null assertion since we checked above
            .single();
        debugPrint('🔍 Sub-city check result: $subCityCheck');
      } catch (e) {
        debugPrint('❌ Warning: Sub-city may not exist: $e');
        // Continue anyway as it might just be a data inconsistency
      }
      
      // Create the insert data map
      final insertData = area.toJson();
      debugPrint('🔍 Inserting area with data: $insertData');
      
      // Perform the insert
      final data = await _supabase
          .from('areas')
          .insert(insertData)
          .select('*, sub_cities(name)')
          .single();
      
      debugPrint('🔍 Area created successfully: $data');
      
      return Area.fromJson({
        ...data,
        'sub_cities': data['sub_cities'],
      });
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating area: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      throw Exception('Failed to create area: $e');
    }
  }
  
  // Update an existing area
  Future<Area?> updateArea(Area area) async {
    try {
      // Make sure the id is not null before using it
      if (area.id == null) {
        throw Exception('Cannot update area with null id');
      }
      
      final data = await _supabase
          .from('areas')
          .update(area.toJson())
          .eq('id', area.id!)  // Use non-null assertion since we checked above
          .select('*, sub_cities(name)')
          .single();
      
      return Area.fromJson({
        ...data,
        'sub_cities': data['sub_cities'],
      });
    } catch (e) {
      debugPrint('Error updating area: $e');
      return null;
    }
  }
  
  // Delete an area
  Future<bool> deleteArea(String id) async {
    try {
      // First delete all associated images
      await _deleteAllAreaImages(id);
      
      // Then delete the area
      await _supabase
          .from('areas')
          .delete()
          .eq('id', id);
      return true;
    } catch (e) {
      debugPrint('Error deleting area: $e');
      return false;
    }
  }
  
  // Get all images for an area
  Future<List<AreaImage>> getAreaImages(String areaId) async {
    try {
      final data = await _supabase
          .from('area_images')
          .select()
          .eq('area_id', areaId)
          .order('is_primary', ascending: false);
      
      return data.map((item) => AreaImage.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error fetching area images: $e');
      return [];
    }
  }
  
  // Upload an image for an area
  Future<AreaImage?> uploadAreaImage(String areaId, File imageFile, {bool isPrimary = false}) async {
    try {
      // Generate a unique filename
      final fileExt = path.extension(imageFile.path);
      final fileName = '${_uuid.v4()}$fileExt';
      final filePath = 'gallery/$fileName';
      
      // Upload to Supabase Storage
      await _supabase.storage.from('area').upload(filePath, imageFile);
      
      // Get the public URL
      final imageUrl = _supabase.storage.from('area').getPublicUrl(filePath);
      
      // Create a thumbnail
      final thumbnailPath = 'thumbnails/$fileName';
      await _supabase.storage.from('area').upload(thumbnailPath, imageFile);
      
      // Create a record in the area_images table
      final areaImage = AreaImage(
        areaId: areaId,
        imageUrl: imageUrl,
        isPrimary: isPrimary,
      );
      
      final data = await _supabase
          .from('area_images')
          .insert(areaImage.toJson())
          .select()
          .single();
      
      // If this is the primary image, update the area record
      if (isPrimary) {
        await _supabase
            .from('areas')
            .update({'thumbnail_url': imageUrl})
            .eq('id', areaId);
      }
      
      return AreaImage.fromJson(data);
    } catch (e) {
      debugPrint('Error uploading area image: $e');
      return null;
    }
  }
  
  // Set an image as primary
  Future<bool> setImageAsPrimary(String areaId, String imageId) async {
    try {
      // First, set all images as non-primary
      await _supabase
          .from('area_images')
          .update({'is_primary': false})
          .eq('area_id', areaId);
      
      // Set the selected image as primary
      final data = await _supabase
          .from('area_images')
          .update({'is_primary': true})
          .eq('id', imageId)
          .select()
          .single();
      
      final imageUrl = data['image_url'];
      
      // Update the area's thumbnail_url field
      await _supabase
          .from('areas')
          .update({'thumbnail_url': imageUrl})
          .eq('id', areaId);
      
      return true;
    } catch (e) {
      debugPrint('Error setting primary image: $e');
      return false;
    }
  }
  
  // Delete an area image
  Future<bool> deleteAreaImage(String imageId) async {
    try {
      // Get the image details to access the storage file
      final data = await _supabase
          .from('area_images')
          .select()
          .eq('id', imageId)
          .single();
      
      final imageUrl = data['image_url'] as String;
      final fileName = imageUrl.split('/').last;
      
      // Delete from storage (both gallery and thumbnails if exist)
      try {
        await _supabase.storage.from('area').remove(['gallery/$fileName']);
        await _supabase.storage.from('area').remove(['thumbnails/$fileName']);
      } catch (e) {
        debugPrint('Error removing files from storage: $e');
        // Continue anyway to ensure database record is deleted
      }
      
      // Delete the database record
      await _supabase
          .from('area_images')
          .delete()
          .eq('id', imageId);
      
      return true;
    } catch (e) {
      debugPrint('Error deleting area image: $e');
      return false;
    }
  }
  
  // Helper to delete all images for an area
  Future<void> _deleteAllAreaImages(String areaId) async {
    try {
      // Get all images for the area
      final images = await getAreaImages(areaId);
      
      // Delete each image
      for (var image in images) {
        if (image.id != null) {
          await deleteAreaImage(image.id!);
        }
      }
    } catch (e) {
      debugPrint('Error deleting all area images: $e');
    }
  }
} 