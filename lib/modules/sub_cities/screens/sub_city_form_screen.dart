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
import 'package:tripaldashboard/modules/sub_cities/models/sub_city.dart';
import 'package:tripaldashboard/modules/sub_cities/providers/sub_city_provider.dart';
import 'package:tripaldashboard/core/services/supabase_service.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class SubCityFormScreen extends ConsumerStatefulWidget {
  final SubCity? subCityToEdit;

  const SubCityFormScreen({Key? key, this.subCityToEdit}) : super(key: key);

  @override
  ConsumerState<SubCityFormScreen> createState() => _SubCityFormScreenState();
}

class _SubCityFormScreenState extends ConsumerState<SubCityFormScreen> with SingleTickerProviderStateMixin {
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
  
  City? _selectedCity;
  String? _thumbnailUrl;
  bool _isLoading = false;
  bool _isUploading = false;
  List<City> _cities = [];
  
  static const String _bucketName = 'sub_city_images';
  static const String _directory = 'thumbnails';

  @override
  void initState() {
    super.initState();
    _loadCities();
    
    // Initialize tab controller
    _tabController = TabController(length: 4, vsync: this);
    
    // If editing, populate the form
    if (widget.subCityToEdit != null) {
      // English fields
      _nameController.text = widget.subCityToEdit!.name;
      _descriptionController.text = widget.subCityToEdit!.description ?? '';
      
      // Arabic fields
      _nameArController.text = widget.subCityToEdit!.nameAr ?? '';
      _descriptionArController.text = widget.subCityToEdit!.descriptionAr ?? '';
      
      // Kurdish fields
      _nameKuController.text = widget.subCityToEdit!.nameKu ?? '';
      _descriptionKuController.text = widget.subCityToEdit!.descriptionKu ?? '';
      
      // Badinani fields
      _nameBadController.text = widget.subCityToEdit!.nameBad ?? '';
      _descriptionBadController.text = widget.subCityToEdit!.descriptionBad ?? '';
      
      _thumbnailUrl = widget.subCityToEdit!.thumbnailUrl;
      _loadCityForSubCity();
    }
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

  Future<void> _loadCities() async {
    try {
      setState(() => _isLoading = true);
      final cities = await SupabaseService.staticClient
          .from('cities')
          .select()
          .order('name');
      
      setState(() {
        _cities = cities.map((city) => City.fromJson(city)).toList();
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

  Future<void> _saveSubCity() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCity == null) {
      _showErrorSnackBar('Please select a city');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final subCityProvider = ref.read(subCityServiceProvider);
      
      final subCityData = widget.subCityToEdit?.copyWith(
        cityId: _selectedCity!.id,
        name: _nameController.text,
        description: _descriptionController.text,
        nameAr: _nameArController.text.isEmpty ? null : _nameArController.text,
        nameKu: _nameKuController.text.isEmpty ? null : _nameKuController.text,
        nameBad: _nameBadController.text.isEmpty ? null : _nameBadController.text,
        descriptionAr: _descriptionArController.text.isEmpty ? null : _descriptionArController.text,
        descriptionKu: _descriptionKuController.text.isEmpty ? null : _descriptionKuController.text,
        descriptionBad: _descriptionBadController.text.isEmpty ? null : _descriptionBadController.text,
        thumbnailUrl: _thumbnailUrl,
      ) ?? SubCity.create(
        cityId: _selectedCity!.id,
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

      if (widget.subCityToEdit != null) {
        // Update existing sub_city
        try {
          await SupabaseService.staticClient
              .from('sub_cities')
              .update(subCityData.toJson())
              .eq('id', widget.subCityToEdit!.id);
          
          print('SubCity updated successfully');
          
          if (!mounted) return;
          Navigator.pop(context, true);
        } catch (e) {
          print('Error updating SubCity: $e');
          if (!mounted) return;
          _showErrorSnackBar('Failed to update sub-city: ${e.toString()}');
        }
      } else {
        // Create new sub_city
        try {
          await SupabaseService.staticClient
              .from('sub_cities')
              .insert(subCityData.toJson());
          
          print('SubCity created successfully');
          
          if (!mounted) return;
          Navigator.pop(context, true);
        } catch (e) {
          print('Error creating SubCity: $e');
          if (!mounted) return;
          _showErrorSnackBar('Failed to create sub-city: ${e.toString()}');
        }
      }
    } catch (e) {
      print('Error in _saveSubCity: $e');
      if (!mounted) return;
      _showErrorSnackBar('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
        title: Text(widget.subCityToEdit == null ? 'Add Sub-City' : 'Edit Sub-City'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // City Dropdown
                    FormBuilderDropdown<City>(
                      name: 'city',
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                      items: _cities.map((city) => DropdownMenuItem(
                        value: city,
                        child: Text(city.name),
                      )).toList(),
                      validator: FormBuilderValidators.required(),
                      onChanged: (city) {
                        setState(() {
                          _selectedCity = city;
                        });
                      },
                      initialValue: _selectedCity,
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
                              'Sub-City Details',
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
                    
                    const SizedBox(height: 16),
                    
                    // Image Upload Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thumbnail Image',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const Divider(),
                            const SizedBox(height: 16),
                            
                            // Image preview
                            if (_thumbnailUrl != null) ...[
                              SizedBox(
                                height: 200,
                                width: double.infinity,
                                child: Image.network(
                                  _thumbnailUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => 
                                      const Center(child: Icon(Icons.image_not_supported, size: 50)),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            
                            // Upload button
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: _isUploading ? null : _pickImage,
                                icon: const Icon(Icons.upload),
                                label: Text(_isUploading ? 'Uploading...' : 'Upload Image'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading || _isUploading ? null : _saveSubCity,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            widget.subCityToEdit == null ? 'Create Sub-City' : 'Update Sub-City',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile == null) return;
      
      if (!mounted) return; // Check if widget is still mounted
      setState(() => _isUploading = true);
      
      // Upload image
      final file = await pickedFile.readAsBytes();
      final fileExt = p.extension(pickedFile.path);
      final fileName = '${const Uuid().v4()}$fileExt';
      final filePath = '$_directory/$fileName';
      
      try {
        await SupabaseService.staticClient
            .storage
            .from(_bucketName)
            .uploadBinary(filePath, file);
        
        // Get public URL
        final imageUrlResponse = SupabaseService.staticClient
            .storage
            .from(_bucketName)
            .getPublicUrl(filePath);
        
        if (!mounted) return;
        setState(() {
          _thumbnailUrl = imageUrlResponse;
          _isUploading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() => _isUploading = false);
        _showErrorSnackBar('Failed to upload image: ${e.toString()}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      _showErrorSnackBar('Error picking image: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
} 