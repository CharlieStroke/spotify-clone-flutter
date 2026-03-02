abstract class AuthEvent {}

class AuthSignupEvent extends AuthEvent {
  final String username;
  final String email;
  final String password;
  AuthSignupEvent({required this.username, required this.email, required this.password});
}

class AuthSigninEvent extends AuthEvent {
  final String email;
  final String password;
  AuthSigninEvent({required this.email, required this.password});
}