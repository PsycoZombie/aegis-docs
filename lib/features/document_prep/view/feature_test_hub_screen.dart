// file: features/document_prep/view/feature_test_hub_screen.dart

import 'package:aegis_docs/features/document_prep/view/widgets/resize_panel.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class FeatureTestHubScreen extends StatelessWidget {
  const FeatureTestHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(title: 'Select a Workflow', body: ResizePanel());
  }
}
