import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/accommodation.dart';
import '../models/accommodation_availability.dart';
import '../providers/availability_provider.dart';
import 'availability_form_screen.dart';

class AvailabilityListScreen extends ConsumerWidget {
  final Accommodation accommodation;
  
  const AvailabilityListScreen({
    Key? key,
    required this.accommodation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availabilitiesAsync = ref.watch(accommodationAvailabilitiesProvider(accommodation.requireId));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Availability - ${accommodation.name}'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddAvailability(context, ref),
        child: const Icon(Icons.add),
      ),
      body: availabilitiesAsync.when(
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
                onPressed: () => ref.refresh(accommodationAvailabilitiesProvider(accommodation.requireId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (availabilities) {
          if (availabilities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No availability periods defined',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add periods to manage when this accommodation is available',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToAddAvailability(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Availability Period'),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () => ref.refresh(accommodationAvailabilitiesProvider(accommodation.requireId).future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: availabilities.length,
              itemBuilder: (context, index) {
                final availability = availabilities[index];
                return _buildAvailabilityCard(context, ref, availability);
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildAvailabilityCard(BuildContext context, WidgetRef ref, AccommodationAvailability availability) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final startDate = dateFormat.format(availability.startTime);
    final endDate = dateFormat.format(availability.endTime);
    final duration = availability.durationInDays;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        children: [
          // Header with status
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: availability.isAvailable ? Colors.green : Colors.red,
            width: double.infinity,
            child: Text(
              availability.isAvailable ? 'AVAILABLE' : 'UNAVAILABLE',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date range
                Row(
                  children: [
                    const Icon(Icons.date_range, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$startDate - $endDate',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Duration
                Text('Duration: $duration ${duration == 1 ? 'day' : 'days'}'),
                
                const SizedBox(height: 16),
                
                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      onPressed: () => _navigateToEditAvailability(context, ref, availability),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                      onPressed: () => _confirmDeleteAvailability(context, ref, availability),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _navigateToAddAvailability(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AvailabilityFormScreen(
          accommodationId: accommodation.requireId,
          accommodationName: accommodation.name,
        ),
      ),
    );
    
    if (result == true) {
      ref.refresh(accommodationAvailabilitiesProvider(accommodation.requireId));
    }
  }
  
  Future<void> _navigateToEditAvailability(BuildContext context, WidgetRef ref, AccommodationAvailability availability) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AvailabilityFormScreen(
          accommodationId: accommodation.requireId,
          accommodationName: accommodation.name,
          availability: availability,
        ),
      ),
    );
    
    if (result == true) {
      ref.refresh(accommodationAvailabilitiesProvider(accommodation.requireId));
    }
  }
  
  void _confirmDeleteAvailability(BuildContext context, WidgetRef ref, AccommodationAvailability availability) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Availability Period'),
        content: const Text('Are you sure you want to delete this availability period? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteAvailability(context, ref, availability);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteAvailability(BuildContext context, WidgetRef ref, AccommodationAvailability availability) async {
    try {
      final result = await ref.read(availabilityServiceProvider).deleteAvailability(availability.requireId);
      
      if (result && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Availability period deleted successfully')),
        );
        ref.refresh(accommodationAvailabilitiesProvider(accommodation.requireId));
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete availability period')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
} 