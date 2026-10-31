import 'dart:async';
import 'dart:convert';

import 'package:material_ui/material_ui.dart';

import '../../core/storage/kv_store.dart';
import '../../design/themes.dart';

export '../../design/themes.dart' show LgThemeId;

/// Foydalanuvchi tanlagan yo'nalish. Bu faqat UI afzalligi: hech qanday
/// ruxsat bermaydi (haqiqiy vakolat serverda tekshiriladi).
enum AppRole { doctor, lab, student, teacher }

/// Qo'llab-quvvatlanadigan interfeys tillari.
enum AppLanguage {
  uz,
  ru,
  en;

  Locale get locale => Locale(name);

  String get shortLabel => name.toUpperCase();

  static AppLanguage? tryParse(String? code) {
    for (final l in values) {
      if (l.name == code) return l;
    }
    return null;
  }

  /// Tizim tili qo'llab-quvvatlansa — o'sha, aks holda o'zbekcha.
  static AppLanguage fromSystem(Iterable<Locale> systemLocales) {
    for (final locale in systemLocales) {
      final match = tryParse(locale.languageCode);
      if (match != null) return match;
    }
    return AppLanguage.uz;
  }
}

/// Malaka toifasi (KDL attestatsiyasi) bo'limi qaysi mintaqa uchun
/// ko'rsatilishi — ilova TILIDAN mustaqil foydalanuvchi sozlamasi
/// (egasi talabi, 2026-10-24: Uzbekistondagi rus tilli foydalanuvchi ham
/// barcha materialni ruscha ko'radi, toifa esa alohida boshqariladi).
///
/// * [auto] — standart: til va mintaqadan qat'i nazar ko'rinadi (D-79,
///   2026-10-26; ilgari faqat til uz yoki mintaqa UZ edi);
/// * [uz] — ham doim ko'rinadi ([auto] bilan bir xil; saqlangan tanlov uchun);
/// * [none] — hech qachon ko'rinmaydi.
enum AttestationRegion {
  auto,
  uz,
  none;

  static AttestationRegion? tryParse(String? code) {
    for (final r in values) {
      if (r.name == code) return r;
    }
    return null;
  }
}

/// Laboratoriya birliklari tizimi: SI (mmol/L, µmol/L, g/L) yoki
/// konvensional (mg/dL, g/dL). Faqat ko'rsatish va kalkulyatorlarning
/// boshlang'ich birligiga ta'sir qiladi; manbadagi raqamlar o'zgarmaydi.
enum UnitSystem {
  si,
  conventional;

  static UnitSystem? tryParse(String? code) {
    for (final u in values) {
      if (u.name == code) return u;
    }
    return null;
  }

  /// Qurilma mintaqasi AQSH (konvensional birliklar) bo'lsa — konvensional,
  /// aks holda SI.
  static UnitSystem fromSystem(Iterable<Locale> systemLocales) {
    final country = systemLocales.isEmpty
        ? null
        : systemLocales.first.countryCode;
    return country == 'US' ? UnitSystem.conventional : UnitSystem.si;
  }
}

