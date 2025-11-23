// lib/screens/admin/division/division_settings_overview_screen.dart
import 'package:flutter/material.dart';
import 'package:apk_absensi/models/division_setting_model.dart';
import 'package:apk_absensi/services/division_setting_service.dart';
import 'package:apk_absensi/widgets/loading_widget.dart';
import 'package:apk_absensi/widgets/error_widget.dart' as CustomError;
import 'package:apk_absensi/screens/admin/division/division_setting_screen.dart';

class DivisionSettingsOverviewScreen extends StatefulWidget {
  const DivisionSettingsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<DivisionSettingsOverviewScreen> createState() =>
      _DivisionSettingsOverviewScreenState();
}

class _DivisionSettingsOverviewScreenState
    extends State<DivisionSettingsOverviewScreen> {
  List<DivisionSetting> _settings = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadAllSettings();
  }

  Future<void> _loadAllSettings() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final settings = await DivisionSettingService.getAllDivisionSettings();

      if (!mounted) return;

      setState(() {
        _settings = settings;
        _isLoading = false;
      });

      print('✅ Loaded ${settings.length} division settings');
    } catch (e) {
      if (!mounted) return;

      print('❌ Error loading division settings: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _settings = [];
      });
    }
  }

  Widget _buildSettingCard(DivisionSetting setting) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          DivisionSettingData.getDivisionIcon(setting.division),
          size: 32,
          color: DivisionSettingData.getDivisionColor(setting.division),
        ),
        title: Text(
          DivisionSettingData.getDivisionLabel(setting.division),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Jam Kerja: ${setting.workStartTime} - ${setting.workEndTime}',
            ),
            Text('Toleransi: ${setting.lateTolerance} menit'),
            Text('Rate Lembur: ${setting.overtimeRate}x'),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DivisionSettingScreen(division: setting.division),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada pengaturan divisi',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAllSettings,
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
        title: const Text('Pengaturan Semua Divisi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllSettings,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error.isNotEmpty
          ? CustomError.ErrorWidget(error: _error, onRetry: _loadAllSettings)
          : _settings.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: _settings.length,
              itemBuilder: (context, index) {
                return _buildSettingCard(_settings[index]);
              },
            ),
    );
  }
}
