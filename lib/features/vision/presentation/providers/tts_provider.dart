import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsState {
  final bool isSpeaking;
  final String? lastText;
  final bool isInitialized;

  TtsState({this.isSpeaking = false, this.lastText, this.isInitialized = false});

  TtsState copyWith({bool? isSpeaking, String? lastText, bool? isInitialized}) {
    return TtsState(
      isSpeaking: isSpeaking ?? this.isSpeaking,
      lastText: lastText ?? this.lastText,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

final ttsNotifierProvider =
    NotifierProvider<TtsNotifier, TtsState>(TtsNotifier.new);

class TtsNotifier extends Notifier<TtsState> {
  FlutterTts? _tts;

  @override
  TtsState build() {
    _initTts();
    return TtsState();
  }

  Future<void> _initTts() async {
    final tts = FlutterTts();
    await tts.setLanguage('en-US');
    await tts.setSpeechRate(0.48);
    await tts.setVolume(1.0);
    await tts.setPitch(1.0);

    tts.setCompletionHandler(() {
      state = state.copyWith(isSpeaking: false);
    });
    
    _tts = tts;
    state = state.copyWith(isInitialized: true);
  }

  Future<void> speak(String text) async {
    if (_tts == null) {
      await _initTts();
    }
    await _tts?.stop();
    state = state.copyWith(isSpeaking: true, lastText: text);
    await _tts?.speak(text);
  }

  Future<void> stop() async {
    if (_tts == null) return;
    await _tts?.stop();
    state = state.copyWith(isSpeaking: false);
  }

  Future<void> repeat() async {
    if (state.lastText != null) {
      await speak(state.lastText!);
    }
  }
}