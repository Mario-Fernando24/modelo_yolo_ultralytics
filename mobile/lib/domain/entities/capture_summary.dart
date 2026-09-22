import 'package:equatable/equatable.dart';

class CaptureSummary extends Equatable {
  const CaptureSummary({
    required this.id,
    required this.createdAt,
    required this.hasCar,
    required this.summary,
    required this.objectCount,
    required this.imageUrl,
    this.annotatedUrl,
  });

  final String id;
  final DateTime createdAt;
  final bool hasCar;
  final String summary;
  final int objectCount;
  final String imageUrl;
  final String? annotatedUrl;

  @override
  List<Object?> get props => [
        id,
        createdAt,
        hasCar,
        summary,
        objectCount,
        imageUrl,
        annotatedUrl,
      ];
}
