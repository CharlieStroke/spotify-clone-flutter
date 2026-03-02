import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    super.uid,
    super.username,
    super.email,
    super.token, // <-- Pasar al padre
  });

  // Aquí está el truco: tu JSON de Node.js trae el token al mismo nivel que el mensaje
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['user'] != null ? json['user']['_id'] : null,
      username: json['user'] != null ? json['user']['username'] : null,
      email: json['user'] != null ? json['user']['email'] : json['email'],
      token: json['token'], // <-- Capturamos el token del JSON principal
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'token': token,
    };
  }
}