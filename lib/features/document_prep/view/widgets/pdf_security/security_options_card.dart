// file: features/document_prep/view/widgets/pdf_security/security_options_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/pdf_security_provider.dart';

class SecurityOptionsCard extends ConsumerStatefulWidget {
  final PdfSecurityState state;
  final PdfSecurityViewModel notifier;

  const SecurityOptionsCard({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  ConsumerState<SecurityOptionsCard> createState() =>
      _SecurityOptionsCardState();
}

class _SecurityOptionsCardState extends ConsumerState<SecurityOptionsCard> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // THE FIX: A state variable to explicitly control the visibility.
  bool _showConfirmField = false;

  @override
  void initState() {
    super.initState();
    // Add a listener to the controller to manage the state.
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

  void _onNewPasswordChanged() {
    final shouldShow = _newPasswordController.text.isNotEmpty;
    // Only call setState if the visibility needs to change.
    if (shouldShow != _showConfirmField) {
      setState(() {
        _showConfirmField = shouldShow;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (widget.state.isEncrypted!) {
      if (_newPasswordController.text.isNotEmpty) {
        widget.notifier.changePassword(
          _oldPasswordController.text,
          _newPasswordController.text,
        );
      } else {
        widget.notifier.unlockPdf(_oldPasswordController.text);
      }
    } else {
      widget.notifier.lockPdf(_newPasswordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
              // THE FIX: Use the state variable for visibility.
              if (_showConfirmField)
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(),
                  ),
                  // THE FIX: A more robust validator.
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
                onPressed: widget.state.isProcessing ? null : _submit,
                child: Text(
                  widget.state.isProcessing
                      ? 'Processing...'
                      : 'Apply Security',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
