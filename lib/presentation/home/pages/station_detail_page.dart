import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pair_app/core/core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pair_app/core/cubit/location_cubit.dart';
import 'package:pair_app/core/services/location_service.dart';
import 'package:pair_app/domain/entities/entities/station_entity.dart';
import 'package:pair_app/presentation/home/widgets/station_distance.dart';
import 'package:pair_app/presentation/widgets/empty_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/station_detail_bloc/station_detail_bloc.dart';

class StationDetailPage extends StatefulWidget {
  final StationEntity station;

  const StationDetailPage({super.key, required this.station});

  @override
  State<StationDetailPage> createState() => _StationDetailPageState();
}

class _StationDetailPageState extends State<StationDetailPage> {
  final loc = LocationService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onLoadDetail();
    });
  }

  Future<void> _onLoadDetail() async {
    final Position? location = await loc.getCurrentLocation();
    if (location != null && mounted) {
      context.read<LocationCubit>().updateLocation(
        location.latitude,
        location.longitude,
      );
    }

    if (!mounted) return;
    final station = widget.station;
    context.read<StationDetailBloc>().add(LoadStationDetail(station: station));
  }

  Widget _buildAppbar({
    required Widget child,
    Future<void> Function()? onRefresh,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.station.name, style: const TextStyle(fontSize: 20)),
        centerTitle: false,
      ),
      body: onRefresh != null
          ? RefreshIndicator(onRefresh: onRefresh, child: child)
          : child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StationDetailBloc, StationDetailState>(
      builder: (context, state) {
        if (state is StationDetailLoading || state is StationDetailInitial) {
          return _buildAppbar(
            child: StationDetailSkeleton(),
            onRefresh: _onLoadDetail,
          );
        }

        if (state is StationDetailError) {
          return _buildAppbar(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: EmptyPage(
                  messageError:
                      'No station found. error message: ${state.message}',
                ),
              ),
            ),
            onRefresh: _onLoadDetail,
          );
        }

        if (state is StationDetailHasData) {
          final s = state.station;
          final aqiText = s.aqi?.toString() ?? '-';
          final latText = s.latitude.toStringAsFixed(6);
          final lonText = s.longitude.toStringAsFixed(6);

          final luminance = s.status.color.computeLuminance();
          final aqiTextColor = luminance > 0.6 ? Colors.black : Colors.white;

          final locationState = context.read<LocationCubit>().state;
          final currentLat = locationState.latitude;
          final currentLng = locationState.longitude;

          final distance = calDistance(
            currentLat,
            currentLng,
            s.latitude,
            s.longitude,
          );

          return _buildAppbar(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // header section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
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
                          SizedBox(height: 8),
                          StationDistance(distance: distance),
                        ],
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

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$latText, $lonText',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12,
                                  ),
                                ),
                                if (s.time != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    fdate(s.time),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Pollutants Section
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pollutant Grid
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.8,
                            children: [
                              if (s.iaqi.pm25 != null)
                                _PollutantCard(
                                  name: 'PM2.5',
                                  value: s.iaqi.pm25!,
                                  unit: 'µg/m³',
                                  icon: Icons.grain,
                                ),
                              if (s.iaqi.pm10 != null)
                                _PollutantCard(
                                  name: 'PM10',
                                  value: s.iaqi.pm10!,
                                  unit: 'µg/m³',
                                  icon: Icons.blur_on,
                                ),
                              if (s.iaqi.o3 != null)
                                _PollutantCard(
                                  name: 'O₃',
                                  value: s.iaqi.o3!,
                                  unit: 'ppb',
                                  icon: Icons.cloud_outlined,
                                ),
                              if (s.iaqi.no2 != null)
                                _PollutantCard(
                                  name: 'NO₂',
                                  value: s.iaqi.no2!,
                                  unit: 'ppb',
                                  icon: Icons.factory_outlined,
                                ),
                              if (s.iaqi.so2 != null)
                                _PollutantCard(
                                  name: 'SO₂',
                                  value: s.iaqi.so2!,
                                  unit: 'ppb',
                                  icon: Icons.science_outlined,
                                ),
                              if (s.iaqi.t != null)
                                _PollutantCard(
                                  name: 'Temp',
                                  value: s.iaqi.t!,
                                  unit: '°C',
                                  icon: Icons.thermostat_outlined,
                                ),
                              if (s.iaqi.h != null)
                                _PollutantCard(
                                  name: 'Humidity',
                                  value: s.iaqi.h!,
                                  unit: '%',
                                  icon: Icons.water_drop_outlined,
                                ),
                              if (s.iaqi.p != null)
                                _PollutantCard(
                                  name: 'Pressure',
                                  value: s.iaqi.p!,
                                  unit: 'hPa',
                                  icon: Icons.speed,
                                ),
                            ],
                          ),

                          // LineChart section
                          if (s.dailys.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            _DailyForecastLineChart(dailys: s.dailys),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onRefresh: _onLoadDetail,
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
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
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

              // Grid section
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.8,
                children: List.generate(
                  8,
                  (index) => Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Chart section
              Container(height: 14, width: 120, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
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
      child: widget.child,
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
          child: child,
        );
      },
    );
  }
}

