import '../../domain/entities/user_entity.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserEntity user;

  ProfileLoaded({required this.user});
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError({required this.message});
}

class ProfileUpdateSuccess extends ProfileState {
  final UserEntity user;
  
  ProfileUpdateSuccess({required this.user});
}

class ProfileUpdateError extends ProfileState {
  final String message;
  
  ProfileUpdateError({required this.message});
}
