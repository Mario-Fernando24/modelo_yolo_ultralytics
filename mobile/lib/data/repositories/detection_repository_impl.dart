import 'package:dartz/dartz.dart';

import '../../core/constants/api_constants.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/capture_summary.dart';
import '../../domain/entities/detection_result.dart';
import '../../domain/repositories/detection_repository.dart';
import '../datasources/vision_remote_data_source.dart';

class DetectionRepositoryImpl implements DetectionRepository {
  DetectionRepositoryImpl({
    required this.remote,
    required this.config,
  });

  final VisionRemoteDataSource remote;
  final ApiConfig config;

  @override
  String get baseUrl => config.baseUrl;

  @override
  void updateBaseUrl(String url) => config.update(url);

  @override
  String resolveMedia(String path) => config.resolve(path);

  @override
  Future<Either<Failure, DetectionResult>> detectLive(String imagePath) async {
    try {
      return Right(await remote.detectLive(imagePath));
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (error) {
      return Left(ServerFailure('No se pudo analizar el fotograma: $error'));
    }
  }

  @override
  Future<Either<Failure, DetectionResult>> saveCapture(String imagePath) async {
    try {
      return Right(await remote.saveCapture(imagePath));
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (error) {
      return Left(ServerFailure('No se pudo guardar la fotografía: $error'));
    }
  }

  @override
  Future<Either<Failure, List<CaptureSummary>>> getHistory() async {
    try {
      return Right(await remote.getHistory());
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (error) {
      return Left(ServerFailure('No se pudo cargar el historial: $error'));
    }
  }
}
