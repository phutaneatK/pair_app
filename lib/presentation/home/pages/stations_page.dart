import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pair_app/core/core.dart';
import 'package:pair_app/core/cubit/location_cubit.dart';
import 'package:pair_app/core/services/location_service.dart';
import 'package:pair_app/domain/entities/entities/station_entity.dart';
import 'package:pair_app/presentation/home/bloc/station_bloc/station_bloc.dart';
import 'package:pair_app/presentation/home/bloc/station_bloc/station_event.dart';
import 'package:pair_app/presentation/home/bloc/station_bloc/station_state.dart';
import 'package:pair_app/presentation/home/widgets/station_distance.dart';
import 'package:pair_app/presentation/widgets/empty_page.dart';

class StationsConstants {
  StationsConstants._();
  static const double radiusKm = 20.0;
}

class StationsPage extends StatefulWidget {
  const StationsPage({super.key});

  @override
  State<StationsPage> createState() => _StationsPageState();
}

class _StationsPageState extends State<StationsPage> {
  final loc = LocationService();

  @override
  void initState() {
    super.initState();
    logDebug("StationsPage init ~");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onLoadList();
    });
  }

  Future<void> _onLoadList({isRefresh = false}) async {
    final Position? location = await loc.getCurrentLocation();
    if (location == null) {
      return;
    }

    if (isRefresh) {
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    final bounds = _onGetBound(location);

    // Update location in cubit for app-wide access
    if (mounted) {
      context.read<LocationCubit>().updateLocation(
        location.latitude,
        location.longitude,
      );
    }

    if (!mounted) return;

    context.read<StationBloc>().add(
      LoadStations(
        location: location,
        minLat: bounds['minLat']!,
        minLon: bounds['minLon']!,
        maxLat: bounds['maxLat']!,
        maxLon: bounds['maxLon']!,
      ),
    );
  }

  Map<String, double> _onGetBound(Position location) {
    const double kmPerDegreeLat = 111.0;

    final double radiusKm = StationsConstants.radiusKm;

    final double latDelta = radiusKm / kmPerDegreeLat;

    final double latRad = location.latitude * pi / 180.0;
    final double kmPerDegreeLon = kmPerDegreeLat * cos(latRad);
    final double lonDelta = radiusKm / kmPerDegreeLon;

    final double minLat = location.latitude - latDelta;
    final double maxLat = location.latitude + latDelta;
    final double minLon = location.longitude - lonDelta;
    final double maxLon = location.longitude + lonDelta;

    return {
      'minLat': minLat,
      'minLon': minLon,
      'maxLat': maxLat,
      'maxLon': maxLon,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _onLoadList,
        child: BlocBuilder<StationBloc, StationState>(
          builder: (context, state) {
            if (state is StationLoading) {
              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                itemCount: 10,
                itemBuilder: (context, index) => const _StationSkeleton(),
                separatorBuilder: (_, __) => const SizedBox(height: 6),
              );
            } else if (state is StationHasData) {
              final locationState = context.read<LocationCubit>().state;
              final currentLat = locationState.latitude;
              final currentLng = locationState.longitude;
              final List<StationEntity> stations = state.stations
                  .map(
                    (e) => e.copyWith(
                      distance: calDistance(
                        currentLat,
                        currentLng,
                        e.latitude,
                        e.longitude,
                      ),
                    ),
                  )
                  .toList(growable: false);

              stations.sort((a, b) => a.distance.compareTo(b.distance));

              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: stations.length,
                itemBuilder: (context, index) =>
                    _buildStationItem(stations[index]),
                separatorBuilder: (_, __) => const SizedBox(height: 8),
              );
            } else if (state is StationError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: EmptyPage(
                        messageError:
                            'No stations found. error message: ${state.message}',
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              itemCount: 10,
              itemBuilder: (context, index) => const _StationSkeleton(),
              separatorBuilder: (_, __) => const SizedBox(height: 6),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStationItem(StationEntity station) {
    final aqiText = station.aqi?.toString() ?? '-';
    final latText = station.latitude.toStringAsFixed(6);
    final lonText = station.longitude.toStringAsFixed(6);
    final timeText = fdate(station.time);

    final luminance = station.status.color.computeLuminance();
    final aqiTextColor = luminance > 0.6 ? Colors.black : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            CoveNav.push('/station/detail', extra: station);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vertical accent
                // Container(
                //   width: 6,
                //   height: 56,
                //   decoration: BoxDecoration(
                //     color: s.status.color,
                //     borderRadius: BorderRadius.circular(4),
                //   ),
                // ),
                // const SizedBox(width: 12),

                // AQI circle
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: station.status.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: station.status.color.withValues(alpha: 0.22),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          aqiText,
                          style: TextStyle(
                            color: aqiTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Main info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              station.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 4),
                          StationDistance(distance: station.distance),
                        ],
                      ),

                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_pin,
                            size: 14,
                            color: Colors.grey[700],
                          ),
                          Expanded(
                            child: Text(
                              '$latText, $lonText',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (timeText.isNotEmpty) ...[
                            // Icon(
                            //   Icons.access_time_rounded,
                            //   size: 14,
                            //   color: Colors.grey[700],
                            // ),
                            Text(
                              timeText,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Status chip
                // Column(
                //   mainAxisSize: MainAxisSize.min,
                //   crossAxisAlignment: CrossAxisAlignment.end,
                //   children: [
                //     const Icon(Icons.chevron_right, color: Colors.grey),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StationSkeleton extends StatelessWidget {
  const _StationSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            // small vertical accent (hidden for skeleton but keeps layout)
            Container(height: 56, color: Colors.transparent),
            const SizedBox(width: 12),

            // AQI/status circle skeleton
            _Shimmer(
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Main info skeleton
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Shimmer(
                    child: Container(
                      height: 20,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Shimmer(
                        child: Container(
                          height: 15,
                          width: 100,
                          color: Colors.grey.shade300,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _Shimmer(
                        child: Container(
                          height: 12,
                          width: 80,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  final Widget child;
  const _Shimmer({required this.child});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            final width = rect.width;
            // move gradient from right to left
            final dx = -width + (width * 2) * _ctrl.value;
            final gradientRect = Rect.fromLTWH(dx, 0, width * 2, rect.height);
            return LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: const [0.1, 0.5, 0.9],
            ).createShader(gradientRect);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}
