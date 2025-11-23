import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:apk_absensi/config/api.dart';
import 'package:apk_absensi/models/overtime_model.dart';
import 'package:intl/intl.dart';

class ApplyOvertimePage extends StatefulWidget {
  const ApplyOvertimePage({super.key});

  @override
  State<ApplyOvertimePage> createState() => _ApplyOvertimePageState();
}

class _ApplyOvertimePageState extends State<ApplyOvertimePage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  DateTime? _selectedDate;
  double _selectedHours = 1.0;
  String? _selectedReason;
  bool _isLoading = false;
  String? _token;
  int? _userId;

  final List<double> _availableHours = [0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
      _userId = prefs.getInt('user_id');
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 30),
      ), // Bisa memilih 30 hari ke belakang
      lastDate: DateTime.now().add(
        const Duration(days: 30),
      ), // Dan 30 hari ke depan
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitOvertimeRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap pilih tanggal lembur'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final overtimeRequest = OvertimeRequest(
        userId: _userId!,
        date: _selectedDate!,
        hours: _selectedHours,
        reason: _selectedReason ?? _reasonController.text,
      );

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/overtime'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(overtimeRequest.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          _showSuccessDialog(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Gagal mengajukan lembur');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog(Map<String, dynamic> overtimeData) {
    final overtime = OvertimeRequest.fromJson(overtimeData);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Lembur Berhasil Diajukan'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tanggal: ${DateFormat('dd/MM/yyyy').format(overtime.date)}'),
            Text('Durasi: ${overtime.formattedHours}'),
            Text('Alasan: ${overtime.reason}'),
            Text('Status: ${OvertimeData.getStatusLabel(overtime.status)}'),
            const SizedBox(height: 16),
            const Text(
              'Pengajuan lembur Anda telah berhasil dikirim dan menunggu persetujuan.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
              Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _reasonController.clear();
    setState(() {
      _selectedDate = null;
      _selectedHours = 1.0;
      _selectedReason = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajukan Lembur',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetForm,
            tooltip: 'Reset Form',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informasi penting
                      Card(
                        color: Colors.orange[50],
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.orange[700]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Ajukan lembur maksimal H+1 setelah tanggal lembur',
                                  style: TextStyle(
                                    color: Colors.orange[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Field Tanggal Lembur
                      _buildDateField(),
                      const SizedBox(height: 16),

                      // Field Durasi Lembur
                      _buildHoursField(),
                      const SizedBox(height: 16),

                      // Field Alasan (Predefined)
                      _buildReasonDropdown(),
                      const SizedBox(height: 16),

                      // Field Alasan Custom (jika memilih Lainnya)
                      if (_selectedReason == 'Lainnya')
                        _buildCustomReasonField(),

                      const SizedBox(height: 32),

                      // Tombol Submit
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submitOvertimeRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Ajukan Lembur',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Tanggal Lembur'),
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedDate != null
                      ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                      : 'Pilih tanggal lembur',
                  style: TextStyle(
                    color: _selectedDate != null
                        ? Colors.black
                        : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHoursField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Durasi Lembur'),
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableHours.map((hour) {
            final isSelected = _selectedHours == hour;
            return ChoiceChip(
              label: Text(
                hour == hour.truncate() ? '${hour.toInt()} jam' : '$hour jam',
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedHours = hour;
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.orangeAccent,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReasonDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Alasan Lembur'),
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedReason,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            hint: const Text('Pilih alasan lembur'),
          ),
          items: OvertimeData.commonReasons.map((String reason) {
            return DropdownMenuItem<String>(value: reason, child: Text(reason));
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedReason = newValue;
              if (newValue != 'Lainnya') {
                _reasonController.text = newValue ?? '';
              } else {
                _reasonController.clear();
              }
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Pilih alasan lembur';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCustomReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Keterangan Tambahan'),
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _reasonController,
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            hintText: 'Jelaskan alasan lembur Anda...',
            contentPadding: const EdgeInsets.all(12),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Keterangan tambahan harus diisi';
            }
            if (value.length < 10) {
              return 'Keterangan minimal 10 karakter';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}
