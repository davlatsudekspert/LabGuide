import 'dart:async';

import 'package:flutter/widgets.dart';

/// Ikki marta bosish himoyasi (single-flight): bitta amal tugamaguncha xuddi
/// shu amal qayta boshlanmaydi. Qulf SINXRON qo'yiladi — bir kadr ichidagi
/// ikkinchi bosish (tugma hali "band" ko'rinishiga o'tmasdan) ham tashlanadi.
///
/// * [SingleFlight] — kalit bo'yicha umumiy qulf (StatelessWidget
///   handlerlari, dialoglardan oldin tarmoq so'rovi bo'lgan joylar).
/// * [BusyGuard] — State uchun mixin: qulf + `setState` (tugma `busy`/
///   o'chirilgan holati shundan).
final class SingleFlight {
  SingleFlight._();

  static final Set<Object> _running = {};

  /// [key] bo'yicha amal hozir bajarilyaptimi.
  static bool isRunning(Object key) => _running.contains(key);

  /// [action] ni bajaradi; xuddi shu [key] bilan amal ketayotgan bo'lsa —
  /// hech narsa qilmaydi va `null` qaytaradi. Xato chaqiruvchiga o'tadi.
  static Future<T?> run<T>(Object key, Future<T> Function() action) async {
    if (!_running.add(key)) return null;
    try {
      return await action();
    } finally {
      _running.remove(key);
    }
  }

  static final Map<Object, Future<Object?>> _shared = {};

  /// Natijasi kerak bo'lgan amal: xuddi shu [key] bilan amal ketayotgan
  /// bo'lsa, ikkinchi chaqiruvchi YANGI so'rov yubormaydi — birinchisining
  /// natijasini (yoki xatosini) oladi. Masalan, javoblarni yuborish: ikkinchi
  /// bosish "allaqachon topshirilgan" xatosini ko'rsatmaydi.
  static Future<T> share<T>(Object key, Future<T> Function() action) {
    final running = _shared[key];
    if (running != null) return running.then((v) => v as T);
    final f = action();
    _shared[key] = f;
    f.whenComplete(() => _shared.remove(key)).ignore();
    return f;
  }

  /// Faqat testlar uchun.
  @visibleForTesting
  static void reset() {
    _running.clear();
    _shared.clear();
  }
}

/// State uchun: `guard(() async {...})` — amal davomida [isBusy] `true`
/// (tugmaga `busy: isBusy()` yoki `onPressed: isBusy() ? null : ...`).
/// [key] bilan bir ekranda bir nechta mustaqil amal (masalan, "o'chirish" va
/// "chiqarish") alohida qulflanadi.
mixin BusyGuard<W extends StatefulWidget> on State<W> {
  final Set<Object> _busyKeys = {};

  static const Object _default = Object();

  bool isBusy([Object key = _default]) => _busyKeys.contains(key);

  /// Biror amal ketyaptimi (ekrandagi hamma tugmalarni o'chirish uchun).
  bool get anyBusy => _busyKeys.isNotEmpty;

  Future<T?> guard<T>(
    Future<T> Function() action, {
    Object key = _default,
  }) async {
    if (!_busyKeys.add(key)) return null;
    if (mounted) setState(() {});
    try {
      return await action();
    } finally {
      _busyKeys.remove(key);
      if (mounted) setState(() {});
    }
  }
}
