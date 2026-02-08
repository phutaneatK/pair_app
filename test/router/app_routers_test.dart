import 'package:flutter_test/flutter_test.dart';
import 'package:pair_app/router/app_routers.dart';

void main() {
  group('AppRoutes', () {
    group('Route Names', () {
      test('should have correct splash route name', () {
        expect(AppRoutes.splashName, 'splash');
      });

      test('should have correct login route name', () {
        expect(AppRoutes.loginName, 'login');
      });

      test('should have correct home route name', () {
        expect(AppRoutes.homeName, 'home');
      });
    });

    group('Route Paths', () {
      test('should have correct splash route path', () {
        expect(AppRoutes.splashPath, '/splash');
      });

      test('should have correct login route path', () {
        expect(AppRoutes.loginPath, '/login');
      });

      test('should have correct home route path', () {
        expect(AppRoutes.homePath, '/home');
      });
    });

    group('Route Path Construction', () {
      test('splash path should be constructed from splash name', () {
        expect(AppRoutes.splashPath, '/${AppRoutes.splashName}');
      });

      test('login path should be constructed from login name', () {
        expect(AppRoutes.loginPath, '/${AppRoutes.loginName}');
      });

      test('home path should be constructed from home name', () {
        expect(AppRoutes.homePath, '/${AppRoutes.homeName}');
      });
    });

    group('Route Constants Validation', () {
      test('all route names should be non-empty strings', () {
        expect(AppRoutes.splashName, isNotEmpty);
        expect(AppRoutes.loginName, isNotEmpty);
        expect(AppRoutes.homeName, isNotEmpty);
      });

      test('all route paths should start with forward slash', () {
        expect(AppRoutes.splashPath, startsWith('/'));
        expect(AppRoutes.loginPath, startsWith('/'));
        expect(AppRoutes.homePath, startsWith('/'));
      });

      test('all route names should be lowercase', () {
        expect(AppRoutes.splashName, equals(AppRoutes.splashName.toLowerCase()));
        expect(AppRoutes.loginName, equals(AppRoutes.loginName.toLowerCase()));
        expect(AppRoutes.homeName, equals(AppRoutes.homeName.toLowerCase()));
      });

      test('all route names should contain only alphabetic characters', () {
        final alphaRegex = RegExp(r'^[a-z]+$');
        expect(AppRoutes.splashName, matches(alphaRegex));
        expect(AppRoutes.loginName, matches(alphaRegex));
        expect(AppRoutes.homeName, matches(alphaRegex));
      });
    });

    group('Route Uniqueness', () {
      test('all route names should be unique', () {
        final routeNames = [
          AppRoutes.splashName,
          AppRoutes.loginName,
          AppRoutes.homeName,
        ];
        
        expect(routeNames.toSet().length, equals(routeNames.length));
      });

      test('all route paths should be unique', () {
        final routePaths = [
          AppRoutes.splashPath,
          AppRoutes.loginPath,
          AppRoutes.homePath,
        ];
        
        expect(routePaths.toSet().length, equals(routePaths.length));
      });
    });
  });
}