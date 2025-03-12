import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/accommodation.dart';
import '../providers/accommodations_provider_simple.dart';
import 'accommodation_simple_form_screen.dart';
import 'accommodation_simple_detail_screen.dart';

class AccommodationsSimpleScreen extends ConsumerWidget {
  final String areaId;
  final String areaName;
  
  const AccommodationsSimpleScreen({
    Key? key,
    required this.areaId,
    required this.areaName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accommodationsAsync = ref.watch(accommodationsByAreaSimpleProvider(areaId));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Accommodations - $areaName'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddAccommodation(context, ref),
        child: const Icon(Icons.add),
      ),
      body: accommodationsAsync.when(
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
                onPressed: () => ref.refresh(accommodationsByAreaSimpleProvider(areaId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (accommodations) {
          if (accommodations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.hotel_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No accommodations found for this area',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToAddAccommodation(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Accommodation'),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () => ref.refresh(accommodationsByAreaSimpleProvider(areaId).future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: accommodations.length,
              itemBuilder: (context, index) {
                final accommodation = accommodations[index];
                return _buildAccommodationCard(context, ref, accommodation);
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildAccommodationCard(BuildContext context, WidgetRef ref, Accommodation accommodation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToAccommodationDetail(context, ref, accommodation),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Accommodation image or placeholder
            if (accommodation.primaryImageUrl != null)
              Image.network(
                accommodation.primaryImageUrl!,
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
                  child: Icon(Icons.hotel, size: 50, color: Colors.grey),
                ),
              ),
              
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and price row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          accommodation.name,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$${accommodation.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  
                  // Type and capacity
                  const SizedBox(height: 8),
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
                      Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${accommodation.capacity} persons',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  
                  // Description
                  const SizedBox(height: 8),
                  Text(
                    accommodation.description,
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
                        onPressed: () => _navigateToEditAccommodation(context, ref, accommodation),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => _confirmDelete(context, ref, accommodation),
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
  
  void _navigateToAccommodationDetail(BuildContext context, WidgetRef ref, Accommodation accommodation) {
    if (accommodation.id == null) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AccommodationSimpleDetailScreen(
          accommodationId: accommodation.id!,
        ),
      ),
    );
  }
  
  void _navigateToAddAccommodation(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AccommodationSimpleFormScreen(
          areaId: areaId,
          areaName: areaName,
        ),
      ),
    );
    
    if (result == true) {
      ref.refresh(accommodationsByAreaSimpleProvider(areaId));
    }
  }
  
  void _navigateToEditAccommodation(BuildContext context, WidgetRef ref, Accommodation accommodation) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AccommodationSimpleFormScreen(
          areaId: areaId,
          areaName: areaName,
          accommodation: accommodation,
        ),
      ),
    );
    
    if (result == true) {
      ref.refresh(accommodationsByAreaSimpleProvider(areaId));
    }
  }
  
  void _confirmDelete(BuildContext context, WidgetRef ref, Accommodation accommodation) {
    if (accommodation.id == null) return;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${accommodation.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _deleteAccommodation(context, ref, accommodation.id!);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteAccommodation(BuildContext context, WidgetRef ref, String id) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    try {
      final result = await ref.read(accommodationsSimpleServiceProvider).deleteAccommodation(id);
      
      if (result) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Accommodation deleted successfully')),
        );
        ref.refresh(accommodationsByAreaSimpleProvider(areaId));
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Failed to delete accommodation')),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
} 