import 'package:aegis_docs/core/services/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_auth_provider.g.dart';

/// Represents the possible states of the local authentication process.
enum AuthState {
  /// The initial state before any authentication attempt.
  initial,

  /// The user has initiated authentication and is waiting for a result.
  loading,

  /// The user has successfully authenticated.
  success,

  /// Authentication failed, was cancelled, or is not supported.
  error,
}

/// A Notifier (ViewModel) that manages the state of local biometric/device authentication.
///
/// This provider orchestrates the [AuthService] to
/// handle the authentication flow
/// and updates the UI by changing its [AuthState].
@riverpod
class LocalAuth extends _$LocalAuth {
  late final AuthService _authService;

  /// Initializes the provider, setting the
  /// initial state and getting a reference
  /// to the [AuthService].
  @override
  AuthState build() {
    // Get the auth service dependency from its own provider.
    _authService = ref.watch(authServiceProvider);
    return AuthState.initial;
  }

  /// Initiates the device's local authentication prompt
  /// (biometric or passcode).
  ///
  /// The provider's state will transition through
  /// [AuthState.loading] and end in
  /// either [AuthState.success] or [AuthState.error].
  Future<void> authenticateWithDeviceCredentials() async {
    state = AuthState.loading;
    final isSupported = await _authService.isDeviceSupported();

    if (!isSupported) {
      state = AuthState.error;
      return;
    }

    final result = await _authService.authenticate();
    state = result ? AuthState.success : AuthState.error;
  }

  /// Resets the authentication state to its initial value.
  ///
  /// This can be used to log the user out of the secure wallet, requiring
  /// them to authenticate again for access.
  void logout() {
    state = AuthState.initial;
  }
}
