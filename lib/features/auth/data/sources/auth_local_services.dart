import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalService {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clear();
}

class AuthLocalServiceImpl implements AuthLocalService {
  final SharedPreferences _sharedPreferences;

  AuthLocalServiceImpl(this._sharedPreferences);

  @override
  Future<void> saveToken(String token) async {
    await _sharedPreferences.setString('token', token);
  }

  @override
  Future<String?> getToken() async {
    return _sharedPreferences.getString('token');
  }

  @override
  Future<void> clear() async {
    await _sharedPreferences.remove('token');
  }
}