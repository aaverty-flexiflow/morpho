///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsFr = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.fr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <fr>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final Translations$common$fr common = Translations$common$fr._(_root);
	late final Translations$garden$fr garden = Translations$garden$fr._(_root);
	late final Translations$habitDetail$fr habitDetail = Translations$habitDetail$fr._(_root);
	late final Translations$plantStage$fr plantStage = Translations$plantStage$fr._(_root);
	late final Translations$addHabit$fr addHabit = Translations$addHabit$fr._(_root);
	late final Translations$habitCard$fr habitCard = Translations$habitCard$fr._(_root);
	late final Translations$archived$fr archived = Translations$archived$fr._(_root);
	late final Translations$settings$fr settings = Translations$settings$fr._(_root);
	late final Translations$onboarding$fr onboarding = Translations$onboarding$fr._(_root);
	late final Translations$frequency$fr frequency = Translations$frequency$fr._(_root);
	late final Translations$plantType$fr plantType = Translations$plantType$fr._(_root);
}

// Path: common
class Translations$common$fr {
	Translations$common$fr._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// fr: 'Annuler'
	String get cancel => 'Annuler';

	/// fr: 'Supprimer'
	String get delete => 'Supprimer';

	/// fr: 'Erreur : {error}'
	String error({required Object error}) => 'Erreur : ${error}';
}

// Path: garden
class Translations$garden$fr {
	Translations$garden$fr._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// fr: 'Bonjour 🌿'
	String get greetingMorning => 'Bonjour 🌿';

	/// fr: 'Bonne journée 🌱'
	String get greetingDay => 'Bonne journée 🌱';

	/// fr: 'Bonsoir 🌙'
	String get greetingEvening => 'Bonsoir 🌙';

	/// fr: '{done}/{total} aujourd'hui'
	String todayProgress({required Object done, required Object total}) => '${done}/${total} aujourd\'hui';

	/// fr: 'Paramètres'
	String get settingsTooltip => 'Paramètres';

	/// fr: 'Ton jardin t'attend'
	String get emptyTitle => 'Ton jardin t\'attend';

	/// fr: 'Crée ta première habitude pour planter ta première graine.'
	String get emptySubtitle => 'Crée ta première habitude\npour planter ta première graine.';

	/// fr: 'Habitude'
	String get addHabitLabel => 'Habitude';

	/// fr: 'Impossible de charger ton jardin'
	String get loadError => 'Impossible de charger ton jardin';
}

// Path: habitDetail
class Translations$habitDetail$fr {
	Translations$habitDetail$fr._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// fr: 'Streak actuel'
	String get statStreak => 'Streak actuel';

	/// fr: 'Record'
	String get statRecord => 'Record';

	/// fr: '30j taux'
	String get statRate => '30j taux';

	/// fr: '30 derniers jours'
	String get last30Days => '30 derniers jours';

	/// fr: 'Valider pour aujourd'hui'
	String get checkIn => 'Valider pour aujourd\'hui';

	/// fr: 'Complété aujourd'hui !'
	String get completedToday => 'Complété aujourd\'hui !';

	/// fr: 'Annuler la validation'
	String get undoCheckIn => 'Annuler la validation';

	/// fr: 'Archiver'
	String get archive => 'Archiver';

	/// fr: 'Cette habitude n'existe plus.'
	String get notFound => 'Cette habitude n\'existe plus.';

	/// fr: 'Supprimer l'habitude ?'
	String get deleteTitle => 'Supprimer l\'habitude ?';

	/// fr: 'Toutes les données de suivi seront perdues.'
	String get deleteBody => 'Toutes les données de suivi seront perdues.';
}

// Path: plantStage
class Translations$plantStage$fr {
	Translations$plantStage$fr._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// fr: 'Graine 🌑'
	String get seed => 'Graine 🌑';

	/// fr: 'Pousse 🌱'
	String get sprout => 'Pousse 🌱';

	/// fr: 'Plante jeune 🌿'
	String get young => 'Plante jeune 🌿';

	/// fr: 'Plante mature 🌳'
	String get mature => 'Plante mature 🌳';

