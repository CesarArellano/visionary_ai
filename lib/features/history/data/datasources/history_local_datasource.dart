import 'dart:convert';
import 'package:simple_secure_storage/simple_secure_storage.dart';
import 'package:visionary_ai/core/constants/app_constants.dart';
import 'package:visionary_ai/features/history/domain/entities/history_entry.dart';

class HistoryLocalDatasource {
  Future<List<HistoryEntry>> getHistory() async {
    final jsonString = await SimpleSecureStorage.read(AppConstants.kHistoryStorageKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveHistory(List<HistoryEntry> entries) async {
    final jsonList = entries.map((e) => e.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await SimpleSecureStorage.write(AppConstants.kHistoryStorageKey, jsonString);
  }
}