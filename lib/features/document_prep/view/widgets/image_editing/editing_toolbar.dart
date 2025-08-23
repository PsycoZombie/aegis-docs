import 'package:flutter/material.dart';

/// A toolbar widget that displays a row of image editing actions.
class EditingToolbar extends StatelessWidget {
  /// Creates an instance of [EditingToolbar].
  const EditingToolbar({
    required this.onCrop,
    this.onUndo,
    this.onGrayscale,
    this.isProcessing = false,
    super.key,
  });

  /// A callback function for the crop action.
  final VoidCallback onCrop;

  /// An optional callback for the undo action. If null, the button is disabled.
  final VoidCallback? onUndo;

  /// An optional callback for the grayscale filter action.
  final VoidCallback? onGrayscale;

  /// A flag indicating if an editing operation is currently in progress.
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      // Use a semi-transparent background to overlay the image slightly.
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withAlpha((0.5 * 255).toInt()),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ToolButton(
            icon: Icons.undo,
            label: 'Undo',
            // Disable the button if an operation is in progress or
            // if there's nothing to undo.
            onPressed: isProcessing ? null : onUndo,
          ),
          _ToolButton(
            icon: Icons.crop,
            label: 'Crop',
            onPressed: isProcessing ? null : onCrop,
          ),
          _ToolButton(
            icon: Icons.filter_b_and_w,
            label: 'B & W',
            onPressed: isProcessing ? null : onGrayscale,
          ),
        ],
      ),
    );
  }
}

/// A private helper widget for a single button in the editing toolbar.
class _ToolButton extends StatelessWidget {
  /// Creates an instance of [_ToolButton].
  const _ToolButton({required this.icon, required this.label, this.onPressed});

  /// The icon to display for the button.
  final IconData icon;

  /// The text label to display below the icon.
  final String label;

  /// The callback to invoke when the button is tapped. If null, the button
  /// will be displayed in a disabled state.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isEnabled
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isEnabled
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
