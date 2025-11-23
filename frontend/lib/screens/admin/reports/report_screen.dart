// lib/screens/admin/reports/report_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:apk_absensi/models/report_model.dart';
import 'package:apk_absensi/services/report_service.dart';
import 'package:apk_absensi/widgets/loading_widget.dart';
import 'package:apk_absensi/widgets/error_widget.dart' as CustomError;

class ReportScreen extends StatefulWidget {
  final String? division;

  const ReportScreen({Key? key, this.division}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AttendanceReport> _attendanceReports = [];
  List<SalaryReport> _salaryReports = [];
  bool _isLoading = false;
  String _error = '';

  // Filter states
  String _selectedReportType = 'Harian';
  String _selectedDivision = '';
  String _selectedJabatan = '';
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _selectedMonth;
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDivision = widget.division ?? '';
    _selectedMonth = DateTime.now();
    _initializeDates();

    // Load data automatically when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAttendanceReports();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initializeDates() {
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = DateTime(now.year, now.month + 1, 0);
  }

  Future<void> _loadAttendanceReports() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final filter = ReportFilter(
        type: _getReportTypeApiValue(),
        startDate: _startDate,
        endDate: _endDate,
        division: _selectedDivision.isEmpty ? null : _selectedDivision,
        jabatan: _selectedJabatan.isEmpty ? null : _selectedJabatan,
      );

      final reports = await ReportService.getAttendanceReport(filter);

      if (!mounted) return;

      setState(() {
        _attendanceReports = reports;
        _isLoading = false;
      });

