import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<String, UserEntity>> call({
    String? username,
    String? oldPassword,
    String? newPassword,
    String? imagePath,
  }) {
    return repository.updateProfile(
      username: username,
      oldPassword: oldPassword,
      newPassword: newPassword,
      imagePath: imagePath,
    );
  }
}
