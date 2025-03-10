import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripaldashboard/core/providers/services_provider.dart';
import 'package:tripaldashboard/modules/sub_cities/models/sub_city.dart';
import 'package:tripaldashboard/modules/sub_cities/models/sub_city_image.dart';
import 'package:tripaldashboard/modules/sub_cities/providers/sub_city_service.dart';

// Provider for the SubCityService
final subCityServiceProvider = Provider<SubCityService>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return SubCityService(supabaseService);
});

// Class to hold sub_city query parameters
class SubCityQueryParams {
  final int page;
  final int limit;
  final String orderBy;
  final bool ascending;
  final String? cityId;

  SubCityQueryParams({
    this.page = 1,
    this.limit = 10,
    this.orderBy = 'created_at',
    this.ascending = false,
    this.cityId,
  });
}

// Provider for the list of sub_cities
final subCitiesProvider = FutureProvider.autoDispose.family<List<SubCity>, SubCityQueryParams>((ref, params) async {
  final subCityService = ref.watch(subCityServiceProvider);
  return subCityService.getSubCities(
    page: params.page,
    limit: params.limit,
    orderBy: params.orderBy,
    ascending: params.ascending,
    cityId: params.cityId,
  );
});

// Provider for a single sub_city by ID
final subCityProvider = FutureProvider.autoDispose.family<SubCity?, String>((ref, id) async {
  final subCityService = ref.watch(subCityServiceProvider);
  return subCityService.getSubCityById(id);
});

// Provider for sub_city images
final subCityImagesProvider = FutureProvider.autoDispose.family<List<SubCityImage>, String>((ref, subCityId) async {
  final subCityService = ref.watch(subCityServiceProvider);
  return subCityService.getSubCityImages(subCityId);
});

// Notifier for managing sub_city state
class SubCityNotifier extends StateNotifier<AsyncValue<List<SubCity>>> {
  final SubCityService _subCityService;
  
  SubCityNotifier(this._subCityService) : super(const AsyncValue.loading());
  
  // Load sub_cities
  Future<void> loadSubCities({
    int page = 1,
    int limit = 10,
    String orderBy = 'created_at',
    bool ascending = false,
    String? cityId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final subCities = await _subCityService.getSubCities(
        page: page,
        limit: limit,
        orderBy: orderBy,
        ascending: ascending,
        cityId: cityId,
      );
      state = AsyncValue.data(subCities);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  // Create a new sub_city
  Future<SubCity?> createSubCity(SubCity subCity) async {
    try {
      final createdSubCity = await _subCityService.createSubCity(subCity);
      
      // Update the state with the new sub_city
      state.whenData((subCities) {
        state = AsyncValue.data([createdSubCity, ...subCities]);
      });
      
      return createdSubCity;
    } catch (e) {
      print('Error in createSubCity: $e');
      return null;
    }
  }
  
  // Update a sub_city
  Future<SubCity?> updateSubCity(SubCity subCity) async {
    try {
      final updatedSubCity = await _subCityService.updateSubCity(subCity);
      
      // Update the state with the updated sub_city
      state.whenData((subCities) {
        final index = subCities.indexWhere((c) => c.id == subCity.id);
        if (index != -1) {
          final updatedSubCities = List<SubCity>.from(subCities);
          updatedSubCities[index] = updatedSubCity;
          state = AsyncValue.data(updatedSubCities);
        }
      });
      
      return updatedSubCity;
    } catch (e) {
      print('Error in updateSubCity: $e');
      return null;
    }
  }
  
  // Delete a sub_city
  Future<bool> deleteSubCity(String id) async {
    try {
      await _subCityService.deleteSubCity(id);
      
      // Update the state by removing the deleted sub_city
      state.whenData((subCities) {
        final updatedSubCities = subCities.where((c) => c.id != id).toList();
        state = AsyncValue.data(updatedSubCities);
      });
      
      return true;
    } catch (e) {
      print('Error in deleteSubCity: $e');
      return false;
    }
  }
}

// Provider for the SubCityNotifier
final subCityNotifierProvider = StateNotifierProvider<SubCityNotifier, AsyncValue<List<SubCity>>>((ref) {
  final subCityService = ref.watch(subCityServiceProvider);
  return SubCityNotifier(subCityService);
}); 