// file: app/providers/app_router_provider.dart

import 'package:aegis_docs/app/navigation/app_router.dart';
import 'package:aegis_docs/features/auth/providers/local_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router_provider.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  // 1. Create a listenable that GoRouter can subscribe to.
  final listenable = ValueNotifier<int>(0);

  // 2. Use ref.listen to detect changes in your auth provider's state.
  ref.listen(localAuthProvider, (_, __) {
    // When the auth state changes, update the listenable's value.
    // This notifies GoRouter to re-run the redirect logic.
    // The actual value doesn't matter, just that it changes.
    listenable.value++;
  });

  // 3. Dispose the listenable when the provider is disposed to prevent memory leaks.
  ref.onDispose(() => listenable.dispose());

  return GoRouter(
    initialLocation: '/login',
    routes: appRoutes,

    // 4. Pass the custom listenable to GoRouter.
    refreshListenable: listenable,

    redirect: (BuildContext context, GoRouterState state) {
      final bool isLoggedIn = ref.read(localAuthProvider) == AuthState.success;
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
  );
}
