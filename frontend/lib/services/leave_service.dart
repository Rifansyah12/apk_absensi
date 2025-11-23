// lib/services/leave_service.dart - UPDATE
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:apk_absensi/models/leave_model.dart';
import 'package:apk_absensi/config/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaveService {
  static final String _baseUrl = ApiConfig.baseUrl;

  // Get semua cuti (tidak hanya pending)
  static Future<List<LeaveRequest>> getLeaves() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/leaves'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔍 Get leaves response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> leavesJson = data['data'];
          final leaves = leavesJson
              .map((json) => LeaveRequest.fromJson(json))
              .toList();
          print('✅ Loaded ${leaves.length} leaves');
          return leaves;
        } else {
          throw Exception(data['message'] ?? 'Failed to load leaves');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        final data = json.decode(response.body);
        throw Exception(
          data['message'] ??
              'Failed to load leaves. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error loading leaves: $e');
      rethrow;
    }
  }

  // Update status cuti (approve/reject) - TETAP SAMA
  static Future<void> updateLeaveStatus({
    required int leaveId,
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
        Uri.parse('$_baseUrl/leaves/$leaveId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': status, 'notes': notes}),
      );

      print('🔍 Update leave status response: ${response.statusCode}');
      print('🔍 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ Leave status updated successfully');
          return;
        } else {
          throw Exception(data['message'] ?? 'Failed to update leave status');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Leave request not found');
      } else {
        final data = json.decode(response.body);
        throw Exception(
          data['message'] ??
              'Failed to update leave status. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error updating leave status: $e');
      rethrow;
    }
  }
}
