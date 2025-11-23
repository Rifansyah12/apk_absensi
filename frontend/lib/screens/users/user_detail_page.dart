import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

class UserDetailPage extends StatelessWidget {
  final Map<String, dynamic> user;

  UserDetailPage({required this.user});

  final List<Map<String, dynamic>> roleList = [
    {"id": 1, "name": "SUPER_ADMIN"},
    {"id": 2, "name": "EMPLOYEE"},
  ];

  final List<Map<String, dynamic>> divisionList = [
    {"id": 1, "name": "FINANCE"},
    {"id": 2, "name": "APO"},
    {"id": 3, "name": "FRONT DESK"},
    {"id": 4, "name": "ONSITE"},
  ];

  String getRoleName(int id) {
    return roleList.firstWhere(
      (r) => r["id"] == id,
      orElse: () => {"name": "-"},
    )["name"];
  }

  String getDivisionName(int? id) {
    if (id == null) return "-";
    return divisionList.firstWhere(
      (d) => d["id"] == id,
      orElse: () => {"name": "-"},
    )["name"];
  }

  @override
  Widget build(BuildContext context) {
    final photo = user["photo"] as String?;

    Widget buildPhoto() {
      if (photo == null || photo.isEmpty) {
        return ClipOval(
          child: Container(
            color: Colors.grey.shade300,
            width: 150,
            height: 150,
            child: Icon(Icons.account_circle, size: 100, color: Colors.grey),
          ),
        );
      }

      // Base64
      if (photo.startsWith("data:image") || !photo.startsWith("http")) {
        Uint8List bytes;
        try {
          if (photo.contains(',')) {
            bytes = base64Decode(photo.split(',').last);
          } else {
            bytes = base64Decode(photo);
          }
          return ClipOval(
            child: Image.memory(
              bytes,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
          );
        } catch (e) {
          return ClipOval(
            child: Container(
              color: Colors.grey.shade300,
              width: 150,
              height: 150,
              child: Icon(Icons.account_circle, size: 100, color: Colors.grey),
            ),
          );
        }
      }

      // URL
      return ClipOval(
        child: Image.network(photo, width: 150, height: 150, fit: BoxFit.cover),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Detail Karyawan")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            Center(child: buildPhoto()),
            SizedBox(height: 20),
            TextFormField(
              initialValue: user["name"],
              decoration: InputDecoration(labelText: "Nama"),
              readOnly: true,
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: user["email"],
              decoration: InputDecoration(labelText: "Email"),
              readOnly: true,
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: getRoleName(user["role_id"]),
              decoration: InputDecoration(labelText: "Role"),
              readOnly: true,
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: getDivisionName(user["division_id"]),
              decoration: InputDecoration(labelText: "Divisi"),
              readOnly: true,
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: user["is_active"] == 1 ? "Aktif" : "Tidak Aktif",
              decoration: InputDecoration(labelText: "Status"),
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }
}
