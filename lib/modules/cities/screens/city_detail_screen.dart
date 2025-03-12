import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripaldashboard/core/providers/services_provider.dart';
import 'package:tripaldashboard/core/utils/image_utils.dart';
import 'package:tripaldashboard/modules/cities/models/city.dart';
import 'package:tripaldashboard/modules/cities/models/city_image.dart';
import 'package:tripaldashboard/modules/cities/providers/city_provider.dart';
import 'package:tripaldashboard/modules/regions/providers/region_provider.dart';

class CityDetailScreen extends ConsumerStatefulWidget {
  final String cityId;

  const CityDetailScreen({Key? key, required this.cityId}) : super(key: key);

  @override
  ConsumerState<CityDetailScreen> createState() => _CityDetailScreenState();
}

class _CityDetailScreenState extends ConsumerState<CityDetailScreen> {
  bool _isLoading = false;
  
  // Constants for storage
  static const String _bucketName = 'city_images';
  static const String _directory = 'gallery';

  @override
  Widget build(BuildContext context) {
    final cityAsync = ref.watch(cityProvider(widget.cityId));
    final cityImagesAsync = ref.watch(cityImagesProvider(widget.cityId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('City Details'),
      ),
      body: cityAsync.when(
        data: (city) {
          if (city == null) {
            return const Center(
              child: Text('City not found'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCityHeader(city),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRegionInfo(city),
                      const SizedBox(height: 16),
                      _buildDetailsSection(),
                      const SizedBox(height: 24),
                      const Text(
                        'Photos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildImageGallery(cityImagesAsync, city),
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

  Widget _buildCityHeader(City city) {
    return Stack(
      children: [
        if (city.thumbnailUrl != null)
          Image.network(
            city.thumbnailUrl!,
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
              city.name,
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

  Widget _buildRegionInfo(City city) {
    final regionAsync = ref.watch(regionProvider(city.regionId));
    
    return regionAsync.when(
      data: (region) {
        if (region == null) {
          return const Text('Region not found');
        }
        return Row(
          children: [
            const Icon(Icons.location_on, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              'Region: ${region.name}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Error loading region: ${error.toString()}'),
    );
  }

  Widget _buildDetailsSection() {
    final cityAsync = ref.watch(cityProvider(widget.cityId));
    
    return cityAsync.when(
      data: (city) {
        if (city == null) {
          return const Center(child: Text('City not found'));
        }
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'City Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(),
                const SizedBox(height: 16),
                
                // Language tabbed view
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
                        height: 200,
                        child: TabBarView(
                          children: [
                            // English content
                            _buildLanguageContent(
                              name: city.name,
                              description: city.description,
                            ),
                            
                            // Arabic content
                            _buildLanguageContent(
                              name: city.nameAr ?? 'Not available',
                              description: city.descriptionAr ?? 'Not available',
                              textDirection: TextDirection.rtl,
                            ),
                            
                            // Kurdish content
                            _buildLanguageContent(
                              name: city.nameKu ?? 'Not available',
                              description: city.descriptionKu ?? 'Not available',
                            ),
                            
                            // Badinani content
                            _buildLanguageContent(
                              name: city.nameBad ?? 'Not available',
                              description: city.descriptionBad ?? 'Not available',
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: ${error.toString()}')),
    );
  }

  Widget _buildLanguageContent({
    required String name,
    required String description,
    TextDirection? textDirection,
  }) {
    return Directionality(
      textDirection: textDirection ?? TextDirection.ltr,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Name: ',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Description: ',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(AsyncValue<List<CityImage>> imagesAsync, City city) {
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

  void _showImageOptions(CityImage image) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Set as primary'),
            onTap: () async {
              Navigator.pop(context);
              setState(() {
                _isLoading = true;
              });
              try {
                final cityService = ref.read(cityServiceProvider);
                await cityService.setCityImageAsPrimary(widget.cityId, image.id);
                ref.refresh(cityImagesProvider(widget.cityId));
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
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete image'),
            onTap: () async {
              Navigator.pop(context);
              final confirmed = await _confirmDeleteImage();
              if (confirmed) {
                setState(() {
                  _isLoading = true;
                });
                try {
                  final cityService = ref.read(cityServiceProvider);
                  await cityService.deleteCityImage(image.id);
                  ref.refresh(cityImagesProvider(widget.cityId));
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
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDeleteImage() async {
    return await showDialog<bool>(
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
    ) ?? false;
  }

  Future<void> _pickAndUploadImage() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final XFile? image = await ImageUtils.showImagePickerDialog(context);
      
      if (image != null && mounted) {
        final storageService = ref.read(storageServiceProvider);
        
        final imageUrl = await ImageUtils.uploadImageToSupabase(
          image: image,
          storageService: storageService,
          bucketName: _bucketName,
          directory: _directory,
        );
        
        if (imageUrl != null && mounted) {
          final cityService = ref.read(cityServiceProvider);
          final cityImage = CityImage.create(
            cityId: widget.cityId,
            imageUrl: imageUrl,
            isPrimary: false,
          );
          
          await cityService.addCityImage(cityImage);
          ref.refresh(cityImagesProvider(widget.cityId));
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image uploaded successfully')),
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