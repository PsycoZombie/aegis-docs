import 'package:aegis_docs/features/auth/providers/local_auth_provider.dart';
import 'package:aegis_docs/features/auth/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// The mock provider class remains the same.
class MockLocalAuthProvider extends AutoDisposeNotifier<AuthState>
    implements LocalAuth {
  @override
  AuthState build() {
    return AuthState.initial;
  }

  @override
  Future<void> authenticateWithDeviceCredentials() async {
    // No implementation needed for tests.
  }

  void setState(AuthState newState) {
    state = newState;
  }
}

void main() {
  // The helper function now takes the mock provider as an argument.
  Widget createWidgetUnderTest(MockLocalAuthProvider mockProvider) {
    return ProviderScope(
      overrides: [localAuthProvider.overrideWith(() => mockProvider)],
      child: const MaterialApp(home: LoginScreen()),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('shows initial UI correctly when state is initial', (
      WidgetTester tester,
    ) async {
      // Arrange: Create a NEW mock provider instance for this specific test.
      final mockProvider = MockLocalAuthProvider();
      await tester.pumpWidget(createWidgetUnderTest(mockProvider));

      // Assert
      expect(find.text('Authentication Required'), findsOneWidget);
      expect(find.widgetWithText(Row, 'Unlock App'), findsOneWidget);
      expect(find.byIcon(Icons.fingerprint), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows loading indicator when state is loading', (
      WidgetTester tester,
    ) async {
      // Arrange: Create a NEW, fresh mock provider instance.
      final mockProvider = MockLocalAuthProvider();
      await tester.pumpWidget(createWidgetUnderTest(mockProvider));

      // Act: Change the provider's state to loading.
      mockProvider.setState(AuthState.loading);
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Unlock App'), findsNothing);
      expect(find.byIcon(Icons.fingerprint), findsNothing);
    });

    testWidgets('button is disabled when loading', (WidgetTester tester) async {
      // Arrange: Create a NEW, fresh mock provider instance.
      final mockProvider = MockLocalAuthProvider();
      await tester.pumpWidget(createWidgetUnderTest(mockProvider));

      // Act
      mockProvider.setState(AuthState.loading);
      await tester.pump();

      // Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });
}
