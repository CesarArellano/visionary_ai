class HistoryEntry {
  final String id;
  final String description;
  final DateTime timestamp;

  HistoryEntry({
    required this.id,
    required this.description,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}