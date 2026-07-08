import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../home/models/movie.dart';
import '../../home/models/series.dart';
import '../../home/widgets/media_section.dart';
import '../models/cast_member.dart';
import '../models/movie_detail.dart';
import '../models/series_detail.dart';
import '../repositories/details_repository.dart';
import '../widgets/cast_card.dart';

class DetailPage extends StatefulWidget {
  final int id;
  final bool isMovie;

  const DetailPage({super.key, required this.id, required this.isMovie});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final DetailsRepository _repository = DetailsRepository();

  MovieDetail? _movieDetail;
  SeriesDetail? _seriesDetail;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      if (widget.isMovie) {
        final detail = await _repository.getMovieDetail(widget.id);
        setState(() {
          _movieDetail = detail;
          _isLoading = false;
        });
      } else {
        final detail = await _repository.getSeriesDetail(widget.id);
        setState(() {
          _seriesDetail = detail;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar detalhes. Tente novamente.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_error!),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isMovie && _movieDetail != null) {
      return _buildMovieContent(_movieDetail!);
    } else if (!widget.isMovie && _seriesDetail != null) {
      return _buildSeriesContent(_seriesDetail!);
    }
    return const SizedBox();
  }

  Widget _buildMovieContent(MovieDetail movie) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(
          backdropPath: movie.backdropPath,
          posterPath: movie.posterPath,
          title: movie.title,
          year: movie.releaseDate.isNotEmpty
              ? movie.releaseDate.substring(0, 4)
              : '',
          runtime: '${movie.runtime} min',
          voteAverage: movie.voteAverage,
          genres: movie.genres,
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverview(movie.overview),
              _buildCastSection(movie.cast),
              _buildSimilarMovies(movie.similar),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeriesContent(SeriesDetail series) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(
          backdropPath: series.backdropPath,
          posterPath: series.posterPath,
          title: series.name,
          year: series.firstAirDate.isNotEmpty
              ? series.firstAirDate.substring(0, 4)
              : '',
          runtime: series.episodeRuntime > 0
              ? '${series.episodeRuntime} min/ep'
              : '',
          voteAverage: series.voteAverage,
          genres: series.genres,
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverview(series.overview),
              _buildCastSection(series.cast),
              _buildSimilarSeries(series.similar),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildAppBar({
    required String backdropPath,
    required String posterPath,
    required String title,
    required String year,
    required String runtime,
    required double voteAverage,
    required List<String> genres,
  }) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            backdropPath.isNotEmpty
                ? Image.network(
                    '${AppConfig.imageBaseUrl}$backdropPath',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        Container(color: Colors.grey.shade800),
                  )
                : Container(color: Colors.grey.shade800),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: posterPath.isNotEmpty
                        ? Image.network(
                            '${AppConfig.imageBaseUrl}$posterPath',
                            height: 120,
                            width: 80,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 120,
                            width: 80,
                            color: Colors.grey.shade700,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (year.isNotEmpty)
                              Text(
                                year,
                                style: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontSize: 13,
                                ),
                              ),
                            if (runtime.isNotEmpty) ...[
                              Text(
                                '  •  $runtime',
                                style: TextStyle(
                                  color: Colors.grey.shade300,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: genres
                              .take(3)
                              .map(
                                (g) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    g,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview(String overview) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sinopse',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            overview.isNotEmpty ? overview : 'Sinopse não disponível.',
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildCastSection(List<CastMember> cast) {
    if (cast.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Elenco Principal',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: cast.length,
            itemBuilder: (context, index) => CastCard(member: cast[index]),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSimilarMovies(List<Movie> movies) {
    if (movies.isEmpty) return const SizedBox();

    return MediaSection(
      title: 'Filmes Similares',
      items: movies
          .map(
            (m) => {
              'id': m.id,
              'title': m.title,
              'posterPath': m.posterPath,
              'voteAverage': m.voteAverage,
              'onTap': () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailPage(id: m.id, isMovie: true),
                ),
              ),
            },
          )
          .toList(),
    );
  }

  Widget _buildSimilarSeries(List<Series> series) {
    if (series.isEmpty) return const SizedBox();

    return MediaSection(
      title: 'Séries Similares',
      items: series
          .map(
            (s) => {
              'id': s.id,
              'title': s.name,
              'posterPath': s.posterPath,
              'voteAverage': s.voteAverage,
              'onTap': () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailPage(id: s.id, isMovie: false),
                ),
              ),
            },
          )
          .toList(),
    );
  }
}
