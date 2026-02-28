import 'package:device_monitor/src/config/routes/routes.dart';
import 'package:device_monitor/src/core/di/di_container.dart';
import 'package:device_monitor/src/core/enums/e_dialog_type.dart';
import 'package:device_monitor/src/core/enums/e_loading.dart';
import 'package:device_monitor/src/core/services/device_vitals_service.dart';
import 'package:device_monitor/src/core/services/navigation_service.dart';
import 'package:device_monitor/src/core/utils/helpers/widget_helper.dart';
import 'package:device_monitor/src/core/widgets/buttons/basic_button.dart';
import 'package:device_monitor/src/features/device/presentation/bloc/bloc_device_monitor.dart';
import 'package:device_monitor/src/features/vitals/data/requests/request_vitals.dart';
import 'package:device_monitor/src/core/domain/entities/vitals_entity.dart';
import 'package:device_monitor/src/features/vitals/domain/usecases/usecase_save_vitals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class ProviderVitals extends ChangeNotifier {
  VitalsEntity? _currentVitals;
  ELoading? _loading;
  String? _error;
  String? _successMessage;

  VitalsEntity? get currentVitals => _currentVitals;

  ELoading? get loading => _loading;

  String? get error => _error;

  String? get successMessage => _successMessage;

  //setters
  set loading(ELoading? state) {
    _loading = state;
    notifyListeners();
  }

  Future<void> refreshVitals() async {
    loading = ELoading.refreshing;
    _error = null;
    notifyListeners();

    try {
      _currentVitals = await sl<DeviceVitalsService>().getAllVitals();
      _error = null;
    } catch (e) {
      _error = 'Failed to read sensors: ${e.toString()}';
    } finally {
      loading = null;
    }
  }

  Future<void> saveVitals() async {
    if(_loading == ELoading.submitButtonLoading){
      //already processing to save
      return;
    }
    var context = sl<NavigationService>().navigatorKey.currentContext!;
    if (_currentVitals == null) {
      WidgetHelper.showAlertDialog(
        title: "Warning!",
        message: "No vitals data found to save!",
        dialogType: EDialogType.warning,
        positiveButton: BasicButton(
          buttonText: "Re-try Now",
          onPressed: () async {
            await refreshVitals();
            Navigator.pop(context);
            saveVitals();
          },
        ),
      );
      return;
    }
    String? deviceId = context.read<BlocDeviceMonitor>().state.currentDevice?.deviceId;
    if (deviceId == null) {
      WidgetHelper.showAlertDialog(
        title: "Warning!",
        message: "Looks like your device is not registered! Re-try to register your device now.",
        dialogType: EDialogType.warning,
        positiveButton: BasicButton(
          buttonText: "Re-try Now",
          onPressed: () async {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.splashScreen,
              (params) => false,
            );
          },
        ),
      );
      return;
    }
    loading = ELoading.submitButtonLoading;

    RequestVitals request = RequestVitals(deviceId: deviceId);
    request.batteryLevel = _currentVitals?.batteryLevel;
    request.memoryUsage = _currentVitals?.memoryUsage;
    request.thermalStatus = _currentVitals?.thermalStatus;

    var result = await UseCaseSaveVitals(repositoryVitals: sl()).execute(request);
    result.fold(
      (error) {
        WidgetHelper.showAlertDialog(
          title: "Error!",
          message: error.message,
          dialogType: EDialogType.error,
          positiveButton: BasicButton(
            buttonText: "Re-try Now",
            onPressed: () async {
              loading = null;
              saveVitals();
              Navigator.pop(context);
            },
          ),
        );
      },
      (response) {
        WidgetHelper.showAlertDialog(
          title: "Success!",
          message: response.message??'Saved successfully.',
          dialogType: EDialogType.success,
          positiveButton: BasicButton(
            buttonText: "Okay",
            onPressed: () async {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
    loading = null;
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}
