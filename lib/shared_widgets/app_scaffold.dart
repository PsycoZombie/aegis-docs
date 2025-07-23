import 'package:aegis_docs/app/config/theme_provider.dart'; // Update with your path
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppScaffold extends ConsumerWidget {
  final String title;

  final Widget body;

  final List<Widget>? actions;

  final FloatingActionButton? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    final themeToggleButton = IconButton(
      icon: Icon(
        currentTheme == ThemeMode.dark
            ? Icons.light_mode_outlined
            : Icons.dark_mode_outlined,
      ),
      onPressed: () {
        ref.read(themeProvider.notifier).toggleTheme();
      },
      tooltip: 'Toggle Theme',
    );

    final allActions = [themeToggleButton, ...?actions];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        actions: allActions,
      ),
      body: Padding(padding: EdgeInsets.all(24), child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}
