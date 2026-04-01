import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static Future<File?> pickFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    return image != null ? File(image.path) : null;
  }
}
