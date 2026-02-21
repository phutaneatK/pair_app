import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pair_app/core/core.dart';
import 'package:pair_app/domain/usecases/get_stations_usecase.dart';
import 'station_event.dart';
import 'station_state.dart';

class StationBloc extends Bloc<StationEvent, StationState> {
  final GetStationsUseCase stationUseCase;

  StationBloc(this.stationUseCase) : super(StationInitial()) {
    on<StartLoading>((event, emit) => emit(StationLoading()));
    on<LoadStations>((event, emit) async {
      log('LoadStations start ~');
      emit(StationLoading());
      try {
        final res = await stationUseCase.execute(
          event.location,
          event.minLat,
          event.minLon,
          event.maxLat,
          event.maxLon,
        );
        res.fold(
          (l) {
            emit(StationError(l.message));
          },
          (stations) {
            log("Stations loaded successfully: ${stations.length} stations");
            emit(StationHasData(stations));
          },
        );
      } catch (e) {
        emit(StationError(e.toString()));
      }
    });
  }
}
