import 'package:aegis_docs/features/document_prep/view/widgets/resize_panel.dart';
import 'package:flutter/material.dart';

class FeatureTestHubScreen extends StatelessWidget {
  const FeatureTestHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aegis Docs Feature Tests')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _FeatureButton(title: '3. Resize Image', child: const ResizePanel()),
        ],
      ),
    );
  }
}

class _FeatureButton extends StatelessWidget {
  final String title;
  final Widget child;

  const _FeatureButton({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          textStyle: const TextStyle(fontSize: 16),
        ),
        child: Text(title),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: Text(title)),
                body: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
