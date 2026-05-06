import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Android / mobile imports — only used on non-Windows platforms
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
// Windows desktop import
import 'package:local_notifier/local_notifier.dart';
import 'package:mushaf_hifd/src/constants.dart';
import 'package:mushaf_hifd/main.dart'; // For navigatorKey
import 'package:mushaf_hifd/src/pages/learn2_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Singleton accessor
// ─────────────────────────────────────────────────────────────────────────────

late NotificationService _notificationService;

/// We fire 8 times a day, every 3 hours.
const int _slotsPerDay = 8;
const int _intervalHours = 3;

class NotificationService extends LocalNotificationListener {
  // ── Android plugin — lazy, created only when needed ───────────────────────
  FlutterLocalNotificationsPlugin? _androidPlugin;
  static const int _baseNotifId = 9000;
  static const int _learningNotifId = 9100;

  final List<String> _encouragingPhrases = [
    "واصل مسيرك في حفظ كتاب الله! 🌟",
    "المراجعة هي سر الحفظ المتين، لا تهملها! 📖",
    "خطوة بخطوة نحو الختم، استعن بالله وإحتسب بكل حرف تقرأه حسنة و مل حرف تحفظه درجة في الجنة. ❤️",
    "وقت الحفظ هو أعظم أوقات يومك، اغتنمه. ⌛",
  ];

  // ── Windows: timers keyed by composite id (thomun * 10 + slot) ────────────
  final Map<int, Timer> _windowsTimers = {};

  // ── Private constructor ───────────────────────────────────────────────────
  NotificationService._();

  static void initialize() {
    _notificationService = NotificationService._();
  }

  static NotificationService get instance => _notificationService;

  // ─────────────────────────────────────────────────────────────────────────
  // Initialization
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> initializeNotifications() async {
    if (Platform.isWindows) {
      await _initWindows();
    } else {
      await _initAndroid();
    }
  }

  // ── Windows ──────────────────────────────────────────────────────────────

  Future<void> _initWindows() async {
    await localNotifier.setup(
      appName: 'مصحف الحفظ',
      shortcutPolicy: ShortcutPolicy.requireCreate,
    );

    localNotifier.addListener(this);
  }

