///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsEn with BaseTranslations<AppLocale, Translations> implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	late final TranslationsEn _root = this; // ignore: unused_field

	@override 
	TranslationsEn $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEn(meta: meta ?? this.$meta);

	// Translations
	@override late final _Translations$common$en common = _Translations$common$en._(_root);
	@override late final _Translations$garden$en garden = _Translations$garden$en._(_root);
	@override late final _Translations$habitDetail$en habitDetail = _Translations$habitDetail$en._(_root);
	@override late final _Translations$plantStage$en plantStage = _Translations$plantStage$en._(_root);
	@override late final _Translations$addHabit$en addHabit = _Translations$addHabit$en._(_root);
	@override late final _Translations$habitCard$en habitCard = _Translations$habitCard$en._(_root);
	@override late final _Translations$archived$en archived = _Translations$archived$en._(_root);
	@override late final _Translations$settings$en settings = _Translations$settings$en._(_root);
	@override late final _Translations$onboarding$en onboarding = _Translations$onboarding$en._(_root);
	@override late final _Translations$frequency$en frequency = _Translations$frequency$en._(_root);
	@override late final _Translations$plantType$en plantType = _Translations$plantType$en._(_root);
}

// Path: common
class _Translations$common$en implements Translations$common$fr {
	_Translations$common$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get cancel => 'Cancel';
	@override String get delete => 'Delete';
	@override String error({required Object error}) => 'Error: ${error}';
}

// Path: garden
class _Translations$garden$en implements Translations$garden$fr {
	_Translations$garden$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get greetingMorning => 'Good morning 🌿';
	@override String get greetingDay => 'Good afternoon 🌱';
	@override String get greetingEvening => 'Good evening 🌙';
	@override String todayProgress({required Object done, required Object total}) => '${done}/${total} today';
	@override String get settingsTooltip => 'Settings';
	@override String get emptyTitle => 'Your garden awaits';
	@override String get emptySubtitle => 'Create your first habit\nto plant your first seed.';
	@override String get addHabitLabel => 'Habit';
	@override String get loadError => 'Could not load your garden';
}

// Path: habitDetail
class _Translations$habitDetail$en implements Translations$habitDetail$fr {
	_Translations$habitDetail$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get statStreak => 'Current streak';
	@override String get statRecord => 'Record';
	@override String get statRate => '30d rate';
	@override String get last30Days => 'Last 30 days';
	@override String get checkIn => 'Complete for today';
	@override String get completedToday => 'Completed today!';
	@override String get undoCheckIn => 'Undo completion';
	@override String get archive => 'Archive';
	@override String get notFound => 'This habit no longer exists.';
	@override String get deleteTitle => 'Delete habit?';
	@override String get deleteBody => 'All tracking data will be permanently lost.';
}

// Path: plantStage
class _Translations$plantStage$en implements Translations$plantStage$fr {
	_Translations$plantStage$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get seed => 'Seed 🌑';
	@override String get sprout => 'Sprout 🌱';
	@override String get young => 'Young plant 🌿';
	@override String get mature => 'Mature plant 🌳';
	@override String get legendary => 'Legendary plant ✨';
}

// Path: addHabit
class _Translations$addHabit$en implements Translations$addHabit$fr {
	_Translations$addHabit$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'New habit';
	@override String get namePlaceholder => 'Meditation, reading, exercise…';
	@override String get nameRequired => 'Give your habit a name';
	@override String get nameMinLength => 'At least 2 characters';
	@override String get sectionFrequency => 'Frequency';
	@override String get sectionPlant => 'Plant';
	@override String get sectionColor => 'Pot colour';
	@override String get submit => 'Plant it 🌱';
	@override String reminderSet({required Object time}) => 'Reminder at ${time}';
	@override String get reminderAdd => 'Add a reminder (optional)';
}

// Path: habitCard
class _Translations$habitCard$en implements Translations$habitCard$fr {
	_Translations$habitCard$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get start => 'Start';
	@override String get thisWeekDone => 'This wk. ✓';
}

// Path: archived
class _Translations$archived$en implements Translations$archived$fr {
	_Translations$archived$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Archived habits';
	@override String get restoreTooltip => 'Restore';
	@override String get deleteTooltip => 'Delete permanently';
	@override String restoredSnackbar({required Object name}) => '${name} restored 🌱';
	@override String get deleteTitle => 'Delete permanently?';
	@override String deleteBody({required Object name}) => '${name} and all its history will be deleted. This cannot be undone.';
	@override String get emptyTitle => 'No archived habits';
	@override String get emptySubtitle => 'Habits you archive\nwill appear here.';
}

