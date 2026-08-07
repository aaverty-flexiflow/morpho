import 'plant_type.dart';
import 'habit_frequency.dart';

/// An immutable representation of a user-created habit.
///
/// Stored in SQLite via [toMap] / [fromMap]. All mutation returns a new instance
/// via [copyWith] — no in-place state.
class Habit {
  const Habit({
    this.id,
    required this.name,
    required this.emoji,
    required this.colorValue,
    required this.plantType,
    this.frequency = HabitFrequency.daily,
    this.reminderTime,
    required this.createdAt,
    this.isArchived = false,
  });

  final int? id;
  final String name;
  final String emoji;

  /// ARGB packed colour for the pot (from AppColors.potColors).
  final int colorValue;

  final PlantType plantType;

  /// How often the habit must be performed (daily, N× per week, etc.).
  final HabitFrequency frequency;

  /// Optional wall-clock time for the daily reminder (date component ignored).
  final DateTime? reminderTime;

  final DateTime createdAt;
  final bool isArchived;

  // ── Serialisation ─────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'emoji': emoji,
        'color_value': colorValue,
        'plant_type': plantType.name,
        'frequency_index': frequency.index,
        'reminder_time': reminderTime?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'is_archived': isArchived ? 1 : 0,
      };

  factory Habit.fromMap(Map<String, dynamic> map) => Habit(
        id: map['id'] as int?,
        name: map['name'] as String,
        emoji: map['emoji'] as String,
        colorValue: map['color_value'] as int,
        plantType: PlantType.values.firstWhere(
          (t) => t.name == map['plant_type'],
          orElse: () => PlantType.fern,
        ),
        frequency: _frequencyFromIndex(map['frequency_index'] as int?),
        reminderTime: map['reminder_time'] != null
            ? DateTime.parse(map['reminder_time'] as String)
            : null,
        createdAt: DateTime.parse(map['created_at'] as String),
        isArchived: (map['is_archived'] as int) == 1,
      );

  // ── Mutation ──────────────────────────────────────────────────────────────

  Habit copyWith({
    int? id,
    String? name,
    String? emoji,
    int? colorValue,
    PlantType? plantType,
    HabitFrequency? frequency,
    DateTime? reminderTime,
    bool clearReminderTime = false,
    DateTime? createdAt,
    bool? isArchived,
  }) =>
      Habit(
        id: id ?? this.id,
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        colorValue: colorValue ?? this.colorValue,
        plantType: plantType ?? this.plantType,
        frequency: frequency ?? this.frequency,
        reminderTime: clearReminderTime ? null : (reminderTime ?? this.reminderTime),
        createdAt: createdAt ?? this.createdAt,
        isArchived: isArchived ?? this.isArchived,
      );

  @override
  bool operator ==(Object other) =>
      other is Habit && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);

  // ──────────────────────────────────────────────────────────────────────────

  static HabitFrequency _frequencyFromIndex(int? index) {
    if (index == null || index < 0 || index >= HabitFrequency.values.length) {
      return HabitFrequency.daily;
    }
    return HabitFrequency.values[index];
  }
}
