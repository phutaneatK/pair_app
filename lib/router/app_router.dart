import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:pair_app/core/cubit/location_cubit.dart';
import 'package:pair_app/domain/entities/entities/station_entity.dart';
import 'package:pair_app/presentation/login/bloc/login_bloc.dart';
import 'package:pair_app/presentation/login/cubit/password_visibility_cubit.dart';
import 'package:pair_app/presentation/login/pages/login_page.dart';
import 'package:pair_app/presentation/home/pages/home_page.dart';
import 'package:pair_app/presentation/home/pages/station_detail_page.dart';
import 'package:pair_app/presentation/home/bloc/station_detail_bloc/station_detail_bloc.dart';
import 'package:pair_app/presentation/splash/bloc/splash_bloc.dart';
import 'package:pair_app/presentation/splash/pages/splash_page.dart';
import 'package:pair_app/router/app_routers.dart';
import 'package:pair_app/presentation/home/bloc/station_bloc/station_bloc.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final getIt = GetIt.instance;

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.splashPath,
    redirect: (context, state) async {
      //final hasToken = await getIt<AuthService>().hasToken();
      //if (!hasToken) return AppRoutes.loginPath;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splashName,
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<SplashBloc>()..add(OnCheckLogin()),
          child: const SplashPage(),
        ),
      ),

      // ==================== Auth Routes ====================
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.loginName,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => getIt<LoginBloc>()),
            BlocProvider(create: (context) => getIt<PasswordVisibilityCubit>()),
          ],
          child: const LoginPage(),
        ),
      ),

      // ==================== Home Route ====================
      GoRoute(
        path: AppRoutes.homePath,
        name: AppRoutes.homeName,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => getIt<StationBloc>()),
            BlocProvider.value(value: getIt<LocationCubit>()),
          ],
          child: const HomePage(),
        ),
        // builder: (context, state) => BlocProvider(
        //   create: (_) => getIt<StationBloc>(),
        //   child: const HomePage(),
        // ),
      ),
      // ==================== Station Detail Route ====================
      GoRoute(
        path: AppRoutes.stationDetailPath,
        name: AppRoutes.stationDetailName,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => getIt<StationDetailBloc>()),
            BlocProvider.value(value: getIt<LocationCubit>()),
          ],
          child: StationDetailPage(station: state.extra as StationEntity),
        ),
      ),
    ],
  );
}