	/// fr: 'Plante légendaire ✨'
	String get legendary => 'Plante légendaire ✨';
}

// Path: addHabit
class Translations$addHabit$fr {
	Translations$addHabit$fr._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// fr: 'Nouvelle habitude'
	String get title => 'Nouvelle habitude';

	/// fr: 'Méditation, lecture, sport…'
	String get namePlaceholder => 'Méditation, lecture, sport…';

	/// fr: 'Donne un nom à ton habitude'
	String get nameRequired => 'Donne un nom à ton habitude';

	/// fr: 'Au moins 2 caractères'
	String get nameMinLength => 'Au moins 2 caractères';

	/// fr: 'Fréquence'
	String get sectionFrequency => 'Fréquence';

	/// fr: 'Plante'
	String get sectionPlant => 'Plante';

	/// fr: 'Couleur du pot'
	String get sectionColor => 'Couleur du pot';

	/// fr: 'Planter 🌱'
	String get submit => 'Planter 🌱';

	/// fr: 'Rappel à {time}'
	String reminderSet({required Object time}) => 'Rappel à ${time}';

	/// fr: 'Ajouter un rappel (optionnel)'
	String get reminderAdd => 'Ajouter un rappel (optionnel)';
}

// Path: habitCard
class Translations$habitCard$fr {
	Translations$habitCard$fr._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// fr: 'Commencer'
	String get start => 'Commencer';

	/// fr: 'Cette sem. ✓'
	String get thisWeekDone => 'Cette sem. ✓';
}

// Path: archived
class Translations$archived$fr {
	Translations$archived$fr._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// fr: 'Habitudes archivées'
	String get title => 'Habitudes archivées';

	/// fr: 'Restaurer'
	String get restoreTooltip => 'Restaurer';

	/// fr: 'Supprimer définitivement'
	String get deleteTooltip => 'Supprimer définitivement';

	/// fr: '{name} restaurée 🌱'
	String restoredSnackbar({required Object name}) => '${name} restaurée 🌱';

	/// fr: 'Supprimer définitivement ?'
	String get deleteTitle => 'Supprimer définitivement ?';

	/// fr: '{name} et tout son historique seront supprimés. Cette action est irréversible.'
	String deleteBody({required Object name}) => '${name} et tout son historique seront supprimés. Cette action est irréversible.';

	/// fr: 'Aucune habitude archivée'
	String get emptyTitle => 'Aucune habitude archivée';

	/// fr: 'Les habitudes que tu archives apparaîtront ici.'
	String get emptySubtitle => 'Les habitudes que tu archives\napparaîtront ici.';
}

// Path: settings
class Translations$settings$fr {
	Translations$settings$fr._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// fr: 'Paramètres'
	String get title => 'Paramètres';

	/// fr: 'Apparence'
	String get sectionAppearance => 'Apparence';

	/// fr: 'Système'
	String get themeSystem => 'Système';

	/// fr: 'Clair'
	String get themeLight => 'Clair';

	/// fr: 'Sombre'
	String get themeDark => 'Sombre';

	/// fr: 'Habitudes'
	String get sectionHabits => 'Habitudes';

	/// fr: 'Habitudes archivées'
	String get archivedTitle => 'Habitudes archivées';

	/// fr: 'Voir et restaurer les habitudes archivées.'
	String get archivedSubtitle => 'Voir et restaurer les habitudes archivées.';

	/// fr: 'Période de grâce (1 jour)'
	String get gracePeriodTitle => 'Période de grâce (1 jour)';

	/// fr: 'Un oubli toléré par semaine sans casser le streak.'
	String get gracePeriodSubtitle => 'Un oubli toléré par semaine sans casser le streak.';

	/// fr: 'Notifications'
	String get sectionNotifications => 'Notifications';

	/// fr: 'Vérification…'
	String get notifChecking => 'Vérification…';

	/// fr: 'Notifications activées'
	String get notifActive => 'Notifications activées';

	/// fr: 'Activer les notifications'
	String get notifActivateTitle => 'Activer les notifications';

	/// fr: 'Rappels quotidiens pour tes habitudes.'
	String get notifActivateSubtitle => 'Rappels quotidiens pour tes habitudes.';

