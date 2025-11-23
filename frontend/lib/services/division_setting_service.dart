// lib/services/division_setting_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:apk_absensi/models/division_setting_model.dart';
import 'package:apk_absensi/config/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DivisionSettingService {
  static final String _baseUrl = ApiConfig.baseUrl;

  // Get division setting
  static Future<DivisionSetting> getDivisionSetting(String division) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/division-settings/$division'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔍 Get division setting response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final setting = DivisionSetting.fromJson(data['data']);
          print('✅ Loaded division setting for $division');
          return setting;
        } else {
          throw Exception(data['message'] ?? 'Failed to load division setting');
        }
      } else if (response.statusCode == 404) {
        // Return default setting if not found
        print('⚠️ Division setting not found, returning default');
        return DivisionSettingData.getDefaultSetting(division);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        final data = json.decode(response.body);
        throw Exception(
          data['message'] ??
              'Failed to load division setting. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error loading division setting: $e');
      rethrow;
    }
  }

  // Create division setting
  static Future<void> createDivisionSetting(DivisionSetting setting) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/division-settings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(setting.toJson()),
      );

      print('🔍 Create division setting response: ${response.statusCode}');
      print('🔍 Request body: ${setting.toJson()}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ Division setting created successfully');
          return;
        } else {
          throw Exception(
            data['message'] ?? 'Failed to create division setting',
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 409) {
        throw Exception('Division setting already exists');
      } else {
        final data = json.decode(response.body);
        throw Exception(
          data['message'] ??
              'Failed to create division setting. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error creating division setting: $e');
      rethrow;
    }
  }

  // Update division setting
  static Future<void> updateDivisionSetting(
    String division,
    DivisionSetting setting,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/division-settings/$division'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(setting.toJson()),
      );

      print('🔍 Update division setting response: ${response.statusCode}');
      print('🔍 Request body: ${setting.toJson()}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('✅ Division setting updated successfully');
          return;
        } else {
          throw Exception(
            data['message'] ?? 'Failed to update division setting',
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Division setting not found');
      } else {
        final data = json.decode(response.body);
        throw Exception(
          data['message'] ??
              'Failed to update division setting. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error updating division setting: $e');
      rethrow;
    }
  }

  // Get all division settings
  static Future<List<DivisionSetting>> getAllDivisionSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      // Since we don't have an endpoint for all settings, we'll fetch each one
      final List<DivisionSetting> settings = [];

      for (final division in DivisionSettingData.divisions) {
        try {
          final setting = await getDivisionSetting(division);
          settings.add(setting);
        } catch (e) {
          print('⚠️ Failed to load setting for $division: $e');
          // Add default setting if failed to load
          settings.add(DivisionSettingData.getDefaultSetting(division));
        }
      }

      return settings;
    } catch (e) {
      print('❌ Error loading all division settings: $e');
      rethrow;
    }
  }
}
