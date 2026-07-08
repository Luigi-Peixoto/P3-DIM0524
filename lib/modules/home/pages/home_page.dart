import 'package:flutter/material.dart';
import 'package:p3_dim0524/modules/details/pages/details_page.dart';
import 'package:p3_dim0524/modules/profile/pages/profile_page.dart';

import '../models/movie.dart';
import '../models/series.dart';
import '../repositories/home_repository.dart';
import '../widgets/media_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeRepository _repository = HomeRepository();

  List<Movie> _nowPlaying = [];
  List<Movie> _popularMovies = [];
  List<Movie> _topRatedMovies = [];
  List<Series> _popularSeries = [];
  List<Series> _topRatedSeries = [];

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

      final results = await Future.wait([
        _repository.getNowPlaying(),
        _repository.getPopularMovies(),
        _repository.getTopRatedMovies(),
        _repository.getPopularSeries(),
        _repository.getTopRatedSeries(),
      ]);

      setState(() {
        _nowPlaying = results[0] as List<Movie>;
        _popularMovies = results[1] as List<Movie>;
        _topRatedMovies = results[2] as List<Movie>;
        _popularSeries = results[3] as List<Series>;
        _topRatedSeries = results[4] as List<Series>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar dados. Tente novamente.';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _moviesToItems(List<Movie> movies) {
    return movies
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
        .toList();
  }

  List<Map<String, dynamic>> _seriesToItems(List<Series> series) {
    return series
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
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CineApp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {}, // navegação para busca depois
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
          ),
        ],
      ),
      body: _error != null
          ? Center(
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
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    MediaSection(
                      title: 'Em Cartaz',
                      items: _moviesToItems(_nowPlaying),
                      isLoading: _isLoading,
                    ),
                    MediaSection(
                      title: 'Filmes Populares',
                      items: _moviesToItems(_popularMovies),
                      isLoading: _isLoading,
                    ),
                    MediaSection(
                      title: 'Filmes Mais Bem Avaliados',
                      items: _moviesToItems(_topRatedMovies),
                      isLoading: _isLoading,
                    ),
                    MediaSection(
                      title: 'Séries Populares',
                      items: _seriesToItems(_popularSeries),
                      isLoading: _isLoading,
                    ),
                    MediaSection(
                      title: 'Séries Mais Bem Avaliadas',
                      items: _seriesToItems(_topRatedSeries),
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}
