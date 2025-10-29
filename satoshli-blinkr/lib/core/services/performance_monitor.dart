import 'package:flutter/foundation.dart';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();

  factory PerformanceMonitor() {
    return _instance;
  }

  PerformanceMonitor._internal();

  final Map<String, Stopwatch> _timers = {};
  final Map<String, List<int>> _measurements = {};

  void startTimer(String label) {
    _timers[label] = Stopwatch()..start();
  }

  void stopTimer(String label) {
    final stopwatch = _timers[label];
    if (stopwatch != null) {
      stopwatch.stop();
      final elapsed = stopwatch.elapsedMilliseconds;

      // Guardar medición
      _measurements.putIfAbsent(label, () => []).add(elapsed);

      if (kDebugMode) {
        print('[Performance] $label: ${elapsed}ms');
      }
    }
  }

  int getElapsedTime(String label) {
    return _timers[label]?.elapsedMilliseconds ?? 0;
  }

  double getAverageTime(String label) {
    final measurements = _measurements[label];
    if (measurements == null || measurements.isEmpty) return 0;
    return measurements.reduce((a, b) => a + b) / measurements.length;
  }

  void clearTimers() {
    _timers.clear();
  }

  void clearMeasurements() {
    _measurements.clear();
  }

  Map<String, dynamic> getReport() {
    final report = <String, dynamic>{};
    for (final entry in _measurements.entries) {
      report[entry.key] = {
        'count': entry.value.length,
        'average': getAverageTime(entry.key),
        'min': entry.value.reduce((a, b) => a < b ? a : b),
        'max': entry.value.reduce((a, b) => a > b ? a : b),
      };
    }
    return report;
  }
}
