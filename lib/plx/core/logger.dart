import 'package:flutter/foundation.dart';

enum LogLevel {
  message,
  warning,
  error,
  fatal,
}

class PlxLogger {
  static void log(String message, {LogLevel level = LogLevel.message, String system = 'Engine'}) {
    final prefix = _getPrefix(level);
    final formattedMessage = '[$prefix] [$system] $message';
    debugPrint(formattedMessage);
  }

  static void message(String message, {String system = 'Engine'}) => log(message, level: LogLevel.message, system: system);
  static void warning(String message, {String system = 'Engine'}) => log(message, level: LogLevel.warning, system: system);
  static void error(String message, {String system = 'Engine'}) => log(message, level: LogLevel.error, system: system);
  static void fatal(String message, {String system = 'Engine'}) => log(message, level: LogLevel.fatal, system: system);

  static String _getPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.message: return 'MSG';
      case LogLevel.warning: return 'WRN';
      case LogLevel.error: return 'ERR';
      case LogLevel.fatal: return 'FTL';
    }
  }
}
