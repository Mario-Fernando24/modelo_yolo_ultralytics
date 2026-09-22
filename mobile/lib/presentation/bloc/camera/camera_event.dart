import 'package:equatable/equatable.dart';

/// Evento = "qué pasó en la UI" (el usuario tocó un botón, arrancó la pantalla…).
/// El BLoC NUNCA llama a la UI: solo recibe eventos y emite estados.
///
/// Equatable sirve para que dos eventos iguales no se procesen como distintos.
abstract class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object?> get props => [];
}

/// Se dispara al abrir la app: hay que encender la cámara.
class CameraStarted extends CameraEvent {
  const CameraStarted();
}

/// Lo manda un Timer cada ~700 ms para analizar un fotograma en vivo
/// (sin guardarlo en PostgreSQL).
class CameraLiveTicked extends CameraEvent {
  const CameraLiveTicked();
}

/// El usuario pulsó "Tomar foto y guardar".
class CameraCapturePressed extends CameraEvent {
  const CameraCapturePressed();
}

/// El usuario eligió una imagen de la galería (útil si no hay cámara).
class CameraGalleryPressed extends CameraEvent {
  const CameraGalleryPressed();
}

/// Cambió la URL de FastAPI (engranaje), p. ej. la IP del teléfono.
class CameraApiUrlChanged extends CameraEvent {
  const CameraApiUrlChanged(this.url);

  final String url;

  @override
  List<Object?> get props => [url];
}

/// La UI ya mostró el SnackBar; limpiamos [CameraState.message]
/// para no volver a mostrarlo.
class CameraMessageConsumed extends CameraEvent {
  const CameraMessageConsumed();
}

/// Cerrar cámara y cancelar el Timer.
class CameraStopped extends CameraEvent {
  const CameraStopped();
}
