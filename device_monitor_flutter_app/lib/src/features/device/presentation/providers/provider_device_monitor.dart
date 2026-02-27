import 'dart:convert';

import 'package:device_monitor/src/config/routes/routes.dart';
import 'package:device_monitor/src/core/di/di_container.dart';
import 'package:device_monitor/src/core/domain/interfaces/interface_cache_repository.dart';
import 'package:device_monitor/src/core/enums/e_dialog_type.dart';
import 'package:device_monitor/src/core/enums/e_loading.dart';
import 'package:device_monitor/src/core/services/device_info_service.dart';
import 'package:device_monitor/src/core/services/navigation_service.dart';
import 'package:device_monitor/src/core/utils/helpers/widget_helper.dart';
import 'package:device_monitor/src/core/widgets/buttons/basic_button.dart';
import 'package:device_monitor/src/features/device/data/requests/request_register_device.dart';
import 'package:device_monitor/src/core/domain/entities/device_entity.dart';
import 'package:device_monitor/src/features/device/domain/usecases/usecase_register_device.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProviderDeviceMonitor extends ChangeNotifier {
  //states
  ELoading _loading = ELoading.none;
  DeviceEntity? _currentDevice;

  //getters
  ELoading get loading => _loading;

  DeviceEntity? get currentDevice => _currentDevice;

  //setters
  set loading(ELoading state) {
    _loading = state;
    notifyListeners();
  }

  void checkDeviceStatus() async{
    await Future.delayed(Duration(seconds: 2));
    String? cachedJson = sl<ICacheRepository>().fetchDeviceEntityJson();
    if (cachedJson?.isEmpty ?? true) {
      //means need to register device
      registerDevice();
    } else {
      //parse to model and verify calling api
      try {
        _currentDevice = DeviceEntity.fromJson(jsonDecode(cachedJson!));
        //push to homepage
        Navigator.pushNamedAndRemoveUntil(
          sl<NavigationService>().navigatorKey.currentContext!,
          Routes.homeScreen,
          (params) => false,
        );
      } catch (e) {
        //if parsing error then try to register again
        registerDevice();
      }
    }
  }

  //methods
  Future<void> registerDevice() async {
    loading = ELoading.loading;

    var deviceInfo = DeviceInfoService();
    await deviceInfo.initialize();
    RequestRegisterDevice request = RequestRegisterDevice();
    request.androidId = deviceInfo.androidId;
    request.identifierForVendor = deviceInfo.identifierForVendor;
    request.osVersion = deviceInfo.osVersion;
    request.osName = deviceInfo.osName;
    request.model = deviceInfo.deviceModel;
    request.brand = deviceInfo.deviceBrand;

    var result = await UseCaseRegisterDevice(repositoryDevice: sl()).execute(request);
    result.fold(
      (error) {
        WidgetHelper.showAlertDialog(
          title: "Failed!",
          message: error.message,
          dialogType: EDialogType.error,
          positiveButton: BasicButton(
            buttonText: "Retry Now",
            onPressed: (){
              registerDevice();
              Navigator.pop(sl<NavigationService>().navigatorKey.currentContext!);
            },
          ),
        );
      },
      (response) {
        _currentDevice = response.data;
        Fluttertoast.showToast(msg: response.message??'Success');
        //save data to cache
        sl<ICacheRepository>().saveDeviceEntityJson(jsonEncode(_currentDevice?.toJson()));

        //push to homepage
        Navigator.pushNamedAndRemoveUntil(
          sl<NavigationService>().navigatorKey.currentContext!,
          Routes.homeScreen,
              (params) => false,
        );
      },
    );
  }
}
