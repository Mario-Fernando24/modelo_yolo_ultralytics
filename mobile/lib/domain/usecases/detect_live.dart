import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/detection_result.dart';
import '../repositories/detection_repository.dart';

/// Caso de uso: "analizar un fotograma sin guardarlo".
/// El BLoC no habla con HTTP; llama a esto y el repositorio habla con FastAPI.
class DetectLive implements UseCase<DetectionResult, ImagePathParams> {
  DetectLive(this.repository);

  final DetectionRepository repository;

  @override
  Future<Either<Failure, DetectionResult>> call(ImagePathParams params) {
    return repository.detectLive(params.path);
  }
}
