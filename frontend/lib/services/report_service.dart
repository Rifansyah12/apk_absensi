// lib/services/report_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:apk_absensi/models/report_model.dart';
import 'package:apk_absensi/config/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportService {
  static final String _baseUrl = ApiConfig.baseUrl;

  // Get attendance report
  static Future<List<AttendanceReport>> getAttendanceReport(
    ReportFilter filter,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final queryParams = filter.toQueryParams();
      final uri = Uri.parse(
        '$_baseUrl/reports/attendance',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔍 Get attendance report response: ${response.statusCode}');
      print('🔍 Query params: $queryParams');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> reportJson = data['data'];
          final reports = reportJson
              .map((json) => AttendanceReport.fromJson(json))
              .toList();
          print('✅ Loaded ${reports.length} attendance records');
          return reports;
        } else {
          throw Exception(
            data['message'] ?? 'Failed to load attendance report',
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Tidak memiliki akses untuk melihat laporan');
      } else {
        final data = json.decode(response.body);
        throw Exception(
          data['message'] ??
              'Failed to load attendance report. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error loading attendance report: $e');
      rethrow;
    }
  }

  // Get salary report
  static Future<List<SalaryReport>> getSalaryReport(ReportFilter filter) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final queryParams = filter.toQueryParams();
      final uri = Uri.parse(
        '$_baseUrl/reports/salary',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔍 Get salary report response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> reportJson = data['data'];
          final reports = reportJson
              .map((json) => SalaryReport.fromJson(json))
              .toList();
          print('✅ Loaded ${reports.length} salary records');
          return reports;
        } else {
          throw Exception(data['message'] ?? 'Failed to load salary report');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Tidak memiliki akses untuk melihat laporan gaji');
      } else {
        final data = json.decode(response.body);
        throw Exception(
          data['message'] ??
              'Failed to load salary report. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error loading salary report: $e');
      rethrow;
    }
  }

  // Export attendance report
  static Future<void> exportAttendanceReport({
    required ReportFilter filter,
    required String format, // 'excel' or 'pdf'
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final queryParams = filter.toQueryParams();
      queryParams['format'] = format;

      final uri = Uri.parse(
        '$_baseUrl/reports/attendance/export',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('🔍 Export attendance report response: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Handle file download
        _handleFileDownload(response, 'laporan_absensi', format);
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to export report');
      }
    } catch (e) {
      print('❌ Error exporting attendance report: $e');
      rethrow;
    }
  }

  // Export salary report
  static Future<void> exportSalaryReport({
    required ReportFilter filter,
    required String format, // 'excel' or 'pdf'
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final queryParams = filter.toQueryParams();
      queryParams['format'] = format;

      final uri = Uri.parse(
        '$_baseUrl/reports/salary/export',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('🔍 Export salary report response: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Handle file download
        _handleFileDownload(response, 'laporan_gaji', format);
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to export report');
      }
    } catch (e) {
      print('❌ Error exporting salary report: $e');
      rethrow;
    }
  }

  static void _handleFileDownload(
    http.Response response,
    String filename,
    String format,
  ) {
    // Implement file download logic
    // This would typically use the file_saver or similar package
    print('✅ File downloaded: $filename.$format');
    // For now, we'll just show a success message
    // In a real app, you would save the file to device storage
  }

  // Calculate report summary
  static ReportSummary calculateAttendanceSummary(
    List<AttendanceReport> reports,
  ) {
    if (reports.isEmpty) {
      return ReportSummary(
        totalRecords: 0,
        totalLembur: 0,
        totalPotongan: 0,
        totalGaji: 0,
        rataRataTerlambat: 0,
      );
    }

    final totalLembur = reports.fold(0.0, (sum, report) => sum + report.lembur);
    final totalPotongan = reports.fold(
      0.0,
      (sum, report) => sum + report.potongan,
    );
    final totalGaji = reports.fold(
      0.0,
      (sum, report) => sum + report.totalGaji,
    );
    final rataRataTerlambat =
        reports.fold(0, (sum, report) => sum + report.terlambat) /
        reports.length;

    return ReportSummary(
      totalRecords: reports.length,
      totalLembur: totalLembur,
      totalPotongan: totalPotongan,
      totalGaji: totalGaji,
      rataRataTerlambat: rataRataTerlambat,
    );
  }

  // Decision tree algorithm for salary calculation
  static Map<String, dynamic> calculateSalaryDecisionTree(
    AttendanceReport report,
  ) {
    // Simple decision tree based on company rules
    double bonus = 0;
    String kategori = 'Standar';

    if (report.lembur > 20) {
      bonus = report.totalGaji * 0.1;
      kategori = 'Luar Biasa';
    } else if (report.lembur > 10) {
      bonus = report.totalGaji * 0.05;
      kategori = 'Baik';
    } else if (report.terlambat > 300) {
      // 5 hours
      bonus = 0;
      kategori = 'Perlu Perbaikan';
    } else if (report.terlambat < 30) {
      bonus = report.totalGaji * 0.02;
      kategori = 'Tepat Waktu';
    }

    return {
      'bonus': bonus,
      'kategori': kategori,
      'gajiAkhir': report.totalGaji + bonus,
    };
  }
}
