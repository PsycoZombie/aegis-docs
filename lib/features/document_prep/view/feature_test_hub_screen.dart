import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FeatureTestHubScreen extends StatelessWidget {
  const FeatureTestHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Select a Workflow',
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          _FeatureButton(title: 'Resize Image', path: '/hub/resize'),
          _FeatureButton(title: 'Compress Image', path: '/hub/compress'),
          _FeatureButton(title: 'Crop & Edit Image', path: '/hub/edit'),
          _FeatureButton(title: 'Images to PDF', path: '/hub/images-to-pdf'),
          _FeatureButton(title: 'PDF to Images', path: '/hub/pdf-to-images'),
        ],
      ),
    );
  }
}

class _FeatureButton extends StatelessWidget {
  final String title;
  final String path;

  const _FeatureButton({required this.title, required this.path});

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
          context.push(path);
        },
      ),
    );
  }
}
