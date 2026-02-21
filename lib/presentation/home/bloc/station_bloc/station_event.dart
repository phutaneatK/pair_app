import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

abstract class StationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadStations extends StationEvent {
  final Position location;
  final double minLat;
  final double minLon;
  final double maxLat;
  final double maxLon;

  LoadStations({
    required this.location,
    required this.minLat,
    required this.minLon,
    required this.maxLat,
    required this.maxLon,
  });

  @override
  List<Object?> get props => [location, minLat, minLon, maxLat, maxLon];
}

class StartLoading extends StationEvent {}
