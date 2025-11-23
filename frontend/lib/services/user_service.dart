import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:apk_absensi/config/api.dart';
import 'package:apk_absensi/models/user_model.dart';
import 'package:apk_absensi/utils/storage.dart';
import 'package:apk_absensi/utils/photo_url_helper.dart';
import 'package:image_picker/image_picker.dart';

class UserService {
  static String getPhotoUrl(String? photoPath) {
    return PhotoUrlHelper.generatePhotoUrl(photoPath);
  }

  static Future<User> updateUser(int id, Map<String, dynamic> userData) async {
    try {
      final token = await Storage.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final dio = Dio();
      dio.options.headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      };

      // Siapkan form-data
      final formData = FormData.fromMap({
        'employeeId': userData['employeeId'],
        'name': userData['name'],
        'email': userData['email'],
        'division': userData['division'],
        'position': userData['position'],
        'joinDate': userData['joinDate'],
        if (userData['phone'] != null) 'phone': userData['phone'],
        if (userData['address'] != null) 'address': userData['address'],
      });

      // FOTO (Mengikuti pola ProfileService)
      if (userData['photo'] != null && userData['photo'] is XFile) {
        final XFile photo = userData['photo'];
        final bytes = await photo.readAsBytes();

        final String fileName =
            "user_${id}_${DateTime.now().millisecondsSinceEpoch}.${photo.name.split('.').last}";

        formData.files.add(
          MapEntry('photo', MultipartFile.fromBytes(bytes, filename: fileName)),
        );

        print('📸 Foto siap diupload: $fileName (${bytes.length} bytes)');
      }

      final response = await dio.put(
        "${ApiConfig.baseUrl}/users/$id",
        data: formData,
      );

      print("📡 Response status: ${response.statusCode}");
      print("📡 Response body: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        return User.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? "Gagal update user");
      }
    } catch (e) {
      print("❌ Error updateUser(): $e");
      throw Exception("Gagal update user: $e");
    }
  }

  // CREATE USER - juga diperbaiki
  static Future<User> createUser(Map<String, dynamic> userData) async {
    try {
      final token = await Storage.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${ApiConfig.baseUrl}/users"),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Text fields
      request.fields['employeeId'] = userData['employeeId'];
      request.fields['name'] = userData['name'];
      request.fields['email'] = userData['email'];
      request.fields['division'] = userData['division'];
      request.fields['position'] = userData['position'];
      request.fields['joinDate'] = userData['joinDate'];
      request.fields['password'] = userData['password'] ?? 'password123';

      // Field opsional
      if (userData['phone'] != null) {
        request.fields['phone'] = userData['phone'];
      }
      if (userData['address'] != null) {
        request.fields['address'] = userData['address'];
      }

      // Handle foto
      if (userData['photo'] != null && userData['photo'] is XFile) {
        final XFile photoFile = userData['photo'];
        final bytes = await photoFile.readAsBytes();

        final ext = photoFile.name.split('.').last;
        final multipartFile = http.MultipartFile.fromBytes(
          'photo',
          bytes,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.$ext',
          contentType: http.MediaType('image', ext),
        );

        request.files.add(multipartFile);
        print('📸 Foto dikirim: ${photoFile.name} (${bytes.length} bytes)');
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print('📡 Create user response status: ${response.statusCode}');
      print('📡 Create user response body: $responseData');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(responseData);
        if (data['success']) {
          if (data['data']['photo'] != null &&
              data['data']['photo'] is String) {
            // ✅ Cache busting untuk create juga
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            data['data']['photo'] =
                '${getPhotoUrl(data['data']['photo'])}?t=$timestamp';
          }
          return User.fromJson(data['data']);
        } else {
          throw Exception('Failed to create user: ${data['message']}');
        }
      } else {
        throw Exception(
          'Failed to create user: ${response.statusCode} - $responseData',
        );
      }
    } catch (e) {
      print('❌ Error di UserService.createUser(): $e');
      rethrow;
    }
  }

  static Future<List<User>> getUsers() async {
    try {
      final token = await Storage.getToken();

      if (token == null) {
        throw Exception('❌ Token tidak ditemukan di storage');
      }

      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/users"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success']) {
          List<dynamic> usersJson = data['data'];

          return usersJson.map((json) {
            if (json['photo'] != null && json['photo'] is String) {
              // ✅ Cache busting untuk getUsers juga
              final timestamp = DateTime.now().millisecondsSinceEpoch;
              json['photo'] = '${getPhotoUrl(json['photo'])}?t=$timestamp';
            }
            return User.fromJson(json);
          }).toList();
        } else {
          throw Exception('Failed to load users: ${data['message']}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('❌ Unauthorized (401) - Token invalid atau expired');
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error di UserService.getUsers(): $e');
      rethrow;
    }
  }

  static Future<User> getUserById(int id) async {
    try {
      final token = await Storage.getToken();

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/users/$id"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success']) {
          if (data['data']['photo'] != null &&
              data['data']['photo'] is String) {
            // ✅ Cache busting untuk getUserById juga
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            data['data']['photo'] =
                '${getPhotoUrl(data['data']['photo'])}?t=$timestamp';
          }
          return User.fromJson(data['data']);
        } else {
          throw Exception('Failed to load user: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error di UserService.getUserById(): $e');
      rethrow;
    }
  }

  // Helper method untuk handle photo upload dengan validasi yang lebih baik
  static Future<void> _addPhotoToRequest(
    http.MultipartRequest request,
    dynamic photoData,
  ) async {
    try {
      if (photoData == null) return;

      // Handle XFile (dari image_picker)
      if (photoData is XFile) {
        final bytes = await photoData.readAsBytes();

        // ✅ VALIDASI: Pastikan file adalah gambar dan tidak kosong
        if (bytes.isEmpty) {
          print('❌ File foto kosong');
          return;
        }

        // ✅ Dapatkan ekstensi file yang benar
        String fileName = photoData.name;
        String fileExtension = 'jpg'; // default

        if (fileName.contains('.')) {
          fileExtension = fileName.split('.').last.toLowerCase();
        }

        // ✅ Validasi ekstensi file gambar
        final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
        if (!allowedExtensions.contains(fileExtension)) {
          print('❌ Ekstensi file tidak diizinkan: $fileExtension');
          fileExtension = 'jpg'; // fallback to jpg
        }

        // ✅ Buat filename dengan timestamp
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final finalFileName = 'profile_$timestamp.$fileExtension';

        // ✅ Buat multipart file
        final multipartFile = http.MultipartFile.fromBytes(
          'photo',
          bytes,
          filename: finalFileName,
        );

        request.files.add(multipartFile);
        print(
          '✅ Foto berhasil ditambahkan ke request: $finalFileName (${bytes.length} bytes)',
        );
      }
    } catch (e) {
      print('❌ Error menambahkan foto ke request: $e');
      // Jangan throw error agar operasi tetap berjalan tanpa foto
    }
  }

  static Future<void> deleteUser(int id) async {
    try {
      final token = await Storage.getToken();

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.delete(
        Uri.parse("${ApiConfig.baseUrl}/users/$id"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete user: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error di UserService.deleteUser(): $e');
      rethrow;
    }
  }

  static Future<void> restoreUser(int id) async {
    try {
      final token = await Storage.getToken();

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.patch(
        Uri.parse("${ApiConfig.baseUrl}/users/$id/restore"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to restore user: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error di UserService.restoreUser(): $e');
      rethrow;
    }
  }
}
