import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/backend/lab_backend.dart';
import '../../core/backend/partner_models.dart';
import '../../core/storage/kv_store.dart';
import '../instruments/instrument_catalog.dart';

/// Hamkorlar (reklama) ro'yxati: serverdan olinadi va qurilmada keshlanadi —
/// internet bo'lmasa oxirgi ro'yxat ko'rinadi (muddati o'tgani baribir
/// yashiriladi). Server sozlanmagan buildda reklama joylari umuman yo'q.
///
/// Hisoblagichlar tejamkor: bir kunda bitta qurilmadan har hamkor × joy ×
/// hodisa turi bir marta yuboriladi, bir kadrdagi hodisalar bitta so'rovda.
/// Mehmon hodisasi yuborilmaydi (server faqat hisobli foydalanuvchini
/// sanaydi). Kim nimani ko'rgani hech qayerda saqlanmaydi.
class PartnersController extends ChangeNotifier {
  PartnersController(this._store, this._backend, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    _readCache();
  }

  final KeyValueStore _store;
  final LabBackend _backend;
  final DateTime Function() _clock;

  /// Shundan eski kesh fonda yangilanadi.
  static const refreshAfter = Duration(hours: 6);

  List<Partner> _all = const [];
  DateTime? _fetchedAt;
  Future<void>? _loading;
  final Set<String> _sent = {};
  final List<PartnerEvent> _queue = [];
  bool _flushScheduled = false;

  /// Reklama joylari faqat server ulangan buildda bor.
  bool get enabled => _backend.isConfigured;

  DateTime get today => tashkentToday(_clock());

  /// Oxirgi muvaffaqiyatli yangilanish (kesh bo'lsa ham).
  DateTime? get fetchedAt => _fetchedAt;

  /// E'lon qilingan va bugun faol hamkorlar.
  List<Partner> get live {
    if (!enabled) return const [];
    final day = today;
    return [
      for (final p in _all)
        if (p.isLiveOn(day)) p,
    ];
  }

  Partner? byId(String id) => live.where((p) => p.id == id).firstOrNull;

  /// Kunlik aylanish: har kuni boshqa hamkor birinchi bo'ladi (adolatli
  /// ko'rinish; katalog tartibiga aloqasi yo'q).
  List<Partner> _rotate(List<Partner> list) {
    if (list.length < 2) return list;
    final sorted = [...list]..sort((a, b) => a.id.compareTo(b.id));
    final shift = today.difference(DateTime.utc(2026)).inDays % sorted.length;
    return [...sorted.skip(shift), ...sorted.take(shift)];
  }

  /// Apparat kartasi: shu model bilan bog'langanlar, so'ng shu ishlab
  /// chiqaruvchi bilan bog'langanlar.
  List<Partner> forModel(InstrumentModel m) {
    final byModel = _rotate([
      for (final p in live)
        if (p.linksModel(m.id)) p,
    ]);
    final byMaker = _rotate([
      for (final p in live)
        if (!p.linksModel(m.id) && p.linksMaker(m.makerId)) p,
    ]);
    return [...byModel, ...byMaker];
  }

  /// Yo'nalish: shu yo'nalishdagi model yoki ishlab chiqaruvchi bilan
  /// bog'langan hamkorlar.
  List<Partner> forCategory(InstrumentCatalog catalog, InstrumentCategory c) {
    final models = catalog.inCategory(c);
    final modelIds = {for (final m in models) m.id};
    final makerIds = {for (final m in models) m.makerId};
    return _rotate([
      for (final p in live)
        if (p.links.any(
          (l) => l.target == PartnerLinkTarget.model
              ? modelIds.contains(l.catalogId)
              : makerIds.contains(l.catalogId),
        ))
          p,
    ]);
  }

  /// Lab bosh sahifasi uchun bitta hamkor (bo'lmasa — `null`).
  Partner? get featured => _rotate(live).firstOrNull;

  // ------------------------------------------------------------ yuklash
  void _readCache() {
    final raw = _store.getString(StoreKeys.partnersCache);
    if (raw == null) return;
    try {
      final json = jsonDecode(raw) as Map<String, Object?>;
      _all = [
        for (final p in json['partners']! as List)
          Partner.fromJson((p as Map).cast<String, Object?>()),
      ];
      _fetchedAt = DateTime.tryParse(json['fetched_at'] as String? ?? '');
    } on Object catch (e) {
      debugPrint('partners cache ignored: $e');
      _all = const [];
    }
  }

  /// Serverdan yangilaydi ([force] bo'lmasa — kesh [refreshAfter] dan eski
  /// bo'lganda). Xato bo'lsa kesh qoladi.
  Future<void> refresh({bool force = false}) {
    if (!enabled) return Future.value();
    final last = _fetchedAt;
    if (!force && last != null && _clock().difference(last) < refreshAfter) {
      return Future.value();
    }
    return _loading ??= _load().whenComplete(() => _loading = null);
  }

  Future<void> _load() async {
    try {
      final list = await _backend.partners();
      _all = list;
      _fetchedAt = _clock();
      await _store.setString(
        StoreKeys.partnersCache,
        jsonEncode({
          'fetched_at': _fetchedAt!.toIso8601String(),
          'partners': [for (final p in list) p.toJson()],
        }),
      );
      notifyListeners();
    } on Object catch (e) {
      debugPrint('partners refresh: $e');
    }
  }

  // -------------------------------------------------------- hisoblagich
  void trackImpression(Partner p, PartnerPlacement placement) =>
      _track(PartnerEvent(p.id, placement, PartnerEventKind.impression));

  void trackContact(Partner p, PartnerPlacement placement) =>
      _track(PartnerEvent(p.id, placement, PartnerEventKind.contact));

  void _track(PartnerEvent e) {
    if (!enabled || !_backend.hasSession) return;
    final key =
        '${today.toIso8601String()}|${e.partnerId}|'
        '${e.placement.wire}|${e.kind.name}';
    if (!_sent.add(key)) return;
    _queue.add(e);
    if (_flushScheduled) return;
    _flushScheduled = true;
    scheduleMicrotask(_flush);
  }

  Future<void> _flush() async {
    _flushScheduled = false;
    if (_queue.isEmpty) return;
    final batch = List.of(_queue);
    _queue.clear();
    try {
      await _backend.trackPartnerEvents(batch);
    } on Object catch (e) {
      // Hisoblagich ilova ishiga xalaqit bermaydi (cheklov, internet yo'q).
      debugPrint('partner events: $e');
    }
  }

  /// “Lokal ma'lumotlarni o'chirish”.
  void resetInMemory() {
    _all = const [];
    _fetchedAt = null;
    _sent.clear();
    _queue.clear();
    notifyListeners();
  }
}
