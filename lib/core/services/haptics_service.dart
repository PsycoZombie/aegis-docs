import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A global provider for accessing the HapticsService.
final hapticsProvider = Provider<HapticsService>((ref) {
  return HapticsService();
});

/// A service class for handling haptic feedback consistently across the app.
class HapticsService {
  /// Light impact, good for subtle UI interactions (e.g., button tap).
  Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact, stronger than light.
  Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact, strong haptic feedback for significant actions.
  Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// A selection click, best for list/grid selections.
  Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// A short vibration — often used for errors or warnings.
  Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }
}
