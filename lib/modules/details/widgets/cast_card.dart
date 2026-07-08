import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../models/cast_member.dart';

class CastCard extends StatelessWidget {
  final CastMember member;

  const CastCard({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(45),
            child: member.profilePath.isNotEmpty
                ? Image.network(
                    '${AppConfig.imageBaseUrl}${member.profilePath}',
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          const SizedBox(height: 6),
          Text(
            member.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
          Text(
            member.character,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: Colors.grey),
    );
  }
}
