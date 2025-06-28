import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  // Ambil gambar dari galeri (kompatibel dengan web dan mobile)
  static Future<File?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
    return null;
  }

  // Ambil foto dari kamera (hanya untuk mobile)
  static Future<File?> takePhoto() async {
    try {
      if (kIsWeb) {
        // Untuk web, gunakan gallery picker sebagai fallback
        return await pickImage();
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo != null) {
        return File(photo.path);
      }
    } catch (e) {
      print('Error taking photo: $e');
      // Fallback ke gallery picker
      return await pickImage();
    }
    return null;
  }

  // Hapus gambar (placeholder untuk sekarang)
  static Future<void> deleteImage(String? imagePath) async {
    // Untuk web, tidak perlu menghapus file
    if (kIsWeb) return;

    if (imagePath != null) {
      try {
        final File imageFile = File(imagePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      } catch (e) {
        print('Error deleting image: $e');
      }
    }
  }
}
