import 'package:flutter/material.dart';
import 'package:pair_app/core/core.dart';

class StationDistance extends StatelessWidget {
  const StationDistance({
    super.key,
    required this.distance,
  });
  final double distance;
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {

        String distText = distanceText(distance);
        final Color chipColor = Colors.grey;

        final textColor = chipColor.computeLuminance() > 0.6
            ? Colors.black
            : Colors.white;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: chipColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: chipColor.withValues(alpha: .18),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                distText,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
