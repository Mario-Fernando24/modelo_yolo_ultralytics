import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/capture_summary.dart';
import '../entities/detection_result.dart';

/// Contrato del dominio: "qué se puede hacer", no "cómo" (HTTP, JSON, etc.).
/// La implementación está en data/repositories/detection_repository_impl.dart.
///
/// Either: Left(Failure) = error, Right(T) = éxito. Así el BLoC no usa try/catch de red.
abstract class DetectionRepository {
  String get baseUrl;

  void updateBaseUrl(String url);

  String resolveMedia(String path);

  Future<Either<Failure, DetectionResult>> detectLive(String imagePath);

  Future<Either<Failure, DetectionResult>> saveCapture(String imagePath);

  Future<Either<Failure, List<CaptureSummary>>> getHistory();
}
