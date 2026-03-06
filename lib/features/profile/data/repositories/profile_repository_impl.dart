import 'package:dartz/dartz.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../sources/profile_api_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileApiService profileApiService;

  ProfileRepositoryImpl({required this.profileApiService});

  @override
  Future<Either<String, UserEntity>> getUserProfile() async {
    try {
      final user = await profileApiService.getUserProfile();
      return Right(user);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
