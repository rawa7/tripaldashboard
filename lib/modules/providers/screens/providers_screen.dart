import 'package:flutter/material.dart';

class ProvidersScreen extends StatelessWidget {
  const ProvidersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Providers'),
      ),
      body: const Center(
        child: Text('Providers Management Screen'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new provider
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 