import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/accommodation_image.dart';
import '../providers/accommodations_provider.dart';

class AccommodationImageCaptionEditor extends ConsumerStatefulWidget {
  final AccommodationImage image;
  
  const AccommodationImageCaptionEditor({
    Key? key,
    required this.image,
  }) : super(key: key);

  @override
  ConsumerState<AccommodationImageCaptionEditor> createState() => _AccommodationImageCaptionEditorState();
}

class _AccommodationImageCaptionEditorState extends ConsumerState<AccommodationImageCaptionEditor> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _captionController;
  late TextEditingController _captionArController;
  late TextEditingController _captionKuController;
  late TextEditingController _captionBadController;
  
  bool _isSubmitting = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize tab controller
    _tabController = TabController(length: 4, vsync: this);
    
    // Initialize text controllers
    _captionController = TextEditingController(text: widget.image.caption ?? '');
    _captionArController = TextEditingController(text: widget.image.captionAr ?? '');
    _captionKuController = TextEditingController(text: widget.image.captionKu ?? '');
    _captionBadController = TextEditingController(text: widget.image.captionBad ?? '');
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _captionController.dispose();
    _captionArController.dispose();
    _captionKuController.dispose();
    _captionBadController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Image Caption'),
      ),
      body: Column(
        children: [
          // Image preview
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Image.network(
              widget.image.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => 
                  const Center(child: Icon(Icons.image_not_supported, size: 50)),
            ),
          ),
          
          // Language tabs
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'English'),
              Tab(text: 'Arabic'),
              Tab(text: 'Kurdish'),
              Tab(text: 'Badinani'),
            ],
          ),
          
          // Caption fields
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // English caption
                _buildCaptionField(
                  controller: _captionController,
                  label: 'Caption (English)',
                  hintText: 'Enter image caption in English',
                ),
                
                // Arabic caption
                _buildCaptionField(
                  controller: _captionArController,
                  label: 'Caption (Arabic)',
                  hintText: 'Enter image caption in Arabic',
                  textDirection: TextDirection.rtl,
                ),
                
                // Kurdish caption
                _buildCaptionField(
                  controller: _captionKuController,
                  label: 'Caption (Kurdish)',
                  hintText: 'Enter image caption in Kurdish',
                ),
                
                // Badinani caption
                _buildCaptionField(
                  controller: _captionBadController,
                  label: 'Caption (Badinani)',
                  hintText: 'Enter image caption in Badinani',
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _saveCaption,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Caption'),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCaptionField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextDirection? textDirection,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: const OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
        maxLines: 5,
        textDirection: textDirection,
      ),
    );
  }
  
  Future<void> _saveCaption() async {
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      final service = ref.read(accommodationsServiceProvider);
      
      // Create updated image with new captions
      final updatedImage = widget.image.copyWith(
        caption: _captionController.text.trim().isNotEmpty ? _captionController.text.trim() : null,
        captionAr: _captionArController.text.trim().isNotEmpty ? _captionArController.text.trim() : null,
        captionKu: _captionKuController.text.trim().isNotEmpty ? _captionKuController.text.trim() : null,
        captionBad: _captionBadController.text.trim().isNotEmpty ? _captionBadController.text.trim() : null,
      );
      
      // Update the image
      final success = await service.updateAccommodationImage(updatedImage);
      
      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Caption updated successfully')),
        );
        
        // Refresh the data and close the screen
        ref.refresh(accommodationImagesProvider(widget.image.accommodationId));
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update caption')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating caption: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
} 