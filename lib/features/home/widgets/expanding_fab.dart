import 'dart:async';

import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:aegis_docs/core/services/haptics_service.dart'; // 👈 add
import 'package:aegis_docs/data/repositories/document_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// An enum to define the type of file that needs to be
/// picked for a feature workflow.
// ignore: public_member_api_docs
enum PickType { singleImage, multiImage, pdf }

/// An expanding Floating Action Button that reveals
/// a menu of document prep tools.
class ExpandingFab extends ConsumerStatefulWidget {
  /// Creates an instance of [ExpandingFab].
  const ExpandingFab({super.key});

  @override
  ConsumerState<ExpandingFab> createState() => _ExpandingFabState();
}

class _ExpandingFabState extends ConsumerState<ExpandingFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _toggle() {
    if (_controller.isAnimating) return;

    setState(() => _isOpen = !_isOpen);

    final haptics = ref.read(hapticsProvider);
    if (_isOpen) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
      _controller.forward();
      haptics.lightImpact();
    } else {
      _controller.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      });
      haptics.selectionClick();
    }
  }

  Future<void> _onActionButtonTapped(String route, PickType pickType) async {
    final router = GoRouter.of(context);
    _toggle();

    await ref.read(hapticsProvider).selectionClick();

    final repo = await ref.read(documentRepositoryProvider.future);
    switch (pickType) {
      case PickType.singleImage:
        final (pickedFile, _) = await repo.pickImage();
        if (pickedFile != null) {
          await router.push(route, extra: pickedFile);
        }
      case PickType.multiImage:
        final pickedFiles = await repo.pickAndSanitizeMultipleImagesForPdf();
        if (pickedFiles.isNotEmpty) {
          await router.push(route, extra: pickedFiles);
        }
      case PickType.pdf:
        final pickedFile = await repo.pickPdf();
        if (pickedFile != null) {
          await router.push(route, extra: pickedFile);
        }
    }
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggle,
                child: Container(color: Colors.black.withAlpha(128)),
              ),
            ),
            Positioned.fill(
              child: Stack(
                alignment: Alignment.bottomRight,
                clipBehavior: Clip.none,
                children: _buildExpandingActionButtons(),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _toggle,
      child: AnimatedIcon(
        icon: AnimatedIcons.menu_close,
        progress: _controller,
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = _actionButtons.length;
    for (var i = 0; i < count; i++) {
      final action = _actionButtons[i];
      children.add(
        _ExpandingActionButton(
          index: i,
          progress: _expandAnimation,
          onPressed: () => _onActionButtonTapped(action.route, action.pickType),
          child: action,
        ),
      );
    }
    return children;
  }
}

/// A single action button that animates out from the main FAB.
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.index,
    required this.progress,
    required this.onPressed,
    required this.child,
  });

  final int index;
  final Animation<double> progress;
  final VoidCallback onPressed;
  final _ActionButton child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset(0, -10 + (index + 1) * -50.0);
        return Positioned(
          right: 16,
          bottom: 16,
          child: Transform.translate(
            offset: Offset(0, progress.value * offset.dy),
            child: Opacity(
              opacity: progress.value,
              child: child,
            ),
          ),
        );
      },
      child: child.copyWith(onPressed: onPressed),
    );
  }
}

/// A list of all the action buttons to be displayed in the expanding FAB.
final List<_ActionButton> _actionButtons = [
  const _ActionButton(
    color: Colors.red,
    icon: Icon(
      Icons.security,
    ),
    label: 'PDF Security',
    route: AppConstants.routePdfSecurity,
    pickType: PickType.pdf,
  ),
  const _ActionButton(
    color: Colors.red,
    icon: Icon(Icons.compress),
    label: 'Compress PDF',
    route: AppConstants.routePdfCompression,
    pickType: PickType.pdf,
  ),
  const _ActionButton(
    color: Colors.red,
    icon: Icon(Icons.image_search),
    label: 'PDF to Images',
    route: AppConstants.routePdfToImages,
    pickType: PickType.pdf,
  ),
  const _ActionButton(
    color: Colors.red,
    icon: Icon(Icons.picture_as_pdf_outlined),
    label: 'Images to PDF',
    route: AppConstants.routeImagesToPdf,
    pickType: PickType.multiImage,
  ),
  const _ActionButton(
    color: Colors.blue,
    icon: Icon(Icons.swap_horiz),
    label: 'Change Format',
    route: AppConstants.routeImageFormat,
    pickType: PickType.singleImage,
  ),
  const _ActionButton(
    color: Colors.blue,
    icon: Icon(Icons.crop),
    label: 'Crop & Edit',
    route: AppConstants.routeEdit,
    pickType: PickType.singleImage,
  ),
  const _ActionButton(
    color: Colors.blue,
    icon: Icon(Icons.photo_size_select_small),
    label: 'Compress Image',
    route: AppConstants.routeCompress,
    pickType: PickType.singleImage,
  ),
  const _ActionButton(
    color: Colors.blue,
    icon: Icon(Icons.aspect_ratio),
    label: 'Resize Image',
    route: AppConstants.routeResize,
    pickType: PickType.singleImage,
  ),
];

/// A single, labeled action button for the expanding menu.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.route,
    required this.pickType,
    required this.color,
    this.onPressed,
  });

  final Icon icon;
  final String label;
  final String route;
  final PickType pickType;
  final VoidCallback? onPressed;
  final Color color;

  // A helper to create a new instance with a different onPressed callback.
  _ActionButton copyWith({VoidCallback? onPressed}) {
    return _ActionButton(
      icon: icon,
      label: label,
      route: route,
      pickType: pickType,
      onPressed: onPressed ?? this.onPressed,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Material(
            elevation: 2,
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(label),
            ),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.small(
          backgroundColor: color,
          heroTag: null,
          tooltip: label,
          onPressed: onPressed,
          child: icon,
        ),
      ],
    );
  }
}
