import 'package:flutter/material.dart';
import 'package:flasholator/features/flashcards/application/flashcard_collection_projections.dart';

class AllLanguagesTable extends StatelessWidget {
  final List<FlashcardTablePair> data;
  final ValueChanged<FlashcardTablePair> onCellTap;
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
      child: Column(
        children: [
          // Post-it cards
          ...data.map((rowData) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                        // Colonne 1 : Langue source + mot source
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                languages[rowData.card.sourceLang] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                rowData.card.front,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Séparateur
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.yellow[700],
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        // Colonne 2 : Langue cible + traduction
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                languages[rowData.card.targetLang] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                rowData.card.back,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
