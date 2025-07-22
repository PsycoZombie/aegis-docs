import 'package:aegis_docs/features/auth/providers/local_auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(localAuthProvider, (previous, next) {
      if (next == AuthState.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication Successful!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home');
      }
      if (next == AuthState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication Failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final authState = ref.watch(localAuthProvider);
    final isLoading = authState == AuthState.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Secure Login'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.lock_person_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                'Authentication Required',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Please use your device credentials (fingerprint, face, PIN, etc.) to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
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
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.fingerprint),
                          SizedBox(width: 8),
                          Text('Unlock App', style: TextStyle(fontSize: 16)),
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
