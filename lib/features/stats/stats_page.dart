import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flasholator/core/models/stats_model.dart';
import 'package:flasholator/core/services/flashcards_collection.dart';
import 'package:flasholator/core/services/stats_service.dart';
import 'package:flasholator/features/stats/widgets/date_time_picker.dart';
import 'package:flasholator/features/stats/widgets/summary_section.dart';
import 'package:flasholator/features/stats/widgets/time_series_chart.dart';
import 'package:flasholator/features/stats/widgets/ranking_section.dart';

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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.statistics)),
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
                  return Center(
                      child: Text(
                          '${AppLocalizations.of(context)!.error}: ${snapshot.error}'));
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
          SummarySection(data: data),
          const SizedBox(height: 24),
          TimeSeriesChart(data: data),
          const SizedBox(height: 24),
          RankingSection(data: data),
        ],
      ),
    );
  }
}
