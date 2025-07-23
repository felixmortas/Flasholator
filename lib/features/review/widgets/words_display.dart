import 'package:flutter/material.dart';

class WordsDisplay extends StatelessWidget {
  final String questionLang;
  final String questionText;
  final String responseLang;
  final String responseText;
  final bool isResponseHidden;
  final bool isDue;

  const WordsDisplay({
    Key? key,
    required this.questionLang,
    required this.questionText,
    required this.responseLang,
    required this.responseText,
    required this.isResponseHidden,
    required this.isDue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              questionLang,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Arial',
                color: Color.fromARGB(255, 238, 220, 245),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Center(
                child: Text(
                  questionText,
                  style: const TextStyle(fontSize: 18.0),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Container(height: 1.0, color: Colors.grey),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Visibility(
              visible: isDue,
              child: Text(
                responseLang,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Arial',
                  color: Color.fromARGB(255, 238, 220, 245),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Center(
                child: Visibility(
                  visible: !isResponseHidden,
                  child: Text(
                    responseText,
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
