import 'dart:convert';
import 'package:flutter_library_app/data/model/google_book_model.dart';
import 'package:http/http.dart' as http;

class GoogleBooksService {
  static const _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  static Future<GoogleBookModel?> fetchBookByISBN(String isbn) async {
    final url = Uri.parse('$_baseUrl?q=isbn:$isbn');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['totalItems'] > 0) {
        return GoogleBookModel.fromJson(data['items'][0]['volumeInfo']);
      }
    }
    return null;
  }
}
