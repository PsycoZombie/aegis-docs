import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {

  AuthService({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();
  final LocalAuthentication _localAuth;

  Future<bool> isDeviceSupported() async {
    return _localAuth.isDeviceSupported();
  }

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
      return false;
    }
  }
}
