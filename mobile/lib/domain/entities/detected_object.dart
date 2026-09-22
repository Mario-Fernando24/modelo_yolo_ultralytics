import 'package:equatable/equatable.dart';

class DetectedObject extends Equatable {
  const DetectedObject({
    required this.className,
    required this.labelEs,
    required this.confidence,
    required this.confidencePct,
    required this.x1n,
    required this.y1n,
    required this.x2n,
    required this.y2n,
  });

  final String className;
  final String labelEs;
  final double confidence;
  final double confidencePct;
  final double x1n;
  final double y1n;
  final double x2n;
  final double y2n;

  bool get isCar => className == 'car';

  @override
  List<Object?> get props => [
        className,
        labelEs,
        confidence,
        confidencePct,
        x1n,
        y1n,
        x2n,
        y2n,
      ];
}
