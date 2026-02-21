
import 'package:pair_app/domain/entities/entities/station_entity.dart';

class StationModel {
  final double? lat;
  final double? lon;
  final int? uid;
  final String? aqi;
  final StationInfoModel? station;

  StationModel({this.lat, this.lon, this.uid, this.aqi, this.station});

  factory StationModel.fromJson(Map<String, dynamic> json) {
    return StationModel(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0.0,
      uid: json['uid'] as int?,
      aqi: json['aqi']?.toString(),
      station: json['station'] != null
          ? StationInfoModel.fromJson(json['station'])
          : null,
    );
  }

  StationEntity toEntity() {
    return StationEntity(
      uid: uid ?? 0,
      latitude: lat ?? 0.0,
      longitude: lon ?? 0.0,
      name: station?.name ?? '',
      aqi: int.parse(aqi ?? '0'),
      time: station?.time != null ? DateTime.tryParse(station!.time!) : null,
    );
  }
}

class StationInfoModel {
  final String? name;
  final String? time;

  StationInfoModel({this.name, this.time});

  factory StationInfoModel.fromJson(Map<String, dynamic> json) {
    return StationInfoModel(
      name: json['name'] as String?,
      time: json['time'] as String?,
    );
  }
}
