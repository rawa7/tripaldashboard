import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import '../models/accommodation.dart';
import '../models/accommodation_image.dart';
import '../providers/accommodations_provider_simple.dart';
import 'accommodation_simple_form_screen.dart';
import 'accommodation_image_viewer.dart';
import 'accommodation_image_caption_editor.dart';
import '../providers/availability_provider.dart';
import 'availability_list_screen.dart';

class AccommodationSimpleDetailScreen extends ConsumerStatefulWidget {
  final String accommodationId;
  
  const AccommodationSimpleDetailScreen({
    Key? key,
    required this.accommodationId,
  }) : super(key: key);

  @override
  ConsumerState<AccommodationSimpleDetailScreen> createState() => _AccommodationSimpleDetailScreenState();
}

class _AccommodationSimpleDetailScreenState extends ConsumerState<AccommodationSimpleDetailScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  
  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    
    if (pickedFile == null) return;
    
    final file = File(pickedFile.path);
    setState(() {
      _isUploading = true;
    });
    
    try {
      await ref.read(accommodationsSimpleServiceProvider).uploadAccommodationImage(
        widget.accommodationId,
        file
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully')),
        );
        // Refresh the accommodation data and images
        ref.refresh(accommodationSimpleProvider(widget.accommodationId));
        ref.refresh(accommodationImagesSimpleProvider(widget.accommodationId));
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
  
  Future<void> _pickAndUploadVideo() async {
    final pickedFile = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5),
    );
    
    if (pickedFile == null) return;
    
    final file = File(pickedFile.path);
    setState(() {
      _isUploading = true;
    });
    
    try {
      // Check file size (max 100MB)
      final fileSize = await file.length();
      if (fileSize > 100 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video size must be less than 100MB')),
          );
        }
        setState(() {
          _isUploading = false;
        });
        return;
      }
      
      await ref.read(accommodationsSimpleServiceProvider).uploadAccommodationVideo(
        widget.accommodationId,
        file
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video uploaded successfully')),
        );
        // Refresh the accommodation data and images
        ref.refresh(accommodationSimpleProvider(widget.accommodationId));
        ref.refresh(accommodationImagesSimpleProvider(widget.accommodationId));
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
  }
  
  Future<void> _pickAndUploadVideoWithThumbnail() async {
    // First pick a video
    final videoFile = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5),
    );
    
    if (videoFile == null || !mounted) return;
    
    // Then pick a thumbnail image
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    
    if (pickedFile == null || !mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thumbnail selection canceled. Video upload aborted.')),
      );
      return;
    }
    
    setState(() {
      _isUploading = true;
    });
    
    try {
      final videoFileObj = File(videoFile.path);
      final thumbnailFileObj = File(pickedFile.path);
      
      // Check file size (max 100MB)
      final fileSize = await videoFileObj.length();
      if (fileSize > 100 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video size must be less than 100MB')),
          );
        }
        setState(() {
          _isUploading = false;
        });
        return;
      }
      
      // Upload both video and thumbnail
      final result = await ref.read(accommodationsSimpleServiceProvider).uploadAccommodationVideoWithThumbnail(
        widget.accommodationId,
        videoFileObj,
        thumbnailFileObj,
      );
      
      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video uploaded with custom thumbnail')),
        );
        // Refresh the accommodation data and images
        ref.refresh(accommodationSimpleProvider(widget.accommodationId));
        ref.refresh(accommodationImagesSimpleProvider(widget.accommodationId));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload video with thumbnail')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading: $e')),
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
  
  Future<void> _pickAndUploadVideoThumbnail(AccommodationImage videoItem) async {
    // Only allow thumbnail uploads for videos
    if (videoItem.mediaType != MediaType.video) return;
    
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    
    if (pickedFile == null || !mounted) return;
    
    setState(() {
      _isUploading = true;
    });
    
    try {
      final file = File(pickedFile.path);
      
      // Upload the thumbnail for the video
      final success = await ref.read(accommodationsSimpleServiceProvider).uploadVideoThumbnail(
        widget.accommodationId,
        videoItem.requireId,
        file,
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thumbnail updated successfully')),
        );
        // Refresh the images
        ref.refresh(accommodationImagesSimpleProvider(widget.accommodationId));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update thumbnail')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating thumbnail: $e')),
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
  
  Future<void> _setImageAsPrimary(AccommodationImage image) async {
    if (image.isPrimary) return;
    
    try {
      final success = await ref.read(accommodationsSimpleServiceProvider).setImageAsPrimary(image);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Set as primary image')),
        );
        // Refresh providers to update UI
        ref.refresh(accommodationSimpleProvider(widget.accommodationId));
        ref.refresh(accommodationImagesSimpleProvider(widget.accommodationId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error setting primary image: $e')),
        );
      }
    }
  }
  
  Future<void> _deleteImage(AccommodationImage image) async {
    try {
      final success = await ref.read(accommodationsSimpleServiceProvider).deleteAccommodationImage(image);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image deleted successfully')),
        );
        // Refresh providers to update UI
        ref.refresh(accommodationSimpleProvider(widget.accommodationId));
        ref.refresh(accommodationImagesSimpleProvider(widget.accommodationId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting image: $e')),
        );
      }
    }
  }
  
  void _confirmDeleteImage(BuildContext context, AccommodationImage image) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
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
  
  void _viewMedia(BuildContext context, List<AccommodationImage> mediaItems, int initialIndex) {
    final mediaItem = mediaItems[initialIndex];
    
    if (mediaItem.mediaType == MediaType.video) {
      // Open video player for video
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            videoUrl: mediaItem.imageUrl,
            title: mediaItem.caption ?? 'Video',
          ),
        ),
      );
    } else {
      // Open image viewer for images
      final imageUrls = mediaItems
        .where((item) => item.mediaType == MediaType.image)
        .map((item) => item.imageUrl)
        .toList();
      
      final imageIndex = mediaItems
        .where((item) => item.mediaType == MediaType.image)
        .toList()
        .indexWhere((item) => item.id == mediaItem.id);
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AccommodationImageViewer(
            imageUrls: imageUrls,
            initialIndex: imageIndex >= 0 ? imageIndex : 0,
            title: 'Accommodation Images',
          ),
        ),
      );
    }
  }
  
  void _viewImage(BuildContext context, List<String> imageUrls, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AccommodationImageViewer(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
          title: 'Accommodation Images',
        ),
      ),
    );
  }
  
  void _showMediaOptions(BuildContext context, AccommodationImage image) {
    final bool isVideo = image.mediaType == MediaType.video;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(isVideo ? Icons.play_circle : Icons.image),
            title: Text(isVideo ? 'View Video' : 'View Image'),
            onTap: () {
              Navigator.pop(context);
              _viewMedia(context, [image], 0);
            },
          ),
          if (!image.isPrimary)
            ListTile(
              leading: const Icon(Icons.star_border),
              title: const Text('Set as Primary'),
              onTap: () {
                Navigator.pop(context);
                _setImageAsPrimary(image);
              },
            ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Caption'),
            onTap: () {
              Navigator.pop(context);
              _editImageCaption(context, image);
            },
          ),
          if (isVideo)
            ListTile(
              leading: const Icon(Icons.add_photo_alternate),
              title: const Text('Set Custom Thumbnail'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadVideoThumbnail(image);
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _confirmDeleteImage(context, image);
            },
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final accommodationAsync = ref.watch(accommodationSimpleProvider(widget.accommodationId));
    final imagesAsync = ref.watch(accommodationImagesSimpleProvider(widget.accommodationId));
    final availabilitiesAsync = ref.watch(accommodationAvailabilitiesProvider(widget.accommodationId));
    
    return Scaffold(
      appBar: AppBar(
        title: accommodationAsync.when(
          data: (accommodation) => Text(accommodation?.name ?? 'Accommodation Details'),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Accommodation Details'),
        ),
        actions: [
          accommodationAsync.when(
            data: (accommodation) => accommodation != null
                ? IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _navigateToEdit(context, accommodation),
                  )
                : const SizedBox(),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: accommodationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
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
                onPressed: () => ref.refresh(accommodationSimpleProvider(widget.accommodationId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (accommodation) {
          if (accommodation == null) {
            return const Center(
              child: Text('Accommodation not found'),
            );
          }
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Accommodation details card
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Primary image
                        GestureDetector(
                          onTap: () {
                            if (accommodation.primaryImageUrl != null) {
                              _viewImage(context, [accommodation.primaryImageUrl!], 0);
                            }
                          },
                          child: accommodation.primaryImageUrl != null
                            ? Hero(
                                tag: 'main-image-${accommodation.id}',
                                child: Image.network(
                                  accommodation.primaryImageUrl!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 200,
                                    color: Colors.grey.shade300,
                                    child: const Center(
                                      child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                height: 200,
                                color: Colors.grey.shade300,
                                child: const Center(
                                  child: Icon(Icons.hotel, size: 50, color: Colors.grey),
                                ),
                              ),
                        ),
                          
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      accommodation.name,
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                  ),
                                  Text(
                                    '\$${accommodation.price.toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Type and area
                              Row(
                                children: [
                                  if (accommodation.typeName != null) ...[
                                    Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      accommodation.typeName!,
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                    const SizedBox(width: 16),
                                  ],
                                  if (accommodation.areaName != null) ...[
                                    Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      accommodation.areaName!,
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                  ],
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Capacity
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 16),
                                  const SizedBox(width: 4),
                                  Text('Capacity: ${accommodation.capacity} persons'),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Description
                              const Text(
                                'Description:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Language selector tabs
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
                                      height: 120,
                                      child: TabBarView(
                                        children: [
                                          // English content
                                          SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(accommodation.name),
                                                const SizedBox(height: 8),
                                                Text(accommodation.description),
                                              ],
                                            ),
                                          ),
                                          
                                          // Arabic content
                                          SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if (accommodation.nameAr != null)
                                                  Text(
                                                    accommodation.nameAr!,
                                                    textAlign: TextAlign.right,
                                                    textDirection: ui.TextDirection.rtl,
                                                  ),
                                                const SizedBox(height: 8),
                                                if (accommodation.descriptionAr != null)
                                                  Text(
                                                    accommodation.descriptionAr!,
                                                    textAlign: TextAlign.right,
                                                    textDirection: ui.TextDirection.rtl,
                                                  ),
                                                if (accommodation.nameAr == null && accommodation.descriptionAr == null)
                                                  const Text('No Arabic content available'),
                                              ],
                                            ),
                                          ),
                                          
                                          // Kurdish content
                                          SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if (accommodation.nameKu != null)
                                                  Text(accommodation.nameKu!),
                                                const SizedBox(height: 8),
                                                if (accommodation.descriptionKu != null)
                                                  Text(accommodation.descriptionKu!),
                                                if (accommodation.nameKu == null && accommodation.descriptionKu == null)
                                                  const Text('No Kurdish content available'),
                                              ],
                                            ),
                                          ),
                                          
                                          // Badinani content
                                          SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if (accommodation.nameBad != null)
                                                  Text(accommodation.nameBad!),
                                                const SizedBox(height: 8),
                                                if (accommodation.descriptionBad != null)
                                                  Text(accommodation.descriptionBad!),
                                                if (accommodation.nameBad == null && accommodation.descriptionBad == null)
                                                  const Text('No Badinani content available'),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Availability management section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Availability',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _navigateToAvailabilityList(context, accommodation),
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Manage'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Availability overview
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: availabilitiesAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, _) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text('Error loading availability: $error'),
                          ),
                        ),
                        data: (availabilities) {
                          if (availabilities.isEmpty) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'No availability periods defined',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'This accommodation has no defined availability periods. Add some to manage when it can be booked.',
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _navigateToAvailabilityList(context, accommodation),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Availability'),
                                  ),
                                ),
                              ],
                            );
                          }
                          
                          // Find current and upcoming availability
                          final now = DateTime.now();
                          final currentAvailabilities = availabilities
                              .where((a) => a.containsDate(now))
                              .toList();
                          final upcomingAvailabilities = availabilities
                              .where((a) => a.startTime.isAfter(now))
                              .take(3)
                              .toList();
                              
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Current status
                              Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 16,
                                    color: currentAvailabilities.any((a) => a.isAvailable)
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    currentAvailabilities.any((a) => a.isAvailable)
                                        ? 'Currently Available'
                                        : 'Currently Unavailable',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: currentAvailabilities.any((a) => a.isAvailable)
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Total periods
                              Text(
                                'Total periods: ${availabilities.length}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              
                              const SizedBox(height: 8),
                              const Divider(),
                              const SizedBox(height: 8),
                              
                              // Upcoming availability
                              if (upcomingAvailabilities.isNotEmpty) ...[
                                const Text(
                                  'Upcoming Availability:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ...upcomingAvailabilities.map(
                                  (a) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          size: 12,
                                          color: a.isAvailable ? Colors.green : Colors.red,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${DateFormat('MMM d').format(a.startTime)} - ${DateFormat('MMM d').format(a.endTime)}',
                                          ),
                                        ),
                                        Text(
                                          a.isAvailable ? 'Available' : 'Unavailable',
                                          style: TextStyle(
                                            color: a.isAvailable ? Colors.green : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ] else ...[
                                const Text(
                                  'No upcoming availability periods',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ],
                              
                              const SizedBox(height: 16),
                              
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _navigateToAvailabilityList(context, accommodation),
                                  child: const Text('View All Availability'),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Images section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Media',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          PopupMenuButton<String>(
                            onSelected: (String value) {
                              if (value == 'video') {
                                _pickAndUploadVideo();
                              } else if (value == 'videoWithThumbnail') {
                                _pickAndUploadVideoWithThumbnail();
                              }
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'video',
                                child: ListTile(
                                  leading: Icon(Icons.videocam, color: Colors.red),
                                  title: Text('Upload Video'),
                                  subtitle: Text('Auto-generated thumbnail'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'videoWithThumbnail',
                                child: ListTile(
                                  leading: Icon(Icons.video_library, color: Colors.red),
                                  title: Text('Upload Video + Thumbnail'),
                                  subtitle: Text('Choose custom thumbnail'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                            child: ElevatedButton.icon(
                              onPressed: null, // Disabled as this is just a trigger for the popup
                              icon: const Icon(Icons.videocam),
                              label: const Text('Add Video'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: _isUploading ? null : _pickAndUploadImage,
                            icon: const Icon(Icons.add_photo_alternate),
                            label: _isUploading
                                ? const Text('Uploading...')
                                : const Text('Add Image'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Images gallery
                  imagesAsync.when(
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
                    data: (images) {
                      if (images.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.photo_library,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No images available',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Use the "Add Image" button to upload images',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      // Prepare image URLs for the viewer
                      final imageUrls = images.map((img) => img.imageUrl).toList();
                      
                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          final image = images[index];
                          final bool isVideo = image.mediaType == MediaType.video;
                          return Stack(
                            children: [
                              // Image with border if primary
                              GestureDetector(
                                onTap: () => _viewMedia(context, images, index),
                                onLongPress: () => _showMediaOptions(context, image),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: image.isPrimary
                                        ? Border.all(
                                            color: Theme.of(context).primaryColor,
                                            width: 3,
                                          )
                                        : null,
                                  ),
                                  child: Hero(
                                    tag: 'gallery-image-${image.id}',
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.network(
                                            isVideo && image.thumbnailUrl != null
                                                ? image.thumbnailUrl!
                                                : image.imageUrl,
                                            height: double.infinity,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              color: Colors.grey.shade300,
                                              child: const Icon(
                                                Icons.broken_image,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          if (isVideo)
                                            Center(
                                              child: Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.6),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.play_arrow,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Primary badge
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
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Text(
                                      'Primary',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              
                              // Media type indicator
                              if (isVideo)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Text(
                                      'Video',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                // Action buttons overlay
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 40,
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // Set as primary button
                                        if (!image.isPrimary)
                                          IconButton(
                                            onPressed: () => _setImageAsPrimary(image),
                                            icon: const Icon(
                                              Icons.star_border,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            tooltip: 'Set as primary',
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                          ),
                                        
                                        // Edit caption button
                                        IconButton(
                                          onPressed: () => _editImageCaption(context, image),
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          tooltip: 'Edit caption',
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                        ),
                                        
                                        // Custom thumbnail button (for videos only)
                                        if (isVideo)
                                          IconButton(
                                            onPressed: () => _pickAndUploadVideoThumbnail(image),
                                            icon: const Icon(
                                              Icons.image,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            tooltip: 'Set custom thumbnail',
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                          ),
                                        
                                        // Delete button
                                        IconButton(
                                          onPressed: () => _confirmDeleteImage(context, image),
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          tooltip: 'Delete image',
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
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
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _navigateToEdit(BuildContext context, Accommodation accommodation) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AccommodationSimpleFormScreen(
          areaId: accommodation.areaId ?? '',
          areaName: accommodation.areaName ?? 'Unknown',
          accommodation: accommodation,
        ),
      ),
    );
    
    if (result == true && mounted) {
      ref.refresh(accommodationSimpleProvider(widget.accommodationId));
    }
  }
  
  void _navigateToAvailabilityList(BuildContext context, Accommodation accommodation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AvailabilityListScreen(
          accommodation: accommodation,
        ),
      ),
    ).then((_) {
      // Refresh availability data when returning from the screen
      ref.refresh(accommodationAvailabilitiesProvider(widget.accommodationId));
    });
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  
  const VideoPlayerScreen({
    Key? key,
    required this.videoUrl,
    required this.title,
  }) : super(key: key);
  
  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  
  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }
  
  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    
    try {
      await _controller.initialize();
      _controller.addListener(() {
        if (mounted) {
          setState(() {
            _isPlaying = _controller.value.isPlaying;
          });
        }
      });
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        
        // Auto-play the video
        _controller.play();
      }
    } catch (e) {
      print('Error initializing video player: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing video: $e')),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title),
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
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          iconSize: 50,
                          color: Colors.white,
                          icon: const Icon(Icons.play_arrow),
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
      floatingActionButton: _isInitialized
          ? FloatingActionButton(
              backgroundColor: Colors.white.withOpacity(0.7),
              onPressed: () {
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.black,
              ),
            )
          : null,
    );
  }
} 