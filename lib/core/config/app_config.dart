import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  final String airApiKey;
  final String baseUrl;

  static const String defaultBaseUrl = "https://api.waqi.info";

  AppConfig({required this.airApiKey, this.baseUrl = defaultBaseUrl});

  /// .env file
  factory AppConfig.fromEnv() {
    return AppConfig(
      airApiKey: dotenv.env['AIR_API_KEY'] ?? '',
      baseUrl: dotenv.env['BASE_URL'] ?? defaultBaseUrl,
    );
  }

  /// test file
  factory AppConfig.fromTest({
    String apiKey = '....',
    String baseUrl = defaultBaseUrl,
  }) {
    return AppConfig(airApiKey: apiKey, baseUrl: baseUrl);
  }
}
