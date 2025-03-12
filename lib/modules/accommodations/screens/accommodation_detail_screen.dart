import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../models/accommodation.dart';
import '../models/accommodation_image.dart';
import '../providers/accommodations_provider.dart';
import 'accommodation_image_caption_editor.dart';

class AccommodationDetailScreen extends ConsumerStatefulWidget {
  final String accommodationId;
  
  const AccommodationDetailScreen({
    Key? key,
    required this.accommodationId,
  }) : super(key: key);

  @override
  ConsumerState<AccommodationDetailScreen> createState() => _AccommodationDetailScreenState();
}

class _AccommodationDetailScreenState extends ConsumerState<AccommodationDetailScreen> {
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    final accommodationAsync = ref.watch(accommodationProvider(widget.accommodationId));
    final imagesAsync = ref.watch(accommodationImagesProvider(widget.accommodationId));
    
    return Scaffold(
      appBar: AppBar(
        title: accommodationAsync.when(
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Accommodation Details'),
          data: (accommodation) => Text(accommodation?.name ?? 'Accommodation Details'),
        ),
      ),
      body: accommodationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Error: $error',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(accommodationProvider(widget.accommodationId));
                  ref.refresh(accommodationImagesProvider(widget.accommodationId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (accommodation) {
          if (accommodation == null) {
            return const Center(child: Text('Accommodation not found'));
          }
          
          return imagesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading images: $error',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(accommodationImagesProvider(widget.accommodationId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (images) {
              return _buildContent(accommodation, images);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showImageUploadOptions(context),
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
  
  Widget _buildContent(Accommodation accommodation, List<AccommodationImage> images) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Gallery
          _buildGallerySection(images),
          
          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Info
                Text(
                  accommodation.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Type and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      accommodation.typeName ?? 'Unknown Type',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      '\$${accommodation.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                if (accommodation.discountPercent != null && accommodation.discountPercent! > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${accommodation.discountPercent!.toStringAsFixed(0)}% OFF',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const Divider(height: 32),
                
                // Description
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  accommodation.description,
                  style: const TextStyle(fontSize: 16),
                ),
                
                const Divider(height: 32),
                
                // Details
                const Text(
                  'Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Capacity
                _buildDetailRow(
                  icon: Icons.people,
                  label: 'Capacity',
                  value: '${accommodation.capacity} guests',
                ),
                
                // Size
                if (accommodation.sizeSqm != null)
                  _buildDetailRow(
                    icon: Icons.square_foot,
                    label: 'Size',
                    value: '${accommodation.sizeSqm} sqm',
                  ),
                
                // Status
                _buildDetailRow(
                  icon: Icons.check_circle,
                  label: 'Status',
                  value: accommodation.isActive == true ? 'Active' : 'Inactive',
                  valueColor: accommodation.isActive == true ? Colors.green : Colors.red,
                ),
                
                // Featured
                if (accommodation.isFeatured == true)
                  _buildDetailRow(
                    icon: Icons.star,
                    label: 'Featured',
                    value: 'Yes',
                    valueColor: Colors.amber,
                  ),
                
                // New
                if (accommodation.isNew == true)
                  _buildDetailRow(
                    icon: Icons.new_releases,
                    label: 'New',
                    value: 'Yes',
                    valueColor: Colors.green,
                  ),
                
                // Area
                _buildDetailRow(
                  icon: Icons.location_on,
                  label: 'Area',
                  value: accommodation.areaName ?? 'Unknown',
                ),
                
                // Map Coordinates
                if (accommodation.latitude != null && accommodation.longitude != null)
                  _buildDetailRow(
                    icon: Icons.map,
                    label: 'Coordinates',
                    value: '${accommodation.latitude!.toStringAsFixed(6)}, ${accommodation.longitude!.toStringAsFixed(6)}',
                  ),
                
                const Divider(height: 32),
                
                // Amenities Placeholder - to be implemented fully in a future update
                const Text(
                  'Amenities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Amenities details will be implemented in a future update',
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGallerySection(List<AccommodationImage> images) {
    if (images.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No images available'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Add Images'),
                onPressed: () => _showImageUploadOptions(context),
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Featured image
        SizedBox(
          height: 250,
          width: double.infinity,
          child: Stack(
            children: [
              // Primary image
              PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final image = images[index];
                  return Image.network(
                    image.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                        const Center(child: Icon(Icons.image_not_supported, size: 50)),
                  );
                },
              ),
              
              // Primary image indicator
              Positioned(
                top: 16,
                right: 16,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Image ${1} of ${images.length}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Thumbnail images
        SizedBox(
          height: 120,
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            itemBuilder: (context, index) {
              final image = images[index];
              return _buildImageThumbnail(image);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildImageThumbnail(AccommodationImage image) {
    final isPrimary = image.isPrimary;
    
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        border: isPrimary 
            ? Border.all(color: Colors.blue, width: 3) 
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              image.imageUrl,
              fit: BoxFit.cover,
              width: 100,
              height: 100,
              errorBuilder: (context, error, stackTrace) => 
                  const Center(child: Icon(Icons.image_not_supported, size: 30)),
            ),
          ),
          
          // Primary indicator
          if (isPrimary)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          
          // Actions overlay
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  // Show the image fullscreen or actions
                  _showImageOptions(context, image);
                },
                child: Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _pickAndUploadImage({bool isPrimary = false}) async {
    final picker = ImagePicker();
    
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (pickedFile == null) {
        return;
      }
      
      setState(() {
        _isLoading = true;
      });
      
      final service = ref.read(accommodationsServiceProvider);
      
      final image = await service.uploadAccommodationImage(
        accommodationId: widget.accommodationId,
        imageFile: pickedFile,
        isPrimary: isPrimary,
      );
      
      if (image != null) {
        // Refresh the data
        ref.refresh(accommodationProvider(widget.accommodationId));
        ref.refresh(accommodationImagesProvider(widget.accommodationId));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image uploaded successfully')),
          );
        }
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
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _deleteImage(AccommodationImage image) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final service = ref.read(accommodationsServiceProvider);
      
      final success = await service.deleteAccommodationImage(image);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image deleted successfully')),
        );
        
        // Refresh the data
        ref.refresh(accommodationProvider(widget.accommodationId));
        ref.refresh(accommodationImagesProvider(widget.accommodationId));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete image')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting image: $e')),
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
  
  Future<void> _setImageAsPrimary(AccommodationImage image) async {
    if (image.isPrimary) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final service = ref.read(accommodationsServiceProvider);
      
      final success = await service.setImageAsPrimary(image);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Primary image updated successfully')),
        );
        
        // Refresh the data
        ref.refresh(accommodationProvider(widget.accommodationId));
        ref.refresh(accommodationImagesProvider(widget.accommodationId));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update primary image')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating primary image: $e')),
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
  
  void _showImageUploadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Upload Regular Image'),
              onTap: () {
                Navigator.of(context).pop();
                _pickAndUploadImage(isPrimary: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Upload as Primary Image'),
              subtitle: const Text('This will be the main image shown'),
              onTap: () {
                Navigator.of(context).pop();
                _pickAndUploadImage(isPrimary: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.red),
              title: const Text('Upload Video'),
              subtitle: const Text('Add a video for this accommodation'),
              onTap: () {
                Navigator.of(context).pop();
                _pickAndUploadVideo();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showImageOptions(BuildContext context, AccommodationImage image) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Full Image'),
              onTap: () {
                Navigator.of(context).pop();
                _showFullImage(context, image);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Caption'),
              subtitle: const Text('Add or edit captions in multiple languages'),
              onTap: () {
                Navigator.of(context).pop();
                _editImageCaption(context, image);
              },
            ),
            if (!image.isPrimary)
              ListTile(
                leading: const Icon(Icons.star, color: Colors.blue),
                title: const Text('Set as Primary Image'),
                onTap: () {
                  Navigator.of(context).pop();
                  _setImageAsPrimary(image);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Image', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                _confirmDeleteImage(context, image);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showFullImage(BuildContext context, AccommodationImage image) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(image.isPrimary ? 'Primary Image' : 'Image'),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Image.network(
                image.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => 
                    const Center(child: Icon(Icons.image_not_supported, size: 100)),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  void _confirmDeleteImage(BuildContext context, AccommodationImage image) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteImage(image);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editImageCaption(BuildContext context, AccommodationImage image) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AccommodationImageCaptionEditor(image: image),
      ),
    );
  }

  Future<void> _pickAndUploadVideo() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5), // Limit video length
      );
      
      if (pickedFile == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Check file size - limit to 100MB
      final fileSize = await File(pickedFile.path).length();
      final fileSizeMB = fileSize / (1024 * 1024);
      
      if (fileSizeMB > 100) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video is too large. Maximum size is 100MB')),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      final service = ref.read(accommodationsServiceProvider);
      final result = await service.uploadAccommodationVideo(
        widget.accommodationId,
        File(pickedFile.path),
      );
      
      if (result != null) {
        // Force refresh of images
        ref.invalidate(accommodationImagesProvider(widget.accommodationId));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video uploaded successfully')),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload video')),
        );
      }
    } catch (e) {
      debugPrint('❌ Error in _pickAndUploadVideo: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading video: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Widget _buildVideoThumbnail(AccommodationImage video) {
    // Always show the placeholder since we're not generating thumbnails
    return Container(
      color: Colors.black,
      child: const Center(
        child: Icon(Icons.movie, size: 48, color: Colors.white),
      ),
    );
  }
  
  void _playVideo(AccommodationImage video) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _VideoPlayerScreen(videoUrl: video.imageUrl),
      ),
    );
  }

