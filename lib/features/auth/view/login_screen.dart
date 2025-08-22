import 'package:aegis_docs/features/auth/providers/local_auth_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthStateListener extends ConsumerWidget {
  const AuthStateListener({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(localAuthProvider, (previous, next) {
      if (next == AuthState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: Text(
              'Authentication Failed. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    });
    return child;
  }
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    final colorScheme = Theme.of(context).colorScheme;

    return AuthStateListener(
      child: AppScaffold(
        title: 'Approve Sign in',
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.lock_person_rounded,
                size: 80,
                color: colorScheme.primary,
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
                onPressed: isLoading
                    ? null
                    : () {
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
