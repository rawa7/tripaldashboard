import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tripaldashboard/modules/regions/models/region.dart';
import 'package:tripaldashboard/modules/regions/providers/region_provider.dart';
import 'package:tripaldashboard/modules/regions/screens/region_detail_screen.dart';
import 'package:tripaldashboard/modules/regions/screens/region_form_screen.dart';

class RegionsListScreen extends ConsumerStatefulWidget {
  const RegionsListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegionsListScreen> createState() => _RegionsListScreenState();
}

class _RegionsListScreenState extends ConsumerState<RegionsListScreen> {
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _isAscending = false;
  String _orderBy = 'created_at';

  @override
  void initState() {
    super.initState();
    // Load regions when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRegions();
    });
  }

  void _loadRegions() {
    ref.read(regionNotifierProvider.notifier).loadRegions(
      page: _currentPage,
      limit: _pageSize,
      orderBy: _orderBy,
      ascending: _isAscending,
    );
  }

  @override
  Widget build(BuildContext context) {
    final regionsState = ref.watch(regionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Regions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRegions,
          ),
        ],
      ),
      body: regionsState.when(
        data: (regions) => _buildRegionsList(regions),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error loading regions: ${error.toString()}'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToRegionForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRegionsList(List<Region> regions) {
    if (regions.isEmpty) {
      return const Center(
        child: Text('No regions found. Add a new region to get started.'),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: regions.length,
            itemBuilder: (context, index) {
              final region = regions[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: region.thumbnailUrl != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(region.thumbnailUrl!),
                        )
                      : const CircleAvatar(
                          child: Icon(Icons.map),
                        ),
                  title: Text(region.name),
                  subtitle: Text(
                    region.description.length > 50
                        ? '${region.description.substring(0, 50)}...'
                        : region.description,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _navigateToRegionForm(region: region),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDeleteRegion(region),
                      ),
                    ],
                  ),
                  onTap: () => _navigateToRegionDetail(region),
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
                    _loadRegions();
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
              _loadRegions();
            },
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Regions'),
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
                  _loadRegions();
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
                  _loadRegions();
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
                _loadRegions();
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

  void _navigateToRegionForm({Region? region}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegionFormScreen(region: region),
      ),
    );

    if (result == true) {
      _loadRegions();
    }
  }

  void _navigateToRegionDetail(Region region) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegionDetailScreen(regionId: region.id),
      ),
    );
  }

  void _confirmDeleteRegion(Region region) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Region'),
        content: Text('Are you sure you want to delete ${region.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(regionNotifierProvider.notifier)
                  .deleteRegion(region.id);
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${region.name} deleted successfully')),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to delete region')),
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