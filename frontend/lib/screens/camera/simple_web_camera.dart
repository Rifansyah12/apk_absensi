// lib/screens/camera/simple_web_camera.dart
import 'dart:html' as html;
import 'dart:convert';
import 'dart:typed_data' as html;
import 'package:flutter/material.dart';

class SimpleWebCamera extends StatefulWidget {
  @override
  _SimpleWebCameraState createState() => _SimpleWebCameraState();
}

class _SimpleWebCameraState extends State<SimpleWebCamera> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  void _initCamera() async {
    try {
      // Create file input element
      final input = html.FileUploadInputElement();
      input.accept = 'image/*';
      input.setAttribute('capture', 'camera'); // This should force camera on mobile

      setState(() {
        _isLoading = false;
      });

      // This will open camera directly on mobile browsers
      // On desktop, it will open file dialog with camera option
      input.click();

      input.onChange.listen((event) async {
        final files = input.files;
        if (files == null || files.isEmpty) return;

        final file = files[0];
        final reader = html.FileReader();

        reader.onLoadEnd.listen((e) {
          final result = reader.result;
          if (result is html.ByteBuffer) {
            final bytes = result.asUint8List();
            final base64 = base64Encode(bytes);
            final imageData = 'data:image/jpeg;base64,$base64';
            Navigator.of(context).pop(imageData);
          }
        });

        reader.readAsArrayBuffer(file);
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kamera'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Membuka kamera...'),
                ],
              )
            : _error != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(_error!),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initCamera,
                    child: Text('Coba Lagi'),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 64, color: Colors.blue),
                  SizedBox(height: 16),
                  Text('Kamera siap...'),
                  SizedBox(height: 8),
                  Text(
                    'Jika kamera tidak terbuka otomatis, \ntekan tombol di bawah',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initCamera,
                    child: Text('Buka Kamera'),
                  ),
                ],
              ),
      ),
    );
  }
}
