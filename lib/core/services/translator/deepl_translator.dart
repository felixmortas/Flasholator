import 'package:http/http.dart' as http;
import 'dart:convert';

class DeeplTranslator {
  final String authKey = "92549361-8983-0e46-4f5f-185b786cedb0:fx";
  
  Future<String> translate(
    String textToTranslate, String targetLang, String sourceLang) async {
    String? translationResult;

    try {
      final response = await http.post(
        Uri.parse('https://api-free.deepl.com/v2/translate'),
        body: {
          'auth_key': authKey,
          'text': textToTranslate,
          'target_lang': targetLang,
          'source_lang': sourceLang,
          // 'formality': 'less',
        },
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        translationResult = json['translations'][0]['text'];
      } else {
        print('Request failed with status: ${response.statusCode}');
        translationResult = null;
      }
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack Trace: $stackTrace');
      translationResult = 'Erreur de connexion';
    }

    return translationResult ?? '';
  }
}
