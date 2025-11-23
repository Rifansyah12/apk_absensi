import 'package:flutter/material.dart';
import 'package:apk_absensi/models/user_model.dart';
import 'package:apk_absensi/models/attendance_model.dart';
import 'package:apk_absensi/services/user_service.dart';
import 'package:apk_absensi/services/attendance_service.dart';

class AttendanceFormScreen extends StatefulWidget {
  final Attendance? attendance; // Null untuk create, ada value untuk edit
  final bool isEditMode;

  const AttendanceFormScreen({
    Key? key,
    this.attendance,
  }) : isEditMode = attendance != null, super(key: key);

  @override
  State<AttendanceFormScreen> createState() => _AttendanceFormScreenState();
}

class _AttendanceFormScreenState extends State<AttendanceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  List<User> _users = [];
  User? _selectedUser;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedCheckIn;
  TimeOfDay? _selectedCheckOut;
  final _reasonController = TextEditingController();
  bool _isLoading = false;
  bool _loadingUsers = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _initializeFormData();
  }

  void _initializeFormData() {
    if (widget.isEditMode && widget.attendance != null) {
      final attendance = widget.attendance!;
      
      // Pre-fill form dengan data existing untuk edit mode
      _selectedDate = attendance.date;
      
      if (attendance.checkIn != null) {
        _selectedCheckIn = TimeOfDay.fromDateTime(attendance.checkIn!);
      }
      
      if (attendance.checkOut != null) {
        _selectedCheckOut = TimeOfDay.fromDateTime(attendance.checkOut!);
      }
      
      _reasonController.text = attendance.notes ?? '';
      
      print('📝 Initialized edit mode for attendance ID: ${attendance.id}');
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await UserService.getUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _loadingUsers = false;
        });

        // Untuk edit mode, set selected user berdasarkan attendance.userId
        if (widget.isEditMode && widget.attendance != null) {
          final attendanceUser = users.firstWhere(
            (user) => user.id == widget.attendance!.userId,
            orElse: () => User(
              id: 0,
              employeeId: 'Unknown',
              name: 'User Not Found',
              email: '',
              division: '',
              role: '',
              position: '',
              isActive: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(), joinDate: DateTime.now(),
            ),
          );
          
          setState(() {
            _selectedUser = attendanceUser;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingUsers = false;
        });
        _showSnackBar(
          'Gagal memuat data karyawan: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectCheckInTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedCheckIn ?? const TimeOfDay(hour: 8, minute: 0),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedCheckIn = picked;
      });
    }
  }

  Future<void> _selectCheckOutTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedCheckOut ?? const TimeOfDay(hour: 17, minute: 0),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedCheckOut = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validasi untuk create mode
    if (!widget.isEditMode && _selectedUser == null) {
      _showSnackBar('Pilih karyawan terlebih dahulu');
      return;
    }

    // Validasi untuk edit mode - pastikan user tersedia
    if (widget.isEditMode && _selectedUser == null) {
      _showSnackBar('Data karyawan tidak ditemukan');
      return;
    }

    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final attendanceData = {
        'userId': _selectedUser!.id,
        'date': _formatDateForApi(_selectedDate),
        'checkIn': _selectedCheckIn != null
            ? DateTime(
                _selectedDate.year,
                _selectedDate.month,
                _selectedDate.day,
                _selectedCheckIn!.hour,
                _selectedCheckIn!.minute,
              ).toUtc().toIso8601String()
            : null,
        'checkOut': _selectedCheckOut != null
            ? DateTime(
                _selectedDate.year,
                _selectedDate.month,
                _selectedDate.day,
                _selectedCheckOut!.hour,
                _selectedCheckOut!.minute,
              ).toUtc().toIso8601String()
            : null,
        'reason': _reasonController.text.isEmpty ? null : _reasonController.text,
      };

      if (widget.isEditMode) {
        // Update existing attendance
        await _updateAttendance(attendanceData);
      } else {
        // Create new attendance
        await _createAttendance(attendanceData);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Gagal ${widget.isEditMode ? 'mengupdate' : 'menambahkan'} absensi: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createAttendance(Map<String, dynamic> attendanceData) async {
    await AttendanceService.createManualAttendance(attendanceData);
    
    if (mounted) {
      _showSnackBar('Absensi manual berhasil ditambahkan');
      Navigator.of(context).pop(true); // Return true untuk indicate success
    }
  }

  Future<void> _updateAttendance(Map<String, dynamic> attendanceData) async {
    // Tambahkan attendanceId untuk update
    attendanceData['attendanceId'] = widget.attendance!.id;
    
    await AttendanceService.updateManualAttendance(attendanceData);
    
    if (mounted) {
      _showSnackBar('Absensi berhasil diupdate');
      Navigator.of(context).pop(true); // Return true untuk indicate success
    }
  }

  // Safe method untuk show snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildUserDropdown() {
    return DropdownButtonFormField<User>(
      value: _selectedUser,
      decoration: InputDecoration(
        labelText: 'Pilih Karyawan',
        border: const OutlineInputBorder(),
        // Nonaktifkan dropdown di edit mode karena user tidak bisa diubah
        enabled: !widget.isEditMode,
      ),
      items: _users.map((user) {
        return DropdownMenuItem(
          value: user,
          child: Text(
            '${user.employeeId} - ${user.name} (${user.division})',
          ),
        );
      }).toList(),
      onChanged: widget.isEditMode 
          ? null // Disable perubahan user di edit mode
          : (user) {
              setState(() {
                _selectedUser = user;
              });
            },
      validator: (value) {
        if (value == null && !widget.isEditMode) {
          return 'Pilih karyawan terlebih dahulu';
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: widget.isEditMode ? null : _selectDate, // Disable di edit mode
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Tanggal Absensi',
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
            enabled: !widget.isEditMode, // Nonaktifkan di edit mode
          ),
          controller: TextEditingController(
            text: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Tanggal absensi harus diisi';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay? selectedTime,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.access_time),
          ),
          controller: TextEditingController(
            text: selectedTime != null
                ? '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'
                : '',
          ),
        ),
      ),
    );
  }

  Widget _buildReasonField() {
    return TextFormField(
      controller: _reasonController,
      decoration: const InputDecoration(
        labelText: 'Keterangan / Alasan',
        border: OutlineInputBorder(),
        hintText: 'Contoh: Sistem error, lupa absen, lembur, dll.',
      ),
      maxLines: 3,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                widget.isEditMode ? 'UPDATE ABSENSI' : 'SIMPAN ABSENSI MANUAL',
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  Widget _buildUserInfo() {
    if (widget.isEditMode && _selectedUser != null) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.person, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedUser!.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${_selectedUser!.employeeId} - ${_selectedUser!.division}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditMode ? 'Edit Absensi' : 'Tambah Absensi Manual',
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _submitForm,
            ),
        ],
      ),
      body: _loadingUsers
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Tampilkan info user di edit mode
                    _buildUserInfo(),
                    
                    // Dropdown user hanya untuk create mode
                    if (!widget.isEditMode) ...[
                      _buildUserDropdown(),
                      const SizedBox(height: 20),
                    ],

                    _buildDateField(),
                    const SizedBox(height: 20),

                    _buildTimeField(
                      label: 'Jam Masuk (Opsional)',
                      selectedTime: _selectedCheckIn,
                      onTap: _selectCheckInTime,
                    ),
                    const SizedBox(height: 20),

                    _buildTimeField(
                      label: 'Jam Pulang (Opsional)',
                      selectedTime: _selectedCheckOut,
                      onTap: _selectCheckOutTime,
                    ),
                    const SizedBox(height: 20),

                    _buildReasonField(),
                    const SizedBox(height: 30),

                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }
}