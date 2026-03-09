abstract class ProfileEvent {}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String? username;
  final String? oldPassword;
  final String? newPassword;
  final String? imagePath;

  UpdateProfileEvent({
    this.username,
    this.oldPassword,
    this.newPassword,
    this.imagePath,
  });
}
