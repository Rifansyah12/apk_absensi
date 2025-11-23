import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart'; // <- pakai ApiConfig
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final String baseUrl = ApiConfig.baseUrl;

  // GET attendance list
  static Future<List<dynamic>> getAttendance() async {
    final url = Uri.parse("$baseUrl/attendance/history");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    
    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body["data"];
    } else {
      throw Exception("Failed to fetch attendance");
    }
  }

  // CREATE attendance
  static Future<bool> createAttendance(Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/attendance");
    final response = await http.post(url, body: data);

    return response.statusCode == 201;
  }

  // UPDATE attendance
  static Future<bool> updateAttendance(
    int id,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse("$baseUrl/attendance/$id");
    final response = await http.put(url, body: data);

    return response.statusCode == 200;
  }

  // DELETE attendance by ID
  static Future<bool> deleteAttendance(int id) async {
    final url = Uri.parse("$baseUrl/attendance/$id");
    final response = await http.delete(url);

    return response.statusCode == 200;
  }
}
