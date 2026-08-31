import 'dart:io';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

class ImagePreview extends StatelessWidget {
  final File? imageFile;

  const ImagePreview({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: imageFile == null
            ? Center(
                child: Icon(
                  FLucideIcons.image,
                  size: 48,
                  color: theme.colors.mutedForeground,
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(imageFile!, fit: BoxFit.fill),
              ),
      ),
    );
  }
}