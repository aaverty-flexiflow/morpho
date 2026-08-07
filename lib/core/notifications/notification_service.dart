import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Thin wrapper around [FlutterLocalNotificationsPlugin].
///
/// Call [initialize] once at app startup (before [runApp]).
/// Each habit gets a stable notification id derived from its database id.
abstract final class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialises timezone database and registers notification channels.
  /// Safe to call multiple times — subsequent calls are no-ops.
  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    // flutter_timezone 5.x returns TimezoneInfo; .identifier is the IANA name.
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    // All permissions are requested explicitly in the onboarding/settings flow.
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // flutter_local_notifications 22.x uses named parameters.
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: darwin),
    );

    await _createAndroidChannel();
    _initialized = true;
  }

  /// Requests system permission to show notifications.
  /// Returns whether the permission was granted.
  static Future<bool> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          false;
    }
    return false;
  }

  /// Schedules (or replaces) a daily reminder for [habitId] at [time].
  ///
  /// The notification fires every day at the same local time. Calling this
  /// again with the same [habitId] cancels the previous schedule.
  static Future<void> scheduleDaily({
    required int habitId,
    required String habitName,
    required DateTime time,
  }) async {
    await cancel(habitId);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time already passed today, start tomorrow.
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: _notifId(habitId),
      title: 'Morpho 🌱',
      body: '$habitName vous attend aujourd\'hui !',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'morpho_reminders',
          'Rappels d\'habitudes',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          categoryIdentifier: 'habit_reminder',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // daily repeat
    );
  }

  /// Cancels the scheduled notification for [habitId].
  static Future<void> cancel(int habitId) async {
    await _plugin.cancel(id: _notifId(habitId));
  }

  /// Returns the count of pending scheduled notifications, or -1 on error.
  /// Used as a lightweight permission check (works on both platforms).
  static Future<int> pendingCount() async {
    try {
      final pending = await _plugin.pendingNotificationRequests();
      return pending.length;
    } catch (_) {
      return -1;
    }
  }

  // Offset habit ids by a constant so they don't collide with other apps.
  static int _notifId(int habitId) => habitId + 1000;

  static Future<void> _createAndroidChannel() async {
    const channel = AndroidNotificationChannel(
      'morpho_reminders',
      'Rappels d\'habitudes',
      description: 'Rappels quotidiens pour vos habitudes Morpho',
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}
