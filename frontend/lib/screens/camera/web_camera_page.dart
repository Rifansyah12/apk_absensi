import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:apk_absensi/main.dart'; // akses globalVideoElement

class WebCameraPage extends StatefulWidget {
  @override
  _WebCameraPageState createState() => _WebCameraPageState();
}

class _WebCameraPageState extends State<WebCameraPage> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) initCamera();
  }

  Future<void> initCamera() async {
    setState(() => isLoading = true);

    try {
      final stream = await html.window.navigator.mediaDevices!.getUserMedia({
        'video': true,
      });

      globalVideoElement.srcObject = stream;
      globalVideoElement.play();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal akses kamera: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// 🔴 Matikan kamera
  void stopCamera() {
    if (globalVideoElement.srcObject != null) {
      final stream = globalVideoElement.srcObject as html.MediaStream;
      stream.getTracks().forEach((track) => track.stop());
    }
    globalVideoElement.srcObject = null;
  }

  @override
  void dispose() {
    stopCamera();
    super.dispose();
  }

  void captureImage() {
    if (globalVideoElement.videoWidth == 0 ||
        globalVideoElement.videoHeight == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Kamera belum siap")));
      return;
    }

    final canvas = html.CanvasElement(
      width: globalVideoElement.videoWidth,
      height: globalVideoElement.videoHeight,
    );

    final ctx = canvas.context2D;
    ctx.drawImage(globalVideoElement, 0, 0);

    final imageData = canvas.toDataUrl("image/png");

    // Kirim hasil foto ke halaman sebelumnya
    Navigator.pop(context, imageData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Camera Preview")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? SizedBox(
                    width: 400,
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : SizedBox(
                    width: 400,
                    height: 300,
                    child: HtmlElementView(viewType: 'camera-view'),
                  ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: captureImage,
              icon: Icon(Icons.camera_alt),
              label: Text("Ambil Gambar"),
            ),
          ],
        ),
      ),
    );
  }
}
