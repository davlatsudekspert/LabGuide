import 'dart:async';
import 'dart:io';
import 'dart:math' show Random;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'app/app_scope.dart';
import 'core/backend/access_controller.dart';
import 'core/backend/cloudflare_backend.dart';
import 'core/backend/community_backend.dart';
import 'core/backend/lab_backend.dart';
import 'core/backend/supabase_backend.dart';
import 'core/build_flags.dart';
import 'core/entitlements/debug_fake_purchases.dart';
import 'core/entitlements/device_attestor.dart';
import 'core/entitlements/entitlement_cache.dart';
import 'core/entitlements/entitlement_service.dart';
import 'core/entitlements/entitlement_source.dart';
import 'core/entitlements/feature.dart';
import 'core/entitlements/pro_catalog.dart';
import 'core/entitlements/purchase_adapter.dart';
import 'core/entitlements/store_purchase_adapter.dart';
import 'core/storage/kv_store.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/otp_auth.dart';
import 'features/auth/social_auth.dart';
import 'features/classroom/classroom_local.dart';
import 'features/classroom/curriculum.dart';
import 'features/classroom/qr_scanner.dart';
import 'features/classroom/topic_test.dart';
import 'features/community/community_controller.dart';
import 'features/content/content_controller.dart';
import 'features/daily/daily_controller.dart';
import 'features/daily/daily_reminder.dart';
import 'features/differential/differential_controller.dart';
import 'features/howto/howto_videos.dart';
import 'features/learn/exam_controller.dart';
import 'features/learn/quiz_progress.dart';
import 'features/library/reading_controller.dart';
import 'features/instruments/instruments_controller.dart';
import 'features/microscopy/microscopy_controller.dart';
import 'features/packs/pack_downloader.dart';
import 'features/packs/packs_controller.dart';
import 'features/partners/partners_controller.dart';
import 'features/qc/qc_controller.dart';
import 'features/settings/settings_controller.dart';
import 'features/share/file_export.dart';
import 'features/share/result_share.dart';
import 'features/toifa/toifa_controller.dart';

const _appVersion = '0.1.0';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = createServices(
    store: await PrefsKeyValueStore.open(),
    bundle: rootBundle,
    systemLocales: PlatformDispatcher.instance.locales,
  );
  // Qurilmadagi sessiya (bo'lsa) — Keychain'dan bir zumda o'qiladi.
  await services.backend.restoreSession().timeout(
    const Duration(seconds: 3),
    onTimeout: () {},
  );
  await services.auth.reconcileWithBackend();
  unawaited(services.refreshAccess());
  // Pro (D-71): faqat LG_PRO_ENABLED=true buildda. Standart (bepul reliz) da
  // bu qator umuman bajarilmaydi — do'kon plagini ishga tushmaydi.
  if (BuildFlags.proEnabled) {
    unawaited(services.entitlements.start());
    // D-75: ilova qayta ochilganda huquqlar serverdan yangilanadi (boshqa
    // qurilmadagi xarid / bekor qilish), 5 daqiqada bir martadan ko'p emas.
    AppLifecycleListener(
      onResume: () => unawaited(services.entitlements.onResume()),
    );
  }
  // Kontent fonda yuklanadi; ekranlar loading/error holatini ko'rsatadi.
  unawaited(services.content.load());
  // O'quv dasturi (asset bo'lmasa — “qo'shilmagan”, ma'ruza qatori yo'q).
  unawaited(services.curriculum.ensureLoaded());
  // “Qanday foydalaniladi?” videolari ro‘yxati (bo‘sh bo‘lsa — tugma yo‘q).
  unawaited(services.howToVideos.ensureLoaded());
  // Hamkorlar keshdan darhol; serverdan fonda (sozlanmagan buildda — yo'q).
  unawaited(services.partners.refresh(force: true));
  // Kunlik eslatma yoqilgan bo'lsa — keyingi kunlar rejasi yangilanadi.
  unawaited(services.reminders.sync());
  unawaited(services.reminders.syncToifa());
  runApp(LabGuideApp(services: services));
}

