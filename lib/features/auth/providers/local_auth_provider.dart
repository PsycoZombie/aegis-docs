import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_auth_provider.g.dart';

@riverpod
class LocalAuth extends _$LocalAuth {
  @override
  bool build() {
    return false;
  }

  void login() {
    state = true;
  }

  void logout() {
    state = false;
  }
}
