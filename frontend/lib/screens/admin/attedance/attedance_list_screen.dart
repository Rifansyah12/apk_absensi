import 'package:apk_absensi/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:apk_absensi/models/attendance_model.dart';
import 'package:apk_absensi/services/attendance_service.dart';
import 'package:apk_absensi/widgets/loading_widget.dart';
import 'package:apk_absensi/widgets/error_widget.dart' as CustomError;
import 'attendance_form_screen.dart';
import 'attendance_detail_screen.dart';

class AttendanceListScreen extends StatefulWidget {
  final String? division;
  final bool isAdminView;

  const AttendanceListScreen({Key? key, this.division, this.isAdminView = true})
    : super(key: key);

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  List<Attendance> _attendances = [];
  List<Attendance> _filteredAttendances = [];
  bool _isLoading = true;
  String _error = '';
  DateTime? _selectedDate;
  String _selectedStatus = 'All';
  String _searchQuery = '';

  final List<String> _statusOptions = ['All', 'PRESENT', 'LATE', 'ABSENT'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAttendances();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAttendances() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final attendances = await AttendanceService.getAttendances(
        division: widget.division,
      );

      if (!mounted) return;

      // Filter hanya attendances yang valid
      final validAttendances = attendances.where((attendance) {
        return attendance.id > 0;
      }).toList();

      setState(() {
        _attendances = validAttendances;
        _filteredAttendances = validAttendances;
        _isLoading = false;
      });

      // Show notification if some data was filtered out
      if (validAttendances.length != attendances.length && mounted) {
        final filteredCount = attendances.length - validAttendances.length;
        _showSnackBar(
          '$filteredCount data absensi tidak valid dan telah difilter',
          isError: false,
          backgroundColor: Colors.orange,
        );
      }
    } catch (e) {
      if (!mounted) return;

      print('❌ Error loading attendances: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _attendances = [];
        _filteredAttendances = [];
      });

