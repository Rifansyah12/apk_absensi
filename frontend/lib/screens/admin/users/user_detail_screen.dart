// lib/screens/admin/users/user_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:apk_absensi/models/user_model.dart';
import 'package:apk_absensi/services/user_service.dart';
import 'package:apk_absensi/utils/photo_url_helper.dart';
import 'package:intl/intl.dart';

class UserDetailScreen extends StatefulWidget {
  final int userId;

  const UserDetailScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  User? _user;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserDetail();
  }

  Future<void> _loadUserDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final user = await UserService.getUserById(widget.userId);

      // ✅ DEBUG: Cek data photo
      print('📸 User photo data: ${user.photo}');
      // print('📸 Is valid URL: ${PhotoUrlHelper.isValidPhotoUrl(user.photo)}');
      // print('📸 Path only: ${PhotoUrlHelper.getPhotoPathOnly(user.photo)}');

      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading user detail: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blueAccent[700]!, Colors.purpleAccent[700]!],
        ),
      ),
      child: Column(
        children: [
          // Avatar/Photo
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(child: _buildProfileImage()),
          ),
          const SizedBox(height: 20),
          // Nama dan Posisi
          Text(
            _user?.name ?? '',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            _user?.position ?? '',
            style: const TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Employee ID
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.badge, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  _user?.employeeId ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Divisi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _user?.division ?? '',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_user?.photo != null && _user!.photo!.isNotEmpty) {
      return _buildNetworkImageWithFallback(_user!.photo!);
    } else {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildNetworkImageWithFallback(String photoPath) {
    // Generate semua kemungkinan URL
    final possibleUrls = PhotoUrlHelper.generateAllPossibleUrls(photoPath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    print('🖼️ Trying photo URLs:');
    for (final url in possibleUrls) {
      print('   - $url');
    }

    return _buildImageWithFallback(possibleUrls, 0, timestamp);
  }

  Widget _buildImageWithFallback(List<String> urls, int index, int timestamp) {
    if (index >= urls.length) {
      // Semua URL gagal, tampilkan default avatar
      return _buildDefaultAvatar();
    }

    final currentUrl =
        '${urls[index]}${urls[index].contains('?') ? '&' : '?'}t=$timestamp';
    print('🖼️ Loading image from: $currentUrl');

    return Image.network(
      currentUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                : null,
            color: Colors.white,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('❌ Failed to load from: $currentUrl');
        print('❌ Error: $error');

        // Coba URL berikutnya
        return _buildImageWithFallback(urls, index + 1, timestamp);
      },
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[200],
      child: Icon(Icons.person, size: 60, color: Colors.grey[600]),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Info Card
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blueAccent[700],
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Informasi Karyawan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.email,
              label: 'Email',
              value: _user?.email ?? '',
              isImportant: true,
            ),
            _buildInfoItem(
              icon: Icons.phone,
              label: 'Telepon',
              value: _user?.phone ?? 'Tidak ada',
            ),
            _buildInfoItem(
              icon: Icons.business_center,
              label: 'Divisi',
              value: _user?.division ?? '',
            ),
            _buildInfoItem(
              icon: Icons.work,
              label: 'Jabatan',
              value: _user?.position ?? '',
            ),
            _buildInfoItem(
              icon: Icons.calendar_today,
              label: 'Tanggal Bergabung',
              value: _user != null
                  ? DateFormat('dd MMMM yyyy').format(_user!.joinDate)
                  : '',
            ),
            _buildInfoItem(
              icon: Icons.location_on,
              label: 'Alamat',
              value: _user?.address ?? 'Tidak ada',
              isMultiline: true,
            ),
            // _buildInfoItem(
            //   icon: Icons.people,
            //   label: 'Role',
            //   value: _user?.role ?? '',
            // ),
            // // ✅ DEBUG: Info photo untuk troubleshooting
            // if (_user?.photo != null && _user!.photo!.isNotEmpty)
            //   _buildInfoItem(
            //     icon: Icons.photo,
            //     label: 'Photo Path (Debug)',
            //     value:
            //         '${_user!.photo!}\n\nGenerated URL: ${PhotoUrlHelper.generatePhotoUrl(_user!.photo!)}',
            //     isMultiline: true,
            //   ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    bool isMultiline = false,
    bool isImportant = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.blueAccent[700]?.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: Colors.blueAccent[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : '-',
                  style: TextStyle(
                    fontSize: 14,
                    color: isImportant
                        ? Colors.blueAccent[700]
                        : Colors.grey[800],
                    fontWeight: isImportant ? FontWeight.w600 : FontWeight.w400,
                  ),
                  maxLines: isMultiline ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: (_user?.isActive == true) ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (_user?.isActive == true) ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                (_user?.isActive == true) ? Icons.verified : Icons.block,
                color: (_user?.isActive == true) ? Colors.green : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Status Karyawan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (_user?.isActive == true) ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              (_user?.isActive == true) ? 'AKTIF' : 'NON-AKTIF',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
          Text(
            'Memuat data karyawan...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat data karyawan',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadUserDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent[700],
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
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
          'Detail Karyawan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserDetail,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _hasError
          ? _buildErrorState()
          : _user == null
          ? _buildErrorState()
          : RefreshIndicator(
              onRefresh: _loadUserDetail,
              child: ListView(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 20),
                  _buildStatusBadge(),
                  const SizedBox(height: 20),
                  _buildInfoCard(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
