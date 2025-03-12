import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/area.dart';
import '../../utils/snackbar_utils.dart';

class EditAreaScreen extends StatefulWidget {
  final String areaId;
  
  const EditAreaScreen({Key? key, required this.areaId}) : super(key: key);

  @override
  _EditAreaScreenState createState() => _EditAreaScreenState();
}

class _EditAreaScreenState extends State<EditAreaScreen> {
  // Controllers for English fields
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
  
  // Controllers for location
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();
  String? _subCityId;
  
  @override
  void initState() {
    super.initState();
    _loadAreaData();
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
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }
  
  Future<void> _loadAreaData() async {
    try {
      final supabase = Supabase.instance.client;
      
      final response = await supabase
          .from('areas')
          .select()
          .eq('id', widget.areaId)
          .single();
      
      if (mounted) {
        setState(() {
          _nameController.text = response['name'] ?? '';
          _descriptionController.text = response['description'] ?? '';
          _nameArController.text = response['name_ar'] ?? '';
          _descriptionArController.text = response['description_ar'] ?? '';
          _nameKuController.text = response['name_ku'] ?? '';
          _descriptionKuController.text = response['description_ku'] ?? '';
          _nameBadController.text = response['name_bad'] ?? '';
          _descriptionBadController.text = response['description_bad'] ?? '';
          _latitudeController.text = response['latitude']?.toString() ?? '';
          _longitudeController.text = response['longitude']?.toString() ?? '';
          _subCityId = response['sub_city_id'];
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
  
  Future<void> _updateArea() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      final supabase = Supabase.instance.client;
      
      await supabase.from('areas').update({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'name_ar': _nameArController.text.trim(),
        'description_ar': _descriptionArController.text.trim(),
        'name_ku': _nameKuController.text.trim(),
        'description_ku': _descriptionKuController.text.trim(),
        'name_bad': _nameBadController.text.trim(),
        'description_bad': _descriptionBadController.text.trim(),
        'latitude': double.tryParse(_latitudeController.text.trim()),
        'longitude': double.tryParse(_longitudeController.text.trim()),
      }).eq('id', widget.areaId);
      
      if (mounted) {
        showSuccessSnackBar(context, 'Area updated successfully!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      showErrorSnackBar(context, 'Error updating area: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Area'),
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
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name (English)',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter area name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (English)',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    
                    // Arabic Section
                    _buildSectionTitle('Arabic Information'),
                    TextFormField(
                      controller: _nameArController,
                      decoration: const InputDecoration(
                        labelText: 'Name (Arabic)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionArController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Arabic)',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    
                    // Kurdish Section
                    _buildSectionTitle('Kurdish Information'),
                    TextFormField(
                      controller: _nameKuController,
                      decoration: const InputDecoration(
                        labelText: 'Name (Kurdish)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionKuController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Kurdish)',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    
                    // Badinani Section
                    _buildSectionTitle('Badinani Information'),
                    TextFormField(
                      controller: _nameBadController,
                      decoration: const InputDecoration(
                        labelText: 'Name (Badinani)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionBadController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Badinani)',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    
                    // Location Section
                    _buildSectionTitle('Location Information'),
                    TextFormField(
                      controller: _latitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter latitude';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _longitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter longitude';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _updateArea,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(_isSaving ? 'Saving...' : 'Update Area'),
                        ),
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