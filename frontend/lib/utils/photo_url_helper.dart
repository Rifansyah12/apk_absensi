// lib/utils/photo_url_helper.dart
import 'package:apk_absensi/config/api.dart';

class PhotoUrlHelper {
  static String generatePhotoUrl(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) {
      return '';
    }

    // Jika photoPath sudah full URL, return langsung
    if (photoPath.startsWith('http')) {
      return photoPath;
    }

    // Jika photoPath adalah path relative, gabungkan dengan baseUrl
    String baseUrl = ApiConfig.baseUrl;

    // Hapus bagian '/api' dari baseUrl jika ada
    if (baseUrl.endsWith('/api')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 4);
    }

    // Pastikan photoPath tidak diawali dengan slash ganda
    if (photoPath.startsWith('/')) {
      return '$baseUrl$photoPath';
    } else {
      return '$baseUrl/$photoPath';
    }
  }
}
