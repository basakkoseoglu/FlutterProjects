import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:movieapp/core/constants/api_constants.dart';
import 'package:movieapp/models/movie_model.dart';

class MovieApiService {

  //popüler filmleri api den getir
  Future<List<Movie>> fetchPopularMovies({int page = 1}) async {
    final url='${ApiConstants.baseUrl}/movie/popular?api_key=${ApiConstants.apiKey}&page=$page';
    final response = await http.get(Uri.parse(url));
     if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];

      return results.map((e) => Movie.fromJson(e)).toList();
    } else {
      throw Exception('Popüler filmler yüklenemedi');
    }
  }

  //film detaylarını api den getir
  Future<Movie> fetchMovieDetail(int movieId) async {
    final url='${ApiConstants.baseUrl}/movie/$movieId?api_key=${ApiConstants.apiKey}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Movie.fromJson(data);
    } else {
      throw Exception('Film detayı yüklenemedi');
    }
  }

  //arama sonuçlarını api den getir
  Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.parse(
    '${ApiConstants.baseUrl}/search/movie?api_key=${ApiConstants.apiKey}&query=$query&language=tr-TR',
  );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];

      return results.map((e) => Movie.fromJson(e)).toList();
    } else {
      throw Exception('Arama sonuçları yüklenemedi');
    }
  }
}