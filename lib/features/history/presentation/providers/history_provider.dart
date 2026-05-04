import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visionary_ai/core/providers/core_providers.dart';
import 'package:visionary_ai/features/history/domain/entities/history_entry.dart';

class HistoryState {
  final bool isSpeaking;
  final List<HistoryEntry> historyEntries;

  HistoryState({this.isSpeaking = false, this.historyEntries = const []});

  HistoryState copyWith({bool? isSpeaking, List<HistoryEntry>? historyEntries}) {
    return HistoryState(
      isSpeaking: isSpeaking ?? this.isSpeaking,
      historyEntries: historyEntries ?? this.historyEntries,
    );
  }
}

final historyNotifierProvider =
    AsyncNotifierProvider<HistoryNotifier, HistoryState>(HistoryNotifier.new);

class HistoryNotifier extends AsyncNotifier<HistoryState> {
  
  @override
  Future<HistoryState> build() async {
    final historyEntries = await ref.read(historyRepositoryProvider).getHistory();
    return HistoryState(historyEntries: historyEntries);
  }

  Future<void> refresh() async {
    final historyEntries = await ref.read(historyRepositoryProvider).getHistory();
    state = AsyncData(state.value!.copyWith(historyEntries: historyEntries));
  }

  Future<void> deleteEntry(String id) async {
    await ref.read(historyRepositoryProvider).delete(id);
    await refresh();
  }
}