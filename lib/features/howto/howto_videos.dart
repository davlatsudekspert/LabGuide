// “Qanday foydalaniladi?” videolari: ma’lumot fayli, tekshiruvchi va
// tarmoq tekshiruvi.
//
// Videolar ilova ichida EMAS (hajm ~40 MB) — egasi joylagan https manzilda;
// ilova faqat ro‘yxatni (assets/howto/videos.json) o‘qiydi va tugma
// bosilganda videoni tizim brauzeri/pleyerida ochadi. Ro‘yxat bo‘sh —
// hech bir oynada video tugmasi yo‘q. Reja va qarorlar:
// docs/video/DELIVERY_PLAN.md; ro‘yxatni yasash: tool/video/make_manifest.py.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'howto_registry.dart';

/// Ro‘yxat sxemasi versiyasi. O‘zgarsa — eski ilova yangi faylni rad etadi.
const kHowToVideosSchema = 1;

const kHowToVideosAsset = 'assets/howto/videos.json';

const _languages = {'uz', 'ru', 'en'};
const _topKeys = {'schema_version', 'owner_approval', 'videos'};
const _entryKeys = {
  'section',
  'lang',
  'url',
  'bytes',
  'seconds',
  'sha256',
  'start_seconds',
};

/// Bitta video uchun aqlli chegaralar (bizdagi fayllar 0,9–1,8 MB, ≤ 64 s).
const _maxBytes = 100 * 1000 * 1000;
const _maxSeconds = 30 * 60;

final _sha256 = RegExp(r'^[0-9a-f]{64}$');
final _approval = RegExp(r'^D-\d+[a-z]?$');

/// Hujjat va test uchun ajratilgan, haqiqiy bo‘lmagan domenlar (RFC 2606,
/// RFC 6761): ulardagi manzil ilovaga tushmasin.
bool _reservedHost(String host) {
  final h = host.toLowerCase();
  const tlds = ['.invalid', '.test', '.example', '.localhost', '.local'];
  const names = {'localhost', 'example.com', 'example.org', 'example.net'};
  return names.contains(h) ||
      tlds.any(h.endsWith) ||
      names.any((n) => h.endsWith('.$n'));
}

/// assets/howto/videos.json: bo‘lim → til → video.
///
/// [parse] har qanday nomuvofiqlikda [FormatException] beradi — buzuq
/// ro‘yxat yarim-yarti ko‘rsatilmaydi.
@immutable
class HowToVideoCatalog {
  const HowToVideoCatalog._(this._bySection, this.ownerApproval);

  static const empty = HowToVideoCatalog._({}, null);

  final Map<HowToSection, Map<String, HowToVideo>> _bySection;

  /// Videolarni ilovaga qo‘shishga egasining qarori (docs/DECISIONS.md dagi
  /// `D-NN`). Ro‘yxat bo‘sh bo‘lsa — `null`.
  final String? ownerApproval;

  bool get isEmpty => _bySection.isEmpty;

  int get length => _bySection.values.fold(0, (n, m) => n + m.length);

  /// Bo‘limning til → video xaritasi (bo‘lmasa — bo‘sh).
  Map<String, HowToVideo> forSection(HowToSection section) =>
      _bySection[section] ?? const {};

  static HowToVideoCatalog parse(String source) {
    final Object? json;
    try {
      json = jsonDecode(source);
    } on FormatException catch (e) {
      throw FormatException('videos.json: not JSON (${e.message})');
    }
    if (json is! Map) throw const FormatException('videos.json: not an object');
    final unknownTop = json.keys.where((k) => !_topKeys.contains(k));
    if (unknownTop.isNotEmpty) {
      throw FormatException('videos.json: unknown field ${unknownTop.first}');
    }
    if (json['schema_version'] != kHowToVideosSchema) {
      throw FormatException(
        'videos.json: unsupported schema_version ${json['schema_version']}',
      );
    }
    final list = json['videos'];
    if (list is! List) throw const FormatException('videos.json: no videos list');
    final approval = json['owner_approval'];
    if (approval != null && (approval is! String || !_approval.hasMatch(approval))) {
      throw FormatException('videos.json: owner_approval must be D-NN: $approval');
    }
    if (list.isNotEmpty && approval == null) {
      // Videoni ilovada ko‘rsatish — egasi qarori (hosting, maxfiylik
      // siyosati, do‘kon). Qarorsiz manzil ilovaga tushmaydi.
      throw const FormatException('videos.json: videos need owner_approval');
    }

    final bySection = <HowToSection, Map<String, HowToVideo>>{};
    final byUrl = <Uri, HowToVideo>{};
    for (final (i, raw) in list.indexed) {
      if (raw is! Map) throw FormatException('videos[$i]: not an object');
      final where = 'videos[$i]';
      final unknown = raw.keys.where((k) => !_entryKeys.contains(k));
      if (unknown.isNotEmpty) {
        throw FormatException('$where: unknown field ${unknown.first}');
      }
      final sectionId = raw['section'];
      final section = HowToSection.values
          .where((s) => s.id == sectionId)
          .firstOrNull;
      if (section == null) {
        throw FormatException('$where: unknown section $sectionId');
      }
      final lang = raw['lang'];
      if (lang is! String || !_languages.contains(lang)) {
        throw FormatException('$where: unknown lang $lang');
      }
      final video = _video(raw, '$where ($sectionId/$lang)');
      final videos = bySection.putIfAbsent(section, () => {});
      if (videos.containsKey(lang)) {
        throw FormatException('$where: duplicate $sectionId/$lang');
      }
      // Umumiy video (bir nechta bo‘lim) — bir xil fayl, bir xil o‘lchov.
      final known = byUrl[video.url];
      if (known != null &&
          (known.bytes != video.bytes ||
              known.sha256 != video.sha256 ||
              known.seconds != video.seconds)) {
        throw FormatException('$where: ${video.url} listed with other size/hash');
      }
      byUrl[video.url] = video;
      videos[lang] = video;
    }
    return HowToVideoCatalog._(
      {
        for (final e in bySection.entries) e.key: Map.unmodifiable(e.value),
      },
      approval as String?,
    );
  }

