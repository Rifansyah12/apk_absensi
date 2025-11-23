import 'package:flutter/material.dart';

class PotonganPage extends StatefulWidget {
  final Map<String, dynamic>? data;
  
  const PotonganPage({Key? key, this.data}) : super(key: key);

  @override
  _PotonganPageState createState() => _PotonganPageState();
}

class _PotonganPageState extends State<PotonganPage> {
  final List<Map<String, dynamic>> _deductions = [
    {'type': 'Keterlambatan', 'amount': 25000, 'date': '2025-01-15', 'reason': 'Terlambat 5 menit'},
    {'type': 'Absen', 'amount': 100000, 'date': '2025-01-10', 'reason': 'Tidak absen tanpa keterangan'},
    {'type': 'Lainnya', 'amount': 50000, 'date': '2025-01-05', 'reason': 'Administrasi'},
  ];

  @override
  Widget build(BuildContext context) {
    double totalDeduction = _deductions.fold(0, (sum, item) => sum + item['amount']);

    return Scaffold(
      appBar: AppBar(
        title: Text('Potongan Gaji'),
        backgroundColor: Colors.greenAccent[700],
      ),
      body: Column(
        children: [
          // Summary Card
          Card(
            margin: EdgeInsets.all(16),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    'Total Potongan Bulan Ini',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Rp ${totalDeduction.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Jumlah', _deductions.length.toString()),
                      _buildStatItem('Terlambat', '1x'),
                      _buildStatItem('Absen', '1x'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // List Potongan
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: _deductions.length,
              itemBuilder: (context, index) {
                final deduction = _deductions[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.money_off,
                        color: Colors.redAccent,
                      ),
                    ),
                    title: Text(
                      deduction['type'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${deduction['date']} - ${deduction['reason']}',
                    ),
                    trailing: Text(
                      'Rp ${deduction['amount'].toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Info
          Container(
            padding: EdgeInsets.all(16),
            child: Text(
              'Potongan dihitung otomatis berdasarkan kehadiran dan keterlambatan',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.greenAccent[700],
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}