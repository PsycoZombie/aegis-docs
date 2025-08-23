import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

/// A widget that displays a horizontal, clickable breadcrumb navigation bar.
///
/// It takes a file system-like path string and renders each segment as a
/// tappable link, allowing the user to navigate up the folder hierarchy.
class BreadcrumbNavigation extends StatelessWidget {
  /// Creates an instance of [BreadcrumbNavigation].
  const BreadcrumbNavigation({
    required this.path,
    required this.onPathChanged,
    super.key,
  });

  /// The current folder path to display (e.g., "folderA/subfolderB").
  /// A `null` or empty path represents the root.
  final String? path;

  /// A callback that is invoked when a breadcrumb segment is tapped.
  /// It provides the full path of the tapped segment.
  final ValueChanged<String?> onPathChanged;

  @override
  Widget build(BuildContext context) {
    // Split the path into its component parts.
    // An empty path results in an empty list.
    final parts = path?.split(p.separator) ?? [];
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // The item count is the number of path parts
        // plus one for the root "Wallet" link.
        itemCount: parts.length + 1,
        separatorBuilder: (context, index) => const Center(
          child: Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        ),
        itemBuilder: (context, index) {
          // The first item is always the root "Wallet" link.
          if (index == 0) {
            return Center(
              child: InkWell(
                onTap: () => onPathChanged(null),
                child: const Text(
                  'Wallet',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }
          // For subsequent items, build the path up to that point.
          final partIndex = index - 1;
          final currentPart = parts[partIndex];
          final currentPath = p.joinAll(parts.sublist(0, partIndex + 1));
          return Center(
            child: InkWell(
              onTap: () => onPathChanged(currentPath),
              child: Text(currentPart),
            ),
          );
        },
      ),
    );
  }
}