  @override
  void onClick(LocalNotification notification) {
    if (notification.identifier != null) {
      final int? index = int.tryParse(notification.identifier!);
      if (index != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => Learn2Page(initialIndex: index),
          ),
        );
      }
    }
  }

  // ── Android ──────────────────────────────────────────────────────────────

  Future<void> _initAndroid() async {
    // 1. Initialize timezone database
    tz.initializeTimeZones();

    // 2. Set tz.local to the device's local timezone using the offset
    //    flutter_local_notifications works with tz.local; without this all
    //    scheduled times would default to UTC.
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    final offsetHours = offset.inHours;
    final offsetMinutes = (offset.inMinutes % 60).abs();
    final sign = offsetHours >= 0 ? '+' : '-';
    final tzName =
        'Etc/GMT${sign == '+' ? '-' : '+'}${offsetHours.abs()}'
        '${offsetMinutes > 0 ? ':$offsetMinutes' : ''}';

    try {
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (_) {
      // If the exact offset-based name is not found, try common fallback
      try {
        tz.setLocalLocation(tz.getLocation('Africa/Casablanca'));
      } catch (_) {
        // Leave as UTC — better than crashing
      }
    }

    // 3. Create and initialise the plugin
    _androidPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _androidPlugin!.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        if (details.payload != null) {
          final int? index = int.tryParse(details.payload!);
          if (index != null) {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => Learn2Page(initialIndex: index),
              ),
            );
          }
        }
      },
    );

    // 4. Request Android 13+ notification permission
    await Permission.notification.request();

    // 5. Request exact-alarm permission (Android 12+)
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Schedule every-3-hour revision reminders for one thomun
  //
  // Notification IDs: thomunIndex * 10 + slotIndex  (slot 0..7)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> scheduleRevisionReminder(int _) async {
    // We no longer schedule per-thumon. Instead we refresh the global daily schedule.
    await rescheduleAllReminders();
  }

  // ── Windows every-3-hours scheduling ─────────────────────────────────────

  Future<void> _scheduleWindowsSlot({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    _windowsTimers[id]?.cancel();

    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    final delay = scheduled.difference(now);

    _windowsTimers[id] = Timer(delay, () async {
      await _showWindowsToast(
        identifier: payload ?? 'reminder_$id',
        title: title,
        body: body,
      );
      // Re-arm for tomorrow
      _scheduleWindowsSlot(
        id: id,
        title: title,
        body: body,
        hour: hour,
        minute: minute,
        payload: payload,
      );
    });
  }

  Future<void> _showWindowsToast({
    required String identifier,
    required String title,
    required String body,
  }) async {
    final notification = LocalNotification(
      identifier: identifier,
      title: title,
      body: body,
    );
    await notification.show();
  }

  // ── Android every-3-hours scheduling ─────────────────────────────────────
  // Schedules 8 independent daily-repeating notifications (one per 3-hour slot).
  //
  // Key fix: instead of using `matchDateTimeComponents: DateTimeComponents.time`
  // (which has edge cases near midnight), we schedule each slot as an absolute
  // zonedSchedule and then re-schedule it from within an onDidReceiveNotification
  // callback — OR, simpler: we just loop through all 8 slots and for each one
  // find the correct next fire time, then use matchDateTimeComponents: .time
  // so it auto-repeats daily.  The fix for midnight wrap-around is to use
  // `isAfter` (strict greater-than) instead of `isBefore` when checking
  // whether to advance to tomorrow.

  Future<void> _scheduleAndroidSlot({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    if (_androidPlugin == null) return;

    final bigTextStyle = BigTextStyleInformation(
      body,
      contentTitle: title,
      summaryText: 'اسحب لرؤية الثمن كاملاً',
    );

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'hifd_reminder_channel',
          'تذكيرات الحفظ والمراجعة',
          channelDescription: 'تذكيرات يومية لمتابعة حفظ ومراجعة القرآن الكريم',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          styleInformation: bigTextStyle,
          actions: <AndroidNotificationAction>[
            const AndroidNotificationAction(
              'show_more',
              'عرض الثمن في المصحف',
              showsUserInterface: true,
            ),
          ],
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
      0,
    );

    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _androidPlugin!.zonedSchedule(
        id,
        title,
        body.length > 100 ? '${body.substring(0, 100)}...' : body,
        scheduledDate,
        notificationDetails,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Error scheduling id $id: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Cancel all reminders for one thomun (all 8 slots)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> cancelReminder(int _) async {
    // Individual cancels are ignored because we always refresh the whole 8-slot block.
    await rescheduleAllReminders();
  }

  Future<void> _cancelAllDailySlots() async {
    for (int i = 0; i < _slotsPerDay; i++) {
      final id1 = _baseNotifId + i;
      final id2 = _learningNotifId + i;
      if (Platform.isWindows) {
        _windowsTimers[id1]?.cancel();
        _windowsTimers.remove(id1);
        _windowsTimers[id2]?.cancel();
        _windowsTimers.remove(id2);
      } else {
        await _androidPlugin?.cancel(id1);
        await _androidPlugin?.cancel(id2);
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Reschedule ALL active revised thomuns (call when the user changes time)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> rescheduleAllReminders() async {
    await _cancelAllDailySlots();

    final prefs = await SharedPreferences.getInstance();

    // 1. REVISION PREP
    final revisedList = (prefs.getStringList('revised_thomuns_txt') ?? [])
        .map((e) => int.tryParse(e))
        .whereType<int>()
        .toList();

    // 2. LEARNING PREP
    final learningIndex = prefs.getInt('current_thomun_txt_index') ?? 0;

    final startTime = prefs.getString('revision_reminder_time') ?? '09:00';
    final timeParts = startTime.split(':');
    final startHour = int.parse(timeParts[0]);
    final startMinute = int.parse(timeParts[1]);

    // Randomize indices for 8 revision slots
    final List<int> selectedIndices = [];
    if (revisedList.isNotEmpty) {
      revisedList.shuffle();
      for (int i = 0; i < _slotsPerDay; i++) {
        selectedIndices.add(revisedList[i % revisedList.length]);
      }
    }

    for (int slot = 0; slot < _slotsPerDay; slot++) {
      final slotHour = (startHour + slot * _intervalHours) % 24;
      final encouragingMsg =
          _encouragingPhrases[slot % _encouragingPhrases.length];

      // A. Schedule REVISION Notif
      if (revisedList.isNotEmpty) {
        final body = await _getThomunSnippet(selectedIndices[slot]);
        const title = 'ورد المراجعة اليومي 📖';
        if (Platform.isWindows) {
          await _scheduleWindowsSlot(
            id: _baseNotifId + slot,
            title: title,
            body: body,
            hour: slotHour,
            minute: startMinute,
            payload: selectedIndices[slot].toString(),
          );
        } else {
          await _scheduleAndroidSlot(
            id: _baseNotifId + slot,
            title: title,
            body: body,
            hour: slotHour,
            minute: startMinute,
            payload: selectedIndices[slot].toString(),
          );
        }
      }

      // B. Schedule LEARNING Notif
      if (learningIndex < kThomunsTxt.length) {
        final body = await _getThomunSnippet(learningIndex);
        final title = 'استمر في الحفظ\n $encouragingMsg';
        if (Platform.isWindows) {
          await _scheduleWindowsSlot(
            id: _learningNotifId + slot,
            minute: startMinute,
            hour: slotHour,
            body: body,
            title: title,
            payload: learningIndex.toString(),
          );
        } else {
          await _scheduleAndroidSlot(
            id: _learningNotifId + slot,
            minute: startMinute,
            hour: slotHour,
            body: body,
            title: title,
            payload: learningIndex.toString(),
          );
        }
      }
    }
  }

  Future<String> _getThomunSnippet(int index) async {
    try {
      final text = await rootBundle.loadString(
        'lib/thomuns_txt/${kThomunsTxt[index].file}',
      );
      // Formatting for better readability in notification
      return text.replaceAll('(', '﴿').replaceAll(')', '﴾').trim();
    } catch (_) {
      return 'ثمن للمراجعة...';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Reminder start-time helpers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> setReminderTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('revision_reminder_time', time);
  }

  Future<String> getReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('revision_reminder_time') ?? '09:00';
  }
}