      print('✅ Loaded ${reports.length} attendance reports');
    } catch (e) {
      if (!mounted) return;

      print('❌ Error loading attendance reports: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _attendanceReports = [];
      });
    }
  }

  Future<void> _loadSalaryReports() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final filter = ReportFilter(
        type: 'monthly',
        month: _selectedMonth?.month,
        year: _selectedMonth?.year,
        division: _selectedDivision.isEmpty ? null : _selectedDivision,
      );

      final reports = await ReportService.getSalaryReport(filter);

      if (!mounted) return;

      setState(() {
        _salaryReports = reports;
        _isLoading = false;
      });

      print('✅ Loaded ${reports.length} salary reports');
    } catch (e) {
      if (!mounted) return;

      print('❌ Error loading salary reports: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _salaryReports = [];
      });
    }
  }

  String _getReportTypeApiValue() {
    switch (_selectedReportType) {
      case 'Harian':
        return 'daily';
      case 'Mingguan':
        return 'weekly';
      case 'Bulanan':
        return 'monthly';
      default:
        return 'daily';
    }
  }

  void _applyFilters() {
    if (_tabController.index == 0) {
      _loadAttendanceReports();
    } else {
      _loadSalaryReports();
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Filter Laporan'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Report Type
                  _buildFilterField(
                    'Jenis Laporan',
                    DropdownButton<String>(
                      value: _selectedReportType,
                      isExpanded: true,
                      items: ReportData.reportTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          _selectedReportType = value!;
                        });
                      },
                    ),
                  ),

                  // Division
                  _buildFilterField(
                    'Divisi',
                    DropdownButton<String>(
                      value: _selectedDivision,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('Semua Divisi'),
                        ),
                        ...ReportData.divisions.map((division) {
                          return DropdownMenuItem(
                            value: division,
                            child: Text(ReportData.getDivisionLabel(division)),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          _selectedDivision = value!;
                        });
                      },
                    ),
                  ),

                  // Position
                  _buildFilterField(
                    'Jabatan',
                    DropdownButton<String>(
                      value: _selectedJabatan,
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('Semua Jabatan'),
                        ),
                        ...ReportData.positions.map((position) {
                          return DropdownMenuItem(
                            value: position,
                            child: Text(position),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          _selectedJabatan = value!;
                        });
                      },
                    ),
                  ),

                  // Date Range
                  if (_tabController.index == 0) ...[
                    _buildFilterField(
                      'Tanggal Mulai',
                      ListTile(
                        title: Text(
                          _startDate != null
                              ? DateFormat('dd/MM/yyyy').format(_startDate!)
                              : 'Pilih Tanggal',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, true, setDialogState),
                      ),
                    ),
                    _buildFilterField(
                      'Tanggal Akhir',
                      ListTile(
                        title: Text(
                          _endDate != null
                              ? DateFormat('dd/MM/yyyy').format(_endDate!)
                              : 'Pilih Tanggal',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () =>
                            _selectDate(context, false, setDialogState),
                      ),
                    ),
                  ] else ...[
                    // Month selection for salary report
                    _buildFilterField(
                      'Bulan',
                      ListTile(
                        title: Text(
                          _selectedMonth != null
                              ? DateFormat('MMMM yyyy').format(_selectedMonth!)
                              : 'Pilih Bulan',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectMonth(context, setDialogState),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _applyFilters();
                },
                child: const Text('Terapkan'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterField(String label, Widget field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          field,
        ],
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    bool isStart,
    void Function(void Function()) setState,
  ) async {
    final initialDate = isStart ? _startDate : _endDate;
    final firstDate = DateTime(2020);
    final lastDate = DateTime(2030);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectMonth(
    BuildContext context,
    void Function(void Function()) setState,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialEntryMode: DatePickerEntryMode.input,
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  void _exportReport(String format) async {
    try {
      if (_tabController.index == 0) {
        final filter = ReportFilter(
          type: _getReportTypeApiValue(),
          startDate: _startDate,
          endDate: _endDate,
          division: _selectedDivision.isEmpty ? null : _selectedDivision,
          jabatan: _selectedJabatan.isEmpty ? null : _selectedJabatan,
        );

        await ReportService.exportAttendanceReport(
          filter: filter,
          format: format,
        );
      } else {
        final filter = ReportFilter(
          type: 'monthly',
          month: _selectedMonth?.month,
          year: _selectedMonth?.year,
          division: _selectedDivision.isEmpty ? null : _selectedDivision,
        );

        await ReportService.exportSalaryReport(filter: filter, format: format);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Laporan berhasil diexport ke $format'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal export laporan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Laporan'),
        content: const Text('Pilih format export:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _exportReport('pdf');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('PDF'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _exportReport('excel');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Excel'),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceReport() {
    if (_isLoading) return const LoadingWidget();
    if (_error.isNotEmpty) {
      return CustomError.ErrorWidget(
        error: _error,
        onRetry: _loadAttendanceReports,
      );
    }
    if (_attendanceReports.isEmpty) {
      return _buildEmptyState(
        'Tidak ada data absensi untuk filter yang dipilih',
      );
    }

    final summary = ReportService.calculateAttendanceSummary(
      _attendanceReports,
    );

    return Column(
      children: [
        // Summary Cards
        _buildSummaryCards(summary),

        // Data Table dengan scroll horizontal yang baik
        Expanded(child: _buildAttendanceTable()),
      ],
    );
  }

  Widget _buildAttendanceTable() {
    final double tableWidth = 1360; // total lebar tabel - disesuaikan

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: tableWidth,
        child: Column(
          children: [
            _buildTableHeader(),

            // Body table
            Expanded(
              child: ListView.builder(
                itemCount: _attendanceReports.length,
                itemBuilder: (context, index) {
                  final report = _attendanceReports[index];
                  final decision = ReportService.calculateSalaryDecisionTree(
                    report,
                  );

                  return _buildAttendanceTableRow(report, decision, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      color: Colors.grey[200],
      child: Row(
        children: [
          SizedBox(width: 200, child: Text('Nama', style: _headerTextStyle())),
          SizedBox(
            width: 150,
            child: Text('Jabatan', style: _headerTextStyle()),
          ),
          SizedBox(
            width: 120,
            child: Text('Tanggal', style: _headerTextStyle()),
          ),
          SizedBox(width: 100, child: Text('Masuk', style: _headerTextStyle())),
          SizedBox(
            width: 100,
            child: Text('Pulang', style: _headerTextStyle()),
          ),
          SizedBox(
            width: 120,
            child: Text('Terlambat', style: _headerTextStyle()),
          ),
          SizedBox(
            width: 100,
            child: Text('Lembur', style: _headerTextStyle()),
          ),
          SizedBox(
            width: 120,
            child: Text('Potongan', style: _headerTextStyle()),
          ),
          SizedBox(
            width: 100,
            child: Text('Total Gaji', style: _headerTextStyle()),
          ),
          SizedBox(
            width: 100,
            child: Text('Lokasi', style: _headerTextStyle()),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTableRow(
    AttendanceReport report,
    Map<String, dynamic> decision,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        color: index.isEven ? Colors.grey[50] : Colors.white,
        child: Row(
          children: [
            SizedBox(
              width: 200,
              child: Text(
                report.nama,
                style: _cellTextStyle(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 150,
              child: Text(
                report.jabatan,
                style: _cellTextStyle(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 120,
              child: Text(
                report.tanggal,
                style: _cellTextStyle(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                report.jamMasuk,
                style: _cellTextStyle(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                report.jamPulang,
                style: _cellTextStyle(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 120,
              child: Text(
                ReportData.formatMinutes(report.terlambat),
                style: _cellTextStyle(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                '${report.lembur.toStringAsFixed(1)} jam',
                style: _cellTextStyle(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 120,
              child: Text(
                ReportData.formatCurrency(report.potongan),
                style: _cellTextStyle(color: Colors.red),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 150,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Tooltip(
                  triggerMode: TooltipTriggerMode.tap,
                  waitDuration: const Duration(milliseconds: 300),
                  showDuration: const Duration(seconds: 3),
                  message:
                      'Kategori: ${decision['kategori']}\nBonus: ${ReportData.formatCurrency(decision['bonus'])}',
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      ReportData.formatCurrency(report.totalGaji),
                      style: _cellTextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                report.lokasi,
                style: _cellTextStyle(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryReport() {
    if (_isLoading) return const LoadingWidget();
    if (_error.isNotEmpty) {
      return CustomError.ErrorWidget(
        error: _error,
        onRetry: _loadSalaryReports,
      );
    }
    if (_salaryReports.isEmpty) {
      return _buildEmptyState('Tidak ada data gaji untuk filter yang dipilih');
    }

    final totalGaji = _salaryReports.fold(
      0.0,
      (sum, report) => sum + report.totalGaji,
    );
    final totalLembur = _salaryReports.fold(
      0.0,
      (sum, report) => sum + report.lembur,
    );
    final totalPotongan = _salaryReports.fold(
      0.0,
      (sum, report) => sum + report.potongan,
    );

    return Column(
      children: [
        // Summary
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Total Gaji',
                  ReportData.formatCurrency(totalGaji),
                  Colors.green,
                ),
                _buildSummaryItem(
                  'Total Lembur',
                  ReportData.formatCurrency(totalLembur),
                  Colors.orange,
                ),
                _buildSummaryItem(
                  'Total Potongan',
                  ReportData.formatCurrency(totalPotongan),
                  Colors.red,
                ),
              ],
            ),
          ),
        ),

        // Data Table dengan struktur yang sama seperti absensi
        Expanded(child: _buildSalaryTable()),
      ],
    );
  }

  Widget _buildSalaryTable() {
    final double tableWidth = 1010; // total lebar untuk 7 kolom

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: tableWidth,
        child: Column(
          children: [
            _buildSalaryTableHeader(),

            // Body table
            Expanded(
              child: ListView.builder(
                itemCount: _salaryReports.length,
                itemBuilder: (context, index) {
                  final report = _salaryReports[index];
                  return _buildSalaryTableRow(report, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      color: Colors.grey[200],
      child: Row(
        children: [
          SizedBox(width: 200, child: Text('Nama', style: _headerTextStyle())),
          SizedBox(
            width: 150,
            child: Text('Jabatan', style: _headerTextStyle()),
          ),
          SizedBox(
            width: 120,
            child: Text('Divisi', style: _headerTextStyle()),
          ),
          SizedBox(
            width: 150,
            child: Text('Gaji Pokok', style: _headerTextStyle()),
          ),
          SizedBox(
            width: 120,
            child: Text('Lembur', style: _headerTextStyle()),
          ),
          SizedBox(
            width: 120,
            child: Text('Potongan', style: _headerTextStyle()),
          ),
          SizedBox(
            width: 100,
            child: Text('Total Gaji', style: _headerTextStyle()),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryTableRow(SalaryReport report, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 1,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        color: index.isEven ? Colors.grey[50] : Colors.white,
        child: Row(
          children: [
            SizedBox(
              width: 200,
              child: Text(
                report.nama,
                style: _cellTextStyle(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 150,
              child: Text(
                report.jabatan,
                style: _cellTextStyle(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 120,
              child: Text(
                ReportData.getDivisionLabel(report.divisi),
                style: _cellTextStyle(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 150,
              child: Text(
                ReportData.formatCurrency(report.gajiPokok),
                style: _cellTextStyle(),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 120,
              child: Text(
                ReportData.formatCurrency(report.lembur),
                style: _cellTextStyle(color: Colors.orange),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 120,
              child: Text(
                ReportData.formatCurrency(report.potongan),
                style: _cellTextStyle(color: Colors.red),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 100,
              child: Text(
                ReportData.formatCurrency(report.totalGaji),
                style: _cellTextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _headerTextStyle() {
    return const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: Colors.black87,
    );
  }

  TextStyle _cellTextStyle({Color? color, FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: 12,
      color: color ?? Colors.black87,
      fontWeight: fontWeight ?? FontWeight.normal,
    );
  }

  Widget _buildSummaryCards(ReportSummary summary) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(
              'Total Records',
              summary.totalRecords.toString(),
              Colors.blue,
            ),
            _buildSummaryItem(
              'Total Lembur',
              '${summary.totalLembur.toStringAsFixed(1)} jam',
              Colors.orange,
            ),
            _buildSummaryItem(
              'Total Potongan',
              ReportData.formatCurrency(summary.totalPotongan),
              Colors.red,
            ),
            _buildSummaryItem(
              'Rata Terlambat',
              ReportData.formatMinutes(summary.rataRataTerlambat.toInt()),
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.assessment, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assessment, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _applyFilters,
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
        title: const Text('Laporan'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Laporan Absensi'),
            Tab(text: 'Laporan Gaji'),
          ],
          onTap: (index) {
            // Load data when tab is switched
            if (index == 0 && _attendanceReports.isEmpty && !_isLoading) {
              _loadAttendanceReports();
            } else if (index == 1 && _salaryReports.isEmpty && !_isLoading) {
              _loadSalaryReports();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _showExportDialog,
            tooltip: 'Export',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _applyFilters,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildAttendanceReport(), _buildSalaryReport()],
      ),
    );
  }
}
