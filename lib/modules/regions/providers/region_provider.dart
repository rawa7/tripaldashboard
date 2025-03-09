import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripaldashboard/core/providers/services_provider.dart';
import 'package:tripaldashboard/modules/regions/models/region.dart';
import 'package:tripaldashboard/modules/regions/models/region_image.dart';
import 'package:tripaldashboard/modules/regions/providers/region_service.dart';

// Provider for the RegionService
final regionServiceProvider = Provider<RegionService>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return RegionService(supabaseService);
});

// Provider for the list of regions
final regionsProvider = FutureProvider.autoDispose.family<List<Region>, RegionQueryParams>((ref, params) async {
  final regionService = ref.watch(regionServiceProvider);
  return regionService.getRegions(
    page: params.page,
    limit: params.limit,
    orderBy: params.orderBy,
    ascending: params.ascending,
  );
});

// Provider for a single region by ID
final regionProvider = FutureProvider.autoDispose.family<Region?, String>((ref, id) async {
  final regionService = ref.watch(regionServiceProvider);
  return regionService.getRegionById(id);
});

// Provider for region images
final regionImagesProvider = FutureProvider.autoDispose.family<List<RegionImage>, String>((ref, regionId) async {
  final regionService = ref.watch(regionServiceProvider);
  return regionService.getRegionImages(regionId);
});

// Class to hold region query parameters
class RegionQueryParams {
  final int page;
  final int limit;
  final String orderBy;
  final bool ascending;

  RegionQueryParams({
    this.page = 1,
    this.limit = 10,
    this.orderBy = 'created_at',
    this.ascending = false,
  });
}

// Notifier for managing region state
class RegionNotifier extends StateNotifier<AsyncValue<List<Region>>> {
  final RegionService _regionService;
  
  RegionNotifier(this._regionService) : super(const AsyncValue.loading());
  
  // Load regions
  Future<void> loadRegions({
    int page = 1,
    int limit = 10,
    String orderBy = 'created_at',
    bool ascending = false,
  }) async {
    state = const AsyncValue.loading();
    try {
      final regions = await _regionService.getRegions(
        page: page,
        limit: limit,
        orderBy: orderBy,
        ascending: ascending,
      );
      state = AsyncValue.data(regions);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  // Create a new region
  Future<Region?> createRegion(Region region) async {
    try {
      final createdRegion = await _regionService.createRegion(region);
      
      // Update the state with the new region
      state.whenData((regions) {
        state = AsyncValue.data([createdRegion, ...regions]);
      });
      
      return createdRegion;
    } catch (e) {
      return null;
    }
  }
  
  // Update a region
  Future<Region?> updateRegion(Region region) async {
    try {
      final updatedRegion = await _regionService.updateRegion(region);
      
      // Update the state with the updated region
      state.whenData((regions) {
        final index = regions.indexWhere((r) => r.id == region.id);
        if (index != -1) {
          final updatedRegions = List<Region>.from(regions);
          updatedRegions[index] = updatedRegion;
          state = AsyncValue.data(updatedRegions);
        }
      });
      
      return updatedRegion;
    } catch (e) {
      return null;
    }
  }
  
  // Delete a region
  Future<bool> deleteRegion(String id) async {
    try {
      await _regionService.deleteRegion(id);
      
      // Update the state by removing the deleted region
      state.whenData((regions) {
        final updatedRegions = regions.where((r) => r.id != id).toList();
        state = AsyncValue.data(updatedRegions);
      });
      
      return true;
    } catch (e) {
      return false;
    }
  }
}

// Provider for the RegionNotifier
final regionNotifierProvider = StateNotifierProvider<RegionNotifier, AsyncValue<List<Region>>>((ref) {
  final regionService = ref.watch(regionServiceProvider);
  return RegionNotifier(regionService);
}); 