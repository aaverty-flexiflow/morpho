import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:morpho/i18n/strings.g.dart';

import '../../../../core/notifications/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/habits/data/habits_provider.dart';
import '../../../../features/habits/domain/habit.dart';
import '../../../../features/habits/domain/habit_frequency.dart';
import '../../../../features/habits/domain/plant_type.dart';
import '../../../../shared/widgets/plant_view.dart';
import '../../../../features/habits/domain/plant_stage.dart';

/// Bottom-sheet form to create a new habit.
///
/// Validates all fields before allowing submission. Handles its own loading
/// and error state locally to avoid polluting the global provider state.
class AddHabitSheet extends ConsumerStatefulWidget {
  const AddHabitSheet({super.key});

  @override
  ConsumerState<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends ConsumerState<AddHabitSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();

  PlantType _selectedPlant = PlantType.fern;
  int _selectedColorIndex = 0;
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  DateTime? _reminderTime;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final habit = Habit(
        name: _nameCtrl.text.trim(),
        emoji: _selectedPlant.emoji,
        colorValue: AppColors.potColors[_selectedColorIndex].toARGB32(),
        plantType: _selectedPlant,
        frequency: _selectedFrequency,
        reminderTime: _reminderTime,
        createdAt: DateTime.now(),
      );

      final id = await ref.read(habitsNotifierProvider.notifier).addHabit(habit);

      if (_reminderTime != null) {
        await NotificationService.scheduleDaily(
          habitId: id,
          habitName: habit.name,
          time: _reminderTime!,
        );
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.common.error(error: e)), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickTime() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _pickTimeCupertino();
    } else {
      await _pickTimeMaterial();
    }
  }

  Future<void> _pickTimeMaterial() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime != null
          ? TimeOfDay.fromDateTime(_reminderTime!)
          : const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked == null || !mounted) return;
    setState(() {
      final now = DateTime.now();
      _reminderTime = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    });
  }

  Future<void> _pickTimeCupertino() async {
    final now = DateTime.now();
    DateTime tempTime = _reminderTime ?? DateTime(now.year, now.month, now.day, 9, 0);

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(ctx),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          children: [
            // Toolbar
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(ctx),
                    width: 0.33,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      t.common.cancel,
                      style: TextStyle(color: CupertinoColors.systemGrey.resolveFrom(ctx)),
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onPressed: () {
                      setState(() => _reminderTime = tempTime);
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
            // Wheel picker
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: tempTime,
                use24hFormat: MediaQuery.of(ctx).alwaysUse24HourFormat,
                onDateTimeChanged: (dt) => tempTime = dt,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      // Shifts the sheet up when the keyboard appears.
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Text(t.addHabit.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const Gap(20),

              // ── Plant preview ─────────────────────────────────────────────
              Center(
                child: PlantView(
                  key: ValueKey(_selectedPlant),
                  type: _selectedPlant,
                  stage: PlantStage.young,
                  currentStreak: 15,
                  potColor: AppColors.potColors[_selectedColorIndex],
                  size: 100,
                ),
              ),
              const Gap(16),

              // ── Name field ────────────────────────────────────────────────
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  hintText: t.addHabit.namePlaceholder,
                  prefixIcon: const Icon(Icons.edit_rounded, size: 20),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLength: 40,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return t.addHabit.nameRequired;
                  if (v.trim().length < 2) return t.addHabit.nameMinLength;
                  return null;
                },
              ),
              const Gap(16),

              // ── Frequency picker ──────────────────────────────────────────
              _SectionLabel(t.addHabit.sectionFrequency),
              const Gap(8),
              _FrequencyPicker(
                selected: _selectedFrequency,
                onChanged: (f) => setState(() => _selectedFrequency = f),
              ),
              const Gap(16),

              // ── Plant picker ──────────────────────────────────────────────
              _SectionLabel(t.addHabit.sectionPlant),
              const Gap(8),
              _PlantPicker(
                selected: _selectedPlant,
                onChanged: (p) => setState(() => _selectedPlant = p),
              ),
              const Gap(16),

              // ── Colour picker ─────────────────────────────────────────────
              _SectionLabel(t.addHabit.sectionColor),
              const Gap(8),
              _ColorPicker(
                selectedIndex: _selectedColorIndex,
                onChanged: (i) => setState(() => _selectedColorIndex = i),
              ),
              const Gap(16),

              // ── Reminder toggle ───────────────────────────────────────────
              _ReminderRow(
                reminderTime: _reminderTime,
                onTap: _pickTime,
                onClear: () => setState(() => _reminderTime = null),
              ),
              const Gap(24),

              // ── Submit ────────────────────────────────────────────────────
              FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(t.addHabit.submit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FrequencyPicker extends StatelessWidget {
  const _FrequencyPicker({required this.selected, required this.onChanged});

  final HabitFrequency selected;
  final ValueChanged<HabitFrequency> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: HabitFrequency.values.length,
        separatorBuilder: (_, _) => const Gap(8),
        itemBuilder: (context, i) {
          final freq = HabitFrequency.values[i];
          final isSelected = freq == selected;
          final theme = Theme.of(context);

          return GestureDetector(
            onTap: () => onChanged(freq),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withAlpha(20)
                    : theme.colorScheme.surface,
                border: Border.all(
                  color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                freq.shortLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withAlpha(180),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class _PlantPicker extends StatelessWidget {
  const _PlantPicker({required this.selected, required this.onChanged});

  final PlantType selected;
  final ValueChanged<PlantType> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: PlantType.values.length,
        separatorBuilder: (_, _) => const Gap(8),
        itemBuilder: (context, i) {
          final plant = PlantType.values[i];
          final isSelected = plant == selected;
          final theme = Theme.of(context);

          return GestureDetector(
            onTap: () => onChanged(plant),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withAlpha(20)
                    : theme.colorScheme.surface,
                border: Border.all(
                  color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Text(plant.emoji, style: const TextStyle(fontSize: 18)),
                  if (isSelected) ...[
                    const Gap(6),
                    Text(
                      plant.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(AppColors.potColors.length, (i) {
        final color = AppColors.potColors[i];
        final isSelected = i == selectedIndex;

        return GestureDetector(
          onTap: () => onChanged(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 10),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2.5)
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                : null,
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({
    required this.reminderTime,
    required this.onTap,
    required this.onClear,
  });

  final DateTime? reminderTime;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasReminder = reminderTime != null;
    final timeStr = hasReminder
        ? TimeOfDay.fromDateTime(reminderTime!).format(context)
        : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: hasReminder
              ? theme.colorScheme.primary.withAlpha(15)
              : (theme.brightness == Brightness.dark
                  ? AppColors.surface2Dark
                  : AppColors.surface2Light),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasReminder ? theme.colorScheme.primary.withAlpha(60) : theme.dividerColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.notifications_outlined,
              size: 20,
              color: hasReminder ? theme.colorScheme.primary : theme.colorScheme.onSurface.withAlpha(150),
            ),
            const Gap(10),
            Expanded(
              child: Text(
                hasReminder
                    ? t.addHabit.reminderSet(time: timeStr!)
                    : t.addHabit.reminderAdd,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: hasReminder ? theme.colorScheme.primary : theme.colorScheme.onSurface.withAlpha(150),
                ),
              ),
            ),
            if (hasReminder)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded, size: 18, color: theme.colorScheme.primary),
              ),
          ],
        ),
      ),
    );
  }
}
