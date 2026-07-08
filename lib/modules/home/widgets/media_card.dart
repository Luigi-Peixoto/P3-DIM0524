import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';

class MediaCard extends StatelessWidget {
  final int id;
  final String title;
  final String posterPath;
  final double voteAverage;
  final VoidCallback? onTap;

  const MediaCard({
    super.key,
    required this.id,
    required this.title,
    required this.posterPath,
    required this.voteAverage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: posterPath.isNotEmpty
                  ? Image.network(
                      '${AppConfig.imageBaseUrl}$posterPath',
                      height: 180,
                      width: 130,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.star, size: 12, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  voteAverage.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 180,
      width: 130,
      color: Colors.grey.shade800,
      child: const Icon(Icons.movie, color: Colors.grey),
    );
  }
}
