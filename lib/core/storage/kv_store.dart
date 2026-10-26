import 'package:shared_preferences/shared_preferences.dart';

/// Maxfiy bo'lmagan lokal holat uchun kichik kalit-qiymat ombori.
///
/// UI va domen qatlamlari `shared_preferences` ga to'g'ridan-to'g'ri
/// bog'lanmaydi: testlarda [MemoryKeyValueStore], ilovada
/// [PrefsKeyValueStore] beriladi. Token va boshqa sirlar bu yerga
/// yozilmaydi (keyingi bosqich: flutter_secure_storage).
abstract interface class KeyValueStore {
  String? getString(String key);
  List<String>? getStringList(String key);
  bool? getBool(String key);
  Future<void> setString(String key, String value);
  Future<void> setStringList(String key, List<String> value);
  Future<void> setBool(String key, bool value);
  Future<void> remove(String key);
  Future<void> clear();
}

/// Ilova ishlatadigan barcha kalitlar — bitta joyda.
abstract final class StoreKeys {
  static const language = 'settings.language';
  static const themeMode = 'settings.theme';

  /// Ilova mavzusi (`classic` / `ivory`) — D-64.
  static const appTheme = 'settings.appTheme';
  static const unitSystem = 'settings.unitSystem';

  /// Toifa (KDL attestatsiya) bo'limi: `auto` / `uz` / `none` — tildan mustaqil.
  static const attestationRegion = 'settings.attestationRegion';
  static const role = 'settings.role';
  static const onboarded = 'settings.onboarded';
  static const languageChosen = 'settings.languageChosen';
  static const session = 'auth.session';
  static const bookmarks = 'content.bookmarks';
  static const researchQuestion = 'research.question';
  static const researchNotes = 'research.notes';
  static const lessonQuestion = 'lesson.question';
  static const lessonNotes = 'lesson.notes';
  static const qcData = 'qc.data';
  static const quizProgress = 'quiz.progress';
  static const examActive = 'exam.active';
  static const examHistory = 'exam.history';
  static const examAssignments = 'exam.assignments';
  static const packsCatalog = 'packs.catalog';
  static const myInstruments = 'instruments.mine';
  static const calibrationLog = 'instruments.calibrations';

  /// Kalibrlash jurnalining faqat qo'shiladigan tarixi (yaratildi / tahrir /
  /// o'chirildi). «Lokal ma'lumotni o'chirish» uni ham tozalaydi.
  static const calibrationAudit = 'instruments.calibrationAudit';
  static const microscopyQuiz = 'microscopy.quiz';

  /// Hamkorlar ro'yxati keshi (internetsiz ham oxirgisi ko'rinadi).
  static const partnersCache = 'partners.cache';

  /// Kutubxona PDF lari: oxirgi sahifa va xatcho'plar.
  static const libraryReading = 'library.reading';

  /// Pro huquqlari: server javobining imzolangan, muddatli nusxasi.
  static const entitlementsCache = 'entitlements.cache';

  /// Mehmon (hisobsiz) do'kon xaridlari: server bergan imzolangan tokenlar
  /// (D-77 addendum). Hisobga kirilganda bog'lanadi va tozalanadi.
  static const guestEntitlements = 'entitlements.guest';

  /// Toifa imtihoniga tayyorgarlik: toifa, og'zaki baholar, bilet, test
  /// sozlamalari.
  static const toifaCategory = 'toifa.category';
  static const toifaOral = 'toifa.oral';
  static const toifaTicket = 'toifa.ticket';
  static const toifaTestSettings = 'toifa.testSettings';

  /// Toifa: kunlik mashg'ulot hisobi (mahalliy sana bo'yicha) va maqsad,
  /// og'zaki savollar Leitner qutilari, mashq rejimidagi test qoralamasi va
  /// "ertaga davom etish" eslatmasi — faqat shu qurilmada.
  static const toifaDaily = 'toifa.daily';
  static const toifaLeitner = 'toifa.leitner';
  static const toifaDrill = 'toifa.drill';
  static const toifaReminder = 'toifa.reminder';

  /// Leykoformula: joriy sanash (qoralama) va saqlangan natijalar.
  static const differentialDraft = 'differential.draft';
  static const differentialHistory = 'differential.history';

  /// Leykoformula: "ko'rmasdan sanash" rejimi sozlamalari.
  static const differentialEyesFree = 'differential.eyesFree';

  /// Leykoformula: oddiy hisoblagichda tovush/tebranish tugmalari.
  static const differentialFeedback = 'differential.feedback';

  /// Leykoformula: laboratoriya blankasidagi me'yorlar (baholash uchun).
  static const differentialLimits = 'differential.limits';

  /// Kunlik savol: bugungi to'plam, ketma-ketlik (kunlar, urug'), eslatma.
  static const dailyToday = 'daily.today';
  static const dailyStreak = 'daily.streak';
  static const dailyReminder = 'daily.reminder';

  /// Guruh darslari — FAQAT ustoz qurilmasida (serverga yuborilmaydi):
  /// boshlanish sanasi, talabalarning lokal belgilari (real ism bo'lishi
  /// mumkin), og'zaki savol-javob belgilari va baholari.
  static const classroomLocal = 'classroom.local';

  /// Hamjamiyat qoidalari kartasi: ochiq/yopiq (qurilma bo'yicha).
  static const communityRulesOpen = 'community.rulesOpen';

