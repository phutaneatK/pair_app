import 'dart:convert';

import 'package:pair_app/core/core.dart';

abstract class StationRemoteDataSource {
  Future<Map<String, dynamic>?> getStations(
    double minLat,
    double minLon,
    double maxLat,
    double maxLon,
  );

  Future<Map<String, dynamic>?> getStationById(int? uid);
}

class StationRemoteDataSourceImpl implements StationRemoteDataSource {
  final String apiBaseUrl;
  final String token;

  StationRemoteDataSourceImpl({required this.apiBaseUrl, required this.token});

  @override
  Future<Map<String, dynamic>?> getStations(
    double? minLat,
    double? minLon,
    double? maxLat,
    double? maxLon,
  ) async {
    try {
      final dio = DioService(baseUrl: apiBaseUrl);
      final path = '/map/bounds/';
      final queryParameters = {
        'latlng':
            '${minLat ?? 13.5},${minLon ?? 100.3},${maxLat ?? 14.1},${maxLon ?? 100.9}',
        'token': token,
      };

      final response = await dio.get(path, params: queryParameters);
      log('getStations url = ${response.realUri}');

      if (response.statusCode == 200) {
        final raw = response.data;

        if (raw is Map<String, dynamic>) {
          return raw;
        }

        if (raw is String) {
          try {
            final decoded = jsonDecode(raw);
            if (decoded is Map<String, dynamic>) return decoded;
          } catch (_) {}
        }

        log(
          '❌ Unexpected response type when loading stations: ${raw.runtimeType}',
        );
        return null;
      } else {
        log('❌ Failed to load stations: HTTP ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('❌ Unexpected error when loading stations: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> getStationById(int? uid) async {
    try {
      final dio = DioService(baseUrl: apiBaseUrl);
      final path = '/feed/@$uid/';
      final queryParameters = {'token': token};

      final response = await dio.get(path, params: queryParameters);
      log('getStationById url = ${response.realUri}');

      if (response.statusCode == 200) {
        final raw = response.data;

        if (raw is Map<String, dynamic>) {
          return raw;
        }

        if (raw is String) {
          try {
            final decoded = jsonDecode(raw);
            if (decoded is Map<String, dynamic>) return decoded;
          } catch (_) {}
        }

        log(
          '❌ Unexpected response type when loading stations: ${raw.runtimeType}',
        );
        return null;
      } else {
        log('❌ Failed to load stations: HTTP ${response.statusCode}');
        return null;
      }
    } catch (e) {
      log('❌ Unexpected error when loading stations: $e');
      return null;
    }
  }
}
