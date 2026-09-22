import 'package:flutter_test/flutter_test.dart';
import 'package:visionai_app/data/models/detected_object_model.dart';
import 'package:visionai_app/data/models/detection_result_model.dart';

void main() {
  test('el modelo de datos mapea un automóvil al entity del dominio', () {
    final result = DetectionResultModel.fromJson({
      'has_car': true,
      'car_count': 1,
      'car_confidence': 0.91,
      'message': 'Sí, es un automóvil (91%).',
      'latency_ms': 40,
      'objects': [
        {
          'class_name': 'car',
          'label_es': 'Automóvil',
          'confidence': 0.91,
          'confidence_pct': 91.0,
          'x1n': 0.1,
          'y1n': 0.2,
          'x2n': 0.8,
          'y2n': 0.9,
        },
      ],
    });
    expect(result.hasCar, isTrue);
    expect(result.objects.first, isA<DetectedObjectModel>());
    expect(result.objects.first.isCar, isTrue);
    expect(result.objects.first.confidencePct, 91.0);
  });
}
