import 'package:dartz/dartz.dart';
import '../sources/auth_local_services.dart'; // Importa el servicio local
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
      // 1. Llamamos a la API
      final user = await authApiService.register(username, email, password);
      
      // Nota: Si tu backend devuelve el token al registrar, 
      // podrías guardarlo aquí igual que en el login.
      
      return Right(user);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, UserEntity>> login(String email, String password) async {
    try {
      // 1. Intentamos el login en la API
      // Nota: Asegúrate de que tu authApiService.login devuelva un objeto 
      // que contenga el TOKEN (puedes modificar tu UserModel para incluirlo)
      final userModel = await authApiService.login(email, password);
      
      // 2. Si el login es exitoso y tenemos un token, lo guardamos localmente
      // Asumiendo que agregaste el campo 'token' a tu UserModel
      if (userModel.token != null) {
        await authLocalService.saveToken(userModel.token!);
      }
      
      return Right(userModel);
    } catch (e) {
      return Left(e.toString());
    }
  }
}