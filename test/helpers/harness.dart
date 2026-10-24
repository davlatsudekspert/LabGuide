import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:go_router/go_router.dart';
import 'package:labguide/app/app.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/app/widgets/lg_page.dart';
import 'package:labguide/core/backend/community_backend.dart';
import 'package:labguide/core/backend/lab_backend.dart';
import 'package:labguide/core/build_flags.dart';
import 'package:labguide/core/entitlements/device_attestor.dart';
import 'package:labguide/core/entitlements/entitlement_cache.dart';
import 'package:labguide/core/entitlements/entitlement_source.dart';
import 'package:labguide/core/entitlements/feature.dart';
import 'package:labguide/core/entitlements/purchase_adapter.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/auth/otp_auth.dart';
import 'package:labguide/features/auth/social_auth.dart';
import 'package:labguide/features/classroom/lecture_catalog.dart';
import 'package:labguide/features/classroom/lecture_decks.dart';
import 'package:labguide/features/classroom/qr_scanner.dart';
import 'package:labguide/features/daily/daily_reminder.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/features/share/result_share.dart';
import 'package:labguide/main.dart';
import 'package:material_ui/material_ui.dart';

import 'daily_fakes.dart';
import 'fake_qr_scanner.dart';

/// Haqiqiy Inter va Material Icons shriftlarini yuklaydi: overflow
/// tekshiruvi test shriftida (har harf = kvadrat) emas, ilovadagi kabi
/// matn kengligida o'tadi.
Future<void> loadAppFonts() async {
  Future<ByteData> file(String path) async =>
      ByteData.sublistView(File(path).readAsBytesSync());
  final inter = FontLoader('Inter');
  for (final w in [400, 500, 600, 700]) {
    inter.addFont(file('assets/fonts/Inter-$w.ttf'));
  }
  await inter.load();
  // Ivory mavzusining sarlavha shriftlari (D-64).
  await (FontLoader(
    'InstrumentSerif',
  )..addFont(file('assets/fonts/InstrumentSerif-Regular.ttf'))).load();
  await (FontLoader(
    'PlayfairDisplay',
  )..addFont(file('assets/fonts/PlayfairDisplay-Variable.ttf'))).load();
  final icons = FontLoader('MaterialIcons')
    ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
  await icons.load();
}

