import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class BreadcrumbNavigation extends StatelessWidget {

  const BreadcrumbNavigation({
    required this.path, required this.onPathChanged, super.key,
  });
  final String? path;
  final ValueChanged<String?> onPathChanged;

  @override
  Widget build(BuildContext context) {
    final parts = path?.split(p.separator) ?? [];
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: parts.length + 1,
        separatorBuilder: (context, index) => const Center(
          child: Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        ),
        itemBuilder: (context, index) {
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
