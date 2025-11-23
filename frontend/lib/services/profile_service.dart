// services/profile_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apk_absensi/config/api.dart';
import 'package:apk_absensi/models/update_profile_model.dart';
import 'package:apk_absensi/models/profile_model.dart';

class ProfileService {
  final Dio _dio = Dio();

  Future<UpdateProfileResponse> updateProfile({
    String? password,
    String? currentPassword,
    List<int>? photoBytes,
    String? fileName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      // Setup headers dengan token
      _dio.options.headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      };

      final formData = FormData.fromMap({
        if (password != null && password.isNotEmpty) 'password': password,
        if (currentPassword != null && currentPassword.isNotEmpty) 
          'currentPassword': currentPassword,
        if (photoBytes != null && fileName != null)
          'photo': await MultipartFile.fromBytes(
            photoBytes,
            filename: fileName,
          ),
      });

      final response = await _dio.put(
        '${ApiConfig.baseUrl}/auth/profile',
        data: formData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return UpdateProfileResponse.fromJson(responseData);
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengupdate profile');
      }
    } on DioException catch (e) {
      print('Dio Error: ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw Exception('Token tidak valid. Silakan login kembali.');
      } else if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['message'] ?? 'Data tidak valid');
      } else {
        throw Exception('Terjadi kesalahan: ${e.message}');
      }
    } catch (e) {
      print('Error updating profile: $e');
      throw Exception('Gagal mengupdate profile: $e');
    }
  }

  Future<Profile> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      // Setup headers untuk request GET
      _dio.options.headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await _dio.get(
        '${ApiConfig.baseUrl}/auth/profile',
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          return Profile.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Gagal memuat profil');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.data}');
      }
    } on DioException catch (e) {
      print('Dio Error getProfile: ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw Exception('Token tidak valid. Silakan login kembali.');
      }
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat profil');
    } catch (e) {
      print('Error getting profile: $e');
      throw e;
    }
  }

  // Method untuk build URL foto profil yang lengkap - DIPERBAIKI
  String getProfilePhotoUrl(String? photoPath) {
    if (photoPath == null || photoPath.isEmpty) {
      return '';
    }
        
    // Jika photoPath sudah berupa URL lengkap, return langsung
    if (photoPath.startsWith('http')) {
      return photoPath;
    }
    
    // SELALU gunakan base URL tanpa /api untuk static files
    String baseUrl = ApiConfig.baseUrl;
    
    // Hapus /api dari baseUrl jika ada
    if (baseUrl.contains('/api')) {
      baseUrl = baseUrl.replaceAll('/api', '');
    }
    
    // Pastikan baseUrl tidak berakhir dengan slash ganda
    if (baseUrl.endsWith('/') && photoPath.startsWith('/')) {
      photoPath = photoPath.substring(1);
    }
    
    final photoUrl = '$baseUrl$photoPath';    
    return photoUrl;
  }

  // Validasi tipe file gambar
  bool isImageFile(String fileName) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final lowerFileName = fileName.toLowerCase();
    return imageExtensions.any((ext) => lowerFileName.endsWith(ext));
  }
}