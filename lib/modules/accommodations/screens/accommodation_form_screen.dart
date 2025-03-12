import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/accommodation.dart';
import '../models/accommodation_type.dart';
import '../providers/accommodations_provider.dart';

class AccommodationFormScreen extends ConsumerStatefulWidget {
  final String areaId;
  final String areaName;
  final Accommodation? accommodation;
  
  const AccommodationFormScreen({
    Key? key,
    required this.areaId,
    required this.areaName,
    this.accommodation,
  }) : super(key: key);

  @override
  ConsumerState<AccommodationFormScreen> createState() => _AccommodationFormScreenState();
}

class _AccommodationFormScreenState extends ConsumerState<AccommodationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
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
  late final TextEditingController _sizeSqmController;
  late final TextEditingController _priceController;
  late final TextEditingController _discountPercentController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  
  String? _selectedTypeId;
  bool _isActive = true;
  bool _isFeatured = false;
  bool _isNew = true;
  Map<String, dynamic> _amenities = {};
  
  bool _isSubmitting = false;
  
  // Tab controller for language selection
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize tab controller
    _tabController = TabController(length: 4, vsync: this);
    
    // Initialize form controllers with existing values if editing
    _nameController = TextEditingController(text: widget.accommodation?.name ?? '');
    _descriptionController = TextEditingController(text: widget.accommodation?.description ?? '');
    
    // Initialize multilingual controllers
    _nameArController = TextEditingController(text: widget.accommodation?.nameAr ?? '');
    _nameKuController = TextEditingController(text: widget.accommodation?.nameKu ?? '');
    _nameBadController = TextEditingController(text: widget.accommodation?.nameBad ?? '');
    _descriptionArController = TextEditingController(text: widget.accommodation?.descriptionAr ?? '');
    _descriptionKuController = TextEditingController(text: widget.accommodation?.descriptionKu ?? '');
    _descriptionBadController = TextEditingController(text: widget.accommodation?.descriptionBad ?? '');
    
    // Set initial values for other fields
    _selectedTypeId = widget.accommodation?.typeId;
    _isActive = widget.accommodation?.isActive ?? true;
    _isFeatured = widget.accommodation?.isFeatured ?? false;
    _isNew = widget.accommodation?.isNew ?? true;
    _amenities = widget.accommodation?.amenities ?? {};
    
    // Initialize other controllers
    _capacityController = TextEditingController(
      text: widget.accommodation?.capacity != null 
          ? widget.accommodation!.capacity.toString() 
          : ''
    );
    _sizeSqmController = TextEditingController(
      text: widget.accommodation?.sizeSqm != null 
          ? widget.accommodation!.sizeSqm.toString() 
          : ''
    );
    _priceController = TextEditingController(
      text: widget.accommodation?.price != null 
          ? widget.accommodation!.price.toString() 
          : ''
    );
    _discountPercentController = TextEditingController(
      text: widget.accommodation?.discountPercent != null 
          ? widget.accommodation!.discountPercent.toString() 
          : ''
    );
    _latitudeController = TextEditingController(
      text: widget.accommodation?.latitude != null 
          ? widget.accommodation!.latitude.toString() 
          : ''
    );
    _longitudeController = TextEditingController(
      text: widget.accommodation?.longitude != null 
          ? widget.accommodation!.longitude.toString() 
          : ''
    );
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    // Dispose multilingual controllers
    _nameArController.dispose();
    _nameKuController.dispose();
    _nameBadController.dispose();
    _descriptionArController.dispose();
    _descriptionKuController.dispose();
    _descriptionBadController.dispose();
    // Dispose other controllers
    _capacityController.dispose();
    _sizeSqmController.dispose();
    _priceController.dispose();
    _discountPercentController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.accommodation != null;
    final title = isEditing ? 'Edit Accommodation' : 'Add Accommodation';
    final accommodationTypesAsync = ref.watch(accommodationTypesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: accommodationTypesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error loading accommodation types: $error',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(accommodationTypesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (accommodationTypes) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Area info
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Area',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  widget.areaName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Accommodation Type Dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Accommodation Type *',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedTypeId,
                    items: accommodationTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type.id,
                        child: Text(type.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTypeId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Language Tabs
                  Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'English'),
                            Tab(text: 'Arabic'),
                            Tab(text: 'Kurdish'),
                            Tab(text: 'Badinani'),
                          ],
                        ),
                        SizedBox(
                          height: 240, // Adjust this height as needed
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // English fields
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _nameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Accommodation Name (English) *',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a name';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _descriptionController,
                                      decoration: const InputDecoration(
                                        labelText: 'Description (English) *',
                                        border: OutlineInputBorder(),
                                        alignLabelWithHint: true,
                                      ),
                                      maxLines: 3,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a description';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Arabic fields
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _nameArController,
                                      decoration: const InputDecoration(
                                        labelText: 'Accommodation Name (Arabic)',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _descriptionArController,
                                      decoration: const InputDecoration(
                                        labelText: 'Description (Arabic)',
                                        border: OutlineInputBorder(),
                                        alignLabelWithHint: true,
                                      ),
                                      maxLines: 3,
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Kurdish fields
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _nameKuController,
                                      decoration: const InputDecoration(
                                        labelText: 'Accommodation Name (Kurdish)',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _descriptionKuController,
                                      decoration: const InputDecoration(
                                        labelText: 'Description (Kurdish)',
                                        border: OutlineInputBorder(),
                                        alignLabelWithHint: true,
                                      ),
                                      maxLines: 3,
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Badinani fields
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _nameBadController,
                                      decoration: const InputDecoration(
                                        labelText: 'Accommodation Name (Badinani)',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _descriptionBadController,
                                      decoration: const InputDecoration(
                                        labelText: 'Description (Badinani)',
                                        border: OutlineInputBorder(),
                                        alignLabelWithHint: true,
                                      ),
                                      maxLines: 3,
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
                  
                  // Capacity & Size
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _capacityController,
                          decoration: const InputDecoration(
                            labelText: 'Capacity (guests) *',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            final capacity = int.tryParse(value);
                            if (capacity == null || capacity <= 0) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _sizeSqmController,
                          decoration: const InputDecoration(
                            labelText: 'Size (sqm)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Pricing Section
                  const Text(
                    'Pricing',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Price & Discount
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: 'Price *',
                            border: OutlineInputBorder(),
                            prefixText: '\$',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            final price = double.tryParse(value);
                            if (price == null || price <= 0) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _discountPercentController,
                          decoration: const InputDecoration(
                            labelText: 'Discount %',
                            border: OutlineInputBorder(),
                            suffixText: '%',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Location Section
                  const Text(
                    'Location',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Latitude & Longitude
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latitudeController,
                          decoration: const InputDecoration(
                            labelText: 'Latitude',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^-?\d+\.?\d{0,8}')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _longitudeController,
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^-?\d+\.?\d{0,8}')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Status Section
                  const Text(
                    'Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Status Checkboxes
                  CheckboxListTile(
                    title: const Text('Active'),
                    subtitle: const Text('Accommodation is available for booking'),
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value ?? true;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text('Featured'),
                    subtitle: const Text('Show this as a featured accommodation'),
                    value: _isFeatured,
                    onChanged: (value) {
                      setState(() {
                        _isFeatured = value ?? false;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text('New'),
                    subtitle: const Text('Mark this as a new accommodation'),
                    value: _isNew,
                    onChanged: (value) {
                      setState(() {
                        _isNew = value ?? false;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 32),
                  
                  // Amenities Section - To be implemented later
                  // For now, just a placeholder
                  const Text(
                    'Amenities',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Amenities will be implemented in a future update',
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : () => _submitForm(context),
                      child: _isSubmitting 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(isEditing ? 'Update Accommodation' : 'Create Accommodation'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Future<void> _submitForm(BuildContext context) async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Update UI
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // Build the accommodation object
      final accommodation = Accommodation(
        id: widget.accommodation?.id,
        areaId: widget.areaId,
        typeId: _selectedTypeId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        // Add multilingual fields
        nameAr: _nameArController.text.trim().isNotEmpty ? _nameArController.text.trim() : null,
        nameKu: _nameKuController.text.trim().isNotEmpty ? _nameKuController.text.trim() : null,
        nameBad: _nameBadController.text.trim().isNotEmpty ? _nameBadController.text.trim() : null,
        descriptionAr: _descriptionArController.text.trim().isNotEmpty ? _descriptionArController.text.trim() : null,
        descriptionKu: _descriptionKuController.text.trim().isNotEmpty ? _descriptionKuController.text.trim() : null,
        descriptionBad: _descriptionBadController.text.trim().isNotEmpty ? _descriptionBadController.text.trim() : null,
        // Other fields
        capacity: int.tryParse(_capacityController.text) ?? 0,
        sizeSqm: double.tryParse(_sizeSqmController.text),
        price: double.tryParse(_priceController.text) ?? 0.0,
        discountPercent: double.tryParse(_discountPercentController.text),
        latitude: double.tryParse(_latitudeController.text),
        longitude: double.tryParse(_longitudeController.text),
        isActive: _isActive,
        isFeatured: _isFeatured,
        isNew: _isNew,
        amenities: _amenities,
      );
      
      // Create or update the accommodation
      final isEditing = widget.accommodation != null;
      final service = ref.read(accommodationsServiceProvider);
      Accommodation? result;
      
      if (isEditing) {
        result = await service.updateAccommodation(accommodation);
      } else {
        result = await service.createAccommodation(accommodation);
      }
      
      // Check result
      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${result.name} ${isEditing ? 'updated' : 'created'} successfully')),
        );
        
        // Close the form and return to the list
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to ${isEditing ? 'update' : 'create'} accommodation')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
} 