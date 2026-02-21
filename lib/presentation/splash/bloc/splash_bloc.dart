import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pair_app/core/core.dart';
import 'package:pair_app/core/services/auth_service.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final AuthService _authService;

  SplashBloc(this._authService) : super(SplashInitial()) {
    on<OnCheckLogin>((event, emit) async {
      log("SplashBloc: OnCheckLogin ~");

      emit(SplashLoading());

      await Future.delayed(const Duration(seconds: 2));

      final hasToken = await _authService.isHasToken();

      if (hasToken) {
        final isValid = await _authService.isValidToken();

        if (isValid) {
          emit(SplashAuthOk());
        } else {
          await _authService.deleteToken();
          emit(
            SplashAuthFail(message: 'Token is expired. Please log in again.'),
          );
        }
      } else {
        emit(SplashAuthFail(message: 'No valid Token.'));
      }
    });
  }
}
