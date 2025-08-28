import 'package:aegis_docs/core/services/haptics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Defines the different types of toasts to display, each with a distinct
/// color and icon.
enum ToastType {
  /// For successful operations (green).
  success,

  /// For errors or failures (red).
  error,

  /// For warnings or non-critical issues (orange).
  warning,

  /// For general information (blue).
  info,
}

/// Displays a custom toast notification at the bottom of the screen.
///
/// [context]: The build context from which to show the toast.
/// [message]: The text to display in the toast.
/// [type]: The [ToastType] which determines the color and icon.

void showToast(
  BuildContext context,
  String message, {
  ToastType type = ToastType.success,
}) {
  // Trigger haptic feedback based on toast type
  final container = ProviderScope.containerOf(context, listen: false);
  final haptics = container.read(hapticsProvider);

  switch (type) {
    case ToastType.success:
      haptics.lightImpact();
    case ToastType.error:
      haptics.vibrate();
    case ToastType.warning:
      haptics.mediumImpact();
    case ToastType.info:
      haptics.selectionClick();
  }

  // Create an OverlayEntry to hold our toast widget.
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 50,
      left: MediaQuery.of(context).size.width * 0.1,
      right: MediaQuery.of(context).size.width * 0.1,
      child: _ToastWidget(message: message, type: type),
    ),
  );

  Overlay.of(context).insert(overlayEntry);
  Future.delayed(const Duration(seconds: 3), overlayEntry.remove);
}

/// The private widget that builds the UI for the toast.
class _ToastWidget extends StatelessWidget {
  const _ToastWidget({required this.message, required this.type});
  final String message;
  final ToastType type;

  // Helper method to get the color based on the ToastType.
  Color _getColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Colors.green.shade700;
      case ToastType.error:
        return Colors.red.shade700;
      case ToastType.warning:
        return Colors.orange.shade700;
      case ToastType.info:
        return Colors.blue.shade700;
    }
  }

  // Helper method to get the icon based on the ToastType.
  IconData _getIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.warning:
        return Icons.warning_amber_rounded;
      case ToastType.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _getColor(type),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIcon(type),
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
