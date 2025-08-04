// file: features/document_prep/view/widgets/image_editing/editing_toolbar.dart

import 'package:flutter/material.dart';

class EditingToolbar extends StatelessWidget {
  final VoidCallback onCrop;
  final VoidCallback? onUndo; // Nullable because it can be disabled
  final VoidCallback? onGrayscale;

  const EditingToolbar({
    super.key,
    required this.onCrop,
    this.onUndo,
    this.onGrayscale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withAlpha((0.5 * 255).toInt()),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ToolButton(
            icon: Icons.undo,
            label: 'Undo',
            // Disable the button if onUndo is null
            onPressed: onUndo,
          ),
          _ToolButton(icon: Icons.edit, label: 'Edit', onPressed: onCrop),
          _ToolButton(
            icon: Icons.filter_b_and_w,
            label: 'B & W',
            onPressed: onGrayscale,
          ),
          // We can add more buttons here later
          // _ToolButton(icon: Icons.rotate_90_degrees_ccw, label: 'Rotate'),
          // _ToolButton(icon: Icons.draw, label: 'Draw'),
          // _ToolButton(icon: Icons.blur_on, label: 'Blur'),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _ToolButton({required this.icon, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: onPressed != null
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: onPressed != null
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
