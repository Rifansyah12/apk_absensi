import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:apk_absensi/config/api.dart';
import 'package:apk_absensi/models/salary_model.dart';
import 'package:apk_absensi/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class SalaryListPage extends StatefulWidget {
  const SalaryListPage({super.key});

  @override
  State<SalaryListPage> createState() => _SalaryListPageState();
}

class _SalaryListPageState extends State<SalaryListPage> {
  List<Salary> _salaries = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadSalaries();
  }

  Future<void> _loadSalaries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');

      if (_token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/salaries/my-salaries'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final List<dynamic> salariesData = responseData['data'];
          setState(() {
            _salaries = salariesData
                .map((data) => Salary.fromJson(data))
                .toList();
            _isLoading = false;
          });
        } else {
          throw Exception(responseData['message'] ?? 'Gagal memuat data gaji');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error loading salaries: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data gaji: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSalaryCard(Salary salary) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan periode dan badge current
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  salary.period,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blueAccent,
                  ),
                ),
                if (salary.isCurrentPeriod)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Text(
                      'Bulan Ini',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Total Gaji
            _buildSalaryItem(
              'Total Gaji',
              CurrencyFormatter.formatRupiah(salary.totalSalary),
              isTotal: true,
            ),
            const SizedBox(height: 8),

            // Detail breakdown
            _buildBreakdownSection(salary),
            const SizedBox(height: 8),

            // Footer dengan tanggal generate
            Divider(color: Colors.grey[300], height: 1),
            const SizedBox(height: 8),
            Text(
              'Digenerate pada: ${DateFormat('dd/MM/yyyy').format(salary.createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryItem(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.green[700] : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.green[700] : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownSection(Salary salary) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200] ?? Colors.grey),
      ),
      child: Column(
        children: [
          _buildBreakdownItem(
            'Gaji Pokok',
            CurrencyFormatter.formatRupiah(salary.baseSalary),
            Colors.blue,
          ),
          const SizedBox(height: 6),
          _buildBreakdownItem(
            'Lembur',
            CurrencyFormatter.formatRupiah(salary.overtimeSalary),
            Colors.orange,
          ),
          const SizedBox(height: 6),
          _buildBreakdownItem(
            'Potongan',
            CurrencyFormatter.formatRupiah(-salary.deduction),
            Colors.red,
          ),
          const SizedBox(height: 6),
          Divider(color: Colors.grey[300] ?? Colors.grey, height: 1),
          const SizedBox(height: 6),
          _buildBreakdownItem(
            'TAKE HOME PAY',
            CurrencyFormatter.formatRupiah(salary.totalSalary),
            Colors.green,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(
    String label,
    String value,
    Color color, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? color : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    if (_salaries.isEmpty) return const SizedBox();

    final totalBase = _salaries.fold(
      0.0,
      (sum, salary) => sum + salary.baseSalary,
    );
    final totalOvertime = _salaries.fold(
      0.0,
      (sum, salary) => sum + salary.overtimeSalary,
    );
    final totalDeductions = _salaries.fold(
      0.0,
      (sum, salary) => sum + salary.deduction,
    );
    final totalNet = _salaries.fold(
      0.0,
      (sum, salary) => sum + salary.totalSalary,
    );

    // Ambil tahun dari data gaji pertama (atau tahun berjalan jika tidak ada data)
    final currentYear = _salaries.isNotEmpty
        ? _getYearFromPeriod(_salaries.first.period)
        : DateTime.now().year.toString();

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Gaji Periode $currentYear',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryItem('Total Gaji Pokok', totalBase),
            _buildSummaryItem('Total Lembur', totalOvertime),
            _buildSummaryItem('Total Potongan', totalDeductions),
            const SizedBox(height: 8),
            Divider(color: Colors.blue[200], height: 1),
            const SizedBox(height: 8),
            _buildSummaryItem('TOTAL DITERIMA', totalNet, isTotal: true),
          ],
        ),
      ),
    );
  }

  // Helper function untuk extract tahun dari string periode
  String _getYearFromPeriod(String period) {
    try {
      // Format periode: "November 2025" atau "Nov 2025"
      final parts = period.split(' ');
      if (parts.length >= 2) {
        return parts.last; // Mengembalikan bagian terakhir (tahun)
      }
      return DateTime.now().year.toString();
    } catch (e) {
      return DateTime.now().year.toString();
    }
  }

  Widget _buildSummaryItem(
    String label,
    double amount, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue[800] : Colors.blue[700],
            ),
          ),
          Text(
            CurrencyFormatter.formatRupiah(amount),
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue[800] : Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.money_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Belum ada data gaji',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Data gaji akan tersedia setelah proses penggajian',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Memuat data gaji...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          const Text(
            'Gagal memuat data',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            _hasError
                ? 'Terjadi kesalahan saat memuat data gaji'
                : 'Token tidak valid',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadSalaries,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gaji & Potongan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.greenAccent[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSalaries,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _hasError
          ? _buildErrorState()
          : _salaries.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadSalaries,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 16),
                  const Text(
                    'Riwayat Gaji',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._salaries
                      .map((salary) => _buildSalaryCard(salary))
                      .toList(),
                ],
              ),
            ),
    );
  }
}
