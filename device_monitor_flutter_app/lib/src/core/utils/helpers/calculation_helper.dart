import 'package:device_monitor/src/core/domain/entities/vitals_entity.dart';

class CalculationHelper {
  static double calculateHealthScore(VitalsEntity? vitals) {
    if (vitals == null) return 0;

    final thermal = vitals.thermalStatus;
    final battery = vitals.batteryLevel;
    final memory = vitals.memoryUsage;

    // Scoring logic (0-100)
    double thermalScore = (3 - thermal) / 3 * 100; // Lower thermal is better
    double batteryScore = battery.toDouble(); // Higher battery is better
    double memoryScore = (100 - memory).toDouble(); // Lower memory usage is better

    return (thermalScore * 0.3 + batteryScore * 0.4 + memoryScore * 0.3);
  }
}