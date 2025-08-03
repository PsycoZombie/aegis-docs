// file: features/document_prep/view/feature_test_hub_screen.dart

import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
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
          // You can add more buttons for other features here
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
      // Use NeumorphicButton for a consistent look
      child: NeumorphicButton(
        padding: const EdgeInsets.all(16),
        onPressed: () {
          context.push(path);
        },
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: NeumorphicTheme.defaultTextColor(context),
          ),
        ),
      ),
    );
  }
}
