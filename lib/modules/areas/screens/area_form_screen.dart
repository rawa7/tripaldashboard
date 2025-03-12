import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  
  // Controllers for Arabic fields
  final _nameArController = TextEditingController();
  final _descriptionArController = TextEditingController();
  
  // Controllers for Kurdish fields
  final _nameKuController = TextEditingController();
  final _descriptionKuController = TextEditingController();
  
  // Controllers for Badinani fields
  final _nameBadController = TextEditingController();
  final _descriptionBadController = TextEditingController();
  
  String? _selectedSubCityId;
  File? _imageFile;
  bool _isLoading = false;
  bool _isEdit = false;
  List<SubCity> _subCities = [];
  Area? _originalArea;
  
  // Google Maps related fields
  GoogleMapController? _mapController;
  LatLng _selectedLocation = const LatLng(36.1901, 43.9930); // Default to a location in Iraq
  Set<Marker> _markers = {};
  bool _mapInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _isEdit = widget.areaId != null;
    _loadSubCities();
    
    if (_isEdit) {
      _loadAreaData();
    }
    
    // Initialize marker
    _markers = {
      Marker(
        markerId: const MarkerId('selected_location'),
        position: _selectedLocation,
        draggable: true,
        onDragEnd: (LatLng newPosition) {
          setState(() {
            _selectedLocation = newPosition;
          });
        },
      ),
    };
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
    _mapController?.dispose();
    super.dispose();
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
          _nameArController.text = area.nameAr ?? '';
          _descriptionArController.text = area.descriptionAr ?? '';
          _nameKuController.text = area.nameKu ?? '';
          _descriptionKuController.text = area.descriptionKu ?? '';
          _nameBadController.text = area.nameBad ?? '';
          _descriptionBadController.text = area.descriptionBad ?? '';
          _selectedSubCityId = area.subCityId;
          
          // Set location from area data if available
          if (area.latitude != null && area.longitude != null) {
            _selectedLocation = LatLng(area.latitude!, area.longitude!);
            _updateMarker();
          }
          
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
  
  void _updateMarker() {
    _markers = {
      Marker(
        markerId: const MarkerId('selected_location'),
        position: _selectedLocation,
        draggable: true,
        onDragEnd: (LatLng newPosition) {
          setState(() {
            _selectedLocation = newPosition;
          });
        },
      ),
    };
  }
  
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _mapInitialized = true;
    });
  }
  
  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _updateMarker();
    });
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
      debugPrint('🔍 Saving area form...');
      debugPrint('🔍 Is edit mode: $_isEdit');
      debugPrint('🔍 Selected location: ${_selectedLocation.latitude}, ${_selectedLocation.longitude}');
      
      if (_isEdit && _originalArea != null) {
        // Update existing area
        debugPrint('🔍 Updating existing area with ID: ${_originalArea!.id}');
        final updatedArea = _originalArea!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          nameAr: _nameArController.text.trim(),
          descriptionAr: _descriptionArController.text.trim(),
          nameKu: _nameKuController.text.trim(),
          descriptionKu: _descriptionKuController.text.trim(),
          nameBad: _nameBadController.text.trim(),
          descriptionBad: _descriptionBadController.text.trim(),
          subCityId: _selectedSubCityId,
          latitude: _selectedLocation.latitude,
          longitude: _selectedLocation.longitude,
        );
        
        debugPrint('🔍 Updated area data: ${updatedArea.toJson()}');
        final result = await ref.read(areaNotifierProvider.notifier).updateArea(updatedArea);
        
        if (result != null && _imageFile != null) {
          // Upload and set primary image if provided
          debugPrint('🔍 Uploading new primary image for area');
          await ref.read(areaNotifierProvider.notifier).uploadImage(
            result.id!,
            _imageFile!,
            isPrimary: true,
          );
        }
        
        if (result != null && mounted) {
          debugPrint('✅ Area updated successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Area updated successfully')),
          );
          Navigator.of(context).pop();
        } else if (mounted) {
          debugPrint('❌ Failed to update area');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update area')),
          );
        }
      } else {
        // Create new area
        debugPrint('🔍 Creating new area');
        final newArea = Area(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          nameAr: _nameArController.text.trim(),
          descriptionAr: _descriptionArController.text.trim(),
          nameKu: _nameKuController.text.trim(),
          descriptionKu: _descriptionKuController.text.trim(),
          nameBad: _nameBadController.text.trim(),
          descriptionBad: _descriptionBadController.text.trim(),
          subCityId: _selectedSubCityId,
          latitude: _selectedLocation.latitude,
          longitude: _selectedLocation.longitude,
        );
        
        debugPrint('🔍 New area data: ${newArea.toJson()}');
        
        try {
          // Use the areaNotifier for area creation
          final areaNotifier = ref.read(areaNotifierProvider.notifier);
          final result = await areaNotifier.createArea(newArea);
          debugPrint('🔍 Create area result: ${result?.id}');
          
          if (result != null && _imageFile != null) {
            // Upload and set primary image if provided
            debugPrint('🔍 Uploading primary image for new area');
            await areaNotifier.uploadImage(
              result.id!,
              _imageFile!,
              isPrimary: true,
            );
          }
          
          if (result != null && mounted) {
            debugPrint('✅ Area created successfully with ID: ${result.id}');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Area created successfully')),
            );
            Navigator.of(context).pop();
          } else if (mounted) {
            debugPrint('❌ Failed to create area, result was null');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to create area')),
            );
          }
        } catch (innerError, stackTrace) {
          debugPrint('❌ Inner error creating area: $innerError');
          debugPrint('❌ Stack trace: $stackTrace');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error creating area: $innerError')),
            );
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving area: $e');
      debugPrint('❌ Stack trace: $stackTrace');
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
                    // English Section
                    _buildSectionTitle('English Information'),
                    
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Area Name (English)',
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
                        labelText: 'Description (English)',
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
                    
                    // Arabic Section
                    _buildSectionTitle('Arabic Information'),
                    
                    TextFormField(
                      controller: _nameArController,
                      decoration: const InputDecoration(
                        labelText: 'Area Name (Arabic)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _descriptionArController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Arabic)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    
                    // Kurdish Section
                    _buildSectionTitle('Kurdish Information'),
                    
                    TextFormField(
                      controller: _nameKuController,
                      decoration: const InputDecoration(
                        labelText: 'Area Name (Kurdish)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _descriptionKuController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Kurdish)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    
                    // Badinani Section
                    _buildSectionTitle('Badinani Information'),
                    
                    TextFormField(
                      controller: _nameBadController,
                      decoration: const InputDecoration(
                        labelText: 'Area Name (Badinani)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _descriptionBadController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Badinani)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    
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
                    
                    // Location section
                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap on the map to select a location or drag the marker.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    
                    // Google Map for location picking
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: _selectedLocation,
                            zoom: 13,
                          ),
                          markers: _markers,
                          onTap: _onMapTap,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          zoomControlsEnabled: true,
                          mapToolbarEnabled: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Show coordinates
                    Text(
                      'Coordinates: ${_selectedLocation.latitude.toStringAsFixed(6)}, ${_selectedLocation.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 14),
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
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18, 
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
} 