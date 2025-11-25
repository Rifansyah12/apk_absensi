import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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

      // ✅ PERBAIKAN: Handle photoBytes dengan validasi yang ketat
      if (userData['photoBytes'] != null &&
          userData['photoBytes'] is Uint8List) {
        final Uint8List photoBytes = userData['photoBytes'];

        // Validasi bahwa photoBytes tidak kosong dan memiliki ukuran yang wajar
        if (photoBytes.isEmpty) {
          print('⚠️ Photo bytes kosong, skip upload foto');
        } else if (photoBytes.length < 100) {
          print(
            '⚠️ Photo bytes terlalu kecil: ${photoBytes.length} bytes, mungkin tidak valid',
          );
        } else {
          print(
            '📸 Mengirim photo bytes untuk update: ${photoBytes.length} bytes',
          );

          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = "user_${id}_$timestamp.jpg";

          formData.files.add(
            MapEntry(
              'photo',
              MultipartFile.fromBytes(
                photoBytes,
                filename: fileName,
                contentType: MediaType('image', 'jpeg'),
              ),
            ),
          );
        }
      } else {
        print(
          'ℹ️ Tidak ada photoBytes yang dikirim atau tipe data tidak sesuai',
        );
      }

      final response = await dio.put(
        "${ApiConfig.baseUrl}/users/$id",
        data: formData,
      );

      print("📡 Update user response status: ${response.statusCode}");
      print("📡 Update user response data: ${response.data}");

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

  static Future<User> createUser(Map<String, dynamic> userData) async {
    try {
      final token = await Storage.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      // Gunakan Dio untuk form data yang lebih reliable
      final dio = Dio();
      dio.options.headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      };

      // Siapkan form data
      final formData = FormData.fromMap({
        'employeeId': userData['employeeId'],
        'name': userData['name'],
        'email': userData['email'],
        'division': userData['division'],
        'position': userData['position'],
        'joinDate': userData['joinDate'],
        'password': userData['password'] ?? 'password123',
        if (userData['phone'] != null) 'phone': userData['phone'],
        if (userData['address'] != null) 'address': userData['address'],
      });

      // ✅ PERBAIKAN: Handle photoBytes dengan cara yang lebih robust
      if (userData['photoBytes'] != null &&
          userData['photoBytes'] is Uint8List) {
        final Uint8List photoBytes = userData['photoBytes'];

        // Validasi bahwa photoBytes tidak kosong
        if (photoBytes.isEmpty) {
          print('⚠️ Photo bytes kosong, skip upload foto');
        } else {
          print('📸 Mengirim photo bytes: ${photoBytes.length} bytes');

          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'user_$timestamp.jpg';

          formData.files.add(
            MapEntry(
              'photo',
              MultipartFile.fromBytes(
                photoBytes,
                filename: fileName,
                contentType: MediaType('image', 'jpeg'),
              ),
            ),
          );
        }
      }

      final response = await dio.post(
        "${ApiConfig.baseUrl}/users",
        data: formData,
      );

      print('📡 Create user response status: ${response.statusCode}');
      print('📡 Create user response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return User.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to create user');
        }
      } else {
        throw Exception('Failed to create user: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error di UserService.createUser(): $e');
      rethrow;
    }
  }

  // Di UserService - HAPUS bagian yang mengubah photo path menjadi URL
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
          // ✅ PERBAIKAN: JANGAN ubah photo path di sini
          // Biarkan photo path tetap sebagai path relatif
          // PhotoUrlHelper akan handle di UI
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

  // Juga di getUsers() - HAPUS bagian yang mengubah photo path
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
            // ✅ PERBAIKAN: JANGAN ubah photo path di sini
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
  } // ✅ PERBAIKAN: Helper method untuk handle photo upload yang mendukung kedua tipe

  static Future<void> _addPhotoToRequest(
    http.MultipartRequest request,
    dynamic photoData,
  ) async {
    try {
      if (photoData == null) return;

      // Handle Uint8List (dari web)
      if (photoData is Uint8List) {
        if (photoData.isEmpty) {
          print('❌ Photo bytes kosong');
          return;
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'profile_$timestamp.jpg';

        final multipartFile = http.MultipartFile.fromBytes(
          'photo',
          photoData,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        );

        request.files.add(multipartFile);
        print(
          '✅ Photo bytes berhasil ditambahkan: $fileName (${photoData.length} bytes)',
        );
      }
      // Handle XFile (dari mobile image_picker)
      else if (photoData is XFile) {
        final bytes = await photoData.readAsBytes();

        if (bytes.isEmpty) {
          print('❌ File foto kosong');
          return;
        }

        String fileName = photoData.name;
        String fileExtension = 'jpg';

        if (fileName.contains('.')) {
          fileExtension = fileName.split('.').last.toLowerCase();
        }

        final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
        if (!allowedExtensions.contains(fileExtension)) {
          print('❌ Ekstensi file tidak diizinkan: $fileExtension');
          fileExtension = 'jpg';
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final finalFileName = 'profile_$timestamp.$fileExtension';

        final multipartFile = http.MultipartFile.fromBytes(
          'photo',
          bytes,
          filename: finalFileName,
          contentType: MediaType('image', fileExtension),
        );

        request.files.add(multipartFile);
        print(
          '✅ Photo file berhasil ditambahkan: $finalFileName (${bytes.length} bytes)',
        );
      }
    } catch (e) {
      print('❌ Error menambahkan foto ke request: $e');
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
