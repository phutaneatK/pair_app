import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pair_app/core/core.dart';
import 'package:pair_app/core/error/failures.dart';
import 'package:pair_app/data/datasources/station_remote_datasource.dart';
import 'package:pair_app/data/model/model/station_detail_model.dart';
import 'package:pair_app/data/model/model/station_model.dart';
import 'package:pair_app/domain/entities/entities/station_entity.dart';
import 'package:pair_app/domain/repositories/station_repository.dart';

class StationRepositoryImpl implements StationRepository {
  final StationRemoteDataSource remoteDataSource;

  StationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<StationEntity>>> getStations(
    Position location,
    double minLat,
    double minLon,
    double maxLat,
    double maxLon,
  ) async {
    try {
      final Map<String, dynamic>? result = await remoteDataSource.getStations(
        minLat,
        minLon,
        maxLat,
        maxLon,
      );

      if (result == null) {
        return Left(ServerFailure('API Call error'));
      }

      if (result['status'] == 'error') {
        return Left(
          ServerFailure('API returned error status [${result['data']}]'),
        );
      }

      final stations = ((result['data'] as List?) ?? [])
          .map((e) => StationModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final stationEntities = stations
          .where((e) => (e.lat ?? 0) != 0 && (e.lon ?? 0) != 0)
          .map((e) => e.toEntity())
          .toList(growable: false);

      return Right(stationEntities);
    } catch (e, st) {
      log('StationRepositoryImpl.loadStations error: $e\n$st');
      return Left(ServerFailure('Server error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, StationDetailEntity>> getStationById(
    StationEntity station,
  ) async {
    try {
      final Map<String, dynamic>? result = await remoteDataSource
          .getStationById(station.uid);

      if (result == null) {
        return Left(ServerFailure('API Call error'));
      }

      if (result['status'] == 'error') {
        return Left(
          ServerFailure('API returned error status [${result['data']}]'),
        );
      }

      final model = StationDetailModel.fromJson(
        result['data'] as Map<String, dynamic>,
      );

      return Right(model.toEntity());
    } catch (e, st) {
      log('StationRepositoryImpl.getStationById error: $e\n$st');
      return Left(ServerFailure('Server error: ${e.toString()}'));
    }
  }
}
