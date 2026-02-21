import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pair_app/core/config/app_config.dart';
import 'package:pair_app/core/core.dart';
import 'package:pair_app/data/datasources/auth_remote_datasource.dart';
import 'package:pair_app/data/datasources/station_remote_datasource.dart';
import 'package:pair_app/data/repositories/auth_repository_impl.dart';
import 'package:pair_app/data/repositories/station_repository_impl.dart';
import 'package:pair_app/domain/repositories/auth_repository.dart';
import 'package:pair_app/domain/repositories/station_repository.dart';
import 'package:pair_app/domain/usecases/check_login_usecase.dart';
import 'package:pair_app/domain/usecases/get_station_byid_usecase.dart';
import 'package:pair_app/domain/usecases/get_stations_usecase.dart';
import 'core/cubit/location_cubit.dart';
import 'core/services/auth_service.dart';
import 'core/services/location_service.dart';
import 'presentation/login/bloc/login_bloc.dart';
import 'presentation/login/cubit/password_visibility_cubit.dart';
import 'presentation/splash/bloc/splash_bloc.dart';
import 'presentation/home/bloc/station_bloc/station_bloc.dart';
import 'presentation/home/bloc/station_detail_bloc/station_detail_bloc.dart';

final getIt = GetIt.instance;

void initGetIt() {
  // -- Services -----------------------------------------------------------
  getIt.registerLazySingleton<DioService>(
    () => DioService(
      baseUrl: AppConfig.defaultBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

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

  getIt.registerLazySingleton<StationRepository>(
    () => StationRepositoryImpl(getIt<StationRemoteDataSource>()),
  );

  // -- Usecases -----------------------------------------------------------
  getIt.registerLazySingleton<CheckLoginUseCase>(
    () => CheckLoginUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<GetStationsUseCase>(
    () => GetStationsUseCase(getIt<StationRepository>()),
  );

  getIt.registerLazySingleton<GetStationByIdUseCase>(
    () => GetStationByIdUseCase(getIt<StationRepository>()),
  );

  // -- Services (Auth, Location) -----------------------------------------
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<LocationService>(() => LocationService());

  // -- Presentation: Cubits ----------------------------------------------
  getIt.registerLazySingleton<LocationCubit>(() => LocationCubit());

  // -- Presentation: Blocs -----------------------------------------------
  getIt.registerFactory<StationBloc>(
    () => StationBloc(getIt<GetStationsUseCase>()),
  );

  getIt.registerFactory<StationDetailBloc>(
    () => StationDetailBloc(getIt<GetStationByIdUseCase>()),
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
