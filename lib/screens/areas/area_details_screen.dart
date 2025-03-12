import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/area.dart';
import './edit_area_screen.dart';
import '../../utils/snackbar_utils.dart';

class AreaDetailsScreen extends StatefulWidget {
  final String areaId;
  
  const AreaDetailsScreen({Key? key, required this.areaId}) : super(key: key);

  @override
  _AreaDetailsScreenState createState() => _AreaDetailsScreenState();
}

class _AreaDetailsScreenState extends State<AreaDetailsScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  Map<String, dynamic>? _areaData;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAreaData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadAreaData() async {
    try {
      final supabase = Supabase.instance.client;
      
      final response = await supabase
          .from('areas')
          .select('*, sub_cities(name)')
          .eq('id', widget.areaId)
          .single();
      
      if (mounted) {
        setState(() {
          _areaData = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'Error loading area data: $e');
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _navigateToEditScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAreaScreen(areaId: widget.areaId),
      ),
    );
    
    if (result == true) {
      _loadAreaData();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? 'Area Details' : (_areaData?['name'] ?? 'Area Details')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _isLoading ? null : _navigateToEditScreen,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'English'),
            Tab(text: 'Arabic'),
            Tab(text: 'Kurdish'),
            Tab(text: 'Badinani'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // English Tab
                _buildLanguageTab(
                  name: _areaData?['name'] ?? '',
                  description: _areaData?['description'] ?? '',
                  subCityName: _areaData?['sub_cities']?['name'] ?? '',
                  latitude: _areaData?['latitude']?.toString() ?? '',
                  longitude: _areaData?['longitude']?.toString() ?? '',
                ),
                
                // Arabic Tab
                _buildLanguageTab(
                  name: _areaData?['name_ar'] ?? '',
                  description: _areaData?['description_ar'] ?? '',
                  subCityName: _areaData?['sub_cities']?['name_ar'] ?? _areaData?['sub_cities']?['name'] ?? '',
                  latitude: _areaData?['latitude']?.toString() ?? '',
                  longitude: _areaData?['longitude']?.toString() ?? '',
                ),
                
                // Kurdish Tab
                _buildLanguageTab(
                  name: _areaData?['name_ku'] ?? '',
                  description: _areaData?['description_ku'] ?? '',
                  subCityName: _areaData?['sub_cities']?['name_ku'] ?? _areaData?['sub_cities']?['name'] ?? '',
                  latitude: _areaData?['latitude']?.toString() ?? '',
                  longitude: _areaData?['longitude']?.toString() ?? '',
                ),
                
                // Badinani Tab
                _buildLanguageTab(
                  name: _areaData?['name_bad'] ?? '',
                  description: _areaData?['description_bad'] ?? '',
                  subCityName: _areaData?['sub_cities']?['name_bad'] ?? _areaData?['sub_cities']?['name'] ?? '',
                  latitude: _areaData?['latitude']?.toString() ?? '',
                  longitude: _areaData?['longitude']?.toString() ?? '',
                ),
              ],
            ),
    );
  }
  
  Widget _buildLanguageTab({
    required String name,
    required String description,
    required String subCityName,
    required String latitude,
    required String longitude,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name.isEmpty ? 'Not provided' : name,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    'Description:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description.isEmpty ? 'Not provided' : description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    'Sub-City:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subCityName.isEmpty ? 'Not provided' : subCityName,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    'Coordinates:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Latitude: $latitude, Longitude: $longitude',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 