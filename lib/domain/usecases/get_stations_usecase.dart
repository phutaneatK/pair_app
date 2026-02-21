import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pair_app/core/error/failures.dart';
import 'package:pair_app/domain/entities/entities/station_entity.dart';
import 'package:pair_app/domain/repositories/station_repository.dart';

class GetStationsUseCase {
  final StationRepository repository;

  GetStationsUseCase(this.repository);

  Future<Either<Failure, List<StationEntity>>> execute(
    Position location,
    double minLat,
    double minLon,
    double maxLat,
    double maxLon,
  ) async {
    return await repository.getStations(
      location,
      minLat,
      minLon,
      maxLat,
      maxLon,
    );
  }
}
