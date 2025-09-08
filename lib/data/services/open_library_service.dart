import 'dart:convert';
import 'package:flutter_library_app/data/model/open_library_model.dart';
import 'package:http/http.dart' as http;

class OpenLibraryService {
  static Future<OpenLibraryBookModel?> fetchBookByISBN(String isbn) async {
    final url = Uri.parse('https://openlibrary.org/isbn/$isbn.json');
    final response = await http.get(url);

    if (response.statusCode != 200) return null;

    final data = json.decode(response.body) as Map<String, dynamic>;
    return OpenLibraryBookModel.fromJson(data);
  }
}
