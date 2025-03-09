import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripaldashboard/core/providers/services_provider.dart';
import 'package:tripaldashboard/core/utils/image_utils.dart';
import 'package:tripaldashboard/modules/regions/models/region.dart';
import 'package:tripaldashboard/modules/regions/models/region_image.dart';
import 'package:tripaldashboard/modules/regions/providers/region_provider.dart';
import 'package:tripaldashboard/modules/regions/providers/region_service.dart';

class RegionDetailScreen extends ConsumerStatefulWidget {
  final String regionId;

  const RegionDetailScreen({Key? key, required this.regionId}) : super(key: key);

  @override
  ConsumerState<RegionDetailScreen> createState() => _RegionDetailScreenState();
}

class _RegionDetailScreenState extends ConsumerState<RegionDetailScreen> {
  bool _isLoading = false;
  
  // Constants for storage
  static const String _bucketName = 'region_images';
  static const String _directory = 'gallery';

  @override
  Widget build(BuildContext context) {
    final regionAsync = ref.watch(regionProvider(widget.regionId));
    final regionImagesAsync = ref.watch(regionImagesProvider(widget.regionId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Region Details'),
      ),
      body: regionAsync.when(
        data: (region) {
          if (region == null) {
            return const Center(
              child: Text('Region not found'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRegionHeader(region),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        region.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      _buildImagesSection(regionImagesAsync),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error loading region: ${error.toString()}'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addRegionImage(widget.regionId),
        child: const Icon(Icons.add_photo_alternate),
      ),
    );
  }

  Widget _buildRegionHeader(Region region) {
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
          ),
          child: region.thumbnailUrl != null
              ? Image.network(
                  region.thumbnailUrl!,
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
                      child: Icon(
                        Icons.map,
                        size: 80,
                        color: Colors.grey,
                      ),
                    );
                  },
                )
              : const Center(
                  child: Icon(
                    Icons.map,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
        ),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                region.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Created: ${_formatDate(region.createdAt)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagesSection(AsyncValue<List<RegionImage>> imagesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Images',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => _addRegionImage(widget.regionId),
              icon: const Icon(Icons.add),
              label: const Text('Add Image'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        imagesAsync.when(
          data: (images) {
            if (images.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Text('No images added yet'),
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                return _buildImageItem(image);
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stackTrace) => Center(
            child: Text('Error loading images: ${error.toString()}'),
          ),
        ),
      ],
    );
  }

  Widget _buildImageItem(RegionImage image) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: image.isPrimary ? Colors.blue : Colors.grey[300]!,
              width: image.isPrimary ? 3 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.network(
              image.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
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
                      SizedBox(height: 4),
                      Text('Error', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              if (!image.isPrimary)
                GestureDetector(
                  onTap: () => _setAsPrimaryImage(image),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.star_border,
                      size: 20,
                      color: Colors.blue,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _deleteImage(image),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.delete,
                    size: 20,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
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
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Primary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _addRegionImage(String regionId) async {
    // Prevent multiple calls
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
          // Create a new region image
          final regionImage = RegionImage.create(
            regionId: regionId,
            imageUrl: imageUrl,
            isPrimary: false,
          );
          
          // Get the region service
          final regionService = ref.read(regionServiceProvider);
          
          // Add the image
          await regionService.addRegionImage(regionImage);
          
          // Refresh the images list
          ref.refresh(regionImagesProvider(regionId));
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image added successfully')),
            );
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding image: ${e.toString()}')),
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

  Future<void> _setAsPrimaryImage(RegionImage image) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the region service
      final regionService = ref.read(regionServiceProvider);
      
      // Set the image as primary
      await regionService.setRegionImageAsPrimary(image.regionId, image.id);
      
      // Refresh the images list
      ref.refresh(regionImagesProvider(image.regionId));
      
      // Refresh the region to update the thumbnail
      ref.refresh(regionProvider(image.regionId));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Primary image updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating primary image: ${e.toString()}')),
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

  Future<void> _deleteImage(RegionImage image) async {
    // Show confirmation dialog
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the region service
      final regionService = ref.read(regionServiceProvider);
      
      // Delete the image
      await regionService.deleteRegionImage(image.id);
      
      // Refresh the images list
      ref.refresh(regionImagesProvider(image.regionId));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting image: ${e.toString()}')),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 