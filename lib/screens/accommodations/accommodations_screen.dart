import 'package:flutter/material.dart';

class AccommodationsScreen extends StatelessWidget {
  const AccommodationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accommodations'),
      ),
      body: const Center(
        child: Text('Accommodations Management Screen'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add accommodations screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 