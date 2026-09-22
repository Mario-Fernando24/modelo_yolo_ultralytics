import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/capture_summary.dart';
import '../repositories/detection_repository.dart';

class GetHistory implements UseCase<List<CaptureSummary>, NoParams> {
  GetHistory(this.repository);

  final DetectionRepository repository;

  @override
  Future<Either<Failure, List<CaptureSummary>>> call(NoParams params) {
    return repository.getHistory();
  }
}
