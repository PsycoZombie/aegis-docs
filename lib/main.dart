import 'package:aegis_docs/app/config/app_theme.dart';
import 'package:aegis_docs/app/config/theme_provider.dart';
import 'package:aegis_docs/app/navigation/app_router_provider.dart';
import 'package:aegis_docs/core/services/cleanup_service.dart';
import 'package:aegis_docs/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';

/// The entry point of the Aegis Docs Flutter application.
void main() async {
  // Ensures Flutter bindings are initialized before calling native code.
  WidgetsFlutterBinding.ensureInitialized();

  // Get the temporary directory from the device.
  final tempDir = await getTemporaryDirectory();

  // Set the cache directory for the pdfrx library.
  // CORRECTED: Provide a function that returns the clean .path string.
  Pdfrx.getCacheDirectory = () => tempDir.path;

  // Initializes Firebase with platform-specific options.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Create a Riverpod container to access providers before the app runs.
  final container = ProviderContainer();

  // Use the container to correctly instantiate and run the cleanup service.
  // This ensures we are using the same
  // service instances as the rest of the app.
  final cleanupService = container.read(cleanupServiceProvider);
  await cleanupService.runCleanup();

  // Launches the app within a ProviderScope for state management.
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AegisDocsApp(),
    ),
  );
}

/// The root widget of the Aegis Docs application.
///
/// Uses [ConsumerWidget] to listen to Riverpod
/// providers for routing and theming.
class AegisDocsApp extends ConsumerWidget {
  /// Creates an instance of [AegisDocsApp].
  const AegisDocsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watches the app's router configuration provider.
    final router = ref.watch(appRouterProvider);

    // Watches the current theme mode provider (light/dark/system).
    final themeMode = ref.watch(themeNotifierProvider);

    // Builds the app using MaterialApp.router once the theme mode is loaded.
    return themeMode.when(
      data: (mode) => MaterialApp.router(
        title: 'Aegis Docs',
        routerConfig: router,
        themeMode: mode,
        theme: lightTheme,
        darkTheme: darkTheme,
        debugShowCheckedModeBanner: false,
      ),
      // Shows a loading indicator while theme mode is being fetched.
      loading: () => const Center(child: CircularProgressIndicator()),
      // Displays an error message if the theme provider fails.
      error: (err, stack) => Center(child: Text('Error loading theme: $err')),
    );
  }
}
