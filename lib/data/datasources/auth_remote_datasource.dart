
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dio/dio.dart';
import 'package:pair_app/core/core.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>?> login(String username, String password);
  Future<Map<String, dynamic>?> verifyToken(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final String googleSheetId;
  final String jwtSecretKey;

  AuthRemoteDataSourceImpl({
    required this.googleSheetId,
    required this.jwtSecretKey,
  });

  @override
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await _fetchSheetCsv();

      if (response != null && response.statusCode == 200) {
        final csvData = response.data as String;
        final lines = csvData.split('\n');

        if (lines.isEmpty) {
          log('❌ No data found in Google Sheets');
          return null;
        }

        for (var i = 1; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;

          final row = line.split(',');

          if (row.length >= 3) {
            final sheetUsername = row[1].trim();
            final sheetPassword = row[2].trim();

            if (sheetUsername == username && sheetPassword == password) {
              final jwt = JWT({
                'username': username,
                'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
                'exp':
                    DateTime.now()
                        .add(const Duration(days: 7))
                        .millisecondsSinceEpoch ~/
                    1000,
              });

              final token = jwt.sign(SecretKey(jwtSecretKey));

              return {'username': username, 'token': token};
            }
          }
        }

        log('❌ Invalid credentials - User not found in Google Sheets');
        return null;
      } else {
        log('❌ Google Sheets API error or fetch failed');
        return null;
      }
    } catch (e) {
      log('❌ Unexpected error: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> verifyToken(String token) async {
    try {
      // ถอดรหัส JWT
      final jwt = JWT.verify(token, SecretKey(jwtSecretKey));

      final username = jwt.payload['username'] as String?;
      if (username == null) {
        log('❌ JWT payload missing username');
        return null;
      }

      final response = await _fetchSheetCsv();

      if (response != null && response.statusCode == 200) {
        final csvData = response.data as String;
        final lines = csvData.split('\n');

        for (var i = 1; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;

          final row = line.split(',');
          if (row.length >= 3) {
            final sheetUsername = row[1].trim();

            if (sheetUsername == username) {
              log('✅ User verified: $username');
              return {'username': username, 'token': token};
            }
          }
        }

        log('❌ User not found in Google Sheets: $username');
        return null;
      }

      log('❌ Google Sheets API error or fetch failed');
      return null;
    } on JWTExpiredException {
      log('❌ JWT token expired');
      return null;
    } on JWTException catch (e) {
      log('❌ JWT verification failed: ${e.message}');
      return null;
    } catch (e) {
      log('❌ Token verification error: $e');
      return null;
    }
  }

  Future<Response<dynamic>?> _fetchSheetCsv() async {
    final sheetId = googleSheetId;

    if (sheetId.isEmpty) {
      log('❌ Google Sheet ID not found in .env');
      return null;
    }

    final dio = DioService(baseUrl: 'https://docs.google.com');

    try {
      final path = '/spreadsheets/d/$sheetId/export';
      final queryParameters = {'format': 'csv', 'gid': '0'};
      final response = await dio.get(path, params: queryParameters);

      return response;
    } on DioException catch (e) {
      log('❌ Dio error when fetching Google Sheets: ${e.message}');
      return null;
    } catch (e) {
      log('❌ Unexpected error when fetching Google Sheets: $e');
      return null;
    }
  }
}
