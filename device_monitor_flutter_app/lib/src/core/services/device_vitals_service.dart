import 'package:device_monitor/src/core/domain/entities/vitals_entity.dart';
import 'package:device_monitor/src/core/utils/helpers/debugger_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class DeviceVitalsService {
  static const MethodChannel _channel = MethodChannel('com.device_monitor/vitals');

  Future<int> getThermalStatus() async {
    try {
      final int result = await _channel.invokeMethod('getThermalStatus');
      return result;
    } on PlatformException catch (e) {
      debugPrint('DeviceVitalsService.getThermalStatus(): PlatformException: $e');
      return 0; // Default to "None"
    } catch (e) {
      debugPrint('DeviceVitalsService.getThermalStatus(): Exception: $e');
      return 0;
    }
  }

  Future<int> getBatteryLevel() async {
    try {
      final int result = await _channel.invokeMethod('getBatteryLevel');
      return result;
    } on PlatformException catch (e) {
      debugPrint('DeviceVitalsService.getBatteryLevel(): PlatformException: $e');
      return 0;
    } catch (e) {
      debugPrint('DeviceVitalsService.getBatteryLevel(): Exception: $e');
      return 0;
    }
  }

  Future<int> getMemoryUsage() async {
    try {
      final int result = await _channel.invokeMethod('getMemoryUsage');
      return result;
    } on PlatformException catch (e) {
      debugPrint('DeviceVitalsService.getMemoryUsage(): PlatformException: $e');
      return 0;
    } catch (e) {
      debugPrint('DeviceVitalsService.getMemoryUsage(): Exception: $e');
      return 0;
    }
  }

  Future<VitalsEntity> getAllVitals() async {
    final thermal = await getThermalStatus();
    final battery = await getBatteryLevel();
    final memory = await getMemoryUsage();

    return VitalsEntity(
      thermalStatus: thermal,
      batteryLevel: battery,
      memoryUsage: memory,
      timestamp: DateTime.now(),
    );
  }
}