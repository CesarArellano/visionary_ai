import 'dart:typed_data';
import 'package:visionary_ai/features/vision/data/datasources/gemini_remote_datasource.dart';
import 'package:visionary_ai/features/vision/domain/entities/vision_result.dart';
import 'package:visionary_ai/features/vision/domain/repositories/vision_repository.dart';

class VisionRepositoryImpl implements VisionRepository {
  final GeminiRemoteDatasource _datasource;

  VisionRepositoryImpl({required GeminiRemoteDatasource datasource})
      : _datasource = datasource;

  @override
  Future<VisionResult> analyzeImage(Uint8List imageBytes) async {
    final description = await _datasource.analyzeImage(imageBytes);
    return VisionResult(
      description: description,
      timestamp: DateTime.now(),
    );
  }
}