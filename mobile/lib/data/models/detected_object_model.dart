import '../../domain/entities/detected_object.dart';

class DetectedObjectModel extends DetectedObject {
  const DetectedObjectModel({
    required super.className,
    required super.labelEs,
    required super.confidence,
    required super.confidencePct,
    required super.x1n,
    required super.y1n,
    required super.x2n,
    required super.y2n,
  });

  factory DetectedObjectModel.fromJson(Map<String, dynamic> json) {
    return DetectedObjectModel(
      className: json['class_name'] as String,
      labelEs: json['label_es'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      confidencePct: (json['confidence_pct'] as num).toDouble(),
      x1n: (json['x1n'] as num).toDouble(),
      y1n: (json['y1n'] as num).toDouble(),
      x2n: (json['x2n'] as num).toDouble(),
      y2n: (json['y2n'] as num).toDouble(),
    );
  }
}
