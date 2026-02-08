import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pair_api/domain/usecases/load_station_usecase.dart';
import 'station_event.dart';
import 'station_state.dart';

class StationBloc extends Bloc<StationEvent, StationState> {
  final LoadStationUseCase _useCase;
  final String _token;

  StationBloc(this._useCase, {String token = ''})
    : _token = token,
      super(StationInitial()) {
    on<LoadStations>(_onLoadStations);
  }

  Future<void> _onLoadStations(
    LoadStations event,
    Emitter<StationState> emit,
  ) async {
    emit(StationLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final res = await _useCase.execute(
        event.minLat,
        event.minLon,
        event.maxLat,
        event.maxLon,
        _token,
      );
      res.fold(
        (l) {
          emit(StationError(l.message));
        },
        (stations) {
          emit(StationHasData(stations));
        },
      );
    } catch (e) {
      emit(StationError(e.toString()));
    }
  }
}
