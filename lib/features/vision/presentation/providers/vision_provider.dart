import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:visionary_ai/core/injection/injection_container.dart';
import 'package:visionary_ai/core/providers/core_providers.dart';
import 'package:visionary_ai/core/utils/image_utils.dart';
import 'package:visionary_ai/features/history/domain/entities/history_entry.dart';
import 'package:visionary_ai/features/vision/domain/entities/vision_result.dart';

final visionNotifierProvider =
    AsyncNotifierProvider<VisionNotifier, VisionResult?>(VisionNotifier.new);

class VisionNotifier extends AsyncNotifier<VisionResult?> {
  @override
  Future<VisionResult?> build() async {
    return null;
  }

  Future<void> analyzeImage(XFile image) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final compressed = await sl<ImageUtils>().compress(image);
      final result =
          await ref.read(visionRepositoryProvider).analyzeImage(compressed);
      final historyEntry = HistoryEntry(
        id: const Uuid().v4(),
        description: result.description,
        timestamp: result.timestamp,
      );
      await ref.read(historyRepositoryProvider).save(historyEntry);
      return result;
    });
  }

  void clearResult() {
    state = const AsyncData(null);
  }
}