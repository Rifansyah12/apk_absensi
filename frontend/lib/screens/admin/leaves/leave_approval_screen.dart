// lib/screens/admin/leaves/leave_approval_screen.dart - UPDATE
import 'package:flutter/material.dart';
import 'package:apk_absensi/models/leave_model.dart';
import 'package:apk_absensi/services/leave_service.dart';
import 'package:apk_absensi/widgets/loading_widget.dart';
import 'package:apk_absensi/widgets/error_widget.dart' as CustomError;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class LeaveApprovalScreen extends StatefulWidget {
  final String? division;

  const LeaveApprovalScreen({Key? key, this.division}) : super(key: key);

  @override
  State<LeaveApprovalScreen> createState() => _LeaveApprovalScreenState();
}

class _LeaveApprovalScreenState extends State<LeaveApprovalScreen> {
  List<LeaveRequest> _allLeaves = []; // Semua data dari API
  List<LeaveRequest> _filteredLeaves = []; // Data setelah difilter
  bool _isLoading = true;
  String _error = '';
  String _selectedFilter = 'All';
  String _searchQuery = '';

  final List<String> _filterOptions = [
    'All',
    'PENDING',
    'APPROVED',
    'REJECTED',
  ];
  final TextEditingController _searchController = TextEditingController();
  bool _dateFormatInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
    _loadLeaves();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeDateFormatting() async {
    try {
      await initializeDateFormatting('id_ID', null);
      if (mounted) {
        setState(() {
          _dateFormatInitialized = true;
        });
      }
    } catch (e) {
      print('❌ Error initializing date formatting: $e');
      if (mounted) {
        setState(() {
          _dateFormatInitialized = true;
        });
      }
    }
  }

  Future<void> _loadLeaves() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final leaves = await LeaveService.getLeaves();

      // Filter berdasarkan division jika ada
      List<LeaveRequest> filteredLeaves = leaves;
      if (widget.division != null) {
        filteredLeaves = leaves.where((leave) {
          return leave.user?.division == widget.division;
        }).toList();
      }

      if (!mounted) return;

      setState(() {
        _allLeaves = filteredLeaves;
        _isLoading = false;
      });

      // Terapkan filter setelah data dimuat
      _applyFilters();

