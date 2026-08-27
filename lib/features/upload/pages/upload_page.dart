import 'package:flutter/material.dart';
import '../controllers/upload_controller.dart';
import '../widgets/image_preview.dart';

class UploadPage extends StatelessWidget {
  final UploadController controller;

  const UploadPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ImagePreview(imageFile: controller.selectedImage),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: controller.isUploading
                    ? null
                    : controller.pickImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Pilih Gambar'),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: controller.selectedImage == null ||
                        controller.isUploading
                    ? null
                    : () => controller.upload(useBase64: false),
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('Upload Langsung (File Asli)'),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: controller.selectedImage == null ||
                        controller.isUploading
                    ? null
                    : () => controller.upload(useBase64: true),
                icon: const Icon(Icons.data_object),
                label: const Text('Upload via Base64'),
              ),
              const SizedBox(height: 20),
              if (controller.isUploading)
                const Center(child: CircularProgressIndicator()),
              if (controller.errorMessage != null)
                Text(
                  controller.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              if (controller.resultUrl != null) ...[
                const Text('Berhasil! URL gambar:'),
                const SizedBox(height: 4),
                SelectableText(
                  controller.resultUrl!,
                  style: const TextStyle(color: Colors.blue),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
