import 'package:aegis_docs/core/services/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_auth_provider.g.dart';

enum AuthState { initial, loading, success, error }

@riverpod
class LocalAuth extends _$LocalAuth {
  late final AuthService _authService;

  @override
  AuthState build() {
    _authService = AuthService();
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
}
