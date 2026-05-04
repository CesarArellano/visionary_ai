import 'package:visionary_ai/core/constants/app_constants.dart';
import 'package:visionary_ai/features/history/data/datasources/history_local_datasource.dart';
import 'package:visionary_ai/features/history/domain/entities/history_entry.dart';
import 'package:visionary_ai/features/history/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDatasource _datasource;

  HistoryRepositoryImpl({required HistoryLocalDatasource datasource})
      : _datasource = datasource;

  @override
  Future<List<HistoryEntry>> getHistory() async {
    final entries = await _datasource.getHistory();
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }

  @override
  Future<void> save(HistoryEntry entry) async {
    final entries = await _datasource.getHistory();
    entries.insert(0, entry);
    if (entries.length > AppConstants.kMaxHistoryEntries) {
      entries.removeRange(
        AppConstants.kMaxHistoryEntries,
        entries.length,
      );
    }
    await _datasource.saveHistory(entries);
  }

  @override
  Future<void> delete(String id) async {
    final entries = await _datasource.getHistory();
    entries.removeWhere((e) => e.id == id);
    await _datasource.saveHistory(entries);
  }
}