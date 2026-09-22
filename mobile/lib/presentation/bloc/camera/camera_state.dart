import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';

import '../../../data/datasources/device_data_source.dart';
import '../../../domain/entities/detection_result.dart';

/// Estado = "qué debe pintar la pantalla ahora".
/// Es inmutable: no se edita, se crea uno nuevo con [copyWith].
///
/// Flujo típico:
/// Evento (UI) → CameraBloc → nuevo CameraState → BlocBuilder redibuja.
class CameraState extends Equatable {
  const CameraState({
    this.session,
    this.detection,
    this.saving = false,
    this.busy = false,
    this.status = 'Apunta la cámara. Te diré si hay un automóvil y el porcentaje de cada objeto.',
    this.error,
    this.message,
    required this.apiUrl,
  });

  /// Sesión del plugin `camera` (preview + takePicture).
  final CameraSession? session;

  /// Último resultado de YOLO: objetos, porcentajes y si hay auto.
  final DetectionResult? detection;

  /// true mientras se sube la foto a POST /captures.
  final bool saving;

  /// true mientras un fotograma en vivo está en POST /detect.
  /// Evita mandar 2 frames a la vez.
  final bool busy;

  /// Texto de la franja ("Sí, es un automóvil (91%)…").
  final String status;

  /// Error al abrir la cámara (p. ej. simulador sin cámara).
  final String? error;

  /// Mensaje de un solo uso para el SnackBar. Luego se limpia.
  final String? message;

  /// URL de FastAPI que usa la app.
  final String apiUrl;

  CameraController? get controller => session?.controller;

  bool get isCameraReady => controller?.value.isInitialized == true;

  /// Copia el estado cambiando solo lo que pases.
  /// Los `clear*` existen porque `copyWith(error: null)` no distinguiría
  /// "no toques error" de "borra error".
  CameraState copyWith({
    CameraSession? session,
    DetectionResult? detection,
    bool? saving,
    bool? busy,
    String? status,
    String? error,
    String? message,
    String? apiUrl,
    bool clearSession = false,
    bool clearDetection = false,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return CameraState(
      session: clearSession ? null : (session ?? this.session),
      detection: clearDetection ? null : (detection ?? this.detection),
      saving: saving ?? this.saving,
      busy: busy ?? this.busy,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      message: clearMessage ? null : (message ?? this.message),
      apiUrl: apiUrl ?? this.apiUrl,
    );
  }

  /// Si cambian estos campos, BlocBuilder vuelve a construir la UI.
  @override
  List<Object?> get props => [
        session,
        detection,
        saving,
        busy,
        status,
        error,
        message,
        apiUrl,
      ];
}
