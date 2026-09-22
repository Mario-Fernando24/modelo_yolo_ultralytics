import '../../domain/entities/detection_result.dart';
import 'detected_object_model.dart';

class DetectionResultModel extends DetectionResult {
  const DetectionResultModel({
    required super.hasCar,
    required super.carCount,
    required super.carConfidence,
    required super.message,
    required super.objects,
    required super.latencyMs,
    super.id,
    super.imageUrl,
    super.annotatedUrl,
  });

  factory DetectionResultModel.fromJson(Map<String, dynamic> json) {
    final raw = json['objects'] as List<dynamic>? ?? const [];
    return DetectionResultModel(
      hasCar: json['has_car'] as bool? ?? false,
      carCount: json['car_count'] as int? ?? 0,
      carConfidence: (json['car_confidence'] as num?)?.toDouble(),
      message: json['message'] as String? ?? '',
      objects: raw
          .map((item) => DetectedObjectModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      latencyMs: json['latency_ms'] as int? ?? 0,
      id: json['id']?.toString(),
      imageUrl: json['image_url'] as String?,
      annotatedUrl: json['annotated_url'] as String?,
    );
  }
}
