import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/features/document_prep/providers/image_resize_provider.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/image_resize/image_preview_section.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/image_resize/options_card.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/image_resize/size_reduction_info.dart';
import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:aegis_docs/shared_widgets/save_options_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

/// A screen for resizing an image to new dimensions.
class ImageResizeScreen extends ConsumerStatefulWidget {
  /// Creates an instance of [ImageResizeScreen].
  const ImageResizeScreen({super.key, this.initialFile});

  /// The initial image file to be processed.
  final PickedFileModel? initialFile;

  @override
  ConsumerState<ImageResizeScreen> createState() => _ImageResizeScreenState();
}

class _ImageResizeScreenState extends ConsumerState<ImageResizeScreen> {
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  /// A flag to prevent infinite loops between the width and height listeners
  /// when the aspect ratio is locked.
  bool _isUpdatingFromListener = false;

  /// A flag to ensure the initial dimensions are only set once.
  bool _initialValuesSet = false;

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

  /// Listener that triggers when the width text field changes.
  /// If the aspect ratio is locked, it
  /// calculates and sets the corresponding height.
  void _onWidthChanged() {
    final state = ref
        .read(imageResizeViewModelProvider(widget.initialFile))
        .value;
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

  /// Listener that triggers when the height text field changes.
  /// If the aspect ratio is locked, it
  /// calculates and sets the corresponding width.
  void _onHeightChanged() {
    final state = ref
        .read(imageResizeViewModelProvider(widget.initialFile))
        .value;
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
    final viewModel = ref.watch(
      imageResizeViewModelProvider(widget.initialFile),
    );
    final notifier = ref.read(
      imageResizeViewModelProvider(widget.initialFile).notifier,
    );

    // Listen to the provider to set the initial text field values once.
    ref.listen(imageResizeViewModelProvider(widget.initialFile), (_, next) {
      if (next.hasValue && !_initialValuesSet) {
        final state = next.value!;
        if (state.originalDimensions != null) {
          _widthController.text = state.originalDimensions!.width
              .toInt()
              .toString();
          _heightController.text = state.originalDimensions!.height
              .toInt()
              .toString();
          _initialValuesSet = true;
        }
      }
    });

    return AppScaffold(
      title: 'Resize Image',
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: viewModel.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('An error occurred: $err')),
          data: (state) {
            if (state.originalImage == null) {
              return const Center(
                child: Text('No image was selected. Please go back.'),
              );
            }
            return _buildContent(context, state, notifier, viewModel);
          },
        ),
      ),
    );
  }

  /// Builds the main content of the screen based on the current state.
  Widget _buildContent(
    BuildContext context,
    ResizeState state,
    ImageResizeViewModel notifier,
    AsyncValue<ResizeState> viewModel,
  ) {
    final isProcessing = viewModel.isLoading;

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
          isProcessing: isProcessing,
          onSave: () async {
            final originalName = p.basenameWithoutExtension(
              state.originalImage!.name,
            );
            final extension = p.extension(state.originalImage!.name);
            final defaultName = 'resized_$originalName';

            final saveResult = await showSaveOptionsDialog(
              context,
              defaultFileName: defaultName,
              fileExtension: extension.isNotEmpty ? extension : '.jpg',
            );

            if (saveResult != null && context.mounted) {
              await notifier.saveResizedImage(
                fileName: saveResult.fileName,
                folderPath: saveResult.folderPath,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Image saved successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                ref.invalidate(walletViewModelProvider);
                context.pop();
              }
            }
          },
        ),
      ],
    );
  }
}
