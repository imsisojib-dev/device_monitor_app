import 'package:device_monitor/src/core/data/models/api_response.dart';
import 'package:device_monitor/src/features/device/data/requests/request_register_device.dart';
import 'package:device_monitor/src/core/domain/entities/device_entity.dart';

abstract class IRepositoryDevice{
  Future<ApiResponse<DeviceEntity>> registerDevice(RequestRegisterDevice request);
}