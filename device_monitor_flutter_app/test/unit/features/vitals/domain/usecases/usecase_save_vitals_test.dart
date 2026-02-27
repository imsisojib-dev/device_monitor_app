import 'package:test/test.dart';
import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:device_monitor/src/features/vitals/domain/usecases/usecase_save_vitals.dart';
import 'package:device_monitor/src/features/vitals/data/requests/request_vitals.dart';
import 'package:device_monitor/src/core/domain/entities/vitals_entity.dart';
import 'package:device_monitor/src/core/data/models/api_response.dart';
import 'package:device_monitor/src/core/data/models/failure.dart';

import '../../data/repositories/mock_repository_vitals.dart';


void main() {
  late MockRepositoryVitals mockRepository;
  late UseCaseSaveVitals useCase;

  setUp(() {
    mockRepository = MockRepositoryVitals();
    useCase = UseCaseSaveVitals(repositoryVitals: mockRepository);
  });

  group('UseCaseSaveVitals -', () {
    final tRequest = RequestVitals(
      deviceId: 'device-123',
      batteryLevel: 85,
      thermalStatus: 1,
      memoryUsage: 45,
    );

    final tVitalsEntity = VitalsEntity(
      id: 1,
      batteryLevel: 85,
      thermalStatus: 1,
      memoryUsage: 45,
    );

    test('should return Right(ApiResponse) when save is successful', () async {
      // Arrange
      final tSuccessResponse = ApiResponse<VitalsEntity>(
        statusCode: 200,
        data: tVitalsEntity,
        message: 'Vitals saved successfully',
      );

      when(() => mockRepository.saveVitals(tRequest))
          .thenAnswer((_) async => tSuccessResponse);

      // Act
      final result = await useCase.execute(tRequest);

      // Assert
      expect(result, isA<Right<Failure, ApiResponse<VitalsEntity>>>());

      result.fold(
            (failure) => fail('Should return Right, but got Left with: ${failure.message}'),
            (response) {
          expect(response.statusCode, equals(200));
          expect(response.data, equals(tVitalsEntity));
          expect(response.message, equals('Vitals saved successfully'));
        },
      );

      verify(() => mockRepository.saveVitals(tRequest)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Left(Failure) when statusCode is not 200', () async {
      // Arrange
      final tErrorResponse = ApiResponse<VitalsEntity>(
        statusCode: 400,
        data: null,
        message: 'Bad request - Invalid data',
      );

      when(() => mockRepository.saveVitals(tRequest))
          .thenAnswer((_) async => tErrorResponse);

      // Act
      final result = await useCase.execute(tRequest);

      // Assert
      expect(result, isA<Left<Failure, ApiResponse<VitalsEntity>>>());

      result.fold(
            (failure) {
          expect(failure.statusCode, equals(400));
          expect(failure.message, equals('Bad request - Invalid data'));
        },
            (response) => fail('Should return Left, but got Right'),
      );

      verify(() => mockRepository.saveVitals(tRequest)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Left(Failure) when statusCode is 200 but data is null', () async {
      // Arrange
      final tNullDataResponse = ApiResponse<VitalsEntity>(
        statusCode: 200,
        data: null,
        message: null,
      );

      when(() => mockRepository.saveVitals(tRequest))
          .thenAnswer((_) async => tNullDataResponse);

      // Act
      final result = await useCase.execute(tRequest);

      // Assert
      expect(result, isA<Left<Failure, ApiResponse<VitalsEntity>>>());

      result.fold(
            (failure) {
          expect(failure.statusCode, equals(200));
          expect(failure.message, equals('Something is went wrong!'));
        },
            (response) => fail('Should return Left, but got Right'),
      );

      verify(() => mockRepository.saveVitals(tRequest)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Left(Failure) when statusCode is 500', () async {
      // Arrange
      final tServerErrorResponse = ApiResponse<VitalsEntity>(
        statusCode: 500,
        data: null,
        message: 'Internal server error',
      );

      when(() => mockRepository.saveVitals(tRequest))
          .thenAnswer((_) async => tServerErrorResponse);

      // Act
      final result = await useCase.execute(tRequest);

      // Assert
      expect(result, isA<Left<Failure, ApiResponse<VitalsEntity>>>());

      result.fold(
            (failure) {
          expect(failure.statusCode, equals(500));
          expect(failure.message, equals('Internal server error'));
        },
            (response) => fail('Should return Left, but got Right'),
      );

      verify(() => mockRepository.saveVitals(tRequest)).called(1);
    });

    test('should return Left(Failure) when statusCode is null', () async {
      // Arrange
      final tNullStatusResponse = ApiResponse<VitalsEntity>(
        statusCode: null,
        data: null,
        message: 'Unknown error',
      );

      when(() => mockRepository.saveVitals(tRequest))
          .thenAnswer((_) async => tNullStatusResponse);

      // Act
      final result = await useCase.execute(tRequest);

      // Assert
      expect(result, isA<Left<Failure, ApiResponse<VitalsEntity>>>());

      result.fold(
            (failure) {
          expect(failure.statusCode, equals(500)); // Falls back to 500
          expect(failure.message, equals('Unknown error'));
        },
            (response) => fail('Should return Left, but got Right'),
      );

      verify(() => mockRepository.saveVitals(tRequest)).called(1);
    });

    test('should use default error message when message is null', () async {
      // Arrange
      final tNullMessageResponse = ApiResponse<VitalsEntity>(
        statusCode: 404,
        data: null,
        message: null,
      );

      when(() => mockRepository.saveVitals(tRequest))
          .thenAnswer((_) async => tNullMessageResponse);

      // Act
      final result = await useCase.execute(tRequest);

      // Assert
      expect(result, isA<Left<Failure, ApiResponse<VitalsEntity>>>());

      result.fold(
            (failure) {
          expect(failure.statusCode, equals(404));
          expect(failure.message, equals('Something is went wrong!'));
        },
            (response) => fail('Should return Left, but got Right'),
      );

      verify(() => mockRepository.saveVitals(tRequest)).called(1);
    });

    test('should handle repository exception gracefully', () async {
      // Arrange
      when(() => mockRepository.saveVitals(tRequest))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
            () => useCase.execute(tRequest),
        throwsA(isA<Exception>()),
      );

      verify(() => mockRepository.saveVitals(tRequest)).called(1);
    });
  });
}