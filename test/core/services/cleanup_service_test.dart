import 'package:aegis_docs/core/services/cleanup_service.dart';
import 'package:aegis_docs/core/services/native_cleanup_service.dart';
import 'package:aegis_docs/core/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Import the generated mock file.
import 'cleanup_service_test.mocks.dart';

// This annotation tells build_runner to generate mocks for our dependencies.
@GenerateMocks([NativeCleanupService, SettingsService])
void main() {
  late CleanupService cleanupService;
  late MockNativeCleanupService mockNativeCleanupService;
  late MockSettingsService mockSettingsService;

  // This runs before each test, ensuring a clean state.
  setUp(() {
    mockNativeCleanupService = MockNativeCleanupService();
    mockSettingsService = MockSettingsService();
    // Inject the mock dependencies into the service.
    cleanupService = CleanupService(
      nativeService: mockNativeCleanupService,
      settingsService: mockSettingsService,
    );
  });

  group('CleanupService', () {
    test(
      'runCleanup should call native cleanup when duration is not "never"',
      () async {
        // Arrange: Simulate the user having selected the "oneHour" setting.
        when(
          mockSettingsService.loadCleanupDuration(),
        ).thenAnswer((_) async => CleanupDuration.oneHour);
        // Simulate the conversion of that enum to a minute value.
        when(
          mockSettingsService.getDurationInMinutes(CleanupDuration.oneHour),
        ).thenReturn(60);
        // Set up the expected call to the native service.
        when(
          mockNativeCleanupService.cleanupExportedFiles(
            expirationInMinutes: anyNamed('expirationInMinutes'),
          ),
        ).thenAnswer((_) async {
          return;
        });

        // Act: Call the method we are testing.
        await cleanupService.runCleanup();

        // Assert: Verify that the methods on our mocks were called as expected.
        verify(mockSettingsService.loadCleanupDuration()).called(1);
        verify(
          mockSettingsService.getDurationInMinutes(CleanupDuration.oneHour),
        ).called(1);
        // Verify that the native service was called
        // with the correct minute value.
        verify(
          mockNativeCleanupService.cleanupExportedFiles(
            expirationInMinutes: 60,
          ),
        ).called(1);
      },
    );

    test(
      'runCleanup should NOT call native cleanup when duration is "never"',
      () async {
        // Arrange: Simulate the user having selected the "never" setting.
        when(
          mockSettingsService.loadCleanupDuration(),
        ).thenAnswer((_) async => CleanupDuration.never);

        // Act
        await cleanupService.runCleanup();

        // Assert
        // Verify that we loaded the setting.
        verify(mockSettingsService.loadCleanupDuration()).called(1);
        // Crucially, verify that the other methods were NEVER called.
        verifyNever(mockSettingsService.getDurationInMinutes(any));
        verifyNever(
          mockNativeCleanupService.cleanupExportedFiles(
            expirationInMinutes: anyNamed('expirationInMinutes'),
          ),
        );
      },
    );
  });
}
