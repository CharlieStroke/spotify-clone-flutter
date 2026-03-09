import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';

abstract class ProfileRepository {
  Future<Either<String, UserEntity>> getUserProfile();
  Future<Either<String, UserEntity>> updateProfile({
    String? username,
    String? oldPassword,
    String? newPassword,
    String? imagePath,
  });
}
