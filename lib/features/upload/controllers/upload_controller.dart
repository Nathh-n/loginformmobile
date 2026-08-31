import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/upload_repository.dart';

class UploadController extends ChangeNotifier {
  final _picker = ImagePicker();
  final _uploadRepository = UploadRepository();

  File? _selectedImage;
  bool _isUploading = false;
  String? _resultUrl;
  String? _errorMessage;

  File? get selectedImage => _selectedImage;
  bool get isUploading => _isUploading;
  String? get resultUrl => _resultUrl;
  String? get errorMessage => _errorMessage;

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    _selectedImage = File(pickedFile.path);
    _resultUrl = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> upload({required bool useBase64}) async {
    final image = _selectedImage;
    if (image == null) return;

    _isUploading = true;
    _resultUrl = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = useBase64
          ? await _uploadRepository.uploadBase64(image)
          : await _uploadRepository.uploadMultipart(image);
      _resultUrl = result.url;
    } on UploadException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  void clear() {
    _selectedImage = null;
    _resultUrl = null;
    _errorMessage = null;
    _isUploading = false;
    notifyListeners();
  }
}