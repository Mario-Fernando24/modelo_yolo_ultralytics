import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/error/exceptions.dart';

class CameraSession {
  CameraSession(this.controller);

  final CameraController controller;
}

abstract class DeviceDataSource {
  Future<CameraSession> openCamera();

  Future<String> takePicture(CameraSession session);

  Future<String?> pickFromGallery();

  Future<void> close(CameraSession? session);
}

class DeviceDataSourceImpl implements DeviceDataSource {
  DeviceDataSourceImpl({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<CameraSession> openCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw DeviceException('No hay cámara. Puedes analizar una foto de la galería.');
      }
      final selected = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        selected,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      return CameraSession(controller);
    } on DeviceException {
      rethrow;
    } catch (error) {
      throw DeviceException('No se pudo abrir la cámara: $error');
    }
  }

  @override
  Future<String> takePicture(CameraSession session) async {
    final controller = session.controller;
    if (!controller.value.isInitialized) {
      throw DeviceException('La cámara no está lista.');
    }
    if (controller.value.isTakingPicture) {
      throw DeviceException('La cámara está ocupada.');
    }
    try {
      final shot = await controller.takePicture();
      return shot.path;
    } catch (error) {
      throw DeviceException('No se pudo tomar la foto: $error');
    }
  }

  @override
  Future<String?> pickFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    return picked?.path;
  }

  @override
  Future<void> close(CameraSession? session) async {
    await session?.controller.dispose();
  }
}
