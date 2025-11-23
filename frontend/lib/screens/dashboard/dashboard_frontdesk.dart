import 'package:apk_absensi/screens/admin/attedance/attedance_list_screen.dart';
import 'package:apk_absensi/screens/admin/overtime/overtime_approval_screen.dart';
import 'package:apk_absensi/screens/admin/reports/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:apk_absensi/widgets/dashboard_template.dart';
import 'package:apk_absensi/screens/admin/users/user_list_screen.dart';
import 'package:apk_absensi/screens/admin/leaves/leave_approval_screen.dart';
import 'package:apk_absensi/screens/admin/division/division_setting_screen.dart';

class DashboardFrontdesk extends StatelessWidget {
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
            builder: (context) => UserListScreen(division: 'FRONT_DESK'),
          ),
        );
        break;
      case "Absensi":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttendanceListScreen(division: 'FRONT_DESK'),
          ),
        );
        break;
      case "Persetujuan Cuti":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LeaveApprovalScreen(division: 'FRONT_DESK'),
          ),
        );
        break;
      case "Persetujuan Lembur":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OvertimeApprovalScreen(division: 'FRONT_DESK'),
          ),
        );
        break;
      case "Laporan":
        // Tambahkan navigasi ke halaman laporan di sini
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportScreen(division: 'FRONT_DESK'),
          ),
        );
        break;
      case "Divisi":
        // Tambahkan navigasi ke halaman jam kerja di sini
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DivisionSettingScreen(division: 'FRONT_DESK'),
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
      title: "Dashboard FRONT_DESK",
      menu: menu,
      color: Colors.purple[100],
      onMenuTap: (title) => handleMenuTap(title, context),
    );
  }
}
