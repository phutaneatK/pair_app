import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:pair_app/core/services/auth_service.dart';
import 'package:pair_app/presentation/login/bloc/login_bloc.dart';
import 'package:pair_app/presentation/login/cubit/password_visibility_cubit.dart';
import 'package:pair_app/presentation/login/pages/login_page.dart';
import 'package:pair_app/presentation/home/pages/home_page.dart';
import 'package:pair_app/presentation/splash/bloc/splash_bloc.dart';
import 'package:pair_app/presentation/splash/pages/splash_page.dart';
import 'package:pair_app/router/app_routers.dart';
import 'package:pair_app/presentation/home/bloc/station_bloc.dart';

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
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<StationBloc>(),
          child: const HomePage(),
        ),
      ),
    ],
  );
}
