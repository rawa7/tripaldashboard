import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripaldashboard/modules/areas/models/area.dart';
import 'package:tripaldashboard/modules/areas/providers/area_provider.dart';
import 'package:tripaldashboard/modules/sub_cities/models/sub_city.dart';
import 'package:tripaldashboard/modules/sub_cities/providers/sub_city_provider.dart';

class AreaFormScreen extends ConsumerStatefulWidget {
  final String? areaId;
  
  const AreaFormScreen({Key? key, this.areaId}) : super(key: key);

  @override
  ConsumerState<AreaFormScreen> createState() => _AreaFormScreenState();
}

class _AreaFormScreenState extends ConsumerState<AreaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedSubCityId;
  File? _imageFile;
  bool _isLoading = false;
  bool _isEdit = false;
  List<SubCity> _subCities = [];
  Area? _originalArea;
  
  @override
  void initState() {
    super.initState();
    _isEdit = widget.areaId != null;
    _loadSubCities();
    
    if (_isEdit) {
      _loadAreaData();
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _loadSubCities() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final subCities = await ref.read(subCityServiceProvider).getSubCities();
      
      setState(() {
        _subCities = subCities;
        _isLoading = false;
      });
      
      // If there are sub-cities and none is selected, select the first one
      if (_subCities.isNotEmpty && _selectedSubCityId == null) {
        setState(() {
          _selectedSubCityId = _subCities.first.id;
        });
      }
    } catch (e) {
      debugPrint('Error loading sub-cities: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading sub-cities: $e')),
        );
      }
    }
  }
  
  Future<void> _loadAreaData() async {
    if (widget.areaId == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final area = await ref.read(areaServiceProvider).getAreaById(widget.areaId!);
      
      if (area != null) {
        setState(() {
          _originalArea = area;
          _nameController.text = area.name;
          _descriptionController.text = area.description;
          _selectedSubCityId = area.subCityId;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load area data')),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      debugPrint('Error loading area data: $e');
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading area data: $e')),
        );
        Navigator.of(context).pop();
      }
    }
  }
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }
  
  Future<void> _saveArea() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedSubCityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a sub-city')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      if (_isEdit && _originalArea != null) {
        // Update existing area
        final updatedArea = _originalArea!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          subCityId: _selectedSubCityId,
        );
        
        final result = await ref.read(areaNotifierProvider.notifier).updateArea(updatedArea);
        
        if (result != null && _imageFile != null) {
          // Upload and set primary image if provided
          await ref.read(areaNotifierProvider.notifier).uploadImage(
            result.id!,
            _imageFile!,
            isPrimary: true,
          );
        }
        
        if (result != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Area updated successfully')),
          );
          Navigator.of(context).pop();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update area')),
          );
        }
      } else {
        // Create new area
        final newArea = Area(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          subCityId: _selectedSubCityId,
        );
        
        debugPrint('Creating new area: ${newArea.toJson()}');
        
        final result = await ref.read(areaNotifierProvider.notifier).createArea(newArea);
        
        if (result != null && _imageFile != null) {
          // Upload and set primary image if provided
          await ref.read(areaNotifierProvider.notifier).uploadImage(
            result.id!,
            _imageFile!,
            isPrimary: true,
          );
        }
        
        if (result != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Area created successfully')),
          );
          Navigator.of(context).pop();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create area')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving area: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Area' : 'Add Area'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Area Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter area name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Description field
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
                    const SizedBox(height: 16),
                    
                    // SubCity dropdown
                    DropdownButtonFormField<String?>(
                      decoration: const InputDecoration(
                        labelText: 'Sub-City',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedSubCityId,
                      items: _subCities.map((subCity) => DropdownMenuItem<String?>(
                        value: subCity.id,
                        child: Text(subCity.name),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSubCityId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a sub-city';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Image picker
                    Center(
                      child: Column(
                        children: [
                          if (_imageFile != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _imageFile!,
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ] else if (_originalArea?.thumbnailUrl != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _originalArea!.thumbnailUrl!,
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image_not_supported,
                                  size: 100,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo),
                            label: Text(_imageFile != null || _originalArea?.thumbnailUrl != null
                                ? 'Change Image'
                                : 'Add Image'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveArea,
                        child: Text(_isEdit ? 'Update Area' : 'Create Area'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 