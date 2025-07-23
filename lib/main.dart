import 'package:aegis_docs/app/config/app_theme.dart';
import 'package:aegis_docs/app/config/theme_provider.dart';
import 'package:aegis_docs/app/navigation/app_router_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: AegisDocsApp()));
}

class AegisDocsApp extends ConsumerWidget {
  const AegisDocsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Aegis Docs',
      routerConfig: router,
      themeMode: themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
    );
  }
}
