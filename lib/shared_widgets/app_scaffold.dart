import 'package:aegis_docs/app/config/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppScaffold extends ConsumerWidget {

  const AppScaffold({
    required this.title, required this.body, super.key,
    this.actions,
    this.floatingActionButton,
  });
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final themeMode = currentTheme.value;

    final themeToggleButton = IconButton(
      tooltip: 'Toggle Theme',
      onPressed: () {
        ref.read(themeNotifierProvider.notifier).toggleTheme();
      },
      icon: Icon(
        themeMode == ThemeMode.dark
            ? Icons.light_mode_outlined
            : Icons.dark_mode_outlined,
      ),
    );

    final allActions = [themeToggleButton, ...?actions];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
        actions: allActions,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
