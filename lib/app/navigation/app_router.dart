import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:aegis_docs/data/models/picked_file_model.dart';
import 'package:aegis_docs/features/auth/view/login_screen.dart';
import 'package:aegis_docs/features/document_prep/view/feature_test_hub_screen.dart';
import 'package:aegis_docs/features/document_prep/view/screens/image_compression_screen.dart';
import 'package:aegis_docs/features/document_prep/view/screens/image_editing_screen.dart';
import 'package:aegis_docs/features/document_prep/view/screens/image_format_screen.dart';
import 'package:aegis_docs/features/document_prep/view/screens/image_resize_screen.dart';
import 'package:aegis_docs/features/document_prep/view/screens/images_to_pdf_screen.dart';
import 'package:aegis_docs/features/document_prep/view/screens/pdf_compression_screen.dart';
import 'package:aegis_docs/features/document_prep/view/screens/pdf_security_screen.dart';
import 'package:aegis_docs/features/document_prep/view/screens/pdf_to_images_screen.dart';
import 'package:aegis_docs/features/home/view/home_screen.dart';
import 'package:aegis_docs/features/settings/view/settings_screen.dart';
import 'package:aegis_docs/features/wallet/view/document_detail_screen.dart';
import 'package:go_router/go_router.dart';

/// Defines all the application's routes using GoRouter.
///
/// This list is the single source of truth for navigation in the app.
/// It maps URL paths to specific screens and handles passing parameters
/// between them.
final List<RouteBase> appRoutes = [
  // --- Authentication Flow --- //
  GoRoute(
    path: AppConstants.routeLogin,
    builder: (context, state) => const LoginScreen(),
  ),

  // --- Main App Flow --- //
  GoRoute(
    path: AppConstants.routeHome,
    builder: (context, state) => const HomeScreen(),
  ),
  GoRoute(
    path: AppConstants.routeDocumentDetail,
    builder: (context, state) {
      final fileName = state.pathParameters[AppConstants.paramFileName]!;
      final folderPath = state.extra as String?;
      return DocumentDetailScreen(
        fileName: fileName,
        folderPath: folderPath,
      );
    },
  ),
  GoRoute(
    path: AppConstants.routeSettings,
    builder: (context, state) => const SettingsScreen(),
  ),

  // --- Document Preparation Hub and Workflows --- //
  GoRoute(
    path: AppConstants.routeHub,
    builder: (context, state) => const FeatureTestHubScreen(),
  ),
  GoRoute(
    path: AppConstants.routeResize,
    builder: (context, state) {
      final pickedFile = state.extra as PickedFileModel?;
      return ImageResizeScreen(initialFile: pickedFile);
    },
  ),
  GoRoute(
    path: AppConstants.routeCompress,
    builder: (context, state) {
      final pickedFile = state.extra as PickedFileModel?;
      return ImageCompressionScreen(initialFile: pickedFile);
    },
  ),
  GoRoute(
    path: AppConstants.routeEdit,
    builder: (context, state) {
      final pickedFile = state.extra as PickedFileModel?;
      return ImageEditingScreen(initialFile: pickedFile);
    },
  ),
  GoRoute(
    path: AppConstants.routeImageFormat,
    builder: (context, state) {
      final pickedFile = state.extra as PickedFileModel?;
      return ImageFormatScreen(initialFile: pickedFile);
    },
  ),
  GoRoute(
    path: AppConstants.routeImagesToPdf,
    builder: (context, state) {
      final pickedFiles = state.extra as List<PickedFileModel>? ?? [];
      return ImagesToPdfScreen(initialFiles: pickedFiles);
    },
  ),
  GoRoute(
    path: AppConstants.routePdfToImages,
    builder: (context, state) {
      final pickedFile = state.extra as PickedFileModel?;
      return PdfToImagesScreen(initialFile: pickedFile);
    },
  ),
  GoRoute(
    path: AppConstants.routePdfCompression,
    builder: (context, state) {
      final pickedFile = state.extra as PickedFileModel?;
      return PdfCompressionScreen(initialFile: pickedFile);
    },
  ),
  GoRoute(
    path: AppConstants.routePdfSecurity,
    builder: (context, state) {
      final pickedFile = state.extra as PickedFileModel?;
      return PdfSecurityScreen(initialFile: pickedFile);
    },
  ),
];