class SettingsController extends ChangeNotifier {
  SettingsController(
    this._store, {
    required Iterable<Locale> systemLocales,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       _language =
           AppLanguage.tryParse(_store.getString(StoreKeys.language)) ??
           AppLanguage.fromSystem(systemLocales),
       _unitSystem =
           UnitSystem.tryParse(_store.getString(StoreKeys.unitSystem)) ??
           UnitSystem.fromSystem(systemLocales),
       _attestationRegion =
           AttestationRegion.tryParse(
             _store.getString(StoreKeys.attestationRegion),
           ) ??
           AttestationRegion.auto,
       _themeMode = _parseTheme(_store.getString(StoreKeys.themeMode)),
       _appTheme =
           LgThemeId.tryParse(_store.getString(StoreKeys.appTheme)) ??
           LgThemeId.classic,
       _role = _parseRole(_store.getString(StoreKeys.role)),
       _onboarded = _store.getBool(StoreKeys.onboarded) ?? false,
       // Migratsiya: onboarding tugatgan foydalanuvchi tilni tanlagan deb
       // hisoblanadi — eski o'rnatmalarda til tanlash ekrani chiqmaydi.
       _languageChosen =
           (_store.getBool(StoreKeys.languageChosen) ?? false) ||
           (_store.getBool(StoreKeys.onboarded) ?? false);

  final KeyValueStore _store;
  final DateTime Function() _clock;

  /// Kutilayotgan taklif shuncha vaqt saqlanadi.
  static const pendingInviteTtl = Duration(hours: 24);

  /// Faqat qo'shilish ekraniga yo'l saqlanadi/qaytariladi (ombordagi boshqa
  /// qiymat ixtiyoriy sahifaga yo'naltirmasin).
  static const _invitePath = '/learn/classes/join';

  AppLanguage _language;
  UnitSystem _unitSystem;
  AttestationRegion _attestationRegion;
  ThemeMode _themeMode;
  LgThemeId _appTheme;
  AppRole? _role;
  bool _onboarded;
  bool _languageChosen;

  AppLanguage get language => _language;
  UnitSystem get unitSystem => _unitSystem;

  /// Toifa (KDL attestatsiya) bo'limi sozlamasi; standart — [AttestationRegion.auto].
  AttestationRegion get attestationRegion => _attestationRegion;
  ThemeMode get themeMode => _themeMode;

  /// Tanlangan mavzu (Klassik / Ivory) — D-64. Kunduzgi/tungi rejim
  /// ([themeMode]) undan mustaqil.
  LgThemeId get appTheme => _appTheme;

  /// Onboardingda hali tanlanmagan bo'lsa `null`.
  AppRole? get role => _role;

  /// Bosh sahifa uchun: tanlanmagan bo'lsa laborant ko'rinishi.
  AppRole get effectiveRole => _role ?? AppRole.lab;

  /// Welcome → (mehmon yoki email) → rol oqimi yakunlanganmi.
  bool get onboarded => _onboarded;

  /// Birinchi ishga tushirishdagi til tanlash ekrani yakunlanganmi.
  bool get languageChosen => _languageChosen;

  /// Til tanlash ekranidan: tilni o'rnatadi va tanlov bajarilganini saqlaydi.
  Future<void> chooseLanguage(AppLanguage value) async {
    _languageChosen = true;
    final saved = setLanguage(value);
    // setLanguage til o'zgarmagan bo'lsa notify qilmaydi — router baribir
    // yangilanishi uchun alohida xabar beramiz.
    notifyListeners();
    await saved;
    await _store.setBool(StoreKeys.languageChosen, true);
  }

  Future<void> setLanguage(AppLanguage value) async {
    if (_language == value) return;
    _language = value;
    notifyListeners();
    await _store.setString(StoreKeys.language, value.name);
  }

  Future<void> setUnitSystem(UnitSystem value) async {
    if (_unitSystem == value) return;
    _unitSystem = value;
    notifyListeners();
    await _store.setString(StoreKeys.unitSystem, value.name);
  }

  Future<void> setAttestationRegion(AttestationRegion value) async {
    if (_attestationRegion == value) return;
    _attestationRegion = value;
    notifyListeners();
    await _store.setString(StoreKeys.attestationRegion, value.name);
  }

  Future<void> setThemeMode(ThemeMode value) async {
    if (_themeMode == value) return;
    _themeMode = value;
    notifyListeners();
    await _store.setString(StoreKeys.themeMode, value.name);
  }

  Future<void> setAppTheme(LgThemeId value) async {
    if (_appTheme == value) return;
    _appTheme = value;
    notifyListeners();
    await _store.setString(StoreKeys.appTheme, value.name);
  }

  Future<void> setRole(AppRole value) async {
    if (_role == value) return;
    _role = value;
    notifyListeners();
    await _store.setString(StoreKeys.role, value.name);
  }

  Future<void> completeOnboarding() async {
    if (_onboarded) return;
    _onboarded = true;
    _languageChosen = true;
    notifyListeners();
    await _store.setBool(StoreKeys.onboarded, true);
  }

  /// Chiqishda: welcome qayta ko'rsatiladi, til va mavzu saqlanadi.
  /// Kutilayotgan taklif ham o'chiriladi (boshqa hisob uchun ochilmasin).
  Future<void> resetOnboarding() async {
    _onboarded = false;
    notifyListeners();
    await _store.setBool(StoreKeys.onboarded, false);
    await clearPendingInvite();
  }

  /// Onboarding/kirishdan oldin ochilgan taklif havolasi (qo'shilish ekrani
  /// yo'li). Ombordan o'qiladi — OS ilovani yopib qo'ysa ham saqlanadi.
  /// 24 soatdan eski yoki buzilgan yozuv — `null` (va o'chiriladi).
  String? get pendingInvite {
    final raw = _store.getString(StoreKeys.pendingInvite);
    if (raw == null) return null;
    try {
      final j = (jsonDecode(raw) as Map).cast<String, Object?>();
      final loc = j['loc'];
      final at = j['at'];
      if (loc is String &&
          at is int &&
          loc.startsWith(_invitePath) &&
          _clock().difference(DateTime.fromMillisecondsSinceEpoch(at)) <
              pendingInviteTtl) {
        return loc;
      }
    } on Object catch (_) {
      // Buzilgan yozuv — pastda o'chiriladi.
    }
    unawaited(clearPendingInvite());
    return null;
  }

  Future<void> setPendingInvite(String location) async {
    if (!location.startsWith(_invitePath)) return;
    await _store.setString(
      StoreKeys.pendingInvite,
      jsonEncode({'loc': location, 'at': _clock().millisecondsSinceEpoch}),
    );
  }

  /// Taklifni bir marta oladi va o'chiradi.
  String? takePendingInvite() {
    final invite = pendingInvite;
    if (invite != null) unawaited(clearPendingInvite());
    return invite;
  }

  Future<void> clearPendingInvite() => _store.remove(StoreKeys.pendingInvite);

  /// Lokal ma'lumotlar o'chirilgandan keyin xotiradagi holatni tozalash.
  void resetToDefaults(Iterable<Locale> systemLocales) {
    _language = AppLanguage.fromSystem(systemLocales);
    _unitSystem = UnitSystem.fromSystem(systemLocales);
    _attestationRegion = AttestationRegion.auto;
    _themeMode = ThemeMode.system;
    _appTheme = LgThemeId.classic;
    _role = null;
    _onboarded = false;
    _languageChosen = false;
    notifyListeners();
  }

  static ThemeMode _parseTheme(String? raw) => switch (raw) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  static AppRole? _parseRole(String? raw) {
    for (final r in AppRole.values) {
      if (r.name == raw) return r;
    }
    return null;
  }
}