  Widget _buildMediaItem(AccommodationImage media) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Media content (image or video thumbnail)
          media.mediaType == MediaType.video
              ? _buildVideoThumbnail(media)
              : Image.network(
                  media.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                    );
                  },
                ),
          
          // Primary badge
          if (media.isPrimary)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Primary',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            
          // Video indicator
          if (media.mediaType == MediaType.video)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          
          // Actions overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Set as primary button
                  if (!media.isPrimary)
                    IconButton(
                      icon: const Icon(Icons.star_border, color: Colors.white),
                      tooltip: 'Set as primary',
                      onPressed: () => _setAsPrimaryImage(media),
                    ),
                  
                  // View/play button
                  IconButton(
                    icon: Icon(
                      media.mediaType == MediaType.video ? Icons.play_arrow : Icons.visibility,
                      color: Colors.white,
                    ),
                    tooltip: media.mediaType == MediaType.video ? 'Play video' : 'View image',
                    onPressed: () => _viewMedia(media),
                  ),
                  
                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    tooltip: 'Delete',
                    onPressed: () => _confirmDeleteMedia(media),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _viewMedia(AccommodationImage media) {
    if (media.mediaType == MediaType.video) {
      _playVideo(media);
    } else {
      _viewImage(media);
    }
  }

  void _confirmDeleteMedia(AccommodationImage media) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(media.mediaType == MediaType.video ? 'Delete Video' : 'Delete Image'),
        content: Text('Are you sure you want to delete this ${media.mediaType == MediaType.video ? 'video' : 'image'}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteImage(media);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _viewImage(AccommodationImage image) {
    // Show full image view
    _showFullImage(context, image);
  }
}

// Video player screen
class _VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  
  const _VideoPlayerScreen({required this.videoUrl});
  
  @override
  State<_VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<_VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  
  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }
  
  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.network(widget.videoUrl);
    
    try {
      await _controller.initialize();
      _controller.addListener(_videoListener);
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing video player: $e');
    }
  }
  
  void _videoListener() {
    final isPlaying = _controller.value.isPlaying;
    if (isPlaying != _isPlaying) {
      setState(() {
        _isPlaying = isPlaying;
      });
    }
  }
  
  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: Center(
        child: _isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    if (!_isPlaying)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 50,
                          ),
                          onPressed: () {
                            _controller.play();
                          },
                        ),
                      ),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      ),
      bottomNavigationBar: _isInitialized
          ? Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Play/pause button
                  IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    onPressed: () {
                      _isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    },
                  ),
                  
                  // Video progress
                  Expanded(
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                  
                  // Duration text
                  Text(
                    '${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            )
          : null,
    );
  }
  
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
} 