import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionary_ai/core/theme/app_theme.dart';
import 'package:visionary_ai/core/utils/haptic_utils.dart';
import 'package:visionary_ai/features/vision/presentation/providers/tts_provider.dart';

class ResultCard extends ConsumerStatefulWidget {
  final String description;

  const ResultCard({super.key, required this.description});

  @override
  ConsumerState<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends ConsumerState<ResultCard> {

  late final TtsNotifier _ttsNotifier;
  
  @override
  void initState() {
    super.initState();
    _ttsNotifier = ref.read(ttsNotifierProvider.notifier);
    _ttsNotifier.speak(widget.description);
  }
  
  @override
  void dispose() {
    _ttsNotifier.stop();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final ttsState = ref.watch(ttsNotifierProvider);
    return Semantics(
      liveRegion: true,
      label: 'AI description ready',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.success.withAlpha(77),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppTheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Semantics(
                  button: true,
                  label: ttsState.isSpeaking ? 'Stop description' : 'Repeat description',
                  child: TextButton.icon(
                    onPressed: () {
                      if (ttsState.isSpeaking) {
                        _ttsNotifier.stop();
                        return;
                      } else {
                        HapticUtils.onPlay();
                        _ttsNotifier.speak(widget.description);
                      }
                    },
                    icon: Icon(
                      ttsState.isSpeaking ? Icons.stop : Icons.volume_up,
                      color: AppTheme.accentColor,
                    ),
                    label: Text(
                      ttsState.isSpeaking ? 'Stop' : 'Repeat',
                      style: const TextStyle(color: AppTheme.accentColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}