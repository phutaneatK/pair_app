
import 'package:pair_app/domain/entities/entities/station_entity.dart';

class StationDetailModel {
  final int? aqi;
  final int? idx;
  final List<AttributionModel>? attributions;
  final CityModel? city;
  final String? dominentpol;
  final Map<String, IaqiValueModel>? iaqi;
  final TimeModel? time;
  final ForecastModel? forecast;

  StationDetailModel({
    this.aqi,
    this.idx,
    this.attributions,
    this.city,
    this.dominentpol,
    this.iaqi,
    this.time,
    this.forecast,
  });

  factory StationDetailModel.fromJson(Map<String, dynamic> json) {
    return StationDetailModel(
      aqi: json['aqi'] as int?,
      idx: json['idx'] as int? ?? 0,
      attributions: (json['attributions'] as List?)
          ?.map((e) => AttributionModel.fromJson(e))
          .toList(),
      city: json['city'] != null ? CityModel.fromJson(json['city']) : null,
      dominentpol: json['dominentpol'] as String?,
      iaqi: (json['iaqi'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, IaqiValueModel.fromJson(value)),
      ),
      time: json['time'] != null ? TimeModel.fromJson(json['time']) : null,
      forecast: json['forecast'] != null
          ? ForecastModel.fromJson(json['forecast'])
          : null,
    );
  }

  StationDetailEntity toEntity() {
    DateTime? parsedTime;
    if (time?.iso != null) {
      parsedTime = DateTime.tryParse(time!.iso!);
    } else if (time?.s != null) {
      parsedTime = DateTime.tryParse(time!.s!);
    }

    final latitude = (city?.geo != null && city!.geo!.length >= 2)
        ? city!.geo![0]
        : 0.0;
    final longitude = (city?.geo != null && city!.geo!.length >= 2)
        ? city!.geo![1]
        : 0.0;

    final iaqiEntity = IaqiEntity(
      dew: iaqi?['dew']?.v,
      h: iaqi?['h']?.v,
      no2: iaqi?['no2']?.v,
      o3: iaqi?['o3']?.v,
      p: iaqi?['p']?.v,
      pm10: iaqi?['pm10']?.v,
      pm25: iaqi?['pm25']?.v,
      so2: iaqi?['so2']?.v,
      t: iaqi?['t']?.v,
    );

    final List<DailyEntity> dailysList = [];
    if (forecast?.daily?.pm10 != null) {
      dailysList.addAll(
        forecast!.daily!.pm10!.map((f) {
          final day = DateTime.tryParse(f.day ?? '');
          return DailyEntity(
            name: 'pm10',
            day: day,
            avg: f.avg,
            min: f.min,
            max: f.max,
          );
        }),
      );
    }
    if (forecast?.daily?.pm25 != null) {
      dailysList.addAll(
        forecast!.daily!.pm25!.map((f) {
          final day = DateTime.tryParse(f.day ?? '');
          return DailyEntity(
            name: 'pm25',
            day: day,
            avg: f.avg,
            min: f.min,
            max: f.max,
          );
        }),
      );
    }
    if (forecast?.daily?.uvi != null) {
      dailysList.addAll(
        forecast!.daily!.uvi!.map((f) {
          final day = DateTime.tryParse(f.day ?? '');
          return DailyEntity(
            name: 'uvi',
            day: day,
            avg: f.avg,
            min: f.min,
            max: f.max,
          );
        }),
      );
    }

    return StationDetailEntity(
      id: idx ?? 0,
      latitude: latitude,
      longitude: longitude,
      aqi: aqi,
      name: city?.name ?? '',
      time: parsedTime,
      iaqi: iaqiEntity,
      dailys: dailysList,
    );
  }
}

class AttributionModel {
  final String? url;
  final String? name;
  final String? logo;

  AttributionModel({this.url, this.name, this.logo});

  factory AttributionModel.fromJson(Map<String, dynamic> json) {
    return AttributionModel(
      url: json['url'] as String?,
      name: json['name'] as String?,
      logo: json['logo'] as String?,
    );
  }
}

class CityModel {
  final List<double>? geo;
  final String? name;
  final String? url;
  final String? location;

  CityModel({this.geo, this.name, this.url, this.location});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      geo: (json['geo'] as List?)?.map((e) => (e as num).toDouble()).toList(),
      name: json['name'] as String?,
      url: json['url'] as String?,
      location: json['location'] as String?,
    );
  }
}

class IaqiValueModel {
  final double? v;

  IaqiValueModel({this.v});

  factory IaqiValueModel.fromJson(Map<String, dynamic> json) {
    return IaqiValueModel(v: (json['v'] as num?)?.toDouble());
  }
}

class TimeModel {
  final String? s;
  final String? tz;
  final int? v;
  final String? iso;

  TimeModel({this.s, this.tz, this.v, this.iso});

  factory TimeModel.fromJson(Map<String, dynamic> json) {
    return TimeModel(
      s: json['s'] as String?,
      tz: json['tz'] as String?,
      v: json['v'] as int?,
      iso: json['iso'] as String?,
    );
  }
}

class ForecastModel {
  final DailyForecastModel? daily;

  ForecastModel({this.daily});

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      daily: json['daily'] != null
          ? DailyForecastModel.fromJson(json['daily'])
          : null,
    );
  }
}

class DailyForecastModel {
  final List<ForecastValueModel>? pm10;
  final List<ForecastValueModel>? pm25;
  final List<ForecastValueModel>? uvi;

  DailyForecastModel({this.pm10, this.pm25, this.uvi});

  factory DailyForecastModel.fromJson(Map<String, dynamic> json) {
    return DailyForecastModel(
      pm10: (json['pm10'] as List?)
          ?.map((e) => ForecastValueModel.fromJson(e))
          .toList(),
      pm25: (json['pm25'] as List?)
          ?.map((e) => ForecastValueModel.fromJson(e))
          .toList(),
      uvi: (json['uvi'] as List?)
          ?.map((e) => ForecastValueModel.fromJson(e))
          .toList(),
    );
  }
}

class ForecastValueModel {
  final int? avg;
  final int? min;
  final int? max;
  final String? day;

  ForecastValueModel({this.avg, this.min, this.max, this.day});

  factory ForecastValueModel.fromJson(Map<String, dynamic> json) {
    return ForecastValueModel(
      avg: json['avg'] as int?,
      min: json['min'] as int?,
      max: json['max'] as int?,
      day: json['day'] as String?,
    );
  }
}
