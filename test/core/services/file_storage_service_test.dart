import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:aegis_docs/core/services/file_storage_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// --- Mock Platform Implementations --- //

// A fake implementation of the PathProviderPlatform. This allows us to control
// what paths are returned during a test,
// without touching the actual file system.
class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/fake/documents';
  }

  @override
  Future<String?> getDownloadsPath() async {
    return '/fake/downloads';
  }
}

// A fake implementation of the PermissionHandlerPlatform. This lets us simulate
// the user granting or denying storage permissions.
class FakePermissionHandlerPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PermissionHandlerPlatform {
  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) async {
    // Simulate granting all requested permissions
    return {
      for (final permission in permissions)
        permission: PermissionStatus.granted,
    };
  }
}

void main() {
  late FileStorageService fileStorageService;
  // A mock handler for the native method channel calls.
  late TestWidgetsFlutterBinding binding;

  setUp(() {
    // Initialize the test binding.
    binding = TestWidgetsFlutterBinding.ensureInitialized();
    // Set the fake platform implementations before each test.
    PathProviderPlatform.instance = FakePathProviderPlatform();
    PermissionHandlerPlatform.instance = FakePermissionHandlerPlatform();
    fileStorageService = FileStorageService();
  });

  group('FileStorageService', () {
    test(
      'getBaseWalletDirectory should create and return the correct directory',
      () async {
        // Act
        final directory = await fileStorageService.getBaseWalletDirectory();

        // Assert
        final expectedPath = p.join(
          '/fake/documents',
          AppConstants.privateWalletDirectory,
        );
        expect(directory.path, expectedPath);
      },
    );

    test(
      'saveToPublicDirectory should request permission and return a valid path',
      () async {
        // Act
        final filePath = await fileStorageService.saveToPublicDirectory(
          fileName: 'test.txt',
          data: Uint8List(0),
        );

        // Assert
        final expectedPath = p.join(
          '/fake/downloads',
          AppConstants.publicExportDirectory,
          'test.txt',
        );
        expect(filePath, expectedPath);
      },
    );

    test(
      'saveToPublicDownloads should correctly call the native method channel',
      () async {
        // Arrange: Set up a mock handler for our method channel.
        const channel = MethodChannel(AppConstants.platformChannelName);
        const expectedPath = '/fake/downloads/AegisDocs/native_test.txt';

        binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (
          MethodCall methodCall,
        ) async {
          // We check if the correct method with the
          // correct arguments was called.
          if (methodCall.method == AppConstants.methodSaveToDownloads) {
            return expectedPath;
          }
          return null;
        });

        // Act
        final resultPath = await fileStorageService.saveToPublicDownloads(
          fileName: 'native_test.txt',
          data: Uint8List(0),
        );

        // Assert
        expect(resultPath, equals(expectedPath));
      },
    );
  });
}
