import '../../../core/network/http_client.dart';
import '../../home/models/movie.dart';
import '../../home/models/series.dart';
import '../models/cast_member.dart';
import '../models/movie_detail.dart';
import '../models/series_detail.dart';

class DetailsRepository {
  final HttpClient _client = HttpClient();

  Future<MovieDetail> getMovieDetail(int id) async {
    final results = await Future.wait([
      _client.get('/movie/$id'),
      _client.get('/movie/$id/credits'),
      _client.get('/movie/$id/similar'),
    ]);

    final cast = (results[1]['cast'] as List)
        .take(10)
        .map((e) => CastMember.fromJson(e))
        .toList();

    final similar = (results[2]['results'] as List)
        .take(10)
        .map((e) => Movie.fromJson(e))
        .toList();

    return MovieDetail.fromJson(results[0], cast, similar);
  }

  Future<SeriesDetail> getSeriesDetail(int id) async {
    final results = await Future.wait([
      _client.get('/tv/$id'),
      _client.get('/tv/$id/credits'),
      _client.get('/tv/$id/similar'),
    ]);

    final cast = (results[1]['cast'] as List)
        .take(10)
        .map((e) => CastMember.fromJson(e))
        .toList();

    final similar = (results[2]['results'] as List)
        .take(10)
        .map((e) => Series.fromJson(e))
        .toList();

    return SeriesDetail.fromJson(results[0], cast, similar);
  }
}
