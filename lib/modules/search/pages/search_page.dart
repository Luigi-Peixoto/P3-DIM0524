import 'dart:async';

import 'package:flutter/material.dart';
import 'package:p3_dim0524/modules/details/pages/details_page.dart';

import '../../home/models/movie.dart';
import '../../home/models/series.dart';
import '../repositories/search_repository.dart';

enum SearchType { movie, series }

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SearchRepository _repository = SearchRepository();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Timer? _debounce;

  SearchType _type = SearchType.movie;
  String _query = '';
  int _currentPage = 1;
  int _totalPages = 1;

  List<Movie> _movies = [];
  List<Series> _series = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.trim() == _query) return;
      _query = value.trim();
      _resetAndSearch();
    });
  }

  void _onTypeChanged(SearchType type) {
    if (type == _type) return;
    setState(() => _type = type);
    _resetAndSearch();
  }

  void _resetAndSearch() {
    setState(() {
      _movies = [];
      _series = [];
      _currentPage = 1;
      _totalPages = 1;
      _error = null;
    });
    if (_query.isNotEmpty) _fetchResults();
  }

  void _onScroll() {
    final nearBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300;

    if (nearBottom && !_isLoadingMore && _currentPage < _totalPages) {
      _fetchMore();
    }
  }

  Future<void> _fetchResults() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _repository.search(
        query: _query,
        type: _type == SearchType.movie ? 'movie' : 'tv',
        page: 1,
      );

      setState(() {
        _movies = result.movies;
        _series = result.series;
        _currentPage = 1;
        _totalPages = result.totalPages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao buscar. Tente novamente.';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMore() async {
    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final result = await _repository.search(
        query: _query,
        type: _type == SearchType.movie ? 'movie' : 'tv',
        page: nextPage,
      );

      setState(() {
        _movies.addAll(result.movies);
        _series.addAll(result.series);
        _currentPage = nextPage;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  List<dynamic> get _items => _type == SearchType.movie ? _movies : _series;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: _onSearchChanged,
          decoration: const InputDecoration(
            hintText: 'Buscar filmes ou séries...',
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _query = '';
                  _movies = [];
                  _series = [];
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Filmes'),
            selected: _type == SearchType.movie,
            onSelected: (_) => _onTypeChanged(SearchType.movie),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Séries'),
            selected: _type == SearchType.series,
            onSelected: (_) => _onTypeChanged(SearchType.series),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Digite para buscar', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchResults,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(child: Text('Nenhum resultado para "$_query"'));
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.55,
      ),
      itemCount: _items.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return const Center(child: CircularProgressIndicator());
        }

        final item = _items[index];
        final isMovie = _type == SearchType.movie;
        final id = item.id as int;
        final title = isMovie ? (item as Movie).title : (item as Series).name;
        final posterPath = item.posterPath as String;
        final voteAverage = item.voteAverage as double;

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailPage(id: id, isMovie: isMovie),
            ),
          ),
          child: _SearchCard(
            title: title,
            posterPath: posterPath,
            voteAverage: voteAverage,
          ),
        );
      },
    );
  }
}

class _SearchCard extends StatelessWidget {
  final String title;
  final String posterPath;
  final double voteAverage;

  const _SearchCard({
    required this.title,
    required this.posterPath,
    required this.voteAverage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: posterPath.isNotEmpty
                ? Image.network(
                    'https://image.tmdb.org/t/p/w500$posterPath',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, _, _) => _placeholder(),
                  )
                : _placeholder(),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        Row(
          children: [
            const Icon(Icons.star, size: 11, color: Colors.amber),
            const SizedBox(width: 2),
            Text(
              voteAverage.toStringAsFixed(1),
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade800,
      child: const Icon(Icons.movie, color: Colors.grey),
    );
  }
}
