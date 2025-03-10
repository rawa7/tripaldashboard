import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripaldashboard/core/services/supabase_service.dart';
import 'package:tripaldashboard/modules/sub_cities/models/sub_city.dart';
import 'package:tripaldashboard/modules/sub_cities/models/sub_city_image.dart';
import 'package:tripaldashboard/modules/sub_cities/providers/sub_city_provider.dart';
import 'package:tripaldashboard/modules/cities/providers/city_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class SubCityDetailScreen extends ConsumerStatefulWidget {
  final String subCityId;

  const SubCityDetailScreen({
    Key? key,
    required this.subCityId,
  }) : super(key: key);

  @override
  ConsumerState<SubCityDetailScreen> createState() => _SubCityDetailScreenState();
}

class _SubCityDetailScreenState extends ConsumerState<SubCityDetailScreen> {
  bool _isLoading = false;
  
  static const String _bucketName = 'sub_city';
  static const String _directory = 'gallery';

  @override
  Widget build(BuildContext context) {
    final subCityAsync = ref.watch(subCityProvider(widget.subCityId));
    final subCityImagesAsync = ref.watch(subCityImagesProvider(widget.subCityId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sub-City Details'),
      ),
      body: subCityAsync.when(
        data: (subCity) {
          if (subCity == null) {
            return const Center(
              child: Text('Sub-City not found'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSubCityHeader(subCity),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCityInfo(subCity),
                      const SizedBox(height: 16),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subCity.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Photos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildImageGallery(subCityImagesAsync, subCity),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndUploadImage,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildSubCityHeader(SubCity subCity) {
    return Stack(
      children: [
        if (subCity.thumbnailUrl != null)
          Image.network(
            subCity.thumbnailUrl!,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.error, size: 50, color: Colors.red),
                ),
              );
            },
          )
        else
          Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.location_city, size: 50, color: Colors.grey),
            ),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
            child: Text(
              subCity.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCityInfo(SubCity subCity) {
    final cityAsync = ref.watch(cityProvider(subCity.cityId));
    
    return cityAsync.when(
      data: (city) {
        if (city == null) {
          return const Text('City not found');
        }
        return Row(
          children: [
            const Icon(Icons.location_on, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              'City: ${city.name}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error loading city: ${error.toString()}'),
    );
  }

  Widget _buildImageGallery(AsyncValue<List<SubCityImage>> imagesAsync, SubCity subCity) {
    return imagesAsync.when(
      data: (images) {
        if (images.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
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
            return GestureDetector(
              onTap: () => _showImageOptions(image),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      image.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.error, color: Colors.red),
                          ),
                        );
                      },
                    ),
                  ),
                  if (image.isPrimary)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error loading images: ${error.toString()}'),
      ),
    );
  }

  void _showImageOptions(SubCityImage image) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Set as Primary'),
            onTap: () {
              Navigator.pop(context);
              _setPrimaryImage(image);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Image'),
            onTap: () {
              Navigator.pop(context);
              _confirmDeleteImage(image);
            },
          ),
          ListTile(
            leading: const Icon(Icons.fullscreen),
            title: const Text('View Full Size'),
            onTap: () {
              Navigator.pop(context);
              _viewFullImage(image);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _setPrimaryImage(SubCityImage image) async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      await ref.read(subCityServiceProvider).setSubCityImageAsPrimary(
        image.subCityId,
        image.id,
      );
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primary image updated')),
      );
      
      // Refresh the images
      ref.refresh(subCityImagesProvider(widget.subCityId));
      ref.refresh(subCityProvider(widget.subCityId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error setting primary image: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _confirmDeleteImage(SubCityImage image) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteImage(image);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteImage(SubCityImage image) async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      await ref.read(subCityServiceProvider).deleteSubCityImage(image.id);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image deleted successfully')),
      );
      
      // Refresh the images
      ref.refresh(subCityImagesProvider(widget.subCityId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting image: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _viewFullImage(SubCityImage image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Full Image'),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Image.network(
                image.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.error, color: Colors.red, size: 50),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    if (_isLoading) return;
    
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile == null) return;
      
      if (!mounted) return;
      setState(() => _isLoading = true);
      
      // Generate a unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExt = p.extension(pickedFile.path);
      final fileName = '$timestamp$fileExt';
      final filePath = '$_directory/$fileName';
      
      // Upload the file
      final fileBytes = await pickedFile.readAsBytes();
      final response = await SupabaseService.staticClient
          .storage
          .from(_bucketName)
          .uploadBinary(filePath, fileBytes);
      
      if (response.contains('error')) {
        throw Exception('Failed to upload image');
      }
      
      // Get the public URL
      final imageUrl = SupabaseService.staticClient
          .storage
          .from(_bucketName)
          .getPublicUrl(filePath);
      
      // Create a new image record
      final image = SubCityImage.create(
        subCityId: widget.subCityId,
        imageUrl: imageUrl,
        isPrimary: false,
      );
      
      await ref.read(subCityServiceProvider).addSubCityImage(image);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully')),
      );
      
      // Refresh the images
      ref.refresh(subCityImagesProvider(widget.subCityId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
} 