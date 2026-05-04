import 'dart:typed_data';
import 'package:visionary_ai/features/vision/domain/entities/vision_result.dart';

abstract class VisionRepository {
  Future<VisionResult> analyzeImage(Uint8List imageBytes);
}