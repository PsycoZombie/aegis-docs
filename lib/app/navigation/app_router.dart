import 'package:aegis_docs/features/auth/view/login_screen.dart';
import 'package:aegis_docs/features/document_prep/view/feature_test_hub_screen.dart';
import 'package:aegis_docs/features/document_prep/view/screens/image_resize_screen.dart';
import 'package:aegis_docs/features/home/view/home_screen.dart';
import 'package:aegis_docs/features/wallet/view/document_detail_screen.dart';
import 'package:go_router/go_router.dart';

final List<RouteBase> appRoutes = [
  ShellRoute(
    builder: (context, state, child) => child,
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    ],
  ),

  ShellRoute(
    builder: (context, state, child) => child,
    routes: <RouteBase>[
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/hub',
        builder: (context, state) => const FeatureTestHubScreen(),
      ),
      GoRoute(
        path: '/hub/resize',
        builder: (context, state) => const ImageResizeScreen(),
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
