import 'package:dartz/dartz.dart';
import 'package:device_monitor/src/core/data/models/api_response.dart';
import 'package:device_monitor/src/core/data/models/failure.dart';
import 'package:device_monitor/src/core/domain/interfaces/interface_use_case.dart';
import 'package:device_monitor/src/features/device/data/requests/request_register_device.dart';
import 'package:device_monitor/src/core/domain/entities/device_entity.dart';
import 'package:device_monitor/src/features/device/domain/interfaces/i_repository_device.dart';

class UseCaseRegisterDevice implements IUseCase<RequestRegisterDevice, ApiResponse<DeviceEntity>> {
  final IRepositoryDevice repositoryDevice;

  UseCaseRegisterDevice({required this.repositoryDevice});

  @override
  Future<Either<Failure, ApiResponse<DeviceEntity>>> execute(RequestRegisterDevice request) async {
    var response = await repositoryDevice.registerDevice(request);

    if(response.statusCode==200 && response.data!=null && response.data?.deviceId!=null) {
      return Right(response);
    }

    return Left(Failure(
      message: response.message??"Something is went wrong!",
      statusCode: response.statusCode??500,
    ));
  }
}
