import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    super.uId,
    super.name,
    super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uId: json['uId'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uId': uId,
      'name': name,
      'email': email,
    };
  }
}