import 'package:equatable/equatable.dart';

import 'detected_object.dart';

class DetectionResult extends Equatable {
  const DetectionResult({
    required this.hasCar,
    required this.carCount,
    required this.carConfidence,
    required this.message,
    required this.objects,
    required this.latencyMs,
    this.id,
    this.imageUrl,
    this.annotatedUrl,
  });

  final bool hasCar;
  final int carCount;
  final double? carConfidence;
  final String message;
  final List<DetectedObject> objects;
  final int latencyMs;
  final String? id;
  final String? imageUrl;
  final String? annotatedUrl;

  @override
  List<Object?> get props => [
        hasCar,
        carCount,
        carConfidence,
        message,
        objects,
        latencyMs,
        id,
        imageUrl,
        annotatedUrl,
      ];
}
