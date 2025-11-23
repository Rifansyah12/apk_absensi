// lib/screens/admin/users/user_list_screen.dart (COMPLETE VERSION)
import 'package:flutter/material.dart';
import 'package:apk_absensi/models/user_model.dart';
import 'package:apk_absensi/services/user_service.dart';
import 'package:apk_absensi/screens/admin/users/user_form_screen.dart';
import 'package:apk_absensi/screens/admin/users/user_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  final String division;

  const UserListScreen({Key? key, this.division = ''}) : super(key: key);

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final users = await UserService.getUsers();
      setState(() {
        _users = users;
        _applyFilters();
      });
    } catch (e) {
      _showErrorSnackbar('Gagal memuat data karyawan: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<User> filtered = _users;

    if (widget.division.isNotEmpty) {
      filtered = filtered
          .where((user) => user.division == widget.division)
          .toList();
    }

    if (!_showInactive) {
      filtered = filtered.where((user) => user.isActive).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (user) =>
                user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                user.employeeId.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                user.email.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    setState(() {
      _filteredUsers = filtered;
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  // ✅ TAMBAHKAN: Method untuk navigasi ke form user
  void _navigateToUserForm([User? user]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            UserFormScreen(user: user, onUserSaved: _loadUsers),
      ),
    );
  }

  // ✅ TAMBAHKAN: Method untuk hapus user
  Future<void> _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Karyawan'),
        content: Text('Apakah Anda yakin ingin menghapus ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await UserService.deleteUser(user.id);
        _showSuccessSnackbar('Karyawan berhasil dihapus');
        _loadUsers();
      } catch (e) {
        _showErrorSnackbar('Gagal menghapus karyawan: $e');
      }
    }
  }

  // ✅ TAMBAHKAN: Method untuk restore user
  Future<void> _restoreUser(User user) async {
    try {
      await UserService.restoreUser(user.id);
      _showSuccessSnackbar('Karyawan berhasil dipulihkan');
      _loadUsers();
    } catch (e) {
      _showErrorSnackbar('Gagal memulihkan karyawan: $e');
    }
  }

  Widget _buildUserAvatar(User user) {
    // ✅ FIX: Tampilkan foto jika ada, dengan URL lengkap
    if (user.photo != null && user.photo!.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(user.photo!),
        onBackgroundImageError: (exception, stackTrace) {
          print('❌ Error loading avatar for ${user.name}: $exception');
        },
        child: _buildDefaultAvatar(user), // Fallback
      );
    }

    return _buildDefaultAvatar(user);
  }

  // ✅ FIX: Perbaiki return type untuk errorBuilder
  Widget _buildDefaultAvatar(User user) {
    return CircleAvatar(
      backgroundColor: _getDivisionColor(user.division),
      child: Text(
        user.name.substring(0, 1).toUpperCase(),
        style: TextStyle(color: Colors.white),
      ),
    );
  }

Widget _buildUserCard(User user) {
  return Card(
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: ListTile(
      leading: _buildUserAvatar(user),
      title: Text(
        user.name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: user.isActive ? Colors.black : Colors.grey,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${user.employeeId} • ${user.position}'),
          Text('${user.division} • ${user.email}'),
          if (!user.isActive)
            Text(
              'Non-Aktif',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'edit':
              _navigateToUserForm(user);
              break;
            case 'delete':
              _deleteUser(user);
              break;
            case 'restore':
              _restoreUser(user);
              break;
          }
        },
        itemBuilder: (context) => [
          if (user.isActive) PopupMenuItem(value: 'edit', child: Text('Edit')),
          if (user.isActive) PopupMenuItem(value: 'delete', child: Text('Hapus')),
          if (!user.isActive) PopupMenuItem(value: 'restore', child: Text('Pulihkan')),
        ],
      ),
      // ✅ PERBAIKAN: Tap card untuk lihat detail, bukan edit
      onTap: () => _navigateToUserDetail(user),
    ),
  );
}

// ✅ TAMBAHKAN: Method untuk navigasi ke detail user
void _navigateToUserDetail(User user) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => UserDetailScreen(userId: user.id),
    ),
  );
}

  Color _getDivisionColor(String division) {
    switch (division) {
      case 'FINANCE':
        return Colors.blue;
      case 'APO':
        return Colors.green;
      case 'FRONT_DESK':
        return Colors.orange;
      case 'ONSITE':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Karyawan'),
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: _loadUsers)],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari karyawan...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _applyFilters();
                    });
                  },
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FilterChip(
                        label: Text('Tampilkan Non-Aktif'),
                        selected: _showInactive,
                        onSelected: (selected) {
                          setState(() {
                            _showInactive = selected;
                            _applyFilters();
                          });
                        },
                      ),
                    ),
                    if (widget.division.isNotEmpty)
                      Chip(
                        label: Text(widget.division),
                        backgroundColor: _getDivisionColor(
                          widget.division,
                        ).withOpacity(0.2),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // User List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty || _showInactive
                              ? 'Tidak ada karyawan yang sesuai'
                              : 'Belum ada data karyawan',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadUsers,
                    child: ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        return _buildUserCard(_filteredUsers[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToUserForm(),
        child: Icon(Icons.add),
        tooltip: 'Tambah Karyawan',
      ),
    );
  }
}
