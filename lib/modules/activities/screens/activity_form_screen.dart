import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/activity.dart';
import '../models/activity_type.dart';
import '../providers/activities_provider.dart';

class ActivityFormScreen extends ConsumerStatefulWidget {
  final String areaId;
  final String areaName;
  final Activity? activity; // If editing an existing activity
  
  const ActivityFormScreen({
    Key? key,
    required this.areaId,
    required this.areaName,
    this.activity,
  }) : super(key: key);

  @override
  ConsumerState<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends ConsumerState<ActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _pricePerPersonController;
  late final TextEditingController _groupPriceController;
  late final TextEditingController _flatRateController;
  late final TextEditingController _discountPercentController;
  late final TextEditingController _capacityController;
  late final TextEditingController _durationMinutesController;
  
  // Add controllers for multilingual fields
  late final TextEditingController _nameArController;
  late final TextEditingController _nameKuController;
  late final TextEditingController _nameBadController;
  late final TextEditingController _descriptionArController;
  late final TextEditingController _descriptionKuController;
  late final TextEditingController _descriptionBadController;
  
  // Form state
  String? _selectedTypeId;
  bool _isActive = true;
  bool _isFeatured = false;
  bool _isNew = true;
  bool _isLoading = false;
  
  // Price type selection
  String _priceType = 'perPerson'; // 'perPerson', 'group', or 'flat'
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data if editing
    final activity = widget.activity;
    
    _nameController = TextEditingController(text: activity?.name ?? '');
    _descriptionController = TextEditingController(text: activity?.description ?? '');
    _pricePerPersonController = TextEditingController(
      text: activity?.pricePerPerson?.toString() ?? '',
    );
    _groupPriceController = TextEditingController(
      text: activity?.groupPrice?.toString() ?? '',
    );
    _flatRateController = TextEditingController(
      text: activity?.flatRate?.toString() ?? '',
    );
    _discountPercentController = TextEditingController(
      text: activity?.discountPercent?.toString() ?? '',
    );
    _capacityController = TextEditingController(
      text: activity?.capacity?.toString() ?? '',
    );
    _durationMinutesController = TextEditingController(
      text: activity?.durationMinutes?.toString() ?? '',
    );
    
    // Initialize multilingual controllers
    _nameArController = TextEditingController(text: activity?.nameAr ?? '');
    _nameKuController = TextEditingController(text: activity?.nameKu ?? '');
    _nameBadController = TextEditingController(text: activity?.nameBad ?? '');
    _descriptionArController = TextEditingController(text: activity?.descriptionAr ?? '');
    _descriptionKuController = TextEditingController(text: activity?.descriptionKu ?? '');
    _descriptionBadController = TextEditingController(text: activity?.descriptionBad ?? '');
    
    // Set price type
    if (activity != null) {
      if (activity.flatRate != null && activity.flatRate! > 0) {
        _priceType = 'flat';
      } else if (activity.groupPrice != null && activity.groupPrice! > 0) {
        _priceType = 'group';
      } else {
        _priceType = 'perPerson';
      }
    }
    
