import 'package:device_monitor/src/core/data/repositories/cache_repository_impl.dart';
import 'package:device_monitor/src/core/domain/interfaces/interface_api_interceptor.dart';
import 'package:device_monitor/src/core/domain/interfaces/interface_cache_repository.dart';
import 'package:device_monitor/src/core/services/api_interceptor.dart';
import 'package:device_monitor/src/core/services/device_vitals_service.dart';
import 'package:device_monitor/src/core/services/navigation_service.dart';
import 'package:device_monitor/src/core/services/token_service.dart';
import 'package:device_monitor/src/features/analytics/data/repositories/repository_analytics.dart';
import 'package:device_monitor/src/features/analytics/domain/interfaces/i_repository_analytics.dart';
import 'package:device_monitor/src/features/analytics/presentation/providers/provider_analytics.dart';
import 'package:device_monitor/src/features/device/data/repositories/repository_device.dart';
import 'package:device_monitor/src/features/device/domain/interfaces/i_repository_device.dart';
import 'package:device_monitor/src/features/history/presentation/providers/provider_history.dart';
import 'package:device_monitor/src/features/vitals/data/repopsitories/repository_vitals.dart';
import 'package:device_monitor/src/features/vitals/domain/interfaces/i_repository_vitals.dart';
import 'package:device_monitor/src/features/vitals/presentation/providers/provider_vitals.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {

  //using dependency-injection
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  ///REPOSITORIES
  //#region Repositories
  sl.registerLazySingleton<ICacheRepository>(() => CacheRepositoryImpl(sharedPreference: sl()));
  sl.registerLazySingleton<IRepositoryDevice>(() => RepositoryDevice(apiInterceptor: sl(), tokenService: sl()));
  sl.registerLazySingleton<IRepositoryVitals>(() => RepositoryVitals(apiInterceptor: sl(), tokenService: sl()));
  sl.registerLazySingleton<IRepositoryAnalytics>(() => RepositoryAnalytics(apiInterceptor: sl(), tokenService: sl()));
  //#endregion

  ///PROVIDERS
  //region Providers
  sl.registerFactory(() => ProviderVitals(),);
  sl.registerFactory(() => ProviderHistory(),);
  sl.registerFactory(() => ProviderAnalytics(),);

  //interceptors
  sl.registerLazySingleton<IApiInterceptor>(() => ApiInterceptor());

  ///services
  sl.registerSingleton(DeviceVitalsService());
  sl.registerSingleton(NavigationService());  //to initialize navigator-key for common-runtime
  sl.registerSingleton(TokenService()); //token service to store token common-runtime
  //logger
  sl.registerLazySingleton(()=>Logger(
    printer: PrettyPrinter(
      colors: false,
    ),
  ),);

}