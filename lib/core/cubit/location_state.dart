part of 'location_cubit.dart';

class LocationState {
  final double latitude;
  final double longitude;

  const LocationState({required this.latitude, required this.longitude});

  LocationState copyWith({double? latitude, double? longitude}) {
    return LocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
