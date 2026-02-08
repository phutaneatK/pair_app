import 'package:equatable/equatable.dart';
import 'package:pair_api/domain/entities/station.dart';

abstract class StationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StationInitial extends StationState {}

class StationLoading extends StationState {}

class StationHasData extends StationState {
  final List<Station> stations;

  StationHasData(this.stations);

  @override
  List<Object?> get props => [stations];
}

class StationError extends StationState {
  final String message;

  StationError(this.message);

  @override
  List<Object?> get props => [message];
}
