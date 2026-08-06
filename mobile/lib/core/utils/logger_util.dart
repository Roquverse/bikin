import 'package:flutter/foundation.dart';

class LoggerUtil {
  static final List<RegExp> _sensitivePatterns = [
    RegExp(r'"?password"?:?\s*"[^"]*"', caseSensitive: false),
    RegExp(r'"?token"?:?\s*"[^"]*"', caseSensitive: false),
    RegExp(r'"?otp"?:?\s*"[^"]*"', caseSensitive: false),
    RegExp(r'"?access_token"?:?\s*"[^"]*"', caseSensitive: false),
    RegExp(r'"?refresh_token"?:?\s*"[^"]*"', caseSensitive: false),
  ];

  static void info(String message) {
    _log('INFO', message);
  }

  static void warning(String message) {
    _log('WARNING', message);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _log('ERROR', '$message ${error != null ? '\nError: $error' : ''} ${stackTrace != null ? '\nStackTrace: $stackTrace' : ''}');
  }

  static void debug(String message) {
    if (kDebugMode) {
      _log('DEBUG', message);
    }
  }

  static void _log(String level, String message) {
    String safeMessage = message;
    
    // Redact sensitive info
    for (var pattern in _sensitivePatterns) {
      safeMessage = safeMessage.replaceAllMapped(pattern, (match) {
        final matchedString = match.group(0)!;
        final keyPart = matchedString.substring(0, matchedString.indexOf(':') + 1);
        return '$keyPart "***REDACTED***"';
      });
    }

    if (kDebugMode) {
      // ignore: avoid_print
      print('[$level] $safeMessage');
    }
  }
}
