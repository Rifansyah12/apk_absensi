// lib/utils/storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static const String _tokenKey = 'token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _employeeIdKey = 'employee_id';
  static const String _positionKey = 'position';
  static const String _divisionKey = 'division';
  static const String _roleKey = 'role';
  static const String _photoKey = 'photo';

  // lib/utils/storage.dart
  static Future<String?> getPhoto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final photo = prefs.getString('photo');

      // ✅ DEBUG: Log photo path
      print('📸 Storage getPhoto(): $photo');

      return photo;
    } catch (e) {
      print('❌ Error getting photo from storage: $e');
      return null;
    }
  }

  // ✅ GETTERS
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print(
      '🔐 Token dari storage: ${token != null ? '${token.substring(0, 20)}...' : 'NULL'}',
    );
    return token;
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  static Future<String?> getDivision() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_divisionKey);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  // ✅ SETTERS
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    print('💾 Token disimpan: ${token.substring(0, 20)}...');
  }

  static Future<void> setUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_userIdKey, userData['id'] ?? 0);
    await prefs.setString(_userNameKey, userData['name'] ?? '');
    await prefs.setString(_userEmailKey, userData['email'] ?? '');
    await prefs.setString(_employeeIdKey, userData['employeeId'] ?? '');
    await prefs.setString(_positionKey, userData['position'] ?? '');
    await prefs.setString(_divisionKey, userData['division'] ?? '');
    await prefs.setString(_roleKey, userData['role'] ?? '');
    if (userData['photo'] != null && userData['photo'] != '') {
      await prefs.setString(_photoKey, userData['photo']);
    }

    print(
      '👤 User data disimpan: ${userData['name']} - ${userData['division']}',
    );
  }

  // ✅ CLEAR
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_employeeIdKey);
    await prefs.remove(_positionKey);
    await prefs.remove(_divisionKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_photoKey);

    print('🗑️ Semua data storage dihapus');
  }

  // ✅ DEBUG: Print semua data
  static Future<void> debugPrintAll() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();

    print('🔍 DEBUG Storage Data:');
    for (String key in allKeys) {
      final value = prefs.get(key);
      print('   $key: $value');
    }
  }
}
