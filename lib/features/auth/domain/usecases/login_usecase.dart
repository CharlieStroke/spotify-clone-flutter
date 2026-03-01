import 'package:dartz/dartz.dart';
import '../../data/repository/auth_repository.dart';
import '../entities/user_entity.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<String, UserEntity>> call(String email, String password) {
    return repository.login(email, password);
  }
}