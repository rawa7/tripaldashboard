import 'package:flutter/material.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
      ),
      body: const Center(
        child: Text('Activities Management Screen'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new activity
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 