import 'package:apk_absensi/screens/admin/attedance/attedance_list_screen.dart';
import 'package:apk_absensi/screens/admin/overtime/overtime_approval_screen.dart';
import 'package:apk_absensi/screens/admin/reports/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:apk_absensi/widgets/dashboard_template.dart';
import 'package:apk_absensi/screens/admin/users/user_list_screen.dart';
import 'package:apk_absensi/screens/admin/leaves/leave_approval_screen.dart';
import 'package:apk_absensi/screens/admin/division/division_setting_screen.dart';

class DashboardApo extends StatelessWidget {
  final List<Map<String, dynamic>> menu = [
    {"title": "Data Karyawan", "icon": Icons.people_alt},
    {"title": "Absensi", "icon": Icons.fingerprint},
    {"title": "Persetujuan Cuti", "icon": Icons.fact_check},
    {"title": "Persetujuan Lembur", "icon": Icons.add_alarm},
    {"title": "Laporan", "icon": Icons.analytics},
    {"title": "Divisi", "icon": Icons.settings},
  ];

  void handleMenuTap(String title, BuildContext context) {
    switch (title) {
      case "Data Karyawan":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserListScreen(division: 'APO'),
          ),
        );
        break;
      case "Absensi":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttendanceListScreen(division: 'APO'),
          ),
        );
        break;
      case "Persetujuan Cuti":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LeaveApprovalScreen(division: 'APO'),
          ),
        );
        break;
      case "Persetujuan Lembur":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OvertimeApprovalScreen(division: 'APO'),
          ),
        );
        break;
      case "Laporan":
        // Tambahkan navigasi ke halaman laporan di sini
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportScreen(division: 'APO'),
          ),
        );
        break;
      case "Divisi":
        // Tambahkan navigasi ke halaman jam kerja di sini
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DivisionSettingScreen(division: 'APO'),
          ),
        );
        break;
      default:
        print("Menu tidak dikenali: $title");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardTemplate(
      title: "Dashboard APO",
      menu: menu,
      color: Colors.purple[100],
      onMenuTap: (title) => handleMenuTap(title, context),
    );
  }
}