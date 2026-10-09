import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../core/backend/access_controller.dart';
import '../core/backend/lab_backend.dart';
import '../core/storage/kv_store.dart';
import '../features/auth/auth_controller.dart';
import '../features/content/content_controller.dart';
import '../features/differential/differential_controller.dart';
import '../features/instruments/instruments_controller.dart';
import '../features/learn/exam_controller.dart';
import '../features/learn/quiz_progress.dart';
import '../features/microscopy/microscopy_controller.dart';
import '../features/partners/partners_controller.dart';
import '../features/library/reading_controller.dart';
import '../features/packs/packs_controller.dart';
import '../features/qc/qc_controller.dart';
import '../features/settings/settings_controller.dart';

/// Build va siyosat sozlamalari. Biznes qarorlari (masalan, qurilmalar
/// soni) kodga qotirilmaydi — shu yerda, keyin remote config'dan keladi.
@immutable
class AppConfig {
  const AppConfig({
    required this.appVersion,
    required this.showDebugBadge,
    this.maxActiveDevicesProposal = 2,
    this.packsIndexUrl = defaultPacksIndexUrl,
  });

  /// Yuklab olinadigan paketlar katalogi (statik JSON, public repo).
  static const defaultPacksIndexUrl =
      'https://raw.githubusercontent.com/davlatsudekspert/LabGuide/main/packs/index.json';

  final String appVersion;

  /// Debug buildda demo adapterlar ishlayotganini ko'rsatish.
  final bool showDebugBadge;

  /// Taklif: 1 hisob / 2 faol qurilma. Hali qat'iy qaror emas.
  final int maxActiveDevicesProposal;

  final String packsIndexUrl;
}

/// Ilova bo'ylab umumiy servislar. Har biri o'z holatini ChangeNotifier
/// orqali e'lon qiladi; widgetlar kerakli controllerni tinglaydi.
class AppServices {
  AppServices({
    required this.config,
    required this.store,
    required this.settings,
    required this.auth,
    required this.content,
    required this.bookmarks,
    required this.qc,
    required this.quizProgress,
    required this.exams,
    required this.packs,
    required this.instruments,
    required this.microscopy,
    required this.reading,
    required this.backend,
    required this.access,
    required this.partners,
    required this.differential,
  });

  final AppConfig config;
  final KeyValueStore store;
  final SettingsController settings;
  final AuthController auth;
  final ContentController content;
  final BookmarksController bookmarks;
  final QcController qc;
  final QuizProgressController quizProgress;

  /// Imtihon rejimi: davom etayotgan imtihon va natijalar tarixi.
  final ExamController exams;
  final PacksController packs;

  /// Apparatlar katalogi, “Mening apparatlarim” va kalibrlash jurnali.
  final InstrumentsController instruments;

  /// Mikroskopiya atlasi va “Bu nima?” mashqi natijalari.
  final MicroscopyController microscopy;

  /// Kutubxona PDF lari: oxirgi sahifa, xatcho'plar, faylni tekshirib ochish.
  final ReadingController reading;

  /// Server (sozlanmagan buildda — [UnconfiguredBackend]).
  final LabBackend backend;
  final AccessController access;

  /// Hamkorlar (reklama) — faqat server ulangan buildda.
  final PartnersController partners;

  /// Leykoformula hisoblagichi va natijalar tarixi (faqat qurilmada).
  final DifferentialController differential;

  /// Server vakolatlari va o'qilmagan javoblarni yangilash. Rol hali
  /// tanlanmagan bo'lsa profil yozilmaydi (taxminiy rol sanalmasin).
  Future<void> refreshAccess() => access.refresh(
    role: settings.role?.name,
    language: settings.language.name,
  );

  /// Kirish/chiqish va rol/til o'zgarishini kuzatadi.
  void watchAccess() {
    var signedIn = auth.hasAccount;
    var role = settings.role;
    var language = settings.language;
    auth.addListener(() {
      if (auth.hasAccount == signedIn) return;
      signedIn = auth.hasAccount;
      if (signedIn) {
        unawaited(refreshAccess());
      } else {
        access.clear();
      }
    });
    settings.addListener(() {
      if (settings.role == role && settings.language == language) return;
      role = settings.role;
      language = settings.language;
      access.profileChanged();
      if (auth.hasAccount) unawaited(refreshAccess());
    });
  }

  /// "Lokal ma'lumotlarni o'chirish": omborni tozalaydi va xotiradagi
  /// holatni boshlang'ichga qaytaradi.
  Future<void> deleteLocalData(Iterable<Locale> systemLocales) async {
    await store.clear();
    await auth.signOut();
    access.clear();
    bookmarks.resetInMemory();
    qc.resetInMemory();
    quizProgress.resetInMemory();
    exams.resetInMemory();
    instruments.resetInMemory();
    microscopy.resetInMemory();
    partners.resetInMemory();
    reading.resetInMemory();
    differential.resetInMemory();
    await packs.removeAll();
    settings.resetToDefaults(systemLocales);
  }
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => services != oldWidget.services;
}

extension AppScopeX on BuildContext {
  AppServices get services => AppScope.of(this);
}
