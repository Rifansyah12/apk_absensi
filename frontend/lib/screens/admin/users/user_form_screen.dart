// lib/screens/admin/users/user_form_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:apk_absensi/models/user_model.dart';
import 'package:apk_absensi/services/user_service.dart';
import 'package:apk_absensi/utils/photo_url_helper.dart';

// Conditional import for web
import 'dart:html' as html;

// Import web camera page
import 'package:apk_absensi/screens/camera/web_camera_page.dart';

class UserFormScreen extends StatefulWidget {
  final User? user;
  final VoidCallback? onUserSaved;

  const UserFormScreen({Key? key, this.user, this.onUserSaved})
    : super(key: key);

  @override
  _UserFormScreenState createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _positionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedDivision = 'FINANCE';
  DateTime _selectedDate = DateTime.now();
  XFile? _photoFile;
  Uint8List? _imageBytes;
  bool _isLoading = false;

  final List<String> _divisions = ['FINANCE', 'APO', 'FRONT_DESK', 'ONSITE'];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _initializeForm(widget.user!);
    }
  }

  void _initializeForm(User user) {
    _nameController.text = user.name;
    _emailController.text = user.email;
    _employeeIdController.text = user.employeeId;
    _positionController.text = user.position;
    _phoneController.text = user.phone ?? '';
    _addressController.text = user.address ?? '';
    _selectedDivision = user.division;
    _selectedDate = user.joinDate;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final maxSize = 5 * 1024 * 1024; // 5MB

        if (bytes.length > maxSize) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ukuran file terlalu besar. Maksimal 5MB')),
          );
          return;
        }

        setState(() {
          _photoFile = pickedFile;
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      print('❌ Error memilih foto: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih foto: ${e.toString()}')),
      );
    }
  }

  // Di UserFormScreen, tambahkan error handling yang lebih baik
  Future<void> _takePhoto() async {
    try {
      if (kIsWeb) {
        final imageData = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WebCameraPage()),
        );

        if (imageData != null && imageData is String) {
          // Convert data URL to bytes
          final base64String = imageData.split(',').last;
          final bytes = base64Decode(base64String);

          // Check file size
          final maxSize = 5 * 1024 * 1024; // 5MB
          if (bytes.length > maxSize) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ukuran file terlalu besar. Maksimal 5MB'),
              ),
            );
            return;
          }

          setState(() {
            _imageBytes = bytes;
            _photoFile = null;
          });

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Foto berhasil diambil')));
        }
        return;
      }

      // Mobile code tetap sama...
    } catch (e) {
      print('❌ Error mengambil foto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto: ${e.toString()}')),
      );
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userData = {
        'employeeId': _employeeIdController.text,
        'name': _nameController.text,
        'email': _emailController.text,
        'division': _selectedDivision,
        'position': _positionController.text,
        'joinDate': _selectedDate.toIso8601String().split('T')[0],
        'phone': _phoneController.text.isEmpty ? null : _phoneController.text,
        'address': _addressController.text.isEmpty
            ? null
            : _addressController.text,
        if (_imageBytes != null) 'photoBytes': _imageBytes,
        if (widget.user == null) 'password': 'password123',
      };

      if (widget.user == null) {
        await UserService.createUser(userData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Karyawan berhasil ditambahkan')),
        );
      } else {
        await UserService.updateUser(widget.user!.id, userData);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Karyawan berhasil diperbarui')));
      }

      if (widget.onUserSaved != null) {
        widget.onUserSaved!();
      }

      Navigator.of(context).pop();
    } catch (e) {
      print('❌ Error detail: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan karyawan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildPhotoPreview() {
    if (_imageBytes != null) {
      return ClipOval(
        child: Image.memory(
          _imageBytes!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    }

    if (widget.user?.photo != null && widget.user!.photo!.isNotEmpty) {
      final photoUrl = PhotoUrlHelper.generatePhotoUrl(widget.user!.photo!);

      return ClipOval(
        child: Image.network(
          photoUrl,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 100,
              height: 100,
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
        ),
      );
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return ClipOval(
      child: Container(
        width: 100,
        height: 100,
        color: Colors.grey[300],
        child: Icon(Icons.camera_alt, size: 30, color: Colors.grey[600]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Tambah Karyawan' : 'Edit Karyawan'),
        actions: [
          if (!_isLoading)
            IconButton(icon: Icon(Icons.save), onPressed: _saveUser),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Photo Section
                    Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: _buildPhotoPreview(),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap untuk memilih foto dari galeri',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: Icon(Icons.photo_library),
                              label: Text('Galeri'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _takePhoto,
                              icon: Icon(Icons.camera_alt),
                              label: Text('Kamera'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Form Fields
                    TextFormField(
                      controller: _employeeIdController,
                      decoration: InputDecoration(
                        labelText: 'ID Karyawan',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ID Karyawan harus diisi';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama harus diisi';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email harus diisi';
                        }
                        if (!value.contains('@')) {
                          return 'Email tidak valid';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedDivision,
                      decoration: InputDecoration(
                        labelText: 'Divisi',
                        border: OutlineInputBorder(),
                      ),
                      items: _divisions.map((String division) {
                        return DropdownMenuItem<String>(
                          value: division,
                          child: Text(division),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDivision = newValue!;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _positionController,
                      decoration: InputDecoration(
                        labelText: 'Posisi/Jabatan',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Posisi harus diisi';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: _selectDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Tanggal Bergabung',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          controller: TextEditingController(
                            text:
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tanggal bergabung harus diisi';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Nomor Telepon (Opsional)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Alamat (Opsional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveUser,
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                widget.user == null
                                    ? 'TAMBAH KARYAWAN'
                                    : 'UPDATE KARYAWAN',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _employeeIdController.dispose();
    _positionController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
