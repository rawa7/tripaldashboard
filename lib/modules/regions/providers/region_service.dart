import 'package:tripaldashboard/core/services/supabase_service.dart';
import 'package:tripaldashboard/modules/regions/models/region.dart';
import 'package:tripaldashboard/modules/regions/models/region_image.dart';

class RegionService {
  final SupabaseService _supabaseService;
  
  RegionService(this._supabaseService);
  
  // Table names
  static const String _regionsTable = 'regions';
  static const String _regionImagesTable = 'region_images';
  
  // Fetch all regions with pagination
  Future<List<Region>> getRegions({
    int page = 1,
    int limit = 10,
    String orderBy = 'created_at',
    bool ascending = false,
  }) async {
    final records = await _supabaseService.fetchRecords(
      table: _regionsTable,
      page: page,
      limit: limit,
      orderBy: orderBy,
      ascending: ascending,
    );
    
    return records.map((record) => Region.fromJson(record)).toList();
  }
  
  // Get a region by ID
  Future<Region?> getRegionById(String id) async {
    final record = await _supabaseService.getRecordById(
      table: _regionsTable,
      id: id,
    );
    
    if (record == null) {
      return null;
    }
    
    return Region.fromJson(record);
  }
  
  // Create a new region
  Future<Region> createRegion(Region region) async {
    final record = await _supabaseService.insertRecord(
      table: _regionsTable,
      data: region.toJson(),
    );
    
    return Region.fromJson(record);
  }
  
  // Update a region
  Future<Region> updateRegion(Region region) async {
    final record = await _supabaseService.updateRecord(
      table: _regionsTable,
      id: region.id,
      data: region.toJson(),
    );
    
    return Region.fromJson(record);
  }
  
  // Delete a region
  Future<void> deleteRegion(String id) async {
    // First delete all related images
    await _supabaseService.client
      .from(_regionImagesTable)
      .delete()
      .eq('region_id', id);
    
    // Then delete the region
    await _supabaseService.deleteRecord(
      table: _regionsTable,
      id: id,
    );
  }
  
  // Get all images for a region
  Future<List<RegionImage>> getRegionImages(String regionId) async {
    final records = await _supabaseService.client
      .from(_regionImagesTable)
      .select()
      .eq('region_id', regionId);
    
    return records.map((record) => RegionImage.fromJson(record)).toList();
  }
  
  // Add an image to a region
  Future<RegionImage> addRegionImage(RegionImage image) async {
    final record = await _supabaseService.insertRecord(
      table: _regionImagesTable,
      data: image.toJson(),
    );
    
    return RegionImage.fromJson(record);
  }
  
  // Update a region image
  Future<RegionImage> updateRegionImage(RegionImage image) async {
    final record = await _supabaseService.updateRecord(
      table: _regionImagesTable,
      id: image.id,
      data: image.toJson(),
    );
    
    return RegionImage.fromJson(record);
  }
  
  // Delete a region image
  Future<void> deleteRegionImage(String id) async {
    await _supabaseService.deleteRecord(
      table: _regionImagesTable,
      id: id,
    );
  }
  
  // Set a region image as primary
  Future<void> setRegionImageAsPrimary(String regionId, String imageId) async {
    // First, set all images for this region as not primary
    await _supabaseService.client
      .from(_regionImagesTable)
      .update({'is_primary': false})
      .eq('region_id', regionId);
    
    // Then set the selected image as primary
    await _supabaseService.client
      .from(_regionImagesTable)
      .update({'is_primary': true})
      .eq('id', imageId);
  }
} 