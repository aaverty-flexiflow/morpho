import 'dart:convert';

import 'package:home_widget/home_widget.dart';

import '../../features/habits/domain/habit_summary.dart';
import '../../features/habits/domain/plant_stage.dart';

class HomeWidgetService {
  static const _appGroupId = 'group.fr.flexiflow.morpho';
  static const _iOSWidgetName = 'MorphoWidget';
  static const _dataKey = 'widget_data';
  static const _pendingKey = 'pending_checkins';

  static bool _groupRegistered = false;

  static Future<void> _ensureGroup() async {
    if (_groupRegistered) return;
    await HomeWidget.setAppGroupId(_appGroupId);
    _groupRegistered = true;
  }

  /// Push current habit summaries to the widget.
  static Future<void> update(List<HabitSummary> summaries) async {
    try {
      await _ensureGroup();

      final done = summaries.where((s) => s.isGoalMetForPeriod).length;
      final habits = summaries
          .map((s) => {
                'id': s.habit.id ?? 0,
                'name': s.habit.name,
                'streak': s.currentStreak,
                'done': s.isGoalMetForPeriod,
                'plant': _stagePlant(s.stage),
              })
          .toList();

      await HomeWidget.saveWidgetData<String>(
        _dataKey,
        jsonEncode({'done': done, 'total': summaries.length, 'habits': habits}),
      );
      await HomeWidget.updateWidget(iOSName: _iOSWidgetName);
    } catch (_) {}
  }

  /// Reads and clears the pending check-in queue written by CheckInIntent.
  /// Returns the list of habit IDs that need to be committed to SQLite.
  static Future<List<int>> takePendingCheckIns() async {
    try {
      await _ensureGroup();
      final raw =
          await HomeWidget.getWidgetData<String>(_pendingKey) ?? '[]';
      if (raw == '[]' || raw.isEmpty) return [];
      final ids = (jsonDecode(raw) as List).cast<int>();
      if (ids.isEmpty) return [];
      // Clear immediately so we don't double-process on the next foreground
      await HomeWidget.saveWidgetData<String>(_pendingKey, '[]');
      return ids;
    } catch (_) {
      return [];
    }
  }

  static String _stagePlant(PlantStage stage) => switch (stage) {
        PlantStage.seed => '🌱',
        PlantStage.sprout => '🌿',
        PlantStage.young => '🌳',
        PlantStage.mature => '🌲',
        PlantStage.legendary => '✨',
      };
}
