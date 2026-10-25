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
  DateTime Function()? clock,
  Curriculum? curriculum,
  CommunityBackend? community,
  SocialAuthService? socialAuth,
  QrScanner? qrScanner,
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
