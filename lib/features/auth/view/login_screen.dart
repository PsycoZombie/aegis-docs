// file: features/auth/view/login_screen.dart

import 'package:aegis_docs/features/auth/providers/local_auth_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthStateListener extends ConsumerWidget {
  const AuthStateListener({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(localAuthProvider, (previous, next) {
      if (next == AuthState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: Neumorphic(
              style: NeumorphicStyle(
                color: Colors.red[400],
                depth: 5,
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(12),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Authentication Failed. Please try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      }
    });
    return child;
  }
}

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(localAuthProvider);
    final isLoading = authState == AuthState.loading;
    // The theme is now correctly inherited from the router's NeumorphicTheme.
    final currentNeumorphicTheme = NeumorphicTheme.currentTheme(context);

    // The local NeumorphicTheme and Builder wrappers are no longer needed.
    return AuthStateListener(
      child: AppScaffold(
        title: '',
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Neumorphic(
              style: const NeumorphicStyle(
                shape: NeumorphicShape.concave,
                boxShape: NeumorphicBoxShape.circle(),
                depth: 8,
                intensity: 0.7,
              ),
              padding: const EdgeInsets.all(24),
              child: Icon(
                Icons.lock_person_rounded,
                size: 80,
                color: currentNeumorphicTheme.accentColor,
              ),
            ),
            const SizedBox(height: 24),
            // Flat, crisp text for the title
            NeumorphicText(
              'Authentication Required',
              style: NeumorphicStyle(
                color: currentNeumorphicTheme.defaultTextColor,
                disableDepth: true,
              ),
              textAlign: TextAlign.center,
              textStyle: NeumorphicTextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Please use your device credentials (fingerprint, face, PIN, etc.) to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: currentNeumorphicTheme.defaultTextColor,
              ),
            ),
            const SizedBox(height: 40),
            NeumorphicButton(
              minDistance: isLoading ? 0 : -4,
              style: NeumorphicStyle(
                depth: isLoading ? 0 : 4,
                color: currentNeumorphicTheme.accentColor,
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(12),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              onPressed: isLoading
                  ? null // Disables the button automatically
                  : () {
                      ref
                          .read(localAuthProvider.notifier)
                          .authenticateWithDeviceCredentials();
                    },
              child: isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: currentNeumorphicTheme.baseColor,
                          ),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fingerprint,
                          color: currentNeumorphicTheme.baseColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Unlock App',
                          style: TextStyle(
                            color: currentNeumorphicTheme.baseColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
