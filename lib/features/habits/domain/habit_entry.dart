/// A single completion record — one row per successful check-in.
///
/// Multiple entries on the same calendar day are deduplicated by the repository
/// before insertion, so each day counts at most once toward a streak.
class HabitEntry {
  const HabitEntry({
    this.id,
    required this.habitId,
    required this.completedAt,
  });

  final int? id;
  final int habitId;
  final DateTime completedAt;

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'habit_id': habitId,
        'completed_at': completedAt.toIso8601String(),
      };

  factory HabitEntry.fromMap(Map<String, dynamic> map) => HabitEntry(
        id: map['id'] as int?,
        habitId: map['habit_id'] as int,
        completedAt: DateTime.parse(map['completed_at'] as String),
      );

  @override
  bool operator ==(Object other) => other is HabitEntry && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
