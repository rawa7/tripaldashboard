import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/accommodation.dart';
import '../models/accommodation_type.dart';
import '../providers/accommodations_provider_simple.dart';

class AccommodationSimpleFormScreen extends ConsumerStatefulWidget {
  final String areaId;
  final String areaName;
  final Accommodation? accommodation; // If editing existing accommodation
  
  const AccommodationSimpleFormScreen({
    Key? key,
    required this.areaId,
    required this.areaName,
    this.accommodation,
  }) : super(key: key);

  @override
  ConsumerState<AccommodationSimpleFormScreen> createState() => _AccommodationSimpleFormScreenState();
}

class _AccommodationSimpleFormScreenState extends ConsumerState<AccommodationSimpleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // Form controllers
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  // Multilingual controllers
  late final TextEditingController _nameArController;
  late final TextEditingController _nameKuController;
  late final TextEditingController _nameBadController;
  late final TextEditingController _descriptionArController;
  late final TextEditingController _descriptionKuController;
  late final TextEditingController _descriptionBadController;
  // Other controllers
  late final TextEditingController _capacityController;
  late final TextEditingController _priceController;
  
  // Accommodation type selection
  String? _selectedTypeId;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data if editing
    _nameController = TextEditingController(text: widget.accommodation?.name ?? '');
    _descriptionController = TextEditingController(text: widget.accommodation?.description ?? '');
    
    // Initialize multilingual controllers
    _nameArController = TextEditingController(text: widget.accommodation?.nameAr ?? '');
    _nameKuController = TextEditingController(text: widget.accommodation?.nameKu ?? '');
    _nameBadController = TextEditingController(text: widget.accommodation?.nameBad ?? '');
    _descriptionArController = TextEditingController(text: widget.accommodation?.descriptionAr ?? '');
    _descriptionKuController = TextEditingController(text: widget.accommodation?.descriptionKu ?? '');
    _descriptionBadController = TextEditingController(text: widget.accommodation?.descriptionBad ?? '');
    
    _capacityController = TextEditingController(text: widget.accommodation?.capacity.toString() ?? '');
    _priceController = TextEditingController(text: widget.accommodation?.price.toString() ?? '');
    
    // Initialize selected type
    _selectedTypeId = widget.accommodation?.typeId;
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _nameArController.dispose();
    _nameKuController.dispose();
    _nameBadController.dispose();
    _descriptionArController.dispose();
    _descriptionKuController.dispose();
    _descriptionBadController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    super.dispose();
  }
  
  Future<void> _saveAccommodation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final accommodationService = ref.read(accommodationsSimpleServiceProvider);
      
      // Create accommodation data from form
      final accommodation = widget.accommodation?.copyWith(
        areaId: widget.areaId,
        typeId: _selectedTypeId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        nameAr: _nameArController.text.trim().isNotEmpty ? _nameArController.text.trim() : null,
        nameKu: _nameKuController.text.trim().isNotEmpty ? _nameKuController.text.trim() : null,
        nameBad: _nameBadController.text.trim().isNotEmpty ? _nameBadController.text.trim() : null,
        descriptionAr: _descriptionArController.text.trim().isNotEmpty ? _descriptionArController.text.trim() : null,
        descriptionKu: _descriptionKuController.text.trim().isNotEmpty ? _descriptionKuController.text.trim() : null,
        descriptionBad: _descriptionBadController.text.trim().isNotEmpty ? _descriptionBadController.text.trim() : null,
        capacity: int.parse(_capacityController.text),
        price: double.parse(_priceController.text),
      ) ?? Accommodation(
        areaId: widget.areaId,
        typeId: _selectedTypeId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        nameAr: _nameArController.text.trim().isNotEmpty ? _nameArController.text.trim() : null,
        nameKu: _nameKuController.text.trim().isNotEmpty ? _nameKuController.text.trim() : null,
        nameBad: _nameBadController.text.trim().isNotEmpty ? _nameBadController.text.trim() : null,
        descriptionAr: _descriptionArController.text.trim().isNotEmpty ? _descriptionArController.text.trim() : null,
        descriptionKu: _descriptionKuController.text.trim().isNotEmpty ? _descriptionKuController.text.trim() : null,
        descriptionBad: _descriptionBadController.text.trim().isNotEmpty ? _descriptionBadController.text.trim() : null,
        capacity: int.parse(_capacityController.text),
        price: double.parse(_priceController.text),
      );
      
      // Create or update accommodation
      Accommodation? result;
      if (widget.accommodation != null) {
        result = await accommodationService.updateAccommodation(accommodation);
      } else {
        result = await accommodationService.createAccommodation(accommodation);
      }
      
      if (result != null && mounted) {
        Navigator.of(context).pop(true); // Return success
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save accommodation')),
        );
      }
    } catch (e) {
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
    final accommodationTypesAsync = ref.watch(accommodationTypesSimpleProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.accommodation != null ? 'Edit Accommodation' : 'Add Accommodation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Area info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Area Information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('Area: ${widget.areaName}'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Basic details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      // Accommodation type
                      accommodationTypesAsync.when(
                        data: (types) {
                          if (types.isEmpty) {
                            return const Text('No accommodation types found');
                          }
                          
                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Accommodation Type',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedTypeId,
                            onChanged: (value) {
                              setState(() {
                                _selectedTypeId = value;
                              });
                            },
                            items: types.map<DropdownMenuItem<String>>((AccommodationType type) {
                              return DropdownMenuItem<String>(
                                value: type.id,
                                child: Text(type.name),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select an accommodation type';
                              }
                              return null;
                            },
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (error, _) => Text('Error loading types: $error'),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Language Tabs
                      DefaultTabController(
                        length: 4,
                        child: Column(
                          children: [
                            TabBar(
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
              
              const SizedBox(height: 16),
              
              // Capacity and price
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Capacity & Price',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      // Capacity field
                      TextFormField(
                        controller: _capacityController,
                        decoration: const InputDecoration(
                          labelText: 'Capacity (persons)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter capacity';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Price field
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price (\$)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a price';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Media Upload
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Media Upload',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              IconButton.filled(
                                onPressed: _isLoading ? null : _pickAndUploadImage,
                                icon: const Icon(Icons.image),
                                iconSize: 32,
                              ),
                              const SizedBox(height: 8),
                              const Text('Upload Image'),
                            ],
                          ),
                          Column(
                            children: [
                              IconButton.filled(
                                onPressed: _isLoading ? null : _pickAndUploadVideo,
                                icon: const Icon(Icons.videocam, color: Colors.red),
                                iconSize: 32,
                              ),
                              const SizedBox(height: 8),
                              const Text('Upload Video'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Save button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveAccommodation,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading
                    ? 'Saving...'
                    : (widget.accommodation != null ? 'Update' : 'Create')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile == null || !mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final accommodationService = ref.read(accommodationsSimpleServiceProvider);
      final file = File(pickedFile.path);
      
      if (widget.accommodation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please save the accommodation first before uploading images')),
        );
        return;
      }
      
      await accommodationService.uploadAccommodationImage(widget.accommodation!.id!, file);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
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
  
  Future<void> _pickAndUploadVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5),
    );
    
    if (pickedFile == null || !mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final file = File(pickedFile.path);
      
      // Check file size (max 100MB)
      final fileSize = await file.length();
      if (fileSize > 100 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video size must be less than 100MB')),
          );
        }
        return;
      }
      
      if (widget.accommodation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please save the accommodation first before uploading videos')),
        );
        return;
      }
      
      final accommodationService = ref.read(accommodationsSimpleServiceProvider);
      await accommodationService.uploadAccommodationVideo(widget.accommodation!.id!, file);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video uploaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading video: $e')),
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
} 