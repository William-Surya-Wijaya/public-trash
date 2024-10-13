import 'dart:convert';
import 'package:http/http.dart' as http;

class GogoanimeService {
  static Future<List<dynamic>> searchAnime(String query) async {
    final response = await http.get(
      Uri.parse('https://gogoanime.consumet.stream/search?keyw=$query'),
    );
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load anime');
    }
  }
}
