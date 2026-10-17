/// Activity audit log entry for MD executive oversight.
class ActivityLog {
  final int? id;
  final String actionType; // CREATE, UPDATE, DELETE, SYSTEM
  final String title;
  final String description;
  final DateTime timestamp;

  const ActivityLog({
    this.id,
    required this.actionType,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action_type': actionType,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ActivityLog.fromMap(Map<String, dynamic> map) {
    return ActivityLog(
      id: map['id'] as int?,
      actionType: map['action_type'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}
