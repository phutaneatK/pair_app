import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pair_api/pair_api.dart';
import 'package:pcore/utils/format.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/station_detail_bloc/station_detail_bloc.dart';

class StationDetailPage extends StatefulWidget {
  final StationEntity station;

  const StationDetailPage({super.key, required this.station});

  static Widget builder(BuildContext context, GoRouterState state) {
    final extra = state.extra;
    if (extra is StationEntity) return StationDetailPage(station: extra);
    return const Scaffold(body: Center(child: Text('No station data')));
  }

  @override
  State<StationDetailPage> createState() => _StationDetailPageState();
}

class _StationDetailPageState extends State<StationDetailPage> {
  @override
  void initState() {
    super.initState();
  }

  Widget _buildAppbar(Widget child) {
    return Scaffold(
      appBar: AppBar(title: const Text('รายละเอียด'),centerTitle: false,),
      body: StationDetailSkeleton(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use bloc state to render real station detail fetched by usecase
    return BlocBuilder<StationDetailBloc, StationDetailState>(
      builder: (context, state) {
        if (state is StationDetailLoading || state is StationDetailInitial) {
          return _buildAppbar(StationDetailSkeleton());
        }

        if (state is StationDetailError) {
          return _buildAppbar(Center(child: Text('Error: ${state.message}')));
        }

        if (state is StationDetailHasData) {
          final s = state.station;
          final aqiText = s.aqi?.toString() ?? '-';
          final latText = s.latitude.toStringAsFixed(6);
          final lonText = s.longitude.toStringAsFixed(6);

          final luminance = s.status.color.computeLuminance();
          final aqiTextColor = luminance > 0.6 ? Colors.black : Colors.white;

          return Scaffold(
            appBar: AppBar(centerTitle: false, title: Text(s.name)),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: s.status.color,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            aqiText,
                            style: TextStyle(
                              color: aqiTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$latText, $lonText',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            if (s.time != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                'อัพเดท: ${fdate(s.time)}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text('UID: ${s.id}'),
                  Text('AQI status: ${s.status.name}'),
                ],
              ),
            ),
          );
        }

        return const Scaffold(body: Center(child: Text('Unknown state')));
      },
    );
  }
}

class StationDetailSkeleton extends StatelessWidget {
  const StationDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 64, height: 64, color: Colors.grey.shade300),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 18,
                        width: 180,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 120,
                        color: Colors.grey.shade300,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(height: 14, width: 120, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Container(
              height: 12,
              width: double.infinity,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 6),
            Container(
              height: 12,
              width: double.infinity,
              color: Colors.grey.shade300,
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

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();
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
