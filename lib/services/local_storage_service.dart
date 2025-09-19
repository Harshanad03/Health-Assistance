import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String userKey = 'user_info';

  Future<void> saveUserInfo(String userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, userInfo);
    print('LocalStorageService: Saved user info: $userInfo');
  }

  Future<String?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(userKey);
    print('LocalStorageService: Retrieved user info: $value');
    return value;
  }

  Future<void> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userKey);
    print('LocalStorageService: Cleared user info');
  }
}
