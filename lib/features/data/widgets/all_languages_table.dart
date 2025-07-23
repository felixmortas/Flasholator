import '../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class AllLanguagesTable extends StatelessWidget {
  final List<Map<dynamic, dynamic>> data;
  final Function(Map<dynamic, dynamic>)
      onCellTap; // Modified to accept the entire row
  final Map<String, String> languages;

  const AllLanguagesTable({
    super.key,
    required this.data,
    required this.onCellTap,
    required this.languages,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: [
          DataColumn(label: Text(AppLocalizations.of(context)!.source)),
          DataColumn(label: Text(AppLocalizations.of(context)!.word)),
          DataColumn(label: Text(AppLocalizations.of(context)!.translation)),
          DataColumn(label: Text(AppLocalizations.of(context)!.target)),
        ],
        rows: data.map((rowData) {
          return DataRow(cells: [
            DataCell(Text(languages[rowData['sourceLang']] ??
                'Unknown')), // Modified to use 'sourceLanguage'
            DataCell(GestureDetector(
              onTap: () =>
                  onCellTap(rowData), // Modified to pass the entire row
              child: Text(rowData['front']), // Modified to use 'word'
            )),
            DataCell(GestureDetector(
              onTap: () =>
                  onCellTap(rowData), // Modified to pass the entire row
              child: Text(rowData['back']), // Modified to use 'translation'
            )),
            DataCell(Text(languages[rowData['targetLang']] ??
                'Unknown')), // Modified to use 'targetLanguage'
          ]);
        }).toList(),
      ),
    );
  }
}
