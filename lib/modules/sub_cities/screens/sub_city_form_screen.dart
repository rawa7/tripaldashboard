import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tripaldashboard/core/services/supabase_service.dart';
import 'package:tripaldashboard/modules/sub_cities/models/sub_city.dart';
import 'package:tripaldashboard/modules/sub_cities/providers/sub_city_provider.dart';
import 'package:tripaldashboard/modules/cities/models/city.dart';
import 'package:tripaldashboard/modules/cities/providers/city_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class SubCityFormScreen extends ConsumerStatefulWidget {
  final SubCity? subCityToEdit;
  final String? preselectedCityId;

  const SubCityFormScreen({
    Key? key,
    this.subCityToEdit,
    this.preselectedCityId,
  }) : super(key: key);

  @override
  ConsumerState<SubCityFormScreen> createState() => _SubCityFormScreenState();
}

class _SubCityFormScreenState extends ConsumerState<SubCityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  City? _selectedCity;
  String? _thumbnailUrl;
  bool _isLoading = false;
  bool _isUploading = false;
  List<City> _cities = [];
  
  static const String _bucketName = 'sub_city';
  static const String _directory = 'thumbnails';

  @override
  void initState() {
    super.initState();
    _loadCities();
    
    // If editing, populate the form
    if (widget.subCityToEdit != null) {
      _nameController.text = widget.subCityToEdit!.name;
      _descriptionController.text = widget.subCityToEdit!.description;
      _thumbnailUrl = widget.subCityToEdit!.thumbnailUrl;
      _loadCityForSubCity();
    }
  }

  Future<void> _loadCities() async {
    try {
      setState(() => _isLoading = true);
      final cities = await SupabaseService.staticClient
          .from('cities')
          .select()
          .order('name');
      
      setState(() {
        _cities = cities.map((city) => City.fromJson(city)).toList();
        
        // If a city ID is preselected (e.g., from parent screen)
        if (widget.preselectedCityId != null && _selectedCity == null) {
          final foundCity = _cities.where(
            (city) => city.id == widget.preselectedCityId,
          ).toList();
          
          if (foundCity.isNotEmpty) {
            _selectedCity = foundCity.first;
          }
        }
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load cities: ${e.toString()}');
    }
  }

  Future<void> _loadCityForSubCity() async {
    if (widget.subCityToEdit?.cityId == null) return;
    
    try {
      final data = await SupabaseService.staticClient
          .from('cities')
          .select()
          .eq('id', widget.subCityToEdit!.cityId)
          .single();
      
      if (data != null) {
        setState(() {
          _selectedCity = City.fromJson(data);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load city: ${e.toString()}');
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile == null) return;
      
      if (!mounted) return; // Check if widget is still mounted
      setState(() => _isUploading = true);
      
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

  Future<void> _saveSubCity() async {
    // Check if form is valid
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      _showErrorSnackBar('Please fill out all required fields correctly');
      return;
    }
    
    if (_selectedCity == null) {
      _showErrorSnackBar('Please select a city');
      return;
    }
    
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);
      
      final SubCity subCity;
      
      if (widget.subCityToEdit != null) {
        // Update existing sub_city
        subCity = widget.subCityToEdit!.copyWith(
          cityId: _selectedCity!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          thumbnailUrl: _thumbnailUrl,
        );
        
        await ref.read(subCityNotifierProvider.notifier).updateSubCity(subCity);
        print('Sub-City updated successfully');
      } else {
        // Create new sub_city
        subCity = SubCity.create(
          cityId: _selectedCity!.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          thumbnailUrl: _thumbnailUrl,
        );
        
        await ref.read(subCityNotifierProvider.notifier).createSubCity(subCity);
        print('Sub-City created successfully');
      }
      
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sub-City saved successfully!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to save sub-city: ${e.toString()}');
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
        title: Text(widget.subCityToEdit != null ? 'Edit Sub-City' : 'Add Sub-City'),
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
                    
                    // City Dropdown
                    DropdownButtonFormField<City>(
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                      value: _findCityInList(_selectedCity),
                      hint: const Text('Select City'),
                      items: _cities.map((city) {
                        return DropdownMenuItem(
                          value: city,
                          child: Text(city.name),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCity = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a city';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Sub-City Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a sub-city name';
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveSubCity,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          widget.subCityToEdit != null ? 'Update Sub-City' : 'Add Sub-City',
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
  
  City? _findCityInList(City? selectedCity) {
    if (selectedCity == null || _cities.isEmpty) return null;
    
    // Find the city in our loaded list that matches the ID of the selected city
    try {
      return _cities.firstWhere((city) => city.id == selectedCity.id);
    } catch (e) {
      // If no match is found, return null so no item is selected
      print('Could not find city with ID: ${selectedCity.id} in cities list');
      return null;
    }
  }
} 