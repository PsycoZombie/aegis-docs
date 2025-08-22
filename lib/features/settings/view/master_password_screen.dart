import 'dart:typed_data';

import 'package:aegis_docs/features/settings/providers/settings_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// THE FIX: The widget must be a ConsumerStatefulWidget to use Riverpod.
class MasterPasswordScreen extends ConsumerStatefulWidget {
  const MasterPasswordScreen({
    required this.isCreating,
    required this.onSubmit,
    super.key,
    this.backupBytes,
  });
  final bool isCreating;
  final Future<void> Function(String password) onSubmit;
  final Uint8List? backupBytes;

  @override
  ConsumerState<MasterPasswordScreen> createState() =>
      _MasterPasswordScreenState();
}

// THE FIX: The state must extend ConsumerState to get access to 'ref'.
class _MasterPasswordScreenState extends ConsumerState<MasterPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // For the restore flow, we now call the provider directly.
    if (!widget.isCreating) {
      final success = await ref
          .read(settingsViewModelProvider.notifier)
          .finishRestore(widget.backupBytes!, _passwordController.text);

      // If the restore is successful, pop the screen.
      // If not, the provider will have set an error message, and the listener
      // on the SettingsScreen will show the snackbar.
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    } else {
      // The backup flow remains the same, using the passed-in callback.
      await widget.onSubmit(_passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider to get the loading state for the button.
    final state = ref.watch(settingsViewModelProvider);
    final isLoading = state.valueOrNull?.isProcessing ?? false;

    // Listen for the operation to finish to pop the screen.
    ref.listen(settingsViewModelProvider, (previous, next) {
      if (previous is AsyncData && previous!.value!.isProcessing) {
        if (next is AsyncData && !next.value!.isProcessing && mounted) {
          // If the operation was a successful backup, pop the screen.
          if (next.value!.successMessage != null && widget.isCreating) {
            Navigator.of(context).pop();
          }
        }
      }
    });

    return AppScaffold(
      title: widget.isCreating
          ? 'Create Master Password'
          : 'Enter Master Password',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.isCreating
                    ? 'Create a strong password to secure your backup key. '
                          'This password cannot be recovered.'
                    : 'Enter your master password to restore your backup.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Master Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Password cannot be empty' : null,
              ),
              if (widget.isCreating) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(widget.isCreating ? 'Create & Backup' : 'Restore'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
