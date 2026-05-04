import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visionary_ai/core/theme/app_theme.dart';
import 'package:visionary_ai/core/utils/haptic_utils.dart';
import 'package:visionary_ai/features/vision/presentation/providers/tts_provider.dart';
import 'package:visionary_ai/features/vision/presentation/providers/vision_provider.dart';
import 'package:visionary_ai/features/vision/presentation/widgets/capture_button.dart';
import 'package:visionary_ai/features/vision/presentation/widgets/result_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visionState = ref.watch(visionNotifierProvider);
    final ttsState = ref.watch(ttsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visionary AI'),
        actions: [
          Semantics(
            button: true,
            label: 'About',
            child: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => context.push('/info'),
              tooltip: 'About',
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: visionState.when(
                    data: (result) {
                      if (result != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!ttsState.isSpeaking) {
                            ref.read(ttsNotifierProvider.notifier).speak(result.description);
                            HapticUtils.onResult();
                          }
                        });
                        return ResultCard(description: result.description);
                      }
                      return _buildIdleState();
                    },
                    loading: () => _buildLoadingState(),
                    error: (error, stack) => _buildErrorState(error, ref),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const CaptureButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: Semantics(
        button: true,
        label: 'History',
        child: FloatingActionButton(
          onPressed: () => context.push('/history'),
          child: const Icon(Icons.history),
        ),
      ),
    );
  }

  Widget _buildIdleState() {
    return Semantics(
      label: 'Tap the button to describe your environment',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 64,
            color: AppTheme.onSurface.withAlpha(128),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tap the button to describe your environment',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Semantics(
      label: 'Analyzing',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppTheme.accentColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'Analyzing...',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, WidgetRef ref) {
    HapticUtils.onError();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ttsNotifierProvider.notifier).speak('Something went wrong. Please try again.');
    });
    return Semantics(
      liveRegion: true,
      label: 'Error occurred',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: ${error.toString()}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.error,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(visionNotifierProvider.notifier).clearResult(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}