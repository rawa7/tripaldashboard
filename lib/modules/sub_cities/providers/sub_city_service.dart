import 'package:tripaldashboard/core/services/supabase_service.dart';
import 'package:tripaldashboard/modules/sub_cities/models/sub_city.dart';
import 'package:tripaldashboard/modules/sub_cities/models/sub_city_image.dart';

class SubCityService {
  final SupabaseService _supabaseService;
  
  SubCityService(this._supabaseService);
  
  // Table names
  static const String _subCitiesTable = 'sub_cities';
  static const String _subCityImagesTable = 'sub_city_images';
  
  // Fetch all sub_cities with pagination
  Future<List<SubCity>> getSubCities({
    int page = 1,
    int limit = 10,
    String orderBy = 'created_at',
    bool ascending = false,
    String? cityId,
  }) async {
    try {
      final query = SupabaseService.staticClient
          .from(_subCitiesTable)
          .select();
          
      // Add filter if city ID is provided
      if (cityId != null) {
        // Use where filter instead of eq
        query.filter('city_id', 'eq', cityId);
      }
      
      // Add ordering
      query.order(orderBy, ascending: ascending);
      
      // Add pagination
      query.range((page - 1) * limit, page * limit - 1);
      
      final data = await query;
      return data.map((record) => SubCity.fromJson(record)).toList();
    } catch (e) {
      print('Error fetching sub_cities: $e');
      rethrow;
    }
  }
  
  // Get a sub_city by ID
  Future<SubCity?> getSubCityById(String id) async {
    try {
      final data = await SupabaseService.staticClient
          .from(_subCitiesTable)
          .select()
          .eq('id', id)
          .single();
      
      return data != null ? SubCity.fromJson(data) : null;
    } catch (e) {
      print('Error fetching sub_city by ID: $e');
      return null;
    }
  }
  
  // Create a new sub_city
  Future<SubCity> createSubCity(SubCity subCity) async {
    try {
      final data = subCity.toJson();
      
      final response = await SupabaseService.staticClient
          .from(_subCitiesTable)
          .insert(data)
          .select();
      
      return SubCity.fromJson(response.first);
    } catch (e) {
      print('Error creating sub_city: $e');
      rethrow;
    }
  }
  
  // Update a sub_city
  Future<SubCity> updateSubCity(SubCity subCity) async {
    try {
      final data = subCity.toJson();
      
      final response = await SupabaseService.staticClient
          .from(_subCitiesTable)
          .update(data)
          .eq('id', subCity.id)
          .select();
      
      return SubCity.fromJson(response.first);
    } catch (e) {
      print('Error updating sub_city: $e');
      rethrow;
    }
  }
  
  // Delete a sub_city
  Future<void> deleteSubCity(String id) async {
    try {
      // First delete all related images
      await SupabaseService.staticClient
        .from(_subCityImagesTable)
        .delete()
        .eq('sub_city_id', id);
      
      // Then delete the sub_city
      await SupabaseService.staticClient
        .from(_subCitiesTable)
        .delete()
        .eq('id', id);
    } catch (e) {
      print('Error deleting sub_city: $e');
      rethrow;
    }
  }
  
  // Get all images for a sub_city
  Future<List<SubCityImage>> getSubCityImages(String subCityId) async {
    try {
      final data = await SupabaseService.staticClient
        .from(_subCityImagesTable)
        .select()
        .eq('sub_city_id', subCityId);
      
      return data.map((record) => SubCityImage.fromJson(record)).toList();
    } catch (e) {
      print('Error fetching sub_city images: $e');
      return [];
    }
  }
  
  // Add an image to a sub_city
  Future<SubCityImage> addSubCityImage(SubCityImage image) async {
    try {
      final data = image.toJson();
      
      final response = await SupabaseService.staticClient
        .from(_subCityImagesTable)
        .insert(data)
        .select();
      
      return SubCityImage.fromJson(response.first);
    } catch (e) {
      print('Error adding sub_city image: $e');
      rethrow;
    }
  }
  
  // Update a sub_city image
  Future<SubCityImage> updateSubCityImage(SubCityImage image) async {
    try {
      final data = image.toJson();
      
      final response = await SupabaseService.staticClient
        .from(_subCityImagesTable)
        .update(data)
        .eq('id', image.id)
        .select();
      
      return SubCityImage.fromJson(response.first);
    } catch (e) {
      print('Error updating sub_city image: $e');
      rethrow;
    }
  }
  
  // Delete a sub_city image
  Future<void> deleteSubCityImage(String id) async {
    try {
      await SupabaseService.staticClient
        .from(_subCityImagesTable)
        .delete()
        .eq('id', id);
    } catch (e) {
      print('Error deleting sub_city image: $e');
      rethrow;
    }
  }
  
  // Set a sub_city image as primary
  Future<void> setSubCityImageAsPrimary(String subCityId, String imageId) async {
    try {
      // First, set all images for this sub_city as not primary
      await SupabaseService.staticClient
        .from(_subCityImagesTable)
        .update({'is_primary': false})
        .eq('sub_city_id', subCityId);
      
      // Then set the selected image as primary
      await SupabaseService.staticClient
        .from(_subCityImagesTable)
        .update({'is_primary': true})
        .eq('id', imageId);
    } catch (e) {
      print('Error setting sub_city image as primary: $e');
      rethrow;
    }
  }
} 