import 'package:dartz/dartz.dart';
import '../repository/auth_repository.dart';
import '../entities/user_entity.dart';

class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<Either<String, UserEntity>> call(String email, String password) {
    return repository.login(email, password);
  }
}