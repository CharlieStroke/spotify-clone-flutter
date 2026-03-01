import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;

  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
  }) : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        super(AuthInitial()) {
    
    // Manejar Registro
    on<AuthSignupEvent>((event, emit) async {
      emit(AuthLoading());
      final result = await _registerUseCase(event.email, event.password, event.name);
      result.fold(
        (error) => emit(AuthFailure(message: error)),
        (user) => emit(AuthSuccess(user: user)),
      );
    });

    // Manejar Inicio de Sesión
    on<AuthSigninEvent>((event, emit) async {
      emit(AuthLoading());
      final result = await _loginUseCase(event.email, event.password);
      result.fold(
        (error) => emit(AuthFailure(message: error)),
        (user) => emit(AuthSuccess(user: user)),
      );
    });
  }
}