import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionary_ai/core/providers/core_providers.dart';
import 'package:visionary_ai/features/history/domain/entities/history_entry.dart';

final historyNotifierProvider =
    AsyncNotifierProvider<HistoryNotifier, List<HistoryEntry>>(
        HistoryNotifier.new);

class HistoryNotifier extends AsyncNotifier<List<HistoryEntry>> {
  @override
  Future<List<HistoryEntry>> build() async {
    return ref.read(historyRepositoryProvider).getHistory();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(historyRepositoryProvider).getHistory());
  }

  Future<void> deleteEntry(String id) async {
    await ref.read(historyRepositoryProvider).delete(id);
    await refresh();
  }
}