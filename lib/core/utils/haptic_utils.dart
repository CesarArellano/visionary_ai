import 'package:flutter/services.dart';

class HapticUtils {
  static void onCapture() => HapticFeedback.mediumImpact();
  static void onResult() => HapticFeedback.heavyImpact();
  static void onError() => HapticFeedback.vibrate();
  static void onPlay() => HapticFeedback.lightImpact();
}