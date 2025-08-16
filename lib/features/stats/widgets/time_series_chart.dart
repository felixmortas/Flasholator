import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:flasholator/core/models/stats_model.dart';
import 'package:flasholator/l10n/app_localizations.dart';

class TimeSeriesChart extends StatefulWidget {
  final StatsData data;

  const TimeSeriesChart({Key? key, required this.data}) : super(key: key);

  @override
  State<TimeSeriesChart> createState() => _TimeSeriesChartState();
}

class _TimeSeriesChartState extends State<TimeSeriesChart> {
  TimeGranularity _selectedGranularity = TimeGranularity.daily;

  @override
  Widget build(BuildContext context) {
    final aggregatedData = widget.data.aggregate(_selectedGranularity);
    final minY = aggregatedData.isNotEmpty
    ? aggregatedData
        .map((e) => e.count)
        .reduce((a, b) => a < b ? a : b)
        .toDouble()
    : 0.0;

final maxY = aggregatedData.isNotEmpty
    ? aggregatedData
        .map((e) => e.count)
        .reduce((a, b) => a > b ? a : b)
        .toDouble()
    : 1.0;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.addedWords,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ToggleButtons(
              isSelected: [
                _selectedGranularity == TimeGranularity.daily,
                _selectedGranularity == TimeGranularity.weekly,
                _selectedGranularity == TimeGranularity.monthly,
                _selectedGranularity == TimeGranularity.yearly,
              ],
              onPressed: (index) {
                setState(() {
                  _selectedGranularity = TimeGranularity.values[index];
                });
              },
              children: [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(AppLocalizations.of(context)!.day)),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(AppLocalizations.of(context)!.week)),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(AppLocalizations.of(context)!.month)),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(AppLocalizations.of(context)!.year)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LayoutBuilder(builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  child: LineChart(
                    LineChartData(
                      minY: minY,
                      maxY: maxY,
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                final allX = aggregatedData
                                    .map((e) => e.date.millisecondsSinceEpoch.toDouble())
                                    .toList();

                                final minX = allX.isEmpty ? 0 : allX.reduce((a, b) => a < b ? a : b);
                                final maxX = allX.isEmpty ? 0 : allX.reduce((a, b) => a > b ? a : b);

                                // Ne pas afficher les labels pour min et max X
                                if (value == minX || value == maxX) {
                                  return Container();
                                }

                                final date =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        value.toInt());
                                String label;
                                switch (_selectedGranularity) {
                                  case TimeGranularity.daily:
                                    label = '${date.day}/${date.month}';
                                    break;
                                  case TimeGranularity.weekly:
                                    label =
                                        'S${_weekNumber(date)} ${date.year}';
                                    break;
                                  case TimeGranularity.monthly:
                                    label = '${date.month}/${date.year}';
                                    break;
                                  case TimeGranularity.yearly:
                                    label = '${date.year}';
                                    break;
                                }

                                return Transform.rotate(
                                  angle: -0.6,
                                  child: Text(label,
                                      style: TextStyle(fontSize: 10)),
                                );
                              }),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30, // augmenter la place réservée
                            getTitlesWidget: (value, _) {
                              // Ne pas afficher min et max pour éviter chevauchement
                              if (value == minY || value == maxY) {
                                return Container();
                              }
                              return Text(
                                value.toInt().toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: aggregatedData
                              .map((e) => FlSpot(
                                    e.date.millisecondsSinceEpoch.toDouble(),
                                    e.count.toDouble(),
                                  ))
                              .toList(),
                          isCurved: false,
                          color: Colors.blue,
                          barWidth: 4,
                          belowBarData: BarAreaData(
                              show: true, color: Colors.blue.withOpacity(0.3)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  int _weekNumber(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    return ((date.difference(firstDay).inDays + firstDay.weekday) / 7).ceil();
  }
}
