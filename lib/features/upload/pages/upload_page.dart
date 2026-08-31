import 'package:cached_network_image/cached_network_image.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import '../../auth/models/user_model.dart';
import '../../auth/repositories/auth_repository.dart';
import '../controllers/upload_controller.dart';
import '../widgets/image_preview.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  final UploadController controller;

  const UploadPage({super.key, required this.controller});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _authRepository = AuthRepository();
  late final Future<UserModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _authRepository.getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder<UserModel>(
                future: _profileFuture,
                builder: (context, snapshot) => _buildProfile(snapshot.data),
              ),
              const SizedBox(height: 16),
              ImagePreview(imageFile: widget.controller.selectedImage),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FButton(
                      variant: FButtonVariant.outline,
                      onPress: widget.controller.isUploading
                          ? null
                          : () => widget.controller.pickImage(
                                ImageSource.gallery,
                              ),
                      prefix: const Icon(FLucideIcons.imageUp),
                      child: const Text('Galeri'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FButton(
                      variant: FButtonVariant.outline,
                      onPress: widget.controller.isUploading
                          ? null
                          : () => widget.controller.pickImage(
                                ImageSource.camera,
                              ),
                      prefix: const Icon(FLucideIcons.camera),
                      child: const Text('Kamera'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FButton(
                onPress:
                    widget.controller.selectedImage == null ||
                        widget.controller.isUploading
                    ? null
                    : () => widget.controller.upload(useBase64: false),
                prefix: const Icon(FLucideIcons.cloudUpload),
                child: const Text('Upload Langsung (File Asli)'),
              ),
              const SizedBox(height: 8),
              FButton(
                onPress:
                    widget.controller.selectedImage == null ||
                        widget.controller.isUploading
                    ? null
                    : () => widget.controller.upload(useBase64: true),
                prefix: const Icon(FLucideIcons.binary),
                child: const Text('Upload via Base64'),
              ),
              const SizedBox(height: 20),
              if (widget.controller.isUploading)
                const Center(child: CircularProgressIndicator()),
              if (widget.controller.errorMessage != null)
                Text(
                  widget.controller.errorMessage!,
                  style: TextStyle(
                    color: context.theme.colors.destructive,
                  ),
                ),
              if (widget.controller.resultUrl != null) ...[
                const Text('Berhasil! URL gambar:'),
                const SizedBox(height: 4),
                SelectableText(
                  widget.controller.resultUrl!,
                  style: TextStyle(color: context.theme.colors.primary),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfile(UserModel? user) {
    final theme = context.theme;
    final avatarUrl = user?.avatar ?? '';

    Widget fallback() => Container(
          width: 40,
          height: 40,
          color: theme.colors.muted,
          child: Icon(
            FLucideIcons.user,
            size: 22,
            color: theme.colors.mutedForeground,
          ),
        );

    return Row(
      children: [
        if (avatarUrl.isEmpty)
          ClipOval(child: fallback())
        else
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: avatarUrl,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              placeholder: (context, url) => fallback(),
              errorWidget: (context, url, error) => fallback(),
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            user?.name ?? '',
            style: theme.typography.body.lg.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}