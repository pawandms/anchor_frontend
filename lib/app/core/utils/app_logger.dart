import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

/// Application-wide logger utility
/// Configurable through LOG_LEVEL in .env file
/// Supported levels: trace, debug, info, warning, error, none
class AppLogger {
  // Check if we're in production mode
  static bool get _isProduction => kReleaseMode;

  // Get log level from .env, default based on build mode
  static Level get _logLevel {
    final logLevelStr = dotenv.env['LOG_LEVEL']?.toLowerCase();

    if (logLevelStr != null) {
      switch (logLevelStr) {
        case 'trace':
          return Level.trace;
        case 'debug':
          return Level.debug;
        case 'info':
          return Level.info;
        case 'warning':
          return Level.warning;
        case 'error':
          return Level.error;
        case 'none':
          return Level.off;
        default:
          return _isProduction ? Level.warning : Level.trace;
      }
    }

    // Default: warning in production, trace in development
    return _isProduction ? Level.warning : Level.trace;
  }

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: _logLevel,
  );

  /// Trace log (very detailed, for debugging only)
  static void trace(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  /// Debug log (development only)
  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Info log (general information)
  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Warning log (potential issues)
  static void warning(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Error log (errors that should be investigated)
  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
