import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../core/backend/access_controller.dart';
import '../core/backend/admin_console.dart';
import '../core/backend/admin_team.dart';
import '../core/backend/lab_backend.dart';
import '../core/backend/pro_grants.dart';
import '../core/backend/teacher_tests.dart';
import '../core/build_flags.dart';
import '../core/entitlements/entitlement_service.dart';
import '../core/storage/kv_store.dart';
import '../features/auth/auth_controller.dart';
import '../features/classroom/classroom_local.dart';
import '../features/classroom/curriculum.dart';
import '../features/classroom/qr_scanner.dart';
import '../features/classroom/topic_test.dart';
import '../features/community/community_controller.dart';
import '../features/content/content_controller.dart';
import '../features/daily/daily_controller.dart';
import '../features/daily/daily_reminder.dart';
import '../features/differential/differential_controller.dart';
import '../features/home/resume_history.dart';
import '../features/howto/howto_videos.dart';
import '../features/instruments/instruments_controller.dart';
import '../features/learn/exam_controller.dart';
import '../features/learn/quiz_progress.dart';
import '../features/microscopy/microscopy_controller.dart';
import '../features/partners/partners_controller.dart';
import '../features/library/reading_controller.dart';
import '../features/packs/packs_controller.dart';
import '../features/qc/qc_controller.dart';
import '../features/settings/settings_controller.dart';
import '../features/share/file_export.dart';
import '../features/share/result_share.dart';
import '../features/teacher_pro/teacher_test_cache.dart';
import '../features/toifa/toifa_controller.dart';

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
    required this.entitlements,
    required this.toifa,
    required this.differential,
    required this.daily,
    required this.reminders,
    required this.sharer,
    required this.curriculum,
    required this.classroom,
    required this.community,
    required this.topicTests,
    required this.howToVideos,
    this.qrScanner = const MobileQrScanner(),
    this.fileSharer = const SystemFileSharer(),
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

  /// Pro huquqlari. `BuildFlags.proEnabled == false` bo'lsa — o'chirilgan
  /// (`EntitlementService.disabled()`): `can()` doim `true`, hech narsa
  /// ishga tushmaydi (D-71).
  final EntitlementService entitlements;

  /// Toifa imtihoniga tayyorgarlik (hamma til, davlat va rol uchun, D-79).
  final ToifaController toifa;

  /// Leykoformula hisoblagichi va natijalar tarixi (faqat qurilmada).
  final DifferentialController differential;

  /// Kunlik 5 ta savol va ketma-ketlik (faqat qurilmada).
  final DailyController daily;

  /// Kunlik lokal eslatma (standart o'chiq).
  final ReminderController reminders;

  /// Natija kartochkasini tizim oynasi orqali ulashish.
  final ResultSharer sharer;

  /// Eksport fayllari (PDF / CSV) — tizim ulashish oynasi (D-78, Pro).
  final FileSharer fileSharer;

  /// O'quv dasturi (`curriculum.json`; asset bo'lmasa — “qo'shilmagan”).
  final CurriculumController curriculum;

  /// Ustoz qurilmasidagi dars ma'lumotlari (serverga yuborilmaydi).
  final ClassroomLocal classroom;

  /// Hamjamiyat (savol-javob, mutaxassis tasdig'i) — faqat Cloudflare
  /// serveri ulangan buildda ([CommunityController.available]).
  final CommunityController community;

  /// Mavzu testlari (taqdimot oxirida): qoralama va natijalar (qurilmada).
  final TopicTestController topicTests;

  /// Ilova ichidagi QR skaner (D-68; testlarda — soxta skaner).
  final QrScanner qrScanner;

  /// “Qanday foydalaniladi?” videolari ro‘yxati (assets/howto/videos.json)
  /// va tugma bosilgandagi tarmoq tekshiruvi. Ro‘yxat bo‘sh — tugma yo‘q.
  final HowToVideoService howToVideos;

  /// Adminlar boshqaruvi (D-44) — server bu imkoniyatga ega bo'lsa
  /// (hozircha faqat Cloudflare). Aks holda bo'lim ko'rinmaydi.
  AdminTeamBackend? get adminTeam =>
      backend is AdminTeamBackend ? backend as AdminTeamBackend : null;

  /// Admin tomonidan Pro berish (D-73): faqat Pro bayrog'i yoqilgan buildda
  /// VA server bu imkoniyatga ega bo'lsa. Bayroq o'chiq — doim `null`
  /// (bo'lim umuman ko'rinmaydi, admin panel o'zgarmaydi).
  ProGrantBackend? get proGrants =>
      BuildFlags.proEnabled && backend is ProGrantBackend
      ? backend as ProGrantBackend
      : null;

  /// Ustoz Pro (D-78): o'z testlari, topshirish, taklifnoma, natijalar va
  /// talaba tomoni — faqat Pro bayrog'i yoqilgan buildda VA server bu
  /// imkoniyatga ega bo'lsa. Bayroq o'chiq — doim `null`: bo'limlar, kirish
  /// qatorlari va yo'llar umuman yo'q (bepul guruhlar o'zgarmaydi).
  TeacherTestBackend? get teacherTests =>
      BuildFlags.proEnabled && backend is TeacherTestHost
      ? (backend as TeacherTestHost).teacherTestApi
      : null;

  /// Ustoz testlari lokal keshi (oflayn ro'yxat, boshlangan urinish javoblari).
  late final TeacherTestCache teacherTestCache = TeacherTestCache(store);

  /// Egasi admin paneli (foydalanuvchilar, shikoyatlar) — faqat Cloudflare.
  AdminConsoleBackend? get adminConsole =>
      backend is AdminConsoleBackend ? backend as AdminConsoleBackend : null;

  /// Ilova ichidan shikoyat yuborish (Aloqa va shikoyat) — server bo'lsa.
  ComplaintsBackend? get complaints =>
      backend is ComplaintsBackend ? backend as ComplaintsBackend : null;

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
      community.reset();
      if (BuildFlags.proEnabled) unawaited(entitlements.refresh());
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
    entitlements.resetInMemory();
    reading.resetInMemory();
    toifa.resetInMemory();
    differential.resetInMemory();
    daily.resetInMemory();
    classroom.resetInMemory();
    topicTests.resetInMemory();
    community.resetInMemory();
    ResumeHistory.of(store).resetInMemory();
    await reminders.reset();
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
