import 'dart:convert';

import 'package:device_monitor/src/core/di/di_container.dart';
import 'package:device_monitor/src/core/domain/entities/device_entity.dart';
import 'package:device_monitor/src/core/domain/interfaces/interface_cache_repository.dart';
import 'package:device_monitor/src/core/services/device_info_service.dart';
import 'package:device_monitor/src/features/device/data/requests/request_register_device.dart';
import 'package:device_monitor/src/features/device/domain/usecases/usecase_register_device.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'event_device_monitor.dart';
part 'state_device_monitor.dart';

class BlocDeviceMonitor extends Bloc<EventDeviceMonitor, StateDeviceMonitor> {

  BlocDeviceMonitor() : super(const StateDeviceMonitorInitial()) {
    on<EventCheckDeviceStatus>(_onCheckDeviceStatus);
    on<EventRegisterDevice>(_onRegisterDevice);
  }

  Future<void> _onCheckDeviceStatus(
      EventCheckDeviceStatus event,
      Emitter<StateDeviceMonitor> emit,
      ) async {
    emit(StateDeviceMonitorLoading(currentDevice: state.currentDevice));

    // Simulate initial delay
    await Future.delayed(const Duration(seconds: 2));

    final cachedJson = sl<ICacheRepository>().fetchDeviceEntityJson();

    if (cachedJson?.isEmpty ?? true) {
      // Need to register device - trigger registration
      add(EventRegisterDevice());
    } else {
      // Try to parse cached device
      try {
        final device = DeviceEntity.fromJson(jsonDecode(cachedJson!));
        emit(StateDeviceMonitorDeviceRegistered(
          device: device,
          message: 'Device loaded from cache',
        ));
      } catch (e) {
        // Parsing error - trigger registration
        add(EventRegisterDevice());
      }
    }
  }

  Future<void> _onRegisterDevice(
      EventRegisterDevice event,
      Emitter<StateDeviceMonitor> emit,
      ) async {
    emit(StateDeviceMonitorLoading(currentDevice: state.currentDevice));

    // Get device info
    final deviceInfo = DeviceInfoService();
    await deviceInfo.initialize();

    final request = RequestRegisterDevice()
      ..androidId = deviceInfo.androidId
      ..identifierForVendor = deviceInfo.identifierForVendor
      ..osVersion = deviceInfo.osVersion
      ..osName = deviceInfo.osName
      ..model = deviceInfo.deviceModel
      ..brand = deviceInfo.deviceBrand;

    // Call use case
    final result = await UseCaseRegisterDevice(repositoryDevice: sl()).execute(request);

    result.fold(
          (failure) {
        emit(StateDeviceMonitorRegistrationFailed(
          errorMessage: failure.message,
          currentDevice: state.currentDevice,
        ));
      },
          (response) {
        final device = response.data!;

        // Save to cache
        sl<ICacheRepository>().saveDeviceEntityJson(
          jsonEncode(device.toJson()),
        );

        emit(StateDeviceMonitorDeviceRegistered(
          device: device,
          message: response.message ?? 'Success',
        ));
      },
    );
  }
}