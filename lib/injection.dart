import 'package:get_it/get_it.dart';
import 'package:pair_api/pair_api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pair_app/core/config/app_config.dart';
import 'core/services/auth_service.dart';
import 'presentation/login/bloc/login_bloc.dart';
import 'presentation/login/cubit/password_visibility_cubit.dart';
import 'presentation/splash/bloc/splash_bloc.dart';
import 'presentation/home/bloc/station_bloc/station_bloc.dart';

final getIt = GetIt.instance;

void initGetIt() {
  // -- Data Sources -------------------------------------------------------
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      googleSheetId: dotenv.env['GOOGLE_SHEET_ID'] ?? '',
      jwtSecretKey: dotenv.env['JWT_SECRET_KEY'] ?? '',
    ),
  );

  getIt.registerLazySingleton<StationRemoteDataSource>(
    () => StationRemoteDataSourceImpl(
      apiBaseUrl: AppConfig.defaultBaseUrl,
      token: dotenv.env['AIR_API_KEY'] ?? '',
    ),
  );

  // -- Repositories -------------------------------------------------------
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );

  getIt.registerLazySingleton<StationRepositoryImpl>(
    () => StationRepositoryImpl(getIt<StationRemoteDataSource>()),
  );

  // -- Usecases -----------------------------------------------------------
  getIt.registerLazySingleton<CheckLoginUseCase>(
    () => CheckLoginUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<GetStationsUseCase>(
    () => GetStationsUseCase(getIt<StationRepositoryImpl>()),
  );

  getIt.registerLazySingleton<GetStationByIdUseCase>(
    () => GetStationByIdUseCase(getIt<StationRepositoryImpl>()),
  );

  // -- Services -----------------------------------------------------------
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt<AuthRepository>()),
  );

  // -- Presentation: Blocs -----------------------------------------------
  getIt.registerFactory<StationBloc>(
    () => StationBloc(
      getIt<GetStationsUseCase>(),
      token: dotenv.env['AIR_API_KEY'] ?? '',
    ),
  );

  getIt.registerFactory<SplashBloc>(() => SplashBloc(getIt<AuthService>()));

  getIt.registerFactory<LoginBloc>(
    () => LoginBloc(
      checkLoginUseCase: getIt<CheckLoginUseCase>(),
      authService: getIt<AuthService>(),
    ),
  );

  getIt.registerFactory<PasswordVisibilityCubit>(
    () => PasswordVisibilityCubit(),
  );
}
