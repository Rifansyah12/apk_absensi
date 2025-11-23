import 'package:flutter/material.dart';
import 'package:apk_absensi/services/help_service.dart';

class AdminHelpPage extends StatefulWidget {
  const AdminHelpPage({super.key});

  @override
  State<AdminHelpPage> createState() => _AdminHelpPageState();
}

class _AdminHelpPageState extends State<AdminHelpPage> {
  final HelpService _helpService = HelpService();
  List<HelpContent> _helpContents = [];
  bool _isLoading = true;
  String? _error;
  String _filterType = 'ALL';
  String _filterDivision = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadHelpContents();
  }

  Future<void> _loadHelpContents() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final contents = await _helpService.getAllHelpContent();
      setState(() {
        _helpContents = contents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      _showErrorSnackBar('Gagal memuat data: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAddEditDialog({HelpContent? content}) {
    showDialog(
      context: context,
      builder: (context) => HelpContentDialog(
        content: content,
        onSaved: _loadHelpContents,
      ),
    );
  }

  Future<void> _toggleContentStatus(HelpContent content) async {
    try {
      await _helpService.toggleHelpContentStatus(content.id);
      _loadHelpContents();
      _showSuccessSnackBar('Status berhasil diubah');
    } catch (e) {
      _showErrorSnackBar('Gagal mengubah status: $e');
    }
  }

  Future<void> _deleteContent(HelpContent content) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Konten'),
        content: Text('Apakah Anda yakin ingin menghapus "${content.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _helpService.deleteHelpContent(content.id);
        _loadHelpContents();
        _showSuccessSnackBar('Konten berhasil dihapus');
      } catch (e) {
        _showErrorSnackBar('Gagal menghapus: $e');
      }
    }
  }

  List<HelpContent> get _filteredContents {
    var filtered = _helpContents;

    // Filter by type
    if (_filterType != 'ALL') {
      filtered = filtered.where((content) => content.type == _filterType).toList();
    }

    // Filter by division
    if (_filterDivision != 'ALL') {
      if (_filterDivision == 'GLOBAL') {
        filtered = filtered.where((content) => content.division == null).toList();
      } else {
        filtered = filtered.where((content) => content.division == _filterDivision).toList();
      }
    }

    return filtered;
  }

  Widget _buildFilterSection() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tipe Konten',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: _filterType,
                        items: [
                          'ALL',
                          'FAQ',
                          'CONTACT',
                          'APP_INFO',
                          'GENERAL',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _filterType = value!;
                          });
                        },
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Divisi',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: _filterDivision,
                        items: [
                          'ALL',
                          'GLOBAL',
                          'FINANCE',
                          'APO',
                          'FRONT_DESK',
                          'ONSITE',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _filterDivision = value!;
                          });
                        },
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard(HelpContent content) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getTypeColor(content.type),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getTypeIcon(content.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          content.title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            decoration: content.isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    content.type,
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: content.division == null ? Colors.blue[100] : Colors.green[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    content.division ?? 'GLOBAL',
                    style: TextStyle(
                      fontSize: 10,
                      color: content.division == null ? Colors.blue[800] : Colors.green[800],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Urutan: ${content.order}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            if (content.content.length > 100)
              Text(
                '${content.content.substring(0, 100)}...',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              )
            else
              Text(
                content.content,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                content.isActive ? Icons.toggle_on : Icons.toggle_off,
                color: content.isActive ? Colors.green : Colors.grey,
                size: 30,
              ),
              onPressed: () => _toggleContentStatus(content),
              tooltip: content.isActive ? 'Nonaktifkan' : 'Aktifkan',
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showAddEditDialog(content: content),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteContent(content),
              tooltip: 'Hapus',
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'FAQ':
        return Colors.orange;
      case 'CONTACT':
        return Colors.green;
      case 'APP_INFO':
        return Colors.blue;
      case 'GENERAL':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'FAQ':
        return Icons.help;
      case 'CONTACT':
        return Icons.contact_phone;
      case 'APP_INFO':
        return Icons.info;
      case 'GENERAL':
        return Icons.description;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Memuat data konten bantuan...'),
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
            _error ?? 'Terjadi kesalahan',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadHelpContents,
            child: const Text('Coba Lagi'),
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
          Icon(Icons.help_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Belum ada konten bantuan',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan konten bantuan untuk membantu pengguna',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
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
          'Kelola Konten Bantuan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.greenAccent[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHelpContents,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(),
            tooltip: 'Tambah Konten',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: Colors.greenAccent[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
              ? _buildErrorState()
              : Column(
                  children: [
                    _buildFilterSection(),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'Total: ${_filteredContents.length} konten',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Aktif: ${_filteredContents.where((c) => c.isActive).length}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _filteredContents.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadHelpContents,
                              child: ListView.builder(
                                itemCount: _filteredContents.length,
                                itemBuilder: (context, index) {
                                  return _buildContentCard(_filteredContents[index]);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }
}

class HelpContentDialog extends StatefulWidget {
  final HelpContent? content;
  final VoidCallback onSaved;

  const HelpContentDialog({
    super.key,
    this.content,
    required this.onSaved,
  });

  @override
  State<HelpContentDialog> createState() => _HelpContentDialogState();
}

class _HelpContentDialogState extends State<HelpContentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _orderController = TextEditingController();

  String? _selectedType;
  String? _selectedDivision;
  bool _isSubmitting = false;

  final List<String> _typeOptions = ['FAQ', 'CONTACT', 'APP_INFO', 'GENERAL'];
  final List<String> _divisionOptions = ['GLOBAL', 'FINANCE', 'APO', 'FRONT_DESK', 'ONSITE'];

  @override
  void initState() {
    super.initState();
    if (widget.content != null) {
      _titleController.text = widget.content!.title;
      _contentController.text = widget.content!.content;
      _orderController.text = widget.content!.order.toString();
      _selectedType = widget.content!.type;
      _selectedDivision = widget.content!.division ?? 'GLOBAL';
    } else {
      _selectedType = 'FAQ';
      _selectedDivision = 'GLOBAL';
      _orderController.text = '0';
    }
  }

  Future<void> _saveContent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final helpService = HelpService();
      
      if (widget.content == null) {
        // Create new
        await helpService.createHelpContent(
          division: _selectedDivision == 'GLOBAL' ? null : _selectedDivision,
          title: _titleController.text,
          content: _contentController.text,
          type: _selectedType!,
          order: int.tryParse(_orderController.text) ?? 0,
        );
      } else {
        // Update
        await helpService.updateHelpContent(
          id: widget.content!.id,
          division: _selectedDivision == 'GLOBAL' ? null : _selectedDivision,
          title: _titleController.text,
          content: _contentController.text,
          type: _selectedType!,
          order: int.tryParse(_orderController.text) ?? widget.content!.order,
        );
      }

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
      widget.onSaved();
      
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.content == null ? 'Konten berhasil ditambahkan' : 'Konten berhasil diupdate'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.content == null ? 'Tambah Konten Bantuan' : 'Edit Konten Bantuan'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Konten',
                  border: OutlineInputBorder(),
                  hintText: 'Untuk CONTACT dan APP_INFO, gunakan format JSON',
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konten wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipe Konten',
                  border: OutlineInputBorder(),
                ),
                items: _typeOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Tipe konten wajib dipilih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDivision,
                decoration: const InputDecoration(
                  labelText: 'Divisi',
                  border: OutlineInputBorder(),
                ),
                items: _divisionOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDivision = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Divisi wajib dipilih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _orderController,
                decoration: const InputDecoration(
                  labelText: 'Urutan',
                  border: OutlineInputBorder(),
                  hintText: '0',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Urutan wajib diisi';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Urutan harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'Catatan: Untuk tipe CONTACT dan APP_INFO, konten harus dalam format JSON',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _saveContent,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.content == null ? 'Tambah' : 'Update'),
        ),
      ],
    );
  }
}