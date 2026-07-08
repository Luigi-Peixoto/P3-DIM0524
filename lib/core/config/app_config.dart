import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl => dotenv.env['TMDB_BASE_URL']!;
  static String get apiKey => dotenv.env['TMDB_API_KEY']!;
  static String get imageBaseUrl => dotenv.env['TMDB_IMAGE_BASE_URL']!;
  static String get language => dotenv.env['TMDB_LANGUAGE'] ?? 'pt-BR';
}
