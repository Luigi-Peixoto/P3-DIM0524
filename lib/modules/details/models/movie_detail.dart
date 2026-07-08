import '../../home/models/movie.dart';
import 'cast_member.dart';

class MovieDetail {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final String releaseDate;
  final int runtime;
  final List<String> genres;
  final List<CastMember> cast;
  final List<Movie> similar;

  MovieDetail({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.runtime,
    required this.genres,
    required this.cast,
    required this.similar,
  });

  factory MovieDetail.fromJson(
    Map<String, dynamic> json,
    List<CastMember> cast,
    List<Movie> similar,
  ) {
    return MovieDetail(
      id: json['id'],
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteAverage: (json['vote_average'] as num).toDouble(),
      releaseDate: json['release_date'] ?? '',
      runtime: json['runtime'] ?? 0,
      genres: (json['genres'] as List).map((g) => g['name'] as String).toList(),
      cast: cast,
      similar: similar,
    );
  }
}
