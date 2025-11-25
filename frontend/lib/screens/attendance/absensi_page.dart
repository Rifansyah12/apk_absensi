import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:apk_absensi/config/api.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:apk_absensi/widgets/attendance_widgets.dart';

class TodayAttendance {
  int? id;
  String? checkIn;
  String? checkOut;
  Uint8List? selfieCheckInBytes;
  Uint8List? selfieCheckOutBytes;
  String? notes;
  String? status;
  String? locationCheckIn;
  String? locationCheckOut;
  int? lateMinutes;
  int? overtimeMinutes;
  String? selfieCheckInPath;
  String? selfieCheckOutPath;

  TodayAttendance({
    this.id,
    this.checkIn,
    this.checkOut,
    this.selfieCheckInBytes,
    this.selfieCheckOutBytes,
    this.notes,
    this.status,
    this.locationCheckIn,
    this.locationCheckOut,
    this.lateMinutes,
    this.overtimeMinutes,
    this.selfieCheckInPath,
    this.selfieCheckOutPath,
  });

  bool get hasCheckedIn => checkIn != null;
  bool get hasCheckedOut => checkOut != null;
  bool get hasSelfieCheckIn =>
      selfieCheckInPath != null && selfieCheckInPath!.isNotEmpty;
  bool get hasSelfieCheckOut =>
      selfieCheckOutPath != null && selfieCheckOutPath!.isNotEmpty;
}

class AbsensiPage extends StatefulWidget {
  final String userName;
  final String token;

  const AbsensiPage({required this.userName, required this.token, super.key});

  @override
  _AbsensiPageState createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  TodayAttendance? _todayAttendance;
  String _todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool _isProcessing = false;
  bool _isCheckIn = true;
  String _notes = '';
  String? _lastError;
  bool _isLoading = true;
  late final StreamSubscription<html.MessageEvent> _messageSub;
  final TextEditingController _notesController = TextEditingController();

  // Cache untuk foto yang sudah diload
  final Map<String, Uint8List> _photoCache = {};

  @override
  void initState() {
    super.initState();
    _messageSub = html.window.onMessage.listen(_handleMessage);
    _loadTodayAttendance();
  }

  @override
  void dispose() {
    _messageSub.cancel();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadTodayAttendance() async {
    try {
      setState(() {
        _isLoading = true;
        _lastError = null;
      });

      final url = Uri.parse('${ApiConfig.baseUrl}/attendance/today');
      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer ${widget.token}"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final attendanceData = data['data'];
          if (attendanceData != null) {
            await _updateTodayAttendanceFromData(attendanceData);
          } else {
            setState(() {
              _todayAttendance = TodayAttendance();
            });
          }
        } else {
          _handleError('Gagal memuat data absensi: ${data['message']}');
        }
      } else {
        _handleError('Gagal memuat data absensi: ${response.statusCode}');
      }
    } catch (e) {
      _handleError('Error loading today attendance: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateTodayAttendanceFromData(
    Map<String, dynamic> attendanceData,
  ) async {
    TodayAttendance newAttendance = TodayAttendance(
      id: attendanceData['id'],
      checkIn: attendanceData['checkIn'] != null
          ? _formatTime(attendanceData['checkIn'])
          : null,
      checkOut: attendanceData['checkOut'] != null
          ? _formatTime(attendanceData['checkOut'])
          : null,
      status: attendanceData['status'],
      notes: attendanceData['notes'],
      locationCheckIn: attendanceData['locationCheckIn'],
      locationCheckOut: attendanceData['locationCheckOut'],
      lateMinutes: attendanceData['lateMinutes'],
      overtimeMinutes: attendanceData['overtimeMinutes'],
      selfieCheckInPath: attendanceData['selfieCheckIn'],
      selfieCheckOutPath: attendanceData['selfieCheckOut'],
    );

    setState(() {
      _todayAttendance = newAttendance;
    });

    // Load photos jika ada - dengan error handling yang lebih baik
    if (newAttendance.hasSelfieCheckIn) {
      await _loadSelfiePhoto(newAttendance.selfieCheckInPath!, isCheckIn: true);
    }
    if (newAttendance.hasSelfieCheckOut) {
      await _loadSelfiePhoto(
        newAttendance.selfieCheckOutPath!,
        isCheckIn: false,
      );
    }
  }

  String _formatTime(String isoTime) {
    try {
      return DateFormat('HH:mm:ss').format(DateTime.parse(isoTime).toLocal());
    } catch (e) {
      return isoTime;
    }
  }

  Future<void> _loadSelfiePhoto(
    String imagePath, {
    required bool isCheckIn,
  }) async {
    // Cek cache dulu
    final cacheKey = isCheckIn ? 'checkin' : 'checkout';
    if (_photoCache.containsKey(cacheKey)) {
      _updatePhotoBytes(_photoCache[cacheKey]!, isCheckIn: isCheckIn);
      return;
    }

    try {
      print('Loading selfie from: $imagePath');

      // Coba beberapa kemungkinan URL
      final possibleUrls = [
        '${ApiConfig.baseUrl}$imagePath', // Full path dengan base API
        '${ApiConfig.baseUrl.replaceAll('/api', '')}$imagePath', // Tanpa /api
        'http://localhost:3000$imagePath', // Langsung ke localhost
      ];

      Uint8List? photoBytes;
      String? successfulUrl;

      for (final url in possibleUrls) {
        try {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            photoBytes = response.bodyBytes;
            successfulUrl = url;
            print('Successfully loaded selfie from: $url');
            break;
          }
        } catch (e) {
          print('Failed to load from $url: $e');
          continue;
        }
      }

      if (photoBytes != null && successfulUrl != null) {
        // Simpan ke cache
        _photoCache[cacheKey] = photoBytes;
        _updatePhotoBytes(photoBytes, isCheckIn: isCheckIn);
      } else {
        print('All URL attempts failed for selfie: $imagePath');
        // Tidak tampilkan error ke user, biarkan placeholder ditampilkan
      }
    } catch (e) {
      print('Error loading selfie: $e');
    }
  }

