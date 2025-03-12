import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripaldashboard/modules/sub_cities/models/sub_city.dart';
import 'package:tripaldashboard/modules/sub_cities/providers/sub_city_provider.dart';
import 'package:tripaldashboard/modules/sub_cities/screens/sub_city_detail_screen.dart';
import 'package:tripaldashboard/modules/sub_cities/screens/sub_city_form_screen.dart';
import 'package:tripaldashboard/modules/cities/models/city.dart';
import 'package:tripaldashboard/modules/cities/providers/city_provider.dart';

class SubCitiesListScreen extends ConsumerStatefulWidget {
  final String? cityId;
  final String? cityName;

  const SubCitiesListScreen({Key? key, this.cityId, this.cityName}) : super(key: key);

  @override
  ConsumerState<SubCitiesListScreen> createState() => _SubCitiesListScreenState();
}

class _SubCitiesListScreenState extends ConsumerState<SubCitiesListScreen> {
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _isAscending = false;
  String _orderBy = 'created_at';
  String? _selectedCityId;

  @override
  void initState() {
    super.initState();
    // If a city ID is provided, filter by that city
    _selectedCityId = widget.cityId;
    
    // Load sub_cities when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSubCities();
    });
  }

  void _loadSubCities() {
    ref.read(subCityNotifierProvider.notifier).loadSubCities(
      page: _currentPage,
      limit: _pageSize,
      orderBy: _orderBy,
      ascending: _isAscending,
      cityId: _selectedCityId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final subCitiesState = ref.watch(subCityNotifierProvider);
    final citiesAsync = ref.watch(citiesProvider(
      CityQueryParams(
        limit: 100, // Get all cities for the dropdown
      ),
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cityName != null 
          ? 'Sub-Cities in ${widget.cityName}' 
          : 'All Sub-Cities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(citiesAsync),
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSubCities,
          ),
        ],
      ),
      body: subCitiesState.when(
        data: (subCities) => _buildSubCitiesList(subCities),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error loading sub-cities: ${error.toString()}'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToSubCityForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSubCitiesList(List<SubCity> subCities) {
    if (subCities.isEmpty) {
      return const Center(
        child: Text('No sub-cities found. Add a new sub-city to get started.'),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: subCities.length,
            itemBuilder: (context, index) {
              final subCity = subCities[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: subCity.thumbnailUrl != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(subCity.thumbnailUrl!),
                        )
                      : const CircleAvatar(
                          child: Icon(Icons.location_city),
                        ),
                  title: Text(subCity.name),
                  subtitle: Text(
                    (subCity.description.length > 50)
                        ? '${subCity.description.substring(0, 50)}...'
                        : subCity.description,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _navigateToSubCityForm(subCity: subCity),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDeleteSubCity(subCity),
                      ),
                    ],
                  ),
                  onTap: () => _navigateToSubCityDetail(subCity),
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
                    _loadSubCities();
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
              _loadSubCities();
            },
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(AsyncValue<List<City>> citiesAsync) {
    citiesAsync.whenData((cities) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Filter Sub-Cities'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Filter by City:'),
              const SizedBox(height: 8),
              DropdownButton<String?>(
                isExpanded: true,
                value: _selectedCityId,
                hint: const Text('All Cities'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All Cities'),
                  ),
                  ...cities.map((city) => DropdownMenuItem<String?>(
                        value: city.id,
                        child: Text(city.name),
                      )),
                ],
                onChanged: (value) {
                  Navigator.pop(context);
                  setState(() {
                    _selectedCityId = value;
                    _currentPage = 1;
                  });
                  _loadSubCities();
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
        title: const Text('Sort Sub-Cities'),
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
                  _loadSubCities();
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
                  _loadSubCities();
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
                _loadSubCities();
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

  void _navigateToSubCityForm({SubCity? subCity}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubCityFormScreen(
          subCityToEdit: subCity,
        ),
      ),
    );

    if (result == true) {
      _loadSubCities();
    }
  }

  void _navigateToSubCityDetail(SubCity subCity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubCityDetailScreen(subCityId: subCity.id),
      ),
    );
  }

  void _confirmDeleteSubCity(SubCity subCity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sub-City'),
        content: Text('Are you sure you want to delete ${subCity.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(subCityNotifierProvider.notifier)
                  .deleteSubCity(subCity.id);
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${subCity.name} deleted successfully')),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete sub-city')),
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