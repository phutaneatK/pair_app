import 'package:dartz/dartz.dart';
import 'package:pair_app/core/error/failures.dart';
import 'package:pair_app/data/datasources/auth_remote_datasource.dart';
import 'package:pair_app/domain/entities/entities/user_entity.dart';
import 'package:pair_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserEntity>> checkLogin(
      String username, String password) async {
    try {
      final result = await remoteDataSource.login(username, password);

      if (result != null) {
        final user = UserEntity(
          username: result['username'],
          token: result['token'],
        );
        return Right(user);
      }

      return const Left(AuthFailure('Invalid username or password'));
    } catch (e) {
      return Left(ServerFailure('Server error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> checkToken(String token) async {
    try {
      final result = await remoteDataSource.verifyToken(token);

      if (result != null) {
        final user = UserEntity(
          username: result['username'],
          token: result['token'],
        );
        return Right(user);
      }

      return const Left(AuthFailure('Token verification failed'));
    } catch (e) {
      return Left(ServerFailure('Server error: ${e.toString()}'));
    }
  }
}