/// Servislarni yig'ish — testlar ham shu funksiyadan foydalanadi.
AppServices createServices({
  required KeyValueStore store,
  required AssetBundle bundle,
  required Iterable<Locale> systemLocales,
  OtpAuthAdapter? otpAdapter,
  http.Client? httpClient,
  Future<Directory> Function()? packsRoot,
  LabBackend? backend,
  ReminderScheduler? reminderScheduler,
  ResultSharer? sharer,
  FileSharer? fileSharer,
  DateTime Function()? clock,
  Curriculum? curriculum,
  CommunityBackend? community,
  SocialAuthService? socialAuth,
  QrScanner? qrScanner,
  EntitlementKeyStore? entitlementKeys,
  bool? allFeaturesOpen,
  PurchaseAdapter? purchases,
  EntitlementSource? entitlementSource,
  Set<Feature>? gatedFeatures,
  DeviceAttestor? attestor,
  Random? dailyRandom,
}) {
  const config = AppConfig(appVersion: _appVersion, showDebugBadge: kDebugMode);
  final server = backend ?? _defaultBackend();
  final settings = SettingsController(
    store,
    systemLocales: systemLocales,
    clock: clock,
  );
  final daily = DailyController(store, clock: clock, random: dailyRandom);
  final toifa = ToifaController(store, bundle: bundle, clock: clock);
  return AppServices(
    config: config,
    store: store,
    settings: settings,
    // Server sozlangan bo'lsa — haqiqiy email OTP; aks holda debug'da demo,
    // release'da “ulanmagan”.
    auth: AuthController(
      store,
      otpAdapter ?? (server.isConfigured ? server : createOtpAdapter()),
      backend: server,
      // Google / Apple: faqat Cloudflare serveri va --dart-define sozlamasi
      // bilan; aks holda tugmalar umuman ko'rinmaydi (D-56).
      social:
          socialAuth ??
          SocialAuthService.fromEnvironment(
            backend: server,
            appleAndroidRedirect: server is CloudflareLabBackend
                ? server.config.resolve('/v1/auth/apple/callback')
                : null,
          ),
    ),
    content: ContentController(bundle: bundle),
    bookmarks: BookmarksController(store),
    qc: QcController(store),
    quizProgress: QuizProgressController(store),
    exams: ExamController(store),
    packs: PacksController(
      store: store,
      downloader: PackDownloader(httpClient ?? http.Client()),
      indexUri: Uri.parse(config.packsIndexUrl),
      root: packsRoot ?? _defaultPacksRoot,
    ),
    instruments: InstrumentsController(store, bundle: bundle),
    microscopy: MicroscopyController(store, bundle: bundle),
    reading: ReadingController(store, bundle: bundle),
    backend: server,
    access: AccessController(server),
    partners: PartnersController(store, server),
    // Pro (D-71): bayroq o'chiq bo'lsa — o'chirilgan servis (do'kon ham,
    // server ham yo'q, hamma imkoniyat ochiq). Yoqilgan bo'lsa — do'kon
    // (StoreKit 2 / Play Billing) + server tekshiruvi (`/v1/billing/*`).
    entitlements: BuildFlags.proEnabled
        ? _entitlements(
            server: server,
            store: store,
            entitlementSource: entitlementSource,
            purchases: purchases,
            entitlementKeys: entitlementKeys,
            gatedFeatures: gatedFeatures,
            allFeaturesOpen: allFeaturesOpen,
            attestor: attestor,
          )
        : EntitlementService.disabled(),
    toifa: toifa,
    differential: DifferentialController(store),
    daily: daily,
    reminders: ReminderController(
      store,
      reminderScheduler ?? LocalReminderScheduler(),
      daily: daily,
      settings: settings,
      toifa: toifa,
    ),
    sharer: sharer ?? const SystemResultSharer(),
    fileSharer: fileSharer ?? const SystemFileSharer(),
    curriculum: CurriculumController(bundle: bundle, curriculum: curriculum),
    classroom: ClassroomLocal(store),
    topicTests: TopicTestController(store, clock: clock),
    qrScanner: qrScanner ?? const MobileQrScanner(),
    // Video ro‘yxati — ilova bilan keladigan kichik JSON; tarmoqqa faqat
    // “Videoni ko‘rish” bosilganda murojaat qilinadi.
    howToVideos: HowToVideoService(
      bundle: bundle,
      client: httpClient ?? http.Client(),
    ),
    // Hamjamiyat faqat Cloudflare serveri (LG_API_URL) bilan; aks holda
    // UI umuman ko'rinmaydi.
    community: CommunityController(
      community ??
          (server is CommunityBackend ? server as CommunityBackend : null),
      clock: clock,
      store: store,
    ),
  )..watchAccess();
}

Future<Directory> _defaultPacksRoot() async =>
    Directory('${(await getApplicationSupportDirectory()).path}/packs');

/// Server tanlovi (build vaqtidagi `--dart-define`):
/// `LG_API_URL` (Cloudflare Worker) bo'lsa — u; aks holda Supabase
/// sozlamalari bo'lsa — Supabase; ikkalasi ham bo'sh — “server ulanmagan”.
LabBackend _defaultBackend() {
  const api = ApiConfig.fromEnvironment;
  if (api.isConfigured) return CloudflareLabBackend(api);
  const config = BackendConfig.fromEnvironment;
  return config.isConfigured
      ? SupabaseLabBackend(config)
      : const UnconfiguredBackend();
}

/// Pro yoqilgan build uchun huquqlar servisi (D-71/D-75). Do'kon (StoreKit 2 /
/// Play Billing) + server tekshiruvi (`/v1/billing/*`). Debug buildda
/// `LG_FAKE_PURCHASES=true` bo'lsa — soxta do'kon/server/attestatsiya
/// (release'da [BuildFlags.fakePurchases] doimiy `false`).
EntitlementService _entitlements({
  required LabBackend server,
  required KeyValueStore store,
  EntitlementSource? entitlementSource,
  PurchaseAdapter? purchases,
  EntitlementKeyStore? entitlementKeys,
  Set<Feature>? gatedFeatures,
  bool? allFeaturesOpen,
  DeviceAttestor? attestor,
}) {
  final EntitlementSource realSource =
      entitlementSource ??
      switch (server) {
        CloudflareLabBackend() => CloudflareEntitlementSource(server),
        SupabaseLabBackend() => SupabaseEntitlementSource(server),
        _ => const UnavailableEntitlementSource(),
      };
  final fake = BuildFlags.fakePurchases;
  return EntitlementService(
    source: fake ? DebugFakeEntitlementSource(realSource) : realSource,
    purchases:
        purchases ??
        (fake
            ? DebugFakePurchaseAdapter()
            : StorePurchaseAdapter.supported
            ? StorePurchaseAdapter()
            : UnavailablePurchaseAdapter()),
    attestor:
        attestor ??
        (fake ? DebugFakeDeviceAttestor() : const UnconfiguredDeviceAttestor()),
    cache: EntitlementCacheStore(
      store,
      entitlementKeys ?? const SecureEntitlementKeyStore(),
    ),
    gated: gatedFeatures ?? ProGatePolicy.gated,
    allFeaturesOpen:
        allFeaturesOpen ??
        ((kDebugMode && !fake) || EntitlementService.buildAllFeaturesOpen),
  );
}
