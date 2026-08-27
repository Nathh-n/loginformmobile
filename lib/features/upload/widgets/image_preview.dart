import 'dart:io';
import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final File? imageFile;

  const ImagePreview({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: imageFile == null
            ? const Center(
                child: Icon(Icons.image_outlined, size: 48, color: Colors.grey),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(imageFile!, fit: BoxFit.fill),
              ),
      ),
    );
  }
}