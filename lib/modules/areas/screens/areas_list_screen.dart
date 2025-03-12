import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripaldashboard/modules/areas/models/area.dart';
import 'package:tripaldashboard/modules/areas/providers/area_provider.dart';
import 'package:tripaldashboard/modules/areas/screens/area_form_screen.dart';
import 'package:tripaldashboard/modules/areas/screens/area_detail_screen.dart';
import 'package:tripaldashboard/modules/sub_cities/models/sub_city.dart';
import 'package:tripaldashboard/modules/sub_cities/providers/sub_city_provider.dart';
import 'package:flutter/foundation.dart';

// Create a StateProvider to store the query parameters
final areaQueryParamsProvider = StateProvider<Map<String, dynamic>>((ref) => {
  'page': 1,
  'limit': 10,
  'subCityId': null,
  'searchQuery': '',
});

// Provider for current display language
final displayLanguageProvider = StateProvider<String>((ref) => 'en'); // Default to English

class AreasListScreen extends ConsumerStatefulWidget {
  const AreasListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AreasListScreen> createState() => _AreasListScreenState();
}

class _AreasListScreenState extends ConsumerState<AreasListScreen> {
  int _currentPage = 1;
  final int _pageSize = 10;
  String? _selectedSubCityId;
  String _searchQuery = '';
  List<SubCity> _subCities = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadSubCities();
    
    // Initialize query params in the next frame to avoid build-time issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(areaQueryParamsProvider.notifier).state = {
        'page': _currentPage,
        'limit': _pageSize,
        'subCityId': _selectedSubCityId,
        'searchQuery': _searchQuery,
      };
    });
  }
  
  Future<void> _loadSubCities() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final subCities = await ref.read(subCityServiceProvider).getSubCities();
      
      if (mounted) {
        setState(() {
          _subCities = subCities;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading sub-cities: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Update the query params in the provider
  void _updateQueryParams() {
    if (mounted) {
      ref.read(areaQueryParamsProvider.notifier).state = {
        'page': _currentPage,
        'limit': _pageSize,
        'subCityId': _selectedSubCityId,
        'searchQuery': _searchQuery,
      };
    }
  }
  
  void _nextPage(int totalCount) {
    final int totalPages = (totalCount / _pageSize).ceil();
    if (_currentPage < totalPages) {
      setState(() {
        _currentPage++;
      });
      _updateQueryParams();
    }
  }
  
  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
      _updateQueryParams();
    }
  }
  
  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1;
    });
    _updateQueryParams();
  }
  
  void _onSubCityFilterChanged(String? subCityId) {
    setState(() {
      _selectedSubCityId = subCityId;
      _currentPage = 1;
    });
    _updateQueryParams();
  }
  
  void _refreshAreas() {
    debugPrint('🔍 Manually refreshing areas list');
    
    // Invalidate the providers to force a refresh
    ref.invalidate(areasProvider);
    ref.invalidate(areasCountProvider);
    
    // Update the query params
    _updateQueryParams();
  }
  
  void _showDeleteConfirmation(BuildContext context, Area area) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${area.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _deleteArea(area.id!);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteArea(String id) async {
    final result = await ref.read(areaNotifierProvider.notifier).deleteArea(id);
    
    if (result && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Area deleted successfully')),
      );
      
      // Refresh the list
      _refreshAreas();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete area')),
      );
    }
  }
  
  // Get the appropriate name based on the current language
  String getLocalizedName(Area area, String languageCode) {
    switch (languageCode) {
      case 'ar':
        return area.nameAr ?? area.name;
      case 'ku':
        return area.nameKu ?? area.name;
      case 'bad':
        return area.nameBad ?? area.name;
      case 'en':
      default:
        return area.name;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Get the current query params from the provider
    final queryParams = ref.watch(areaQueryParamsProvider);
    
    // Watch the areas and count providers with the query params
    final areasAsync = ref.watch(areasProvider(queryParams));
    final totalCountAsync = ref.watch(areasCountProvider(queryParams));
    
    // Get current display language
    final currentLanguage = ref.watch(displayLanguageProvider);
    
    debugPrint('🔍 AreasListScreen state: ${areasAsync.toString()}');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Areas'),
        actions: [
          // Language selector dropdown
          DropdownButton<String>(
            value: currentLanguage,
            underline: Container(), // Remove underline
            icon: const Icon(Icons.language, color: Colors.white),
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'ar', child: Text('العربية')),
              DropdownMenuItem(value: 'ku', child: Text('کوردی')),
              DropdownMenuItem(value: 'bad', child: Text('بادینی')),
            ],
            onChanged: (value) {
              if (value != null) {
                ref.read(displayLanguageProvider.notifier).state = value;
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAreas,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AreaFormScreen(),
                ),
              ).then((_) {
                _refreshAreas();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search Areas',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _onSearch,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  decoration: const InputDecoration(
                    labelText: 'Filter by Sub-City',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedSubCityId,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All Sub-Cities'),
                    ),
                    ..._subCities.map((subCity) => DropdownMenuItem<String?>(
                      value: subCity.id,
                      child: Text(subCity.name),
                    )),
                  ],
                  onChanged: _onSubCityFilterChanged,
                ),
              ],
            ),
          ),
          
          // Areas list
          Expanded(
            child: areasAsync.when(
              data: (areas) {
                if (areas.isEmpty) {
                  return const Center(
                    child: Text('No areas found'),
                  );
                }
                
                return ListView.builder(
                  itemCount: areas.length,
                  itemBuilder: (context, index) {
                    final area = areas[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: area.thumbnailUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  area.thumbnailUrl!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.domain,
                                    size: 40,
                                  ),
                                ),
                              )
                            : const CircleAvatar(
                                child: Icon(Icons.domain),
                              ),
                        title: Text(getLocalizedName(area, currentLanguage)),
                        subtitle: Text(
                          area.subCityName ?? 'No Sub-City',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => AreaFormScreen(
                                      areaId: area.id,
                                    ),
                                  ),
                                ).then((_) {
                                  _refreshAreas();
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteConfirmation(context, area),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AreaDetailScreen(
                                areaId: area.id!,
                              ),
                            ),
                          ).then((_) {
                            _refreshAreas();
                          });
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
          
          // Pagination controls
          totalCountAsync.when(
            data: (totalCount) {
              final totalPages = (totalCount / _pageSize).ceil();
              if (totalPages <= 1) return const SizedBox();
              
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _currentPage > 1 ? _previousPage : null,
                    ),
                    Text('Page $_currentPage of $totalPages'),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _currentPage < totalPages ? () => _nextPage(totalCount) : null,
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
    );
  }
} 