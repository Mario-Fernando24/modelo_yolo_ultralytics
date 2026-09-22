import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'core/constants/api_constants.dart';
import 'data/datasources/device_data_source.dart';
import 'data/datasources/vision_remote_data_source.dart';
import 'data/repositories/detection_repository_impl.dart';
import 'domain/repositories/detection_repository.dart';
import 'domain/usecases/detect_live.dart';
import 'domain/usecases/get_history.dart';
import 'domain/usecases/save_capture.dart';
import 'presentation/bloc/camera/camera_bloc.dart';
import 'presentation/bloc/history/history_bloc.dart';

/// Contenedor de inyección (Service Locator).
/// `sl()` pide una dependencia ya registrada.
/// - Factory: un CameraBloc NUEVO cada vez (cada pantalla).
/// - LazySingleton: una sola instancia (repositorio, HTTP, URL).
final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerFactory(
    () => CameraBloc(
      detectLive: sl(),
      saveCapture: sl(),
      device: sl(),
      repository: sl(),
    ),
  );
  sl.registerFactory(
    () => HistoryBloc(
      getHistory: sl(),
      repository: sl(),
    ),
  );

  sl.registerLazySingleton(() => DetectLive(sl()));
  sl.registerLazySingleton(() => SaveCapture(sl()));
  sl.registerLazySingleton(() => GetHistory(sl()));

  sl.registerLazySingleton<DetectionRepository>(
    () => DetectionRepositoryImpl(remote: sl(), config: sl()),
  );
  sl.registerLazySingleton<VisionRemoteDataSource>(
    () => VisionRemoteDataSourceImpl(client: sl(), config: sl()),
  );
  sl.registerLazySingleton<DeviceDataSource>(() => DeviceDataSourceImpl());
  sl.registerLazySingleton(() => ApiConfig(ApiConstants.defaultBaseUrl()));
  sl.registerLazySingleton(http.Client.new);
}
