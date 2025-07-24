import 'package:aegis_docs/features/document_prep/view/feature_test_hub_screen.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class DocumentPrepWorkspaceScreen extends StatelessWidget {
  const DocumentPrepWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Prepare your document',
      body: FeatureTestHubScreen(),
    );
  }
}
