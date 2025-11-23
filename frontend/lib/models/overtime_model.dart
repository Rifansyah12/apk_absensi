// lib/models/overtime_model.dart
import 'package:flutter/material.dart';

class OvertimeRequest {
  final int? id;
  final int userId;
  final DateTime date;
  final double hours;
  final String reason;
  final String status;
  final int? approvedBy;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final OvertimeUser? user; // Tambahkan properti user

  OvertimeRequest({
    this.id,
    required this.userId,
    required this.date,
    required this.hours,
    required this.reason,
    this.status = 'PENDING',
    this.approvedBy,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.user, // Tambahkan di constructor
  });

  factory OvertimeRequest.fromJson(Map<String, dynamic> json) {
    return OvertimeRequest(
      id: json['id'],
      userId: json['userId'],
      date: DateTime.parse(json['date']),
      hours: (json['hours'] is int)
          ? (json['hours'] as int).toDouble()
          : json['hours'],
      reason: json['reason'],
      status: json['status'],
      approvedBy: json['approvedBy'],
      notes: json['notes'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      user: json['user'] != null
          ? OvertimeUser.fromJson(json['user'])
          : null, // Parse user
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'hours': hours,
      'reason': reason,
    };
  }

  // Format hours to readable string
  String get formattedHours {
    if (hours == hours.truncate()) {
      return '${hours.toInt()} jam';
    } else {
      return '$hours jam';
    }
  }

  // Check if overtime is in the past
  bool get isPast {
    return date.isBefore(DateTime.now());
  }

  // Check if overtime is today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if overtime is in the future
  bool get isFuture {
    return date.isAfter(DateTime.now());
  }
}

class OvertimeUser {
  final int id;
  final String name;
  final String employeeId;
  final String division;
  final String position;

  OvertimeUser({
    required this.id,
    required this.name,
    required this.employeeId,
    required this.division,
    required this.position,
  });

  factory OvertimeUser.fromJson(Map<String, dynamic> json) {
    return OvertimeUser(
      id: json['id'],
      name: json['name'],
      employeeId: json['employeeId'],
      division: json['division'],
      position: json['position'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'employeeId': employeeId,
      'division': division,
      'position': position,
    };
  }
}

class OvertimeData {
  static Color getStatusColor(String status) {
    switch (status) {
      case 'APPROVED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String getStatusLabel(String status) {
    switch (status) {
      case 'APPROVED':
        return 'Disetujui';
      case 'PENDING':
        return 'Menunggu';
      case 'REJECTED':
        return 'Ditolak';
      default:
        return status;
    }
  }

  // Predefined reasons for overtime
  static final List<String> commonReasons = [
    'Menyelesaikan laporan',
    'Meeting dengan klien',
    'Proyek mendesak',
    'Target deadline',
    'Support tim lain',
    'Training/kursus',
    'Lainnya',
  ];

  // Helper untuk icon
  static IconData getIcon() {
    return Icons.access_time;
  }
}
