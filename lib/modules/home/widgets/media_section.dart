import 'package:flutter/material.dart';

import 'media_card.dart';

class MediaSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final bool isLoading;
  final String? error;

  const MediaSection({
    super.key,
    required this.title,
    required this.items,
    this.isLoading = false,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(height: 250, child: _buildContent()),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Text(error!, style: const TextStyle(color: Colors.red)),
      );
    }

    if (items.isEmpty) {
      return const Center(child: Text('Nenhum item encontrado.'));
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return MediaCard(
          id: item['id'],
          title: item['title'],
          posterPath: item['posterPath'],
          voteAverage: item['voteAverage'],
          onTap: item['onTap'],
        );
      },
    );
  }
}
