// models/profile_model.dart
class Profile {
  final int id;
  final String employeeId;
  final String name;
  final String email;
  final String division;
  final String role;
  final String position;
  final DateTime joinDate;
  final String? phone;
  final String? address;
  final String? photo;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.email,
    required this.division,
    required this.role,
    required this.position,
    required this.joinDate,
    this.phone,
    this.address,
    this.photo,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    try {
      return Profile(
        id: json['id'] ?? 0,
        employeeId: json['employeeId'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        division: json['division'] ?? '',
        role: json['role'] ?? '',
        position: json['position'] ?? '',
        joinDate: DateTime.parse(json['joinDate'] ?? DateTime.now().toString()),
        phone: json['phone'],
        address: json['address'],
        photo: json['photo'],
        isActive: json['isActive'] ?? false,
        createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
        updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
      );
    } catch (e) {
      print('❌ Error parsing Profile from JSON: $e');
      rethrow;
    }
  }
}