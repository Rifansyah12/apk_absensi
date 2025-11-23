import 'package:flutter/material.dart';
import 'package:apk_absensi/widgets/dashboard_template.dart';
import 'package:apk_absensi/screens/attendance/absensi_list_page.dart';
import 'package:apk_absensi/screens/attendance/absensi_page.dart';
import 'package:apk_absensi/screens/leave/leave_list_page.dart';
import 'package:apk_absensi/screens/overtime/overtime_list_page.dart';
import 'package:apk_absensi/screens/salary/salary_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardUser extends StatefulWidget {
  @override
  _DashboardUserState createState() => _DashboardUserState();
}

class _DashboardUserState extends State<DashboardUser> {
  List<Map<String, dynamic>> menu = [
    {"title": "Absensi", "icon": Icons.camera_alt},
    {"title": "Cuti Saya", "icon": Icons.beach_access},
    {"title": "Lembur Saya", "icon": Icons.timer},
    {"title": "Riwayat Absensi", "icon": Icons.history},
    {"title": "Gaji & Potongan", "icon": Icons.money},
  ];

  Future<void> handleMenuClick(String title) async {
    if (title == "Riwayat Absensi") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AbsensiListPage()),
      );
    } else if (title == "Absensi") {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? currentToken = prefs.getString("token");
      
      if (currentToken == null || currentToken.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token tidak ditemukan, silakan login kembali'),
            backgroundColor: Colors.red,
          ),
        );
        
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AbsensiPage(
            userName: "Karyawan",
            token: currentToken,
          ),
        ),
      );
    } else if (title == "Cuti Saya") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LeaveListPage()),
      );
    } else if (title == "Lembur Saya") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => OvertimeListPage()),
      );
    } else if (title == "Gaji & Potongan") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SalaryListPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fitur $title sedang dalam pengembangan"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardTemplate(
      title: "Karyawan",
      menu: menu,
      color: Colors.grey[100],
      onMenuTap: handleMenuClick,
    );
  }
}