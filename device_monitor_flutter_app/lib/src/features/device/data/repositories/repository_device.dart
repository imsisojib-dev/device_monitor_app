import 'dart:convert';

import 'package:device_monitor/src/config/config_api.dart';
import 'package:device_monitor/src/config/env.dart';
import 'package:device_monitor/src/core/data/models/api_response.dart';
import 'package:device_monitor/src/core/domain/interfaces/interface_api_interceptor.dart';
import 'package:device_monitor/src/core/services/token_service.dart';
import 'package:device_monitor/src/features/device/data/requests/request_register_device.dart';
import 'package:device_monitor/src/core/domain/entities/device_entity.dart';
import 'package:device_monitor/src/features/device/domain/interfaces/i_repository_device.dart';
import 'package:http/http.dart' as http;

class RepositoryDevice implements IRepositoryDevice {
  final IApiInterceptor apiInterceptor;
  final TokenService tokenService;

  RepositoryDevice({
    required this.apiInterceptor,
    required this.tokenService,
  });

  @override
  Future<ApiResponse<DeviceEntity>> registerDevice(RequestRegisterDevice request) async {
    String url = "${Env.baseUrl}${ConfigApi.devices}";

    http.Response response = await apiInterceptor.post(
      url: url,
      body: jsonEncode(request.toJson()),
      headers: tokenService.getHeadersForJson(),
    );

    var json = jsonDecode(response.body);
    return ApiResponse.fromJson(
      json,
      (data) => DeviceEntity.fromJson(data),
    );
  }
}