  void _updatePhotoBytes(Uint8List bytes, {required bool isCheckIn}) {
    if (!mounted) return;

    setState(() {
      if (_todayAttendance != null) {
        if (isCheckIn) {
          _todayAttendance!.selfieCheckInBytes = bytes;
        } else {
          _todayAttendance!.selfieCheckOutBytes = bytes;
        }
      }
    });
  }

  void _handleMessage(html.MessageEvent event) async {
    if (!mounted) return;

    try {
      if (event.data != null && event.data is Map) {
        final data = Map<String, dynamic>.from(event.data);

        if (data['type'] == 'capture' && data['dataUrl'] != null) {
          final dataUrl = data['dataUrl'] as String;
          await _uploadAttendance(dataUrl, isCheckIn: _isCheckIn);
        } else if (data['type'] == 'faceDetection' &&
            data['faceDetected'] != null) {
          bool faceDetected = data['faceDetected'] as bool;
          if (faceDetected) {
            final element = html.document.querySelector('iframe');
            if (element is html.IFrameElement) {
              element.contentWindow?.postMessage({'type': 'takePhoto'}, '*');
            }
          } else {
            _handleError('Wajah tidak terdeteksi. Silakan coba lagi.');
          }
        }
      }
    } catch (e) {
      _handleError('Terjadi kesalahan: $e');
    }
  }

