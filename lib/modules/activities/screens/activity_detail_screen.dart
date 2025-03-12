import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import '../models/activity.dart';
import '../models/activity_type.dart';
import '../models/activity_image.dart';
import '../models/activity_time_slot.dart';
import '../providers/activities_provider.dart';
import '../widgets/time_slot_dialog.dart';

class ActivityDetailScreen extends ConsumerStatefulWidget {
  final String activityId;
  
  const ActivityDetailScreen({
    Key? key,
    required this.activityId,
  }) : super(key: key);

  @override
  ConsumerState<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends ConsumerState<ActivityDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  final _imagePicker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (pickedFile == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      final service = ref.read(activitiesServiceProvider);
      final result = await service.uploadActivityImage(
        widget.activityId,
        File(pickedFile.path),
      );
      
      if (result != null) {
        // Force refresh of images
        ref.invalidate(activityImagesProvider(widget.activityId));
        
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
    } catch (e) {
      debugPrint('❌ Error in _pickAndUploadImage: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
      
      final service = ref.read(activitiesServiceProvider);
      final result = await service.uploadActivityVideo(
        widget.activityId,
        File(pickedFile.path),
      );
      
      if (result != null) {
        // Force refresh of images
        ref.invalidate(activityImagesProvider(widget.activityId));
        
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
  
  // Upload a video with a custom thumbnail
  Future<void> _pickAndUploadVideoWithThumbnail() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // First pick a video
      final videoFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      
      if (videoFile == null || !mounted) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Then pick a thumbnail image
      final thumbnailFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (thumbnailFile == null || !mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thumbnail selection canceled. Video upload aborted.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Check video file size
      final fileSize = await File(videoFile.path).length();
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
      
      // Upload both video and thumbnail
      final service = ref.read(activitiesServiceProvider);
      final result = await service.uploadActivityVideoWithThumbnail(
        widget.activityId,
        File(videoFile.path),
        File(thumbnailFile.path),
      );
      
      if (result != null && mounted) {
        // Force refresh of images
        ref.invalidate(activityImagesProvider(widget.activityId));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video uploaded with custom thumbnail')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload video with thumbnail')),
        );
      }
    } catch (e) {
      debugPrint('❌ Error in _pickAndUploadVideoWithThumbnail: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Add or update a custom thumbnail for an existing video
  Future<void> _pickAndUploadVideoThumbnail(ActivityImage videoItem) async {
    // Only allow thumbnail uploads for videos
    if (videoItem.mediaType != MediaType.video) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final thumbnailFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (thumbnailFile == null || !mounted) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      final service = ref.read(activitiesServiceProvider);
      final success = await service.uploadVideoThumbnail(
        widget.activityId,
        videoItem.requireId,
        File(thumbnailFile.path),
      );
      
      if (success && mounted) {
        // Force refresh of images
        ref.invalidate(activityImagesProvider(widget.activityId));
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thumbnail updated successfully')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update thumbnail')),
        );
      }
    } catch (e) {
      debugPrint('❌ Error in _pickAndUploadVideoThumbnail: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating thumbnail: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Show dialog with instructions to set up storage
  void _showStorageSetupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Setup Required'),
        content: const SingleChildScrollView(
          child: Text(
            'The app cannot upload images because the Supabase storage is not properly set up. '
            'Please ask your administrator to:\n\n'
            '1. Create an "activity" bucket in Supabase storage\n'
            '2. Make the bucket public or configure RLS policies\n'
            '3. Allow file uploads from authenticated users\n\n'
            'Note: This requires admin access to the Supabase dashboard.'
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _setAsPrimaryImage(ActivityImage image) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final service = ref.read(activitiesServiceProvider);
      final result = await service.setImageAsPrimary(image);
      
      if (result) {
        // Force refresh of images
        ref.invalidate(activityImagesProvider(widget.activityId));
        ref.invalidate(activityProvider(widget.activityId)); // Also refresh activity to update thumbnail
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Primary image updated')),
          );
        }
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _deleteImage(ActivityImage image) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final service = ref.read(activitiesServiceProvider);
      final result = await service.deleteActivityImage(image);
      
      if (result) {
        // Force refresh of images
        ref.invalidate(activityImagesProvider(widget.activityId));
        ref.invalidate(activityProvider(widget.activityId)); // Also refresh activity to update thumbnail
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image deleted')),
          );
        }
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
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _addEditTimeSlot(BuildContext context, [ActivityTimeSlot? timeSlot]) async {
    final isEditing = timeSlot != null;
    
    final result = await showDialog<ActivityTimeSlot?>(
      context: context,
      builder: (context) => TimeSlotDialog(
        activityId: widget.activityId,
        timeSlot: timeSlot,
      ),
    );
    
    if (result != null) {
      try {
        final service = ref.read(activitiesServiceProvider);
        
        bool success;
        if (isEditing) {
          success = await service.updateTimeSlot(result) != null;
        } else {
          success = await service.createTimeSlot(result) != null;
        }
        
        if (success) {
          // Refresh time slots
          ref.invalidate(activityTimeSlotsProvider(widget.activityId));
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isEditing
                    ? 'Time slot updated successfully'
                    : 'Time slot added successfully'),
              ),
            );
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing
                  ? 'Failed to update time slot'
                  : 'Failed to add time slot'),
            ),
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
  }
  
