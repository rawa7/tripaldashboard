import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripaldashboard/core/providers/services_provider.dart';
import 'package:tripaldashboard/core/utils/image_utils.dart';
import 'package:tripaldashboard/modules/regions/models/region.dart';
import 'package:tripaldashboard/modules/regions/providers/region_provider.dart';

class RegionFormScreen extends ConsumerStatefulWidget {
  final Region? region;

  const RegionFormScreen({Key? key, this.region}) : super(key: key);

  @override
  ConsumerState<RegionFormScreen> createState() => _RegionFormScreenState();
}

class _RegionFormScreenState extends ConsumerState<RegionFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  String? _thumbnailUrl;
  
  // Constants for storage
  static const String _bucketName = 'dev-placeholders';
  static const String _directory = 'thumbnails';

  @override
  void initState() {
    super.initState();
    _thumbnailUrl = widget.region?.thumbnailUrl;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.region != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Region' : 'Add Region'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: FormBuilder(
                key: _formKey,
                initialValue: {
                  'name': widget.region?.name ?? '',
                  'description': widget.region?.description ?? '',
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildThumbnailPicker(),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'name',
                      decoration: const InputDecoration(
                        labelText: 'Region Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.maxLength(100),
                      ]),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'description',
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.maxLength(500),
                      ]),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveRegion,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          isEditing ? 'Update Region' : 'Create Region',
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

  Widget _buildThumbnailPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thumbnail Image',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: _thumbnailUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _thumbnailUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error, color: Colors.red),
                                SizedBox(height: 8),
                                Text('Failed to load image'),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 40),
                          SizedBox(height: 8),
                          Text('Add Thumbnail'),
                        ],
                      ),
                    ),
            ),
          ),
        ),
        if (_thumbnailUrl != null)
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _thumbnailUrl = null;
                });
              },
              child: const Text('Remove Thumbnail'),
            ),
          ),
      ],
    );
  }

  Future<void> _pickImage() async {
    // Prevent multiple calls to image picker
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Show image picker dialog
      final XFile? image = await ImageUtils.showImagePickerDialog(context);
      
      if (image != null && mounted) {
        // Get the storage service
        final storageService = ref.read(storageServiceProvider);
        
        // Upload the image to Supabase storage
        final imageUrl = await ImageUtils.uploadImageToSupabase(
          image: image,
          storageService: storageService,
          bucketName: _bucketName,
          directory: _directory,
        );
        
        if (imageUrl != null && mounted) {
          setState(() {
            _thumbnailUrl = imageUrl;
          });
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: ${e.toString()}')),
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

  Future<void> _saveRegion() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final formData = _formKey.currentState!.value;
        
        if (widget.region != null) {
          // Update existing region
          final updatedRegion = widget.region!.copyWith(
            name: formData['name'],
            description: formData['description'],
            thumbnailUrl: _thumbnailUrl,
          );
          
          await ref.read(regionNotifierProvider.notifier).updateRegion(updatedRegion);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Region updated successfully')),
            );
            Navigator.pop(context, true);
          }
        } else {
          // Create new region
          final newRegion = Region.create(
            name: formData['name'],
            description: formData['description'],
            thumbnailUrl: _thumbnailUrl,
          );
          
          await ref.read(regionNotifierProvider.notifier).createRegion(newRegion);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Region created successfully')),
            );
            Navigator.pop(context, true);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
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
} 