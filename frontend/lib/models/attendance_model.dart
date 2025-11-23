import 'package:apk_absensi/models/user_model.dart';

class Attendance {
  final int id;
  final int userId;
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int? lateMinutes;
  final int? overtimeMinutes;
  final String? locationCheckIn;
  final String? locationCheckOut;
  final String? selfieCheckIn;
  final String? selfieCheckOut;
  final String? status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;

  Attendance({
    required this.id,
    required this.userId,
    required this.date,
    this.checkIn,
    this.checkOut,
    this.lateMinutes,
    this.overtimeMinutes,
    this.locationCheckIn,
    this.locationCheckOut,
    this.selfieCheckIn,
    this.selfieCheckOut,
    this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    try {
      // Parse user dengan error handling
      User? user;
      try {
        if (json['user'] != null && json['user'] is Map<String, dynamic>) {
          user = User.fromJson(json['user']);
        }
      } catch (e) {
        print('❌ Error parsing User in Attendance: $e');
        user = null;
      }

      return Attendance(
        id: _parseInt(json['id']) ?? 0,
        userId: _parseInt(json['userId']) ?? 0,
        date: _parseDateTime(json['date']) ?? DateTime.now(),
        checkIn: _parseDateTime(json['checkIn']),
        checkOut: _parseDateTime(json['checkOut']),
        lateMinutes: _parseInt(json['lateMinutes']),
        overtimeMinutes: _parseInt(json['overtimeMinutes']),
        locationCheckIn: json['locationCheckIn']?.toString(),
        locationCheckOut: json['locationCheckOut']?.toString(),
        selfieCheckIn: json['selfieCheckIn']?.toString(),
        selfieCheckOut: json['selfieCheckOut']?.toString(),
        status: json['status']?.toString() ?? 'UNKNOWN',
        notes: json['notes']?.toString(),
        createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
        updatedAt: _parseDateTime(json['updatedAt']) ?? DateTime.now(),
        user: user,
      );
    } catch (e) {
      print('❌ Error parsing Attendance JSON: $e');
      return Attendance(
        id: _parseInt(json['id']) ?? 0,
        userId: _parseInt(json['userId']) ?? 0,
        date: DateTime.now(),
        status: 'UNKNOWN',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      if (value is DateTime) return value.toLocal();
      if (value is String) return DateTime.parse(value).toLocal();
      return null;
    } catch (e) {
      print('❌ Error parsing DateTime: $e, value: $value');
      return null;
    }
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toUtc().toIso8601String(),
      'checkIn': checkIn?.toUtc().toIso8601String(),
      'checkOut': checkOut?.toUtc().toIso8601String(),
      'lateMinutes': lateMinutes,
      'overtimeMinutes': overtimeMinutes,
      'locationCheckIn': locationCheckIn,
      'locationCheckOut': locationCheckOut,
      'selfieCheckIn': selfieCheckIn,
      'selfieCheckOut': selfieCheckOut,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'user': user?.toJson(),
    };
  }

  Map<String, dynamic> toManualAttendanceJson() {
    return {
      'userId': userId,
      'date': _formatDateForApi(date),
      'checkIn': checkIn?.toUtc().toIso8601String(),
      'checkOut': checkOut?.toUtc().toIso8601String(),
      'reason': notes,
    };
  }

  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}