import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/storage/kv_store.dart';
import '../../l10n/gen/app_localizations.dart';
import '../settings/settings_controller.dart';
import '../toifa/toifa_bank.dart' show toifaAvailable;
import '../toifa/toifa_controller.dart';
import '../toifa/toifa_daily.dart' show ToifaGoal;
import 'daily_controller.dart';

/// Bildirishnomaga ruxsat natijasi.
enum ReminderPermission {
  granted,
  denied,

  /// Platforma qo'llamaydi yoki plagin ishga tushmadi.
  unavailable,
}

/// Eslatma matnlari (ilova tilida).
typedef ReminderTexts = ({String title, String body, String channel});

/// Eslatma turi: har biri o'z bildirishnoma id lari va kanali bilan —
/// birini rejalashtirish/bekor qilish ikkinchisiga tegmaydi.
enum ReminderSlot {
  /// Kunlik 5 ta savol.
  daily(7100, 'daily_reminder'),

  /// Toifa mashg'uloti ("ertaga davom etamiz").
  toifa(7200, 'toifa_reminder');

  const ReminderSlot(this.baseId, this.channelId);

  final int baseId;
  final String channelId;

  /// Bildirishnoma `payload` idan (eski/bo'sh — kunlik).
  static ReminderSlot fromPayload(String? payload) =>
      payload == toifa.name ? toifa : daily;
}

/// Lokal bildirishnoma rejalashtiruvchi. Server/push yo'q — hammasi
/// qurilmaning o'zida.
abstract interface class ReminderScheduler {
  Future<ReminderPermission> requestPermission();

  /// Shu turdagi oldingi eslatmalar o'chiriladi, [times] dagi har biri bir
  /// martalik.
  Future<void> schedule(
    List<DateTime> times,
    ReminderTexts texts, {
    ReminderSlot slot = ReminderSlot.daily,
  });
  Future<void> cancelAll({ReminderSlot slot = ReminderSlot.daily});

  /// Bildirishnoma bosilganda (ilova ochilganda ham) chaqiriladi.
  set onOpen(ValueChanged<ReminderSlot>? callback);
}

/// Oldindan rejalashtiriladigan kunlar soni: ilova shuncha kun ochilmasa,
/// eslatmalar o'z-o'zidan to'xtaydi (bezovta qilinmaydi).
const kReminderDays = 7;

/// Keyingi eslatma vaqtlari (mahalliy vaqt). Bugungi to'plam bajarilgan yoki
/// vaqti o'tgan bo'lsa — ertadan. Mahalliy sana konstruktori yozgi vaqtni
/// o'zi hisobga oladi (har kuni aynan tanlangan soat).
List<DateTime> upcomingReminderTimes(
  DateTime now, {
  required int hour,
  required int minute,
  required bool todayDone,
  int count = kReminderDays,
}) {
  final out = <DateTime>[];
  for (var d = 0; out.length < count && d <= count; d++) {
    final t = DateTime(now.year, now.month, now.day + d, hour, minute);
    if (d == 0 && (todayDone || !t.isAfter(now))) continue;
    out.add(t);
  }
  return out;
}

/// `flutter_local_notifications` (BSD-3) orqali: Android'da aniq signal
/// (exact alarm) ruxsati so'ralmaydi — tizim qulay paytda (inexact)
/// ko'rsatadi, bir necha daqiqa kechikishi mumkin.
class LocalReminderScheduler implements ReminderScheduler {
  LocalReminderScheduler();

  final _plugin = FlutterLocalNotificationsPlugin();
  Future<bool>? _ready;
  ValueChanged<ReminderSlot>? _onOpen;

  @override
  set onOpen(ValueChanged<ReminderSlot>? callback) {
    _onOpen = callback;
    unawaited(_init());
  }

