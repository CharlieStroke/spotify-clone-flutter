import '../../domain/entities/user_entity.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final UserEntity user;
  AuthSuccess({required this.user});
}
class AuthFailure extends AuthState {
  final String message;
  AuthFailure({required this.message});
}