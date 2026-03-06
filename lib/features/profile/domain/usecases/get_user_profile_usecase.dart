import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class GetUserProfileUseCase {
  final ProfileRepository repository;

  GetUserProfileUseCase({required this.repository});

  Future<Either<String, UserEntity>> call() async {
    return await repository.getUserProfile();
  }
}
