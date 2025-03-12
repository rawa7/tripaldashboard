import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/activity.dart';
import '../models/activity_type.dart';
import '../providers/activities_provider.dart';
import 'activity_detail_screen.dart';
import 'activity_form_screen.dart';

class ActivitiesScreen extends ConsumerWidget {
  final String areaId;
  final String areaName;
  
  const ActivitiesScreen({
    Key? key,
    required this.areaId,
    required this.areaName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activitiesByAreaProvider(areaId));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Activities - $areaName'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddActivity(context, ref),
        child: const Icon(Icons.add),
      ),
      body: activitiesAsync.when(
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
                onPressed: () => ref.refresh(activitiesByAreaProvider(areaId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (activities) {
          if (activities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.attractions,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No activities found for this area',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add activities that visitors can book',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToAddActivity(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Activity'),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () => ref.refresh(activitiesByAreaProvider(areaId).future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return _buildActivityCard(context, ref, activity);
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildActivityCard(BuildContext context, WidgetRef ref, Activity activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToActivityDetail(context, ref, activity),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity image or placeholder
            if (activity.thumbnailUrl != null)
              Image.network(
                activity.thumbnailUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 150,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                  ),
                ),
              )
            else
              Container(
                height: 150,
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(Icons.attractions, size: 50, color: Colors.grey),
                ),
              ),
              
            // Status indicators
            if (activity.isFeatured == true || activity.isNew == true)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    if (activity.isNew == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ),
                    if (activity.isNew == true && activity.isFeatured == true)
                      const SizedBox(width: 8),
                    if (activity.isFeatured == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'FEATURED',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ),
                  ],
                ),
              ),
              
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and type
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activity.name,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  // Display activity type using Consumer
                  if (activity.typeId != null) ...[
                    const SizedBox(height: 4),
                    Consumer(
                      builder: (context, ref, _) {
                        final typesAsync = ref.watch(activityTypesProvider);
                        return typesAsync.when(
                          data: (types) {
                            final type = types.firstWhere(
                              (t) => t.id == activity.typeId,
                              orElse: () => ActivityType(name: 'Unknown Type', description: ''),
                            );
                            return Text(
                              type.name,
                              style: TextStyle(color: Colors.grey.shade600),
                            );
                          },
                          loading: () => Text('Loading type...', style: TextStyle(color: Colors.grey.shade600)),
                          error: (_, __) => Text('Unknown type', style: TextStyle(color: Colors.grey.shade600)),
                        );
                      },
                    ),
                  ],
                  
                  const SizedBox(height: 8),
                  
                  // Price display
                  Text(
                    activity.displayPrice,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Duration if available
                  if (activity.durationMinutes != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 16),
                        const SizedBox(width: 4),
                        Text(activity.durationFormatted),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // Description
                  Text(
                    activity.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                  
                  // Action buttons
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _navigateToEditActivity(context, ref, activity),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => _confirmDeleteActivity(context, ref, activity),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _navigateToActivityDetail(BuildContext context, WidgetRef ref, Activity activity) {
    if (activity.id == null) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActivityDetailScreen(
          activityId: activity.requireId,
        ),
      ),
    );
  }
  
  Future<void> _navigateToAddActivity(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActivityFormScreen(
          areaId: areaId,
          areaName: areaName,
        ),
      ),
    );
    
    if (result == true) {
      ref.refresh(activitiesByAreaProvider(areaId));
    }
  }
  
  Future<void> _navigateToEditActivity(BuildContext context, WidgetRef ref, Activity activity) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActivityFormScreen(
          areaId: areaId,
          areaName: areaName,
          activity: activity,
        ),
      ),
    );
    
    if (result == true) {
      ref.refresh(activitiesByAreaProvider(areaId));
    }
  }
  
  void _confirmDeleteActivity(BuildContext context, WidgetRef ref, Activity activity) {
    if (activity.id == null) return;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Activity'),
        content: Text('Are you sure you want to delete "${activity.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _deleteActivity(context, ref, activity.requireId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteActivity(BuildContext context, WidgetRef ref, String id) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      final result = await ref.read(activitiesServiceProvider).deleteActivity(id);
      
      if (result && context.mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Activity deleted successfully')),
        );
        ref.refresh(activitiesByAreaProvider(areaId));
      } else if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Failed to delete activity')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
} 