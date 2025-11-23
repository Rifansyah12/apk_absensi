// lib/screens/admin/division/division_setting_screen.dart
import 'package:flutter/material.dart';
import 'package:apk_absensi/models/division_setting_model.dart';
import 'package:apk_absensi/services/division_setting_service.dart';
import 'package:apk_absensi/widgets/loading_widget.dart';
import 'package:apk_absensi/widgets/error_widget.dart' as CustomError;

class DivisionSettingScreen extends StatefulWidget {
  final String division;

  // Tidak perlu const di sini karena stateful punya state yang berubah
  DivisionSettingScreen({Key? key, required this.division}) : super(key: key);

  @override
  State<DivisionSettingScreen> createState() => _DivisionSettingScreenState();
}

class _DivisionSettingScreenState extends State<DivisionSettingScreen> {
  DivisionSetting? _setting;
  bool _isLoading = false;
  bool _isEditing = false;
  String _error = '';

  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadSetting();
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _initializeControllers() {
    _controllers['workStartTime'] = TextEditingController();
    _controllers['workEndTime'] = TextEditingController();
    _controllers['lateTolerance'] = TextEditingController();
    _controllers['overtimeRate'] = TextEditingController();
    _controllers['deductionRate'] = TextEditingController();
    _controllers['baseSalary'] = TextEditingController();
    _controllers['deductionPerMinute'] = TextEditingController();
  }

  void _updateControllers() {
    // Gunakan default setting sebagai fallback jika _setting null
    final source =
        _setting ?? DivisionSettingData.getDefaultSetting(widget.division);

    _controllers['workStartTime']!.text = source.workStartTime;
    _controllers['workEndTime']!.text = source.workEndTime;
    _controllers['lateTolerance']!.text = (source.lateTolerance ?? 0)
        .toString();
    _controllers['overtimeRate']!.text = (source.overtimeRate ?? 0.0)
        .toString();
    _controllers['deductionRate']!.text = (source.deductionRate ?? 0.0)
        .toString();
    _controllers['baseSalary']!.text = source.baseSalary?.toString() ?? '';
    _controllers['deductionPerMinute']!.text =
        source.deductionPerMinute?.toString() ?? '';
  }

  Future<void> _loadSetting() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final setting = await DivisionSettingService.getDivisionSetting(
        widget.division,
      );

      if (!mounted) return;

      setState(() {
        _setting = setting;
        _isLoading = false;
      });

