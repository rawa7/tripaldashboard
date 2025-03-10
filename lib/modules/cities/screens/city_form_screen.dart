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

class _CityFormScreenState extends ConsumerState<CityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
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
    
    // If editing, populate the form
    if (widget.cityToEdit != null) {
      _nameController.text = widget.cityToEdit!.name;
      _descriptionController.text = widget.cityToEdit!.description ?? '';
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
    // Check if form is valid
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      _showErrorSnackBar('Please fill out all required fields correctly');
      return;
    }
    
    if (_selectedRegion == null) {
      _showErrorSnackBar('Please select a region');
      return;
    }
    
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);
      
      final cityData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'region_id': _selectedRegion!.id,
      };
      
      if (_thumbnailUrl != null) {
        cityData['thumbnail_url'] = _thumbnailUrl!;
      }
      
      if (widget.cityToEdit != null) {
        // Update existing city
        try {
          await SupabaseService.staticClient
              .from('cities')
              .update(cityData)
              .eq('id', widget.cityToEdit!.id);
          
          print('City updated successfully');
        } catch (e) {
          print('Error updating city: $e');
          throw e;
        }
      } else {
        // Create new city
        cityData['id'] = const Uuid().v4();
        cityData['created_at'] = DateTime.now().toIso8601String();
        
        try {
          await SupabaseService.staticClient
              .from('cities')
              .insert(cityData);
          
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
    super.dispose();
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
                  
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'City Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a city name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Description Field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  
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