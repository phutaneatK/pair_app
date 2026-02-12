part of 'station_detail_bloc.dart';

sealed class StationDetailEvent extends Equatable {
  const StationDetailEvent();

  @override
  List<Object> get props => [];
}

final class LoadStationDetail extends StationDetailEvent {
  final StationEntity station;

  const LoadStationDetail({required this.station});

  @override
  List<Object> get props => [station];
}
