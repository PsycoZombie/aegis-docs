import 'package:aegis_docs/core/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_auth_provider.g.dart';

enum AuthState { initial, loading, success, error }

@riverpod
AuthService authService(Ref ref) {
  return AuthService();
}

@riverpod
class LocalAuth extends _$LocalAuth {
  late final AuthService _authService;

  @override
  AuthState build() {
    _authService = ref.watch(authServiceProvider);
    return AuthState.initial;
  }

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

  void logout() {
    state = AuthState.initial;
  }
}
