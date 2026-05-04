import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionary_ai/core/theme/app_theme.dart';
import 'package:visionary_ai/core/utils/haptic_utils.dart';
import 'package:visionary_ai/features/vision/presentation/providers/vision_provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/injection/injection_container.dart';

class CaptureButton extends ConsumerWidget {
  const CaptureButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visionState = ref.watch(visionNotifierProvider);

    return Semantics(
      button: true,
      label: 'Take a photo',
      child: IconButton(
        onPressed: visionState.isLoading
            ? null
            : () async {
                HapticUtils.onCapture();
                final picker = sl<ImagePicker>();
                final image = await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  ref.read(visionNotifierProvider.notifier).analyzeImage(image);
                }
              },
        icon: Icon(
          Icons.camera_alt,
          color: AppTheme.onPrimary,
          size: 36,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryVariant,
          disabledBackgroundColor: AppTheme.primaryVariant.withValues(alpha: 0.6),
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(20),
        ),
      ),
    );
  }
}