	/// fr: 'Autorise les notifications dans les Réglages de l'appareil.'
	String get notifDeniedSnackbar => 'Autorise les notifications dans les Réglages de l\'appareil.';

	/// fr: 'À propos'
	String get sectionAbout => 'À propos';

	/// fr: 'Version'
	String get version => 'Version';

	/// fr: '1.0.0'
	String get versionNumber => '1.0.0';

	/// fr: 'Construis des habitudes, fais pousser des plantes.'
	String get appDescription => 'Construis des habitudes, fais pousser des plantes.';
}

// Path: onboarding
class Translations$onboarding$fr {
	Translations$onboarding$fr._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// fr: 'Suivant'
	String get next => 'Suivant';

	/// fr: 'Commencer 🌱'
	String get start => 'Commencer 🌱';

	/// fr: 'Bienvenue sur Morpho'
	String get welcomeTitle => 'Bienvenue sur Morpho';

	/// fr: 'Construis des habitudes solides et regarde tes plantes s'épanouir.'
	String get welcomeSubtitle => 'Construis des habitudes solides\net regarde tes plantes s\'épanouir.';

	/// fr: 'Comment ça marche ?'
	String get howTitle => 'Comment ça marche ?';

	/// fr: 'Crée une habitude'
	String get step1Title => 'Crée une habitude';

	/// fr: 'Choisis ta plante et personnalise ton pot.'
	String get step1Subtitle => 'Choisis ta plante et personnalise ton pot.';

	/// fr: 'Valide chaque jour'
	String get step2Title => 'Valide chaque jour';

	/// fr: 'Un geste quotidien pour arroser ta plante.'
	String get step2Subtitle => 'Un geste quotidien pour arroser ta plante.';

	/// fr: 'Construis ton streak'
	String get step3Title => 'Construis ton streak';

	/// fr: 'Plus ton streak grandit, plus ta plante évolue.'
	String get step3Subtitle => 'Plus ton streak grandit, plus ta plante évolue.';

	/// fr: 'Atteins le stade légendaire'
	String get step4Title => 'Atteins le stade légendaire';

	/// fr: '100 jours consécutifs — la plante ultime.'
	String get step4Subtitle => '100 jours consécutifs — la plante ultime.';

	/// fr: 'C'est bon !'
	String get notifGrantedTitle => 'C\'est bon !';

	/// fr: 'Ne rate rien'
	String get notifTitle => 'Ne rate rien';

	/// fr: 'Les rappels sont activés. Tu peux les gérer habitude par habitude.'
	String get notifGrantedSubtitle => 'Les rappels sont activés. Tu peux les gérer habitude par habitude.';

	/// fr: 'Active les rappels pour ne pas oublier de valider tes habitudes chaque jour.'
	String get notifSubtitle => 'Active les rappels pour ne pas oublier de valider tes habitudes chaque jour.';

	/// fr: 'Activer les notifications'
	String get notifButton => 'Activer les notifications';
}

// Path: frequency
class Translations$frequency$fr {
	Translations$frequency$fr._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// fr: 'Quotidien'
	String get daily => 'Quotidien';

	/// fr: '2×/semaine'
	String get twiceWeek => '2×/semaine';

	/// fr: '3×/semaine'
	String get thriceWeek => '3×/semaine';

	/// fr: '4×/semaine'
	String get fourWeek => '4×/semaine';

	/// fr: '5×/semaine'
	String get fiveWeek => '5×/semaine';

	/// fr: '6×/semaine'
	String get sixWeek => '6×/semaine';

	/// fr: 'Hebdomadaire'
	String get weekly => 'Hebdomadaire';

	/// fr: 'Quotidien'
	String get dailyShort => 'Quotidien';

	/// fr: '2×/sem'
	String get twiceWeekShort => '2×/sem';

	/// fr: '3×/sem'
	String get thriceWeekShort => '3×/sem';

	/// fr: '4×/sem'
	String get fourWeekShort => '4×/sem';

	/// fr: '5×/sem'
	String get fiveWeekShort => '5×/sem';

