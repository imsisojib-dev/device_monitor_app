import 'package:device_monitor/src/config/env.dart';
import 'package:device_monitor/src/core/presentation/bloc/app_theme/bloc_app_theme.dart';
import 'package:device_monitor/src/core/services/navigation_service.dart';
import 'package:device_monitor/src/core/services/vitals_background_service.dart';
import 'package:device_monitor/src/features/device/presentation/bloc/bloc_device_monitor.dart';
import 'package:device_monitor/src/features/vitals/presentation/providers/provider_vitals.dart';
import 'package:flutter/material.dart';
import 'package:device_monitor/src/config/routes/router_helper.dart';
import 'package:device_monitor/src/config/routes/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'src/config/resources/app_theme.dart';
import 'src/core/di/di_container.dart' as di;
import 'src/core/di/di_container.dart';

const String storeVitalsToAPI = "sendVitalsLogToAPI";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case storeVitalsToAPI:
        await VitalsBackgroundService.sendVitalsLogToAPI();
        break;
    }
    return Future.value(true);
  });
}

Future<void> initEnvConfig() async {
  await dotenv.load(fileName: '.env');

  Env.baseUrl = dotenv.env['BASE_URL']??'';
  Env.type = EEnvType.prod;
  Env.X_API_KEY = dotenv.env['X_API_KEY']??'';
  Env.X_SERVICE_NAME = dotenv.env['X_SERVICE_NAME']??'';
}

Future<void> initApp() async {
  await di.init(); //initializing Dependency Injection

  //starting background service to store data
  VitalsBackgroundService().start();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<BlocAppTheme>(
          create: (BuildContext context) => BlocAppTheme(),
        ),
        BlocProvider<BlocDeviceMonitor>(
          create: (BuildContext context) => BlocDeviceMonitor(),
        ),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => di.sl<ProviderVitals>()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NavigationService navigationService = sl();

  @override
  void initState() {
    super.initState();
    RouterHelper().setupRouter();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, app) {
        return BlocBuilder<BlocAppTheme,StateAppTheme>(
          builder: (_, themeState){
            return MaterialApp(
              navigatorKey: navigationService.navigatorKey,
              debugShowCheckedModeBanner: false,
              builder: (context, child) {
                return ScrollConfiguration(
                  //Removes the whole common's scroll glow
                  behavior: AppBehavior(),
                  child: child!,
                );
              },
              title: 'Device Monitor',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeState.themeMode,
              initialRoute: Routes.splashScreen,
              onGenerateRoute: RouterHelper.router.generator,
            );
          },
        );
      },
    );
  }
}

//to avoid scroll glow in whole common
class AppBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
    BuildContext context,
    Widget child,
    AxisDirection axisDirection,
  ) {
    return child;
  }
}