      _showSnackBar(
        'Gagal memuat data absensi: ${e.toString()}',
        isError: true,
      );
    }
  }

  void _filterAttendances() {
    List<Attendance> filtered = _attendances;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((attendance) {
        final user = attendance.user;
        if (user != null) {
          final nameMatch = user.name.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
          final employeeIdMatch = user.employeeId.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
          return nameMatch || employeeIdMatch;
        }
        return false;
      }).toList();
    }

    // Filter by status
    if (_selectedStatus != 'All') {
      filtered = filtered
          .where((attendance) => attendance.status == _selectedStatus)
          .toList();
    }

    // Filter by date
    if (_selectedDate != null) {
      filtered = filtered.where((attendance) {
        return attendance.date.year == _selectedDate!.year &&
            attendance.date.month == _selectedDate!.month &&
            attendance.date.day == _selectedDate!.day;
      }).toList();
    }

    if (mounted) {
      setState(() {
        _filteredAttendances = filtered;
      });
    }
  }

  // Safe method untuk show snackbar
  void _showSnackBar(
    String message, {
    bool isError = false,
    Color? backgroundColor,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? (isError ? Colors.red : null),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Absensi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(labelText: 'Status'),
              items: _statusOptions.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(_formatStatus(status)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null && mounted) {
                  setState(() {
                    _selectedStatus = value;
                  });
                  _filterAttendances();
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                _selectedDate != null
                    ? 'Tanggal: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                    : 'Pilih Tanggal',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null && mounted) {
                  setState(() {
                    _selectedDate = picked;
                  });
                  _filterAttendances();
                  Navigator.pop(context);
                }
              },
            ),
            if (_selectedDate != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  if (mounted) {
                    setState(() {
                      _selectedDate = null;
                    });
                    _filterAttendances();
                  }
                  Navigator.pop(context);
                },
                child: const Text('Hapus Filter Tanggal'),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'PRESENT':
        return 'Hadir';
      case 'LATE':
        return 'Terlambat';
      case 'ABSENT':
        return 'Tidak Hadir';
      case 'All':
        return 'Semua Status';
      default:
        return status;
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
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteDialog(Attendance attendance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Absensi'),
        content: Text(
          'Apakah Anda yakin ingin menghapus absensi ID: ${attendance.id}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => _deleteAttendance(attendance),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // Pisahkan logic delete ke method terpisah
  Future<void> _deleteAttendance(Attendance attendance) async {
    // Tutup dialog terlebih dahulu
    Navigator.pop(context);

    try {
      print('🗑️ Attempting to delete attendance ID: ${attendance.id}');

      await AttendanceService.deleteAttendance(attendance.id);

      // Hapus dari local state tanpa perlu reload dari server
      if (mounted) {
        setState(() {
          _attendances.removeWhere((a) => a.id == attendance.id);
          _filteredAttendances.removeWhere((a) => a.id == attendance.id);
        });

        _showSnackBar('Absensi berhasil dihapus', isError: false);
      }
    } catch (e) {
      print('❌ Delete attendance error: $e');
      if (mounted) {
        _showSnackBar('Gagal menghapus absensi: $e', isError: true);
      }
    }
  }

  void _showEditDialog(Attendance attendance) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceFormScreen(attendance: attendance),
      ),
    ).then((result) {
      // Refresh list jika edit berhasil (result = true)
      if (result == true && mounted) {
        _loadAttendances();
        _showSnackBar('Absensi berhasil diupdate');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.division != null
              ? 'Absensi ${widget.division}'
              : 'Data Absensi',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          if (widget.isAdminView) ...[
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AttendanceFormScreen(),
                  ),
                ).then((_) {
                  if (mounted) {
                    _loadAttendances();
                  }
                });
              },
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error.isNotEmpty
          ? CustomError.ErrorWidget(error: _error, onRetry: _loadAttendances)
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Cari nama atau ID karyawan...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          _searchQuery = value;
                        });
                      }
                      _filterAttendances();
                    },
                  ),
                ),
                // Summary
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Total: ${_filteredAttendances.length} data',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const Spacer(),
                      if (_selectedDate != null || _selectedStatus != 'All')
                        TextButton(
                          onPressed: () {
                            if (mounted) {
                              setState(() {
                                _selectedDate = null;
                                _selectedStatus = 'All';
                                _searchQuery = '';
                                _searchController.clear();
                              });
                            }
                            _filterAttendances();
                          },
                          child: const Text('Reset Filter'),
                        ),
                    ],
                  ),
                ),
                // List
                Expanded(
                  child: _filteredAttendances.isEmpty
                      ? _buildEmptyState()
                      : _buildAttendanceList(),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Tidak ada data absensi",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _filteredAttendances.length,
      itemBuilder: (context, index) {
        final attendance = _filteredAttendances[index];
        final user = attendance.user;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: _buildDateLeading(attendance),
            title: _buildUserInfo(user, attendance),
            subtitle: _buildAttendanceInfo(attendance),
            trailing: widget.isAdminView
                ? _buildAdminMenu(attendance)
                : const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AttendanceDetailScreen(attendance: attendance),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDateLeading(Attendance attendance) {
    return Container(
      width: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _getStatusColor(attendance.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            attendance.date.day.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: _getStatusColor(attendance.status),
            ),
          ),
          Text(
            attendance.date.month.toString(),
            style: TextStyle(
              fontSize: 8,
              color: _getStatusColor(attendance.status),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(User? user, Attendance attendance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (user != null) ...[
          Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            user.employeeId,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
        const SizedBox(height: 2),
        _buildTimeInfo(attendance),
      ],
    );
  }

  Widget _buildTimeInfo(Attendance attendance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.login, size: 12, color: Colors.green),
            const SizedBox(width: 4),
            Text(
              _formatTime(attendance.checkIn),
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.logout, size: 12, color: Colors.blue),
            const SizedBox(width: 4),
            Text(
              _formatTime(attendance.checkOut),
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAttendanceInfo(Attendance attendance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getStatusColor(attendance.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _getStatusColor(attendance.status),
              width: 1,
            ),
          ),
          child: Text(
            _formatStatus(attendance.status ?? 'UNKNOWN'),
            style: TextStyle(
              color: _getStatusColor(attendance.status),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (attendance.lateMinutes != null && attendance.lateMinutes! > 0)
          Text(
            'Terlambat: ${attendance.lateMinutes}m',
            style: const TextStyle(fontSize: 10, color: Colors.orange),
          ),
      ],
    );
  }

  Widget _buildAdminMenu(Attendance attendance) {
    return PopupMenuButton<String>(
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility, size: 20),
              SizedBox(width: 8),
              Text('Lihat Detail'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Hapus', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (value) async {
        switch (value) {
          case 'view':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    AttendanceDetailScreen(attendance: attendance),
              ),
            );
            break;
          case 'edit':
            _showEditDialog(attendance); // Sekarang navigasi ke form edit
            break;
          case 'delete':
            _showDeleteDialog(attendance);
            break;
        }
      },
    );
  }
}
