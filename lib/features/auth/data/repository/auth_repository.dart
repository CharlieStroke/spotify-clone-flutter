import 'package:dartz/dartz.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<String, UserEntity>> login(String email, String password);
  Future<Either<String, UserEntity>> register(String username, String email, String password);
}