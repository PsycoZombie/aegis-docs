import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:aegis_docs/features/auth/providers/local_auth_provider.dart';
import 'package:aegis_docs/features/home/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Import the generated mock file
import 'home_screen_test.mocks.dart';

// ✅ FIX 1: Create a "Fake" Notifier instead of a "Mock".
// This fake class correctly implements the Notifier's structure for Riverpod,
// while also allowing us to track method calls.
class FakeLocalAuthNotifier extends AutoDisposeNotifier<AuthState>
    implements LocalAuth {
  bool logoutCalled = false;

  @override
  AuthState build() {
    // Define the initial state for the provider in tests.
    return AuthState.initial;
  }

  @override
  void logout() {
    // Instead of verifying with mockito, we track the call with a simple flag.
    logoutCalled = true;
  }

  @override
  Future<void> authenticateWithDeviceCredentials() async {
    // Not needed for this test, so we provide an empty implementation.
  }
}

// We only need to generate a mock for GoRouter.
@GenerateMocks([GoRouter])
void main() {
  // Declare late variables.
  late FakeLocalAuthNotifier fakeLocalAuthNotifier;
  late MockGoRouter mockGoRouter;

  // setUp is called before each test to ensure a fresh state.
  setUp(() {
    fakeLocalAuthNotifier = FakeLocalAuthNotifier();
    mockGoRouter = MockGoRouter();
  });

  // A helper function to create our widget test environment.
  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        // Override the real provider with our fake instance.
        localAuthProvider.overrideWith(() => fakeLocalAuthNotifier),
      ],
      child: MaterialApp(
        home: InheritedGoRouter(
          goRouter: mockGoRouter,
          child: const HomeScreen(),
        ),
      ),
    );
  }

  group('HomeScreen Widget Tests', () {
    testWidgets('renders initial UI elements correctly', (
      WidgetTester tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Aegis Docs'), findsOneWidget);
      expect(find.text('My Wallet'), findsOneWidget);
      expect(find.text('Profiles'), findsOneWidget);
      expect(
        find.widgetWithText(
          FloatingActionButton,
          AppConstants.titleStartNewPrep,
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('tapping logout button calls logout method on provider', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pump();

      // Assert: ✅ FIX 1 (continued): Check the flag on our fake notifier.
      expect(fakeLocalAuthNotifier.logoutCalled, isTrue);
    });

    testWidgets('tapping FloatingActionButton navigates to /prep', (
      WidgetTester tester,
    ) async {
      // Arrange
      // ✅ FIX 2: Stub the push method before the widget is built.
      // We tell the mock router to do nothing when push is called.
      when(mockGoRouter.push(any)).thenAnswer((_) async => const <Never>[]);

      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Assert: Verify that the router's push method was called with '/prep'.
      verify(mockGoRouter.push('/prep')).called(1);
    });
  });
}
