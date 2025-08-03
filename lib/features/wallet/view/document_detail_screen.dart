import 'package:aegis_docs/features/wallet/providers/wallet_provider.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DocumentDetailScreen extends ConsumerWidget {
  final String fileName;

  const DocumentDetailScreen({super.key, required this.fileName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentAsyncValue = ref.watch(
      documentDetailProvider(fileName: fileName),
    );
    final isPdf = fileName.toLowerCase().endsWith('.pdf');

    return AppScaffold(
      title: fileName,
      body: Center(
        child: documentAsyncValue.when(
          // 1. Use NeumorphicProgressIndeterminate for loading
          loading: () => const NeumorphicProgressIndeterminate(),
          error: (error, stack) =>
              NeumorphicText('Error loading document: $error'),
          data: (decryptedData) {
            if (decryptedData == null) {
              return NeumorphicText('Could not load or decrypt the document.');
            }

            // Determine which viewer to use
            final Widget documentView = isPdf
                ? SfPdfViewer.memory(decryptedData)
                : InteractiveViewer(
                    child: Image.memory(decryptedData, fit: BoxFit.contain),
                  );

            // 2. Wrap the document viewer in a styled Neumorphic container
            return Neumorphic(
              style: NeumorphicStyle(
                depth: -5, // A negative depth gives an inset "concave" look
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(12),
                ),
              ),
              // 3. Clip the content to match the container's rounded corners
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: documentView,
              ),
            );
          },
        ),
      ),
    );
  }
}
