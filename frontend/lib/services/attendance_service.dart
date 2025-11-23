// lib/services/attendance_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:apk_absensi/config/api.dart';
import 'package:apk_absensi/models/attendance_model.dart';
import 'package:apk_absensi/utils/storage.dart';

class AttendanceService {
  // Get all attendance (for admin)
  static Future<List<Attendance>> getAttendances({
    String? division,
    DateTime? startDate,
    DateTime? endDate,
    int? userId,
  }) async {
    try {
      final token = await Storage.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      var url = "${ApiConfig.baseUrl}/attendance";
      final params = <String>[];

      if (division != null) {
        params.add('division=$division');
      }
      if (startDate != null) {
        params.add('startDate=${startDate.toIso8601String().split('T')[0]}');
      }
      if (endDate != null) {
        params.add('endDate=${endDate.toIso8601String().split('T')[0]}');
      }
      if (userId != null) {
        params.add('userId=$userId');
      }

      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      print('📡 Fetching attendances from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          List<dynamic> attendancesJson = data['data'] ?? [];

          // ✅ PERBAIKAN: Handle parsing dengan try-catch untuk setiap item
          List<Attendance> attendances = [];
          for (var json in attendancesJson) {
            try {
              final attendance = Attendance.fromJson(json);
              attendances.add(attendance);
            } catch (e) {
              print('❌ Error parsing attendance item: $e');
              print('❌ Problematic JSON: $json');
              // Skip item yang error, continue dengan yang lain
              continue;
            }
          }

          print('✅ Successfully loaded ${attendances.length} attendances');
          return attendances;
        } else {
          throw Exception('Failed to load attendances: ${data['message']}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized (401) - Token invalid atau expired');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(
          'Failed to load attendances: ${response.statusCode} - ${errorBody['message'] ?? response.body}',
        );
      }
    } catch (e) {
      print('❌ Error di AttendanceService.getAttendances(): $e');
      rethrow;
    }
  }

  // Create manual attendance
  static Future<Attendance> createManualAttendance(
    Map<String, dynamic> attendanceData,
  ) async {
    try {
      final token = await Storage.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      print('📡 Creating manual attendance: $attendanceData');

      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/attendance/manual"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(attendanceData),
      );

      print(
        '📡 Create manual attendance response status: ${response.statusCode}',
      );
      print('📡 Create manual attendance response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return Attendance.fromJson(data['data']);
        } else {
          throw Exception(
            'Failed to create manual attendance: ${data['message']}',
          );
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          'Failed to create manual attendance: ${response.statusCode} - ${errorData['message'] ?? response.body}',
        );
      }
    } catch (e) {
      print('❌ Error di AttendanceService.createManualAttendance(): $e');
      rethrow;
    }
  }

  // Update attendance
  static Future<Attendance> updateAttendance(
    int id,
    Map<String, dynamic> attendanceData,
  ) async {
    try {
      final token = await Storage.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/attendance/$id"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(attendanceData),
      );

      print('📡 Update attendance response status: ${response.statusCode}');
      print('📡 Update attendance response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return Attendance.fromJson(data['data']);
        } else {
          throw Exception('Failed to update attendance: ${data['message']}');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          'Failed to update attendance: ${response.statusCode} - ${errorData['message'] ?? response.body}',
        );
      }
    } catch (e) {
      print('❌ Error di AttendanceService.updateAttendance(): $e');
      rethrow;
    }
  }

  // Delete attendance
  static Future<void> deleteAttendance(int attendanceId) async {
    try {
      final token = await Storage.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }
      final response = await http.delete(
        Uri.parse("${ApiConfig.baseUrl}/attendance/$attendanceId"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔍 Delete attendance response: ${response.statusCode}');
      print('🔍 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ Attendance deleted successfully');
          return;
        } else {
          throw Exception(data['message'] ?? 'Failed to delete attendance');
        }
      } else if (response.statusCode == 404) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Attendance not found');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 403) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Permission denied');
      } else {
        final data = json.decode(response.body);
        throw Exception(
          data['message'] ??
              'Failed to delete attendance. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error deleting attendance: $e');
      rethrow;
    }
  }

  // Get attendance by ID
  static Future<Attendance> getAttendanceById(int id) async {
    try {
      final token = await Storage.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/attendance/$id"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return Attendance.fromJson(data['data']);
        } else {
          throw Exception('Failed to load attendance: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load attendance: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error di AttendanceService.getAttendanceById(): $e');
      rethrow;
    }
  }

  static Future<void> updateManualAttendance(Map<String, dynamic> data) async {
    try {
      final token = await Storage.getToken();
      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }
      
      final response = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/manual"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      print('🔍 Update manual attendance response: ${response.statusCode}');
      print('🔍 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          print('✅ Attendance updated successfully');
          return;
        } else {
          throw Exception(
            responseData['message'] ?? 'Failed to update attendance',
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
          responseData['message'] ??
              'Failed to update attendance. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error updating attendance: $e');
      rethrow;
    }
  }
}
