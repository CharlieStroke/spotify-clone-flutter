import '../../domain/entities/user_entity.dart';
import '../../../artist/domain/entities/artist_entity.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserEntity user;
  final ArtistEntity? artist;

  ProfileLoaded({required this.user, this.artist});
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
