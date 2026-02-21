import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String username;
  final String token;

  const UserEntity({required this.username, required this.token});

  @override
  List<Object?> get props => [username, token];
}
