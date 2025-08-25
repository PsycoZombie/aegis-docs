import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:aegis_docs/app/navigation/app_router_provider.dart';
import 'package:aegis_docs/features/auth/providers/local_auth_provider.dart';
import 'package:aegis_docs/features/auth/view/login_screen.dart';
import 'package:aegis_docs/features/home/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class FakeLocalAuth extends LocalAuth {
  FakeLocalAuth(this._initialState);
  final AuthState _initialState;

  @override
  AuthState build() => _initialState;

  // We also need to provide dummy implementations for
  // the methods, even if we don't use them.
  @override
  Future<void> authenticateWithDeviceCredentials() async {}

  @override
  void logout() {}
}

void main() {
  late GoRouter router;

  // A helper function to create the app with an overridden provider.
  Widget createTestApp(AuthState authState) {
    return ProviderScope(
      overrides: [
        // We override the localAuthProvider to use our new FakeLocalAuth,
        // passing in the desired state for the test.
        localAuthProvider.overrideWith(() => FakeLocalAuth(authState)),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          router = ref.watch(appRouterProvider);
          // We use a dummy MaterialApp.router for the test.
          return MaterialApp.router(routerConfig: router);
        },
      ),
    );
  }

  group('App Router Redirect Logic', () {
    testWidgets('should redirect to login screen when not authenticated', (
      WidgetTester tester,
    ) async {
      // Arrange: Create the app in a logged-out state.
      await tester.pumpWidget(createTestApp(AuthState.initial));

      // Act: Attempt to navigate to a protected route.
      router.go(AppConstants.routeHome);
      await tester.pumpAndSettle(); // Wait for navigation to complete.

      // Assert: Verify that we were redirected and are now on the LoginScreen.
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
    });

    testWidgets(
      'should redirect to home screen when authenticated and going to login',
      (WidgetTester tester) async {
        // Arrange: Create the app in a logged-in state.
        await tester.pumpWidget(createTestApp(AuthState.success));

        // Act: Attempt to navigate to the login screen.
        router.go(AppConstants.routeLogin);
        await tester.pumpAndSettle(); // Wait for navigation to complete.

        // Assert: Verify that we were redirected and are now on the HomeScreen.
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
      },
    );

    testWidgets('should allow navigation to home when authenticated', (
      WidgetTester tester,
    ) async {
      // Arrange: Create the app in a logged-in state.
      await tester.pumpWidget(createTestApp(AuthState.success));

      // Act: Navigate to the home screen.
      router.go(AppConstants.routeHome);
      await tester.pumpAndSettle();

      // Assert: Verify that we are on the HomeScreen as expected.
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });
  });
}
