part of 'bloc_device_monitor.dart';

abstract class EventDeviceMonitor {}

class EventCheckDeviceStatus extends EventDeviceMonitor {}

class EventRegisterDevice extends EventDeviceMonitor {}