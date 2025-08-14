import 'package:aegis_docs/features/document_prep/providers/pdf_security_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecurityOptionsCard extends ConsumerStatefulWidget {
  final PdfSecurityState state;
  final PdfSecurityViewModel notifier;
  final VoidCallback onSave;

  const SecurityOptionsCard({
    super.key,
    required this.state,
    required this.notifier,
    required this.onSave,
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

  void _onNewPasswordChanged() {
    final shouldShow = _newPasswordController.text.isNotEmpty;
    if (shouldShow != _showConfirmField) {
      setState(() {
        _showConfirmField = shouldShow;
      });
    }
  }

  Future<void> _applySecurity() async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted || !_formKey.currentState!.validate()) return;

    Future<bool> action;
    if (widget.state.isEncrypted!) {
      if (_newPasswordController.text.isNotEmpty) {
        action = widget.notifier.changePassword(
          _oldPasswordController.text,
          _newPasswordController.text,
        );
      } else {
        action = widget.notifier.unlockPdf(_oldPasswordController.text);
      }
    } else {
      action = widget.notifier.lockPdf(_newPasswordController.text);
    }

    final success = await action;

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
                onPressed: widget.state.isProcessing ? null : _applySecurity,
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