// Path: settings
class _Translations$settings$en implements Translations$settings$fr {
	_Translations$settings$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Settings';
	@override String get sectionAppearance => 'Appearance';
	@override String get themeSystem => 'System';
	@override String get themeLight => 'Light';
	@override String get themeDark => 'Dark';
	@override String get sectionHabits => 'Habits';
	@override String get archivedTitle => 'Archived habits';
	@override String get archivedSubtitle => 'View and restore archived habits.';
	@override String get gracePeriodTitle => 'Grace period (1 day)';
	@override String get gracePeriodSubtitle => 'One missed day forgiven per streak.';
	@override String get sectionNotifications => 'Notifications';
	@override String get notifChecking => 'Checking…';
	@override String get notifActive => 'Notifications enabled';
	@override String get notifActivateTitle => 'Enable notifications';
	@override String get notifActivateSubtitle => 'Daily reminders for your habits.';
	@override String get notifDeniedSnackbar => 'Allow notifications in your device Settings.';
	@override String get sectionAbout => 'About';
	@override String get version => 'Version';
	@override String get versionNumber => '1.0.0';
	@override String get appDescription => 'Build habits, grow plants.';
}

// Path: onboarding
class _Translations$onboarding$en implements Translations$onboarding$fr {
	_Translations$onboarding$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get next => 'Next';
	@override String get start => 'Get started 🌱';
	@override String get welcomeTitle => 'Welcome to Morpho';
	@override String get welcomeSubtitle => 'Build lasting habits\nand watch your plants flourish.';
	@override String get howTitle => 'How does it work?';
	@override String get step1Title => 'Create a habit';
	@override String get step1Subtitle => 'Choose your plant and customise your pot.';
	@override String get step2Title => 'Check in daily';
	@override String get step2Subtitle => 'One tap a day to water your plant.';
	@override String get step3Title => 'Build your streak';
	@override String get step3Subtitle => 'The longer your streak, the more your plant evolves.';
	@override String get step4Title => 'Reach legendary';
	@override String get step4Subtitle => '100 consecutive days — the ultimate plant.';
	@override String get notifGrantedTitle => 'You\'re all set!';
	@override String get notifTitle => 'Never miss a day';
	@override String get notifGrantedSubtitle => 'Reminders are on. Manage them per habit.';
	@override String get notifSubtitle => 'Enable reminders so you never forget to check in.';
	@override String get notifButton => 'Enable notifications';
}

// Path: frequency
class _Translations$frequency$en implements Translations$frequency$fr {
	_Translations$frequency$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get daily => 'Daily';
	@override String get twiceWeek => '2×/week';
	@override String get thriceWeek => '3×/week';
	@override String get fourWeek => '4×/week';
	@override String get fiveWeek => '5×/week';
	@override String get sixWeek => '6×/week';
	@override String get weekly => 'Weekly';
	@override String get dailyShort => 'Daily';
	@override String get twiceWeekShort => '2×/wk';
	@override String get thriceWeekShort => '3×/wk';
	@override String get fourWeekShort => '4×/wk';
	@override String get fiveWeekShort => '5×/wk';
	@override String get sixWeekShort => '6×/wk';
	@override String get weeklyShort => 'Weekly';
	@override String get streakUnitDay => 'd';
	@override String get streakUnitWeek => 'wk';
}

