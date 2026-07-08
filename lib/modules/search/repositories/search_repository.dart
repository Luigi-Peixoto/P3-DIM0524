import '../../../core/network/http_client.dart';
import '../../home/models/movie.dart';
import '../../home/models/series.dart';

class SearchRepository {
  final HttpClient _client = HttpClient();

  Future<({List<Movie> movies, List<Series> series, int totalPages})> search({
    required String query,
    required String type,
    required int page,
  }) async {
    final data = await _client.get(
      '/search/$type',
      queryParams: {'query': query, 'page': '$page'},
    );

    final totalPages = data['total_pages'] as int;

    if (type == 'movie') {
      final movies = (data['results'] as List)
          .map((e) => Movie.fromJson(e))
          .toList();
      return (movies: movies, series: <Series>[], totalPages: totalPages);
    } else {
      final series = (data['results'] as List)
          .map((e) => Series.fromJson(e))
          .toList();
      return (movies: <Movie>[], series: series, totalPages: totalPages);
    }
  }
}
