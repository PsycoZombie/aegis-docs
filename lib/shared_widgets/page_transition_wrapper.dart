// file: shared_widgets/page_transition_wrapper.dart

import 'package:aegis_docs/app/config/app_theme.dart';
import 'package:aegis_docs/app/config/theme_provider.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PageTransitionWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const PageTransitionWrapper({super.key, required this.child});

  @override
  ConsumerState<PageTransitionWrapper> createState() =>
      _PageTransitionWrapperState();
}

class _PageTransitionWrapperState extends ConsumerState<PageTransitionWrapper> {
  bool _isAnimating = false;

  @override
  Widget build(BuildContext context) {
    // Listen for theme changes to trigger the fade animation
    ref.listen<ThemeMode>(themeProvider, (_, __) {
      if (!mounted) return;
      setState(() => _isAnimating = true);
      // Duration should be slightly longer than the fade animation
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() => _isAnimating = false);
        }
      });
    });

    // Get the current theme mode to pass to NeumorphicTheme
    final themeMode = ref.watch(themeProvider);

    // THE FIX: This wrapper now ALSO provides the NeumorphicTheme
    return NeumorphicTheme(
      theme: neumorphicLightTheme,
      darkTheme: neumorphicDarkTheme,
      themeMode: themeMode,
      child: NeumorphicBackground(
        // Apply the fade animation to the child page
        child: AnimatedOpacity(
          opacity: _isAnimating ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 250),
          child: widget.child,
        ),
      ),
    );
  }
}
