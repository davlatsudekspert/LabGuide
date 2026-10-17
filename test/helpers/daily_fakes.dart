import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart' show ValueChanged;

import 'package:labguide/features/daily/daily_reminder.dart';
import 'package:labguide/features/share/result_share.dart';

/// Testda bildirishnoma o'rniga: so'rovlar va reja yoziladi (har tur
/// alohida; [scheduled]/[texts]/[cancels] — kunlik eslatma).
class FakeReminderScheduler implements ReminderScheduler {
  FakeReminderScheduler({this.permission = ReminderPermission.granted});

  ReminderPermission permission;
  int permissionRequests = 0;
  final plans = <ReminderSlot, List<DateTime>>{};
  final textsBySlot = <ReminderSlot, ReminderTexts>{};
  final cancelsBySlot = <ReminderSlot, int>{};
  ValueChanged<ReminderSlot>? _onOpen;

  List<DateTime> get scheduled => plans[ReminderSlot.daily] ?? const [];
  set scheduled(List<DateTime> v) => plans[ReminderSlot.daily] = v;
  ReminderTexts? get texts => textsBySlot[ReminderSlot.daily];
  int get cancels => cancelsBySlot[ReminderSlot.daily] ?? 0;

  /// Bildirishnoma bosilgandek.
  void tap([ReminderSlot slot = ReminderSlot.daily]) => _onOpen?.call(slot);

  @override
  set onOpen(ValueChanged<ReminderSlot>? callback) => _onOpen = callback;

  @override
  Future<ReminderPermission> requestPermission() async {
    permissionRequests++;
    return permission;
  }

  @override
  Future<void> schedule(
    List<DateTime> times,
    ReminderTexts texts, {
    ReminderSlot slot = ReminderSlot.daily,
  }) async {
    plans[slot] = List.of(times);
    textsBySlot[slot] = texts;
  }

  @override
  Future<void> cancelAll({ReminderSlot slot = ReminderSlot.daily}) async {
    cancelsBySlot[slot] = (cancelsBySlot[slot] ?? 0) + 1;
    plans[slot] = [];
  }
}

/// Tizim ulashish oynasi o'rniga: yuborilgan rasm va matn yoziladi.
class FakeResultSharer implements ResultSharer {
  final shared = <(Uint8List, String)>[];
  bool available = true;

  @override
  Future<bool> share({
    required Uint8List png,
    required String text,
    Rect? origin,
  }) async {
    if (!available) return false;
    shared.add((png, text));
    return true;
  }
}
