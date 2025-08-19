import 'package:aegis_docs/app/config/app_theme.dart';
import 'package:aegis_docs/app/config/theme_provider.dart';
import 'package:aegis_docs/app/navigation/app_router_provider.dart';
import 'package:aegis_docs/core/services/cleanup_service.dart';
import 'package:aegis_docs/core/services/native_compression_service.dart';
import 'package:aegis_docs/core/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cleanupService = CleanupService(
    nativeService: NativeCompressionService(),
    settingsService: SettingsService(),
  );
  await cleanupService.runCleanup();

  runApp(const ProviderScope(child: AegisDocsApp()));
}

class AegisDocsApp extends ConsumerWidget {
  const AegisDocsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeNotifierProvider);

    return themeMode.when(
      data: (mode) => MaterialApp.router(
        title: 'Aegis Docs',
        routerConfig: router,
        themeMode: mode,
        theme: lightTheme,
        darkTheme: darkTheme,
        debugShowCheckedModeBanner: false,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading theme: $err')),
    );
  }
}
