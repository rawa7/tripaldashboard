import 'package:tripaldashboard/core/services/supabase_service.dart';
import 'package:tripaldashboard/modules/cities/models/city.dart';
import 'package:tripaldashboard/modules/cities/models/city_image.dart';

class CityService {
  final SupabaseService _supabaseService;
  
  CityService(this._supabaseService);
  
  // Table names
  static const String _citiesTable = 'cities';
  static const String _cityImagesTable = 'city_images';
  
  // Fetch all cities with pagination
  Future<List<City>> getCities({
    int page = 1,
    int limit = 10,
    String orderBy = 'created_at',
    bool ascending = false,
    String? regionId,
  }) async {
    Map<String, dynamic>? filters;
    
    if (regionId != null) {
      filters = {'region_id': regionId};
    }
    
    final records = await _supabaseService.fetchRecords(
      table: _citiesTable,
      page: page,
      limit: limit,
      orderBy: orderBy,
      ascending: ascending,
      filters: filters,
    );
    
    return records.map((record) => City.fromJson(record)).toList();
  }
  
  // Get a city by ID
  Future<City?> getCityById(String id) async {
    final record = await _supabaseService.getRecordById(
      table: _citiesTable,
      id: id,
    );
    
    if (record == null) {
      return null;
    }
    
    return City.fromJson(record);
  }
  
  // Create a new city
  Future<City> createCity(City city) async {
    final record = await _supabaseService.insertRecord(
      table: _citiesTable,
      data: city.toJson(),
    );
    
    return City.fromJson(record);
  }
  
  // Update a city
  Future<City> updateCity(City city) async {
    final record = await _supabaseService.updateRecord(
      table: _citiesTable,
      id: city.id,
      data: city.toJson(),
    );
    
    return City.fromJson(record);
  }
  
  // Delete a city
  Future<void> deleteCity(String id) async {
    // First delete all related images
    await _supabaseService.client
      .from(_cityImagesTable)
      .delete()
      .eq('city_id', id);
    
    // Then delete the city
    await _supabaseService.deleteRecord(
      table: _citiesTable,
      id: id,
    );
  }
  
  // Get all images for a city
  Future<List<CityImage>> getCityImages(String cityId) async {
    final records = await _supabaseService.client
      .from(_cityImagesTable)
      .select()
      .eq('city_id', cityId);
    
    return records.map((record) => CityImage.fromJson(record)).toList();
  }
  
  // Add an image to a city
  Future<CityImage> addCityImage(CityImage image) async {
    final record = await _supabaseService.insertRecord(
      table: _cityImagesTable,
      data: image.toJson(),
    );
    
    return CityImage.fromJson(record);
  }
  
  // Update a city image
  Future<CityImage> updateCityImage(CityImage image) async {
    final record = await _supabaseService.updateRecord(
      table: _cityImagesTable,
      id: image.id,
      data: image.toJson(),
    );
    
    return CityImage.fromJson(record);
  }
  
  // Delete a city image
  Future<void> deleteCityImage(String id) async {
    await _supabaseService.deleteRecord(
      table: _cityImagesTable,
      id: id,
    );
  }
  
  // Set a city image as primary
  Future<void> setCityImageAsPrimary(String cityId, String imageId) async {
    // First, set all images for this city as not primary
    await _supabaseService.client
      .from(_cityImagesTable)
      .update({'is_primary': false})
      .eq('city_id', cityId);
    
    // Then set the selected image as primary
    await _supabaseService.client
      .from(_cityImagesTable)
      .update({'is_primary': true})
      .eq('id', imageId);
  }
} 