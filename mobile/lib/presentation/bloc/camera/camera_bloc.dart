import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/usecase/usecase.dart';
import '../../../data/datasources/device_data_source.dart';
import '../../../domain/repositories/detection_repository.dart';
import '../../../domain/usecases/detect_live.dart';
import '../../../domain/usecases/save_capture.dart';
import 'camera_event.dart';
import 'camera_state.dart';

/// Cerebro de la pantalla de cámara.
///
/// Idea de BLoC:
///   UI  --add(Evento)-->  CameraBloc  --emit(Estado)-->  UI
///
/// El BLoC no pinta widgets. Solo decide qué estado hay.
/// La página usa BlocBuilder / BlocConsumer para dibujar ese estado.
///
/// Dependencias (inyectadas con get_it):
/// - [detectLive]   caso de uso → POST /detect  (no guarda en BD)
/// - [saveCapture]  caso de uso → POST /captures (sí guarda foto + tabla)
/// - [device]       cámara y galería del teléfono
/// - [repository]   URL del servidor
class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraBloc({
    required this.detectLive,
    required this.saveCapture,
    required this.device,
    required this.repository,
  }) : super(CameraState(apiUrl: repository.baseUrl)) {
    // Cada evento tiene un handler. add(CameraStarted()) acaba en _onStarted.
    on<CameraStarted>(_onStarted);
    on<CameraLiveTicked>(_onLiveTicked);
    on<CameraCapturePressed>(_onCapturePressed);
    on<CameraGalleryPressed>(_onGalleryPressed);
    on<CameraApiUrlChanged>(_onApiUrlChanged);
    on<CameraMessageConsumed>(_onMessageConsumed);
    on<CameraStopped>(_onStopped);
  }

  final DetectLive detectLive;
  final SaveCapture saveCapture;
  final DeviceDataSource device;
  final DetectionRepository repository;

  /// Timer interno: cada 700 ms dispara un análisis en vivo.
  Timer? _timer;

  /// Abre la cámara. Si falla (simulador), [error] explica que use la galería.
  Future<void> _onStarted(CameraStarted event, Emitter<CameraState> emit) async {
    try {
      final session = await device.openCamera();
      emit(state.copyWith(session: session, clearError: true));
      _startTicker();
    } on DeviceException catch (error) {
      emit(state.copyWith(error: error.message, clearSession: true));
    }
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      // isClosed evita add() cuando el BLoC ya se destruyó (saliste de la pantalla).
      if (!isClosed) {
        add(const CameraLiveTicked());
      }
    });
  }

  /// Un fotograma: se manda a FastAPI y se actualizan cajas + porcentajes.
  /// No se guarda en PostgreSQL (eso es solo "Tomar foto").
  Future<void> _onLiveTicked(CameraLiveTicked event, Emitter<CameraState> emit) async {
    final session = state.session;
    // Si ya hay un detect en curso, o se está guardando, saltamos este tick.
    if (state.busy || state.saving || session == null || !state.isCameraReady) {
      return;
    }
    emit(state.copyWith(busy: true));
    try {
      final path = await device.takePicture(session);
      // Either: Left = fallo de red, Right = DetectionResult con objetos.
      final result = await detectLive(ImagePathParams(path));
      result.fold(
        (_) => emit(state.copyWith(busy: false)), // en vivo no molestamos con SnackBar
        (detection) => emit(
          state.copyWith(
            busy: false,
            detection: detection,
            status: detection.message, // "Sí, es un automóvil (93%)…"
          ),
        ),
      );
    } catch (_) {
      emit(state.copyWith(busy: false));
    }
  }

  /// Foto que SÍ se persiste: imagen en disco + filas en captures / capture_objects.
  Future<void> _onCapturePressed(
    CameraCapturePressed event,
    Emitter<CameraState> emit,
  ) async {
    _timer?.cancel(); // pausamos el vivo para no pelear por la cámara
    emit(state.copyWith(saving: true));
    final session = state.session;
    try {
      String? path;
      if (session != null && state.isCameraReady) {
        path = await device.takePicture(session);
      }
      if (path == null) {
        emit(state.copyWith(saving: false, message: 'No se tomó ninguna foto.'));
        _startTicker();
        return;
      }
      await _savePath(path, emit);
    } on DeviceException catch (error) {
      emit(state.copyWith(saving: false, message: error.message));
      _startTicker();
    }
  }

  Future<void> _onGalleryPressed(
    CameraGalleryPressed event,
    Emitter<CameraState> emit,
  ) async {
    _timer?.cancel();
    emit(state.copyWith(saving: true));
    final path = await device.pickFromGallery();
    if (path == null) {
      emit(state.copyWith(saving: false)); // el usuario canceló el picker
      _startTicker();
      return;
    }
    await _savePath(path, emit);
  }

  /// Llama al caso de uso SaveCapture → FastAPI → PostgreSQL.
  Future<void> _savePath(String path, Emitter<CameraState> emit) async {
    final result = await saveCapture(ImagePathParams(path));
    result.fold(
      (failure) => emit(state.copyWith(saving: false, message: failure.message)),
      (detection) => emit(
        state.copyWith(
          saving: false,
          detection: detection,
          status: detection.message,
          message: detection.message, // BlocConsumer muestra el SnackBar
        ),
      ),
    );
    _startTicker();
  }

  void _onApiUrlChanged(CameraApiUrlChanged event, Emitter<CameraState> emit) {
    if (event.url.isEmpty) {
      return;
    }
    repository.updateBaseUrl(event.url);
    emit(state.copyWith(apiUrl: repository.baseUrl));
  }

  /// Tras el SnackBar, [message] vuelve a null.
  void _onMessageConsumed(CameraMessageConsumed event, Emitter<CameraState> emit) {
    emit(state.copyWith(clearMessage: true));
  }

  Future<void> _onStopped(CameraStopped event, Emitter<CameraState> emit) async {
    _timer?.cancel();
    await device.close(state.session);
    emit(state.copyWith(clearSession: true));
  }

  /// Se llama al destruir el BlocProvider. Liberamos cámara y Timer.
  @override
  Future<void> close() async {
    _timer?.cancel();
    await device.close(state.session);
    return super.close();
  }
}
