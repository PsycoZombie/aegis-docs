import 'package:aegis_docs/app/navigation/app_router.dart';
import 'package:aegis_docs/features/auth/providers/local_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router_provider.g.dart';

/// Provides the [GoRouter] instance for the application.
///
/// This provider is responsible for creating and configuring the router.
/// It listens to the authentication state and automatically redirects users
/// between the login screen and the home screen, ensuring that only
/// authenticated users can access protected areas.
@riverpod
GoRouter appRouter(Ref ref) {
  // A ValueNotifier is used as a listenable to trigger the router's refresh
  // mechanism when the authentication state changes.
  final listenable = ValueNotifier<int>(0);

  ref
    ..listen(localAuthProvider, (_, _) {
      // Increment the notifier's value to trigger the redirect logic.
      listenable.value++;
    })
    ..onDispose(listenable.dispose);

  return GoRouter(
    initialLocation: '/login',
    routes: appRoutes,
    refreshListenable: listenable,

    /// The redirect logic that protects the app's routes.
    redirect: (BuildContext context, GoRouterState state) {
      // Read the current authentication state.
      final isLoggedIn = ref.read(localAuthProvider) == AuthState.success;
      final location = state.matchedLocation;
      final isGoingToLogin = location == '/login';

      // If the user is not logged in and is trying to access a protected route,
      // redirect them to the login screen.
      if (!isLoggedIn && !isGoingToLogin) {
        return '/login';
      }

      // If the user is already logged in and tries to go to the login screen,
      // redirect them to the home screen.
      if (isLoggedIn && isGoingToLogin) {
        return '/home';
      }

      // In all other cases, allow the navigation to proceed.
      return null;
    },
  );
}
