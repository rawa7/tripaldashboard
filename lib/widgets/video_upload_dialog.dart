import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:video_compress/video_compress.dart';
import 'package:tripaldashboard/core/models/translation.dart';

class VideoUploadDialog extends StatefulWidget {
  final Function(
    File videoFile,
    bool isPrimary,
    File? thumbnailFile,
  ) onUpload;

  const VideoUploadDialog({
    Key? key,
    required this.onUpload,
  }) : super(key: key);

  @override
  State<VideoUploadDialog> createState() => _VideoUploadDialogState();
}

class _VideoUploadDialogState extends State<VideoUploadDialog> {
  File? _videoFile;
  File? _thumbnailFile;
  bool _isPrimary = false;
  bool _isLoading = false;

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickThumbnail() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _thumbnailFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload Video'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _pickVideo,
              child: const Text('Select Video'),
            ),
            if (_videoFile != null) ...[
              const SizedBox(height: 8),
              Text('Selected video: ${p.basename(_videoFile!.path)}'),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _pickThumbnail,
              child: const Text('Select Thumbnail (Optional)'),
            ),
            if (_thumbnailFile != null) ...[
              const SizedBox(height: 8),
              Text('Selected thumbnail: ${p.basename(_thumbnailFile!.path)}'),
            ],
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Set as primary video'),
              value: _isPrimary,
              onChanged: _isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _isPrimary = value ?? false;
                      });
                    },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading || _videoFile == null
              ? null
              : () async {
                  setState(() {
                    _isLoading = true;
                  });

                  await widget.onUpload(
                    _videoFile!,
                    _isPrimary,
                    _thumbnailFile,
                  );

                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Upload'),
        ),
      ],
    );
  }
} 