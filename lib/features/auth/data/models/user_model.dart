import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  final String? refreshToken;

  UserModel({
    super.uid,
    super.username,
    super.email,
    super.token,
    this.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['user'] != null ? json['user']['_id'] : null,
      username: json['user'] != null ? json['user']['username'] : null,
      email: json['user'] != null ? json['user']['email'] : json['email'],
      token: json['token'],
      refreshToken: json['refreshToken'],
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