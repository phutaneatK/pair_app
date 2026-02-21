

import 'package:dartz/dartz.dart';
import 'package:pair_app/core/error/failures.dart';
import 'package:pair_app/domain/entities/entities/station_entity.dart';
import 'package:pair_app/domain/repositories/station_repository.dart';

class GetStationByIdUseCase {
  final StationRepository repository;

  GetStationByIdUseCase(this.repository);

  Future<Either<Failure, StationDetailEntity>> execute(
    StationEntity station,
  ) async {
    return await repository.getStationById(station);
  }
}
