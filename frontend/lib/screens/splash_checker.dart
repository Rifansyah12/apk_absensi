import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard/dashboard_user.dart';
import 'dashboard/dashboard_finance.dart';
import 'dashboard/dashboard_apo.dart';
import 'dashboard/dashboard_frontdesk.dart';
import 'dashboard/dashboard_onsite.dart';
import 'auth/login_page.dart';

class SplashChecker extends StatefulWidget {
  @override
  _SplashCheckerState createState() => _SplashCheckerState();
}

class _SplashCheckerState extends State<SplashChecker> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    String? role = prefs.getString("role");

    await Future.delayed(Duration(seconds: 1)); // animasi kecil

    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
      return;
    }

    switch (role) {
      case "USER":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardUser()),
        );
        break;

      case "FINANCE":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardFinance()),
        );
        break;

      case "APO":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardApo()),
        );
        break;

      case "FRONTDESK":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardFrontdesk()),
        );
        break;

      case "ONSITE":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardOnsite()),
        );
        break;

      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
