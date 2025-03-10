import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripaldashboard/modules/areas/models/area.dart';
import 'package:tripaldashboard/modules/areas/models/area_image.dart';
import 'package:tripaldashboard/modules/areas/providers/area_provider.dart';
import 'package:tripaldashboard/modules/areas/screens/area_form_screen.dart';

class AreaDetailScreen extends ConsumerStatefulWidget {
  final String areaId;
  
  const AreaDetailScreen({Key? key, required this.areaId}) : super(key: key);

  @override
  ConsumerState<AreaDetailScreen> createState() => _AreaDetailScreenState();
}

class _AreaDetailScreenState extends ConsumerState<AreaDetailScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  
  Future<void> _pickAndUploadImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _isUploading = true;
      });
      
      try {
        await ref.read(areaNotifierProvider.notifier).uploadImage(
          widget.areaId,
          File(pickedFile.path),
        );
        
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
            _isUploading = false;
          });
        }
      }
    }
  }
  
  void _showDeleteConfirmation(BuildContext context, String imageId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _deleteImage(imageId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteImage(String imageId) async {
    try {
      final result = await ref.read(areaNotifierProvider.notifier).deleteImage(
        widget.areaId,
        imageId,
      );
      
      if (result && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image deleted successfully')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete image')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
  
  Future<void> _setAsPrimaryImage(String imageId) async {
    try {
      final result = await ref.read(areaNotifierProvider.notifier).setImageAsPrimary(
        widget.areaId,
        imageId,
      );
      
      if (result && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Primary image updated successfully')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update primary image')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final areaAsync = ref.watch(areaProvider(widget.areaId));
    final areaImagesAsync = ref.watch(areaImagesProvider(widget.areaId));
    
    return Scaffold(
      appBar: AppBar(
        title: areaAsync.when(
          data: (area) => Text(area?.name ?? 'Area Details'),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Area Details'),
        ),
        actions: [
          areaAsync.when(
            data: (area) => area != null
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AreaFormScreen(areaId: area.id),
                        ),
                      ).then((_) {
                        ref.refresh(areaProvider(widget.areaId));
                      });
                    },
                  )
                : const SizedBox(),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: areaAsync.when(
        data: (area) {
          if (area == null) {
            return const Center(
              child: Text('Area not found'),
            );
          }
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Area details card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (area.thumbnailUrl != null) ...[
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  area.thumbnailUrl!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.image_not_supported,
                                    size: 100,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            area.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sub-City: ${area.subCityName ?? 'N/A'}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Description:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(area.description),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Images section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Images',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isUploading ? null : _pickAndUploadImage,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: _isUploading
                            ? const Text('Uploading...')
                            : const Text('Add Image'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Images grid
                  areaImagesAsync.when(
                    data: (images) {
                      if (images.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('No images found'),
                          ),
                        );
                      }
                      
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          final image = images[index];
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  image.imageUrl,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              if (image.isPrimary)
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Primary',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  color: Colors.black.withOpacity(0.6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (!image.isPrimary)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.star_border,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              _setAsPrimaryImage(image.id!),
                                          tooltip: 'Set as primary',
                                        )
                                      else
                                        const SizedBox(width: 40),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        onPressed: () =>
                                            _showDeleteConfirmation(context, image.id!),
                                        tooltip: 'Delete image',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text('Error loading images: $error'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
} 