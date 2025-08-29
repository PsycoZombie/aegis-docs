import 'package:aegis_docs/core/services/haptics_service.dart';
import 'package:aegis_docs/features/auth/providers/local_auth_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:aegis_docs/shared_widgets/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget that listens to the [localAuthProvider] for state changes
/// and shows a Toast when an error occurs.
///
/// This separates side-effect logic (like showing dialogs, Toast, or Haptics)
/// from the main UI layout.
class AuthStateListener extends ConsumerWidget {
  /// Creates an [AuthStateListener].
  const AuthStateListener({required this.child, super.key});

  /// The child widget that will be rendered by this listener.
  ///
  /// This allows the listener to be wrapped around any part of the widget tree
  /// without affecting the layout.
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(localAuthProvider, (previous, next) {
      if (next == AuthState.error) {
        // Show error toast
        showToast(
          context,
          'Authentication Failed. Please try again.',
          type: ToastType.error,
        );
        // Haptic feedback for error
        ref.read(hapticsProvider).heavyImpact();
      }
    });
    return child;
  }
}

/// The main screen for handling user authentication to unlock the app.
class LoginScreen extends ConsumerStatefulWidget {
  /// Creates the [LoginScreen].
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  /// When the screen is first built, automatically
  /// trigger the authentication prompt.
  @override
  void initState() {
    super.initState();
    // We use a post-frame callback to ensure the widget tree is fully built
    // before we try to read from a provider.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only trigger auth if it hasn't already been attempted.
      if (ref.read(localAuthProvider) == AuthState.initial) {
        ref
            .read(localAuthProvider.notifier)
            .authenticateWithDeviceCredentials();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(localAuthProvider);
    final isLoading = authState == AuthState.loading;
    final textTheme = Theme.of(context).textTheme;

    return AuthStateListener(
      child: AppScaffold(
        title: 'Approve Sign in',
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/logo/icon.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
              const SizedBox(height: 24),
              Text(
                'Authentication Required',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Please use your device credentials to continue.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                // Disable the button while authentication is in progress.
                onPressed: isLoading
                    ? null
                    : () {
                        // Haptic for button press
                        ref.read(hapticsProvider).lightImpact();
                        ref
                            .read(localAuthProvider.notifier)
                            .authenticateWithDeviceCredentials();
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fingerprint),
                          SizedBox(width: 8),
                          Text('Unlock App'),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
