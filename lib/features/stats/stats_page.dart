import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/models/stats_model.dart';
import '../../core/services/flashcards_collection.dart';
import '../../core/services/stats_service.dart';
import 'widgets/date_time_picker.dart';

class StatsPage extends StatefulWidget {
  final FlashcardsCollection flashcardsCollection;

  const StatsPage({Key? key, required this.flashcardsCollection})
      : super(key: key);

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  DateTime? _startDate;
  late DateTime _endDate;
  late Future<StatsData> _statsFuture;

  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now();
    _initializeDateRange();
  }

  Future<void> _initializeDateRange() async {
    final flashcards = await widget.flashcardsCollection.loadAllFlashcards();
    final dates = flashcards
        .map((f) => DateTime.tryParse(f.addedDate))
        .where((d) => d != null)
        .cast<DateTime>()
        .toList();

    if (dates.isEmpty) {
      // Valeur de repli : 30 jours avant aujourd'hui
      _startDate = _endDate.subtract(const Duration(days: 30));
    } else {
      dates.sort();
      _startDate = dates.first;
    }

    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _statsFuture = StatsService(widget.flashcardsCollection)
          .calculateStats(startDate: _startDate!, endDate: _endDate);
    });
  }

  void _onStartDateChanged(DateTime newDate) {
    if (newDate.isAfter(_endDate)) return;
    _startDate = newDate;
    _loadStats();
  }

  void _onEndDateChanged(DateTime newDate) {
    if (newDate.isBefore(_startDate!)) return;
    _endDate = newDate;
    _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    if (_startDate == null || _statsFuture == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DateRangePickerRow(
              startDate: _startDate!,
              endDate: _endDate,
              onStartDateChanged: _onStartDateChanged,
              onEndDateChanged: _onEndDateChanged,
            ),
          ),
          Expanded(
            child: FutureBuilder<StatsData>(
              future: _statsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }
                final data = snapshot.data!;
                return _StatsView(data: data);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsView extends StatelessWidget {
  final StatsData data;

  const _StatsView({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummarySection(),
          const SizedBox(height: 24),
          _buildTimeSeriesChart(),
          const SizedBox(height: 24),
          _buildRankingSection(),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryItem('Mots ajoutés', data.totalWords),
            _buildSummaryItem('Paires de langues', data.totalPairs),
            _buildSummaryItem(
                'Moyenne/jour', data.dailyAverage.toStringAsFixed(2)),
            _buildSummaryItem(
                'Moyenne/semaine', data.weeklyAverage.toStringAsFixed(2)),
            _buildSummaryItem(
                'Moyenne/mois', data.monthlyAverage.toStringAsFixed(2)),
            _buildSummaryItem(
                'Moyenne/an', data.yearlyAverage.toStringAsFixed(2)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value.toString(), style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildTimeSeriesChart() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ajout de mots par jour',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                              value.toInt());
                          return Text('${date.day}/${date.month}');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.dailySeries
                          .map((e) => FlSpot(
                                e.date.millisecondsSinceEpoch.toDouble(),
                                e.count.toDouble(),
                              ))
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRankingCard('Plus révisés', data.mostReviewed),
        const SizedBox(height: 16),
        _buildRankingCard('Succès consécutifs', data.mostSuccessful),
        const SizedBox(height: 16),
        _buildRankingCard('Mots les plus faciles', data.easiest),
      ],
    );
  }

  Widget _buildRankingCard(String title, List<RankingItem> items) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(2),
              },
              children: [
                const TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('Mot',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('Valeur',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('Langues',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                ...items.map((item) => TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(item.word),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(item.value.toString()),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(item.languagePair),
                        ),
                      ],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
