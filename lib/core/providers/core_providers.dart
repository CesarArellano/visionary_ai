import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionary_ai/core/injection/injection_container.dart';
import 'package:visionary_ai/features/history/domain/repositories/history_repository.dart';
import 'package:visionary_ai/features/vision/domain/repositories/vision_repository.dart';

final visionRepositoryProvider = Provider<VisionRepository>((ref) {
  return sl<VisionRepository>();
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return sl<HistoryRepository>();
});