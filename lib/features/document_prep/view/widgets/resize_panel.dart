// modernized_resize_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/resize_tool_provider.dart';

class ResizePanel extends ConsumerStatefulWidget {
  const ResizePanel({super.key});

  @override
  ConsumerState<ResizePanel> createState() => _ResizePanelState();
}

class _ResizePanelState extends ConsumerState<ResizePanel> {
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(resizeToolViewModelProvider);
    final notifier = ref.read(resizeToolViewModelProvider.notifier);

    ref.listen(resizeToolViewModelProvider, (_, next) {
      final dimensions = next.value?.originalDimensions;
      if (dimensions != null) {
        _widthController.text = dimensions.width.toInt().toString();
        _heightController.text = dimensions.height.toInt().toString();
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: viewModel.when(
          data: (state) => _buildContent(context, state, notifier),
          loading: () => const Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(),
          ),
          error: (err, _) => Text('Error: $err'),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ResizeState state,
    ResizeToolViewModel notifier,
  ) {
    final hasOriginal = state.originalImage != null;
    final hasResized = state.resizedImage != null;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: !hasOriginal
          ? FilledButton.icon(
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Pick an Image'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: Theme.of(context).textTheme.titleMedium,
              ),
              onPressed: () => notifier.pickImage(),
            )
          : Column(
              key: const ValueKey("content"),
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Image Preview",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Wrap(
                      spacing: 24,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        _ImagePreview(
                          label: 'Original',
                          imageBytes: state.originalImage!,
                          dimensions: state.originalDimensions,
                        ),
                        if (hasResized)
                          _ImagePreview(
                            label: 'Resized',
                            imageBytes: state.resizedImage!,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            "Resize Options",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _DimensionTextField(
                                controller: _widthController,
                                label: 'Width',
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('x'),
                              ),
                              _DimensionTextField(
                                controller: _heightController,
                                label: 'Height',
                              ),
                              const SizedBox(width: 8),
                              const Text('px'),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 16,
                            children: [
                              FilledButton.icon(
                                icon: const Icon(Icons.aspect_ratio),
                                label: const Text('Resize Image'),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    final width = int.parse(
                                      _widthController.text,
                                    );
                                    final height = int.parse(
                                      _heightController.text,
                                    );
                                    notifier.resizeImage(
                                      width: width,
                                      height: height,
                                    );
                                  }
                                },
                              ),
                              if (hasResized)
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.save_alt_outlined),
                                  label: const Text('Save'),
                                  onPressed: () async {
                                    await notifier.saveResizedImage();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Image saved successfully!',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _DimensionTextField extends StatelessWidget {
  const _DimensionTextField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (value == null || value.isEmpty) return 'Required';
          if (int.tryParse(value) == null) return 'Invalid';
          return null;
        },
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.label,
    required this.imageBytes,
    this.dimensions,
  });

  final String label;
  final Uint8List imageBytes;
  final Size? dimensions;

  String _formatSize(int bytes) => '${(bytes / 1024).toStringAsFixed(2)} KB';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            imageBytes,
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 8),
        Text(_formatSize(imageBytes.lengthInBytes)),
        if (dimensions != null)
          Text('${dimensions!.width.toInt()} x ${dimensions!.height.toInt()}'),
      ],
    );
  }
}
