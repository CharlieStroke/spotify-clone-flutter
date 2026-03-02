class UserEntity {
  final String? uid;
  final String? username;
  final String? email;
  final String? token; // <-- Agregamos esto

  UserEntity({
    this.uid,
    this.username,
    this.email,
    this.token, // <-- Y esto
  });
}