import 'package:aegis_docs/features/document_prep/providers/resize_tool_provider.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/image_resize/image_preview_section.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/image_resize/options_card.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/image_resize/size_reduction_info.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageResizeScreen extends ConsumerStatefulWidget {
  const ImageResizeScreen({super.key});

  @override
  ConsumerState<ImageResizeScreen> createState() => _ImageResizePanelState();
}

class _ImageResizePanelState extends ConsumerState<ImageResizeScreen> {
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

    return AppScaffold(
      title: 'Resize Image',
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: viewModel.when(
          data: (state) => _buildContent(context, state, notifier),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('An error occurred: $err')),
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
    if (!hasOriginal) {
      return SingleChildScrollView(
        child: Center(
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
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ImagePreviewSection(state: state),
                const SizedBox(height: 12),
                SizeReductionInfo(state: state),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        OptionsCard(
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
