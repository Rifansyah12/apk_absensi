// lib/screens/admin/division/onsite_locations_screen.dart
import 'package:flutter/material.dart';
import 'package:apk_absensi/screens/admin/division/onsite_locations_tab.dart';

class OnsiteLocationsScreen extends StatelessWidget {
  final String division;

  const OnsiteLocationsScreen({Key? key, required this.division}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Lokasi Onsite'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: OnsiteLocationsTab(division: division),
    );
  }
}