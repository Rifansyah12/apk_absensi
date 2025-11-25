// lib/utils/photo_url_helper.dart
import 'package:apk_absensi/config/api.dart';
// lib/utils/photo_url_helper.dart
class PhotoUrlHelper {
  static String generatePhotoUrl(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) {
      return '';
    }

    // Jika sudah full URL, langsung return
    if (photoPath.startsWith('http')) {
      print('🖼️ Photo is already full URL: $photoPath');
      return photoPath;
    }

    String baseUrl = ApiConfig.baseUrl;

    // Hapus /api dari baseUrl jika ada
    if (baseUrl.contains('/api')) {
      baseUrl = baseUrl.replaceAll('/api', '');
    }

    String cleanPath = photoPath;

    // Handle berbagai format path
    if (cleanPath.startsWith('/public')) {
      cleanPath = cleanPath.substring(7);
    } else if (cleanPath.startsWith('public')) {
      cleanPath = cleanPath.substring(6);
    }

    // Pastikan path dimulai dengan /
    if (!cleanPath.startsWith('/')) {
      cleanPath = '/$cleanPath';
    }

    // Hapus slash ganda
    if (baseUrl.endsWith('/') && cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    final url = '$baseUrl$cleanPath';
    print('🖼️ Generated photo URL: $url');
    return url;
  }

  // ✅ METHOD BARU: Coba multiple paths untuk fallback
  static List<String> generateAllPossibleUrls(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) return [];
    
    final baseUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    final urls = <String>[];
    
    // Original path
    urls.add('$baseUrl$photoPath');
    
    // Dengan /public prefix
    if (!photoPath.startsWith('/public')) {
      urls.add('$baseUrl/public$photoPath');
    }
    
    // Tanpa leading slash
    if (photoPath.startsWith('/')) {
      urls.add('$baseUrl${photoPath.substring(1)}');
    }
    
    return urls;
  }
}