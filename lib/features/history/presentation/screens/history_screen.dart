import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:visionary_ai/core/theme/app_theme.dart';
import 'package:visionary_ai/core/utils/haptic_utils.dart';
import 'package:visionary_ai/features/history/domain/entities/history_entry.dart';
import 'package:visionary_ai/features/history/presentation/providers/history_provider.dart';
import 'package:visionary_ai/features/vision/presentation/providers/tts_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});
  
  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {

  late final TtsNotifier _ttsNotifier;

  @override
  void initState() {
    super.initState();
    _ttsNotifier = ref.read(ttsNotifierProvider.notifier);
  }
  
  @override
  void dispose() {
    _ttsNotifier.stop();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: historyState.when(
        data: (historyState) => historyState.historyEntries.isEmpty
            ? _buildEmptyState()
            : _buildHistoryList(historyState.historyEntries, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: AppTheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Semantics(
      label: 'No history yet',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppTheme.onSurface.withAlpha(128),
            ),
            const SizedBox(height: 16),
            const Text(
              'No history yet.\nTake your first photo!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList(List<HistoryEntry> entries, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _HistoryTile(
          entry: entry,
          onPlay: () {
            HapticUtils.onPlay();
            ref.read(ttsNotifierProvider.notifier).speak(entry.description);
          },
          onDelete: () {
            ref.read(historyNotifierProvider.notifier).deleteEntry(entry.id);
          },
        );
      },
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final HistoryEntry entry;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  const _HistoryTile({
    required this.entry,
    required this.onPlay,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy · h:mm a');
    final truncatedDescription = entry.description.length > 80
        ? '${entry.description.substring(0, 80)}…'
        : entry.description;

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Semantics(
        label: 'History entry from ${dateFormat.format(entry.timestamp)}',
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              truncatedDescription,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.onBackground,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                dateFormat.format(entry.timestamp),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.onSurface,
                ),
              ),
            ),
            trailing: Semantics(
              button: true,
              label: 'Play description',
              child: IconButton(
                icon: const Icon(
                  Icons.play_arrow,
                  color: AppTheme.accentColor,
                ),
                onPressed: onPlay,
                tooltip: 'Play',
              ),
            ),
          ),
        ),
      ),
    );
  }
}