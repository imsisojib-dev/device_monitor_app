import 'package:dartz/dartz.dart';
import 'package:device_monitor/src/core/data/models/api_filter.dart';
import 'package:device_monitor/src/core/data/models/api_response.dart';
import 'package:device_monitor/src/core/data/models/failure.dart';
import 'package:device_monitor/src/core/domain/interfaces/interface_use_case.dart';
import 'package:device_monitor/src/features/device/data/requests/request_register_device.dart';
import 'package:device_monitor/src/core/domain/entities/device_entity.dart';
import 'package:device_monitor/src/features/device/domain/interfaces/i_repository_device.dart';
import 'package:device_monitor/src/core/domain/entities/vitals_entity.dart';
import 'package:device_monitor/src/features/vitals/domain/interfaces/i_repository_vitals.dart';

class UseCaseFetchVitals implements IUseCase<ApiFilterRequest, ApiResponse<List<VitalsEntity>>> {
  final IRepositoryVitals repositoryVitals;

  UseCaseFetchVitals({required this.repositoryVitals});

  @override
  Future<Either<Failure, ApiResponse<List<VitalsEntity>>>> execute(ApiFilterRequest request) async {
    var response = await repositoryVitals.getVitals(request);

    if(response.statusCode==200) {
      return Right(response);
    }

    return Left(Failure(
      message: response.message??"Something is went wrong!",
      statusCode: response.statusCode??500,
    ));
  }
}
