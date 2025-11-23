// lib/models/leave_model.dart - UPDATE MODEL YANG SUDAH ADA
import 'package:flutter/material.dart';

class LeaveRequest {
  final int? id;
  final int userId;
  final DateTime startDate;
  final DateTime endDate;
  final String type;
  final String reason;
  final String status;
  final int? approvedBy;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final LeaveUser? user; // Tambahkan properti user sebagai optional

  LeaveRequest({
    this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.reason,
    this.status = 'PENDING',
    this.approvedBy,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.user, // Tambahkan di constructor
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'],
      userId: json['userId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      type: json['type'],
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
      user: json['user'] != null ? LeaveUser.fromJson(json['user']) : null, // Parse user jika ada
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String().split('T')[0],
      'endDate': endDate.toIso8601String().split('T')[0],
      'type': type,
      'reason': reason,
    };
  }

  // Get duration in days
  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }

  // Check if leave is in the past
  bool get isPast {
    return endDate.isBefore(DateTime.now());
  }

  // Check if leave is current
  bool get isCurrent {
    final now = DateTime.now();
    return (startDate.isBefore(now) || startDate.isAtSameMomentAs(now)) &&
        (endDate.isAfter(now) || endDate.isAtSameMomentAs(now));
  }

  // Check if leave is upcoming
  bool get isUpcoming {
    return startDate.isAfter(DateTime.now());
  }
}

class LeaveUser {
  final int id;
  final String name;
  final String employeeId;
  final String division;
  final String position;

  LeaveUser({
    required this.id,
    required this.name,
    required this.employeeId,
    required this.division,
    required this.position,
  });

  factory LeaveUser.fromJson(Map<String, dynamic> json) {
    return LeaveUser(
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

class LeaveType {
  final String value;
  final String label;

  const LeaveType(this.value, this.label);
}

class LeaveData {
  static final List<LeaveType> types = [
    LeaveType('CUTI_TAHUNAN', 'Cuti Tahunan'),
    LeaveType('CUTI_SAKIT', 'Cuti Sakit'),
    LeaveType('CUTI_MELAHIRKAN', 'Cuti Melahirkan'),
    LeaveType('CUTI_PENTING', 'Cuti Kepentingan Penting'),
    LeaveType('CUTI_BESAR', 'Cuti Besar'),
    LeaveType('CUTI_ALASAN_PENTING', 'Cuti Alasan Penting'),
  ];

  static String getLabel(String value) {
    return types
        .firstWhere(
          (type) => type.value == value,
          orElse: () => LeaveType(value, value),
        )
        .label;
  }

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

  // Helper untuk icon jenis cuti
  static IconData getIcon(String type) {
  switch (type) {
    case 'CUTI_TAHUNAN':
      return Icons.beach_access;
    case 'CUTI_SAKIT':
      return Icons.medical_services;
    case 'CUTI_MELAHIRKAN':
      return Icons.child_care;
    case 'CUTI_ALASAN_PENTING':
      return Icons.warning;
    case 'CUTI_BESAR':
      return Icons.work;
    case 'CUTI_DILUAR_TANGGUNGAN':
      return Icons.beach_access;
    default:
      return Icons.event;
  }
}
}