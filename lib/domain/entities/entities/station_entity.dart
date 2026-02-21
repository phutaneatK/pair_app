import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class StationEntity extends Equatable {
  final int uid;

  final double latitude;
  final double longitude;
  final double distance;

  final int? aqi;
  final String name;
  final DateTime? time;

  const StationEntity({
    required this.uid,
    required this.latitude,
    required this.longitude,
    required this.name,
    this.aqi,
    this.time,
    this.distance = 0.0,
  });

  AqiStatus get status => aqiStatusFromValue(aqi);

  factory StationEntity.fromJson(Map<String, dynamic> json) {
    int? parsedAqi;
    final rawAqi = json['aqi'];
    if (rawAqi != null) {
      if (rawAqi is int) {
        parsedAqi = rawAqi;
      } else {
        parsedAqi = int.tryParse(rawAqi.toString());
      }
    }

    String name = '';
    DateTime? time;
    if (json['station'] != null) {
      name = json['station']['name'] ?? '';
      time = json['station']['time'] != null
          ? DateTime.tryParse(json['station']['time'].toString())
          : null;
    }

    return StationEntity(
      uid: json['uid'] is int
          ? json['uid'] as int
          : int.parse('${json['uid']}'),
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lon'] as num).toDouble(),
      aqi: parsedAqi,
      name: name,
      time: time,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'lat': latitude,
    'lon': longitude,
    'aqi': aqi,
    'name': name,
    'time': time?.toIso8601String(),
  };

  StationEntity copyWith({
    int? uid,
    double? latitude,
    double? longitude,
    int? aqi,
    String? name,
    DateTime? time,
    double? distance,
  }) {
    return StationEntity(
      uid: uid ?? this.uid,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      aqi: aqi ?? this.aqi,
      name: name ?? this.name,
      time: time ?? this.time,
      distance: distance ?? this.distance,
    );
  }

  @override
  List<Object?> get props => [uid, latitude, longitude, aqi, name, time];
}

class StationDetailEntity extends Equatable {
  final int id;
  final double latitude;
  final double longitude;
  final double distance;

  final int? aqi;
  final String name;
  final DateTime? time;

  final IaqiEntity iaqi;
  final List<DailyEntity> dailys;

  const StationDetailEntity({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.name,
    this.distance = 0.0,
    this.aqi,
    this.time,
    required this.iaqi,
    required this.dailys,
  });

  AqiStatus get status => aqiStatusFromValue(aqi);

  @override
  List<Object?> get props => [];
}

class IaqiEntity extends Equatable {
  final double? dew;
  final double? h;
  final double? no2;
  final double? o3;
  final double? p;
  final double? pm10;
  final double? pm25;
  final double? so2;
  final double? t;

  const IaqiEntity({
    this.dew,
    this.h,
    this.no2,
    this.o3,
    this.p,
    this.pm10,
    this.pm25,
    this.so2,
    this.t,
  });

  @override
  List<Object?> get props => [dew, h, no2, o3, p, pm10, pm25, so2, t];
}

class DailyEntity extends Equatable {
  final String name;
  final DateTime? day;
  final int? avg;
  final int? min;
  final int? max;

  const DailyEntity({
    required this.name,
    required this.day,
    this.avg,
    this.min,
    this.max,
  });

  @override
  List<Object?> get props => [name, day, avg, min, max];
}

enum AqiStatus {
  none,
  good,
  moderate,
  unhealthyForSensitiveGroups,
  unhealthy,
  veryUnhealthy,
  hazardous,
}

extension AqiStatusExt on AqiStatus {
  String get name {
    switch (this) {
      case AqiStatus.good:
        return 'Good';
      case AqiStatus.moderate:
        return 'Moderate';
      case AqiStatus.unhealthyForSensitiveGroups:
        return 'Unhealthy for Sensitive Groups';
      case AqiStatus.unhealthy:
        return 'Unhealthy';
      case AqiStatus.veryUnhealthy:
        return 'Very Unhealthy';
      case AqiStatus.hazardous:
        return 'Hazardous';
      case AqiStatus.none:
        return 'None';
    }
  }

  Color get color {
    switch (this) {
      case AqiStatus.good:
        return Color(0xFF00E400); // Green
      case AqiStatus.moderate:
        return Color(0xFFFFFF00); // Yellow
      case AqiStatus.unhealthyForSensitiveGroups:
        return Color(0xFFFF7E00); // Orange
      case AqiStatus.unhealthy:
        return Color(0xFFFF0000); // Red
      case AqiStatus.veryUnhealthy:
        return Color(0xFF8F3F97); // Purple
      case AqiStatus.hazardous:
        return Color(0xFF7E0023); // Maroon
      case AqiStatus.none:
        return Color(0xFFD3D3D3); // LightGray
    }
  }
}

AqiStatus aqiStatusFromValue(int? aqi) {
  if (aqi == null) return AqiStatus.none;

  if (aqi >= 0 && aqi <= 50) return AqiStatus.good;
  if (aqi >= 51 && aqi <= 100) return AqiStatus.moderate;
  if (aqi >= 101 && aqi <= 150) return AqiStatus.unhealthyForSensitiveGroups;
  if (aqi >= 151 && aqi <= 200) return AqiStatus.unhealthy;
  if (aqi >= 201 && aqi <= 300) return AqiStatus.veryUnhealthy;
  if (aqi >= 301 && aqi <= 500) return AqiStatus.hazardous;

  return AqiStatus.none;
}