/// Test uchun servislar: xotiradagi ombor, tasdiqlangan kontent yuklangan.
Future<AppServices> makeServices(
  WidgetTester tester, {
  MemoryKeyValueStore? store,
  OtpAuthAdapter? otpAdapter,
  AppLanguage language = AppLanguage.uz,
  AppRole? role = AppRole.lab,
  bool onboarded = true,
  // Mavjud testlar /welcome'dan boshlanadi; til tanlash ekrani alohida sinaladi.
  bool languageChosen = true,
  ThemeMode themeMode = ThemeMode.light,
  // Ilova mavzusi (D-64): berilmasa — ombordagi (yangi omborda Klassik).
  LgThemeId? appTheme,
  AssetBundle? bundle,
  http.Client? httpClient,
  LabBackend? backend,
  // Hamkor (reklama) UI: `null` — build bayrog'i (standart o'chiq, do'kon
  // build kabi); `true` — TestFlight/Play ichki test build kabi.
  bool? partnerAds,
  // Pro (D-71): `null` — build bayrog'i (standart o'chiq = bepul reliz).
  // `true` — Pro qatlami yoqilgan (pro-next sinov buildi).
  bool? proEnabled,
  bool? allFeaturesOpen,
  // Pro yoqilganda: soxta do'kon va server (test/helpers/billing_fakes.dart).
  PurchaseAdapter? purchases,
  EntitlementSource? entitlementSource,
  // Haqiqatan yopiladigan imkoniyatlar (berilmasa — `ProGatePolicy.gated`).
  Set<Feature>? gatedFeatures,
  DeviceAttestor? attestor,
  ReminderScheduler? reminderScheduler,
  ResultSharer? sharer,
  DateTime Function()? clock,
  CommunityBackend? community,
  // Google / Apple kirish tugmalari (soxta provayderlar; berilmasa — yo'q).
  SocialAuthService? socialAuth,
  // Ilova ichidagi QR skaner (berilmasa — soxta, Android kabi "qo'llanadi").
  QrScanner? qrScanner,
  // false — toifa banki oldindan yuklanmaydi (ilova sovuq ochilgandek:
  // bank faqat kerakli sahifa so'raganda yuklanadi).
  bool loadToifa = true,
}) async {
  final s = store ?? MemoryKeyValueStore();
  if (proEnabled != null) {
    BuildFlags.debugProEnabledOverride = proEnabled;
    addTearDown(() => BuildFlags.debugProEnabledOverride = null);
  }
  if (partnerAds != null) {
    BuildFlags.debugPartnerAdsOverride = partnerAds;
    addTearDown(() => BuildFlags.debugPartnerAdsOverride = null);
  }
  // Har test o'z (hali yaratilmagan) paketlar papkasi bilan.
  final packsRoot = Directory(
    '${Directory.systemTemp.path}/lg-packs-${DateTime.now().microsecondsSinceEpoch}',
  );
  addTearDown(() {
    if (packsRoot.existsSync()) packsRoot.deleteSync(recursive: true);
  });
  final services = createServices(
    store: s,
    bundle: bundle ?? rootBundle,
    systemLocales: [language.locale],
    // Server berilsa — kirish uning OTP'si orqali (haqiqiy oqim kabi).
    otpAdapter:
        otpAdapter ??
        (backend == null ? DemoOtpAdapter(releaseBuild: false) : null),
    httpClient: httpClient ?? localPacksServer(),
    packsRoot: () async => packsRoot,
    backend: backend,
    // Haqiqiy bildirishnoma/ulashish plaginlari testda yo'q.
    reminderScheduler: reminderScheduler ?? FakeReminderScheduler(),
    sharer: sharer ?? FakeResultSharer(),
    clock: clock,
    community: community,
    socialAuth: socialAuth ?? SocialAuthService.none(),
    qrScanner: qrScanner ?? FakeQrScanner(),
    entitlementKeys: MemoryEntitlementKeyStore(),
    allFeaturesOpen: allFeaturesOpen,
    purchases: purchases,
    entitlementSource: entitlementSource,
    gatedFeatures: gatedFeatures,
    attestor: attestor,
  );
  if (languageChosen) {
    await services.settings.chooseLanguage(language);
  } else {
    await services.settings.setLanguage(language);
  }
  await services.settings.setThemeMode(themeMode);
  if (appTheme != null) await services.settings.setAppTheme(appTheme);
  if (role != null) await services.settings.setRole(role);
  if (onboarded) {
    await services.auth.continueAsGuest();
    await services.settings.completeOnboarding();
  }
  await tester.runAsync(services.content.load);
  await tester.runAsync(services.instruments.ensureCatalog);
  await tester.runAsync(services.microscopy.ensureAtlas);
  if (loadToifa) await tester.runAsync(services.toifa.ensureLoaded);
  // O'quv dasturi asset'i (bundle'da bo'lmasa — “qo'shilmagan” holati).
  await tester.runAsync(services.curriculum.ensureLoaded);
  // Tayyor taqdimotlar (Ma'ruza rejimi) — keshga oldindan.
  await tester.runAsync(
    () => LectureDecks.all(services.curriculum.bundle ?? rootBundle),
  );
  // Barcha taqdimotlar katalogi (Ma'ruza ro'yxati va qidiruv).
  await tester.runAsync(
    () => DeckCatalog.load(services.curriculum.bundle ?? rootBundle),
  );
  return services;
}

/// Telefon kabi ekran: o'lcham (logik px), safe area, shrift masshtabi,
/// tizim mavzusi, reduced motion.
Future<void> pumpApp(
  WidgetTester tester,
  AppServices services, {
  Size size = const Size(390, 844),
  double textScale = 1,
  Brightness platformBrightness = Brightness.light,
  bool reduceMotion = false,
  bool notch = true,
  double ratio = 3.0,
}) async {
  tester.view.devicePixelRatio = ratio;
  tester.view.physicalSize = size * ratio;
  if (notch) {
    tester.view.padding = FakeViewPadding(top: 47 * ratio, bottom: 34 * ratio);
  }
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  tester.platformDispatcher.platformBrightnessTestValue = platformBrightness;
  if (reduceMotion) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
  }
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  await tester.pumpWidget(LabGuideApp(services: services));
  await tester.pumpAndSettle();
}

