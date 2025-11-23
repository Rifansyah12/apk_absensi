import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
// ignore: deprecated_member_use
import 'dart:html' as html;
import '../../config/api.dart';
import 'package:apk_absensi/screens/camera/web_camera_page.dart';

class UserAddPage extends StatefulWidget {
  @override
  _UserAddPageState createState() => _UserAddPageState();
}

class _UserAddPageState extends State<UserAddPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  // Role & Division
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

  int selectedRole = 2;
  int? selectedDivision;

  File? _imageFile; // Mobile
  XFile? _webImageFile; // Web (ImagePicker)
  String? _webImageDataUrl; // Web (camera via html)

  // Ambil foto Mobile / Upload file
  Future<void> pickImage({required bool fromCamera}) async {
    final picker = ImagePicker();
    if (kIsWeb) {
      if (!fromCamera) {
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _webImageFile = pickedFile;
            _webImageDataUrl = null;
          });
        }
      } else {
        pickWebCameraImage();
      }
    } else {
      final pickedFile = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    }
  }

  // Ambil kamera Web
  void pickWebCameraImage() {
    html.FileUploadInputElement input = html.FileUploadInputElement();
    input.accept = 'image/*'; // cukup ini saja
    input.click();

    input.onChange.listen((e) {
      final file = input.files!.first;
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((e) {
        setState(() {
          _webImageDataUrl = reader.result as String?;
          _webImageFile = null;
        });
      });
    });
  }

  Future<void> saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final uri = Uri.parse("${ApiConfig.baseUrl}/users");

    String? base64Image;

    if (kIsWeb) {
      if (_webImageFile != null) {
        List<int> bytes = await _webImageFile!.readAsBytes();
        base64Image = base64Encode(bytes);
      } else if (_webImageDataUrl != null) {
        base64Image = _webImageDataUrl!.split(',').last;
      }
    } else if (_imageFile != null) {
      List<int> bytes = await _imageFile!.readAsBytes();
      base64Image = base64Encode(bytes);
    }

    // print({
    //   "name": name.text,
    //   "email": email.text,
    //   "password": password.text,
    //   "role_id": selectedRole.toString(),
    //   "division_id": selectedRole == 1 ? selectedDivision?.toString() : null,
    //   "photo": base64Image?.substring(0, 30), // preview 30 karakter saja
    // });

    final response = await http.post(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name.text,
        "email": email.text,
        "password": password.text,
        "role_id": selectedRole,
        "division_id": selectedRole == 1 ? selectedDivision : null,
        "photo": base64Image ?? "",
      }),
    );

    if (response.statusCode == 201) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User berhasil ditambahkan")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menambah user")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Karyawan")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: name,
                decoration: InputDecoration(labelText: "Nama"),
                validator: (v) => v!.isEmpty ? "Nama wajib diisi" : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: email,
                decoration: InputDecoration(labelText: "Email"),
                validator: (v) => v!.isEmpty ? "Email wajib diisi" : null,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: password,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (v) => v!.length < 6 ? "Minimal 6 karakter" : null,
              ),
              SizedBox(height: 20),
              // Role
              Text("Pilih Role", style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<int>(
                value: selectedRole,
                items: roleList
                    .map(
                      (r) => DropdownMenuItem<int>(
                        value: r["id"],
                        child: Text(r["name"]),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => selectedRole = v!),
              ),
              SizedBox(height: 20),
              // Division
              if (selectedRole == 1) ...[
                Text(
                  "Pilih Divisi",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButtonFormField<int>(
                  value: selectedDivision,
                  items: divisionList
                      .map(
                        (d) => DropdownMenuItem<int>(
                          value: d["id"],
                          child: Text(d["name"]),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedDivision = v),
                ),
                SizedBox(height: 20),
              ],
              // Foto
              Text(
                "Foto Karyawan",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              if (kIsWeb)
                _webImageDataUrl != null
                    ? Image.network(_webImageDataUrl!, height: 150)
                    : _webImageFile != null
                    ? Image.network(_webImageFile!.path, height: 150)
                    : Text("Belum ada foto")
              else
                _imageFile != null
                    ? Image.file(_imageFile!, height: 150)
                    : Text("Belum ada foto"),
              SizedBox(height: 10),
              // Tombol kamera / upload
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (kIsWeb) {
                          final dataUrl = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => WebCameraPage()),
                          );

                          if (dataUrl != null) {
                            setState(() {
                              _webImageDataUrl = dataUrl;
                            });
                          }
                        } else {
                          pickImage(fromCamera: true);
                        }
                      },
                      icon: Icon(Icons.camera_alt),
                      label: Text("Ambil Foto"),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => pickImage(fromCamera: false),
                      icon: Icon(Icons.upload_file),
                      label: Text("Upload Foto"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: saveUser,
                child: Text("Simpan"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
