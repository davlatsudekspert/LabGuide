import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app.dart';
import 'app/app_scope.dart';
import 'core/backend/access_controller.dart';
import 'core/backend/lab_backend.dart';
import 'core/backend/supabase_backend.dart';
import 'core/storage/kv_store.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/otp_auth.dart';
import 'features/content/content_controller.dart';
import 'features/learn/exam_controller.dart';
import 'features/learn/quiz_progress.dart';
import 'features/instruments/instruments_controller.dart';
import 'features/packs/pack_downloader.dart';
import 'features/packs/packs_controller.dart';
import 'features/qc/qc_controller.dart';
import 'features/settings/settings_controller.dart';

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
}) {
  const config = AppConfig(appVersion: _appVersion, showDebugBadge: kDebugMode);
  final server = backend ?? _defaultBackend();
  return AppServices(
    config: config,
    store: store,
    settings: SettingsController(store, systemLocales: systemLocales),
    // Server sozlangan bo'lsa — haqiqiy email OTP; aks holda debug'da demo,
    // release'da “ulanmagan”.
    auth: AuthController(
      store,
      otpAdapter ?? (server.isConfigured ? server : createOtpAdapter()),
      backend: server,
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
    backend: server,
    access: AccessController(server),
  )..watchAccess();
}

Future<Directory> _defaultPacksRoot() async =>
    Directory('${(await getApplicationSupportDirectory()).path}/packs');

LabBackend _defaultBackend() {
  const config = BackendConfig.fromEnvironment;
  return config.isConfigured
      ? SupabaseLabBackend(config)
      : const UnconfiguredBackend();
}
