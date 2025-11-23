import 'dart:convert';
import 'package:apk_absensi/config/api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:apk_absensi/widgets/attendance_widgets.dart';

class AbsensiDetailPage extends StatefulWidget {
  final Map<String, dynamic> attendance;

  const AbsensiDetailPage({required this.attendance, super.key});

  @override
  State<AbsensiDetailPage> createState() => _AbsensiDetailPageState();
}

class _AbsensiDetailPageState extends State<AbsensiDetailPage> {
  bool _dateFormatInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('id_ID', null);
    setState(() {
      _dateFormatInitialized = true;
    });
  }

  String _formatDate(String dateString) {
    if (!_dateFormatInitialized) return 'Loading...';

    try {
      final date = DateTime.parse(dateString).toLocal();
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return '-';

    try {
      final time = DateTime.parse(timeString).toLocal();
      return DateFormat('HH:mm:ss').format(time);
    } catch (e) {
      return timeString;
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

    // Clean path - remove leading slash if exists
    String cleanPath = imagePath.startsWith('/')
        ? imagePath.substring(1)
        : imagePath;

    // Check the actual path structure from your API response
    // Some paths start with 'public/uploads/', others with 'uploads/'
    // Remove any duplicate 'api/' prefix if it exists
    if (cleanPath.startsWith('api/')) {
      cleanPath = cleanPath.substring(4);
    }

    // Construct the correct URL - remove '/api' from baseUrl for static files
    String baseUrlForFiles = ApiConfig.baseUrl.replaceFirst('/api', '');

    return "$baseUrlForFiles/$cleanPath";
  }

  Widget _buildPhotoSection() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Foto Absensi",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 16),
            // Use Wrap instead of Row for better responsiveness
            Wrap(
              spacing: 20,
              runSpacing: 16,
              alignment: WrapAlignment.spaceEvenly,
              children: [
                _buildPhotoWidget(
                  widget.attendance['selfieCheckIn'],
                  'Check-in',
                ),
                _buildPhotoWidget(
                  widget.attendance['selfieCheckOut'],
                  'Check-out',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoWidget(String? photoPath, String label) {
    if (photoPath == null || photoPath.isEmpty) {
      return _buildPlaceholder('Tidak ada foto $label');
    }

    final imageUrl = _getImageUrl(photoPath);
    print('Loading image from: $imageUrl');

    return SizedBox(
      width: 140, // Fixed width to prevent overflow
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // Important: use min to prevent overflow
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $error');
                  print('Image URL: $imageUrl');
                  return _buildErrorWidget('Gagal memuat');
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String message) {
    return SizedBox(
      width: 140,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_camera, color: Colors.grey[400], size: 32),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Foto',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return SizedBox(
      width: 140,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red[300]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red[400], size: 32),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Colors.red[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Error',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isImportant = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
                color:
                    valueColor ??
                    (isImportant ? Colors.blueAccent : Colors.black87),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(String? location, String label) {
    if (location == null || location.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              location,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontFamily: 'Monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceInfo() {
    final attendance = widget.attendance;
    final status = attendance['status'] ?? '-';
    final statusColor = _getStatusColor(status);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Informasi Absensi",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 16),

            // Basic Information
            _buildInfoRow("Tanggal:", _formatDate(attendance['date'] ?? '')),
            _buildInfoRow("Check-in:", _formatTime(attendance['checkIn'])),
            _buildInfoRow("Check-out:", _formatTime(attendance['checkOut'])),
            _buildInfoRow(
              "Status:",
              _formatStatus(status),
              isImportant: true,
              valueColor: statusColor,
            ),

            // Time Information
            if (attendance['lateMinutes'] != null &&
                attendance['lateMinutes'] > 0)
              AttendanceWidgets.buildLateMinutesRow(
                lateMinutes: attendance['lateMinutes'],
                isImportant: true,
              ),

            if (attendance['overtimeMinutes'] != null &&
                attendance['overtimeMinutes'] > 0)
              _buildInfoRow(
                "Lembur:",
                "${attendance['overtimeMinutes']} menit",
                valueColor: Colors.green,
              ),

            // Location Information
            _buildLocationInfo(attendance['locationCheckIn'], "Lokasi Masuk:"),

            _buildLocationInfo(
              attendance['locationCheckOut'],
              "Lokasi Pulang:",
            ),

            // Notes
            if (attendance['notes'] != null && attendance['notes'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        "Catatan:",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        attendance['notes'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Metadata
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              "Informasi Sistem",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow("ID Absensi:", "${attendance['id'] ?? '-'}"),
            _buildInfoRow("Dibuat:", _formatTime(attendance['createdAt'])),
            _buildInfoRow("Diupdate:", _formatTime(attendance['updatedAt'])),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detail Absensi",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: !_dateFormatInitialized
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_buildPhotoSection(), _buildAttendanceInfo()],
              ),
            ),
    );
  }
}
