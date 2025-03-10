import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripaldashboard/core/providers/services_provider.dart';
import 'package:tripaldashboard/modules/cities/models/city.dart';
import 'package:tripaldashboard/modules/cities/models/city_image.dart';
import 'package:tripaldashboard/modules/cities/providers/city_service.dart';

// Provider for the CityService
final cityServiceProvider = Provider<CityService>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return CityService(supabaseService);
});

// Provider for the list of cities
final citiesProvider = FutureProvider.autoDispose.family<List<City>, CityQueryParams>((ref, params) async {
  final cityService = ref.watch(cityServiceProvider);
  return cityService.getCities(
    page: params.page,
    limit: params.limit,
    orderBy: params.orderBy,
    ascending: params.ascending,
    regionId: params.regionId,
  );
});

// Provider for a single city by ID
final cityProvider = FutureProvider.autoDispose.family<City?, String>((ref, id) async {
  final cityService = ref.watch(cityServiceProvider);
  return cityService.getCityById(id);
});

// Provider for city images
final cityImagesProvider = FutureProvider.autoDispose.family<List<CityImage>, String>((ref, cityId) async {
  final cityService = ref.watch(cityServiceProvider);
  return cityService.getCityImages(cityId);
});

// Class to hold city query parameters
class CityQueryParams {
  final int page;
  final int limit;
  final String orderBy;
  final bool ascending;
  final String? regionId;

  CityQueryParams({
    this.page = 1,
    this.limit = 10,
    this.orderBy = 'created_at',
    this.ascending = false,
    this.regionId,
  });
}

// Notifier for managing city state
class CityNotifier extends StateNotifier<AsyncValue<List<City>>> {
  final CityService _cityService;
  
  CityNotifier(this._cityService) : super(const AsyncValue.loading());
  
  // Load cities
  Future<void> loadCities({
    int page = 1,
    int limit = 10,
    String orderBy = 'created_at',
    bool ascending = false,
    String? regionId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final cities = await _cityService.getCities(
        page: page,
        limit: limit,
        orderBy: orderBy,
        ascending: ascending,
        regionId: regionId,
      );
      state = AsyncValue.data(cities);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  // Create a new city
  Future<City?> createCity(City city) async {
    try {
      final createdCity = await _cityService.createCity(city);
      
      // Update the state with the new city
      state.whenData((cities) {
        state = AsyncValue.data([createdCity, ...cities]);
      });
      
      return createdCity;
    } catch (e) {
      return null;
    }
  }
  
  // Update a city
  Future<City?> updateCity(City city) async {
    try {
      final updatedCity = await _cityService.updateCity(city);
      
      // Update the state with the updated city
      state.whenData((cities) {
        final index = cities.indexWhere((c) => c.id == city.id);
        if (index != -1) {
          final updatedCities = List<City>.from(cities);
          updatedCities[index] = updatedCity;
          state = AsyncValue.data(updatedCities);
        }
      });
      
      return updatedCity;
    } catch (e) {
      return null;
    }
  }
  
  // Delete a city
  Future<bool> deleteCity(String id) async {
    try {
      await _cityService.deleteCity(id);
      
      // Update the state by removing the deleted city
      state.whenData((cities) {
        final updatedCities = cities.where((c) => c.id != id).toList();
        state = AsyncValue.data(updatedCities);
      });
      
      return true;
    } catch (e) {
      return false;
    }
  }
}

// Provider for the CityNotifier
final cityNotifierProvider = StateNotifierProvider<CityNotifier, AsyncValue<List<City>>>((ref) {
  final cityService = ref.watch(cityServiceProvider);
  return CityNotifier(cityService);
}); 