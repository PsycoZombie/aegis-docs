import 'package:aegis_docs/core/services/auth_service.dart';
import 'package:aegis_docs/features/auth/providers/local_auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import './local_auth_provider_test.mocks.dart';

// Generate a mock for our AuthService
@GenerateMocks([AuthService])
void main() {
  late MockAuthService mockAuthService;

  // This function is now essential for setting up the test environment.
  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        // We override the real authServiceProvider with our mock instance.
        authServiceProvider.overrideWithValue(mockAuthService),
      ],
    );
    // Add this line to ensure the container is disposed after the test.
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    mockAuthService = MockAuthService();
  });

  test('Initial state is AuthState.initial', () {
    // Arrange: Use the helper to create a container with the mock.
    final container = createContainer();

    // Act
    final state = container.read(localAuthProvider);

    // Assert
    expect(state, AuthState.initial);
  });

  test(
    'authenticateWithDeviceCredentials transitions state: loading -> success',
    () async {
      // Arrange
      when(mockAuthService.isDeviceSupported()).thenAnswer((_) async => true);
      when(mockAuthService.authenticate()).thenAnswer((_) async => true);

      final container = createContainer();
      final listener = Listener<AuthState>();

      container.listen<AuthState>(
        localAuthProvider,
        listener.call,
        fireImmediately: true,
      );

      // Act
      await container
          .read(localAuthProvider.notifier)
          .authenticateWithDeviceCredentials();

      // Assert: Check the sequence of states.
      expect(listener.states, [
        AuthState.initial,
        AuthState.loading,
        AuthState.success,
      ]);
      // Verify that the service methods were called.
      verify(mockAuthService.isDeviceSupported()).called(1);
      verify(mockAuthService.authenticate()).called(1);
    },
  );

  test('authenticateWithDeviceCredentials transitions state: '
      'loading -> error on auth fail', () async {
    // Arrange
    when(mockAuthService.isDeviceSupported()).thenAnswer((_) async => true);
    // Simulate a failed authentication
    when(mockAuthService.authenticate()).thenAnswer((_) async => false);

    final container = createContainer();
    final listener = Listener<AuthState>();
    container.listen<AuthState>(
      localAuthProvider,
      listener.call,
      fireImmediately: true,
    );

    // Act
    await container
        .read(localAuthProvider.notifier)
        .authenticateWithDeviceCredentials();

    // Assert
    expect(listener.states, [
      AuthState.initial,
      AuthState.loading,
      AuthState.error,
    ]);
  });
}

// A helper class to listen to provider state changes.
class Listener<T> {
  final List<T> states = [];
  void call(T? previous, T next) {
    states.add(next);
  }
}
