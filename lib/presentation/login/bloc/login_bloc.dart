import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pair_api/pair_api.dart';
import 'package:pair_app/core/services/auth_service.dart';
import 'package:pcore/pcore.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final CheckLoginUseCase checkLoginUseCase;
  final AuthService authService;

  LoginBloc({required this.checkLoginUseCase, required this.authService})
    : super(LoginInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());

      log('Login attempt: ${event.username}');

      final result = await checkLoginUseCase.execute(
        event.username,
        event.password,
      );

      await result.fold(
        (failure) async {
          log('❌ Login failed: ${failure.message}');
          emit(LoginFailure(failure.message));
        },
        (user) async {
          await authService.saveToken(user.token);
          log('✅ Login successful: ${user.username}');
          if (!emit.isDone) {
            emit(LoginSuccess(user));
          }
        },
      );
    });
  }
}
