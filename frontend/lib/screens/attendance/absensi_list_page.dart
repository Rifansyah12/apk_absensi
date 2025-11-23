import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apk_absensi/config/api.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'absensi_detail_page.dart';
import 'package:apk_absensi/widgets/attendance_widgets.dart';

class AbsensiListPage extends StatefulWidget {
  @override
  _AbsensiListPageState createState() => _AbsensiListPageState();
}

class _AbsensiListPageState extends State<AbsensiListPage> {
  List<dynamic> _attendanceList = [];
  bool _loading = true;
  String? _token;
  bool _dateFormatInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize date formatting first
      await initializeDateFormatting('id_ID', null);
      setState(() {
        _dateFormatInitialized = true;
      });

      // Then load token and history
      await _loadTokenAndHistory();
    } catch (e) {
      print('Error initializing app: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadTokenAndHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _token = prefs.getString("token");

      if (_token == null || _token!.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Token tidak ditemukan, silakan login kembali'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      await _loadAttendanceHistory();
    } catch (e) {
      print('Error loading token: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadAttendanceHistory() async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/attendance/history");

      print(
        'Mengambil riwayat absensi dengan token: ${_token!.substring(0, 20)}...',
      );

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $_token",
          "Accept": "application/json",
        },
      );

      if (!mounted) return;

      print('Status history: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _attendanceList = data['data'] ?? [];
          _loading = false;
        });
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token tidak valid, silakan login kembali'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat riwayat: ${response.statusCode}'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _loading = false);
      }
    } catch (e) {
      print('Error load history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _loading = false);
      }
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'PRESENT':
        return 'Hadir';
      case 'LATE':
        return 'Terlambat';
      case 'ABSENT':
        return 'Tidak Hadir';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PRESENT':
        return Colors.green;
      case 'LATE':
        return Colors.orange;
      case 'ABSENT':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // Fix image path - remove double /api/ if exists
    String cleanPath = imagePath.startsWith('/')
        ? imagePath.substring(1)
        : imagePath;

    // Check if path already contains 'api/'
    if (cleanPath.startsWith('api/')) {
      cleanPath = cleanPath.substring(4); // Remove 'api/' prefix
    }

    // Check if path already contains 'public/'
    if (!cleanPath.startsWith('public/')) {
      cleanPath = 'public/$cleanPath';
    }

    return "${ApiConfig.baseUrl}/$cleanPath";
  }

  @override
  Widget build(BuildContext context) {
    // Show loading until date formatting is initialized
    if (!_dateFormatInitialized || _loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Absensi"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: _attendanceList.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Tidak ada riwayat absensi",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadAttendanceHistory,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _attendanceList.length,
                itemBuilder: (context, index) {
                  final attendance = _attendanceList[index];
                  final date = DateTime.parse(attendance['date']).toLocal();
                  final checkIn = attendance['checkIn'] != null
                      ? DateFormat('HH:mm').format(
                          DateTime.parse(attendance['checkIn']).toLocal(),
                        )
                      : '-';
                  final checkOut = attendance['checkOut'] != null
                      ? DateFormat('HH:mm').format(
                          DateTime.parse(attendance['checkOut']).toLocal(),
                        )
                      : '-';

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 50,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('dd').format(date),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.blueAccent,
                              ),
                            ),
                            Text(
                              DateFormat('MMM').format(date),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              DateFormat('EEEE', 'id_ID').format(date),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                attendance['status'],
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _getStatusColor(attendance['status']),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _formatStatus(attendance['status']),
                              style: TextStyle(
                                color: _getStatusColor(attendance['status']),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              Icons.login,
                              'Masuk:',
                              checkIn,
                              Colors.green,
                            ),
                            const SizedBox(height: 2),
                            _buildInfoRow(
                              Icons.logout,
                              'Pulang:',
                              checkOut,
                              Colors.blue,
                            ),
                            if (attendance['lateMinutes'] != null &&
                                attendance['lateMinutes'] > 0) ...[
                              const SizedBox(height: 2),
                              AttendanceWidgets.buildLateMinutesInfo(
                                lateMinutes: attendance['lateMinutes'],
                                useCompactFormat: false,
                                iconSize: 16,
                                fontSize: 12,
                              ),
                            ],
                            if (attendance['notes'] != null &&
                                attendance['notes'].isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.note,
                                    size: 14,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Catatan:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      attendance['notes'],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AbsensiDetailPage(attendance: attendance),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
