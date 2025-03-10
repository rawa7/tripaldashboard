import 'package:flutter/material.dart';

class CitiesScreen extends StatelessWidget {
  const CitiesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cities'),
      ),
      body: const Center(
        child: Text('Cities Management Screen'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new city
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 