  void _handleError(String error) {
    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _lastError = error;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void captureImage({required bool isCheckIn}) {
    if (_isProcessing) return;

    if (isCheckIn && _todayAttendance?.hasCheckedIn == true) {
      _handleError('Anda sudah melakukan check-in hari ini');
      return;
    }

    if (!isCheckIn && _todayAttendance?.hasCheckedOut == true) {
      _handleError('Anda sudah melakukan check-out hari ini');
      return;
    }

    if (!isCheckIn && _todayAttendance?.hasCheckedIn != true) {
      _handleError('Silakan check-in terlebih dahulu');
      return;
    }

    setState(() {
      _isProcessing = true;
      _isCheckIn = isCheckIn;
      _lastError = null;
    });

    final element = html.document.querySelector('iframe');
    if (element is html.IFrameElement) {
      element.contentWindow?.postMessage({'type': 'detectFace'}, '*');
    } else {
      _handleError('Iframe tidak ditemukan!');
    }
  }

  Future<Map<String, double>> _getCurrentLocation() async {
    try {
      final position = await html.window.navigator.geolocation!
          .getCurrentPosition(enableHighAccuracy: true);

      if (position.coords == null) {
        throw Exception('Koordinat tidak tersedia');
      }

      final coords = position.coords!;
      final lat = (coords.latitude ?? -6.9173248).toDouble();
      final lng = (coords.longitude ?? 107.6461568).toDouble();

      print('Lokasi berhasil didapat: lat=$lat, lng=$lng');
      return {'lat': lat, 'lng': lng};
    } catch (e) {
      print('Error geolocation: $e');
      return {'lat': -6.9173248, 'lng': 107.6461568};
    }
  }

  Future<void> _uploadAttendance(
    String dataUrl, {
    required bool isCheckIn,
  }) async {
    if (!mounted) return;

    try {
      final location = await _getCurrentLocation();
      final url = Uri.parse(
        isCheckIn
            ? '${ApiConfig.baseUrl}/attendance/checkin'
            : '${ApiConfig.baseUrl}/attendance/checkout',
      );

      final base64String = dataUrl.split(',').last;
      final bytes = base64Decode(base64String);

      final request = http.MultipartRequest("POST", url);
      request.headers.addAll({
        "Authorization": "Bearer ${widget.token}",
        "Accept": "application/json",
      });

      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          bytes,
          filename: "attendance.jpg",
          contentType: MediaType("image", "jpeg"),
        ),
      );

      request.fields['lat'] = location['lat'].toString();
      request.fields['lng'] = location['lng'].toString();

      if (isCheckIn) {
        request.fields['note'] = _notesController.text;
      }

      final responseStream = await request.send();
      final responseBody = await responseStream.stream.bytesToString();

      if (!mounted) return;

      setState(() => _isProcessing = false);

      if (responseStream.statusCode == 200) {
        final responseData = jsonDecode(responseBody);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'] ??
                  (isCheckIn ? 'Check-In berhasil!' : 'Check-Out berhasil!'),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        if (responseData['data'] != null) {
          await _updateTodayAttendanceFromData(responseData['data']);
        }

        if (isCheckIn) {
          _notesController.clear();
        }

        await _loadTodayAttendance();
      } else {
        final errorData = jsonDecode(responseBody);
        _handleError(errorData["message"] ?? "Upload gagal");
      }
    } catch (e) {
      if (!mounted) return;
      _handleError('Error upload: $e');
    }
  }

  Widget _buildLocationButton(String? location, {String label = 'Lokasi'}) {
    if (location == null) return SizedBox();

    // ✅ PERBAIKAN: Handle berbagai format lokasi
    double? lat;
    double? lng;
    String locationName = '';

    // Coba parse format: "Nama Lokasi (lat, lng)"
    final regex1 = RegExp(r'(.+)\s*\(([-.\d]+),\s*([-.\d]+)\)');
    final match1 = regex1.firstMatch(location);

    if (match1 != null) {
      locationName = match1.group(1)!.trim();
      lat = double.tryParse(match1.group(2)!);
      lng = double.tryParse(match1.group(3)!);
    } else {
      // Coba parse format: "lat, lng" (tanpa nama)
      final parts = location.split(',');
      if (parts.length == 2) {
        lat = double.tryParse(parts[0].trim());
        lng = double.tryParse(parts[1].trim());
      }
    }

    if (lat == null || lng == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.orange),
              SizedBox(width: 4),
              Text('$label:', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          SizedBox(height: 4),
          Text(
            location,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Text(
            'Format koordinat tidak dikenali',
            style: TextStyle(fontSize: 10, color: Colors.orange),
          ),
        ],
      );
    }

    final mapsUrl = 'https://www.google.com/maps?q=$lat,$lng';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: Colors.blue),
            SizedBox(width: 4),
            Text('$label:', style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {
            html.window.open(mapsUrl, '_blank');
          },
          icon: Icon(Icons.map, size: 16),
          label: Text('Buka di Google Maps'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            backgroundColor: Colors.blue[50],
            foregroundColor: Colors.blue,
            elevation: 0,
          ),
        ),
        SizedBox(height: 4),
        if (locationName.isNotEmpty)
          Text(
            'Lokasi: $locationName',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        Text(
          'Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String? status) {
    if (status == null) return SizedBox();

    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (status) {
      case 'PRESENT':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        statusText = 'TEPAT WAKTU';
        break;
      case 'LATE':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        statusText = 'TERLAMBAT';
        break;
      case 'ABSENT':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        statusText = 'TIDAK HADIR';
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        statusText = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: textColor),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSelfiePhoto(
    Uint8List? photoBytes,
    String label,
    String? imagePath,
  ) {
    final hasPhotoBytes = photoBytes != null;
    final hasImagePath = imagePath != null && imagePath.isNotEmpty;

    return Column(
      children: [
        SizedBox(height: 8),
        Text('$label:', style: TextStyle(fontWeight: FontWeight.w500)),
        SizedBox(height: 4),

        if (hasPhotoBytes)
          Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                photoBytes,
                fit: BoxFit.cover,
                frameBuilder:
                    (
                      BuildContext context,
                      Widget child,
                      int? frame,
                      bool wasSynchronouslyLoaded,
                    ) {
                      // If image was loaded synchronously (already available), just show it
                      if (wasSynchronouslyLoaded) return child;
                      // While frame is null the image is still loading/decoding
                      if (frame == null) {
                        return Center(child: CircularProgressIndicator());
                      }
                      // Once a frame is available, show the image
                      return child;
                    },
                errorBuilder: (context, error, stackTrace) {
                  return _buildPhotoPlaceholder('Gagal memuat foto');
                },
              ),
            ),
          )
        else if (hasImagePath)
          _buildPhotoPlaceholder('Memuat foto...')
        else
          _buildPhotoPlaceholder('Foto tidak tersedia'),
      ],
    );
  }

  Widget _buildPhotoPlaceholder(String message) {
    return Container(
      height: 150,
      width: 150,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo, size: 32, color: Colors.grey[400]),
          SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.token.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Absensi - ${widget.userName}'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/absensi-list');
            },
            tooltip: 'Riwayat Absensi',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Camera View
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SizedBox(
                      width: 320,
                      height: 240,
                      child: HtmlElementView(viewType: 'face-detect'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (_lastError != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange[800]),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _lastError!,
                              style: TextStyle(color: Colors.orange[800]),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  if (_todayAttendance?.hasCheckedIn != true)
                    TextField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'Catatan (opsional)',
                        hintText: 'Tambahkan catatan untuk check-in...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 2,
                    ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              _isProcessing ||
                                  _todayAttendance?.hasCheckedIn == true
                              ? null
                              : () => captureImage(isCheckIn: true),
                          icon: const Icon(Icons.login),
                          label: Text(
                            _isProcessing ? 'Memproses...' : 'Check-In',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              _isProcessing ||
                                  _todayAttendance?.hasCheckedOut == true ||
                                  _todayAttendance?.hasCheckedIn != true
                              ? null
                              : () => captureImage(isCheckIn: false),
                          icon: const Icon(Icons.logout),
                          label: Text(
                            _isProcessing ? 'Memproses...' : 'Check-Out',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.today, color: Colors.blueAccent),
                            SizedBox(width: 8),
                            Text(
                              'Absensi Hari Ini',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blueAccent,
                              ),
                            ),
                            if (_todayAttendance?.status != null) ...[
                              SizedBox(width: 8),
                              _buildStatusBadge(_todayAttendance!.status),
                            ],
                          ],
                        ),

                        const SizedBox(height: 16),

                        if (_todayAttendance?.hasCheckedIn == true) ...[
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.login, color: Colors.green),
                                      SizedBox(width: 8),
                                      Text(
                                        'Check-In',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (_todayAttendance?.lateMinutes !=
                                              null &&
                                          _todayAttendance!.lateMinutes! >
                                              0) ...[
                                        const SizedBox(width: 8),
                                        AttendanceWidgets.buildLateBadge(
                                          lateMinutes:
                                              _todayAttendance!.lateMinutes,
                                          useCompactFormat: true,
                                        ),
                                      ],
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text('Waktu: ${_todayAttendance!.checkIn}'),

                                  _buildLocationButton(
                                    _todayAttendance!.locationCheckIn,
                                    label: 'Lokasi Check-In',
                                  ),

                                  if (_todayAttendance!.notes != null &&
                                      _todayAttendance!.notes!.isNotEmpty) ...[
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.note,
                                          size: 16,
                                          color: Colors.orange,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Catatan:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(_todayAttendance!.notes!),
                                  ],

                                  // Foto Check-In
                                  _buildSelfiePhoto(
                                    _todayAttendance!.selfieCheckInBytes,
                                    'Foto Check-In',
                                    _todayAttendance!.selfieCheckInPath,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                        ],

                        if (_todayAttendance?.hasCheckedOut == true) ...[
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.logout, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Text(
                                        'Check-Out',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (_todayAttendance?.overtimeMinutes !=
                                              null &&
                                          _todayAttendance!.overtimeMinutes! >
                                              0) ...[
                                        SizedBox(width: 8),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green[50],
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            border: Border.all(
                                              color: Colors.green,
                                            ),
                                          ),
                                          child: Text(
                                            '${_todayAttendance!.overtimeMinutes} menit lembur',
                                            style: TextStyle(
                                              color: Colors.green[800],
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text('Waktu: ${_todayAttendance!.checkOut}'),

                                  _buildLocationButton(
                                    _todayAttendance!.locationCheckOut,
                                    label: 'Lokasi Check-Out',
                                  ),

                                  // Foto Check-Out
                                  _buildSelfiePhoto(
                                    _todayAttendance!.selfieCheckOutBytes,
                                    'Foto Check-Out',
                                    _todayAttendance!.selfieCheckOutPath,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        if (_todayAttendance?.hasCheckedIn != true &&
                            _todayAttendance?.hasCheckedOut != true)
                          Container(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Belum ada absensi hari ini',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
