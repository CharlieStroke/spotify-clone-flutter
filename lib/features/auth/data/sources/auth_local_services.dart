import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';

abstract class AuthLocalService {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clear();
}

class AuthLocalServiceImpl implements AuthLocalService {
  final FlutterSecureStorage _secureStorage;

  AuthLocalServiceImpl(this._secureStorage);

  @override
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConstants.tokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return _secureStorage.read(key: AppConstants.tokenKey);
  }

  @override
  Future<void> clear() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
  }
}
