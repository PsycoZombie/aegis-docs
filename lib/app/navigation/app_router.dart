// file: app/navigation/app_router.dart

// Make sure to import your new wrapper
import 'package:aegis_docs/features/auth/view/login_screen.dart';
import 'package:aegis_docs/features/document_prep/view/feature_test_hub_screen.dart';
import 'package:aegis_docs/features/document_prep/view/widgets/resize_panel.dart';
import 'package:aegis_docs/features/home/view/home_screen.dart';
import 'package:aegis_docs/features/wallet/view/document_detail_screen.dart';
import 'package:go_router/go_router.dart';
// ... other imports

final List<RouteBase> appRoutes = [
  // UN-AUTHENTICATED SHELL
  ShellRoute(
    // The builder is now much simpler
    builder: (context, state, child) => child,
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    ],
  ),

  // AUTHENTICATED SHELL
  ShellRoute(
    // Use the same wrapper here
    builder: (context, state, child) => child,
    routes: <RouteBase>[
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/hub',
        builder: (context, state) => const FeatureTestHubScreen(),
      ),
      GoRoute(
        path: '/hub/resize',
        builder: (context, state) => const ResizePanel(),
      ),
      GoRoute(
        path: '/document/:fileName',
        builder: (context, state) {
          final fileName = state.pathParameters['fileName']!;
          return DocumentDetailScreen(fileName: fileName);
        },
      ),
    ],
  ),
];
