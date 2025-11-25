// lib/config/api.dart - PERBAIKAN UNTUK HANDLE ROUTE NOT FOUND
class ApiConfig {
  static const String baseUrl = "http://localhost:3000/api";
  static const String baseUrlWithoutApi = "http://localhost:3000";
  
  static String getPhotoUrl(String? path) {
    try {
      if (path == null || path.isEmpty) {
        print('❌ Photo path is null or empty');
        return '';
      }
      
      print('🔧 Processing photo path: $path');
      
      // Jika sudah URL lengkap, return langsung
      if (path.startsWith('http')) {
        print('✅ Already full URL: $path');
        return path;
      }
      
      String baseUrl = baseUrlWithoutApi;
      
      // ✅ PERBAIKAN: Handle path yang dimulai dengan /public/
      if (path.startsWith('/public/')) {
        // Coba akses dengan path /public/ (default)
        final urlWithPublic = '$baseUrl$path';
        print('🔧 Trying with /public/ prefix: $urlWithPublic');
        return urlWithPublic;
      }
      
      // ✅ PERBAIKAN: Jika path tidak ada /public/, coba tambahkan
      if (!path.startsWith('/public/') && path.startsWith('/uploads/')) {
        final urlWithPublic = '$baseUrl/public$path';
        print('🔧 Added /public to /uploads path: $urlWithPublic');
        return urlWithPublic;
      }
      
      // ✅ PERBAIKAN: Jika path relatif tanpa slash
      if (!path.startsWith('/')) {
        final urlWithPublic = '$baseUrl/public/uploads/profiles/$path';
        print('🔧 Relative path converted: $urlWithPublic');
        return urlWithPublic;
      }
      
      // Default case - langsung gabungkan dengan baseUrl
      final defaultUrl = '$baseUrl$path';
      print('🔧 Default URL: $defaultUrl');
      return defaultUrl;
      
    } catch (e) {
      print('❌ Error in getPhotoUrl: $e');
      return '';
    }
  }
}