import 'dart:io';

import 'package:aegis_docs/features/settings/providers/settings_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A screen for creating or entering a
/// master password for cloud backup and restore.
class MasterPasswordScreen extends ConsumerStatefulWidget {
  /// Creates an instance of [MasterPasswordScreen].
  const MasterPasswordScreen({
    required this.isCreating,
    required this.onSubmit,
    this.backupBytes,
    super.key,
  });

  /// A flag to determine if the screen is in "create" or "enter" mode.
  final bool isCreating;

  /// A callback function that is invoked with the entered password.
  /// This is used by the parent widget to
  /// trigger the backup or restore process.
  final Future<bool> Function(String password) onSubmit;

  /// The downloaded backup data, required only
  /// when restoring (`isCreating` is false).
  final File? backupBytes;

  @override
  ConsumerState<MasterPasswordScreen> createState() =>
      _MasterPasswordScreenState();
}

class _MasterPasswordScreenState extends ConsumerState<MasterPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  /// Validates the form and calls the appropriate provider method or callback.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // The logic is now handled by the parent widget via the onSubmit callback.
    final success = await widget.onSubmit(_passwordController.text);

    if (success && mounted) {
      // The parent screen is responsible for showing feedback and popping.
      // This screen can pop itself if it's not in creation mode.
      if (!widget.isCreating) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider to get the loading state for UI feedback.
    final state = ref.watch(settingsViewModelProvider);
    final isLoading = state.isLoading;

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
              // Only show the confirm password field when
              // creating a new password.
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
