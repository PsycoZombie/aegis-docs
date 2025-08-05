import 'package:aegis_docs/features/document_prep/providers/resize_tool_provider.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/image_resize/dimension_textfield.dart';
import 'package:flutter/material.dart';

class OptionsCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController widthController;
  final TextEditingController heightController;
  final ResizeState state;
  final ResizeToolViewModel notifier;
  final VoidCallback onSave;

  const OptionsCard({
    super.key,
    required this.formKey,
    required this.widthController,
    required this.heightController,
    required this.state,
    required this.notifier,
    required this.onSave,
  });

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
                "Resize Options",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final scale in [0.75, 0.50, 0.25])
                    FilterChip(
                      label: Text('${(scale * 100).toInt()}%'),
                      onSelected: (_) => notifier.applyPreset(scale: scale),
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
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: IconButton(
                      icon: Icon(
                        state.isAspectRatioLocked ? Icons.link : Icons.link_off,
                      ),
                      onPressed: () => notifier.toggleAspectRatioLock(),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  DimensionTextField(
                    controller: heightController,
                    label: 'Height',
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
                    icon: const Icon(Icons.aspect_ratio),
                    label: const Text('Resize'),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        notifier.resizeImage(
                          width: int.parse(widthController.text),
                          height: int.parse(heightController.text),
                        );
                      }
                    },
                  ),
                  if (state.resizedImage != null)
                    FilledButton.icon(
                      icon: const Icon(Icons.save_alt_outlined),
                      label: const Text('Save'),
                      onPressed: onSave,
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