  Future<bool> _init() => _ready ??= () async {
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          // Ruxsat faqat foydalanuvchi eslatmani yoqqanda so'raladi.
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (r) =>
            _onOpen?.call(ReminderSlot.fromPayload(r.payload)),
      );
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        _onOpen?.call(
          ReminderSlot.fromPayload(launch!.notificationResponse?.payload),
        );
      }
      return true;
    } on MissingPluginException {
      return false;
    } on PlatformException catch (e) {
      debugPrint('reminder init failed: $e');
      return false;
    }
  }();

  @override
  Future<ReminderPermission> requestPermission() async {
    if (!await _init()) return ReminderPermission.unavailable;
    try {
      final bool? ok;
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          ok = await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission();
        case TargetPlatform.iOS:
          ok = await _plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, sound: true);
        default:
          return ReminderPermission.unavailable;
      }
      return ok ?? false
          ? ReminderPermission.granted
          : ReminderPermission.denied;
    } on PlatformException {
      return ReminderPermission.unavailable;
    }
  }

  Future<void> _cancelOurs(ReminderSlot slot) async {
    for (var i = 0; i <= kReminderDays; i++) {
      await _plugin.cancel(id: slot.baseId + i);
    }
  }

  @override
  Future<void> schedule(
    List<DateTime> times,
    ReminderTexts texts, {
    ReminderSlot slot = ReminderSlot.daily,
  }) async {
    if (!await _init()) return;
    try {
      await _cancelOurs(slot);
      final details = NotificationDetails(
        android: AndroidNotificationDetails(slot.channelId, texts.channel),
        iOS: const DarwinNotificationDetails(),
      );
      for (final (i, t) in times.indexed) {
        await _plugin.zonedSchedule(
          id: slot.baseId + i,
          title: texts.title,
          body: texts.body,
          payload: slot.name,
          // Aniq lahza (UTC): mahalliy vaqt mintaqasi bazasi kerak emas.
          scheduledDate: tz.TZDateTime.from(t.toUtc(), tz.UTC),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } on PlatformException catch (e) {
      debugPrint('reminder schedule failed: $e');
    }
  }

  @override
  Future<void> cancelAll({ReminderSlot slot = ReminderSlot.daily}) async {
    if (!await _init()) return;
    try {
      await _cancelOurs(slot);
    } on PlatformException catch (e) {
      debugPrint('reminder cancel failed: $e');
    }
  }
}

/// Kunlik eslatma sozlamasi: standart o'chiq, vaqtni foydalanuvchi tanlaydi.
/// Birinchi kunlik to'plamdan keyin bir marta muloyim taklif qilinadi.
class ReminderController extends ChangeNotifier {
  ReminderController(
    this._store,
    this._scheduler, {
    required this.daily,
    required this.settings,
    this.toifa,
  }) {
    _read();
    _scheduler.onOpen = _requestOpen;
    var todayDone = daily.streak.todayDone;
    var language = settings.language;
    var role = settings.role;
    daily.addListener(() {
      final done = daily.streak.todayDone;
      if (done == todayDone) return;
      todayDone = done;
      unawaited(sync());
    });
    settings.addListener(() {
      if (settings.language == language && settings.role == role) return;
      final languageChanged = settings.language != language;
      language = settings.language;
      role = settings.role;
      if (languageChanged) unawaited(sync());
      unawaited(syncToifa());
    });
    final t = toifa;
    if (t != null) {
      var goalMet = t.todayGoalMet;
      var goal = t.goalQuestions;
      var day = t.today;
      t.addListener(() {
        if (t.todayGoalMet == goalMet &&
            t.goalQuestions == goal &&
            t.today == day) {
          return;
        }
        goalMet = t.todayGoalMet;
        goal = t.goalQuestions;
        day = t.today;
        unawaited(syncToifa());
      });
    }
  }

  static const defaultHour = 20;
  static const defaultMinute = 0;

  final KeyValueStore _store;
  final ReminderScheduler _scheduler;
  final DailyController daily;
  final SettingsController settings;

  /// Toifa mashg'uloti (berilmasa — toifa eslatmasi yo'q).
  final ToifaController? toifa;

  bool _enabled = false;
  int _hour = defaultHour;
  int _minute = defaultMinute;
  bool _offerClosed = false;
  ReminderPermission? _lastDenied;
  bool _openPending = false;

  bool _toifaEnabled = false;
  int _toifaHour = defaultHour;
  int _toifaMinute = defaultMinute;
  bool _toifaOfferClosed = false;
  ReminderPermission? _toifaDenied;
  bool _toifaOpenPending = false;

  bool get enabled => _enabled;
  int get hour => _hour;
  int get minute => _minute;

  /// Oxirgi yoqish urinishi rad etildi (yoki platforma qo'llamadi).
  ReminderPermission? get lastDenied => _lastDenied;

  /// Taklif ko'rsatilsinmi: eslatma o'chiq, taklif yopilmagan.
  bool get shouldOffer => !_enabled && !_offerClosed;

  /// Toifa eslatmasi (standart o'chiq) va vaqti.
  bool get toifaEnabled => _toifaEnabled;
  int get toifaHour => _toifaHour;
  int get toifaMinute => _toifaMinute;
  ReminderPermission? get toifaDenied => _toifaDenied;

  /// "Ertaga davom etamizmi?" taklifi: bugungi maqsad bajarilgan va taklif
  /// yopilmagan (yoqilgan bo'lsa ham ko'rinadi — ertangi vaqtni eslatadi).
  bool get shouldOfferToifa =>
      (toifa?.todayGoalMet ?? false) && !_toifaOfferClosed;

  void _read() {
    _readToifa();
    final raw = _store.getString(StoreKeys.dailyReminder);
    if (raw == null) return;
    try {
      final j = (jsonDecode(raw) as Map).cast<String, Object?>();
      _enabled = j['on'] as bool? ?? false;
      _hour = (j['h'] as int? ?? defaultHour).clamp(0, 23);
      _minute = (j['m'] as int? ?? defaultMinute).clamp(0, 59);
      _offerClosed = j['offer'] as bool? ?? false;
    } on Object {
      // Buzilgan yozuv — standart (o'chiq).
    }
  }

  Future<void> _save() => _store.setString(
    StoreKeys.dailyReminder,
    jsonEncode({
      'on': _enabled,
      'h': _hour,
      'm': _minute,
      'offer': _offerClosed,
    }),
  );

  void _readToifa() {
    final raw = _store.getString(StoreKeys.toifaReminder);
    if (raw == null) return;
    try {
      final j = (jsonDecode(raw) as Map).cast<String, Object?>();
      _toifaEnabled = j['on'] as bool? ?? false;
      _toifaHour = (j['h'] as int? ?? defaultHour).clamp(0, 23);
      _toifaMinute = (j['m'] as int? ?? defaultMinute).clamp(0, 59);
      _toifaOfferClosed = j['offer'] as bool? ?? false;
    } on Object {
      // Buzilgan yozuv — standart (o'chiq).
    }
  }

  Future<void> _saveToifa() => _store.setString(
    StoreKeys.toifaReminder,
    jsonEncode({
      'on': _toifaEnabled,
      'h': _toifaHour,
      'm': _toifaMinute,
      'offer': _toifaOfferClosed,
    }),
  );

  void _requestOpen(ReminderSlot slot) {
    if (slot == ReminderSlot.toifa) {
      _toifaOpenPending = true;
    } else {
      _openPending = true;
    }
    notifyListeners();
  }

  /// Toifa eslatmasi bosilgan bo'lsa — bir marta true (ilova toifa
  /// bo'limini ochadi).
  bool takeToifaOpenRequest() {
    final p = _toifaOpenPending;
    _toifaOpenPending = false;
    return p;
  }

  /// Bildirishnoma bosilgan bo'lsa — bir marta true (ilova kunlik savolni
  /// ochadi).
  bool takeOpenRequest() {
    final p = _openPending;
    _openPending = false;
    return p;
  }

  ReminderTexts _texts() {
    final l = lookupAppLocalizations(settings.language.locale);
    return (
      title: l.dailyReminderTitle,
      body: l.dailyReminderBody,
      channel: l.dailyReminderChannel,
    );
  }

  /// Rejani yangilash (ilova ochilganda, kun bajarilganda, til yoki vaqt
  /// o'zgarganda).
  Future<void> sync() async {
    if (!_enabled) return;
    await _scheduler.schedule(
      upcomingReminderTimes(
        daily.now(),
        hour: _hour,
        minute: _minute,
        todayDone: daily.streak.todayDone,
      ),
      _texts(),
    );
  }

  /// Yoqish: avval tizim ruxsati so'raladi. Rad etilsa — o'chiq qoladi.
  Future<ReminderPermission> enable() async {
    final p = await _scheduler.requestPermission();
    if (p != ReminderPermission.granted) {
      _lastDenied = p;
      notifyListeners();
      return p;
    }
    _enabled = true;
    _offerClosed = true;
    _lastDenied = null;
    notifyListeners();
    await _save();
    await sync();
    return p;
  }

  Future<void> disable() async {
    _enabled = false;
    _lastDenied = null;
    notifyListeners();
    await _save();
    await _scheduler.cancelAll();
  }

  Future<void> setTime(int hour, int minute) async {
    _hour = hour.clamp(0, 23);
    _minute = minute.clamp(0, 59);
    notifyListeners();
    await _save();
    await sync();
  }

  /// "Kerak emas" — taklif boshqa ko'rsatilmaydi.
  Future<void> closeOffer() async {
    _offerClosed = true;
    notifyListeners();
    await _save();
  }

  // ----------------------------------------------------- Toifa eslatmasi

  ReminderTexts _toifaTexts() {
    final l = lookupAppLocalizations(settings.language.locale);
    return (
      title: l.toifaReminderTitle,
      body: l.toifaReminderBody(
        toifa?.goalQuestions ?? ToifaGoal.defaultQuestions,
      ),
      channel: l.toifaReminderChannel,
    );
  }

  /// Toifa bo'limi shu foydalanuvchiga ochiqmi (faqat sozlama; D-79).
  bool get _toifaAllowed => toifaAvailable(settings.attestationRegion);

  /// Toifa eslatmasi rejasi: bugungi maqsad bajarilgan bo'lsa — ertadan.
  /// Bo'lim yopiq (masalan, rol o'zgardi) — eslatmalar bekor qilinadi.
  Future<void> syncToifa() async {
    final t = toifa;
    if (!_toifaEnabled || t == null) return;
    if (!_toifaAllowed) {
      await _scheduler.cancelAll(slot: ReminderSlot.toifa);
      return;
    }
    await _scheduler.schedule(
      upcomingReminderTimes(
        t.now(),
        hour: _toifaHour,
        minute: _toifaMinute,
        todayDone: t.todayGoalMet,
      ),
      _toifaTexts(),
      slot: ReminderSlot.toifa,
    );
  }

  /// Toifa eslatmasini yoqish (ixtiyoriy vaqt bilan): avval tizim ruxsati
  /// (iOS/Android oynasi). Rad etilsa — o'chiq qoladi.
  Future<ReminderPermission> enableToifa({int? hour, int? minute}) async {
    final p = await _scheduler.requestPermission();
    if (p != ReminderPermission.granted) {
      _toifaDenied = p;
      notifyListeners();
      return p;
    }
    if (hour != null) _toifaHour = hour.clamp(0, 23);
    if (minute != null) _toifaMinute = minute.clamp(0, 59);
    _toifaEnabled = true;
    _toifaDenied = null;
    notifyListeners();
    await _saveToifa();
    await syncToifa();
    return p;
  }

  Future<void> disableToifa() async {
    _toifaEnabled = false;
    _toifaDenied = null;
    notifyListeners();
    await _saveToifa();
    await _scheduler.cancelAll(slot: ReminderSlot.toifa);
  }

  /// Vaqt (eslatma o'chiq bo'lsa ham — yoqilganda shu vaqt olinadi).
  Future<void> setToifaTime(int hour, int minute) async {
    _toifaHour = hour.clamp(0, 23);
    _toifaMinute = minute.clamp(0, 59);
    notifyListeners();
    await _saveToifa();
    await syncToifa();
  }

  /// "Kerak emas" — natijalardagi taklif boshqa ko'rsatilmaydi (sozlama
  /// "Bugun" kartasida qoladi).
  Future<void> closeToifaOffer() async {
    _toifaOfferClosed = true;
    notifyListeners();
    await _saveToifa();
  }

  /// "Lokal ma'lumotlarni o'chirish": eslatmalar ham bekor qilinadi.
  Future<void> reset() async {
    final was = _enabled;
    final wasToifa = _toifaEnabled;
    _enabled = false;
    _hour = defaultHour;
    _minute = defaultMinute;
    _offerClosed = false;
    _lastDenied = null;
    _toifaEnabled = false;
    _toifaHour = defaultHour;
    _toifaMinute = defaultMinute;
    _toifaOfferClosed = false;
    _toifaDenied = null;
    notifyListeners();
    if (was) await _scheduler.cancelAll();
    if (wasToifa) await _scheduler.cancelAll(slot: ReminderSlot.toifa);
  }
}
