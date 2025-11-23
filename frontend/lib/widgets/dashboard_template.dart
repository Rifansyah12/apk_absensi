// widgets/dashboard_template.dart (FIXED VERSION)
import 'package:apk_absensi/config/api.dart';
import 'package:apk_absensi/utils/photo_url_helper.dart';
import 'package:apk_absensi/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apk_absensi/screens/auth/login_page.dart';
import 'package:apk_absensi/screens/users/profile/profile_page.dart';
import 'package:apk_absensi/screens/settings/settings_page.dart';
import 'package:apk_absensi/screens/help/help_page.dart';
import 'package:apk_absensi/screens/admin/admin_help_page.dart';

// Import navigatorKey dari main.dart
import '../main.dart';

class DashboardTemplate extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> menu;
  final Color? color;
  final String? name;
  final String? userEmail;
  final void Function(String title)? onMenuTap;

  const DashboardTemplate({
    Key? key,
    required this.title,
    required this.menu,
    this.color,
    this.name,
    this.userEmail,
    this.onMenuTap,
  }) : super(key: key);

  @override
  _DashboardTemplateState createState() => _DashboardTemplateState();
}

class _DashboardTemplateState extends State<DashboardTemplate> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? _name;
  String? _userEmail;
  String? _division;
  String? _role;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ✅ PERBAIKAN: Load user data dari Storage utility
  Future<void> _loadUserData() async {
    try {
      _name = await Storage.getUserName();
      _userEmail = await Storage.getUserEmail();
      _division = await Storage.getDivision();
      _role = await Storage.getRole();
      _photoUrl = await Storage.getPhoto();

      print('👤 User data loaded:');
      print('   Name: $_name');
      print('   Email: $_userEmail');
      print('   Division: $_division');
      print('   Role: $_role');
      print('   Photo: $_photoUrl');

      setState(() {});
    } catch (e) {
      print('❌ Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.greenAccent[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: _buildDrawer(context),
      body: _buildBody(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    // ✅ PERBAIKAN: Gunakan data langsung dari Storage, tanpa FutureBuilder
    String displayName = _name ?? widget.name ?? "Nama Pengguna";
    String displayEmail = _userEmail ?? widget.userEmail ?? "email@example.com";
    String userRole = _role ?? "USER";

    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Header Drawer
            _buildDrawerHeader(
              name: displayName,
              userEmail: displayEmail,
              photoUrl: PhotoUrlHelper.generatePhotoUrl(_photoUrl),
            ),

            // Menu List
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Menu utama dari parameter
                  ...widget.menu.map((item) {
                    return ListTile(
                      leading: Icon(
                        item["icon"],
                        color: Colors.greenAccent[700],
                      ),
                      title: Text(
                        item["title"] ?? "Menu",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        if (widget.onMenuTap != null) {
                          widget.onMenuTap!(item["title"] ?? "Menu");
                        } else if (item.containsKey("route")) {
                          Navigator.of(context).pushNamed(item["route"]);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Menu ${item["title"]} diklik"),
                              backgroundColor: Colors.greenAccent[700],
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),

                  const Divider(thickness: 1),

                  // Menu Profil
                  ListTile(
                    leading: Icon(Icons.person, color: Colors.greenAccent[700]),
                    title: const Text(
                      "Profil",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: Icon(
                      Icons.settings,
                      color: Colors.greenAccent[700],
                    ),
                    title: const Text(
                      "Pengaturan",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: Icon(
                      Icons.help_outline,
                      color: Colors.greenAccent[700],
                    ),
                    title: const Text(
                      "Bantuan",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const HelpPage(),
                        ),
                      );
                    },
                  ),

                  // Menu Admin Help hanya untuk SUPER_ADMIN
                  if (userRole.contains('SUPER_ADMIN')) ...[
                    const Divider(thickness: 1),
                    ListTile(
                      leading: Icon(
                        Icons.admin_panel_settings,
                        color: Colors.greenAccent[700],
                      ),
                      title: const Text(
                        "Admin Help",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AdminHelpPage(),
                          ),
                        );
                      },
                    ),
                  ],

                  const Divider(thickness: 1),

                  // Logout
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text(
                      "Logout",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.redAccent,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop(); // Tutup drawer dulu
                      _showLogoutConfirmation(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PERBAIKAN: Method logout yang aman
  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final BuildContext currentContext = context;

    final confirmed = await showDialog<bool>(
      context: currentContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            "Konfirmasi Logout",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Apakah Anda yakin ingin logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    // Gunakan navigatorKey global untuk menghindari context issues
    if (confirmed == true) {
      await _performLogout();
    }
  }

  // PERBAIKAN: Pisahkan logic logout
  Future<void> _performLogout() async {
    try {
      await Storage.clearAll();

      // Gunakan navigatorKey global untuk navigasi yang aman
      if (navigatorKey.currentContext != null) {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => LoginPage()),
          (route) => false,
        );

        // Tampilkan snackbar menggunakan context dari navigatorKey
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          const SnackBar(
            content: Text("Logout berhasil"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Fallback: restart app jika navigatorKey tidak tersedia
        print('Navigator key not available, restarting app...');
        runApp(MyApp());
      }
    } catch (e) {
      print('Error during logout: $e');
      // Fallback error handling
      if (navigatorKey.currentContext != null) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          const SnackBar(
            content: Text("Terjadi error saat logout"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDrawerHeader({
    required String name,
    required String userEmail,
    required String? photoUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.greenAccent[700],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          _buildProfileAvatar(photoUrl),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(String? photoUrl) {
    // Build full URL
    String? fullUrl;

    if (photoUrl != null && photoUrl.isNotEmpty) {
      String baseUrl = ApiConfig.baseUrl;
      if (baseUrl.contains('/api')) {
        baseUrl = baseUrl.replaceAll('/api', '');
      }

      fullUrl = photoUrl.startsWith('http') ? photoUrl : baseUrl + photoUrl;
    }

    // Jika foto ada
    if (fullUrl != null && fullUrl.trim().isNotEmpty) {
      print("📸 Loading avatar: $fullUrl");
      return CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(fullUrl),
        onBackgroundImageError: (e, stack) {
          print('❌ Avatar load error: $e');
        },
      );
    }

    // Default avatar
    return const CircleAvatar(
      radius: 30,
      backgroundColor: Colors.white,
      child: Icon(Icons.person, color: Colors.greenAccent, size: 30),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: widget.color ?? Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.dashboard,
                    color: Colors.greenAccent[700],
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Selamat Datang",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Akses menu ${widget.title} dengan mudah",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Grid Menu
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.9,
              children: widget.menu.map((item) {
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      if (widget.onMenuTap != null) {
                        widget.onMenuTap!(item["title"] ?? "Menu");
                      } else if (item.containsKey("route")) {
                        Navigator.of(context).pushNamed(item["route"]);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Menu ${item["title"]} diklik"),
                            backgroundColor: Colors.greenAccent[700],
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent[700]?.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item["icon"],
                              size: 32,
                              color: Colors.greenAccent[700],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item["title"] ?? "Menu",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
