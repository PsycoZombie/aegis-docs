// Hide the standard Material AppBar and IconButton to avoid conflicts
// Update with your actual path to the theme provider
import 'package:aegis_docs/app/config/theme_provider.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  // Changed to Widget? for flexibility with NeumorphicFloatingActionButton
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

    // 1. Neumorphic version of the theme toggle button
    final themeToggleButton = NeumorphicButton(
      // Style it as a circle to mimic IconButton
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.circle(),
        shape: NeumorphicShape.flat,
        depth: 2,
      ),
      padding: const EdgeInsets.all(12),
      tooltip: 'Toggle Theme',
      onPressed: () {
        ref.read(themeProvider.notifier).toggleTheme();
      },
      child: Icon(
        currentTheme == ThemeMode.dark
            ? Icons.light_mode_outlined
            : Icons.dark_mode_outlined,
        // Ensure the icon color adapts to the neumorphic theme
        color: NeumorphicTheme.defaultTextColor(context),
      ),
    );

    final allActions = [themeToggleButton, ...?actions];

    // 2. Use a standard Scaffold but set its background to the Neumorphic base color
    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor(context),
      // 3. Use NeumorphicAppBar
      appBar: NeumorphicAppBar(
        title: NeumorphicText(
          title,
          style: NeumorphicStyle(
            disableDepth: true, // Give the text some depth
            color: NeumorphicTheme.defaultTextColor(context),
          ),
          textStyle: NeumorphicTextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: allActions,
      ),
      body: Padding(padding: const EdgeInsets.all(16.0), child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}
