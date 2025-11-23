import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/api.dart';

class JamKerjaFormPage extends StatefulWidget {
  final Map<String, dynamic>? existingData;

  JamKerjaFormPage({this.existingData});

  @override
  _JamKerjaFormPageState createState() => _JamKerjaFormPageState();
}

class _JamKerjaFormPageState extends State<JamKerjaFormPage> {
  final TextEditingController workStart = TextEditingController();
  final TextEditingController workEnd = TextEditingController();
  final TextEditingController graceMinutes = TextEditingController();
  final TextEditingController penalty = TextEditingController();

  int? settingId; // ID untuk update
  int? divisionId;

  @override
  void initState() {
    super.initState();

    if (widget.existingData != null) {
      settingId = widget.existingData!["id"];
      divisionId = widget.existingData!["division_id"];

      workStart.text = widget.existingData!["work_start"] ?? "";
      workEnd.text = widget.existingData!["work_end"] ?? "";
      graceMinutes.text =
          widget.existingData!["grace_minutes"]?.toString() ?? "";
      penalty.text =
          widget.existingData!["penalty_per_minute"]?.toString() ?? "";
    }
  }

  Future<void> saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final body = {
      "division_id": divisionId?.toString() ?? "1",
      "work_start": workStart.text,
      "work_end": workEnd.text,
      "grace_minutes": graceMinutes.text,
      "penalty_per_minute": penalty.text,
      "radius_meters": "150", // default supaya tidak error
      "office_lat": "-6.2000",
      "office_lng": "106.8166",
    };

    http.Response response;

    // ============================
    //  UPDATE (JIKA ADA ID)
    // ============================
    if (settingId != null) {
      final url = Uri.parse(
        "${ApiConfig.baseUrl}/division-settings/$settingId",
      );

      response = await http.put(
        url,
        body: jsonEncode(body),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
    }
    // ============================
    //  CREATE (JIKA BELUM ADA)
    // ============================
    else {
      final url = Uri.parse("${ApiConfig.baseUrl}/division-settings");

      response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Berhasil disimpan")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menyimpan perubahan")));
    }
  }

  Widget inputField(String title, TextEditingController controller) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: title,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Jam Kerja")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            inputField("Jam Masuk", workStart),
            inputField("Jam Pulang", workEnd),
            inputField("Grace Period (menit)", graceMinutes),
            inputField("Denda per Menit", penalty),

            SizedBox(height: 20),

            ElevatedButton(onPressed: saveSettings, child: Text("Simpan")),
          ],
        ),
      ),
    );
  }
}
