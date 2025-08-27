import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

/// Provides an instance of [AuthService] for dependency injection.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// A service for handling local device
/// authentication using biometrics or passcode.
class AuthService {
  /// Creates an instance of [AuthService].
  ///
  /// An optional [LocalAuthentication] instance can be
  /// provided for testing purposes.
  AuthService({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  /// Checks if the device has a biometric sensor and
  /// supports local authentication.
  ///
  /// Returns `true` if the device is supported, otherwise `false`.
  Future<bool> isDeviceSupported() async {
    return _localAuth.isDeviceSupported();
  }

  /// Prompts the user to authenticate using
  /// biometrics (e.g., fingerprint, face ID)
  /// or the device passcode.
  ///
  /// The stickyAuth option keeps the authentication
  ///  dialog open on app resume.
  /// Returns `true` if the user successfully authenticates, otherwise `false`.
  /// Returns `false` if a [PlatformException] occurs (e.g., user cancels).
  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason:
            'Please verify your identity to continue to Aegis Docs',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      // This exception can be thrown if the user cancels the auth prompt
      // or if there's an issue with the authentication process.
      return false;
    }
  }
}
