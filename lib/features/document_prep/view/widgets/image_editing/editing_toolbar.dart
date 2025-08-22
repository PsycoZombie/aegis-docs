import 'package:flutter/material.dart';

class EditingToolbar extends StatelessWidget {

  const EditingToolbar({
    required this.onCrop, super.key,
    this.onUndo,
    this.onGrayscale,
  });
  final VoidCallback onCrop;
  final VoidCallback? onUndo;
  final VoidCallback? onGrayscale;

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
          _ToolButton(icon: Icons.undo, label: 'Undo', onPressed: onUndo),
          _ToolButton(icon: Icons.edit, label: 'Edit', onPressed: onCrop),
          _ToolButton(
            icon: Icons.filter_b_and_w,
            label: 'B & W',
            onPressed: onGrayscale,
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {

  const _ToolButton({required this.icon, required this.label, this.onPressed});
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
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
