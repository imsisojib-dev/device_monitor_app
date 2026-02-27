import 'package:dartz/dartz.dart';
import 'package:device_monitor/src/core/data/models/api_response.dart';
import 'package:device_monitor/src/core/data/models/failure.dart';
import 'package:device_monitor/src/core/domain/interfaces/interface_use_case.dart';
import 'package:device_monitor/src/features/device/data/requests/request_register_device.dart';
import 'package:device_monitor/src/core/domain/entities/device_entity.dart';
import 'package:device_monitor/src/features/device/domain/interfaces/i_repository_device.dart';
import 'package:device_monitor/src/features/vitals/data/requests/request_vitals.dart';
import 'package:device_monitor/src/core/domain/entities/vitals_entity.dart';
import 'package:device_monitor/src/features/vitals/domain/interfaces/i_repository_vitals.dart';

class UseCaseSaveVitals implements IUseCase<RequestVitals, ApiResponse<VitalsEntity>> {
  final IRepositoryVitals repositoryVitals;

  UseCaseSaveVitals({required this.repositoryVitals});

  @override
  Future<Either<Failure, ApiResponse<VitalsEntity>>> execute(RequestVitals request) async {
    var response = await repositoryVitals.saveVitals(request);

    if(response.statusCode==200 && response.data!=null) {
      return Right(response);
    }

    return Left(Failure(
      message: response.message??"Something is went wrong!",
      statusCode: response.statusCode??500,
    ));
  }
}
