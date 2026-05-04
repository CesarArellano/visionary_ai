import 'package:visionary_ai/features/history/domain/entities/history_entry.dart';

abstract class HistoryRepository {
  Future<List<HistoryEntry>> getHistory();
  Future<void> save(HistoryEntry entry);
  Future<void> delete(String id);
}