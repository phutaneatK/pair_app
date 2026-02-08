part of 'splash_bloc.dart';

abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashAuthOk extends SplashState {}

class SplashAuthFail extends SplashState {
  final String? message;
  SplashAuthFail({required this.message});
}
