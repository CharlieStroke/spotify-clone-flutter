import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileBloc({
    required this.getUserProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final failureOrUser = await getUserProfileUseCase();

    failureOrUser.fold(
      (failureMessage) => emit(ProfileError(message: failureMessage)),
      (user) => emit(ProfileLoaded(user: user)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    final failureOrUser = await updateProfileUseCase(
      username: event.username,
      oldPassword: event.oldPassword,
      newPassword: event.newPassword,
      imagePath: event.imagePath,
    );

    failureOrUser.fold(
      (failureMessage) => emit(ProfileUpdateError(message: failureMessage)),
      (user) => emit(ProfileUpdateSuccess(user: user)),
    );
  }
}
