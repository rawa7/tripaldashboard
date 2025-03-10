import 'package:flutter/material.dart';

class PhotosScreen extends StatelessWidget {
  const PhotosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos Management'),
      ),
      body: const Center(
        child: Text('Manage your photos here'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new photos
        },
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
} 