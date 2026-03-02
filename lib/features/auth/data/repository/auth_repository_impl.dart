import 'package:dartz/dartz.dart';
import 'auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '/features/auth/data/sources/auth_api_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService authApiService;

  AuthRepositoryImpl(this.authApiService);

  @override
  Future<Either<String, UserEntity>> register(String username, String email, String password) async {
    try {
      final user = await authApiService.register(username, email, password);
      return Right(user); // Éxito
    } catch (e) {
      return Left(e.toString()); // Error
    }
  }

  @override
  Future<Either<String, UserEntity>> login(String email, String password) async {
    try {
      final user = await authApiService.login(email, password);
      return Right(user);
    } catch (e) {
      return Left(e.toString());
    }
  }
}