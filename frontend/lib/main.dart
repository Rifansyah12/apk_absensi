// main.dart
import 'package:apk_absensi/screens/leave/leave_list_page.dart';
import 'package:apk_absensi/screens/users/profile/profile_page.dart';
import 'package:apk_absensi/utils/storage.dart';
import 'package:flutter/material.dart';
import 'screens/splash_checker.dart';
import 'screens/dashboard/dashboard_user.dart';
import 'screens/dashboard/dashboard_finance.dart';
import 'screens/dashboard/dashboard_apo.dart';
import 'screens/dashboard/dashboard_frontdesk.dart';
import 'screens/dashboard/dashboard_onsite.dart';
import 'screens/auth/login_page.dart';
import 'screens/users/user_list_page.dart';
import 'screens/users/user_add_page.dart';
import 'screens/leave/apply_leave_page.dart';

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

// PERBAIKAN: Pastikan navigatorKey didefinisikan sebagai global
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ⬇️ Buat videoElement GLOBAL agar bisa diakses di halaman lain
html.VideoElement globalVideoElement = html.VideoElement()
  ..autoplay = true
  ..muted = true
  ..style.width = '100%'
  ..style.height = '100%';

void main() {
    WidgetsFlutterBinding.ensureInitialized();
  Storage.debugPrintAll().then((_) {
    runApp(MyApp());
  });
  // ⬇️ Register 1 videoElement GLOBAL
  ui_web.platformViewRegistry.registerViewFactory(
    'camera-view',
    (int viewId) => globalVideoElement,
  );
  // Register videoElement GLOBAL
  // register face-detect view
  ui_web.platformViewRegistry.registerViewFactory('face-detect', (int viewId) {
    final iframe = html.IFrameElement()
      ..src = 'assets/face_detect.html'
      ..style.border = 'none'
      ..style.width = '320px'
      ..style.height = '240px';
    return iframe;
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // PASTIKAN INI ADA
      debugShowCheckedModeBanner: false,
      home: SplashChecker(),
      routes: {
        "/login": (context) => LoginPage(),
        "/dashboard_user": (_) => DashboardUser(),
        "/dashboard_finance": (_) => DashboardFinance(),
        "/dashboard_apo": (_) => DashboardApo(),
        "/dashboard_frontdesk": (_) => DashboardFrontdesk(),
        "/dashboard_onsite": (_) => DashboardOnsite(),
        // crud users
        "/users": (context) => UserListPage(),
        "/user/add": (context) => UserAddPage(),
        "/apply-leave": (context) => ApplyLeavePage(),
        "/my-leaves": (context) => LeaveListPage(),
        "/profile": (context) => ProfilePage(),
      },
    );
  }
}