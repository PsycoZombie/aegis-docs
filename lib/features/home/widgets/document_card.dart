import 'package:aegis_docs/core/services/haptics_service.dart';
import 'package:aegis_docs/data/models/wallet_item.dart';
import 'package:aegis_docs/features/home/providers/home_provider.dart';
import 'package:aegis_docs/features/home/widgets/item_context_menu.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A card widget that represents a single document in the wallet's grid view.
class DocumentCard extends ConsumerWidget {
  /// Creates an instance of [DocumentCard].
  const DocumentCard({required this.file, super.key});

  /// The document data model to display.
  final DocumentModel file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPdf = file.name.toLowerCase().endsWith('.pdf');
    final folderPath = ref.watch(homeViewModelProvider).currentFolderPath;

    return RawGestureDetector(
      gestures: {
        LongPressGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
              () => LongPressGestureRecognizer(
                duration: const Duration(milliseconds: 300),
              ),
              (LongPressGestureRecognizer instance) {
                instance.onLongPress = () {
                  // Haptic for long press menu
                  ref.read(hapticsProvider).mediumImpact();
                  showContextMenu(context, ref, file.path, isFolder: false);
                };
              },
            ),
        TapGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
              TapGestureRecognizer.new,
              (TapGestureRecognizer instance) {
                instance.onTap = () {
                  // Haptic for document open
                  ref.read(hapticsProvider).lightImpact();
                  context.push('/document/${file.name}', extra: folderPath);
                };
              },
            ),
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: GridTile(
          footer: GridTileBar(
            backgroundColor: Colors.black45,
            title: Text(file.name, overflow: TextOverflow.ellipsis),
          ),
          child: Icon(
            isPdf ? Icons.picture_as_pdf : Icons.image,
            size: 60,
            color: isPdf ? Colors.red.shade300 : Colors.blue.shade300,
          ),
        ),
      ),
    );
  }
}
