import 'package:aegis_docs/features/auth/view/login_screen.dart';
import 'package:aegis_docs/features/document_prep/view/document_prep_workspace_screen.dart';
import 'package:aegis_docs/features/home/view/home_screen.dart';
import 'package:go_router/go_router.dart';

final List<GoRoute> appRoutes = [
  GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
  GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
  GoRoute(
    path: '/prep',
    builder: (context, state) {
      return const DocumentPrepWorkspaceScreen();
    },
  ),
];
