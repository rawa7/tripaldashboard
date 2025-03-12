import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/area.dart';
import '../../utils/snackbar_utils.dart';

class AddAreaScreen extends StatefulWidget {
  final String subCityId;
  
  const AddAreaScreen({Key? key, required this.subCityId}) : super(key: key);

  @override
  _AddAreaScreenState createState() => _AddAreaScreenState();
}

class _AddAreaScreenState extends State<AddAreaScreen> {
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
  
  // Controllers for location data
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  
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
  
  Future<void> _addArea() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final supabase = Supabase.instance.client;
      
      await supabase.from('areas').insert({
        'sub_city_id': widget.subCityId,
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'name_ar': _nameArController.text.trim(),
        'description_ar': _descriptionArController.text.trim(),
        'name_ku': _nameKuController.text.trim(),
        'description_ku': _descriptionKuController.text.trim(),
        'name_bad': _nameBadController.text.trim(),
        'description_bad': _descriptionBadController.text.trim(),
        'latitude': double.parse(_latitudeController.text.trim()),
        'longitude': double.parse(_longitudeController.text.trim()),
        'created_at': DateTime.now().toIso8601String(),
      });
      
      if (mounted) {
        showSuccessSnackBar(context, 'Area added successfully!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      showErrorSnackBar(context, 'Error adding area: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Area'),
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
                        onPressed: _isLoading ? null : _addArea,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(_isLoading ? 'Saving...' : 'Save Area'),
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