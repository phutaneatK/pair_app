part of 'station_detail_bloc.dart';

sealed class StationDetailState extends Equatable {
  const StationDetailState();
  
  @override
  List<Object> get props => [];
}

final class StationDetailInitial extends StationDetailState {}

final class StationDetailLoading extends StationDetailState {}

final class StationDetailHasData extends StationDetailState {
  final StationDetailEntity station;
  const StationDetailHasData({required this.station});

  @override
  List<Object> get props => [station];
}

final class StationDetailError extends StationDetailState {
  final String message;
  const StationDetailError({required this.message});

  @override
  List<Object> get props => [message];
}
