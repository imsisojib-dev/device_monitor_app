import 'package:device_monitor/src/core/data/models/api_filter.dart';
import 'package:device_monitor/src/core/data/models/api_response.dart';
import 'package:device_monitor/src/features/vitals/data/requests/request_vitals.dart';
import 'package:device_monitor/src/core/domain/entities/vitals_entity.dart';

abstract class IRepositoryVitals{
  Future<ApiResponse<VitalsEntity>> saveVitals(RequestVitals request);
  Future<ApiResponse<List<VitalsEntity>>> getVitals(ApiFilterRequest request);
}