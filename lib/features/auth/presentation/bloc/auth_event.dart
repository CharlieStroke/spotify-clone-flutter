abstract class AuthEvent {}

class AuthSignupEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  AuthSignupEvent({required this.email, required this.password, required this.name});
}

class AuthSigninEvent extends AuthEvent {
  final String email;
  final String password;
  AuthSigninEvent({required this.email, required this.password});
}