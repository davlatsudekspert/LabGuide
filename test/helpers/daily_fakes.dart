import 'dart:typed_data';
import 'dart:ui';

import 'package:labguide/features/daily/daily_reminder.dart';
import 'package:labguide/features/share/result_share.dart';

/// Testda bildirishnoma o'rniga: so'rovlar va reja yoziladi.
class FakeReminderScheduler implements ReminderScheduler {
  FakeReminderScheduler({this.permission = ReminderPermission.granted});

  ReminderPermission permission;
  int permissionRequests = 0;
  List<DateTime> scheduled = [];
  ReminderTexts? texts;
  int cancels = 0;
  VoidCallback? _onOpen;

  /// Bildirishnoma bosilgandek.
  void tap() => _onOpen?.call();

  @override
  set onOpen(VoidCallback? callback) => _onOpen = callback;

  @override
  Future<ReminderPermission> requestPermission() async {
    permissionRequests++;
    return permission;
  }

  @override
  Future<void> schedule(List<DateTime> times, ReminderTexts texts) async {
    scheduled = List.of(times);
    this.texts = texts;
  }

  @override
  Future<void> cancelAll() async {
    cancels++;
    scheduled = [];
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
