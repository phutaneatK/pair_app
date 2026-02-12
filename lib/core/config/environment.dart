class Environment {
  /// Current environment name (dev, staging, production)
  static const String name = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'dev',
  );

  /// API Base URL
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// Check if running in development
  static bool get isDev => name == 'dev';

  /// Check if running in staging
  static bool get isStaging => name == 'staging';

  /// Check if running in production
  static bool get isProduction => name == 'production';

  /// Additional config values
  static const String apiTimeout = String.fromEnvironment(
    'API_TIMEOUT',
    defaultValue: '30000',
  );

  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: false,
  );

  static const bool enableCrashReporting = bool.fromEnvironment(
    'ENABLE_CRASH_REPORTING',
    defaultValue: false,
  );

  /// Print current configuration
  static void printConfig() {
    // print('=== Environment Configuration ===');
    // print('Environment: $name');
    // print('API Base URL: $apiBaseUrl');
    // print('API Timeout: $apiTimeout ms');
    // print('Analytics: $enableAnalytics');
    // print('Crash Reporting: $enableCrashReporting');
    // print('================================');
  }
}
