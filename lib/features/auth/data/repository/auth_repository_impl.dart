import 'package:dartz/dartz.dart';
import '../sources/auth_local_services.dart';
import 'auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../sources/auth_api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService authApiService;
  final AuthLocalService authLocalService; // Añadimos el servicio local

  // Actualizamos el constructor
  AuthRepositoryImpl(this.authApiService, this.authLocalService);

  @override
  Future<Either<String, UserEntity>> register(String username, String email, String password) async {
    try {
      final userModel = await authApiService.register(username, email, password);
      if (userModel.token != null) {
        await authLocalService.saveToken(userModel.token!);
      }
      if (userModel.refreshToken != null) {
        await authLocalService.saveRefreshToken(userModel.refreshToken!);
      }
      return Right(userModel);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, UserEntity>> login(String email, String password) async {
    try {
      final userModel = await authApiService.login(email, password);
      if (userModel.token != null) {
        await authLocalService.saveToken(userModel.token!);
      }
      if (userModel.refreshToken != null) {
        await authLocalService.saveRefreshToken(userModel.refreshToken!);
      }
      return Right(userModel);
    } catch (e) {
      return Left(e.toString());
    }
  }
}