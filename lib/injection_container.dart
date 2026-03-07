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

final sl = GetIt.instance;

Future<void> init() async {
  // --- External ---
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => ApiClient(sl()));

  // --- Data Sources ---
  // ASEGÚRATE DE QUE ESTAS LÍNEAS ESTÉN SOLO UNA VEZ
  sl.registerLazySingleton<AuthApiService>(() => AuthApiServiceImpl(sl()));
  sl.registerLazySingleton<AuthLocalService>(() => AuthLocalServiceImpl(sl()));
  sl.registerLazySingleton<SongApiService>(() => SongApiServiceImpl(sl()));
  sl.registerLazySingleton<HomeApiService>(() => HomeApiServiceImpl(sl()));
  sl.registerLazySingleton<ProfileApiService>(() => ProfileApiServiceImpl(apiClient: sl(), sharedPreferences: sl()));
  sl.registerLazySingleton<CreateApiService>(() => CreateApiServiceImpl(sl()));
  sl.registerLazySingleton<SearchApiService>(() => SearchApiServiceImpl(sl()));

  // --- Repositories ---
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()) // Pasa dos sl() porque ahora usa API y Local
    
  );
  sl.registerLazySingleton<SongRepository>(() => SongRepositoryImpl(sl()));
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(profileApiService: sl()));
  sl.registerLazySingleton<CreateRepository>(() => CreateRepositoryImpl(sl()));
  sl.registerLazySingleton<SearchRepository>(() => SearchRepositoryImpl(sl()));

  // --- Use Cases ---
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => SongUseCase(sl()));
  sl.registerLazySingleton(() => GetAlbumsUseCase(sl()));
  sl.registerLazySingleton(() => GetPlaylistsUseCase(sl()));
  sl.registerLazySingleton(() => GetUserProfileUseCase(repository: sl()));
  sl.registerLazySingleton(() => CreatePlaylistUseCase(sl()));
  sl.registerLazySingleton(() => SearchUseCase(sl()));

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
  sl.registerFactory(() => ProfileBloc(getUserProfileUseCase: sl()));
  sl.registerFactory(() => CreatePlaylistBloc(sl()));
  sl.registerFactory(() => SearchBloc(sl()));
}