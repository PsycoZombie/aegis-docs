import 'package:aegis_docs/app/config/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A custom Scaffold widget that provides a consistent layout and theme
/// toggle functionality across all screens of the app.
class AppScaffold extends ConsumerWidget {
  /// Creates an instance of [AppScaffold].
  const AppScaffold({
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    super.key,
  });

  /// The title to display in the AppBar.
  final String title;

  /// The main content of the screen.
  final Widget body;

  /// An optional list of action widgets to display in the
  /// AppBar, after the theme toggle button.
  final List<Widget>? actions;

  /// An optional floating action button to display on the screen.
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Safely get the current theme mode, defaulting to system if not loaded.
    final themeMode =
        ref.watch(themeNotifierProvider).valueOrNull ?? ThemeMode.system;

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

    // Prepend the theme toggle button to any custom actions provided.
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
