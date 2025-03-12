import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tripaldashboard/core/providers/services_provider.dart';
import 'package:tripaldashboard/core/utils/image_utils.dart';
import 'package:tripaldashboard/modules/cities/models/city.dart';
import 'package:tripaldashboard/modules/cities/providers/city_provider.dart';
import 'package:tripaldashboard/modules/regions/models/region.dart';
import 'package:tripaldashboard/modules/regions/providers/region_provider.dart';
import 'package:tripaldashboard/core/services/supabase_service.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class CityFormScreen extends ConsumerStatefulWidget {
  final City? cityToEdit;

  const CityFormScreen({Key? key, this.cityToEdit}) : super(key: key);

  @override
  ConsumerState<CityFormScreen> createState() => _CityFormScreenState();
}

class _CityFormScreenState extends ConsumerState<CityFormScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // English form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Arabic form controllers
  final _nameArController = TextEditingController();
  final _descriptionArController = TextEditingController();
  
  // Kurdish form controllers
  final _nameKuController = TextEditingController();
  final _descriptionKuController = TextEditingController();
  
  // Badinani form controllers
  final _nameBadController = TextEditingController();
  final _descriptionBadController = TextEditingController();
  
  // Tab controller for language selection
  late TabController _tabController;
  
  Region? _selectedRegion;
  String? _thumbnailUrl;
  bool _isLoading = false;
  bool _isUploading = false;
  List<Region> _regions = [];
  
  static const String _bucketName = 'city_images';
  static const String _directory = 'thumbnails';

  @override
  void initState() {
    super.initState();
    _loadRegions();
    
    // Initialize tab controller
    _tabController = TabController(length: 4, vsync: this);
    
    // If editing, populate the form
    if (widget.cityToEdit != null) {
      // English fields
      _nameController.text = widget.cityToEdit!.name;
      _descriptionController.text = widget.cityToEdit!.description ?? '';
      
      // Arabic fields
      _nameArController.text = widget.cityToEdit!.nameAr ?? '';
      _descriptionArController.text = widget.cityToEdit!.descriptionAr ?? '';
      
      // Kurdish fields
      _nameKuController.text = widget.cityToEdit!.nameKu ?? '';
      _descriptionKuController.text = widget.cityToEdit!.descriptionKu ?? '';
      
      // Badinani fields
      _nameBadController.text = widget.cityToEdit!.nameBad ?? '';
      _descriptionBadController.text = widget.cityToEdit!.descriptionBad ?? '';
      
      _thumbnailUrl = widget.cityToEdit!.thumbnailUrl;
      _loadRegionForCity();
    }
  }

  Future<void> _loadRegions() async {
    try {
      setState(() => _isLoading = true);
      final regions = await SupabaseService.staticClient
          .from('regions')
          .select()
          .order('name');
      
      setState(() {
        _regions = regions.map((region) => Region.fromJson(region)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load regions: ${e.toString()}');
    }
  }

  Future<void> _loadRegionForCity() async {
    if (widget.cityToEdit?.regionId == null) return;
    
    try {
      final data = await SupabaseService.staticClient
          .from('regions')
          .select()
          .eq('id', widget.cityToEdit!.regionId)
          .single();
      
      if (data != null) {
        setState(() {
          _selectedRegion = Region.fromJson(data);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load region: ${e.toString()}');
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile == null) return;
      
      if (!mounted) return; // Check if widget is still mounted
      setState(() => _isUploading = true);
      
      // Skip bucket creation - it should already exist in Supabase
      // or be created by an admin with proper permissions
      
      // Generate a unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExt = p.extension(pickedFile.path);
      final fileName = '$timestamp$fileExt';
      final filePath = '$_directory/$fileName';
      
      // Upload the file
      final fileBytes = await pickedFile.readAsBytes();
      
      try {
        final response = await SupabaseService.staticClient
            .storage
            .from(_bucketName)
            .uploadBinary(filePath, fileBytes);
        
        if (response.contains('error')) {
          throw Exception('Failed to upload image');
        }
        
        // Get the public URL
        final imageUrl = SupabaseService.staticClient
            .storage
            .from(_bucketName)
            .getPublicUrl(filePath);
        
        if (!mounted) return; // Check again before setting state
        setState(() {
          _thumbnailUrl = imageUrl;
          _isUploading = false;
        });
      } catch (e) {
        print('Storage error: $e');
        if (!mounted) return;
        setState(() => _isUploading = false);
        _showErrorSnackBar('Failed to upload image: ${e.toString()}');
      }
    } catch (e) {
      print('General error: $e');
      if (!mounted) return;
      setState(() => _isUploading = false);
      _showErrorSnackBar('Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _saveCity() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRegion == null) {
      _showErrorSnackBar('Please select a region');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cityProvider = ref.read(cityServiceProvider);
      
      final cityData = widget.cityToEdit?.copyWith(
        regionId: _selectedRegion!.id,
        name: _nameController.text,
        description: _descriptionController.text,
        nameAr: _nameArController.text.isEmpty ? null : _nameArController.text,
        nameKu: _nameKuController.text.isEmpty ? null : _nameKuController.text,
        nameBad: _nameBadController.text.isEmpty ? null : _nameBadController.text,
        descriptionAr: _descriptionArController.text.isEmpty ? null : _descriptionArController.text,
        descriptionKu: _descriptionKuController.text.isEmpty ? null : _descriptionKuController.text,
        descriptionBad: _descriptionBadController.text.isEmpty ? null : _descriptionBadController.text,
        thumbnailUrl: _thumbnailUrl,
      ) ?? City.create(
        regionId: _selectedRegion!.id,
        name: _nameController.text,
        description: _descriptionController.text,
        nameAr: _nameArController.text.isEmpty ? null : _nameArController.text,
        nameKu: _nameKuController.text.isEmpty ? null : _nameKuController.text,
        nameBad: _nameBadController.text.isEmpty ? null : _nameBadController.text,
        descriptionAr: _descriptionArController.text.isEmpty ? null : _descriptionArController.text,
        descriptionKu: _descriptionKuController.text.isEmpty ? null : _descriptionKuController.text,
        descriptionBad: _descriptionBadController.text.isEmpty ? null : _descriptionBadController.text,
        thumbnailUrl: _thumbnailUrl,
      );

      if (widget.cityToEdit != null) {
        // Update existing city
        try {
          await SupabaseService.staticClient
              .from('cities')
              .update(cityData.toJson())
              .eq('id', widget.cityToEdit!.id);
          
          print('City updated successfully');
        } catch (e) {
          print('Error updating city: $e');
          throw e;
        }
      } else {
        // Create new city with a generated UUID and current timestamp
        final newCity = City(
          id: const Uuid().v4(),
          regionId: cityData.regionId,
          name: cityData.name,
          description: cityData.description,
          nameAr: cityData.nameAr,
          nameKu: cityData.nameKu,
          nameBad: cityData.nameBad,
          descriptionAr: cityData.descriptionAr,
          descriptionKu: cityData.descriptionKu,
          descriptionBad: cityData.descriptionBad,
          createdAt: DateTime.now().toUtc(),
          thumbnailUrl: cityData.thumbnailUrl,
        );
        
        try {
          await SupabaseService.staticClient
              .from('cities')
              .insert(newCity.toJson());
          
          print('City created successfully');
        } catch (e) {
          print('Error creating city: $e');
          throw e;
        }
      }
      
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('City saved successfully!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to save city: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nameArController.dispose();
    _descriptionArController.dispose();
    _nameKuController.dispose();
    _descriptionKuController.dispose();
    _nameBadController.dispose();
    _descriptionBadController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to build language-specific input fields
  Widget _buildLanguageFields({
    required TextEditingController nameController,
    required TextEditingController descriptionController,
    required String language,
    bool isRequired = false,
    TextDirection? textDirection,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Name ($language)${isRequired ? ' *' : ''}',
              border: const OutlineInputBorder(),
            ),
            textDirection: textDirection,
            validator: isRequired ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            } : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: 'Description ($language)${isRequired ? ' *' : ''}',
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            textDirection: textDirection,
            maxLines: 3,
            validator: isRequired ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            } : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cityToEdit != null ? 'Edit City' : 'Add City'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
            child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                  // Thumbnail Image
        Center(
          child: GestureDetector(
                      onTap: _isUploading ? null : _pickImage,
            child: Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
                        child: _isUploading
                          ? const Center(child: CircularProgressIndicator())
                          : _thumbnailUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _thumbnailUrl!,
                        fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.add_photo_alternate,
                                  size: 50,
                                  color: Colors.grey,
                      ),
                    ),
            ),
          ),
                  const SizedBox(height: 24),
                  
                  // Region Dropdown
                  DropdownButtonFormField<Region>(
                    decoration: const InputDecoration(
                      labelText: 'Region',
                      border: OutlineInputBorder(),
                    ),
                    value: _findRegionInList(_selectedRegion),
                    hint: const Text('Select Region'),
                    items: _regions.map((region) {
                      return DropdownMenuItem(
                        value: region,
                        child: Text(region.name),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                setState(() {
                        _selectedRegion = newValue;
                });
              },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a region';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Language tabs
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'City Details',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Divider(),
                          const SizedBox(height: 16),
                          
                          // Tabbed interface for languages
                          DefaultTabController(
                            length: 4,
                            child: Column(
                              children: [
                                TabBar(
                                  controller: _tabController,
                                  isScrollable: true,
                                  tabs: const [
                                    Tab(text: 'English'),
                                    Tab(text: 'العربية'),
                                    Tab(text: 'کوردی'),
                                    Tab(text: 'بادینی'),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 240,
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      // English fields
                                      _buildLanguageFields(
                                        nameController: _nameController,
                                        descriptionController: _descriptionController,
                                        language: 'English',
                                        isRequired: true,
                                      ),
                                      
                                      // Arabic fields
                                      _buildLanguageFields(
                                        nameController: _nameArController,
                                        descriptionController: _descriptionArController,
                                        language: 'Arabic',
                                        textDirection: TextDirection.rtl,
                                      ),
                                      
                                      // Kurdish fields
                                      _buildLanguageFields(
                                        nameController: _nameKuController,
                                        descriptionController: _descriptionKuController,
                                        language: 'Kurdish',
                                      ),
                                      
                                      // Badinani fields
                                      _buildLanguageFields(
                                        nameController: _nameBadController,
                                        descriptionController: _descriptionBadController,
                                        language: 'Badinani',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveCity,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        widget.cityToEdit != null ? 'Update City' : 'Add City',
                        style: const TextStyle(fontSize: 16),
                      ),
            ),
          ),
      ],
              ),
            ),
          ),
    );
  }

  Region? _findRegionInList(Region? selectedRegion) {
    if (selectedRegion == null || _regions.isEmpty) return null;
    
    // Find the region in our loaded list that matches the ID of the selected region
    try {
      return _regions.firstWhere((region) => region.id == selectedRegion.id);
    } catch (e) {
      // If no match is found, return null so no item is selected
      print('Could not find region with ID: ${selectedRegion.id} in regions list');
      return null;
    }
  }
} 