  Future<void> _deleteTimeSlot(ActivityTimeSlot timeSlot) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Time Slot'),
        content: const Text('Are you sure you want to delete this time slot? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final service = ref.read(activitiesServiceProvider);
      final result = await service.deleteTimeSlot(timeSlot.requireId);
      
      if (result) {
        // Force refresh of time slots
        ref.invalidate(activityTimeSlotsProvider(widget.activityId));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Time slot deleted')),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete time slot')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToEditActivity(Activity activity) {
    Navigator.pushNamed(
      context,
      '/areas/${activity.areaId}/activities/${activity.requireId}/edit',
      arguments: activity,
    ).then((_) {
      // Refresh activity data when returning from edit screen
      ref.invalidate(activityProvider(widget.activityId));
    });
  }
  
  Widget _buildDetailsTab(Activity activity) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  // Name
                  Text(
                    'Name',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(activity.name),
                  const SizedBox(height: 16),
                  
                  // Type
                  const Text(
                    'Type',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final typesAsync = ref.watch(activityTypesProvider);
                      return typesAsync.when(
                        data: (types) {
                          final type = types.firstWhere(
                            (t) => t.id == activity.typeId,
                            orElse: () => ActivityType(
                              name: 'Unknown',
                              description: '',
                            ),
                          );
                          return Text(type.name);
                        },
                        loading: () => const Text('Loading...'),
                        error: (e, _) => Text('Error: $e'),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(activity.description),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Price info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pricing',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  if (activity.pricePerPerson != null && activity.pricePerPerson! > 0)
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Price Per Person'),
                      trailing: Text(
                        currencyFormat.format(activity.pricePerPerson!),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                  if (activity.groupPrice != null && activity.groupPrice! > 0)
                    ListTile(
                      leading: const Icon(Icons.group),
                      title: const Text('Group Price'),
                      trailing: Text(
                        currencyFormat.format(activity.groupPrice!),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                  if (activity.flatRate != null && activity.flatRate! > 0)
                    ListTile(
                      leading: const Icon(Icons.payments),
                      title: const Text('Flat Rate'),
                      trailing: Text(
                        currencyFormat.format(activity.flatRate!),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                  if (activity.discountPercent != null && activity.discountPercent! > 0)
                    ListTile(
                      leading: const Icon(Icons.discount),
                      title: const Text('Discount'),
                      trailing: Text(
                        '${activity.discountPercent}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Additional details card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Additional Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  if (activity.capacity != null)
                    ListTile(
                      leading: const Icon(Icons.people),
                      title: const Text('Capacity'),
                      trailing: Text(
                        '${activity.capacity} persons',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                  if (activity.durationMinutes != null)
                    ListTile(
                      leading: const Icon(Icons.timer),
                      title: const Text('Duration'),
                      trailing: Text(
                        _formatDuration(activity.durationMinutes!),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  
                  // Status indicators
                  ListTile(
                    leading: Icon(
                      activity.isActive ? Icons.check_circle : Icons.cancel,
                      color: activity.isActive ? Colors.green : Colors.red,
                    ),
                    title: const Text('Status'),
                    trailing: Text(
                      activity.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: activity.isActive ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  
                  if (activity.isFeatured)
                    const ListTile(
                      leading: Icon(Icons.star, color: Colors.amber),
                      title: Text('Featured Activity'),
                    ),
                    
                  if (activity.isNew)
                    const ListTile(
                      leading: Icon(Icons.fiber_new, color: Colors.blue),
                      title: Text('New Activity'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildImagesTab() {
    return ref.watch(activityImagesProvider(widget.activityId)).when(
      data: (images) {
        if (images.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No images yet'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickAndUploadImage,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Add Image'),
                ),
              ],
            ),
          );
        }
        
        return Stack(
          children: [
            GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                return _buildMediaItem(image);
              },
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PopupMenuButton<String>(
                    enabled: !_isLoading,
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
                    child: FloatingActionButton(
                      heroTag: 'video_upload',
                      onPressed: null, // Disabled as this is just a trigger for the popup
                      tooltip: 'Add Video',
                      backgroundColor: Colors.red,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(Icons.videocam),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    heroTag: 'image_upload',
                    onPressed: _isLoading ? null : _pickAndUploadImage,
                    tooltip: 'Add Image',
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.add_a_photo),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading images: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(activityImagesProvider(widget.activityId)),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMediaItem(ActivityImage media) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: GestureDetector(
        onTap: () => _viewMedia(media),
        onLongPress: () => _showMediaOptions(media),
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
                    
                    // Thumbnail button (only for videos)
                    if (media.mediaType == MediaType.video)
                      IconButton(
                        icon: const Icon(Icons.image, color: Colors.white),
                        tooltip: 'Set custom thumbnail',
                        onPressed: () => _pickAndUploadVideoThumbnail(media),
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
                      onPressed: () => _confirmDeleteImage(media),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVideoThumbnail(ActivityImage video) {
    // Check if there's a thumbnail URL
    if (video.thumbnailUrl != null && video.thumbnailUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          // Display the custom thumbnail
          Image.network(
            video.thumbnailUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to placeholder on error
              return Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(Icons.movie, size: 48, color: Colors.white),
                ),
              );
            },
          ),
          // Semi-transparent play overlay
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: Icon(Icons.play_circle_outline, size: 48, color: Colors.white),
            ),
          ),
        ],
      );
    }
    
    // No thumbnail - show placeholder
    return Container(
      color: Colors.black,
      child: const Center(
        child: Icon(Icons.movie, size: 48, color: Colors.white),
      ),
    );
  }
  
  void _viewMedia(ActivityImage media) {
    if (media.mediaType == MediaType.video) {
      _playVideo(media);
    } else {
      _viewImage(media);
    }
  }
  
  void _viewImage(ActivityImage image) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Image View'),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Image.network(
                image.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  void _playVideo(ActivityImage video) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _VideoPlayerScreen(videoUrl: video.imageUrl),
      ),
    );
  }
  
  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    
    if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''} ${mins > 0 ? '$mins min' : ''}';
    } else {
      return '$mins minutes';
    }
  }
  
  // Add the missing _confirmDeleteImage method
  void _confirmDeleteImage(ActivityImage media) {
    _deleteImage(media);
  }
  
  // Show options for a media item
  void _showMediaOptions(ActivityImage media) {
    final bool isVideo = media.mediaType == MediaType.video;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(isVideo ? Icons.play_arrow : Icons.image),
            title: Text(isVideo ? 'Play Video' : 'View Image'),
            onTap: () {
              Navigator.pop(context);
              _viewMedia(media);
            },
          ),
          if (!media.isPrimary)
            ListTile(
              leading: const Icon(Icons.star_border),
              title: const Text('Set as Primary'),
              onTap: () {
                Navigator.pop(context);
                _setAsPrimaryImage(media);
              },
            ),
          if (isVideo)
            ListTile(
              leading: const Icon(Icons.add_photo_alternate),
              title: const Text('Set Custom Thumbnail'),
              subtitle: const Text('Choose an image from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadVideoThumbnail(media);
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _confirmDeleteImage(media);
            },
          ),
        ],
      ),
    );
  }
  
  // Build the time slots tab
  Widget _buildTimeSlotsTab() {
    return ref.watch(activityTimeSlotsProvider(widget.activityId)).when(
      data: (timeSlots) {
        if (timeSlots.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.schedule, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No time slots yet'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _addEditTimeSlot(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Time Slot'),
                ),
              ],
            ),
          );
        }
        
        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: timeSlots.length,
              itemBuilder: (context, index) {
                final timeSlot = timeSlots[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text(_getDayName(timeSlot.dayOfWeek)),
                    subtitle: Text('${_formatTime(timeSlot.startTime)} - ${_formatTime(timeSlot.endTime)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _addEditTimeSlot(context, timeSlot),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteTimeSlot(timeSlot),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () => _addEditTimeSlot(context),
                tooltip: 'Add Time Slot',
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading time slots: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(activityTimeSlotsProvider(widget.activityId)),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper methods needed by _buildTimeSlotsTab
  String _getDayName(int day) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[day - 1]; // Assuming days are 1-indexed (1 = Monday, 7 = Sunday)
  }
  
  String _formatTime(String timeString) {
    // Assuming timeString is in format HH:MM:SS
    final parts = timeString.split(':');
    if (parts.length < 2) return timeString;
    
    int hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final activityAsync = ref.watch(activityProvider(widget.activityId));
    
    return Scaffold(
      appBar: AppBar(
        title: activityAsync.when(
          data: (activity) => Text('Activity: ${activity?.name ?? 'Details'}'),
          loading: () => const Text('Activity Details'),
          error: (_, __) => const Text('Activity Details'),
        ),
        actions: [
          activityAsync.when(
            data: (activity) => activity != null ? IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Activity',
              onPressed: () => _navigateToEditActivity(activity),
            ) : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Images'),
            Tab(text: 'Time Slots'),
          ],
        ),
      ),
      body: activityAsync.when(
        data: (activity) => activity != null ? TabBarView(
          controller: _tabController,
          children: [
            _buildDetailsTab(activity),
            _buildImagesTab(),
            _buildTimeSlotsTab(),
          ],
        ) : const Center(child: Text('Activity not found')),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading activity: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(activityProvider(widget.activityId)),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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