import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/activity_time_slot.dart';

class TimeSlotDialog extends StatefulWidget {
  final String activityId;
  final ActivityTimeSlot? timeSlot; // If editing an existing time slot
  
  const TimeSlotDialog({
    Key? key,
    required this.activityId,
    this.timeSlot,
  }) : super(key: key);

  @override
  State<TimeSlotDialog> createState() => _TimeSlotDialogState();
}

class _TimeSlotDialogState extends State<TimeSlotDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Selected values
  int _selectedDay = 1; // Default to Monday
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0); // Default to 9:00 AM
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 0); // Default to 11:00 AM
  
  // Day of week options
  final List<Map<String, dynamic>> _daysOfWeek = [
    {'value': 1, 'name': 'Monday'},
    {'value': 2, 'name': 'Tuesday'},
    {'value': 3, 'name': 'Wednesday'},
    {'value': 4, 'name': 'Thursday'},
    {'value': 5, 'name': 'Friday'},
    {'value': 6, 'name': 'Saturday'},
    {'value': 7, 'name': 'Sunday'},
  ];
  
  @override
  void initState() {
    super.initState();
    
    if (widget.timeSlot != null) {
      // Parse existing time slot data
      _selectedDay = widget.timeSlot!.dayOfWeek;
      
      // Parse start time
      final startParts = widget.timeSlot!.startTime.split(':');
      if (startParts.length >= 2) {
        _startTime = TimeOfDay(
          hour: int.parse(startParts[0]),
          minute: int.parse(startParts[1]),
        );
      }
      
      // Parse end time
      final endParts = widget.timeSlot!.endTime.split(':');
      if (endParts.length >= 2) {
        _endTime = TimeOfDay(
          hour: int.parse(endParts[0]),
          minute: int.parse(endParts[1]),
        );
      }
    }
  }
  
  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    
    if (pickedTime != null && pickedTime != _startTime) {
      setState(() {
        _startTime = pickedTime;
        
        // If end time is earlier than start time, automatically adjust it
        if (_timeOfDayToMinutes(_endTime) <= _timeOfDayToMinutes(_startTime)) {
          // Add 1 hour to start time for end time
          int endHour = _startTime.hour + 1;
          int endMinute = _startTime.minute;
          
          if (endHour >= 24) {
            endHour = 23;
            endMinute = 59;
          }
          
          _endTime = TimeOfDay(hour: endHour, minute: endMinute);
        }
      });
    }
  }
  
  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    
    if (pickedTime != null && pickedTime != _endTime) {
      // Only update if end time is after start time
      if (_timeOfDayToMinutes(pickedTime) > _timeOfDayToMinutes(_startTime)) {
        setState(() {
          _endTime = pickedTime;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('End time must be after start time')),
        );
      }
    }
  }
  
  // Convert TimeOfDay to minutes since midnight for comparison
  int _timeOfDayToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }
  
  // Format TimeOfDay as HH:MM:00 for database
  String _formatTimeForDb(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }
  
  // Save time slot
  void _saveTimeSlot() {
    if (_formKey.currentState!.validate()) {
      final timeSlot = widget.timeSlot?.copyWith(
        activityId: widget.activityId,
        dayOfWeek: _selectedDay,
        startTime: _formatTimeForDb(_startTime),
        endTime: _formatTimeForDb(_endTime),
      ) ?? ActivityTimeSlot(
        activityId: widget.activityId,
        dayOfWeek: _selectedDay,
        startTime: _formatTimeForDb(_startTime),
        endTime: _formatTimeForDb(_endTime),
      );
      
      Navigator.of(context).pop(timeSlot);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.timeSlot != null;
    
    return AlertDialog(
      title: Text(isEditing ? 'Edit Time Slot' : 'Add Time Slot'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day of week
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Day of Week',
                  border: OutlineInputBorder(),
                ),
                value: _selectedDay,
                items: _daysOfWeek.map((day) {
                  return DropdownMenuItem<int>(
                    value: day['value'],
                    child: Text(day['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedDay = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a day';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Time range
              const Text(
                'Time Range',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              
              const SizedBox(height: 8),
              
              // Start time
              InkWell(
                onTap: () => _selectStartTime(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start Time',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    _startTime.format(context),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // End time
              InkWell(
                onTap: () => _selectEndTime(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'End Time',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    _endTime.format(context),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Display selected time range
              Text(
                'Duration: ${_formatDuration(_timeOfDayToMinutes(_endTime) - _timeOfDayToMinutes(_startTime))}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveTimeSlot,
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
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
} 