// lib/models/onsite_location_model.dart
class OnsiteLocation {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int radius;
  final String division;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  OnsiteLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.division,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OnsiteLocation.fromJson(Map<String, dynamic> json) {
    return OnsiteLocation(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: json['latitude'] is int
          ? (json['latitude'] as int).toDouble()
          : json['latitude'],
      longitude: json['longitude'] is int
          ? (json['longitude'] as int).toDouble()
          : json['longitude'],
      radius: json['radius'],
      division: json['division'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'division': division,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
