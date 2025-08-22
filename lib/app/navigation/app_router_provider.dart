import 'package:aegis_docs/app/navigation/app_router.dart';
import 'package:aegis_docs/features/auth/providers/local_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router_provider.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final listenable = ValueNotifier<int>(0);

  ref
    ..listen(localAuthProvider, (_, _) {
      listenable.value++;
    })
    ..onDispose(listenable.dispose);

  return GoRouter(
    initialLocation: '/login',
    routes: appRoutes,

    refreshListenable: listenable,

    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = ref.read(localAuthProvider) == AuthState.success;
      final location = state.matchedLocation;
      final isGoingToLogin = location == '/login';

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