      _updateControllers();
      // debug
      // print('✅ Loaded setting for ${widget.division}');
    } catch (e) {
      if (!mounted) return;

      // Kalau gagal, isi dengan default supaya UI tidak crash
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _setting = DivisionSettingData.getDefaultSetting(widget.division);
      });

      _updateControllers();
      // debug
      // print('❌ Error loading division setting: $e');
    }
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _updateControllers(); // Reset ke nilai sebelumnya / default
    });
  }

  Future<void> _saveSetting() async {
    // Validasi form terlebih dahulu
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // parsing aman dengan tryParse (fallback jika aneh)
      final lateTolerance =
          int.tryParse(_controllers['lateTolerance']!.text) ?? 0;
      final overtimeRate =
          double.tryParse(_controllers['overtimeRate']!.text) ?? 0.0;
      final deductionRate =
          double.tryParse(_controllers['deductionRate']!.text) ?? 0.0;
      final baseSalary = _controllers['baseSalary']!.text.isNotEmpty
          ? double.tryParse(_controllers['baseSalary']!.text)
          : null;
      final deductionPerMinute =
          _controllers['deductionPerMinute']!.text.isNotEmpty
          ? double.tryParse(_controllers['deductionPerMinute']!.text)
          : null;

      final newSetting = DivisionSetting(
        division: widget.division,
        workStartTime: _controllers['workStartTime']!.text,
        workEndTime: _controllers['workEndTime']!.text,
        lateTolerance: lateTolerance,
        overtimeRate: overtimeRate,
        deductionRate: deductionRate,
        baseSalary: baseSalary,
        deductionPerMinute: deductionPerMinute,
      );

      // Try update; kalau gagal, create
      try {
        await DivisionSettingService.updateDivisionSetting(
          widget.division,
          newSetting,
        );
      } catch (e) {
        await DivisionSettingService.createDivisionSetting(newSetting);
      }

      if (!mounted) return;

      setState(() {
        _setting = newSetting;
        _isEditing = false;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengaturan divisi berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan pengaturan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // BORDER UTAMA untuk TextField agar konsisten
  OutlineInputBorder _inputBorder(Color borderColor) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: borderColor, width: 1),
    );
  }

  // Header Card
  Widget _buildDivisionHeader(bool isCompact) {
    final color = DivisionSettingData.getDivisionColor(widget.division);
    return Card(
      elevation: 2,
      margin: EdgeInsets.fromLTRB(
        isCompact ? 12 : 16,
        isCompact ? 12 : 16,
        isCompact ? 12 : 16,
        8,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(isCompact ? 12 : 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [color.withOpacity(0.12), color.withOpacity(0.04)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              radius: isCompact ? 22 : 28,
              child: Icon(
                DivisionSettingData.getDivisionIcon(widget.division),
                color: Colors.white,
                size: isCompact ? 22 : 28,
              ),
            ),
            SizedBox(width: isCompact ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DivisionSettingData.getDivisionLabel(widget.division),
                    style: TextStyle(
                      fontSize: isCompact ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: isCompact ? 4 : 6),
                  Text(
                    'Pengaturan Konfigurasi Divisi',
                    style: TextStyle(
                      fontSize: isCompact ? 12 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (!_isEditing && _setting != null)
              ElevatedButton.icon(
                onPressed: _startEditing,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 10 : 14,
                    vertical: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingForm(bool isCompact) {
    if (_isLoading) return const LoadingWidget();
    if (_error.isNotEmpty && _setting == null) {
      return CustomError.ErrorWidget(error: _error, onRetry: _loadSetting);
    }

    final cardMargin = EdgeInsets.fromLTRB(
      isCompact ? 12 : 16,
      0,
      isCompact ? 12 : 16,
      16,
    );

    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: cardMargin,
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 14 : 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isEditing) _buildActionButtons(isCompact),
              if (_isEditing) SizedBox(height: isCompact ? 12 : 18),

              _buildSectionHeader('Jam Kerja', isCompact),
              SizedBox(height: isCompact ? 10 : 16),
              _buildWorkHoursSection(isCompact),
              SizedBox(height: isCompact ? 14 : 24),

              _buildSectionHeader('Toleransi dan Tarif', isCompact),
              SizedBox(height: isCompact ? 10 : 16),
              _buildToleranceRatesSection(isCompact),
              SizedBox(height: isCompact ? 14 : 24),

              _buildSectionHeader('Pengaturan Gaji', isCompact),
              SizedBox(height: isCompact ? 10 : 16),
              _buildSalarySection(isCompact),
              SizedBox(height: isCompact ? 14 : 24),

              if (!_isEditing) _buildInfoSection(isCompact),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isCompact) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 10 : 16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: _cancelEditing,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 14 : 24,
                vertical: 10,
              ),
            ),
            child: const Text('Batal'),
          ),
          SizedBox(width: isCompact ? 8 : 12),
          ElevatedButton(
            onPressed: _saveSetting,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 14 : 24,
                vertical: 10,
              ),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isCompact) {
    final color = DivisionSettingData.getDivisionColor(widget.division);
    return Row(
      children: [
        Container(
          width: 4,
          height: isCompact ? 18 : 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: isCompact ? 8 : 12),
        Text(
          title,
          style: TextStyle(
            fontSize: isCompact ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkHoursSection(bool isCompact) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        if (isWide) {
          return Row(
            children: [
              Expanded(
                child: _buildTimeField(
                  'Jam Masuk',
                  'workStartTime',
                  Icons.access_time,
                ),
              ),
              SizedBox(width: isCompact ? 10 : 16),
              Expanded(
                child: _buildTimeField(
                  'Jam Pulang',
                  'workEndTime',
                  Icons.access_time,
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildTimeField('Jam Masuk', 'workStartTime', Icons.access_time),
              SizedBox(height: isCompact ? 10 : 16),
              _buildTimeField('Jam Pulang', 'workEndTime', Icons.access_time),
            ],
          );
        }
      },
    );
  }

  Widget _buildToleranceRatesSection(bool isCompact) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        if (isWide) {
          return Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  'Toleransi Keterlambatan (menit)',
                  'lateTolerance',
                  Icons.timer,
                ),
              ),
              SizedBox(width: isCompact ? 8 : 12),
              Expanded(
                child: _buildNumberField(
                  'Rate Lembur (x)',
                  'overtimeRate',
                  Icons.attach_money,
                ),
              ),
              SizedBox(width: isCompact ? 8 : 12),
              Expanded(
                child: _buildNumberField(
                  'Rate Potongan (%)',
                  'deductionRate',
                  Icons.money_off,
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildNumberField(
                'Toleransi Keterlambatan (menit)',
                'lateTolerance',
                Icons.timer,
              ),
              SizedBox(height: isCompact ? 8 : 12),
              _buildNumberField(
                'Rate Lembur (x)',
                'overtimeRate',
                Icons.attach_money,
              ),
              SizedBox(height: isCompact ? 8 : 12),
              _buildNumberField(
                'Rate Potongan (%)',
                'deductionRate',
                Icons.money_off,
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildSalarySection(bool isCompact) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        if (isWide) {
          return Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  'Gaji Pokok (Rp)',
                  'baseSalary',
                  Icons.account_balance_wallet,
                  isOptional: true,
                ),
              ),
              SizedBox(width: isCompact ? 8 : 12),
              Expanded(
                child: _buildNumberField(
                  'Potongan per Menit (Rp)',
                  'deductionPerMinute',
                  Icons.timer_off,
                  isOptional: true,
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildNumberField(
                'Gaji Pokok (Rp)',
                'baseSalary',
                Icons.account_balance_wallet,
                isOptional: true,
              ),
              SizedBox(height: isCompact ? 8 : 12),
              _buildNumberField(
                'Potongan per Menit (Rp)',
                'deductionPerMinute',
                Icons.timer_off,
                isOptional: true,
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildTimeField(String label, String key, IconData icon) {
    final color = DivisionSettingData.getDivisionColor(widget.division);
    return TextFormField(
      controller: _controllers[key],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color),
        border: _inputBorder(Colors.grey.shade300),
        enabledBorder: _inputBorder(Colors.grey.shade300),
        focusedBorder: _inputBorder(color),
        filled: !_isEditing,
        fillColor: !_isEditing ? Colors.grey[50] : Colors.white,
        enabled: _isEditing,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: TextStyle(
          color: _isEditing ? Colors.black87 : Colors.grey[600],
        ),
      ),
      style: TextStyle(
        color: _isEditing ? Colors.black87 : Colors.grey[700],
        fontWeight: _isEditing ? FontWeight.normal : FontWeight.w500,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label harus diisi';
        }
        if (!RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value)) {
          return 'Format waktu tidak valid (HH:MM)';
        }
        return null;
      },
    );
  }

  Widget _buildNumberField(
    String label,
    String key,
    IconData icon, {
    bool isOptional = false,
  }) {
    final color = DivisionSettingData.getDivisionColor(widget.division);
    final suffixText = key == 'baseSalary' || key == 'deductionPerMinute'
        ? 'Rp'
        : key == 'deductionRate'
        ? '%'
        : '';
    return TextFormField(
      controller: _controllers[key],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color),
        border: _inputBorder(Colors.grey.shade300),
        enabledBorder: _inputBorder(Colors.grey.shade300),
        focusedBorder: _inputBorder(color),
        filled: !_isEditing,
        fillColor: !_isEditing ? Colors.grey[50] : Colors.white,
        enabled: _isEditing,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: TextStyle(
          color: _isEditing ? Colors.black87 : Colors.grey[600],
        ),
        suffixText: suffixText,
        suffixStyle: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
        ),
      ),
      style: TextStyle(
        color: _isEditing ? Colors.black87 : Colors.grey[700],
        fontWeight: _isEditing ? FontWeight.normal : FontWeight.w500,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (!isOptional && (value == null || value.isEmpty)) {
          return '$label harus diisi';
        }
        if (value != null && value.isNotEmpty) {
          final numValue = double.tryParse(value);
          if (numValue == null) {
            return '$label harus berupa angka';
          }
          if (numValue < 0) {
            return '$label tidak boleh negatif';
          }
        }
        return null;
      },
    );
  }

  Widget _buildInfoSection(bool isCompact) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.green[700]),
              SizedBox(width: isCompact ? 8 : 10),
              Text(
                'Informasi Pengaturan Saat Ini',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isCompact ? 14 : 16,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 10 : 16),
          Wrap(
            spacing: isCompact ? 10 : 20,
            runSpacing: isCompact ? 8 : 12,
            children: [
              _buildInfoChip(
                'Jam Kerja',
                '${_setting?.workStartTime} - ${_setting?.workEndTime}',
              ),
              _buildInfoChip(
                'Toleransi Keterlambatan',
                '${_setting?.lateTolerance ?? 0} menit',
              ),
              _buildInfoChip('Rate Lembur', '${_setting?.overtimeRate ?? 0}x'),
              _buildInfoChip(
                'Rate Potongan',
                '${_setting?.deductionRate ?? 0}%',
              ),
              if (_setting?.baseSalary != null)
                _buildInfoChip(
                  'Gaji Pokok',
                  'Rp ${_formatCurrency(_setting!.baseSalary!)}',
                ),
              if (_setting?.deductionPerMinute != null)
                _buildInfoChip(
                  'Potongan per Menit',
                  'Rp ${_formatCurrency(_setting!.deductionPerMinute!)}',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 400;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pengaturan ${DivisionSettingData.getDivisionLabel(widget.division)}',
        ),
        backgroundColor: DivisionSettingData.getDivisionColor(widget.division),
        foregroundColor: Colors.white,
        actions: [
          if (_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _cancelEditing,
              tooltip: 'Batal Edit',
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveSetting,
              tooltip: 'Simpan',
            ),
          ] else if (_setting != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _startEditing,
              tooltip: 'Edit Pengaturan',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSetting,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 : 12),
          child: Column(
            children: [
              _buildDivisionHeader(isCompact),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildSettingForm(isCompact),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