// Path: plantType
class _Translations$plantType$en implements Translations$plantType$fr {
	_Translations$plantType$en._(this._root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get fern => 'Fern';
	@override String get cactus => 'Cactus';
	@override String get orchid => 'Orchid';
	@override String get bonsai => 'Bonsai';
	@override String get sunflower => 'Sunflower';
	@override String get bamboo => 'Bamboo';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEn {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.cancel' => 'Cancel',
			'common.delete' => 'Delete',
			'common.error' => ({required Object error}) => 'Error: ${error}',
			'garden.greetingMorning' => 'Good morning 🌿',
			'garden.greetingDay' => 'Good afternoon 🌱',
			'garden.greetingEvening' => 'Good evening 🌙',
			'garden.todayProgress' => ({required Object done, required Object total}) => '${done}/${total} today',
			'garden.settingsTooltip' => 'Settings',
			'garden.emptyTitle' => 'Your garden awaits',
			'garden.emptySubtitle' => 'Create your first habit\nto plant your first seed.',
			'garden.addHabitLabel' => 'Habit',
			'garden.loadError' => 'Could not load your garden',
			'habitDetail.statStreak' => 'Current streak',
			'habitDetail.statRecord' => 'Record',
			'habitDetail.statRate' => '30d rate',
			'habitDetail.last30Days' => 'Last 30 days',
			'habitDetail.checkIn' => 'Complete for today',
			'habitDetail.completedToday' => 'Completed today!',
			'habitDetail.undoCheckIn' => 'Undo completion',
			'habitDetail.archive' => 'Archive',
			'habitDetail.notFound' => 'This habit no longer exists.',
			'habitDetail.deleteTitle' => 'Delete habit?',
			'habitDetail.deleteBody' => 'All tracking data will be permanently lost.',
			'plantStage.seed' => 'Seed 🌑',
			'plantStage.sprout' => 'Sprout 🌱',
			'plantStage.young' => 'Young plant 🌿',
			'plantStage.mature' => 'Mature plant 🌳',
			'plantStage.legendary' => 'Legendary plant ✨',
			'addHabit.title' => 'New habit',
			'addHabit.namePlaceholder' => 'Meditation, reading, exercise…',
			'addHabit.nameRequired' => 'Give your habit a name',
			'addHabit.nameMinLength' => 'At least 2 characters',
			'addHabit.sectionFrequency' => 'Frequency',
			'addHabit.sectionPlant' => 'Plant',
			'addHabit.sectionColor' => 'Pot colour',
			'addHabit.submit' => 'Plant it 🌱',
			'addHabit.reminderSet' => ({required Object time}) => 'Reminder at ${time}',
			'addHabit.reminderAdd' => 'Add a reminder (optional)',
			'habitCard.start' => 'Start',
			'habitCard.thisWeekDone' => 'This wk. ✓',
			'archived.title' => 'Archived habits',
			'archived.restoreTooltip' => 'Restore',
			'archived.deleteTooltip' => 'Delete permanently',
			'archived.restoredSnackbar' => ({required Object name}) => '${name} restored 🌱',
			'archived.deleteTitle' => 'Delete permanently?',
			'archived.deleteBody' => ({required Object name}) => '${name} and all its history will be deleted. This cannot be undone.',
			'archived.emptyTitle' => 'No archived habits',
			'archived.emptySubtitle' => 'Habits you archive\nwill appear here.',
			'settings.title' => 'Settings',
			'settings.sectionAppearance' => 'Appearance',
			'settings.themeSystem' => 'System',
			'settings.themeLight' => 'Light',
			'settings.themeDark' => 'Dark',
			'settings.sectionHabits' => 'Habits',
			'settings.archivedTitle' => 'Archived habits',
			'settings.archivedSubtitle' => 'View and restore archived habits.',
			'settings.gracePeriodTitle' => 'Grace period (1 day)',
			'settings.gracePeriodSubtitle' => 'One missed day forgiven per streak.',
			'settings.sectionNotifications' => 'Notifications',
			'settings.notifChecking' => 'Checking…',
			'settings.notifActive' => 'Notifications enabled',
			'settings.notifActivateTitle' => 'Enable notifications',
			'settings.notifActivateSubtitle' => 'Daily reminders for your habits.',
			'settings.notifDeniedSnackbar' => 'Allow notifications in your device Settings.',
			'settings.sectionAbout' => 'About',
			'settings.version' => 'Version',
			'settings.versionNumber' => '1.0.0',
			'settings.appDescription' => 'Build habits, grow plants.',
			'onboarding.next' => 'Next',
			'onboarding.start' => 'Get started 🌱',
			'onboarding.welcomeTitle' => 'Welcome to Morpho',
			'onboarding.welcomeSubtitle' => 'Build lasting habits\nand watch your plants flourish.',
			'onboarding.howTitle' => 'How does it work?',
			'onboarding.step1Title' => 'Create a habit',
			'onboarding.step1Subtitle' => 'Choose your plant and customise your pot.',
			'onboarding.step2Title' => 'Check in daily',
			'onboarding.step2Subtitle' => 'One tap a day to water your plant.',
			'onboarding.step3Title' => 'Build your streak',
			'onboarding.step3Subtitle' => 'The longer your streak, the more your plant evolves.',
			'onboarding.step4Title' => 'Reach legendary',
			'onboarding.step4Subtitle' => '100 consecutive days — the ultimate plant.',
			'onboarding.notifGrantedTitle' => 'You\'re all set!',
			'onboarding.notifTitle' => 'Never miss a day',
			'onboarding.notifGrantedSubtitle' => 'Reminders are on. Manage them per habit.',
			'onboarding.notifSubtitle' => 'Enable reminders so you never forget to check in.',
			'onboarding.notifButton' => 'Enable notifications',
			'frequency.daily' => 'Daily',
			'frequency.twiceWeek' => '2×/week',
			'frequency.thriceWeek' => '3×/week',
			'frequency.fourWeek' => '4×/week',
			'frequency.fiveWeek' => '5×/week',
			'frequency.sixWeek' => '6×/week',
			'frequency.weekly' => 'Weekly',
			'frequency.dailyShort' => 'Daily',
			'frequency.twiceWeekShort' => '2×/wk',
			'frequency.thriceWeekShort' => '3×/wk',
			'frequency.fourWeekShort' => '4×/wk',
			'frequency.fiveWeekShort' => '5×/wk',
			'frequency.sixWeekShort' => '6×/wk',
			'frequency.weeklyShort' => 'Weekly',
			'frequency.streakUnitDay' => 'd',
			'frequency.streakUnitWeek' => 'wk',
			'plantType.fern' => 'Fern',
			'plantType.cactus' => 'Cactus',
			'plantType.orchid' => 'Orchid',
			'plantType.bonsai' => 'Bonsai',
			'plantType.sunflower' => 'Sunflower',
			'plantType.bamboo' => 'Bamboo',
			_ => null,
		};
	}
}
