import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../core/error/exceptions.dart';
import '../models/capture_summary_model.dart';
import '../models/detection_result_model.dart';

abstract class VisionRemoteDataSource {
  Future<DetectionResultModel> detectLive(String imagePath);

  Future<DetectionResultModel> saveCapture(String imagePath);

  Future<List<CaptureSummaryModel>> getHistory();
}

class VisionRemoteDataSourceImpl implements VisionRemoteDataSource {
  VisionRemoteDataSourceImpl({
    required this.client,
    required this.config,
  });

  final http.Client client;
  final ApiConfig config;

  @override
  Future<DetectionResultModel> detectLive(String imagePath) {
    return _postImage(ApiConstants.detectPath, imagePath);
  }

  @override
  Future<DetectionResultModel> saveCapture(String imagePath) {
    return _postImage(ApiConstants.capturesPath, imagePath);
  }

  @override
  Future<List<CaptureSummaryModel>> getHistory() async {
    final response = await client
        .get(Uri.parse('${config.baseUrl}${ApiConstants.capturesPath}'))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode >= 400) {
      throw ServerException('No se pudo cargar el historial (${response.statusCode})');
    }
    final data = jsonDecode(response.body) as List<dynamic>;

    print('VisionRemoteDataSourceImpl.getHistory: ${data.length} items');
    return data
        .map((item) => CaptureSummaryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<DetectionResultModel> _postImage(String path, String imagePath) async {
    final request = http.MultipartRequest('POST', Uri.parse('${config.baseUrl}$path'));
    request.files.add(await http.MultipartFile.fromPath('file', imagePath));
    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode >= 400) {
      throw ServerException('Error del servidor (${streamed.statusCode}): $body');
    }
    return DetectionResultModel.fromJson(jsonDecode(body) as Map<String, dynamic>);
  }
}
