import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pair_api/pair_api.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final AuthRepository _authRepository;
  static const String _tokenKey = 'auth_token';

  AuthService(this._authRepository);

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<bool> isHasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> isValidToken() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    final result = await _authRepository.checkToken(token);

    return result.fold(
      (failure) {
        return false;
      },
      (user) {
        return true;
      },
    );
  }
}
