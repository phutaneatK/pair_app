import 'package:equatable/equatable.dart';

abstract class StationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadStations extends StationEvent {
  final double minLat;
  final double minLon;
  final double maxLat;
  final double maxLon;

  LoadStations({required this.minLat, required this.minLon, required this.maxLat, required this.maxLon});

  @override
  List<Object?> get props => [minLat, minLon, maxLat, maxLon];
}
