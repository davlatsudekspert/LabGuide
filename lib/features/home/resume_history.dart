import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/storage/kv_store.dart';
import '../../l10n/gen/app_localizations.dart';
import '../classroom/lecture_catalog.dart';
import 'search_sections.dart';

// Bosh sahifadagi “Davom ettirish” (D-69 Q3): oxirgi ochilgan taqdimot,
// mavzu testi yoki bo'lim — faqat shu qurilmada (StoreKeys.homeResume).
// Yozuv router manzilidan olinadi (app.dart → ResumeHistory.note), shuning
// uchun har ekran o'zi yozishi shart emas.

enum ResumeKind { deck, topicTest, section }

@immutable
class ResumeEntry {
  const ResumeEntry(this.kind, this.id);

  final ResumeKind kind;

  /// Deck id (deck, topicTest) yoki [SearchSection.id] (section).
  final String id;

  /// Ochiladigan manzil.
  String? get location => switch (kind) {
    ResumeKind.deck => '/learn/lecture/deck/$id',
    ResumeKind.topicTest => '/learn/lecture/test/$id',
    ResumeKind.section => sectionById(id)?.route,
  };

  /// Taqdimot va mavzu testi — to'liq ekran (push); bo'lim — o'z tabida.
  bool get fullScreen => kind != ResumeKind.section;

  String encode() => '${kind.name}:$id';

  static ResumeEntry? decode(String? raw) {
    if (raw == null) return null;
    final i = raw.indexOf(':');
    if (i <= 0 || i == raw.length - 1) return null;
    final kind = ResumeKind.values.asNameMap()[raw.substring(0, i)];
    if (kind == null) return null;
    final e = ResumeEntry(kind, raw.substring(i + 1));
    return e.location == null ? null : e;
  }

  @override
  bool operator ==(Object other) =>
      other is ResumeEntry && other.kind == kind && other.id == id;

  @override
  int get hashCode => Object.hash(kind, id);

  @override
  String toString() => encode();
}

SearchSection? sectionById(String id) {
  for (final s in kSearchSections) {
    if (s.id == id) return s;
  }
  return null;
}

/// Router manzili → “davom ettirish” yozuvi (bo'lmasa `null`).
/// `/learn/lecture/deck/<id>` — taqdimot, `/learn/lecture/test/<id>` — mavzu
/// testi, bo'lim manzili yoki uning ichidagi sahifa — bo'lim.
ResumeEntry? resumeEntryFor(Uri uri) {
  final seg = uri.pathSegments;
  if (seg.length == 4 && seg[0] == 'learn' && seg[1] == 'lecture') {
    if (seg[2] == 'deck') return ResumeEntry(ResumeKind.deck, seg[3]);
    if (seg[2] == 'test') return ResumeEntry(ResumeKind.topicTest, seg[3]);
  }
  final path = uri.path;
  for (final s in kSearchSections) {
    if (path == s.route || path.startsWith('${s.route}/')) {
      return ResumeEntry(ResumeKind.section, s.id);
    }
  }
  return null;
}

/// Yozuv nomi joriy tilda. Taqdimot/test uchun katalog kerak: yuklanmagan
/// yoki deck topilmasa — `null` (bosh sahifa rolning boshlang'ich amalini
/// ko'rsatadi).
String? resumeTitle(
  ResumeEntry e,
  AppLocalizations l,
  String lang,
  DeckCatalog? catalog,
) {
  switch (e.kind) {
    case ResumeKind.section:
      return sectionById(e.id)?.title(l);
    case ResumeKind.deck:
      return catalog?.byId(e.id)?.title(lang);
    case ResumeKind.topicTest:
      final t = catalog?.byId(e.id)?.title(lang);
      return t == null ? null : l.topicTestTitle(t);
  }
}

/// Oxirgi ochilgan narsa (bitta yozuv). Ombor bo'yicha bitta nusxa.
class ResumeHistory extends ChangeNotifier {
  ResumeHistory._(this._store)
    : _last = ResumeEntry.decode(_store.getString(StoreKeys.homeResume));

  static final _cache = Expando<ResumeHistory>();

  static ResumeHistory of(KeyValueStore store) =>
      _cache[store] ??= ResumeHistory._(store);

  final KeyValueStore _store;
  ResumeEntry? _last;

  ResumeEntry? get last => _last;

  /// Router manzili o'zgarganda chaqiriladi.
  void note(Uri uri) {
    final e = resumeEntryFor(uri);
    if (e == null || e == _last) return;
    _last = e;
    // Xotirada darhol; omborga — fonda (xato bo'lsa ham UI ishlayveradi).
    _store.setString(StoreKeys.homeResume, e.encode()).ignore();
    _notify();
  }

  /// "Lokal ma'lumotlarni o'chirish" dan keyin.
  void resetInMemory() {
    if (_last == null) return;
    _last = null;
    _notify();
  }

  // Navigatsiya kadr qurilayotganda ham bo'lishi mumkin — tinglovchilar
  // (bosh sahifa) build paytida emas, kadrdan keyin yangilanadi.
  void _notify() {
    final binding = SchedulerBinding.instance;
    if (binding.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      binding.addPostFrameCallback((_) => notifyListeners());
    } else {
      notifyListeners();
    }
  }
}
