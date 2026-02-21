import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Utility functions for geographic calculations.
///
/// - `calDistance` uses the Haversine formula to compute the
///   great-circle distance between two lat/lon points in meters.
/// - `distanceText` converts meters to a human-friendly string (m or km).
/// - `getDistanceFromStored` calculates distance from stored location to target.

/// Calculate distance between two geographic points in meters.
double calDistance(
  double startLat,
  double startLng,
  double endLat,
  double endLng,
) {
  const double earthRadius = 6371000; // meters

  final double dLat = _degToRad(endLat - startLat);
  final double dLon = _degToRad(endLng - startLng);

  final double a =
      pow(sin(dLat / 2), 2) +
      cos(_degToRad(startLat)) * cos(_degToRad(endLat)) * pow(sin(dLon / 2), 2);

  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  final double distance = earthRadius * c;
  return distance;
}

/// Format distance in meters to human-readable string.
String distanceText(double meters) {
  if (meters.isNaN || meters.isInfinite) return '-';
  if (meters >= 1000) {
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }
  return '${meters.round()} m';
}

double _degToRad(double deg) => deg * (pi / 180.0);
