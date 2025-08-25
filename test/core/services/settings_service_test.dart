import 'package:aegis_docs/app/config/app_constants.dart';
import 'package:aegis_docs/core/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SettingsService settingsService;

  // We use a group to run setup for a set of related tests.
  group('SettingsService', () {
    // This runs before each test in the group.
    setUp(() {
      settingsService = SettingsService();
    });

    test('loadCleanupDuration should return the default '
        'value (oneDay) when no value is set', () async {
      // Arrange: Set up the mock SharedPreferences with no initial values.
      SharedPreferences.setMockInitialValues({});

      // Act: Call the method we are testing.
      final result = await settingsService.loadCleanupDuration();

      // Assert: Verify that the result is the expected default value.
      expect(result, CleanupDuration.oneDay);
    });

    test(
      'loadCleanupDuration should return the saved value when one is set',
      () async {
        // Arrange: Set up mock SharedPreferences with a pre-saved value.
        SharedPreferences.setMockInitialValues({
          AppConstants.keyCleanupDuration: CleanupDuration.sevenDays.index,
        });

        // Act
        final result = await settingsService.loadCleanupDuration();

        // Assert
        expect(result, CleanupDuration.sevenDays);
      },
    );

    test('saveCleanupDuration should correctly save the value', () async {
      // Arrange
      // Set empty initial values.
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      // Act: Call the save method.
      await settingsService.saveCleanupDuration(CleanupDuration.fiveMinutes);

      // Assert: Verify that the value in our mock
      // SharedPreferences instance is now correct.
      expect(
        prefs.getInt(AppConstants.keyCleanupDuration),
        CleanupDuration.fiveMinutes.index,
      );
    });

    // It's also good practice to test simple helper methods.
    test('getDurationInMinutes should return the correct minute values', () {
      // Assert
      expect(
        settingsService.getDurationInMinutes(CleanupDuration.fiveMinutes),
        5,
      );
      expect(settingsService.getDurationInMinutes(CleanupDuration.oneHour), 60);
      expect(
        settingsService.getDurationInMinutes(CleanupDuration.oneDay),
        24 * 60,
      );
      expect(
        settingsService.getDurationInMinutes(CleanupDuration.sevenDays),
        7 * 24 * 60,
      );
    });
  });
}
