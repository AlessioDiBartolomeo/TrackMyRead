//Servizio implementato ma non utilizzato nell'app a causa del costo per l'utilizzo dell'api, sarebbe stata utilizzata per la
//traduzione delle categorie dei libri in italiano
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<List<String>> translateGenres(List<String> genres) async {
  final apiKey = dotenv.env['GOOGLE_TRANSLATE_API_KEY'] ?? '';
  final translated = <String>[];

  for (final genre in genres) {
    final response = await http.post(
      Uri.parse('https://translation.googleapis.com/language/translate/v2?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'q': genre,
        'target': 'it', // Italian
        'format': 'text',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final translatedText = data['data']['translations'][0]['translatedText'] as String;
      translated.add(translatedText);
    } else {
      translated.add(genre); // fallback if translation fails
    }
  }

  return translated;
}