      print(
        '✅ Loaded ${filteredLeaves.length} leaves for division: ${widget.division}',
      );
    } catch (e) {
      if (!mounted) return;

      print('❌ Error loading leaves: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _allLeaves = [];
        _filteredLeaves = [];
      });

      _showSnackBar('Gagal memuat data cuti: ${e.toString()}', isError: true);
    }
  }

  void _applyFilters() {
    List<LeaveRequest> filtered = _allLeaves;

    // Filter by status
    if (_selectedFilter != 'All') {
      filtered = filtered
          .where((leave) => leave.status == _selectedFilter)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((leave) {
        final user = leave.user;
        if (user != null) {
          final nameMatch = user.name.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
          final employeeIdMatch = user.employeeId.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
          return nameMatch || employeeIdMatch;
        }
        return false;
      }).toList();
    }

    // Sort by created date (newest first)
    filtered.sort((a, b) {
      final aDate = a.createdAt ?? DateTime(2000);
      final bDate = b.createdAt ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

    if (mounted) {
      setState(() {
        _filteredLeaves = filtered;
      });
    }
  }

  void _showActionDialog(LeaveRequest leave, String action) {
    final isApprove = action == 'APPROVED';
    final title = isApprove ? 'Setujui Cuti' : 'Tolak Cuti';
    final buttonText = isApprove ? 'Setujui' : 'Tolak';
    final buttonColor = isApprove ? Colors.green : Colors.red;

    String notes = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Apakah Anda yakin ingin $buttonText pengajuan cuti ini?'),
                const SizedBox(height: 16),
                Text(
                  'Karyawan: ${leave.user?.name ?? 'Unknown'} (${leave.user?.employeeId ?? 'N/A'})',
                ),
                Text(
                  'Periode: ${_formatDate(leave.startDate)} - ${_formatDate(leave.endDate)}',
                ),
                Text('Durasi: ${leave.durationInDays} hari'),
                Text('Jenis: ${_formatLeaveType(leave.type)}'),
                const SizedBox(height: 16),
                const Text('Catatan (opsional):'),
                const SizedBox(height: 8),
                TextField(
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan catatan...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    notes = value;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => _updateLeaveStatus(leave, action, notes),
                style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
                child: Text(buttonText),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateLeaveStatus(
    LeaveRequest leave,
    String status,
    String notes,
  ) async {
    Navigator.pop(context); // Tutup dialog

    try {
      await LeaveService.updateLeaveStatus(
        leaveId: leave.id!,
        status: status,
        notes: notes.isEmpty ? null : notes,
      );

      if (mounted) {
        _showSnackBar(
          'Cuti berhasil ${status == 'APPROVED' ? 'disetujui' : 'ditolak'}',
          isError: false,
        );

        // Load ulang data untuk mendapatkan update terbaru
        await _loadLeaves();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal mengupdate status cuti: $e', isError: true);
      }
    }
  }

  // Safe method untuk show snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatDate(DateTime date) {
    if (!_dateFormatInitialized) return 'Loading...';
    try {
      return DateFormat('dd MMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatLeaveType(String type) {
    return LeaveData.getLabel(type);
  }

  Color _getStatusColor(String status) {
    return LeaveData.getStatusColor(status);
  }

  String _formatStatus(String status) {
    return LeaveData.getStatusLabel(status);
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filterOptions.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                filter == 'All' ? 'Semua' : _formatStatus(filter),
                style: TextStyle(color: isSelected ? Colors.white : null),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (mounted) {
                  setState(() {
                    _selectedFilter = selected ? filter : 'All';
                  });
                }
                _applyFilters();
              },
              backgroundColor: Colors.grey[200],
              selectedColor: _getStatusColor(filter),
              checkmarkColor: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsSummary() {
    final pendingCount = _allLeaves
        .where((leave) => leave.status == 'PENDING')
        .length;
    final approvedCount = _allLeaves
        .where((leave) => leave.status == 'APPROVED')
        .length;
    final rejectedCount = _allLeaves
        .where((leave) => leave.status == 'REJECTED')
        .length;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Menunggu', pendingCount, Colors.orange),
            _buildStatItem('Disetujui', approvedCount, Colors.green),
            _buildStatItem('Ditolak', rejectedCount, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.division != null
              ? 'Persetujuan Cuti - ${widget.division}'
              : 'Persetujuan Cuti',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeaves,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: !_dateFormatInitialized
          ? const Center(child: CircularProgressIndicator())
          : _isLoading
          ? const LoadingWidget()
          : _error.isNotEmpty
          ? CustomError.ErrorWidget(error: _error, onRetry: _loadLeaves)
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Cari nama atau ID karyawan...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          _searchQuery = value;
                        });
                      }
                      _applyFilters();
                    },
                  ),
                ),
                // Stats Summary
                _buildStatsSummary(),
                // Filter Chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildFilterChips(),
                ),
                // Summary
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Total: ${_filteredLeaves.length} pengajuan',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const Spacer(),
                      if (_selectedFilter != 'All' || _searchQuery.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            if (mounted) {
                              setState(() {
                                _selectedFilter = 'All';
                                _searchQuery = '';
                                _searchController.clear();
                              });
                            }
                            _applyFilters();
                          },
                          child: const Text('Reset Filter'),
                        ),
                    ],
                  ),
                ),
                // List
                Expanded(
                  child: _filteredLeaves.isEmpty
                      ? _buildEmptyState()
                      : _buildLeaveList(),
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
          Icon(
            _selectedFilter == 'All'
                ? Icons.check_circle_outline
                : Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'All'
                ? "Tidak ada pengajuan cuti"
                : "Tidak ada pengajuan cuti dengan status ${_formatStatus(_selectedFilter).toLowerCase()}",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveList() {
    return RefreshIndicator(
      onRefresh: _loadLeaves,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredLeaves.length,
        itemBuilder: (context, index) {
          final leave = _filteredLeaves[index];
          final user = leave.user;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header dengan info user dan status
                  Row(
                    children: [
                      Icon(
                        LeaveData.getIcon(leave.type),
                        size: 20,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Unknown User',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${user?.employeeId ?? 'N/A'} - ${user?.position ?? 'Unknown Position'}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(leave.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(leave.status),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _formatStatus(leave.status),
                          style: TextStyle(
                            color: _getStatusColor(leave.status),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Info cuti
                  _buildInfoRow('Jenis Cuti', _formatLeaveType(leave.type)),
                  _buildInfoRow(
                    'Periode',
                    '${_formatDate(leave.startDate)} - ${_formatDate(leave.endDate)}',
                  ),
                  _buildInfoRow('Durasi', '${leave.durationInDays} hari'),
                  _buildInfoRow('Alasan', leave.reason),
                  if (leave.notes != null && leave.notes!.isNotEmpty)
                    _buildInfoRow('Catatan', leave.notes!),
                  if (leave.createdAt != null)
                    _buildInfoRow('Diajukan', _formatDate(leave.createdAt!)),
                  const SizedBox(height: 16),
                  // Actions untuk status PENDING
                  if (leave.status == 'PENDING') ...[
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () =>
                                _showActionDialog(leave, 'REJECTED'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: const Text('Tolak'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                _showActionDialog(leave, 'APPROVED'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text(
                              'Setujui',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
