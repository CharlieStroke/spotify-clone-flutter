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
import 'features/home/data/repository/song_repository.dart';
import 'features/home/data/repository/song_repository_impl.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- External ---
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => ApiClient());

  // --- Data Sources ---
  // ASEGÚRATE DE QUE ESTAS LÍNEAS ESTÉN SOLO UNA VEZ
  sl.registerLazySingleton<AuthApiService>(() => AuthApiServiceImpl(sl()));
  sl.registerLazySingleton<AuthLocalService>(() => AuthLocalServiceImpl(sl()));
  sl.registerLazySingleton<SongApiService>(() => SongApiServiceImpl(sl()));

  // --- Repositories ---
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()) // Pasa dos sl() porque ahora usa API y Local
    
  );
  sl.registerLazySingleton<SongRepository>(() => SongRepositoryImpl(sl()));

  // --- Use Cases ---
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));

  // --- Blocs ---
  sl.registerFactory(() => AuthBloc(
    loginUseCase: sl(),
    registerUseCase: sl(),
  ));
}