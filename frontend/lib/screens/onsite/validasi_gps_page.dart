import 'package:flutter/material.dart';

class ValidasiGpsPage extends StatefulWidget {
  final Map<String, dynamic>? data;
  
  const ValidasiGpsPage({Key? key, this.data}) : super(key: key);

  @override
  _ValidasiGpsPageState createState() => _ValidasiGpsPageState();
}

class _ValidasiGpsPageState extends State<ValidasiGpsPage> {
  bool _isInLocation = true;
  double _distance = 45.2; // meter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Validasi GPS'),
        backgroundColor: Colors.greenAccent[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      _isInLocation ? Icons.location_on : Icons.location_off,
                      size: 64,
                      color: _isInLocation ? Colors.green : Colors.red,
                    ),
                    SizedBox(height: 16),
                    Text(
                      _isInLocation ? 'Dalam Area Kerja' : 'Di Luar Area Kerja',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _isInLocation ? Colors.green : Colors.red,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Jarak dari titik pusat: ${_distance.toStringAsFixed(1)} meter',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: _distance / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isInLocation ? Colors.green : Colors.red,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Batas radius: 100 meter',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildLocationInfo('Lokasi Saat Ini', '-6.2088', '106.8456'),
                  _buildLocationInfo('Titik Pusat Kantor', '-6.2088', '106.8456'),
                  _buildLocationInfo('Site Terdekat', '-6.2090', '106.8460'),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isInLocation = !_isInLocation;
                  _distance = _isInLocation ? 45.2 : 150.0;
                });
              },
              icon: Icon(Icons.refresh),
              label: Text('Refresh Lokasi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent[700],
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(String title, String lat, String lng) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(Icons.location_pin, color: Colors.greenAccent[700]),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Lat: $lat, Lng: $lng'),
        trailing: Icon(Icons.copy, color: Colors.grey),
      ),
    );
  }
}