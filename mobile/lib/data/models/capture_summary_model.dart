import '../../domain/entities/capture_summary.dart';

class CaptureSummaryModel extends CaptureSummary {
  const CaptureSummaryModel({
    required super.id,
    required super.createdAt,
    required super.hasCar,
    required super.summary,
    required super.objectCount,
    required super.imageUrl,
    super.annotatedUrl,
  });

  factory CaptureSummaryModel.fromJson(Map<String, dynamic> json) {
    return CaptureSummaryModel(
      id: json['id'].toString(),
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      hasCar: json['has_car'] as bool? ?? false,
      summary: json['summary'] as String? ?? '',
      objectCount: json['object_count'] as int? ?? 0,
      imageUrl: json['image_url'] as String,
      annotatedUrl: json['annotated_url'] as String?,
    );
  }
}
