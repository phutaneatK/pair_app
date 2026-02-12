import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pair_api/pair_api.dart';
import 'package:pair_app/presentation/home/bloc/station_bloc/station_bloc.dart';
import 'package:pair_app/presentation/home/bloc/station_bloc/station_event.dart';
import 'package:pair_app/presentation/home/bloc/station_bloc/station_state.dart';
import 'package:pcore/pcore.dart';

class StationsPage extends StatefulWidget {
  const StationsPage({super.key});

  @override
  State<StationsPage> createState() => _StationsPageState();
}

class _StationsPageState extends State<StationsPage> {
  @override
  void initState() {
    super.initState();
    log("StationsPage init ~");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onLoadList();
    });
  }

  Future<void> _onLoadList({isRefresh = false}) async {
    if (isRefresh) {
      await Future.delayed(const Duration(milliseconds: 1000));
    }
    if (!mounted) return;
    final bloc = context.read<StationBloc>();
    bloc.add(
      LoadStations(minLat: 13.5, minLon: 100.3, maxLat: 14.1, maxLon: 100.9),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              final List<StationEntity> stations = state.stations;
              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(12),
                itemCount: stations.length,
                itemBuilder: (context, index) => _buildStationItem(stations[index]),
                separatorBuilder: (_, __) => const SizedBox(height: 8),
              );
            } else if (state is StationError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(child: Text('Error: ${state.message}')),
                  ),
                ],
              );
            }
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: const Center(child: Text('No data')),
                ),
              ],
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
                      Text(
                        station.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$latText, $lonText',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                      if (timeText.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text.rich(
                          TextSpan(
                            text: 'อัพเดท: ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            children: [
                              TextSpan(
                                text: timeText,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Status chip
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
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
    return _Shimmer(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(width: 6, height: 52, color: Colors.grey.shade300),
            const SizedBox(width: 12),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 180,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 120,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 28,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
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
