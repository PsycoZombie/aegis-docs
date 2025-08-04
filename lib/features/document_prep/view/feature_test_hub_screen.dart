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
        children: [
          ElevatedButton(
            onPressed: () {
              context.push('/hub/resize');
            },
            child: Text('Reize Image'),
          ),
        ],
      ),
    );
  }
}
