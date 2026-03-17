abstract class ProfileEvent {
  final bool forceRefresh;
  ProfileEvent({this.forceRefresh = false});
}

class LoadProfileEvent extends ProfileEvent {
  LoadProfileEvent({super.forceRefresh = false});
}

class UpdateProfileEvent extends ProfileEvent {
  final String? username;
  final String? oldPassword;
  final String? newPassword;
  final String? imagePath;

  UpdateProfileEvent({
    super.forceRefresh = false,
    this.username,
    this.oldPassword,
    this.newPassword,
    this.imagePath,
  });
}
