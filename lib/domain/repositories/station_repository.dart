import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pair_app/core/error/failures.dart';
import 'package:pair_app/domain/entities/entities/station_entity.dart';

abstract class StationRepository {
  Future<Either<Failure, List<StationEntity>>> getStations(
    Position location,
    double minLat,
    double minLon,
    double maxLat,
    double maxLon,
  );

  Future<Either<Failure, StationDetailEntity>> getStationById(
    StationEntity station,
  );
}
