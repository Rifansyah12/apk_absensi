// pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apk_absensi/models/profile_model.dart';
import 'package:apk_absensi/services/profile_service.dart';
import 'package:apk_absensi/config/api.dart';
import 'package:apk_absensi/screens/auth/login_page.dart';
// Tambahkan import ini
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:apk_absensi/screens/camera/web_camera_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ProfileService _profileService = ProfileService();
  final ImagePicker _imagePicker = ImagePicker();

  Profile? _profile;
  bool _isLoading = true;
  bool _isUpdating = false;

  // Form controllers
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Form key
  final _formKey = GlobalKey<FormState>();

  // ✅ TAMBAHKAN: Key untuk force refresh image dan timestamp
  UniqueKey _imageKey = UniqueKey();
  String _timestamp = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ✅ PERBAIKAN: Load profile dengan force refresh
  Future<void> _loadProfile({bool forceRefresh = false}) async {
    try {
      final profile = await _profileService.getProfile();
      setState(() {
        _profile = profile;
        _isLoading = false;

        // ✅ Force update image key dan timestamp
        if (forceRefresh) {
          _imageKey = UniqueKey();
          _timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        }
      });

      // ✅ PERBAIKAN: Simpan photo terbaru ke SharedPreferences
      if (profile.photo != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_photo', profile.photo!);
        print('💾 Photo saved to storage: ${profile.photo}');
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Gagal memuat profil: $e');

      // Jika error karena token, redirect ke login
      if (e.toString().contains('Token')) {
        _redirectToLogin();
      }
    }
  }

  // METHOD BARU: Ambil foto dari kamera web
  Future<void> _takePhotoWeb() async {
    try {
      final imageData = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WebCameraPage()),
      );

      if (imageData != null && imageData is String) {
        // Convert data URL to bytes
        final base64String = imageData.split(',').last;
        final bytes = base64Decode(base64String);

        // Check file size (max 5MB)
        if (bytes.length > 5 * 1024 * 1024) {
          _showErrorSnackBar('Ukuran file terlalu besar. Maksimal 5MB');
          return;
        }

        setState(() {
          _isUpdating = true;
        });

        try {
          await _profileService.updateProfile(
            photoBytes: bytes,
            fileName:
                'profile_${_profile?.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );

          // ✅ PERBAIKAN: Force reload data dengan refresh
          await _loadProfile(forceRefresh: true);

          _showSuccessSnackBar('Foto profil berhasil diupdate');

          // ✅ PERBAIKAN: Delay sedikit sebelum pop untuk memastikan state terupdate
          await Future.delayed(Duration(milliseconds: 500));
          Navigator.of(context).pop(true);
        } catch (e) {
          print('Update photo error: $e');
          if (e.toString().contains('Token')) {
            _showErrorSnackBar('Sesi telah berakhir. Silakan login kembali.');
            _redirectToLogin();
          } else {
            _showErrorSnackBar('Gagal mengupdate foto: $e');
          }
        } finally {
          setState(() {
            _isUpdating = false;
          });
        }
      }
    } catch (e) {
      print('Error in web camera: $e');
      _showErrorSnackBar('Gagal mengambil foto: $e');
      setState(() {
        _isUpdating = false;
      });
    }
  }

  // METHOD YANG DIPERBAIKI: _updatePhoto
  Future<void> _updatePhoto() async {
    try {
      // Tampilkan dialog pilihan sumber foto
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pilih Sumber Foto'),
          content: const Text('Pilih sumber untuk foto profil'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              child: const Text('Kamera'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
              child: const Text('Galeri'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
          ],
        ),
      );

      if (source == null) return;

      // PERBAIKAN: Untuk web, gunakan kamera khusus
      if (source == ImageSource.camera && kIsWeb) {
        await _takePhotoWeb();
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        // Validasi file sebelum upload
        final fileName = image.name.toLowerCase();
        final imageBytes = await image.readAsBytes();

        // Validasi ekstensi file
        if (!_profileService.isImageFile(fileName)) {
          _showErrorSnackBar('Hanya file JPG, JPEG, dan PNG yang didukung');
          return;
        }

        // Validasi ukuran file (max 5MB)
        if (imageBytes.length > 5 * 1024 * 1024) {
          _showErrorSnackBar('Ukuran file terlalu besar. Maksimal 5MB');
          return;
        }

        setState(() {
          _isUpdating = true;
        });

        try {
          await _profileService.updateProfile(
            photoBytes: imageBytes,
            fileName:
                'profile_${_profile?.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );

          // ✅ PERBAIKAN: Force reload data dengan refresh
          await _loadProfile(forceRefresh: true);

          _showSuccessSnackBar('Foto profil berhasil diupdate');

          // ✅ PERBAIKAN: Delay sedikit sebelum pop untuk memastikan state terupdate
          await Future.delayed(Duration(milliseconds: 500));
          Navigator.of(context).pop(true);
        } catch (e) {
          print('Update photo error: $e');
          // Tangani error spesifik
          if (e.toString().contains('Token')) {
            _showErrorSnackBar('Sesi telah berakhir. Silakan login kembali.');
            _redirectToLogin();
          } else {
            _showErrorSnackBar('Gagal mengupdate foto: $e');
          }
        } finally {
          setState(() {
            _isUpdating = false;
          });
        }
      }
    } catch (e) {
      print('Error in update photo: $e');
      _showErrorSnackBar('Terjadi kesalahan: $e');
      setState(() {
        _isUpdating = false;
      });
    }
  }

  // ✅ PERBAIKAN: Build profile image dengan cache busting
  Widget _buildProfileImage() {
    if (_profile?.photo != null) {
      String photoUrl = _profileService.getProfilePhotoUrl(_profile!.photo!);

      // ✅ PERBAIKAN: Tambahkan timestamp untuk cache busting
      if (!photoUrl.contains('?')) {
        photoUrl += '?t=$_timestamp';
      } else {
        photoUrl += '&t=$_timestamp';
      }

      if (photoUrl.isNotEmpty) {
        print('🔄 Loading profile image: $photoUrl');
        return Image.network(
          photoUrl,
          key: _imageKey, // ✅ Gunakan key untuk force rebuild
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
            print('❌ Error loading profile image from $photoUrl: $error');
            return _buildDefaultAvatar();
          },
        );
      }
    }
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return const Icon(Icons.person, size: 60, color: Colors.grey);
  }

  Widget _buildProfilePhotoSection() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.photo_camera, color: Colors.blueAccent),
                const SizedBox(width: 12),
                const Text(
                  'Foto Profil',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                  child: ClipOval(child: _buildProfileImage()),
                ),
                if (_isUpdating)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isUpdating ? null : _updatePhoto,
              icon: const Icon(Icons.camera_alt, size: 18),
              label: const Text('Ubah Foto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Format: JPG, JPEG, PNG | Maks: 5MB',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // METHOD-METHOD LAIN TETAP SAMA...
  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        _isUpdating = true;
      });

      await _profileService.updateProfile(
        password: _newPasswordController.text,
        currentPassword: _currentPasswordController.text,
      );

      // Clear form
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      _showSuccessSnackBar('Password berhasil diubah');

      // Reset form state
      _formKey.currentState!.reset();
    } catch (e) {
      print('Error updating password: $e');
      if (e.toString().contains('Token')) {
        _showErrorSnackBar('Sesi telah berakhir. Silakan login kembali.');
        _redirectToLogin();
      } else {
        _showErrorSnackBar('Gagal mengubah password: $e');
      }
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  void _redirectToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // ignore: use_build_context_synchronously
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Konfirmasi Logout'),
            content: const Text('Apakah Anda yakin ingin logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // ignore: use_build_context_synchronously
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginPage()),
        (route) => false,
      );
    }
  }

  Widget _buildChangePasswordSection() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lock, color: Colors.blueAccent),
                  const SizedBox(width: 12),
                  const Text(
                    'Ubah Password',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Current Password
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password Saat Ini',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                  hintText: 'Masukkan password saat ini',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password saat ini wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // New Password
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password Baru',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_reset),
                  hintText: 'Minimal 6 karakter',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password baru wajib diisi';
                  }
                  if (value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_clock),
                  hintText: 'Ulangi password baru',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi password wajib diisi';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Password tidak sama';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isUpdating ? null : _updatePassword,
                  icon: _isUpdating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.update, size: 18),
                  label: Text(
                    _isUpdating ? 'Mengupdate...' : 'Update Password',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDangerZone() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 12),
                const Text(
                  'Zona Berbahaya',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Tindakan ini akan mengeluarkan Anda dari aplikasi dan menghapus semua data sesi.',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Memuat pengaturan...'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.greenAccent[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading
                ? null
                : () => _loadProfile(forceRefresh: true),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: () => _loadProfile(forceRefresh: true),
              child: ListView(
                children: [
                  const SizedBox(height: 16),
                  _buildProfilePhotoSection(),
                  _buildChangePasswordSection(),
                  const SizedBox(height: 24),
                  _buildDangerZone(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
