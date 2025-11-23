import 'package:flutter/material.dart';

class JamKerjaPage extends StatefulWidget {
  final Map<String, dynamic>? data;
  
  const JamKerjaPage({Key? key, this.data}) : super(key: key);

  @override
  _JamKerjaPageState createState() => _JamKerjaPageState();
}

class _JamKerjaPageState extends State<JamKerjaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan Jam Kerja'),
        backgroundColor: Colors.greenAccent[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jam Kerja Divisi Onsite',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent[700],
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildInfoRow('Jam Masuk', '08:00'),
                    _buildInfoRow('Jam Pulang', '17:00'),
                    _buildInfoRow('Batas Keterlambatan', '15 menit'),
                    _buildInfoRow('Toleransi GPS', '100 meter'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildLocationCard('Kantor Pusat', '-6.2088', '106.8456'),
                  _buildLocationCard('Site Project A', '-6.2188', '106.8356'),
                  _buildLocationCard('Site Project B', '-6.1988', '106.8556'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.greenAccent[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(String name, String lat, String lng) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.location_on, color: Colors.greenAccent[700]),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Lat: $lat, Lng: $lng'),
                ],
              ),
            ),
            Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }
}