import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/accommodations_provider.dart';
import '../models/accommodation.dart';
import 'accommodation_form_screen.dart';
import 'accommodation_detail_screen.dart';

class AccommodationsScreen extends ConsumerStatefulWidget {
  final String areaId;
  final String areaName;
  
  const AccommodationsScreen({
    Key? key,
    required this.areaId,
    required this.areaName,
  }) : super(key: key);

  @override
  ConsumerState<AccommodationsScreen> createState() => _AccommodationsScreenState();
}

class _AccommodationsScreenState extends ConsumerState<AccommodationsScreen> {
  @override
  Widget build(BuildContext context) {
    final accommodationsAsync = ref.watch(accommodationsByAreaProvider(widget.areaId));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Accommodations - ${widget.areaName}'),
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
                onPressed: () => ref.refresh(accommodationsByAreaProvider(widget.areaId)),
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
                  const Text(
                    'No accommodations found for this area',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Accommodation'),
                    onPressed: () => _navigateToAddAccommodation(context),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(accommodationsByAreaProvider(widget.areaId));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: accommodations.length,
              itemBuilder: (context, index) {
                final accommodation = accommodations[index];
                return _buildAccommodationCard(context, accommodation);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddAccommodation(context),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildAccommodationCard(BuildContext context, Accommodation accommodation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with overlay
          Stack(
            children: [
              // Accommodation image
              SizedBox(
                height: 160,
                width: double.infinity,
                child: accommodation.primaryImageUrl != null && accommodation.primaryImageUrl!.isNotEmpty
                    ? Image.network(
                        accommodation.primaryImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                            const Center(child: Icon(Icons.image_not_supported, size: 50)),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.hotel, size: 50)),
                      ),
              ),
              
              // Status indicators
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    if (accommodation.isNew == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    const SizedBox(width: 4),
                    if (accommodation.isFeatured == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'FEATURED',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          // Content
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
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '\$${accommodation.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  accommodation.description,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people, size: 16),
                        const SizedBox(width: 4),
                        Text('${accommodation.capacity} guests'),
                      ],
                    ),
                    Text(
                      accommodation.typeName ?? 'Unknown Type',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.visibility),
                      label: const Text('View'),
                      onPressed: () => _navigateToAccommodationDetails(context, accommodation),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      onPressed: () => _navigateToEditAccommodation(context, accommodation),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                      onPressed: () => _confirmDelete(context, accommodation),
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
  
  void _navigateToAddAccommodation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AccommodationFormScreen(
          areaId: widget.areaId,
          areaName: widget.areaName,
        ),
      ),
    ).then((_) {
      // Refresh the list when returning from the form
      ref.refresh(accommodationsByAreaProvider(widget.areaId));
    });
  }
  
  void _navigateToEditAccommodation(BuildContext context, Accommodation accommodation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AccommodationFormScreen(
          areaId: widget.areaId,
          areaName: widget.areaName,
          accommodation: accommodation,
        ),
      ),
    ).then((_) {
      // Refresh the list when returning from the form
      ref.refresh(accommodationsByAreaProvider(widget.areaId));
    });
  }
  
  void _navigateToAccommodationDetails(BuildContext context, Accommodation accommodation) {
    try {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AccommodationDetailScreen(
            accommodationId: accommodation.requireId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  void _confirmDelete(BuildContext context, Accommodation accommodation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Accommodation'),
        content: Text('Are you sure you want to delete "${accommodation.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAccommodation(context, accommodation);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  void _deleteAccommodation(BuildContext context, Accommodation accommodation) async {
    try {
      final service = ref.read(accommodationsServiceProvider);
      final success = await service.deleteAccommodation(accommodation.id);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${accommodation.name} deleted successfully')),
        );
        
        // Refresh the list
        ref.refresh(accommodationsByAreaProvider(widget.areaId));
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