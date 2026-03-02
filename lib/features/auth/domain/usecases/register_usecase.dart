import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../../data/repository/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<String, UserEntity>> call(String username, String email, String password) {
    return repository.register(username, email, password);
  }
}