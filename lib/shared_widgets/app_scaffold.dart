import 'package:aegis_docs/app/config/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

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
      tooltip: 'Toggle Theme',
      onPressed: () {
        ref.read(themeProvider.notifier).toggleTheme();
      },
      icon: Icon(
        currentTheme == ThemeMode.dark
            ? Icons.light_mode_outlined
            : Icons.dark_mode_outlined,
      ),
    );

    final allActions = [themeToggleButton, ...?actions];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        actions: allActions,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
