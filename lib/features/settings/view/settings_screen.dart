import 'package:aegis_docs/core/services/settings_service.dart';
import 'package:aegis_docs/shared_widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsServiceProvider = Provider((ref) => SettingsService());

final cleanupDurationProvider = StateProvider<CleanupDuration>((ref) {
  return CleanupDuration.oneDay;
});

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadInitialValue();
  }

  Future<void> _loadInitialValue() async {
    final settingsService = ref.read(settingsServiceProvider);
    final savedDuration = await settingsService.loadCleanupDuration();
    if (mounted) {
      ref.read(cleanupDurationProvider.notifier).state = savedDuration;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = ref.read(settingsServiceProvider);
    final selectedDuration = ref.watch(cleanupDurationProvider);

    return AppScaffold(
      title: 'Settings',
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Automatically delete files from the public "Aegis Docs" folder after a set period to maintain privacy.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<CleanupDuration>(
                    value: selectedDuration,
                    decoration: const InputDecoration(
                      labelText: 'Cleanup After',
                      border: OutlineInputBorder(),
                    ),
                    items: CleanupDuration.values.map((duration) {
                      return DropdownMenuItem(
                        value: duration,
                        child: Text(_getDurationText(duration)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        settingsService.saveCleanupDuration(value);
                        ref.read(cleanupDurationProvider.notifier).state =
                            value;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDurationText(CleanupDuration duration) {
    switch (duration) {
      case CleanupDuration.fiveMinutes:
        return '5 Minutes';
      case CleanupDuration.oneHour:
        return '1 Hour';
      case CleanupDuration.oneDay:
        return '24 Hours';
      case CleanupDuration.sevenDays:
        return '7 Days';
      case CleanupDuration.never:
        return 'Never';
    }
  }
}
