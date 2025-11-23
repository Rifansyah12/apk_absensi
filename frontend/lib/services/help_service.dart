// services/help_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apk_absensi/config/api.dart';

class HelpService {
  Future<HelpResponse> getHelpData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/help'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return HelpResponse.fromJson(responseData['data']);
        } else {
          throw Exception(
            responseData['message'] ?? 'Gagal memuat data bantuan',
          );
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error getting help data: $e');
      throw e;
    }
  }

  Future<List<HelpContent>> getAllHelpContent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/help/admin/all'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'];
          return data.map((e) => HelpContent.fromJson(e)).toList();
        } else {
          throw Exception(
            responseData['message'] ?? 'Gagal memuat data bantuan',
          );
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error getting all help content: $e');
      throw e;
    }
  }

  Future<void> createHelpContent({
    String? division,
    required String title,
    required String content,
    required String type,
    int order = 0,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/help/admin'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'division': division,
          'title': title,
          'content': content,
          'type': type,
          'order': order,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] != true) {
          throw Exception(
            responseData['message'] ?? 'Gagal membuat konten bantuan',
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal membuat konten bantuan');
      }
    } catch (e) {
      print('Error creating help content: $e');
      throw e;
    }
  }

  Future<void> updateHelpContent({
    required int id,
    String? division,
    String? title,
    String? content,
    String? type,
    int? order,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      // Hanya kirim field yang diubah
      final Map<String, dynamic> updateData = {};
      if (division != null) updateData['division'] = division;
      if (title != null) updateData['title'] = title;
      if (content != null) updateData['content'] = content;
      if (type != null) updateData['type'] = type;
      if (order != null) updateData['order'] = order;

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/help/admin/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] != true) {
          throw Exception(
            responseData['message'] ?? 'Gagal mengupdate konten bantuan',
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Gagal mengupdate konten bantuan',
        );
      }
    } catch (e) {
      print('Error updating help content: $e');
      throw e;
    }
  }

  Future<void> deleteHelpContent(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/help/admin/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] != true) {
          throw Exception(
            responseData['message'] ?? 'Gagal menghapus konten bantuan',
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Gagal menghapus konten bantuan',
        );
      }
    } catch (e) {
      print('Error deleting help content: $e');
      throw e;
    }
  }

  Future<void> toggleHelpContentStatus(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/help/admin/$id/toggle-status'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] != true) {
          throw Exception(
            responseData['message'] ?? 'Gagal mengubah status konten',
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal mengubah status konten');
      }
    } catch (e) {
      print('Error toggling help content status: $e');
      throw e;
    }
  }
}

class HelpResponse {
  final List<HelpContent> faqs;
  final List<HelpContent> contacts;
  final List<HelpContent> appInfo;
  final List<HelpContent> general;

  HelpResponse({
    required this.faqs,
    required this.contacts,
    required this.appInfo,
    required this.general,
  });

  factory HelpResponse.fromJson(Map<String, dynamic> json) {
    return HelpResponse(
      faqs:
          (json['faqs'] as List?)
              ?.map((e) => HelpContent.fromJson(e))
              .toList() ??
          [],
      contacts:
          (json['contacts'] as List?)
              ?.map((e) => HelpContent.fromJson(e))
              .toList() ??
          [],
      appInfo:
          (json['appInfo'] as List?)
              ?.map((e) => HelpContent.fromJson(e))
              .toList() ??
          [],
      general:
          (json['general'] as List?)
              ?.map((e) => HelpContent.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class HelpContent {
  final int id;
  final String? division;
  final String title;
  final String content;
  final String type;
  final int order;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  HelpContent({
    required this.id,
    this.division,
    required this.title,
    required this.content,
    required this.type,
    required this.order,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HelpContent.fromJson(Map<String, dynamic> json) {
    return HelpContent(
      id: json['id'],
      division: json['division'],
      title: json['title'],
      content: json['content'],
      type: json['type'],
      order: json['order'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Helper method untuk kontak
  Map<String, dynamic> get contactInfo {
    if (type == 'CONTACT') {
      try {
        return jsonDecode(content);
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  // Helper method untuk app info
  Map<String, dynamic> get appInfo {
    if (type == 'APP_INFO') {
      try {
        return jsonDecode(content);
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  bool get isGlobal => division == null;
}
