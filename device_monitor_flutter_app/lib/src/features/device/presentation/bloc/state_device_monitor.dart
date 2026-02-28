part of 'bloc_device_monitor.dart';

abstract class StateDeviceMonitor extends Equatable {
  final DeviceEntity? currentDevice;

  const StateDeviceMonitor({this.currentDevice});

  @override
  List<Object?> get props => [currentDevice];
}

class StateDeviceMonitorInitial extends StateDeviceMonitor {
  const StateDeviceMonitorInitial() : super(currentDevice: null);
}

class StateDeviceMonitorLoading extends StateDeviceMonitor {
  const StateDeviceMonitorLoading({super.currentDevice});
}

class StateDeviceMonitorDeviceRegistered extends StateDeviceMonitor {
  final String? message;

  const StateDeviceMonitorDeviceRegistered({
    required DeviceEntity device,
    this.message,
  }) : super(currentDevice: device);

  @override
  List<Object?> get props => [currentDevice, message];
}

class StateDeviceMonitorRegistrationFailed extends StateDeviceMonitor {
  final String errorMessage;

  const StateDeviceMonitorRegistrationFailed({
    required this.errorMessage,
    super.currentDevice,
  });

  @override
  List<Object?> get props => [errorMessage, currentDevice];
}