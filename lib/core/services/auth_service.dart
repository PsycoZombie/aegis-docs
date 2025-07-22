import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  final LocalAuthentication _localAuth;

  AuthService({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  Future<bool> isDeviceSupported() async {
    return await _localAuth.isDeviceSupported();
  }

  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason:
            'Please verify your identity to continue to Aegis Docs',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          sensitiveTransaction: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