	/// fr: '6×/sem'
	String get sixWeekShort => '6×/sem';

	/// fr: 'Hebdo'
	String get weeklyShort => 'Hebdo';

	/// fr: 'j'
	String get streakUnitDay => 'j';

	/// fr: 'sem.'
	String get streakUnitWeek => 'sem.';
}

// Path: plantType
class Translations$plantType$fr {
	Translations$plantType$fr._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// fr: 'Fougère'
	String get fern => 'Fougère';

	/// fr: 'Cactus'
	String get cactus => 'Cactus';

	/// fr: 'Orchidée'
	String get orchid => 'Orchidée';

	/// fr: 'Bonsaï'
	String get bonsai => 'Bonsaï';

	/// fr: 'Tournesol'
	String get sunflower => 'Tournesol';

	/// fr: 'Bambou'
	String get bamboo => 'Bambou';
}

/// The flat map containing all translations for locale <fr>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.cancel' => 'Annuler',
			'common.delete' => 'Supprimer',
			'common.error' => ({required Object error}) => 'Erreur : ${error}',
			'garden.greetingMorning' => 'Bonjour 🌿',
			'garden.greetingDay' => 'Bonne journée 🌱',
			'garden.greetingEvening' => 'Bonsoir 🌙',
			'garden.todayProgress' => ({required Object done, required Object total}) => '${done}/${total} aujourd\'hui',
			'garden.settingsTooltip' => 'Paramètres',
			'garden.emptyTitle' => 'Ton jardin t\'attend',
			'garden.emptySubtitle' => 'Crée ta première habitude\npour planter ta première graine.',
			'garden.addHabitLabel' => 'Habitude',
			'garden.loadError' => 'Impossible de charger ton jardin',
			'habitDetail.statStreak' => 'Streak actuel',
			'habitDetail.statRecord' => 'Record',
			'habitDetail.statRate' => '30j taux',
			'habitDetail.last30Days' => '30 derniers jours',
			'habitDetail.checkIn' => 'Valider pour aujourd\'hui',
			'habitDetail.completedToday' => 'Complété aujourd\'hui !',
			'habitDetail.undoCheckIn' => 'Annuler la validation',
			'habitDetail.archive' => 'Archiver',
			'habitDetail.notFound' => 'Cette habitude n\'existe plus.',
			'habitDetail.deleteTitle' => 'Supprimer l\'habitude ?',
			'habitDetail.deleteBody' => 'Toutes les données de suivi seront perdues.',
			'plantStage.seed' => 'Graine 🌑',
			'plantStage.sprout' => 'Pousse 🌱',
			'plantStage.young' => 'Plante jeune 🌿',
			'plantStage.mature' => 'Plante mature 🌳',
			'plantStage.legendary' => 'Plante légendaire ✨',
			'addHabit.title' => 'Nouvelle habitude',
			'addHabit.namePlaceholder' => 'Méditation, lecture, sport…',
			'addHabit.nameRequired' => 'Donne un nom à ton habitude',
			'addHabit.nameMinLength' => 'Au moins 2 caractères',
			'addHabit.sectionFrequency' => 'Fréquence',
			'addHabit.sectionPlant' => 'Plante',
			'addHabit.sectionColor' => 'Couleur du pot',
			'addHabit.submit' => 'Planter 🌱',
			'addHabit.reminderSet' => ({required Object time}) => 'Rappel à ${time}',
			'addHabit.reminderAdd' => 'Ajouter un rappel (optionnel)',
			'habitCard.start' => 'Commencer',
			'habitCard.thisWeekDone' => 'Cette sem. ✓',
			'archived.title' => 'Habitudes archivées',
			'archived.restoreTooltip' => 'Restaurer',
			'archived.deleteTooltip' => 'Supprimer définitivement',
			'archived.restoredSnackbar' => ({required Object name}) => '${name} restaurée 🌱',
			'archived.deleteTitle' => 'Supprimer définitivement ?',
			'archived.deleteBody' => ({required Object name}) => '${name} et tout son historique seront supprimés. Cette action est irréversible.',
			'archived.emptyTitle' => 'Aucune habitude archivée',
			'archived.emptySubtitle' => 'Les habitudes que tu archives\napparaîtront ici.',
			'settings.title' => 'Paramètres',
			'settings.sectionAppearance' => 'Apparence',
			'settings.themeSystem' => 'Système',
			'settings.themeLight' => 'Clair',
			'settings.themeDark' => 'Sombre',
			'settings.sectionHabits' => 'Habitudes',
			'settings.archivedTitle' => 'Habitudes archivées',
			'settings.archivedSubtitle' => 'Voir et restaurer les habitudes archivées.',
			'settings.gracePeriodTitle' => 'Période de grâce (1 jour)',
			'settings.gracePeriodSubtitle' => 'Un oubli toléré par semaine sans casser le streak.',
			'settings.sectionNotifications' => 'Notifications',
			'settings.notifChecking' => 'Vérification…',
			'settings.notifActive' => 'Notifications activées',
			'settings.notifActivateTitle' => 'Activer les notifications',
			'settings.notifActivateSubtitle' => 'Rappels quotidiens pour tes habitudes.',
			'settings.notifDeniedSnackbar' => 'Autorise les notifications dans les Réglages de l\'appareil.',
			'settings.sectionAbout' => 'À propos',
			'settings.version' => 'Version',
			'settings.versionNumber' => '1.0.0',
			'settings.appDescription' => 'Construis des habitudes, fais pousser des plantes.',
			'onboarding.next' => 'Suivant',
			'onboarding.start' => 'Commencer 🌱',
			'onboarding.welcomeTitle' => 'Bienvenue sur Morpho',
			'onboarding.welcomeSubtitle' => 'Construis des habitudes solides\net regarde tes plantes s\'épanouir.',
			'onboarding.howTitle' => 'Comment ça marche ?',
			'onboarding.step1Title' => 'Crée une habitude',
			'onboarding.step1Subtitle' => 'Choisis ta plante et personnalise ton pot.',
			'onboarding.step2Title' => 'Valide chaque jour',
			'onboarding.step2Subtitle' => 'Un geste quotidien pour arroser ta plante.',
			'onboarding.step3Title' => 'Construis ton streak',
			'onboarding.step3Subtitle' => 'Plus ton streak grandit, plus ta plante évolue.',
			'onboarding.step4Title' => 'Atteins le stade légendaire',
			'onboarding.step4Subtitle' => '100 jours consécutifs — la plante ultime.',
			'onboarding.notifGrantedTitle' => 'C\'est bon !',
			'onboarding.notifTitle' => 'Ne rate rien',
			'onboarding.notifGrantedSubtitle' => 'Les rappels sont activés. Tu peux les gérer habitude par habitude.',
			'onboarding.notifSubtitle' => 'Active les rappels pour ne pas oublier de valider tes habitudes chaque jour.',
			'onboarding.notifButton' => 'Activer les notifications',
			'frequency.daily' => 'Quotidien',
			'frequency.twiceWeek' => '2×/semaine',
			'frequency.thriceWeek' => '3×/semaine',
			'frequency.fourWeek' => '4×/semaine',
			'frequency.fiveWeek' => '5×/semaine',
			'frequency.sixWeek' => '6×/semaine',
			'frequency.weekly' => 'Hebdomadaire',
			'frequency.dailyShort' => 'Quotidien',
			'frequency.twiceWeekShort' => '2×/sem',
			'frequency.thriceWeekShort' => '3×/sem',
			'frequency.fourWeekShort' => '4×/sem',
			'frequency.fiveWeekShort' => '5×/sem',
			'frequency.sixWeekShort' => '6×/sem',
			'frequency.weeklyShort' => 'Hebdo',
			'frequency.streakUnitDay' => 'j',
			'frequency.streakUnitWeek' => 'sem.',
			'plantType.fern' => 'Fougère',
			'plantType.cactus' => 'Cactus',
			'plantType.orchid' => 'Orchidée',
			'plantType.bonsai' => 'Bonsaï',
			'plantType.sunflower' => 'Tournesol',
			'plantType.bamboo' => 'Bambou',
			_ => null,
		};
	}
}
