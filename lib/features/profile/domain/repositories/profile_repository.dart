import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';

abstract class ProfileRepository {
  Future<Either<String, UserEntity>> getUserProfile();
}
