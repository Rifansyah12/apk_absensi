// lib/models/user_model.dart
class User {
  final int id;
  final String employeeId;
  final String name;
  final String email;
  final String division;
  final String role;
  final String position;
  final String? photo; // ✅ Pastikan ini nullable
  final bool isActive;
  final DateTime joinDate;
  final String? phone;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.email,
    required this.division,
    required this.role,
    required this.position,
    this.photo, // ✅ Nullable
    required this.isActive,
    required this.joinDate,
    this.phone,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        id: json['id'] as int? ?? 0,
        employeeId: json['employeeId']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        division: json['division']?.toString() ?? '',
        role: json['role']?.toString() ?? 'USER',
        position: json['position']?.toString() ?? '',
        photo: json['photo']?.toString(), // ✅ Handle null
        isActive: json['isActive'] as bool? ?? true,
        joinDate: json['joinDate'] != null
            ? DateTime.parse(json['joinDate'].toString()).toLocal()
            : DateTime.now(),
        phone: json['phone']?.toString(),
        address: json['address']?.toString(),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString()).toLocal()
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'].toString()).toLocal()
            : DateTime.now(),
      );
    } catch (e) {
      print('❌ Error parsing User JSON: $e');
      print('❌ Problematic User JSON: $json');
      // Return default user to prevent crash
      return User(
        id: 0,
        employeeId: 'UNKNOWN',
        name: 'Unknown User',
        email: 'unknown@example.com',
        division: 'UNKNOWN',
        role: 'USER',
        position: 'Unknown',
        isActive: false,
        joinDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'name': name,
      'email': email,
      'division': division,
      'role': role,
      'position': position,
      'photo': photo,
      'isActive': isActive,
      'joinDate': joinDate.toIso8601String(),
      'phone': phone,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
