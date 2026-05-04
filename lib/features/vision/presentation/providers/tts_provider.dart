import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsState {
  final bool isSpeaking;
  final String? lastText;

  TtsState({this.isSpeaking = false, this.lastText});

  TtsState copyWith({bool? isSpeaking, String? lastText}) {
    return TtsState(
      isSpeaking: isSpeaking ?? this.isSpeaking,
      lastText: lastText ?? this.lastText,
    );
  }
}

final ttsNotifierProvider =
    NotifierProvider<TtsNotifier, TtsState>(TtsNotifier.new);

class TtsNotifier extends Notifier<TtsState> {
  late FlutterTts _tts;

  @override
  TtsState build() {
    _initTts();
    return TtsState();
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.48);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setCompletionHandler(() {
      state = state.copyWith(isSpeaking: false);
    });
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    state = state.copyWith(isSpeaking: true, lastText: text);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    state = state.copyWith(isSpeaking: false);
  }

  Future<void> repeat() async {
    if (state.lastText != null) {
      await speak(state.lastText!);
    }
  }
}