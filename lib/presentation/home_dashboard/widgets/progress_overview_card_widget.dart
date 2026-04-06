import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ProgressOverviewCardWidget extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyMoodData;
  final VoidCallback onTap;

  const ProgressOverviewCardWidget({
    super.key,
    required this.weeklyMoodData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomIconWidget(
                        iconName: 'trending_up',
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progress Overview',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Weekly mood trends',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CustomIconWidget(
                      iconName: 'arrow_forward_ios',
                      color: colorScheme.primary,
                      size: 16,
                    ),
                  ],
                ),

                SizedBox(height: 3.h),

                // Chart Container
                Container(
                  width: double.infinity,
                  height: 25.h,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: weeklyMoodData.isNotEmpty
                      ? _buildMoodChart(context)
                      : _buildEmptyState(context),
                ),

                SizedBox(height: 3.h),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        icon: 'calendar_today',
                        label: 'This Week',
                        value: '${weeklyMoodData.length}/7',
                        color: colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        icon: 'mood',
                        label: 'Avg Mood',
                        value: _calculateAverageMood(),
                        color: colorScheme.tertiary,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    // Expanded(
                    //   child: _buildStatItem(
                    //     context,
                    //     icon: 'insights',
                    //     label: 'Trend',
                    //     value: _getMoodTrend(),
                    //     color: _getTrendColor(colorScheme),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodChart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: colorScheme.outline.withValues(alpha: 0.2),
              strokeWidth: 1,
            );
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
              getTitlesWidget: (double value, TitleMeta meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      days[value.toInt()],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10.sp,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 28,
              getTitlesWidget: (double value, TitleMeta meta) {
                const moods = ['😢', '😔', '😐', '😊', '😄'];
                if (value.toInt() >= 1 && value.toInt() <= 5) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      moods[value.toInt() - 1],
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        minX: 0,
        maxX: 6,
        minY: 1,
        maxY: 5,
        lineBarsData: [
          LineChartBarData(
            spots: _generateSpots(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.tertiary,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: colorScheme.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.2),
                  colorScheme.primary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'insights',
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No mood data yet',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Start tracking your mood to see progress',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, {
        required String icon,
        required String label,
        required String value,
        required Color color,
      }) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: color,
            size: 20,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.8),
              fontSize: 10.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateSpots() {
    List<FlSpot> spots = [];
    for (int i = 0; i < weeklyMoodData.length && i < 7; i++) {
      final moodValue = (weeklyMoodData[i]['value'] as int).toDouble();
      spots.add(FlSpot(i.toDouble(), moodValue));
    }

    // Fill remaining days with null data if needed
    if (spots.isEmpty) {
      // Default data for demo
      spots = [
        const FlSpot(0, 3),
        const FlSpot(1, 4),
        const FlSpot(2, 3.5),
        const FlSpot(3, 4.5),
        const FlSpot(4, 4),
        const FlSpot(5, 3.8),
        const FlSpot(6, 4.2),
      ];
    }

    return spots;
  }

  String _calculateAverageMood() {
    if (weeklyMoodData.isEmpty) return '😐';

    final sum = weeklyMoodData.fold<int>(
      0,
          (sum, mood) => sum + (mood['value'] as int),
    );
    final average = sum / weeklyMoodData.length;

    if (average >= 4.5) return '😄';
    if (average >= 3.5) return '😊';
    if (average >= 2.5) return '😐';
    if (average >= 1.5) return '😔';
    return '😢';
  }

  String _getMoodTrend() {
    if (weeklyMoodData.length < 2) return '→';

    final firstHalf = weeklyMoodData
        .take(weeklyMoodData.length ~/ 2)
        .fold<int>(0, (sum, mood) => sum + (mood['value'] as int)) /
        (weeklyMoodData.length ~/ 2);

    final secondHalf = weeklyMoodData
        .skip(weeklyMoodData.length ~/ 2)
        .fold<int>(0, (sum, mood) => sum + (mood['value'] as int)) /
        (weeklyMoodData.length - weeklyMoodData.length ~/ 2);

    if (secondHalf > firstHalf + 0.3) return '↗';
    if (secondHalf < firstHalf - 0.3) return '↘';
    return '→';
  }

  Color _getTrendColor(ColorScheme colorScheme) {
    final trend = _getMoodTrend();
    switch (trend) {
      case '↗':
        return const Color(0xFF7A9B76); // Success green
      case '↘':
        return const Color(0xFFB85C5C); // Warning red
      default:
        return colorScheme.onSurfaceVariant;
    }
  }
}
