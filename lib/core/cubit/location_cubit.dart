import 'package:flutter_bloc/flutter_bloc.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(const LocationState(latitude: 0.0, longitude: 0.0));

  void updateLocation(double latitude, double longitude) {
    emit(LocationState(latitude: latitude, longitude: longitude));
  }
}
