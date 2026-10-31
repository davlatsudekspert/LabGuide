import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Ilova siyosati: server (`GET /v1/app-policy`) "yangilang" yoki "majburiy yangilash"
/// deydi. Ilova ochilganda, internet bo'lsa so'raladi. Xato / internet yo'q / noto'g'ri
/// javob — hech narsa bloklanmaydi (fail open): sozlama xatosi foydalanuvchini qulflamaydi.
enum UpdateNeed { none, available, required }

/// "1.2.3" yoki "1.2.3+4" -> [1, 2, 3]; noto'g'ri bo'lsa null.
List<int>? parseAppVersion(String? v) {
  final core = (v ?? '').trim().split(RegExp(r'[+ ]')).first;
  final m = RegExp(r'^(\d{1,4})\.(\d{1,4})\.(\d{1,4})$').firstMatch(core);
  if (m == null) return null;
  return [for (var i = 1; i <= 3; i++) int.parse(m.group(i)!)];
}

/// <0: a < b, 0: teng, >0: a > b.
int compareAppVersions(List<int> a, List<int> b) {
  for (var i = 0; i < 3; i++) {
    if (a[i] != b[i]) return a[i] - b[i];
  }
  return 0;
}

@immutable
class AppPolicy {
  const AppPolicy({this.minVersion, this.latestVersion, this.updateUrl});

  final List<int>? minVersion;
  final List<int>? latestVersion;

  /// Faqat https (server ham, ilova ham tekshiradi). Yo'q bo'lsa — tugma chiqmaydi.
  final Uri? updateUrl;

  static AppPolicy? fromJson(Object? json) {
    if (json is! Map) return null;
    Uri? url;
    final raw = json['update_url'];
    if (raw is String) {
      final u = Uri.tryParse(raw.trim());
      if (u != null && u.scheme == 'https' && u.host.isNotEmpty) url = u;
    }
    return AppPolicy(
      minVersion: parseAppVersion(json['min_version'] as String?),
      latestVersion: parseAppVersion(json['latest_version'] as String?),
      updateUrl: url,
    );
  }

  UpdateNeed needFor(String appVersion) {
    final cur = parseAppVersion(appVersion);
    if (cur == null) return UpdateNeed.none;
    final min = minVersion;
    if (min != null && compareAppVersions(cur, min) < 0) {
      return UpdateNeed.required;
    }
    final latest = latestVersion;
    if (latest != null && compareAppVersions(cur, latest) < 0) {
      return UpdateNeed.available;
    }
    return UpdateNeed.none;
  }
}

class AppPolicyController extends ChangeNotifier {
  AppPolicyController({
    required this.appVersion,
    required this.endpoint,
    http.Client? client,
    this.timeout = const Duration(seconds: 6),
  }) : _http = client ?? http.Client();

  final String appVersion;

  /// `GET /v1/app-policy?platform=...&version=...` (null — server sozlanmagan, hech narsa so'ralmaydi).
  final Uri? endpoint;
  final Duration timeout;
  final http.Client _http;

  AppPolicy? _policy;
  bool _softDismissed = false;

  AppPolicy? get policy => _policy;
  Uri? get updateUrl => _policy?.updateUrl;

  UpdateNeed get need {
    final n = _policy?.needFor(appVersion) ?? UpdateNeed.none;
    if (n == UpdateNeed.available && _softDismissed) return UpdateNeed.none;
    return n;
  }

  /// "Keyinroq": taklif shu ishga tushirishda qayta ko'rsatilmaydi. Majburiy yangilashni yopib bo'lmaydi.
  void dismissSoft() {
    _softDismissed = true;
    notifyListeners();
  }

  /// Xato bo'lsa jim: oldingi holat o'zgarmaydi.
  Future<void> refresh() async {
    final uri = endpoint;
    if (uri == null) return;
    try {
      final res = await _http.get(uri).timeout(timeout);
      if (res.statusCode != 200) return;
      final p = AppPolicy.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
      if (p == null) return;
      _policy = p;
      notifyListeners();
    } on Object {
      // Internet yo'q yoki server javob bermadi: bloklamaymiz.
    }
  }
}
