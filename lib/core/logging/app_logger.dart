import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, lineLength: 120, colors: true),
  );

  static void debug(String msg) => _logger.d(msg);
  static void info(String msg) => _logger.i(msg);
  static void warning(String msg) => _logger.w(msg);
  static void error(String msg, [dynamic err, StackTrace? s]) =>
      _logger.e(msg, error: err, stackTrace: s);
}
