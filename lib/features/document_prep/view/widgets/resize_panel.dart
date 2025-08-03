import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Assuming your provider file and state model are in this location
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

  // To prevent infinite loops when updating controllers
  bool _isUpdatingFromListener = false;

  @override
  void initState() {
    super.initState();
    _widthController.addListener(_onWidthChanged);
    _heightController.addListener(_onHeightChanged);
  }

  @override
  void dispose() {
    _widthController.removeListener(_onWidthChanged);
    _heightController.removeListener(_onHeightChanged);
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _onWidthChanged() {
    final state = ref.read(resizeToolViewModelProvider).value;
    if (_isUpdatingFromListener ||
        state == null ||
        !state.isAspectRatioLocked) {
      return;
    }

    final originalDims = state.originalDimensions;
    if (originalDims == null || originalDims.width == 0) return;

    final width = int.tryParse(_widthController.text);
    if (width != null) {
      final newHeight = (width * originalDims.height / originalDims.width)
          .round();
      _isUpdatingFromListener = true;
      _heightController.text = newHeight.toString();
      _isUpdatingFromListener = false;
    }
  }

  void _onHeightChanged() {
    final state = ref.read(resizeToolViewModelProvider).value;
    if (_isUpdatingFromListener ||
        state == null ||
        !state.isAspectRatioLocked) {
      return;
    }

    final originalDims = state.originalDimensions;
    if (originalDims == null || originalDims.height == 0) return;

    final height = int.tryParse(_heightController.text);
    if (height != null) {
      final newWidth = (height * originalDims.width / originalDims.height)
          .round();
      _isUpdatingFromListener = true;
      _widthController.text = newWidth.toString();
      _isUpdatingFromListener = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(resizeToolViewModelProvider);
    final notifier = ref.read(resizeToolViewModelProvider.notifier);

    ref.listen(resizeToolViewModelProvider, (_, next) {
      if (next.isLoading) return;
      final state = next.value;
      if (state != null) {
        final currentWidth =
            state.originalDimensions?.width.toInt().toString() ?? '';
        final currentHeight =
            state.originalDimensions?.height.toInt().toString() ?? '';

        if (_widthController.text != currentWidth) {
          _widthController.text = currentWidth;
        }
        if (_heightController.text != currentHeight) {
          _heightController.text = currentHeight;
        }
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: viewModel.when(
        data: (state) => _buildContent(context, state, notifier),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, _) => Center(child: Text('An error occurred: $err')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ResizeState state,
    ResizeToolViewModel notifier,
  ) {
    final hasOriginal = state.originalImage != null;
    if (!hasOriginal) {
      return Center(
        child: FilledButton.icon(
          icon: const Icon(Icons.add_photo_alternate_outlined, size: 24),
          label: const Text('Pick an Image'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          onPressed: () => notifier.pickImage(),
        ),
      );
    }

    return Column(
      key: const ValueKey("content"),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _ImagePreviewSection(state: state),
        const SizedBox(height: 12),
        _SizeReductionInfo(state: state),
        const SizedBox(height: 24),
        _OptionsCard(
          formKey: _formKey,
          widthController: _widthController,
          heightController: _heightController,
          state: state,
          notifier: notifier,
        ),
      ],
    );
  }
}

// --- Helper Widgets for Cleaner Build Method ---

class _ImagePreviewSection extends StatelessWidget {
  final ResizeState state;
  const _ImagePreviewSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final hasResized = state.resizedImage != null;
    return Column(
      children: [
        Text("Image Preview", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            _ImagePreview(
              label: 'Original',
              imageBytes: state.originalImage!,
              dimensions: state.originalDimensions,
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: hasResized
                  ? _ImagePreview(
                      label: 'Resized',
                      imageBytes: state.resizedImage!,
                    )
                  : const SizedBox(width: 150, height: 150), // Placeholder
            ),
          ],
        ),
      ],
    );
  }
}

class _SizeReductionInfo extends StatelessWidget {
  final ResizeState state;
  const _SizeReductionInfo({required this.state});

  @override
  Widget build(BuildContext context) {
    final hasResized = state.resizedImage != null;
    if (!hasResized) return const SizedBox.shrink();

    final originalSize = state.originalImage!.lengthInBytes;
    final resizedSize = state.resizedImage!.lengthInBytes;
    final reduction = ((originalSize - resizedSize) / originalSize * 100);

    return Text(
      reduction > 0
          ? '✨ File size reduced by ${reduction.toStringAsFixed(1)}%'
          : '',
      style: TextStyle(
        color: Colors.green.shade700,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}

class _OptionsCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController widthController;
  final TextEditingController heightController;
  final ResizeState state;
  final ResizeToolViewModel notifier;

  const _OptionsCard({
    required this.formKey,
    required this.widthController,
    required this.heightController,
    required this.state,
    required this.notifier,
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
              // Preset Chips
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
              // Dimension Inputs with Lock
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _DimensionTextField(
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
                  _DimensionTextField(
                    controller: heightController,
                    label: 'Height',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
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
                      onPressed: () async {
                        await notifier.saveResizedImage();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Image saved successfully!'),
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
      width: 90,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          suffixText: 'px',
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (value == null || value.isEmpty) return 'Req';
          if (int.tryParse(value) == null) return 'Inv';
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
