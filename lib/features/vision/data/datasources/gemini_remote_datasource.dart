import 'dart:typed_data';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:visionary_ai/core/constants/app_constants.dart';

class GeminiRemoteDatasource {
  final FirebaseAI _firebaseAI;

  GeminiRemoteDatasource({required FirebaseAI firebaseAI})
      : _firebaseAI = firebaseAI;

  Future<String> analyzeImage(Uint8List imageBytes) async {
    final model = _firebaseAI.generativeModel(model: AppConstants.kGeminiModel);
    final imagePart = InlineDataPart('image/jpeg', imageBytes);
    final textPart = TextPart(AppConstants.kVisionPrompt);
    final response = await model.generateContent([
      Content.multi([imagePart, textPart])
    ]);
    return response.text ?? 'No description available.';
  }
}