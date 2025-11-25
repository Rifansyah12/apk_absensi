// lib/screens/admin/division/onsite_locations_tab.dart
import 'package:flutter/material.dart';
import 'package:apk_absensi/models/onsite_location_model.dart';
import 'package:apk_absensi/services/onsite_location_service.dart';
import 'package:apk_absensi/widgets/loading_widget.dart';

class OnsiteLocationsTab extends StatefulWidget {
  final String division;

  const OnsiteLocationsTab({Key? key, required this.division})
    : super(key: key);

  @override
  State<OnsiteLocationsTab> createState() => _OnsiteLocationsTabState();
}

class _OnsiteLocationsTabState extends State<OnsiteLocationsTab> {
  List<OnsiteLocation> _locations = [];
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final locations = await OnsiteLocationService.getLocationsDivision(
        widget.division,
      );

      if (!mounted) return;

      setState(() {
        _locations = locations;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddLocationDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => LocationFormDialog(division: widget.division),
    );

    if (result != null) {
      await _createLocation(result);
    }
  }

  Future<void> _showEditLocationDialog(OnsiteLocation location) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) =>
          LocationFormDialog(division: widget.division, location: location),
    );

    if (result != null) {
      await _updateLocation(location.id, result);
    }
  }

  Future<void> _createLocation(Map<String, dynamic> data) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await OnsiteLocationService.createLocation(data);
      await _loadLocations();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan lokasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateLocation(int id, Map<String, dynamic> data) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await OnsiteLocationService.updateLocation(id, data);
      await _loadLocations();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui lokasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleLocationStatus(int id, bool currentStatus) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await OnsiteLocationService.toggleLocationStatus(id);
      await _loadLocations();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lokasi berhasil ${!currentStatus ? 'diaktifkan' : 'dinonaktifkan'}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status lokasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteLocation(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus lokasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() {
          _isLoading = true;
        });

        await OnsiteLocationService.deleteLocation(id);
        await _loadLocations();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lokasi berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus lokasi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildLocationCard(OnsiteLocation location) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(
          location.isActive ? Icons.location_on : Icons.location_off,
          color: location.isActive ? Colors.green : Colors.grey,
          size: 32,
        ),
        title: Text(
          location.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: location.isActive ? Colors.black87 : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(location.address),
            const SizedBox(height: 4),
            Text(
              'Koordinat: ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
            ),
            Text('Radius: ${location.radius} meter'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditLocationDialog(location),
            ),
            IconButton(
              icon: Icon(
                location.isActive ? Icons.toggle_on : Icons.toggle_off,
                color: location.isActive ? Colors.green : Colors.grey,
              ),
              onPressed: () =>
                  _toggleLocationStatus(location.id, location.isActive),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteLocation(location.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada lokasi untuk divisi ${widget.division}',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddLocationDialog,
            icon: const Icon(Icons.add_location),
            label: const Text('Tambah Lokasi Pertama'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingWidget();

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: $_error',
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLocations,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Lokasi Onsite - ${widget.division}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddLocationDialog,
                icon: const Icon(Icons.add_location),
                label: const Text('Tambah Lokasi'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _locations.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadLocations,
                  child: ListView.builder(
                    itemCount: _locations.length,
                    itemBuilder: (context, index) =>
                        _buildLocationCard(_locations[index]),
                  ),
                ),
        ),
      ],
    );
  }
}

class LocationFormDialog extends StatefulWidget {
  final String division;
  final OnsiteLocation? location;

  const LocationFormDialog({Key? key, required this.division, this.location})
    : super(key: key);

  @override
  State<LocationFormDialog> createState() => _LocationFormDialogState();
}

class _LocationFormDialogState extends State<LocationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _radiusController = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.location != null) {
      _nameController.text = widget.location!.name;
      _addressController.text = widget.location!.address;
      _latitudeController.text = widget.location!.latitude.toString();
      _longitudeController.text = widget.location!.longitude.toString();
      _radiusController.text = widget.location!.radius.toString();
      _isActive = widget.location!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.location == null ? 'Tambah Lokasi' : 'Edit Lokasi'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lokasi',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama lokasi harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Latitude harus diisi';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Latitude harus angka';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Longitude harus diisi';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Longitude harus angka';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _radiusController,
                decoration: const InputDecoration(
                  labelText: 'Radius (meter)',
                  border: OutlineInputBorder(),
                  suffixText: 'meter',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Radius harus diisi';
                  }
                  final radius = int.tryParse(value);
                  if (radius == null) {
                    return 'Radius harus angka';
                  }
                  if (radius < 50 || radius > 5000) {
                    return 'Radius harus antara 50-5000 meter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (widget.location != null)
                SwitchListTile(
                  title: const Text('Aktif'),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'name': _nameController.text,
                'address': _addressController.text,
                'latitude': double.parse(_latitudeController.text),
                'longitude': double.parse(_longitudeController.text),
                'radius': int.parse(_radiusController.text),
                'division': widget.division,
                'isActive': _isActive,
              });
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
