// Import your route definitions and the new local auth provider
import 'package:aegis_docs/app/navigation/app_router.dart';
// IMPORTANT: You will need to create this provider. See "Next Steps" below.
import 'package:aegis_docs/features/auth/providers/local_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router_provider.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final bool isLoggedIn = ref.watch(localAuthProvider);

  return GoRouter(
    initialLocation: '/login',

    redirect: (BuildContext context, GoRouterState state) {
      final String location = state.matchedLocation;
      final bool isGoingToLogin = location == '/login';

      if (!isLoggedIn && !isGoingToLogin) {
        return '/login';
      }

      if (isLoggedIn && isGoingToLogin) {
        return '/home';
      }

      return null;
    },
    routes: appRoutes,
  );
}