// Modern Pollutant Card Widget
class _PollutantCard extends StatelessWidget {
  final String name;
  final double value;
  final String unit;
  final IconData icon;

  const _PollutantCard({
    required this.name,
    required this.value,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.blue.shade700),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Daily Forecast Card Widget
class _DailyForecastCard extends StatelessWidget {
  final DailyEntity daily;

  const _DailyForecastCard({required this.daily});

  @override
  Widget build(BuildContext context) {
    final hasData = daily.avg != null || daily.min != null || daily.max != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Date Section
          Container(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  daily.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (daily.day != null)
                  Text(
                    fdate(daily.day),
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Values Section
          Expanded(
            child: hasData
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (daily.avg != null)
                        _ValueChip(
                          label: 'Avg',
                          value: daily.avg!,
                          color: Colors.blue.shade100,
                          textColor: Colors.blue.shade900,
                        ),
                      if (daily.min != null)
                        _ValueChip(
                          label: 'Min',
                          value: daily.min!,
                          color: Colors.green.shade100,
                          textColor: Colors.green.shade900,
                        ),
                      if (daily.max != null)
                        _ValueChip(
                          label: 'Max',
                          value: daily.max!,
                          color: Colors.orange.shade100,
                          textColor: Colors.orange.shade900,
                        ),
                    ],
                  )
                : Text(
                    'No data',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// Value Chip for Daily Forecast
class _ValueChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final Color textColor;

  const _ValueChip({
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: textColor.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Daily Forecast LineChart Widget
class _DailyForecastLineChart extends StatelessWidget {
  final List<DailyEntity> dailys;

  const _DailyForecastLineChart({required this.dailys});

  @override
  Widget build(BuildContext context) {
    // แยกข้อมูลตาม name (pm10, pm25, uvi)
    final pm10Data = dailys.where((d) => d.name == 'pm10').toList();
    final pm25Data = dailys.where((d) => d.name == 'pm25').toList();
    final uviData = dailys.where((d) => d.name == 'uvi').toList();

    // หาค่า max สำหรับ Y axis
    final allValues = [
      ...pm10Data.map((d) => d.avg ?? 0),
      ...pm25Data.map((d) => d.avg ?? 0),
      ...uviData.map((d) => d.avg ?? 0),
    ];
    final maxY = allValues.isEmpty
        ? 100.0
        : (allValues.reduce((a, b) => a > b ? a : b) * 1.2);

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: Colors.blue, label: 'PM2.5'),
              const SizedBox(width: 16),
              _LegendItem(color: Colors.orange, label: 'PM10'),
              const SizedBox(width: 16),
              _LegendItem(color: Colors.purple, label: 'UVI'),
            ],
          ),
          const SizedBox(height: 16),

          // Chart
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= pm25Data.length) {
                          return const SizedBox();
                        }
                        final date = pm25Data[index].day;
                        if (date == null) return const SizedBox();

                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${date.day}/${date.month}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: maxY / 5,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                    left: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                minX: 0,
                maxX: (pm25Data.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  // PM2.5 line
                  if (pm25Data.isNotEmpty)
                    LineChartBarData(
                      spots: pm25Data
                          .asMap()
                          .entries
                          .where((e) => e.value.avg != null)
                          .map(
                            (e) => FlSpot(
                              e.key.toDouble(),
                              e.value.avg!.toDouble(),
                            ),
                          )
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(alpha: 0.1),
                      ),
                    ),
                  // PM10 line
                  if (pm10Data.isNotEmpty)
                    LineChartBarData(
                      spots: pm10Data
                          .asMap()
                          .entries
                          .where((e) => e.value.avg != null)
                          .map(
                            (e) => FlSpot(
                              e.key.toDouble(),
                              e.value.avg!.toDouble(),
                            ),
                          )
                          .toList(),
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.orange.withValues(alpha: 0.1),
                      ),
                    ),
                  // UVI line
                  if (uviData.isNotEmpty)
                    LineChartBarData(
                      spots: uviData
                          .asMap()
                          .entries
                          .where((e) => e.value.avg != null)
                          .map(
                            (e) => FlSpot(
                              e.key.toDouble(),
                              e.value.avg!.toDouble(),
                            ),
                          )
                          .toList(),
                      isCurved: true,
                      color: Colors.purple,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.purple.withValues(alpha: 0.1),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
