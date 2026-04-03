import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/app_constants.dart';

abstract class AuthLocalService {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> clearCache();
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
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: AppConstants.refreshTokenKey);
  }

  @override
  Future<void> clearCache() async {
    await Hive.box(AppConstants.boxHomeCache).clear();
    await Hive.box(AppConstants.boxLibraryCache).clear();
    await Hive.box(AppConstants.boxFavorites).clear();
    await Hive.box(AppConstants.boxSearchCache).clear();
  }

  @override
  Future<void> clear() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
    await clearCache();
  }
}
