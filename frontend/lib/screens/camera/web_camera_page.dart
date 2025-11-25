// lib/screens/camera/web_camera_page.dart
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class WebCameraPage extends StatefulWidget {
  const WebCameraPage({super.key});

  @override
  State<WebCameraPage> createState() => _WebCameraPageState();
}

class _WebCameraPageState extends State<WebCameraPage> {
  html.VideoElement? _videoElement;
  html.CanvasElement? _canvas;
  Uint8List? capturedImage;
  bool isCapturing = true;
  bool isLoading = true;
  String? errorMessage;

  // Gunakan viewType yang unik untuk setiap instance
  late String _viewType;

  @override
  void initState() {
    super.initState();
    // Generate unique view type untuk menghindari conflict
    _viewType = 'cameraVideoView_${DateTime.now().millisecondsSinceEpoch}';
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Buat video element baru
      _videoElement = html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..controls = false
        ..style.width = '100%'
        ..style.height = '100%';

      // Daftarkan view factory dengan viewType yang unik
      ui_web.platformViewRegistry.registerViewFactory(
        _viewType,
        (int viewId) => _videoElement!,
      );

      // Request akses kamera
      final mediaStream = await html.window.navigator.mediaDevices!
          .getUserMedia({
            "video": {
              "width": {"ideal": 1280},
              "height": {"ideal": 720},
              "facingMode": "user",
            },
          });

      // Set video source
      _videoElement!.srcObject = mediaStream;

      // Tunggu sampai video siap
      _videoElement!.onCanPlay.listen((_) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      });

      _videoElement!.onError.listen((_) {
        if (mounted) {
          setState(() {
            isLoading = false;
            errorMessage = 'Gagal memuat kamera';
          });
        }
      });

      // Canvas untuk capture
      _canvas = html.CanvasElement();
    } catch (e) {
      print('❌ Error init camera: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Tidak dapat mengakses kamera: $e';
        });
      }
    }
  }

  Future<void> capturePhoto() async {
    final video = _videoElement;
    final canvas = _canvas;

    if (video == null || canvas == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Kamera belum siap')));
      return;
    }

    try {
      // Pastikan video sudah siap
      if (video.videoWidth == 0 || video.videoHeight == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video belum siap, tunggu sebentar')),
        );
        return;
      }

      // Set canvas size sama dengan video
      canvas.width = video.videoWidth!;
      canvas.height = video.videoHeight!;

      final ctx = canvas.context2D as html.CanvasRenderingContext2D;

      // Draw video frame ke canvas
      ctx.drawImage(video, 0, 0);

      // Convert canvas ke Blob → Uint8List
      final blob = await canvas.toBlob("image/jpeg", 0.8);
      final reader = html.FileReader();

      reader.readAsArrayBuffer(blob!);

      await reader.onLoad.first;

      setState(() {
        capturedImage = reader.result as Uint8List;
        isCapturing = false;
      });
    } catch (e) {
      print('❌ Error capture photo: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $e')));
    }
  }

  void retake() {
    setState(() {
      capturedImage = null;
      isCapturing = true;
    });
  }

  void _usePhoto() {
    if (capturedImage != null) {
      // Convert bytes ke base64 untuk dikirim kembali
      final base64Image = base64Encode(capturedImage!);
      final imageData = 'data:image/jpeg;base64,$base64Image';
      Navigator.of(context).pop(imageData);
    }
  }

  void _stopCamera() {
    if (_videoElement?.srcObject != null) {
      final stream = _videoElement!.srcObject as html.MediaStream;
      stream.getTracks().forEach((track) => track.stop());
      _videoElement!.srcObject = null;
    }
  }

  @override
  void dispose() {
    _stopCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ambil Foto"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _stopCamera();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),

            if (errorMessage != null) ...[
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Column(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 48),
                    SizedBox(height: 8),
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red[800]),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _initCamera,
                      child: Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ] else if (isLoading) ...[
              SizedBox(
                width: 300,
                height: 300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Menyiapkan kamera...'),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // ====== LIVE CAMERA VIEW ======
              if (isCapturing)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: HtmlElementView(viewType: _viewType),
                  ),
                ),

              // ====== PREVIEW ======
              if (!isCapturing && capturedImage != null)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green[300]!),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Image.memory(
                    capturedImage!,
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
            ],

            const SizedBox(height: 20),

            // ====== BUTTON LIST ======
            if (!isLoading && errorMessage == null) ...[
              if (isCapturing)
                ElevatedButton.icon(
                  onPressed: capturePhoto,
                  icon: Icon(Icons.camera_alt),
                  label: Text("Ambil Foto"),
                ),

              if (!isCapturing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: retake,
                      child: Text("Ambil Ulang"),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _usePhoto,
                      child: Text("Gunakan Foto"),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}
