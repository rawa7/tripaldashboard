import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripaldashboard/modules/areas/models/area.dart';
import 'package:tripaldashboard/modules/areas/models/area_image.dart';
import 'package:tripaldashboard/modules/areas/providers/area_service.dart';

// Provider for the AreaService
final areaServiceProvider = Provider<AreaService>((ref) {
  return AreaService();
});

// Provider for all areas with filtering and pagination
final areasProvider = FutureProvider.family<List<Area>, Map<String, dynamic>>((ref, params) async {
  final areaService = ref.watch(areaServiceProvider);
  return areaService.getAreas(
    page: params['page'] as int?,
    limit: params['limit'] as int?,
    subCityId: params['subCityId'] as String?,
    searchQuery: params['searchQuery'] as String?,
  );
});

// Provider for areas count
final areasCountProvider = FutureProvider.family<int, Map<String, dynamic>>((ref, params) async {
  final areaService = ref.watch(areaServiceProvider);
  return areaService.getAreasCount(
    subCityId: params['subCityId'] as String?,
    searchQuery: params['searchQuery'] as String?,
  );
});

// Provider for a single area by ID
final areaProvider = FutureProvider.family<Area?, String>((ref, id) async {
  final areaService = ref.watch(areaServiceProvider);
  return areaService.getAreaById(id);
});

// Provider for area images
final areaImagesProvider = FutureProvider.family<List<AreaImage>, String>((ref, areaId) async {
  final areaService = ref.watch(areaServiceProvider);
  return areaService.getAreaImages(areaId);
});

// State notifier for area operations
class AreaNotifier extends StateNotifier<AsyncValue<Area?>> {
  final AreaService _areaService;
  final Ref _ref;
  
  AreaNotifier(this._areaService, this._ref) : super(const AsyncValue.loading());
  
  // Create a new area
  Future<Area?> createArea(Area area) async {
    state = const AsyncValue.loading();
    try {
      final newArea = await _areaService.createArea(area);
      state = AsyncValue.data(newArea);
      return newArea;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }
  
  // Update an existing area
  Future<Area?> updateArea(Area area) async {
    state = const AsyncValue.loading();
    try {
      final updatedArea = await _areaService.updateArea(area);
      state = AsyncValue.data(updatedArea);
      return updatedArea;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }
  
  // Delete an area
  Future<bool> deleteArea(String id) async {
    try {
      final result = await _areaService.deleteArea(id);
      if (result) {
        state = const AsyncValue.data(null);
      }
      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
  
  // Upload an image for an area
  Future<AreaImage?> uploadImage(String areaId, File imageFile, {bool isPrimary = false}) async {
    try {
      final result = await _areaService.uploadAreaImage(areaId, imageFile, isPrimary: isPrimary);
      
      // Refresh images list
      _ref.refresh(areaImagesProvider(areaId));
      
      // If this is the primary image, refresh the area
      if (isPrimary && result != null) {
        _ref.refresh(areaProvider(areaId));
      }
      
      return result;
    } catch (e) {
      return null;
    }
  }
  
  // Set an image as primary
  Future<bool> setImageAsPrimary(String areaId, String imageId) async {
    try {
      final result = await _areaService.setImageAsPrimary(areaId, imageId);
      
      if (result) {
        // Refresh images list and area data
        _ref.refresh(areaImagesProvider(areaId));
        _ref.refresh(areaProvider(areaId));
      }
      
      return result;
    } catch (e) {
      return false;
    }
  }
  
  // Delete an area image
  Future<bool> deleteImage(String areaId, String imageId) async {
    try {
      final result = await _areaService.deleteAreaImage(imageId);
      
      if (result) {
        // Refresh images list
        _ref.refresh(areaImagesProvider(areaId));
      }
      
      return result;
    } catch (e) {
      return false;
    }
  }
}

// Provider for the area notifier
final areaNotifierProvider = StateNotifierProvider<AreaNotifier, AsyncValue<Area?>>((ref) {
  final areaService = ref.watch(areaServiceProvider);
  return AreaNotifier(areaService, ref);
}); 