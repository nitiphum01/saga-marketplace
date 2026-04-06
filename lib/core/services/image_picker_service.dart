import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _imagePicker;

  ImagePickerService({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  Future<XFile?> pickFromCamera() {
    return _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1600,
    );
  }

  Future<XFile?> pickFromGallery() {
    return _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );
  }

  Future<List<XFile>> pickMultiFromGallery() {
    return _imagePicker.pickMultiImage(imageQuality: 85, maxWidth: 1600);
  }
}
