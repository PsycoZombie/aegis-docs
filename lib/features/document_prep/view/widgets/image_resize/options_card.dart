import 'package:aegis_docs/features/document_prep/providers/image_resize_provider.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/image_resize/dimension_textfield.dart';
import 'package:flutter/material.dart';

/// A card containing the user-configurable options for resizing an image.
class OptionsCard extends StatelessWidget {
  /// Creates an instance of [OptionsCard].
  const OptionsCard({
    required this.formKey,
    required this.widthController,
    required this.heightController,
    required this.state,
    required this.notifier,
    required this.isProcessing,
    required this.onSave,
    super.key,
  });

  /// A global key for the form to handle validation.
  final GlobalKey<FormState> formKey;

  /// The controller for the width text field.
  final TextEditingController widthController;

  /// The controller for the height text field.
  final TextEditingController heightController;

  /// The current state from the [ImageResizeViewModel].
  final ResizeState state;

  /// The notifier for the [ImageResizeViewModel].
  final ImageResizeViewModel notifier;

  /// A flag indicating if a resize or save operation is in progress.
  final bool isProcessing;

  /// A callback function to be invoked when the "Save" button is tapped.
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Text(
                'Resize Options',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              // Preset buttons for common resize scales.
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final scale in [0.75, 0.50, 0.25])
                    FilterChip(
                      label: Text('${(scale * 100).toInt()}%'),
                      // Disable presets while processing.
                      onSelected: isProcessing
                          ? null
                          : (_) => notifier.applyPreset(scale: scale),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DimensionTextField(
                    controller: widthController,
                    label: 'Width',
                    enabled: !isProcessing,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: IconButton(
                      icon: Icon(
                        state.isAspectRatioLocked ? Icons.link : Icons.link_off,
                      ),
                      onPressed: isProcessing
                          ? null
                          : notifier.toggleAspectRatioLock,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  DimensionTextField(
                    controller: heightController,
                    label: 'Height',
                    enabled: !isProcessing,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    icon: isProcessing
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.aspect_ratio),
                    label: const Text('Resize'),
                    onPressed: isProcessing
                        ? null
                        : () {
                            if (formKey.currentState!.validate()) {
                              notifier.resizeImage(
                                width: int.parse(widthController.text),
                                height: int.parse(heightController.text),
                              );
                            }
                          },
                  ),
                  // Only show the save button after a resize has occurred.
                  if (state.resizedImage != null)
                    FilledButton.icon(
                      icon: const Icon(Icons.save_alt_outlined),
                      label: const Text('Save'),
                      onPressed: isProcessing ? null : onSave,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
