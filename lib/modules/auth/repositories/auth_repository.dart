import '../../../core/network/http_client.dart';

class AuthException implements Exception {
  final String message;

  AuthException(this.message);
}

class AuthRepository {
  final HttpClient _client = HttpClient();

  Future<String> login(String username, String password) async {
    try {
      final tokenData = await _client.get('/authentication/token/new');
      final requestToken = tokenData['request_token'] as String;

      final validated = await _client.post(
        '/authentication/token/validate_with_login',
        body: {
          'username': username,
          'password': password,
          'request_token': requestToken,
        },
      );

      if (validated['success'] != true) {
        throw AuthException(
          validated['status_message'] as String? ??
              'Usuário ou senha inválidos.',
        );
      }

      final sessionData = await _client.post(
        '/authentication/session/new',
        body: {'request_token': validated['request_token']},
      );

      if (sessionData['success'] != true) {
        throw AuthException(
          'Não foi possível criar a sessão. Tente novamente.',
        );
      }

      return sessionData['session_id'] as String;
    } on AuthException {
      rethrow;
    } catch (_) {
      throw AuthException(
        'Erro de conexão. Verifique sua internet e tente novamente.',
      );
    }
  }

  Future<String> getAccountUsername(String sessionId) async {
    try {
      final data = await _client.get(
        '/account',
        queryParams: {'session_id': sessionId},
      );
      final username = data['username'] as String?;
      return (username != null && username.isNotEmpty) ? username : 'Usuário';
    } catch (_) {
      return 'Usuário';
    }
  }
}
