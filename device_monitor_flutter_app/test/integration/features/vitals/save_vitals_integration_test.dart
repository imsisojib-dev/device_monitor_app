import 'package:device_monitor/src/config/env.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:device_monitor/src/features/vitals/domain/usecases/usecase_save_vitals.dart';
import 'package:device_monitor/src/features/vitals/data/requests/request_vitals.dart';
import 'package:device_monitor/src/core/domain/entities/vitals_entity.dart';
import 'package:device_monitor/src/features/vitals/domain/interfaces/i_repository_vitals.dart';
import 'package:device_monitor/src/core/data/models/api_response.dart';
import 'package:device_monitor/src/core/data/models/failure.dart';

import '../../core/di/test_di_container.dart';

void main() {
  group('UseCaseSaveVitals Integration Tests -', () {
    late UseCaseSaveVitals useCase;
    late IRepositoryVitals repository;
    late String deviceId;

    setUpAll(() async {
      // Initialize environment configuration
      Env.baseUrl = 'http://172.236.151.18:8088/device_monitor';
      Env.type = EEnvType.prod;
      Env.X_API_KEY = 'DEVICEMONITOR3D4E5F6G7H8I9J0K1L2M3N4O5P6';
      Env.X_SERVICE_NAME = 'device-monitor';

      //Testing deviceId
      deviceId = "DEV00000001";

      // Initialize only test-required dependencies
      await initVitalsTestDependencies();
    });

    setUp(() {
      repository = testSl<IRepositoryVitals>();
      useCase = UseCaseSaveVitals(repositoryVitals: repository);
    });

    tearDownAll(() async {
      await cleanupTestDependencies();
    });

    test(
      'should save vitals successfully when API returns 200 with data',
      () async {
        // Arrange
        final request = RequestVitals(
          deviceId: deviceId,
          batteryLevel: 85,
          thermalStatus: 1,
          memoryUsage: 45,
        );

        // Act
        final result = await useCase.execute(request);

        // Assert
        expect(result, isA<Right<Failure, ApiResponse<VitalsEntity>>>());

        result.fold(
          (failure) {
            fail('Expected success but got failure: ${failure.message}');
          },
          (response) {
            expect(response.statusCode, equals(200));
            expect(response.data, isNotNull);
            expect(response.data?.batteryLevel, equals(85));
            expect(response.data?.thermalStatus, equals(1));
            expect(response.data?.memoryUsage, equals(45));
          },
        );
      },
    );

    test(
      'should handle validation errors when sending invalid data',
      () async {

        // Arrange - Invalid thermal status (should be 0-3)
        final invalidRequest = RequestVitals(
          deviceId: deviceId,
          batteryLevel: 85,
          thermalStatus: 999, // Invalid
          memoryUsage: 45,
        );

        // Act
        final result = await useCase.execute(invalidRequest);

        // Assert
        expect(result, isA<Left<Failure, ApiResponse<VitalsEntity>>>());

        result.fold(
          (failure) {
            expect(failure.statusCode, anyOf([400, 422]));
          },
          (response) {
            fail('Expected Failure but got success: API accepted invalid data');
          },
        );
      },
    );

    test(
      'should reject requests with if invalid device id present',
      () async {

        // Arrange
        final request = RequestVitals(
          deviceId: 'invalid-device-id',
          batteryLevel: 75,
          thermalStatus: 2,
          memoryUsage: 60,
        );

        // Act
        final result = await useCase.execute(request).timeout(
              const Duration(seconds: 15),
            );

        // Assert
        expect(result, isA<Left<Failure, ApiResponse<VitalsEntity>>>());

        result.fold(
          (failure) {
            expect(failure.message, contains('Device not found with deviceId'));
          },
          (response) {
            fail('Expected Failure but got success: API accepting invalid device id');
          },
        );
      },
    );

    test(
      'should complete within reasonable time',
      () async {

        // Arrange
        final request = RequestVitals(
          deviceId: deviceId,
          batteryLevel: 85,
          thermalStatus: 1,
          memoryUsage: 45,
        );

        // Act
        final stopwatch = Stopwatch()..start();
        final result = await useCase.execute(request).timeout(
              const Duration(seconds: 10),
            );
        stopwatch.stop();


        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(10000));

        result.fold(
          (failure) => fail('Performance test failed: ${failure.message}'),
          (response) => expect(response.statusCode, equals(200)),
        );
      },
    );

  });
}
