import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripaldashboard/modules/areas/models/area.dart';
import 'package:tripaldashboard/modules/areas/models/area_image.dart';
import 'package:tripaldashboard/modules/areas/models/area_video.dart';
import 'package:tripaldashboard/modules/areas/providers/area_provider.dart';
import 'package:tripaldashboard/modules/areas/providers/area_video_provider.dart';
import 'package:tripaldashboard/modules/areas/screens/area_form_screen.dart';
import 'package:tripaldashboard/modules/accommodations/screens/accommodations_simple_screen.dart';
import 'package:tripaldashboard/modules/activities/screens/activities_screen.dart';
import 'package:tripaldashboard/widgets/video_player_widget.dart';
import 'package:tripaldashboard/widgets/video_upload_dialog.dart';

class AreaDetailScreen extends ConsumerStatefulWidget {
  final String areaId;
  
  const AreaDetailScreen({Key? key, required this.areaId}) : super(key: key);

  @override
  ConsumerState<AreaDetailScreen> createState() => _AreaDetailScreenState();
}

class _AreaDetailScreenState extends ConsumerState<AreaDetailScreen> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  late TabController _tabController;
  int _currentVideoIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
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
  
  void _showUploadVideoDialog() {
    showDialog(
      context: context,
      builder: (context) => VideoUploadDialog(
        onUpload: (videoFile, isPrimary, thumbnailFile) async {
          setState(() {
            _isUploading = true;
          });
          
          try {
            await ref.read(areaVideoNotifierProvider(widget.areaId).notifier).uploadVideo(
              videoFile,
              isPrimary: isPrimary,
              thumbnailFile: thumbnailFile,
            );
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Video uploaded successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error uploading video: $e')),
              );
            }
          } finally {
            if (mounted) {
              setState(() {
                _isUploading = false;
              });
            }
          }
        },
      ),
    );
  }
  
  void _showDeleteVideoConfirmation(BuildContext context, String videoId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this video?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _deleteVideo(videoId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteVideo(String videoId) async {
    try {
      final result = await ref.read(areaVideoNotifierProvider(widget.areaId).notifier).deleteVideo(videoId);
      
      if (result && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video deleted successfully')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete video')),
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
  
  Future<void> _setVideoAsPrimary(String videoId) async {
    try {
      final result = await ref.read(areaVideoNotifierProvider(widget.areaId).notifier).setVideoAsPrimary(videoId);
      
      if (result && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Primary video updated successfully')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update primary video')),
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
    final areaVideos = ref.watch(areaVideoNotifierProvider(widget.areaId));
    
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'English'),
            Tab(text: 'Arabic'),
            Tab(text: 'Kurdish'),
            Tab(text: 'Badinani'),
          ],
        ),
      ),
      body: areaAsync.when(
        data: (area) {
          if (area == null) {
            return const Center(
              child: Text('Area not found'),
            );
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              // English Tab
              _buildLanguageTab(
                area: area,
                name: area.name,
                description: area.description,
                areaImagesAsync: areaImagesAsync,
                areaVideosAsync: areaVideos,
                language: 'en',
              ),
              
              // Arabic Tab
              _buildLanguageTab(
                area: area,
                name: area.nameAr ?? 'Not provided',
                description: area.descriptionAr ?? 'Not provided',
                areaImagesAsync: areaImagesAsync,
                areaVideosAsync: areaVideos,
                language: 'ar',
              ),
              
              // Kurdish Tab
              _buildLanguageTab(
                area: area,
                name: area.nameKu ?? 'Not provided',
                description: area.descriptionKu ?? 'Not provided',
                areaImagesAsync: areaImagesAsync,
                areaVideosAsync: areaVideos,
                language: 'ku',
              ),
              
              // Badinani Tab
              _buildLanguageTab(
                area: area,
                name: area.nameBad ?? 'Not provided',
                description: area.descriptionBad ?? 'Not provided',
                areaImagesAsync: areaImagesAsync,
                areaVideosAsync: areaVideos,
                language: 'bad',
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
  
  Widget _buildLanguageTab({
    required Area area,
    required String name,
    required String description,
    required AsyncValue<List<AreaImage>> areaImagesAsync,
    required List<AreaVideo> areaVideosAsync,
    required String language,
  }) {
    return SingleChildScrollView(
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
                    name,
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
                  Text(description),
                  
                  const SizedBox(height: 24),
                  
                  // Buttons to view related entities
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AccommodationsSimpleScreen(
                              areaId: area.id!,
                              areaName: area.name,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.hotel),
                      label: const Text('View Accommodations'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ActivitiesScreen(
                              areaId: area.id!,
                              areaName: area.name,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.hiking),
                      label: const Text('View Activities'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Only show the media section in the English tab
          if (_tabController.index == 0) ...[
            // Videos section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Videos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _showUploadVideoDialog,
                  icon: const Icon(Icons.videocam_outlined),
                  label: _isUploading
                      ? const Text('Uploading...')
                      : const Text('Add Video'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Videos section
            _buildVideoSection(areaVideosAsync, language),
            
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
        ],
      ),
    );
  }
  
  Widget _buildVideoSection(List<AreaVideo> videos, String language) {
    if (videos.isEmpty) {
      return const Center(
        child: Text('No videos available'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final video in videos) ...[
          Stack(
            children: [
              VideoPlayerWidget(
                videoUrl: video.videoUrl,
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    if (!video.isPrimary)
                      IconButton(
                        icon: const Icon(Icons.star_border),
                        onPressed: () => _setVideoAsPrimary(video.id!),
                        tooltip: 'Set as primary',
                        color: Colors.white,
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteVideoConfirmation(context, video.id!),
                      tooltip: 'Delete video',
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
} 