import '../../../core/network/http_client.dart';
import '../models/movie.dart';
import '../models/series.dart';

class HomeRepository {
  final HttpClient _client = HttpClient();

  Future<List<Movie>> getNowPlaying() async {
    final data = await _client.get('/movie/now_playing');
    return (data['results'] as List).map((e) => Movie.fromJson(e)).toList();
  }

  Future<List<Movie>> getPopularMovies() async {
    final data = await _client.get('/movie/popular');
    return (data['results'] as List).map((e) => Movie.fromJson(e)).toList();
  }

  Future<List<Movie>> getTopRatedMovies() async {
    final data = await _client.get('/movie/top_rated');
    return (data['results'] as List).map((e) => Movie.fromJson(e)).toList();
  }

  Future<List<Series>> getPopularSeries() async {
    final data = await _client.get('/tv/popular');
    return (data['results'] as List).map((e) => Series.fromJson(e)).toList();
  }

  Future<List<Series>> getTopRatedSeries() async {
    final data = await _client.get('/tv/top_rated');
    return (data['results'] as List).map((e) => Series.fromJson(e)).toList();
  }
}