  /// Hamjamiyat: foydalanuvchi bloklagan mualliflar (`CommunityAuthor.ref`),
  /// faqat shu qurilmada (App Store 1.2: suiiste'molchini bloklash).
  static const communityBlocked = 'community.blocked';

  /// Mavzu testlari (taqdimot oxirida): boshlangan test, oxirgi urinish va
  /// natijalar tarixi — faqat shu qurilmada.
  static const topicTests = 'classroom.topicTests';

  /// Ma'ruza taqdimotida ekran holati tanlovi (`landscape` / `keep`; yo'q —
  /// har safar so'raladi) — faqat shu qurilmada.
  static const lectureOrientation = 'lecture.orientation';

  /// Ma'ruza: slaydlarni avtomatik varaqlash tanlovi (`auto`; yo'q — qo'lda)
  /// va tezligi soniyada (`15` / `30` / `60`; yo'q — 30) — faqat shu
  /// qurilmada.
  static const lectureAutoMode = 'lecture.autoMode';
  static const lectureAutoSeconds = 'lecture.autoSeconds';

  /// Bosh sahifadagi “Davom ettirish”: oxirgi ochilgan taqdimot, mavzu testi
  /// yoki bo'lim (`kind:id`) — faqat shu qurilmada (D-69 Q3).
  static const homeResume = 'home.resume';

  /// Kirish/onboarding'dan oldin ochilgan guruh taklifi (`/j?c=..`):
  /// `{"loc": "/learn/classes/join?..", "at": <ms>}`. Ilova fonda yopilsa
  /// ham (email ilovasiga o'tilganda) yo'qolmasin; 24 soatdan keyin eskiradi,
  /// ishlatilgach yoki chiqishda o'chiriladi.
  static const pendingInvite = 'onboarding.pendingInvite';

  /// Ustoz Pro (D-78): ustozning o'z testlari ro'yxati (oxirgi hisob,
  /// `{"uid": .., "tests": [..]}`) — internetsiz ko'rish uchun; talabaning
  /// boshlangan urinishidagi javoblar (`{attemptId: [..]}`, oxirgi 20 ta).
  /// Faqat shu qurilmada; «Lokal ma'lumotni o'chirish» tozalaydi.
  static const teacherTestsCache = 'teacherPro.tests';
  static const teacherTestAnswers = 'teacherPro.answers';

  static const all = <String>{
    language,
    themeMode,
    appTheme,
    unitSystem,
    attestationRegion,
    role,
    onboarded,
    languageChosen,
    session,
    bookmarks,
    researchQuestion,
    researchNotes,
    lessonQuestion,
    lessonNotes,
    qcData,
    quizProgress,
    examActive,
    examHistory,
    examAssignments,
    packsCatalog,
    myInstruments,
    calibrationLog,
    calibrationAudit,
    microscopyQuiz,
    partnersCache,
    libraryReading,
    entitlementsCache,
    guestEntitlements,
    toifaCategory,
    toifaOral,
    toifaTicket,
    toifaTestSettings,
    toifaDaily,
    toifaLeitner,
    toifaDrill,
    toifaReminder,
    differentialDraft,
    differentialHistory,
    differentialEyesFree,
    differentialFeedback,
    differentialLimits,
    dailyToday,
    dailyStreak,
    dailyReminder,
    classroomLocal,
    topicTests,
    lectureOrientation,
    lectureAutoMode,
    lectureAutoSeconds,
    homeResume,
    pendingInvite,
    teacherTestsCache,
    teacherTestAnswers,
    communityRulesOpen,
    communityBlocked,
  };
}

class PrefsKeyValueStore implements KeyValueStore {
  PrefsKeyValueStore._(this._prefs);

  final SharedPreferencesWithCache _prefs;

  static Future<PrefsKeyValueStore> open() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        allowList: StoreKeys.all,
      ),
    );
    return PrefsKeyValueStore._(prefs);
  }

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  List<String>? getStringList(String key) => _prefs.getStringList(key);

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  Future<void> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  @override
  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);

  @override
  Future<void> clear() => _prefs.clear();
}

/// Testlar uchun xotiradagi ombor. [PrefsKeyValueStore] kabi faqat
/// [StoreKeys.all] dagi kalitlarni qabul qiladi — ro'yxatga qo'shilmagan
/// kalit testda darhol xato beradi (ilovada esa saqlanmay qolardi).
class MemoryKeyValueStore implements KeyValueStore {
  MemoryKeyValueStore([Map<String, Object>? initial]) : _data = {...?initial};

  final Map<String, Object> _data;

  void _check(String key) {
    if (!StoreKeys.all.contains(key)) {
      throw ArgumentError.value(key, 'key', 'not in StoreKeys.all');
    }
  }

  Map<String, Object> get snapshot => Map.unmodifiable(_data);

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  List<String>? getStringList(String key) =>
      (_data[key] as List<String>?)?.toList();

  @override
  bool? getBool(String key) => _data[key] as bool?;

  @override
  Future<void> setString(String key, String value) async {
    _check(key);
    _data[key] = value;
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    _check(key);
    _data[key] = List<String>.of(value);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _check(key);
    _data[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _check(key);
    _data.remove(key);
  }

  @override
  Future<void> clear() async => _data.clear();
}
