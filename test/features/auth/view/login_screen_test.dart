import 'package:aegis_docs/features/auth/providers/local_auth_provider.dart';
import 'package:aegis_docs/features/auth/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// A "fake" implementation of the LocalAuth notifier for testing.
class FakeLocalAuth extends LocalAuth {
  bool authenticateCalled = false;

  @override
  AuthState build() {
    // Start in the initial state so the button is enabled.
    return AuthState.initial;
  }

  @override
  Future<void> authenticateWithDeviceCredentials() async {
    authenticateCalled = true;
  }
}

void main() {
  group('LoginScreen', () {
    testWidgets(
      'tapping unlock button calls authenticateWithDeviceCredentials',
      (WidgetTester tester) async {
        // Arrange: Create a fake notifier instance.
        final fakeNotifier = FakeLocalAuth();

        // Pump the LoginScreen widget within a ProviderScope, overriding the
        // localAuthProvider to use our fake implementation.
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localAuthProvider.overrideWith(() => fakeNotifier),
            ],
            child: const MaterialApp(
              home: LoginScreen(),
            ),
          ),
        );

        // Act: Find the ElevatedButton by its text and tap it.
        await tester.tap(find.widgetWithText(ElevatedButton, 'Unlock App'));
        // Wait for any animations or state changes to complete.
        await tester.pumpAndSettle();

        // Assert: Verify that the method on our fake notifier was called.
        expect(fakeNotifier.authenticateCalled, isTrue);
      },
    );
  });
}
