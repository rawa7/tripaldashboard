import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/accommodation_availability.dart';
import '../providers/availability_provider.dart';

class AvailabilityFormScreen extends ConsumerStatefulWidget {
  final String accommodationId;
  final String accommodationName;
  final AccommodationAvailability? availability; // If editing an existing availability
  
  const AvailabilityFormScreen({
    Key? key,
    required this.accommodationId,
    required this.accommodationName,
    this.availability,
  }) : super(key: key);

  @override
  ConsumerState<AvailabilityFormScreen> createState() => _AvailabilityFormScreenState();
}

class _AvailabilityFormScreenState extends ConsumerState<AvailabilityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late DateTime _startDate;
  late DateTime _endDate;
  late bool _isAvailable;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  // Date formatter
  final DateFormat _dateFormatter = DateFormat('EEE, MMM d, yyyy');
  
  @override
  void initState() {
    super.initState();
    
    if (widget.availability != null) {
      // Editing existing availability
      _startDate = widget.availability!.startTime;
      _endDate = widget.availability!.endTime;
      _isAvailable = widget.availability!.isAvailable;
    } else {
      // Creating new availability
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 7));
      _isAvailable = true;
    }
  }
  
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime initialDate = isStartDate ? _startDate : _endDate;
    final DateTime firstDate = isStartDate ? DateTime.now() : _startDate;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)), // 2 years in future
      helpText: isStartDate ? 'Select Start Date' : 'Select End Date',
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // If end date is now before start date, adjust it
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }
  
  Future<void> _saveAvailability() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final service = ref.read(availabilityServiceProvider);
      
      // Create availability object
      final availability = widget.availability?.copyWith(
        startTime: _startDate,
        endTime: _endDate,
        isAvailable: _isAvailable,
      ) ?? AccommodationAvailability(
        accommodationId: widget.accommodationId,
        startTime: _startDate,
        endTime: _endDate,
        isAvailable: _isAvailable,
      );
      
      // Check for overlaps
      final wouldOverlap = await service.wouldOverlap(
        availability, 
        excludeId: widget.availability?.id,
      );
      
      if (wouldOverlap) {
        setState(() {
          _errorMessage = 'This period overlaps with an existing availability period';
          _isLoading = false;
        });
        return;
      }
      
      // Save to database
      AccommodationAvailability? result;
      if (widget.availability != null) {
        result = await service.updateAvailability(availability);
      } else {
        result = await service.createAvailability(availability);
      }
      
      if (result != null && mounted) {
        Navigator.of(context).pop(true); // Return success
      } else if (mounted) {
        setState(() {
          _errorMessage = 'Failed to save availability period';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.availability != null;
    final duration = _endDate.difference(_startDate).inDays;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Availability' : 'Add Availability'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Accommodation',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(widget.accommodationName),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Date range selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date Range',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      // Start date
                      ListTile(
                        title: const Text('Start Date'),
                        subtitle: Text(_dateFormatter.format(_startDate)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, true),
                      ),
                      
                      const Divider(),
                      
                      // End date
                      ListTile(
                        title: const Text('End Date'),
                        subtitle: Text(_dateFormatter.format(_endDate)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, false),
                      ),
                      
                      const Divider(),
                      
                      // Duration info
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Duration: $duration ${duration == 1 ? 'day' : 'days'}',
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Availability status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      SwitchListTile(
                        title: Text(
                          _isAvailable ? 'Available' : 'Unavailable',
                          style: TextStyle(
                            color: _isAvailable ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          _isAvailable 
                              ? 'Accommodation can be booked during this period' 
                              : 'Accommodation cannot be booked during this period'
                        ),
                        value: _isAvailable,
                        onChanged: (value) {
                          setState(() {
                            _isAvailable = value;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Color coded explanation
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isAvailable ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isAvailable ? Colors.green : Colors.red,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _isAvailable
                              ? 'This period will be marked as AVAILABLE for bookings.'
                              : 'This period will be marked as UNAVAILABLE for bookings.',
                          style: TextStyle(
                            color: _isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Save button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveAvailability,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading
                    ? 'Saving...'
                    : (isEditing ? 'Update Availability' : 'Save Availability')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 