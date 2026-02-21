import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class AppLogger {
  AppLogger._();

  static String _getTimestamp() {
    final now = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy HH:mm:ss');
    return formatter.format(now);
  }

  static void log(String message) {
    if (kDebugMode) {
      debugPrint('[${_getTimestamp()}] ddd = 🔵 LOG: $message');
    }
  }

  /// Log error - แสดงแค่ใน debug mode
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[${_getTimestamp()}] ddd = 🔴 ERROR: $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('[${_getTimestamp()}] ddd = 🟡 WARNING: $message');
    }
  }

  static void success(String message) {
    if (kDebugMode) {
      debugPrint('[${_getTimestamp()}] ddd = 🟢 SUCCESS: $message');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      debugPrint('[${_getTimestamp()}] ddd = ℹ️ INFO: $message');
    }
  }

  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('[${_getTimestamp()}] ddd = 🐛 DEBUG: $message');
    }
  }
}

void log(String message) => AppLogger.log(message);

void logError(String message, [Object? error, StackTrace? stackTrace]) {
  AppLogger.error(message, error, stackTrace);
}

void logWarning(String message) => AppLogger.warning(message);

void logSuccess(String message) => AppLogger.success(message);

void logInfo(String message) => AppLogger.info(message);

void logDebug(String message) => AppLogger.debug(message);
