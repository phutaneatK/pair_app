import 'package:dartz/dartz.dart';
import 'package:pair_app/core/error/failures.dart';
import 'package:pair_app/domain/entities/entities/user_entity.dart';
import 'package:pair_app/domain/repositories/auth_repository.dart';

class CheckLoginUseCase {
  final AuthRepository repository;

  CheckLoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> execute(String username, String password) async {
    return await repository.checkLogin(username, password);
  }
}