    // Initialize other state
    _selectedTypeId = activity?.typeId;
    _isActive = activity?.isActive ?? true;
    _isFeatured = activity?.isFeatured ?? false;
    _isNew = activity?.isNew ?? true;
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _pricePerPersonController.dispose();
    _groupPriceController.dispose();
    _flatRateController.dispose();
    _discountPercentController.dispose();
    _capacityController.dispose();
    _durationMinutesController.dispose();
    _nameArController.dispose();
    _nameKuController.dispose();
    _nameBadController.dispose();
    _descriptionArController.dispose();
    _descriptionKuController.dispose();
    _descriptionBadController.dispose();
    super.dispose();
  }
  
  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final service = ref.read(activitiesServiceProvider);
      
      // Prepare price data based on selected price type
      double? pricePerPerson;
      double? groupPrice;
      double? flatRate;
      
      switch (_priceType) {
        case 'perPerson':
          if (_pricePerPersonController.text.isNotEmpty) {
            pricePerPerson = double.tryParse(_pricePerPersonController.text);
          }
          break;
        case 'group':
          if (_groupPriceController.text.isNotEmpty) {
            groupPrice = double.tryParse(_groupPriceController.text);
          }
          break;
        case 'flat':
          if (_flatRateController.text.isNotEmpty) {
            flatRate = double.tryParse(_flatRateController.text);
          }
          break;
      }
      
      // Parse discount
      double? discountPercent;
      if (_discountPercentController.text.isNotEmpty) {
        discountPercent = double.tryParse(_discountPercentController.text);
      }
      
      // Parse capacity and duration
      int? capacity;
      int? durationMinutes;
      
      if (_capacityController.text.isNotEmpty) {
        capacity = int.tryParse(_capacityController.text);
      }
      
      if (_durationMinutesController.text.isNotEmpty) {
        durationMinutes = int.tryParse(_durationMinutesController.text);
      }
      
      // Create activity object with multilingual fields
      final activity = widget.activity?.copyWith(
        areaId: widget.areaId,
        typeId: _selectedTypeId,
        name: _nameController.text,
        description: _descriptionController.text,
        nameAr: _nameArController.text.isNotEmpty ? _nameArController.text : null,
        nameKu: _nameKuController.text.isNotEmpty ? _nameKuController.text : null,
        nameBad: _nameBadController.text.isNotEmpty ? _nameBadController.text : null,
        descriptionAr: _descriptionArController.text.isNotEmpty ? _descriptionArController.text : null,
        descriptionKu: _descriptionKuController.text.isNotEmpty ? _descriptionKuController.text : null,
        descriptionBad: _descriptionBadController.text.isNotEmpty ? _descriptionBadController.text : null,
        pricePerPerson: pricePerPerson,
        groupPrice: groupPrice,
        flatRate: flatRate,
        discountPercent: discountPercent,
        capacity: capacity,
        durationMinutes: durationMinutes,
        isActive: _isActive,
        isFeatured: _isFeatured,
        isNew: _isNew,
      ) ?? Activity(
        areaId: widget.areaId,
        typeId: _selectedTypeId,
        name: _nameController.text,
        description: _descriptionController.text,
        nameAr: _nameArController.text.isNotEmpty ? _nameArController.text : null,
        nameKu: _nameKuController.text.isNotEmpty ? _nameKuController.text : null,
        nameBad: _nameBadController.text.isNotEmpty ? _nameBadController.text : null,
        descriptionAr: _descriptionArController.text.isNotEmpty ? _descriptionArController.text : null,
        descriptionKu: _descriptionKuController.text.isNotEmpty ? _descriptionKuController.text : null,
        descriptionBad: _descriptionBadController.text.isNotEmpty ? _descriptionBadController.text : null,
        pricePerPerson: pricePerPerson,
        groupPrice: groupPrice,
        flatRate: flatRate,
        discountPercent: discountPercent,
        capacity: capacity,
        durationMinutes: durationMinutes,
        isActive: _isActive,
        isFeatured: _isFeatured,
        isNew: _isNew,
      );
      
      // Save to database
      Activity? result;
      if (widget.activity != null) {
        result = await service.updateActivity(activity);
      } else {
        result = await service.createActivity(activity);
      }
      
      if (result != null && mounted) {
        Navigator.of(context).pop(true); // Return success
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save activity')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final activityTypesAsync = ref.watch(activityTypesProvider);
    final isEditing = widget.activity != null;
    
    // Add this method to create the multilingual fields section
    Widget _buildMultilingualFields() {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Multilingual Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(),
              const SizedBox(height: 16),
              
              // Tabbed interface for languages
              DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Arabic'),
                        Tab(text: 'Kurdish'),
                        Tab(text: 'Badinani'),
                      ],
                      labelColor: Colors.blue,
                    ),
                    SizedBox(
                      height: 300, // Adjust height as needed
                      child: TabBarView(
                        children: [
                          // Arabic tab
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _nameArController,
                                  decoration: const InputDecoration(
                                    labelText: 'Name (Arabic)',
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
                              ],
                            ),
                          ),
                          
                          // Kurdish tab
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _nameKuController,
                                  decoration: const InputDecoration(
                                    labelText: 'Name (Kurdish)',
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
                              ],
                            ),
                          ),
                          
                          // Badinani tab
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _nameBadController,
                                  decoration: const InputDecoration(
                                    labelText: 'Name (Badinani)',
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
                              ],
                            ),
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
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Activity' : 'Add Activity'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              // Area info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Area',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('Area: ${widget.areaName}'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Basic details card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      // Activity type
                      activityTypesAsync.when(
                        data: (types) {
                          if (types.isEmpty) {
                            return const Text('No activity types available');
                          }
                          
                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Activity Type',
                              border: OutlineInputBorder(),
                            ),
                            value: _selectedTypeId,
                            hint: const Text('Select a type'),
                            items: types.map<DropdownMenuItem<String>>((ActivityType type) {
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
                                return 'Please select an activity type';
                              }
                              return null;
                            },
                          );
                        },
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (error, _) => Text('Error: $error'),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
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
                      
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
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
              ),
              
              // Add after Basic Details card
              const SizedBox(height: 16),
              _buildMultilingualFields(),
              
              const SizedBox(height: 16),
              
              // Price card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pricing',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      // Price type selector
                      const Text(
                        'Price Type:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Per Person'),
                              value: 'perPerson',
                              groupValue: _priceType,
                              onChanged: (value) {
                                setState(() {
                                  _priceType = value!;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Group'),
                              value: 'group',
                              groupValue: _priceType,
                              onChanged: (value) {
                                setState(() {
                                  _priceType = value!;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Flat Rate'),
                              value: 'flat',
                              groupValue: _priceType,
                              onChanged: (value) {
                                setState(() {
                                  _priceType = value!;
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Price per person
                      if (_priceType == 'perPerson')
                        TextFormField(
                          controller: _pricePerPersonController,
                          decoration: const InputDecoration(
                            labelText: 'Price Per Person (\$)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          validator: (value) {
                            if (_priceType == 'perPerson' && (value == null || value.isEmpty)) {
                              return 'Please enter a price per person';
                            }
                            return null;
                          },
                        ),
                      
                      // Group price
                      if (_priceType == 'group')
                        TextFormField(
                          controller: _groupPriceController,
                          decoration: const InputDecoration(
                            labelText: 'Group Price (\$)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          validator: (value) {
                            if (_priceType == 'group' && (value == null || value.isEmpty)) {
                              return 'Please enter a group price';
                            }
                            return null;
                          },
                        ),
                      
                      // Flat rate
                      if (_priceType == 'flat')
                        TextFormField(
                          controller: _flatRateController,
                          decoration: const InputDecoration(
                            labelText: 'Flat Rate (\$)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          validator: (value) {
                            if (_priceType == 'flat' && (value == null || value.isEmpty)) {
                              return 'Please enter a flat rate';
                            }
                            return null;
                          },
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Discount
                      TextFormField(
                        controller: _discountPercentController,
                        decoration: const InputDecoration(
                          labelText: 'Discount (%)',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.percent),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Details card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      // Capacity
                      TextFormField(
                        controller: _capacityController,
                        decoration: const InputDecoration(
                          labelText: 'Capacity (persons)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.people),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Duration
                      TextFormField(
                        controller: _durationMinutesController,
                        decoration: const InputDecoration(
                          labelText: 'Duration (minutes)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.timer),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Status switches
                      SwitchListTile(
                        title: const Text('Active'),
                        subtitle: const Text('This activity is available for booking'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                      
                      SwitchListTile(
                        title: const Text('Featured'),
                        subtitle: const Text('Display this activity as featured'),
                        value: _isFeatured,
                        onChanged: (value) {
                          setState(() {
                            _isFeatured = value;
                          });
                        },
                      ),
                      
                      SwitchListTile(
                        title: const Text('New'),
                        subtitle: const Text('Mark this activity as new'),
                        value: _isNew,
                        onChanged: (value) {
                          setState(() {
                            _isNew = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Save button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveActivity,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading
                    ? 'Saving...'
                    : (isEditing ? 'Update Activity' : 'Create Activity')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              
              const SizedBox(height: 40), // Extra space at bottom
            ],
          ),
        ),
      ),
    );
  }
} 