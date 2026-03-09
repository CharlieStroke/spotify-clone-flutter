import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';
import 'features/auth/data/sources/auth_api_service.dart';
import 'features/auth/data/repository/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/data/sources/auth_local_services.dart';
import 'features/home/data/sources/song_api_services.dart';
import 'features/home/data/sources/home_api_service.dart';
import 'features/home/data/repository/song_repository.dart';
import 'features/home/data/repository/song_repository_impl.dart';
import 'features/home/data/repository/home_repository.dart';
import 'features/home/data/repository/home_repository_impl.dart';
import 'features/home/domain/usecases/get_songs_usecase.dart';
import 'features/home/domain/usecases/get_albums_usecase.dart';
import 'features/home/domain/usecases/get_playlists_usecase.dart';
import 'features/home/presentation/bloc/home_bloc.dart';
import 'features/main_navigation/presentation/cubit/main_navigation_cubit.dart';
import 'features/profile/data/sources/profile_api_service.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'features/profile/domain/usecases/update_profile_usecase.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

// Create Feature
import 'features/create/data/sources/create_api_service.dart';
import 'features/create/domain/repository/create_repository.dart';
import 'features/create/data/repository/create_repository_impl.dart';
import 'features/create/domain/usecases/create_playlist_usecase.dart';
import 'features/create/presentation/bloc/create_playlist_bloc.dart';

// Search Feature
import 'features/search/data/sources/search_api_service.dart';
import 'features/search/domain/repository/search_repository.dart';
import 'features/search/data/repository/search_repository_impl.dart';
import 'features/search/domain/usecases/search_usecase.dart';
import 'features/search/presentation/bloc/search_bloc.dart';

// Library Feature
import 'features/library/data/sources/library_api_service.dart';
import 'features/library/domain/repository/library_repository.dart';
import 'features/library/data/repository/library_repository_impl.dart';
import 'features/library/domain/usecases/get_library_usecase.dart';
import 'features/library/domain/usecases/add_song_usecase.dart';
import 'features/library/domain/usecases/remove_song_usecase.dart';
import 'features/library/domain/usecases/delete_playlist_usecase.dart';
import 'features/library/presentation/bloc/library_bloc.dart';
import 'features/library/presentation/bloc/library_action_bloc.dart';

// Playlist/Album Detail Feature
import 'features/playlist_detail/data/sources/detail_api_service.dart';
import 'features/playlist_detail/data/repository/detail_repository_impl.dart';
import 'features/playlist_detail/domain/repository/detail_repository.dart';
import 'features/playlist_detail/domain/usecases/get_songs_usecase.dart';
import 'features/playlist_detail/presentation/bloc/detail_bloc.dart';

// Player Feature
import 'core/services/audio_service.dart';
import 'features/player/presentation/bloc/player_cubit.dart';

// Favorites Feature
import 'features/favorites/data/sources/favorites_api_service.dart';
import 'features/favorites/data/repositories/favorites_repository_impl.dart';
import 'features/favorites/domain/repositories/favorites_repository.dart';
import 'features/favorites/domain/usecases/favorites_usecases.dart';
import 'features/favorites/presentation/bloc/favorites_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- External ---
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => ApiClient(sl()));

  // Inicializar Motor de Audio Global
  final audioService = AudioService();
  await audioService.init();
  sl.registerLazySingleton(() => audioService);

  // --- Data Sources ---
  // ASEGÚRATE DE QUE ESTAS LÍNEAS ESTÉN SOLO UNA VEZ
  sl.registerLazySingleton<AuthApiService>(() => AuthApiServiceImpl(sl()));
  sl.registerLazySingleton<AuthLocalService>(() => AuthLocalServiceImpl(sl()));
  sl.registerLazySingleton<SongApiService>(() => SongApiServiceImpl(sl()));
  sl.registerLazySingleton<HomeApiService>(() => HomeApiServiceImpl(sl()));
  sl.registerLazySingleton<ProfileApiService>(() => ProfileApiServiceImpl(apiClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton<CreateApiService>(() => CreateApiServiceImpl(sl()));
  sl.registerLazySingleton<SearchApiService>(() => SearchApiServiceImpl(sl()));
  sl.registerLazySingleton<LibraryApiService>(() => LibraryApiServiceImpl(sl()));
  sl.registerLazySingleton<PlaylistDetailApiService>(() => PlaylistDetailApiServiceImpl(sl()));
  sl.registerLazySingleton<FavoritesApiService>(() => FavoritesApiServiceImpl(sl()));

  // --- Repositories ---
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()) // Pasa dos sl() porque ahora usa API y Local
    
  );
  sl.registerLazySingleton<SongRepository>(() => SongRepositoryImpl(sl()));
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(profileApiService: sl()));
  sl.registerLazySingleton<CreateRepository>(() => CreateRepositoryImpl(sl()));
  sl.registerLazySingleton<SearchRepository>(() => SearchRepositoryImpl(sl()));
  sl.registerLazySingleton<LibraryRepository>(() => LibraryRepositoryImpl(sl()));
  sl.registerLazySingleton<PlaylistDetailRepository>(() => PlaylistDetailRepositoryImpl(sl()));
  sl.registerLazySingleton<FavoritesRepository>(() => FavoritesRepositoryImpl(sl()));

  // --- Use Cases ---
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => SongUseCase(sl()));
  sl.registerLazySingleton(() => GetAlbumsUseCase(sl()));
  sl.registerLazySingleton(() => GetPlaylistsUseCase(sl()));
  sl.registerLazySingleton(() => GetUserProfileUseCase(repository: sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => CreatePlaylistUseCase(sl()));
  sl.registerLazySingleton(() => SearchUseCase(sl()));
  sl.registerLazySingleton(() => GetLibraryUseCase(sl()));
  sl.registerLazySingleton(() => AddSongToPlaylistUseCase(sl()));
  sl.registerLazySingleton(() => RemoveSongFromPlaylistUseCase(sl()));
  sl.registerLazySingleton(() => DeletePlaylistUseCase(sl()));
  sl.registerLazySingleton(() => GetSongsUseCase(sl()));
  sl.registerLazySingleton(() => GetFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => AddFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFavoriteUseCase(sl()));

  // --- Blocs ---
  sl.registerFactory(() => AuthBloc(
    loginUseCase: sl(),
    registerUseCase: sl(),
  ));
  sl.registerFactory(() => HomeBloc(
    getSongsUseCase: sl(),
    getAlbumsUseCase: sl(),
    getPlaylistsUseCase: sl(),
  ));
  sl.registerFactory(() => MainNavigationCubit());
  sl.registerFactory(() => ProfileBloc(
    getUserProfileUseCase: sl(),
    updateProfileUseCase: sl(),
  ));
  sl.registerFactory(() => CreatePlaylistBloc(sl()));
  sl.registerFactory(() => SearchBloc(sl()));
  sl.registerFactory(() => LibraryBloc(sl()));
  sl.registerFactory(() => LibraryActionBloc(sl(), sl(), sl()));
  sl.registerFactory(() => PlaylistDetailBloc(sl()));
  sl.registerLazySingleton(() => PlayerCubit(sl()));
  sl.registerLazySingleton(() => FavoritesBloc(sl(), sl(), sl()));
}