/// Joriy routerni olish (ko'rinib turgan sahifa orqali). To'liq ekranli
/// sahifalarda (LgPage'siz, masalan leykoformula zonalari) — Scaffold orqali.
GoRouter routerOf(WidgetTester tester) {
  final page = find.byType(LgPage);
  return GoRouter.of(
    tester.element(
      page.evaluate().isNotEmpty ? page.first : find.byType(Scaffold).last,
    ),
  );
}

/// Pastki menyuning [index]-tabini bosadi (0 Bosh, 1 Tahlillar, 2 Lab,
/// 3 Kutubxona, 4 O'rganish). Menyu pastga scroll qilinganda ixcham bo'lib
/// nomlarini yashiradi — shuning uchun matn orqali emas, kalit orqali.
Future<void> tapNavTab(WidgetTester tester, int index) async {
  await tester.tap(find.byKey(ValueKey('nav-tab-$index')));
  await tester.pumpAndSettle();
}

Future<void> goTo(WidgetTester tester, String location) async {
  routerOf(tester).go(location);
  await tester.pumpAndSettle();
}

/// Lokalizatsiya obyektini joriy til bo'yicha olish.
T l10n<T>(WidgetTester tester, T Function(BuildContext) read) =>
    read(tester.element(find.byType(LgPage).first));

/// Kontent paketini buzib beradigan asset bundle (xato holatini sinash).
class TamperingBundle extends CachingAssetBundle {
  TamperingBundle(this._inner);

  final AssetBundle _inner;

  @override
  Future<ByteData> load(String key) async {
    final data = await _inner.load(key);
    if (!key.endsWith('core/pack.json')) return data;
    final bytes = Uint8List.fromList(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
    bytes[42] ^= 0x01;
    return ByteData.sublistView(bytes);
  }
}

/// Paket JSON'ini o'zgartirib, manifestni (size + sha256) mos ravishda
/// qayta hisoblaydigan bundle — tekshiruvdan o'tadigan, lekin boshqacha
/// kontentli paket (masalan, “faqat tuzilma” kartasini ko'rsatish uchun).
class PatchedPackBundle extends CachingAssetBundle {
  PatchedPackBundle(this._inner, this._patch);

  final AssetBundle _inner;
  final void Function(Map<String, Object?> pack) _patch;
  Uint8List? _pack;

  Future<Uint8List> _patchedPack() async {
    if (_pack != null) return _pack!;
    final raw = await _inner.loadString('assets/content/core/pack.json');
    final json = jsonDecode(raw) as Map<String, Object?>;
    _patch(json);
    return _pack = Uint8List.fromList(utf8.encode(jsonEncode(json)));
  }

  @override
  Future<ByteData> load(String key) async {
    if (key.endsWith('core/pack.json')) {
      return ByteData.sublistView(await _patchedPack());
    }
    if (key.endsWith('core/manifest.json')) {
      final bytes = await _patchedPack();
      final manifest =
          jsonDecode(await _inner.loadString(key)) as Map<String, Object?>;
      manifest['files'] = [
        {
          'path': 'pack.json',
          'size': bytes.length,
          'sha256': sha256.convert(bytes).toString(),
        },
      ];
      return ByteData.sublistView(
        Uint8List.fromList(utf8.encode(jsonEncode(manifest))),
      );
    }
    return _inner.load(key);
  }
}

/// Tarmoq o'rniga repo ichidagi `packs/` papkasi (nashr qilinadigan aynan
/// shu fayllar). Boshqa manzillar — 404. Sinxron o'qiladi: widget testning
/// soxta vaqtida ham javob darhol keladi.
http.Client localPacksServer() => MockClient((req) async {
  const prefix = '/davlatsudekspert/LabGuide/main/';
  final path = req.url.path;
  if (!path.startsWith(prefix)) return http.Response('not found', 404);
  final file = File(path.substring(prefix.length));
  if (!file.existsSync()) return http.Response('not found', 404);
  return http.Response.bytes(file.readAsBytesSync(), 200);
});
