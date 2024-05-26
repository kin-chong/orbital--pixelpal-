import 'package:http/http.dart' as http;
import 'dart:convert';

class MovieService {
  static const String apiKey =
      '8945cfc7ae54a1979ef2afea7ef4f443'; // Replace with your TMDb API key
  static const String baseUrl = 'https://api.themoviedb.org/3';

  Future<List<dynamic>> fetchUpcomingMovies() async {
    final response = await http.get(Uri.parse(
        '$baseUrl/movie/upcoming?api_key=$apiKey&language=en-US&page=1'));

    if (response.statusCode == 200) {
      return json.decode(response.body)['results'];
    } else {
      throw Exception('Failed to load upcoming movies');
    }
  }
}
