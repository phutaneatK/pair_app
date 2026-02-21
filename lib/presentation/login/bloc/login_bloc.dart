import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pair_app/core/core.dart';
import 'package:pair_app/core/services/auth_service.dart';
import 'package:pair_app/domain/entities/entities/user_entity.dart';
import 'package:pair_app/domain/usecases/check_login_usecase.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final CheckLoginUseCase checkLoginUseCase;
  final AuthService authService;

  LoginBloc({required this.checkLoginUseCase, required this.authService})
    : super(LoginInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());

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
