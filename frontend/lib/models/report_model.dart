// lib/models/report_model.dart
import 'package:flutter/material.dart';

class AttendanceReport {
  final String nama;
  final String jabatan;
  final String tanggal;
  final String jamMasuk;
  final String jamPulang;
  final int terlambat;
  final double lembur;
  final double potongan;
  final double totalGaji;
  final String lokasi;
  final String employeeId;
  final String division;

  AttendanceReport({
    required this.nama,
    required this.jabatan,
    required this.tanggal,
    required this.jamMasuk,
    required this.jamPulang,
    required this.terlambat,
    required this.lembur,
    required this.potongan,
    required this.totalGaji,
    required this.lokasi,
    required this.employeeId,
    required this.division,
  });

  factory AttendanceReport.fromJson(Map<String, dynamic> json) {
    return AttendanceReport(
      nama: json['nama'] ?? '',
      jabatan: json['jabatan'] ?? '',
      tanggal: json['tanggal'] ?? '',
      jamMasuk: json['jamMasuk'] ?? '-',
      jamPulang: json['jamPulang'] ?? '-',
      terlambat: (json['terlambat'] is int)
          ? json['terlambat']
          : (json['terlambat'] as num).toInt(),
      lembur: (json['lembur'] is double)
          ? json['lembur']
          : (json['lembur'] as num).toDouble(),
      potongan: (json['potongan'] is double)
          ? json['potongan']
          : (json['potongan'] as num).toDouble(),
      totalGaji: (json['totalGaji'] is double)
          ? json['totalGaji']
          : (json['totalGaji'] as num).toDouble(),
      lokasi: json['lokasi'] ?? '-',
      employeeId: json['employeeId'] ?? '',
      division: json['division'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'jabatan': jabatan,
      'tanggal': tanggal,
      'jamMasuk': jamMasuk,
      'jamPulang': jamPulang,
      'terlambat': terlambat,
      'lembur': lembur,
      'potongan': potongan,
      'totalGaji': totalGaji,
      'lokasi': lokasi,
      'employeeId': employeeId,
      'division': division,
    };
  }
}

class SalaryReport {
  final String nama;
  final String jabatan;
  final String divisi;
  final double gajiPokok;
  final double lembur;
  final double potongan;
  final double totalGaji;
  final int bulan;
  final int tahun;
  final String employeeId;

  SalaryReport({
    required this.nama,
    required this.jabatan,
    required this.divisi,
    required this.gajiPokok,
    required this.lembur,
    required this.potongan,
    required this.totalGaji,
    required this.bulan,
    required this.tahun,
    required this.employeeId,
  });

  factory SalaryReport.fromJson(Map<String, dynamic> json) {
    return SalaryReport(
      nama: json['nama'] ?? '',
      jabatan: json['jabatan'] ?? '',
      divisi: json['divisi'] ?? '',
      gajiPokok: (json['gajiPokok'] is double)
          ? json['gajiPokok']
          : (json['gajiPokok'] as num).toDouble(),
      lembur: (json['lembur'] is double)
          ? json['lembur']
          : (json['lembur'] as num).toDouble(),
      potongan: (json['potongan'] is double)
          ? json['potongan']
          : (json['potongan'] as num).toDouble(),
      totalGaji: (json['totalGaji'] is double)
          ? json['totalGaji']
          : (json['totalGaji'] as num).toDouble(),
      bulan: (json['bulan'] is int)
          ? json['bulan']
          : (json['bulan'] as num).toInt(),
      tahun: (json['tahun'] is int)
          ? json['tahun']
          : (json['tahun'] as num).toInt(),
      employeeId: json['employeeId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'jabatan': jabatan,
      'divisi': divisi,
      'gajiPokok': gajiPokok,
      'lembur': lembur,
      'potongan': potongan,
      'totalGaji': totalGaji,
      'bulan': bulan,
      'tahun': tahun,
      'employeeId': employeeId,
    };
  }
}

class ReportFilter {
  final String type; // daily, weekly, monthly
  final DateTime? startDate;
  final DateTime? endDate;
  final String? employeeId;
  final String? division;
  final String? jabatan;
  final int? month;
  final int? year;

  ReportFilter({
    required this.type,
    this.startDate,
    this.endDate,
    this.employeeId,
    this.division,
    this.jabatan,
    this.month,
    this.year,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    params['type'] = type;

    if (startDate != null) {
      params['startDate'] = _formatDate(startDate!);
    }
    if (endDate != null) {
      params['endDate'] = _formatDate(endDate!);
    }
    if (employeeId != null && employeeId!.isNotEmpty) {
      params['employeeId'] = employeeId;
    }
    if (division != null && division!.isNotEmpty) {
      params['division'] = division;
    }
    if (month != null) {
      params['month'] = month.toString();
    }
    if (year != null) {
      params['year'] = year.toString();
    }

    return params;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class ReportSummary {
  final int totalRecords;
  final double totalLembur;
  final double totalPotongan;
  final double totalGaji;
  final double rataRataTerlambat;

  ReportSummary({
    required this.totalRecords,
    required this.totalLembur,
    required this.totalPotongan,
    required this.totalGaji,
    required this.rataRataTerlambat,
  });
}

class ReportData {
  static List<String> get reportTypes => ['Harian', 'Mingguan', 'Bulanan'];
  static List<String> get divisions => [
    'FINANCE',
    'HR',
    'IT',
    'OPERATIONAL',
    'MARKETING',
  ];
  static List<String> get positions => [
    'Manager',
    'Supervisor',
    'Staff',
    'Analyst',
  ];

  static String getDivisionLabel(String division) {
    switch (division) {
      case 'FINANCE':
        return 'Keuangan';
      case 'HR':
        return 'HR';
      case 'IT':
        return 'IT';
      case 'OPERATIONAL':
        return 'Operasional';
      case 'MARKETING':
        return 'Pemasaran';
      default:
        return division;
    }
  }

  static String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  static String formatMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes menit';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '$hours jam ${remainingMinutes} menit';
    }
  }
}