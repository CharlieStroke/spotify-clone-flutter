import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../../artist/domain/repository/artist_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final ArtistRepository artistRepository;

  ProfileBloc({
    required this.getUserProfileUseCase,
    required this.updateProfileUseCase,
    required this.artistRepository,
  }) : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    // Evitar recarga si ya hay datos, a menos que se fuerce
    if (state is ProfileLoaded && !event.forceRefresh) return;
    if (state is ProfileLoading) return;

    emit(ProfileLoading());

    final failureOrUser = await getUserProfileUseCase();

    await failureOrUser.fold(
      (failureMessage) async => emit(ProfileError(message: failureMessage)),
      (user) async {
        final artistResult = await artistRepository.getMyArtistProfile();
        final artist = artistResult.fold((_) => null, (a) => a);
        emit(ProfileLoaded(user: user, artist: artist));
      },
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
