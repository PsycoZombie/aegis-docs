import 'dart:io';

import 'package:aegis_docs/features/home/providers/home_provider.dart';
import 'package:aegis_docs/features/home/widgets/item_context_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

class DocumentCard extends ConsumerWidget {
  const DocumentCard({required this.file, super.key});
  final File file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileName = p.basename(file.path);
    final isPdf = fileName.toLowerCase().endsWith('.pdf');
    final folderPath = ref.watch(homeViewModelProvider).currentFolderPath;

    return GestureDetector(
      onTap: () => context.push('/document/$fileName', extra: folderPath),
      onLongPress: () =>
          showContextMenu(context, ref, fileName, isFolder: false),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: GridTile(
          footer: GridTileBar(
            backgroundColor: Colors.black45,
            title: Text(fileName, overflow: TextOverflow.ellipsis),
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
