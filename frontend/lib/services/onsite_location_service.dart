// lib/services/onsite_location_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:apk_absensi/config/api.dart';
import 'package:apk_absensi/models/onsite_location_model.dart';
import 'package:apk_absensi/utils/storage.dart';

class OnsiteLocationService {
  static final String _baseUrl = ApiConfig.baseUrl;

  static Future<List<OnsiteLocation>> getLocationsDivision(
    String division,
  ) async {
    try {
      final token = await Storage.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/onsite/locations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => OnsiteLocation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load locations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading locations: $e');
    }
  }

  static Future<OnsiteLocation> createLocation(
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await Storage.getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/onsite/locations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(
          response.body,
        )['data'];
        return OnsiteLocation.fromJson(responseData);
      } else {
        throw Exception('Failed to create location: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating location: $e');
    }
  }

  static Future<OnsiteLocation> updateLocation(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await Storage.getToken();
      final response = await http.put(
        Uri.parse('$_baseUrl/onsite/locations/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(
          response.body,
        )['data'];
        return OnsiteLocation.fromJson(responseData);
      } else {
        throw Exception('Failed to update location: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating location: $e');
    }
  }

  static Future<void> deleteLocation(int id) async {
    try {
      final token = await Storage.getToken();
      final response = await http.delete(
        Uri.parse('$_baseUrl/onsite/locations/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete location: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting location: $e');
    }
  }

  static Future<OnsiteLocation> toggleLocationStatus(int id) async {
    try {
      final token = await Storage.getToken();
      final response = await http.patch(
        Uri.parse('$_baseUrl/onsite/locations/$id/toggle'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(
          response.body,
        )['data'];
        return OnsiteLocation.fromJson(responseData);
      } else {
        throw Exception(
          'Failed to toggle location status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error toggling location status: $e');
    }
  }
}
