import 'dart:typed_data';

import 'package:aegis_docs/features/settings/providers/settings_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class _MasterPasswordScreenState extends ConsumerState<MasterPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!widget.isCreating) {
      final success = await ref
          .read(settingsViewModelProvider.notifier)
          .finishRestore(widget.backupBytes!, _passwordController.text);

      if (success && mounted) {
        Navigator.of(context).pop();
      }
    } else {
      await widget.onSubmit(_passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsViewModelProvider);
    final isLoading = state.valueOrNull?.isProcessing ?? false;

    ref.listen(settingsViewModelProvider, (previous, next) {
      if (previous is AsyncData && previous!.value!.isProcessing) {
        if (next is AsyncData && !next.value!.isProcessing && mounted) {
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
