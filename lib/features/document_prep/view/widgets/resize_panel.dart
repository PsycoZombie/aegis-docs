// file: features/document_prep/view/widgets/resize_panel.dart

import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
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

    // The AppScaffold is now the single, stable root widget.
    return AppScaffold(
      title: 'Resize Image',
      // The body changes based on the state, but the scaffold does not.
      body: viewModel.when(
        loading: () => const Center(child: NeumorphicProgressIndeterminate()),
        error: (err, _) => Center(child: Text('An error occurred: $err')),
        data: (state) {
          final hasOriginal = state.originalImage != null;
          if (hasOriginal) {
            return _buildContent(context, state, notifier);
          } else {
            return Center(
              child: NeumorphicButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  boxShape: NeumorphicBoxShape.roundRect(
                    BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => notifier.pickImage(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 24,
                      color: NeumorphicTheme.defaultTextColor(context),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Pick an Image',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: NeumorphicTheme.defaultTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // This helper builds ONLY the content column for when an image is present.
  Widget _buildContent(
    BuildContext context,
    ResizeState state,
    ResizeToolViewModel notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _ImagePreviewSection(state: state),
                const SizedBox(height: 12),
                _SizeReductionInfo(state: state),
              ],
            ),
          ),
        ),
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

// --- Helper Widgets ---

class _ImagePreviewSection extends StatelessWidget {
  final ResizeState state;
  const _ImagePreviewSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final hasResized = state.resizedImage != null;
    return Column(
      children: [
        NeumorphicText(
          "Image Preview",
          style: NeumorphicStyle(
            disableDepth: true,
            color: NeumorphicThemeData().defaultTextColor,
          ),
          textStyle: NeumorphicTextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                  : const SizedBox(width: 150, height: 150),
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
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.green.shade600,
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
    // CORRECTED: This widget no longer builds an AppScaffold.
    // It builds its own content directly.
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(16)),
        depth: 5,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              NeumorphicText(
                "Resize Options",
                style: NeumorphicStyle(
                  disableDepth: true,
                  color: NeumorphicThemeData().defaultTextColor,
                ),
                textStyle: NeumorphicTextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final scale in [0.75, 0.50, 0.25])
                    NeumorphicButton(
                      onPressed: () => notifier.applyPreset(scale: scale),
                      style: const NeumorphicStyle(
                        boxShape: NeumorphicBoxShape.stadium(),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text('${(scale * 100).toInt()}%'),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DimensionTextField(
                    controller: widthController,
                    label: 'Width',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4.0,
                      vertical: 8.0,
                    ),
                    child: NeumorphicButton(
                      style: NeumorphicStyle(
                        boxShape: NeumorphicBoxShape.circle(),
                        color: state.isAspectRatioLocked
                            ? NeumorphicTheme.accentColor(context)
                            : null,
                      ),
                      padding: const EdgeInsets.all(12),
                      onPressed: () => notifier.toggleAspectRatioLock(),
                      child: Icon(
                        state.isAspectRatioLocked ? Icons.link : Icons.link_off,
                        color: state.isAspectRatioLocked
                            ? NeumorphicTheme.baseColor(context)
                            : NeumorphicTheme.defaultTextColor(context),
                      ),
                    ),
                  ),
                  _DimensionTextField(
                    controller: heightController,
                    label: 'Height',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NeumorphicButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        notifier.resizeImage(
                          width: int.parse(widthController.text),
                          height: int.parse(heightController.text),
                        );
                      }
                    },
                    style: const NeumorphicStyle(depth: -3),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.aspect_ratio),
                        SizedBox(width: 8),
                        Text('Resize'),
                      ],
                    ),
                  ),
                  if (state.resizedImage != null)
                    NeumorphicButton(
                      onPressed: () async {
                        await notifier.saveResizedImage();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              behavior: SnackBarBehavior.floating,
                              content: Neumorphic(
                                style: NeumorphicStyle(
                                  color: Colors.green,
                                  depth: 3,
                                ),
                                padding: const EdgeInsets.all(16),
                                child: const Text(
                                  'Image saved successfully!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      style: NeumorphicStyle(
                        color: Colors.green.shade600,
                        depth: 3,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.save_alt_outlined, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Save', style: TextStyle(color: Colors.white)),
                        ],
                      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: NeumorphicTheme.defaultTextColor(
                  context,
                ).withAlpha((0.8 * 255).toInt()),
                fontSize: 13,
              ),
            ),
          ),
          Neumorphic(
            style: NeumorphicStyle(
              depth: -4, // Inset appearance
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
            ),
            child: TextFormField(
              controller: controller,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                suffixText: 'px',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 4,
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Req';
                if (int.tryParse(value) == null) return 'Inv';
                return null;
              },
            ),
          ),
        ],
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
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Neumorphic(
          style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              imageBytes,
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _formatSize(imageBytes.lengthInBytes),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (dimensions != null)
          Text(
            '${dimensions!.width.toInt()} x ${dimensions!.height.toInt()}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}
