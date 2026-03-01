import 'package:get_it/get_it.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';
import 'features/auth/data/sources/auth_api_service.dart';
import 'features/auth/data/repository/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // 1. External & Core
  sl.registerLazySingleton(() => ApiClient());

  // 2. Features - Auth
  
  // Data sources
  sl.registerLazySingleton<AuthApiService>(() => AuthApiServiceImpl(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // Use cases
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));

  // Bloc (factory: crea una instancia nueva cada vez que se pide el Bloc)
  sl.registerFactory(() => AuthBloc(
    registerUseCase: sl(),
    loginUseCase: sl(),
  ));
}