  static HowToVideo _video(Map<Object?, Object?> raw, String where) {
    final url = raw['url'];
    final uri = url is String ? Uri.tryParse(url) : null;
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasFragment) {
      throw FormatException('$where: url must be a plain https URL: $url');
    }
    if (_reservedHost(uri.host)) {
      throw FormatException('$where: placeholder host ${uri.host}');
    }
    final bytes = raw['bytes'];
    if (bytes is! int || bytes <= 0 || bytes > _maxBytes) {
      throw FormatException('$where: bad or missing bytes: $bytes');
    }
    final seconds = raw['seconds'];
    if (seconds is! num || seconds <= 0 || seconds > _maxSeconds) {
      throw FormatException('$where: bad or missing seconds: $seconds');
    }
    final sha = raw['sha256'];
    if (sha is! String || !_sha256.hasMatch(sha)) {
      throw FormatException('$where: bad or missing sha256');
    }
    final start = raw['start_seconds'];
    if (start != null && (start is! num || start < 0 || start >= seconds)) {
      throw FormatException('$where: bad start_seconds: $start');
    }
    return HowToVideo(
      url: uri,
      bytes: bytes,
      seconds: seconds.toDouble(),
      sha256: sha,
      startSeconds: (start as num?)?.toDouble(),
    );
  }
}

/// Tugma bosilganda video manzili tekshiruvi natijasi.
enum HowToVideoReach {
  /// Server javob berdi, hajm ro‘yxatdagidek (yoki server hajmni aytmadi).
  ok,

  /// Internet yo‘q, ulanish uzildi yoki javob kelmadi.
  offline,

  /// Server bor, lekin fayl yo‘q (404 va h.k.) yoki hajmi boshqa.
  unavailable,
}

/// Ro‘yxatni yuklaydi va tugma bosilganda manzilni tekshiradi.
///
/// Tarmoqqa faqat foydalanuvchi “Videoni ko‘rish” ni bosganda murojaat
/// qilinadi: bitta HEAD so‘rovi (cookie, identifikator yo‘q), keyin video
/// tizim brauzeri/pleyerida ochiladi.
class HowToVideoService {
  HowToVideoService({
    required this._bundle,
    required this._client,
    this.timeout = const Duration(seconds: 8),
  });

  AssetBundle _bundle;
  http.Client _client;
  final Duration timeout;

  HowToVideoCatalog? _catalog;
  Future<HowToVideoCatalog>? _loading;

  /// Yuklangan ro‘yxat (hali yuklanmagan bo‘lsa — bo‘sh).
  HowToVideoCatalog get catalog => _catalog ?? HowToVideoCatalog.empty;

  /// Ro‘yxat yuklanganmi (yuklanmagan bo‘lsa — [ensureLoaded]).
  bool get isLoaded => _catalog != null;

  /// Ro‘yxatni bir marta yuklaydi. Fayl yo‘q yoki buzuq — bo‘sh ro‘yxat
  /// (matnli qo‘llanma baribir ishlaydi); xato debug konsolga yoziladi.
  Future<HowToVideoCatalog> ensureLoaded() => _loading ??= _load();

  Future<HowToVideoCatalog> _load() async {
    var catalog = HowToVideoCatalog.empty;
    try {
      catalog = HowToVideoCatalog.parse(
        await _bundle.loadString(kHowToVideosAsset, cache: false),
      );
    } on Object catch (e) {
      debugPrint('how-to videos: $e');
    }
    return _catalog = catalog;
  }

  /// Bo‘lim mazmuni + ro‘yxatdagi videolari.
  HowToContent contentFor(HowToSection section) {
    final videos = catalog.forSection(section);
    final base = HowToRegistry.of(section);
    return videos.isEmpty ? base : base.withVideos(videos);
  }

  /// Videoni ochishdan oldin: internet bormi va fayl joyidami.
  Future<HowToVideoReach> probe(HowToVideo video) async {
    try {
      final res = await _client
          .send(http.Request('HEAD', video.url))
          .timeout(timeout);
      unawaited(res.stream.drain<void>().catchError((_) {}));
      if (res.statusCode < 200 || res.statusCode >= 300) {
        return HowToVideoReach.unavailable;
      }
      final length = int.tryParse(res.headers['content-length'] ?? '');
      if (length != null && length > 0 && length != video.bytes) {
        return HowToVideoReach.unavailable;
      }
      return HowToVideoReach.ok;
    } on TimeoutException {
      return HowToVideoReach.offline;
    } on SocketException {
      return HowToVideoReach.offline;
    } on http.ClientException {
      return HowToVideoReach.offline;
    } on HandshakeException {
      return HowToVideoReach.unavailable;
    } on Object {
      return HowToVideoReach.offline;
    }
  }

  /// Faqat testlar va ekran rasmlari (tool/screenshots) uchun: ro‘yxat
  /// va/yoki tarmoqni almashtirish. Ilova kodida chaqirilmaydi.
  void debugUse({
    HowToVideoCatalog? catalog,
    http.Client? client,
    AssetBundle? bundle,
  }) {
    if (bundle != null) {
      _bundle = bundle;
      _loading = null;
      _catalog = null;
    }
    if (catalog != null) {
      _catalog = catalog;
      _loading = Future.value(catalog);
    }
    if (client != null) _client = client;
  }
}
