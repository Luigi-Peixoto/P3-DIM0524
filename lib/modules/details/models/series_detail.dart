import '../../home/models/series.dart';
import 'cast_member.dart';

class SeriesDetail {
  final int id;
  final String name;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final String firstAirDate;
  final int episodeRuntime;
  final List<String> genres;
  final List<CastMember> cast;
  final List<Series> similar;

  SeriesDetail({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.firstAirDate,
    required this.episodeRuntime,
    required this.genres,
    required this.cast,
    required this.similar,
  });

  factory SeriesDetail.fromJson(
    Map<String, dynamic> json,
    List<CastMember> cast,
    List<Series> similar,
  ) {
    final runtimes = json['episode_run_time'] as List;

    return SeriesDetail(
      id: json['id'],
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteAverage: (json['vote_average'] as num).toDouble(),
      firstAirDate: json['first_air_date'] ?? '',
      episodeRuntime: runtimes.isNotEmpty ? runtimes[0] : 0,
      genres: (json['genres'] as List).map((g) => g['name'] as String).toList(),
      cast: cast,
      similar: similar,
    );
  }
}
