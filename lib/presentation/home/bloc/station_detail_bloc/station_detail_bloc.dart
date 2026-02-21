import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pair_app/domain/entities/entities/station_entity.dart';
import 'package:pair_app/domain/usecases/get_station_byid_usecase.dart';

part 'station_detail_event.dart';
part 'station_detail_state.dart';

class StationDetailBloc extends Bloc<StationDetailEvent, StationDetailState> {
  final GetStationByIdUseCase _useCase;

  StationDetailBloc(this._useCase) : super(StationDetailInitial()) {
    on<LoadStationDetail>((event, emit) async {
      emit(StationDetailLoading());
      await Future.delayed(const Duration(milliseconds: 300));
      try {
        final result = await _useCase.execute(event.station);
        result.fold(
          (failure) => emit(StationDetailError(message: failure.message)),
          (data) => emit(StationDetailHasData(station: data)),
        );
      } catch (e) {
        emit(StationDetailError(message: e.toString()));
      }
    });
  }
}
