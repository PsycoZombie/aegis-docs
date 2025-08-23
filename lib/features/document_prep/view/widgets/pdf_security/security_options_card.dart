import 'package:aegis_docs/features/document_prep/providers/pdf_security_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A card containing the form fields and actions for managing PDF security.
class SecurityOptionsCard extends ConsumerStatefulWidget {
  /// Creates an instance of [SecurityOptionsCard].
  const SecurityOptionsCard({
    required this.state,
    required this.notifier,
    required this.isProcessing,
    required this.onSave,
    super.key,
  });

  /// The current state from the [PdfSecurityViewModel].
  final PdfSecurityState state;

  /// The notifier for the [PdfSecurityViewModel].
  final PdfSecurityViewModel notifier;

  /// A flag indicating if a security operation is currently in progress.
  final bool isProcessing;

  /// A callback function to be invoked after a successful security operation.
  final VoidCallback onSave;

  @override
  ConsumerState<SecurityOptionsCard> createState() =>
      _SecurityOptionsCardState();
}

class _SecurityOptionsCardState extends ConsumerState<SecurityOptionsCard> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  /// A local state flag to dynamically show/hide the confirm password field.
  bool _showConfirmField = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_onNewPasswordChanged);
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_onNewPasswordChanged);
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// A listener that shows the "Confirm Password" field as soon as the user
  /// starts typing in the "New Password" field.
  void _onNewPasswordChanged() {
    final shouldShow = _newPasswordController.text.isNotEmpty;
    if (shouldShow != _showConfirmField) {
      setState(() {
        _showConfirmField = shouldShow;
      });
    }
  }

  /// Validates the form and triggers the appropriate security action
  /// (lock, unlock, or change password) based on the current state.
  Future<void> _applySecurity() async {
    // A small delay to allow the UI to update before processing.
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    if (!mounted || !_formKey.currentState!.validate()) return;

    Future<bool> action;
    if (widget.state.isEncrypted!) {
      if (_newPasswordController.text.isNotEmpty) {
        // If a new password is provided, change the password.
        action = widget.notifier.changePassword(
          _oldPasswordController.text,
          _newPasswordController.text,
        );
      } else {
        // Otherwise, unlock the PDF.
        action = widget.notifier.unlockPdf(_oldPasswordController.text);
      }
    } else {
      // If the PDF is not encrypted, lock it with the new password.
      action = widget.notifier.lockPdf(_newPasswordController.text);
    }

    final success = await action;

    // If the operation was successful, call the onSave callback.
    if (success && mounted) {
      widget.onSave();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state.isEncrypted == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Show the "Current Password" field only if
              // the PDF is already encrypted.
              if (widget.state.isEncrypted!)
                TextFormField(
                  controller: _oldPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty
                      ? 'Please enter the current password'
                      : null,
                ),
              if (widget.state.isEncrypted!) const SizedBox(height: 12),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: widget.state.isEncrypted!
                      ? 'New Password (optional)'
                      : 'New Password',
                  hintText: widget.state.isEncrypted!
                      ? 'Leave blank to unlock'
                      : null,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (!widget.state.isEncrypted! && value!.isEmpty) {
                    return 'Please enter a password to lock the PDF';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Show the "Confirm Password" field dynamically.
              if (_showConfirmField)
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: widget.isProcessing ? null : _applySecurity,
                child: Text(
                  widget.isProcessing ? 'Processing...' : 'Apply Security',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
