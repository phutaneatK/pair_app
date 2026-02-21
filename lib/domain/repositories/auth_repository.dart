import 'package:dartz/dartz.dart';
import 'package:pair_app/core/error/failures.dart';
import 'package:pair_app/domain/entities/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> checkLogin(String username, String password);
  Future<Either<Failure, UserEntity>> checkToken(String token);
}
