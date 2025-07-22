import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_auth_provider.g.dart';

enum AuthState { initial, loading, success, error }

@riverpod
class LocalAuth extends _$LocalAuth {
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  AuthState build() {
    return AuthState.initial;
  }

  Future<void> authenticateWithDeviceCredentials() async {
    state = AuthState.loading;
    try {
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) {
        state = AuthState.error;
        return;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason:
            'Please verify your identity to continue to Aegis Docs',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          sensitiveTransaction: true,
        ),
      );

      state = didAuthenticate ? AuthState.success : AuthState.error;
    } on PlatformException catch (_) {
      state = AuthState.error;
    }
  }
}
