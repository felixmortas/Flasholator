import 'package:flutter/material.dart';

class CoupleLanguagesTable extends StatelessWidget {
  final List<Map<dynamic, dynamic>> data;
  final String sourceLanguage;
  final String targetLanguage;
  final Function(Map<dynamic, dynamic>) onCellTap;

  const CoupleLanguagesTable({
    super.key,
    required this.data,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
      children: [
        // Header
        Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
          Expanded(
            child: Text(
            sourceLanguage,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'MomoSignature',
            ),
            textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
            targetLanguage,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'MomoSignature',
            ),
            textAlign: TextAlign.center,
            ),
          ),
          ],
        ),
        ),
        // Post-it cards
        ...data.map((rowData) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: GestureDetector(
          onTap: () => onCellTap(rowData),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
            color: Colors.yellow[200],
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(2, 2),
              ),
            ],
            ),
            child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
              Expanded(
                child: Text(
                rowData['front'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.yellow[700],
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: Text(
                rowData['back'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ],
            ),
            ),
          ),
          ),
        );
        }).toList(),
      ],
      ),
    );
  }
}