import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/detection_result.dart';
import '../repositories/detection_repository.dart';

class SaveCapture implements UseCase<DetectionResult, ImagePathParams> {
  SaveCapture(this.repository);

  final DetectionRepository repository;

  @override
  Future<Either<Failure, DetectionResult>> call(ImagePathParams params) {
    return repository.saveCapture(params.path);
  }
}
