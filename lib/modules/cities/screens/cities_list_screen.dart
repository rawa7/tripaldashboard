import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripaldashboard/modules/cities/models/city.dart';
import 'package:tripaldashboard/modules/cities/providers/city_provider.dart';
import 'package:tripaldashboard/modules/cities/screens/city_detail_screen.dart';
import 'package:tripaldashboard/modules/cities/screens/city_form_screen.dart';
import 'package:tripaldashboard/modules/regions/models/region.dart';
import 'package:tripaldashboard/modules/regions/providers/region_provider.dart';

class CitiesListScreen extends ConsumerStatefulWidget {
  const CitiesListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CitiesListScreen> createState() => _CitiesListScreenState();
}

class _CitiesListScreenState extends ConsumerState<CitiesListScreen> {
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _isAscending = false;
  String _orderBy = 'created_at';
  String? _selectedRegionId;

  @override
  void initState() {
    super.initState();
    // Load cities when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCities();
    });
  }

  void _loadCities() {
    ref.read(cityNotifierProvider.notifier).loadCities(
      page: _currentPage,
      limit: _pageSize,
      orderBy: _orderBy,
      ascending: _isAscending,
      regionId: _selectedRegionId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final citiesState = ref.watch(cityNotifierProvider);
    final regionsAsync = ref.watch(regionsProvider(
      RegionQueryParams(
        limit: 100, // Get all regions for the dropdown
      ),
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(regionsAsync),
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCities,
          ),
        ],
      ),
      body: citiesState.when(
        data: (cities) => _buildCitiesList(cities),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error loading cities: ${error.toString()}'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCityForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCitiesList(List<City> cities) {
    if (cities.isEmpty) {
      return const Center(
        child: Text('No cities found. Add a new city to get started.'),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: cities.length,
            itemBuilder: (context, index) {
              final city = cities[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: city.thumbnailUrl != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(city.thumbnailUrl!),
                        )
                      : const CircleAvatar(
                          child: Icon(Icons.location_city),
                        ),
                  title: Text(city.name),
                  subtitle: Text(
                    (city.description?.length ?? 0) > 50
                        ? '${city.description?.substring(0, 50)}...'
                        : city.description ?? '',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _navigateToCityForm(city: city),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDeleteCity(city),
                      ),
                    ],
                  ),
                  onTap: () => _navigateToCityDetail(city),
                ),
              );
            },
          ),
        ),
        _buildPagination(),
      ],
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _currentPage > 1
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                    _loadCities();
                  }
                : null,
          ),
          Text('Page $_currentPage'),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              setState(() {
                _currentPage++;
              });
              _loadCities();
            },
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(AsyncValue<List<Region>> regionsAsync) {
    regionsAsync.whenData((regions) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Filter Cities'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Filter by Region:'),
              const SizedBox(height: 8),
              DropdownButton<String?>(
                isExpanded: true,
                value: _selectedRegionId,
                hint: const Text('All Regions'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All Regions'),
                  ),
                  ...regions.map((region) => DropdownMenuItem<String?>(
                        value: region.id,
                        child: Text(region.name),
                      )),
                ],
                onChanged: (value) {
                  Navigator.pop(context);
                  setState(() {
                    _selectedRegionId = value;
                    _currentPage = 1;
                  });
                  _loadCities();
                },
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
    });
  }

  void _showSortOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Cities'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Name'),
              trailing: Radio<String>(
                value: 'name',
                groupValue: _orderBy,
                onChanged: (value) {
                  setState(() {
                    _orderBy = value!;
                  });
                  Navigator.pop(context);
                  _loadCities();
                },
              ),
            ),
            ListTile(
              title: const Text('Created Date'),
              trailing: Radio<String>(
                value: 'created_at',
                groupValue: _orderBy,
                onChanged: (value) {
                  setState(() {
                    _orderBy = value!;
                  });
                  Navigator.pop(context);
                  _loadCities();
                },
              ),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Ascending Order'),
              value: _isAscending,
              onChanged: (value) {
                setState(() {
                  _isAscending = value;
                });
                Navigator.pop(context);
                _loadCities();
              },
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
  }

  void _navigateToCityForm({City? city}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CityFormScreen(cityToEdit: city),
      ),
    );

    if (result == true) {
      _loadCities();
    }
  }

  void _navigateToCityDetail(City city) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CityDetailScreen(cityId: city.id),
      ),
    );
  }

  void _confirmDeleteCity(City city) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete City'),
        content: Text('Are you sure you want to delete ${city.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(cityNotifierProvider.notifier)
                  .deleteCity(city.id);
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${city.name} deleted successfully')),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete city')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 