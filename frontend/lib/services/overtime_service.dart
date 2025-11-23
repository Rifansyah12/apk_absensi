// lib/services/overtime_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:apk_absensi/models/overtime_model.dart';
import 'package:apk_absensi/config/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OvertimeService {
  static final String _baseUrl = ApiConfig.baseUrl;

  // Get semua overtime
  static Future<List<OvertimeRequest>> getOvertimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/overtime'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔍 Get overtimes response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> overtimesJson = data['data'];
          final overtimes = overtimesJson
              .map((json) => OvertimeRequest.fromJson(json))
              .toList();
          print('✅ Loaded ${overtimes.length} overtimes');
          return overtimes;
        } else {
          throw Exception(data['message'] ?? 'Failed to load overtimes');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        final data = json.decode(response.body);
        throw Exception(
          data['message'] ??
              'Failed to load overtimes. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error loading overtimes: $e');
      rethrow;
    }
  }

  // Update status overtime (approve/reject)
  static Future<void> updateOvertimeStatus({
    required int overtimeId,
    required String status,
    String? notes,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.patch(
        Uri.parse('$_baseUrl/overtime/$overtimeId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': status, 'notes': notes}),
      );

      print('🔍 Update overtime status response: ${response.statusCode}');
      print('🔍 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ Overtime status updated successfully');
          return;
        } else {
          throw Exception(
            data['message'] ?? 'Failed to update overtime status',
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Overtime request not found');
      } else {
        final data = json.decode(response.body);
        throw Exception(
          data['message'] ??
              'Failed to update overtime status. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error updating overtime status: $e');
      rethrow;
    }
  }
}
