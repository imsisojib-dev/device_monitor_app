import 'dart:convert';

import 'package:device_monitor/src/config/config_api.dart';
import 'package:device_monitor/src/config/env.dart';
import 'package:device_monitor/src/core/data/models/api_filter.dart';
import 'package:device_monitor/src/core/data/models/api_response.dart';
import 'package:device_monitor/src/core/domain/interfaces/interface_api_interceptor.dart';
import 'package:device_monitor/src/core/services/token_service.dart';
import 'package:device_monitor/src/core/utils/helpers/debugger_helper.dart';
import 'package:device_monitor/src/features/vitals/data/requests/request_vitals.dart';
import 'package:device_monitor/src/core/domain/entities/vitals_entity.dart';
import 'package:device_monitor/src/features/vitals/domain/interfaces/i_repository_vitals.dart';
import 'package:http/http.dart' as http;

class RepositoryVitals implements IRepositoryVitals {
  final IApiInterceptor apiInterceptor;
  final TokenService tokenService;

  RepositoryVitals({
    required this.apiInterceptor,
    required this.tokenService,
  });

  @override
  Future<ApiResponse<List<VitalsEntity>>> getVitals(ApiFilterRequest request) async {
    String url = "${Env.baseUrl}${ConfigApi.vitals}/${request.deviceId}";

    http.Response response = await apiInterceptor.post(
      url: url,
      body: jsonEncode(request.toJson()),
      headers: tokenService.getHeadersForJson(),
    );

    var json = jsonDecode(response.body);
    return ApiResponse.fromJson(
      json,
      (data) => _parseVitalsList(data),
    );
  }

  List<VitalsEntity> _parseVitalsList(dynamic list){
    List<VitalsEntity> vitals = [];
    list.forEach((e){
      try{
        vitals.add(VitalsEntity.fromJson(e));
      }catch(error){
        Debugger.error(title: "RepositoryVitals._parseVitalsList(): parsing-error ${e['id']}", data: error);
      }
    });
    return vitals;
  }

  @override
  Future<ApiResponse<VitalsEntity>> saveVitals(RequestVitals request) async {
    String url = "${Env.baseUrl}${ConfigApi.vitals}";

    http.Response response = await apiInterceptor.post(
      url: url,
      body: jsonEncode(request.toJsonForCreate()),
      headers: tokenService.getHeadersForJson(),
    );

    var json = jsonDecode(response.body);
    return ApiResponse.fromJson(
      json,
      (data) => VitalsEntity.fromJson(data),
    );
  }
}
