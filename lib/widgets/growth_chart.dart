import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';

/// Dual-line growth chart for a specimen's weight/size history. Weight
/// (grams) and size (millimetres) are plotted on one shared Y axis/value
/// range rather than each getting its own scale.
class GrowthChart extends StatelessWidget {
  const GrowthChart({super.key, required this.measurements});

  final List<SpecimenMeasurement> measurements;

  @override
  Widget build(BuildContext context) {
    final weightPoints = [
      for (final m in measurements)
        if (m.weightGrams != null) MapEntry(m.timestamp, m.weightGrams!),
    ];
    final sizePoints = [
      for (final m in measurements)
        if (m.sizeMm != null) MapEntry(m.timestamp, m.sizeMm!),
    ];
    if (weightPoints.isEmpty && sizePoints.isEmpty) {
      return const SizedBox.shrink();
    }

    final allTimestamps = [for (final m in measurements) m.timestamp];
    final minTime = allTimestamps.reduce((a, b) => a.isBefore(b) ? a : b);
    final maxTime = allTimestamps.reduce((a, b) => a.isAfter(b) ? a : b);
    final totalSpanMinutes =
        maxTime.difference(minTime).inMinutes.toDouble();

    double xFor(DateTime t) => totalSpanMinutes == 0
        ? 0.5
        : t.difference(minTime).inMinutes.toDouble() / totalSpanMinutes;

    final sharedRange = _Range.of([
      ...weightPoints.map((e) => e.value),
      ...sizePoints.map((e) => e.value),
    ]);

    final weightColor = Theme.of(context).colorScheme.primary;
    final sizeColor = Theme.of(context).colorScheme.tertiary;

    final weightSpots = [
      for (final p in weightPoints) FlSpot(xFor(p.key), p.value),
    ];
    final sizeSpots = [
      for (final p in sizePoints) FlSpot(xFor(p.key), p.value),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (weightPoints.isNotEmpty) ...[
              _LegendDot(color: weightColor, label: 'Weight (g)'),
              const SizedBox(width: 16),
            ],
            if (sizePoints.isNotEmpty)
              _LegendDot(color: sizeColor, label: 'Size (mm)'),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minY: sharedRange.min,
              maxY: sharedRange.max,
              minX: 0,
              maxX: 1,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => [
                    for (final spot in spots)
                      if (spot.barIndex == 0 && weightPoints.isNotEmpty)
                        LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)} g',
                          TextStyle(color: weightColor),
                        )
                      else if (sizePoints.isNotEmpty)
                        LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)} mm',
                          TextStyle(color: sizeColor),
                        ),
                  ],
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    interval: 0.2499,
                    getTitlesWidget: (value, meta) {
                      final date = minTime.add(
                          Duration(minutes: (value * totalSpanMinutes).round()));
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(DateFormat.Md().format(date),
                            style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(
                      value.toStringAsFixed(0),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineBarsData: [
                if (weightSpots.isNotEmpty)
                  LineChartBarData(
                    spots: weightSpots,
                    isCurved: false,
                    color: weightColor,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: true),
                  ),
                if (sizeSpots.isNotEmpty)
                  LineChartBarData(
                    spots: sizeSpots,
                    isCurved: false,
                    color: sizeColor,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: true),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Range {
  _Range(this.min, this.max);

  final double min;
  final double max;

  static _Range of(Iterable<double> values) {
    if (values.isEmpty) return _Range(0, 1);
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    if (minV == maxV) return _Range(minV - 1, maxV + 1);
    return _Range(minV, maxV);
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
