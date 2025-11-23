import 'package:flutter/material.dart';
import 'package:apk_absensi/models/attendance_model.dart';
import 'package:apk_absensi/utils/photo_url_helper.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class AttendanceDetailScreen extends StatefulWidget {
  final Attendance attendance;

  const AttendanceDetailScreen({Key? key, required this.attendance})
    : super(key: key);

  @override
  State<AttendanceDetailScreen> createState() => _AttendanceDetailScreenState();
}

class _AttendanceDetailScreenState extends State<AttendanceDetailScreen> {
  bool _dateFormatInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
  }

  Future<void> _initializeDateFormatting() async {
    try {
      await initializeDateFormatting('id_ID', null);
      if (mounted) {
        setState(() {
          _dateFormatInitialized = true;
        });
      }
    } catch (e) {
      print('❌ Error initializing date formatting: $e');
      if (mounted) {
        setState(() {
          _dateFormatInitialized = true;
        });
      }
    }
  }

  String _formatStatus(String? status) {
    switch (status) {
      case 'PRESENT':
        return 'Hadir';
      case 'LATE':
        return 'Terlambat';
      case 'ABSENT':
        return 'Tidak Hadir';
      default:
        return status ?? 'Tidak Diketahui';
    }
  }

  Color _getStatusColor(String? status) {
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

  String _formatTime(DateTime? time) {
    if (time == null) return '-';
    return DateFormat('HH:mm:ss').format(time);
  }

  String _formatDate(DateTime date) {
    if (!_dateFormatInitialized) return 'Loading...';
    try {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildSinglePhotoSection(String? photoPath, String label) {
    if (photoPath == null || photoPath.isEmpty) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Tidak ada foto\n$label',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final photoUrl = PhotoUrlHelper.generatePhotoUrl(photoPath);

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          photoUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red[400]),
                  const SizedBox(height: 4),
                  Text(
                    'Gagal memuat',
                    style: TextStyle(fontSize: 10, color: Colors.red[400]),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isImportant = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
                color: isImportant ? Colors.blueAccent : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeInfo() {
    final user = widget.attendance.user;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Karyawan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blueAccent[700],
              ),
            ),
            const SizedBox(height: 12),
            if (user != null) ...[
              _buildInfoRow('Nama', user.name),
              _buildInfoRow('ID Karyawan', user.employeeId),
              _buildInfoRow('Divisi', user.division),
              _buildInfoRow('Posisi', user.position),
            ] else ...[
              Text(
                'Data karyawan tidak tersedia',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Absensi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blueAccent[700],
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Tanggal', _formatDate(widget.attendance.date)),
            _buildInfoRow(
              'Status',
              _formatStatus(widget.attendance.status),
              isImportant: true,
            ),
            _buildInfoRow('Check-in', _formatTime(widget.attendance.checkIn)),
            _buildInfoRow('Check-out', _formatTime(widget.attendance.checkOut)),
            if (widget.attendance.lateMinutes != null &&
                widget.attendance.lateMinutes! > 0)
              _buildInfoRow(
                'Terlambat',
                '${widget.attendance.lateMinutes} menit',
              ),
            if (widget.attendance.overtimeMinutes != null &&
                widget.attendance.overtimeMinutes! > 0)
              _buildInfoRow(
                'Lembur',
                '${widget.attendance.overtimeMinutes} menit',
              ),
            if (widget.attendance.notes != null &&
                widget.attendance.notes!.isNotEmpty)
              _buildInfoRow('Catatan', widget.attendance.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSections() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Foto Absensi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blueAccent[700],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    _buildSinglePhotoSection(
                      widget.attendance.selfieCheckIn,
                      'Check-in',
                    ),
                    const SizedBox(height: 8),
                    const Text('Check-in', style: TextStyle(fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    _buildSinglePhotoSection(
                      widget.attendance.selfieCheckOut,
                      'Check-out',
                    ),
                    const SizedBox(height: 8),
                    const Text('Check-out', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Absensi')),
      body: !_dateFormatInitialized
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEmployeeInfo(),
                  const SizedBox(height: 16),
                  _buildAttendanceInfo(),
                  const SizedBox(height: 16),
                  _buildPhotoSections(),
                ],
              ),
            ),
    );
  }
}
