import 'dart:convert';
import 'dart:io';

import 'package:device_monitor/my_app.dart';
import 'package:device_monitor/src/core/data/repositories/cache_repository_impl.dart';
import 'package:device_monitor/src/core/services/device_vitals_service.dart';
import 'package:device_monitor/src/core/domain/entities/device_entity.dart';
import 'package:device_monitor/src/features/vitals/data/requests/request_vitals.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class VitalsBackgroundService {
  Future<void> start() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // true for testing
    );

    await Workmanager().registerPeriodicTask(
      DateTime.now().toIso8601String(),
      storeVitalsToAPI,
      frequency: const Duration(minutes: 15),
      initialDelay: const Duration(minutes: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 5),
    );
  }

  static Future<void> sendVitalsLogToAPI() async {
    try{
      var log = await DeviceVitalsService().getAllVitals();
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? deviceJson = CacheRepositoryImpl(sharedPreference: preferences).fetchDeviceEntityJson();
      if(deviceJson?.isEmpty??true){
        debugPrint('cached device data is null in background process: sendVitalsLogToAPI');
        //invalid device data
        return;
      }
      DeviceEntity entity = DeviceEntity.fromJson(jsonDecode(deviceJson!));
      if(entity.deviceId?.isEmpty??true){
        debugPrint('device-id is null in background process: sendVitalsLogToAPI');
        //invalid device data
        return;
      }
      RequestVitals request = RequestVitals(deviceId: entity.deviceId!);
      request.thermalStatus = log.thermalStatus;
      request.memoryUsage = log.memoryUsage;
      request.batteryLevel = log.batteryLevel;

      Uri uri = Uri.parse('http://172.236.151.18:8088/device_monitor/api/vitals');
      var response = await http.post(
        uri,
        body: jsonEncode(request.toJsonForCreate()),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.connectionHeader: "keep-alive",
          'X-API-Key': "DEVICEMONITOR3D4E5F6G7H8I9J0K1L2M3N4O5P6",
          'X-Service-Name': "device-monitor",
        },
      );
      debugPrint("vitals log saving process finished. statusCode = ${response.statusCode}}");
    }catch(e){
      debugPrint('vitals_background_service caught-error: $e');
    }
  }
}
