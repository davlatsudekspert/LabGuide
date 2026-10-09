// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appTagline => 'BIOKIMYO · LABORATORIYA';

  @override
  String get navHome => 'Bosh sahifa';

  @override
  String get navTests => 'Tahlillar';

  @override
  String get navLab => 'Lab';

  @override
  String get navLibrary => 'Kutubxona';

  @override
  String get navLearn => 'O‘rganish';

  @override
  String get actionBack => 'Orqaga';

  @override
  String get actionProfile => 'Profil va sozlamalar';

  @override
  String get actionLanguage => 'Til';

  @override
  String get actionOpen => 'Ochish';

  @override
  String get actionRetry => 'Qayta urinish';

  @override
  String get actionContinue => 'Davom etish';

  @override
  String get actionCancel => 'Bekor qilish';

  @override
  String get actionDelete => 'O‘chirish';

  @override
  String get actionCopyLink => 'Havolani nusxalash';

  @override
  String get linkCopied => 'Havola nusxalandi';

  @override
  String plannedStage(String stage) {
    return '$stage-bosqichda rejalashtirilgan';
  }

  @override
  String get notAvailableYet => 'Hali mavjud emas';

  @override
  String get debugBuildBadge => 'DEBUG · DEMO ADAPTERLAR';

  @override
  String get welcomeEyebrow => 'Sizning laboratoriya yordamchingiz';

  @override
  String get welcomeTitle => 'Biokimyo.\nTushunarli va amaliy.';

  @override
  String get welcomeSubtitle =>
      'Tahlillar, laboratoriya amaliyoti va o‘rganish — bir joyda.';

  @override
  String get welcomeDevices => 'Telefon va planshet';

  @override
  String get welcomeRoles =>
      'Shifokor · laboratoriya mutaxassisi · talaba · ustoz';

  @override
  String get welcomeGetStarted => 'Boshlash / ro‘yxatdan o‘tish';

  @override
  String get welcomeGuest => 'Mehmon sifatida ko‘rish';

  @override
  String get welcomeSignIn => 'Kirish';

  @override
  String get welcomeGuestNote =>
      'Kontentni o‘qish uchun hisob shart emas. Kirish sinxronlash, guruhlar va xaridlar uchun kerak.';

  @override
  String get authTitle => 'Xush kelibsiz';

  @override
  String get authSubtitle => 'Email orqali kirish yoki yangi hisob ochish.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'name@example.com';

  @override
  String get authEmailInvalid => 'To‘g‘ri email manzil kiriting.';

  @override
  String get authConsent =>
      'Foydalanish shartlari va maxfiylik siyosatini qabul qilaman.';

  @override
  String get authConsentRequired =>
      'Davom etish uchun shartlarni qabul qiling.';

  @override
  String get authGetCode => 'Kod olish';

  @override
  String get authViewTerms => 'Shartlarni ko‘rish';

  @override
  String get authDemoNotice =>
      'Debug build: demo kirish. Email yuborilmaydi; kod keyingi ekranda ko‘rsatiladi.';

  @override
  String get authUnavailableTitle => 'Email orqali kirish hali ulanmagan';

  @override
  String get authUnavailableBody =>
      'Barcha o‘qish kontenti mehmon uchun ochiq. Email xizmati sozlangach kirish yoqiladi.';

  @override
  String get authContinueGuest => 'Mehmon sifatida davom etish';

  @override
  String authRateLimited(int seconds) {
    return 'So‘rovlar juda ko‘p. $seconds soniyadan keyin urinib ko‘ring.';
  }

  @override
  String get authGenericError =>
      'Nimadir xato ketdi. Ulanishni tekshirib, qayta urinib ko‘ring.';

  @override
  String get otpTitle => 'Emailni tasdiqlash';

  @override
  String get otpCodeLabel => '6 xonali kod';

  @override
  String get otpVerify => 'Tasdiqlash';

  @override
  String otpDemoCode(String code) {
    return 'Demo kod: $code. Email yuborilmadi (faqat debug build).';
  }

  @override
  String otpInvalid(int attempts) {
    return 'Kod noto‘g‘ri. Qolgan urinishlar: $attempts.';
  }

  @override
  String get otpExpired => 'Kod muddati tugadi. Yangi kod oling.';

  @override
  String get otpTooManyAttempts => 'Urinishlar juda ko‘p. Yangi kod oling.';

  @override
  String get otpNoActiveCode => 'Faol kod yo‘q. Yangi kod oling.';

  @override
  String get otpFormat => '6 xonali kodni kiriting.';

  @override
  String get otpResend => 'Kodni qayta olish';

  @override
  String otpResendIn(int seconds) {
    return '$seconds soniyadan keyin qayta olish';
  }

  @override
  String otpValidFor(int minutes) {
    return 'Kod $minutes daqiqa amal qiladi.';
  }

  @override
  String get otpResent => 'Yangi kod berildi.';

  @override
  String get rolesTitle => 'Sizga mos ish maydoni';

  @override
  String get rolesSubtitle =>
      'Asosiy yo‘nalishni tanlang. Keyin o‘zgartirish mumkin.';

  @override
  String get rolesNote =>
      'Rol faqat bosh sahifani moslaydi. U boshqa guruhlar yoki ma’lumotlarga ruxsat bermaydi.';

  @override
  String get roleDoctor => 'Shifokor';

  @override
  String get roleDoctorDesc => 'Natija va klinik bog‘lanishlar';

  @override
  String get roleLab => 'Laboratoriya mutaxassisi';

  @override
  String get roleLabDesc => 'Metodika, apparat va sifat nazorati';

  @override
  String get roleStudent => 'Student';

  @override
  String get roleStudentDesc => 'Tushunish, mashq va imtihon';

  @override
  String get roleTeacher => 'Ustoz / tadqiqotchi';

  @override
  String get roleTeacherDesc => 'Guruh, topshiriq va ilmiy ish';

  @override
  String get homeTitle => 'Bilim. Aniqlik. Amaliyot.';

  @override
  String get homeFocusTag => 'Sizning yo‘nalishingiz';

  @override
  String get homeHeroDoctorTitle => 'Natijani kontekst bilan tushuning';

  @override
  String get homeHeroDoctorBody =>
      'Tahlil, ta’sir qiluvchi omillar va bog‘liq tekshiruvlar.';

  @override
  String get homeHeroDoctorCta => 'Tahlillarni ochish';

  @override
  String get homeHeroLabTitle => 'Ishonchli laboratoriya amaliyoti';

  @override
  String get homeHeroLabBody =>
      'Namuna, metodika va sifat nazorati — bir joyda.';

  @override
  String get homeHeroLabCta => 'Sifat nazoratini ochish';

  @override
  String get homeHeroStudentTitle => 'Biokimyoni tushunib o‘rganing';

  @override
  String get homeHeroStudentBody => 'Mavzu → izoh → mashq → takrorlash.';

  @override
  String get homeHeroStudentCta => 'O‘rganishni boshlash';

  @override
  String get homeHeroTeacherTitle => 'Bilimni darsga aylantiring';

  @override
  String get homeHeroTeacherBody =>
      'Guruhlar, izohli savollar va muddatli topshiriqlar.';

  @override
  String get homeHeroTeacherCta => 'Guruhlarni ochish';

  @override
  String get homeQuickAccess => 'Tez toping';

  @override
  String get homeUsefulTests => 'Foydali tahlillar';

  @override
  String get featureTests => 'Tahlillar';

  @override
  String get featureCalculators => 'Kalkulyatorlar';

  @override
  String get featureSampleFactors => 'Namuna omillari';

  @override
  String get featureSaved => 'Saqlanganlar';

  @override
  String get featureCalibration => 'Kalibrlash';

  @override
  String get featureQc => 'QC';

  @override
  String get featureSampling => 'Namuna olish';

  @override
  String get featureTopics => 'Mavzular';

  @override
  String get featureQuiz => 'Test';

  @override
  String get featureMicroscopy => 'Mikroskopiya';

  @override
  String get featureExam => 'Imtihon';

  @override
  String get featureClasses => 'Guruhlar';

  @override
  String get featureQuestionBank => 'Savollar';

  @override
  String get featureSources => 'Manbalar';

  @override
  String get featureResearch => 'Ilmiy ish';

  @override
  String get testsTitle => 'Tahlillar atlasi';

  @override
  String get testsSubtitle => 'Ko‘rsatkichdan amaliy ma’lumotgacha.';

  @override
  String get testsSearchLabel => 'Tahlil qidirish';

  @override
  String get testsSearchHint => 'ALT, kreatinin, HbA1c…';

  @override
  String get testsFilterAll => 'Barchasi';

  @override
  String get testsEmptyTitle => 'Natija topilmadi';

  @override
  String get testsEmptyBody => 'Boshqa nom, qisqartma yoki sinonimni kiriting.';

  @override
  String get testsClearSearch => 'Qidiruvni tozalash';

  @override
  String testsResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta tahlil',
    );
    return '$_temp0';
  }

  @override
  String get statusDraft => 'Qoralama';

  @override
  String get statusVerified => 'Tekshirilgan';

  @override
  String get statusPublished => 'Nashr etilgan';

  @override
  String get statusSourcedSample => 'Manbali namuna';

  @override
  String get statusStructureOnly => 'Faqat tuzilma';

  @override
  String get contentLoading => 'Kontent yuklanmoqda…';

  @override
  String get contentErrorTitle => 'Kontentni yuklab bo‘lmadi';

  @override
  String get contentErrorBody =>
      'Kontent paketi tekshiruvdan o‘tmadi. Tekshirilmagan ma’lumot hech qachon ko‘rsatilmaydi.';

  @override
  String get analyteSave => 'Saqlash';

  @override
  String get analyteSaved => 'Saqlangan';

  @override
  String get analyteSavedToast => 'Saqlanganlarga qo‘shildi';

  @override
  String get analyteRemovedToast => 'Saqlanganlardan olib tashlandi';

  @override
  String get analyteNotFound => 'Bu tahlil kartasi topilmadi.';

  @override
  String get analyteStructureOnlyTitle => 'Kontent tayyorlanmoqda';

  @override
  String get analyteStructureOnlyBody =>
      'Bu kartada faqat tuzilma bor. Klinik matn manbalar bilan va mustaqil mutaxassis tekshiruvidan keyin qo‘shiladi — umumiy matn tayyor deb ko‘rsatilmaydi.';

  @override
  String get analyteSampleNotice =>
      'Ko‘rsatilgan manbalarga tayangan o‘quv namuna. Mustaqil mutaxassis tekshiruvi kutilmoqda — klinik qaror uchun emas.';

  @override
  String get analyteNotWritten =>
      'Hali yozilmagan: manba va tekshiruv talab qilinadi.';

  @override
  String get analyteAtAGlance => 'Bir qarashda';

  @override
  String get analyteSpecimen => 'Namuna';

  @override
  String get analytePopulation => 'Populyatsiya';

  @override
  String get analyteMethod => 'Metod';

  @override
  String get analyteMethodNotSet => 'Ko‘rsatilmagan — reagent IFUga bog‘liq';

  @override
  String get analyteUnits => 'Birliklar';

  @override
  String get analyteRefIntervals => 'Referens intervallar';

  @override
  String get analyteRefIntervalNone =>
      'Bu yerda referens interval berilmagan. Laboratoriyangiz blankidagi intervaldan foydalaning: u metod, namuna va populyatsiyaga bog‘liq.';

  @override
  String get analyteDecisionLimits => 'Diagnostik chegaralar';

  @override
  String get analyteDecisionNotRef =>
      'Diagnostik chegaralar laboratoriya referens intervali emas.';

  @override
  String analyteSiNote(String unit, String mass) {
    return '$unit qiymatlari manbada berilmagan — manbadagi mg/dL chegarasidan molyar massa ($mass g/mol) bo‘yicha hisoblangan va yaxlitlangan. Asosiy chegara — manbadagi mg/dL.';
  }

  @override
  String analyteSiApprox(String value) {
    return '$value (hisoblangan)';
  }

  @override
  String get analyteNoInterpretation =>
      'LabGuide alohida natijani talqin qilmaydi, tashxis yoki doza taklif qilmaydi.';

  @override
  String get analyteSources => 'Manbalar';

  @override
  String analyteSourceAccessed(String date) {
    return 'Murojaat sanasi: $date';
  }

  @override
  String get analyteReuseRightsVerify =>
      'Foydalanish huquqi: tarqatishdan oldin tekshirilishi kerak';

  @override
  String get analyteReview => 'Tekshiruv holati';

  @override
  String get analyteReviewPending => 'Mutaxassis tekshiruvi kutilmoqda';

  @override
  String get analyteReviewApproved => 'Tekshirilgan';

  @override
  String get analyteReviewerNotAssigned => 'Tekshiruvchi tayinlanmagan';

  @override
  String get analyteTranslationPending => 'Tarjima tekshiruvi kutilmoqda';

  @override
  String analyteContentVersion(String version) {
    return 'Kontent versiyasi $version';
  }

  @override
  String get analyteConvertUnits => 'Birliklarni o‘tkazish';

  @override
  String get analyteConvertUnitsSub => 'Moddaga xos koeffitsiyent';

  @override
  String get analyteMethodCalibration => 'Metodika va kalibrlash';

  @override
  String get analyteMethodCalibrationSub => 'IFU · QC';

  @override
  String get analyteCalculatorSub => 'Kalkulyator · nashr etilgan formula';

  @override
  String get analytePractice => 'Mavzuni mustahkamlash';

  @override
  String get analytePracticeSub => 'Izohli savollar';

  @override
  String get analyteRelated => 'Bog‘liq tahlillar';

  @override
  String get sectionPurpose => 'Nima uchun?';

  @override
  String get sectionPhysiology => 'Fiziologiya';

  @override
  String get sectionHighResult => 'Yuqori natija';

  @override
  String get sectionLowResult => 'Past natija';

  @override
  String get sectionPositiveResult => 'Musbat natija';

  @override
  String get sectionNegativeResult => 'Manfiy natija';

  @override
  String get sectionPreanalytics => 'Namuna va preanalitika';

  @override
  String get sectionInterference => 'Interferensiya';

  @override
  String get sectionLimitations => 'Cheklovlar';

  @override
  String get labTitle => 'Laboratoriya';

  @override
  String get labSubtitle => 'Har bosqichda aniq yo‘l.';

  @override
  String get labHeroEyebrow => 'Amaliy ish';

  @override
  String get labHeroTitle => 'Apparat → reagent → metod';

  @override
  String get labHeroBody => 'Aniq modelga mos yo‘riqnoma va nazorat.';

  @override
  String get labHeroCta => 'Kalibrlashni ochish';

  @override
  String get labQcSub => 'Nazorat kartalari va qoidalar';

  @override
  String get labPreanalytics => 'Preanalitika';

  @override
  String get labPreanalyticsSub => 'Tayyorlash, olish, saqlash, tashish';

  @override
  String get labCalculatorsSub => 'Suyultirish va birliklar';

  @override
  String get labInstruments => 'Apparatlar va metodikalar';

  @override
  String get labInstrumentsSub =>
      'Biokimyo · gematologiya · immunokimyo · siydik';

  @override
  String get labMicroscopySub => 'Tasvir va tuzilmalarni solishtirish';

  @override
  String get calTitle => 'Kalibrlash yo‘li';

  @override
  String get calSubtitle => 'To‘g‘ri yo‘riqnoma uchun aniq moslik kerak.';

  @override
  String get calManufacturer => 'Ishlab chiqaruvchi';

  @override
  String get calManufacturerOther => 'Boshqa';

  @override
  String get calModel => 'Apparat modeli';

  @override
  String get calModelHint => 'Aniq model nomi';

  @override
  String get calReagentRef => 'Reagent REF';

  @override
  String get calIfuRevision => 'IFU versiyasi';

  @override
  String get calCalibratorLot => 'Kalibrator loti';

  @override
  String get calCheck => 'Moslikni tekshirish';

  @override
  String get calFieldsRequired =>
      'Model, reagent REF va IFU versiyasini kiriting.';

  @override
  String get calNoMatchTitle =>
      'Bu kombinatsiya uchun tasdiqlangan yo‘riqnoma yo‘q';

  @override
  String get calNoMatchBody =>
      'Kalibrlash parametrlari faqat ishlab chiqaruvchi, model, reagent REF, IFU versiyasi va kalibrator lotiga mos tasdiqlangan IFUdan ko‘rsatiladi. Ishlab chiqaruvchining amaldagi IFUsidan foydalaning.';

  @override
  String calCatalogCount(int count) {
    return 'Ilovaning bu versiyasida tasdiqlangan IFU yozuvlari: $count';
  }

  @override
  String get calBrandWarning =>
      'Brend nomi (masalan, Mindray yoki HUMAN) barcha modellar bir xil degani emas. Reagent IFU va apparat qo‘llanmasi alohida hujjatlar.';

  @override
  String get calWorkflow => 'Ish ketma-ketligi';

  @override
  String get calStep1 => 'Model, reagent va yo‘riqnoma versiyasi';

  @override
  String get calStep2 => 'Kalibrator loti va tayinlangan qiymatlar';

  @override
  String get calStep3 => 'Metodga mos tayyorlash';

  @override
  String get calStep4 => 'Yo‘riqnoma bo‘yicha kalibrlash';

  @override
  String get calStep5 => 'Kalibrlashdan keyingi QC';

  @override
  String get calStep6 => 'Qaydlar va muammolarni tekshirish';

  @override
  String get calNoServiceCodes =>
      'Servis kodlari va xavfsizlikni chetlab o‘tuvchi usullar kiritilmaydi.';

  @override
  String get qcTitle => 'Sifat nazorati';

  @override
  String get qcChartTitle => 'Levey–Jennings';

  @override
  String get qcChartBody =>
      'Grafik uchun test, nazorat loti, daraja, o‘rtacha qiymat va SD kerak. Uydirma natijalar chizilmaydi.';

  @override
  String get qcEmptyTitle => 'Hali nazorat qaydlari yo‘q';

  @override
  String get qcEmptyBody =>
      'Levey–Jennings grafigini boshlash uchun nazorat darajalari bilan test qo‘shing. Ma’lumotlar faqat shu qurilmada saqlanadi.';

  @override
  String get qcIntro =>
      'Har bir nazorat darajasining maqsadli o‘rtachasi va SD sini kiriting, so‘ng har bir seriyani qayd eting. Ilova Westgard qoidalarini tekshiradi; maqsadli qiymat yoki natija to‘qimaydi.';

  @override
  String get qcLoadError =>
      'Saqlangan QC ma’lumotlarini o‘qib bo‘lmadi. Hech narsa ustidan yozilmadi.';

  @override
  String get qcAddSet => 'Test qo‘shish';

  @override
  String get qcSetName => 'Test nomi';

  @override
  String get qcUnit => 'Birlik';

  @override
  String get qcTargetSource => 'Maqsadli o‘rtacha va SD manbai';

  @override
  String get qcSourceLab => 'Laboratoriyamiz ma’lumotlari';

  @override
  String get qcSourceManufacturer => 'Ishlab chiqaruvchi varaqasi';

  @override
  String qcLevel(String label) {
    return '$label-daraja';
  }

  @override
  String qcLevelNamed(String label) {
    return '$label daraja';
  }

  @override
  String qcLevelsCount(int count) {
    return '$count ta daraja';
  }

  @override
  String qcRunsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta seriya',
      zero: 'seriya yo‘q',
    );
    return '$_temp0';
  }

  @override
  String get qcLot => 'Lot';

  @override
  String get qcMean => 'Maqsadli o‘rtacha';

  @override
  String get qcSd => 'Maqsadli SD';

  @override
  String get qcAddLevel => 'Daraja qo‘shish';

  @override
  String get qcRemoveLevel => 'Darajani olib tashlash';

  @override
  String get qcSave => 'Saqlash';

  @override
  String get qcTargetNote =>
      'Westgard va boshq. (1981) o‘rtacha va SD ni laboratoriyaning o‘z nazorat o‘lchovlaridan hisoblaydi — dastlab taxminan 20 ta (kuniga bitta seriya), so‘ng ma’lumot ko‘paygani sari qayta hisoblanadi. Ilova bu qiymatlarni bermaydi.';

  @override
  String get qcManufacturerWarning =>
      'Ishlab chiqaruvchi qiymatlari faqat yo‘l-yo‘riq; Westgard darslari laboratoriyaning o‘z nazorat ma’lumotlaridan hisoblangan chegaralarni tavsiya qiladi — varaqadagi oraliqlar ko‘pincha juda keng.';

  @override
  String get qcErrName => 'Test nomini kiriting.';

  @override
  String qcErrLevel(String label) {
    return '$label: o‘rtacha va noldan katta SD kiriting.';
  }

  @override
  String get qcAccept => 'Qabul qilindi';

  @override
  String get qcWarning => 'Ogohlantirish';

  @override
  String get qcReject => 'Rad etildi';

  @override
  String get qcAcceptBody => 'Hech bir qoida buzilmagan.';

  @override
  String get qcLatestRun => 'Oxirgi seriya';

  @override
  String get qcNoRunsYet => 'Hali seriya yo‘q — birinchisini pastda qo‘shing.';

  @override
  String get qcAddRun => 'Seriya qo‘shish';

  @override
  String get qcNote => 'Izoh (ixtiyoriy)';

  @override
  String get qcSaveRun => 'Seriyani saqlash';

  @override
  String get qcErrRunEmpty => 'Kamida bitta nazorat qiymatini kiriting.';

  @override
  String qcErrRunInvalid(String label) {
    return '$label: son emas.';
  }

  @override
  String get qcRunHistory => 'Seriyalar';

  @override
  String get qcStats => 'Kuzatilgan';

  @override
  String get qcChartLegend => '● nazoratda   ▲ ogohlantirish   ■ rad etilgan';

  @override
  String qcChartSemantics(String label, int count) {
    return 'Levey–Jennings grafigi, $label: $count ta qiymat';
  }

  @override
  String get qcDeleteRun => 'Seriyani o‘chirish';

  @override
  String get qcDeleteSet => 'Testni va barcha seriyalarni o‘chirish';

  @override
  String get qcConfirmDelete => 'Buni qaytarib bo‘lmaydi.';

  @override
  String get qcSetMissing => 'Bu test endi mavjud emas.';

  @override
  String get qcCopyCsv => 'Seriyalarni jadval (CSV) sifatida nusxalash';

  @override
  String qcCopied(int count) {
    return '$count qator nusxalandi — Excel yoki Google Sheets’ga qo‘ying';
  }

  @override
  String get qcChangeTarget => 'Maqsad yoki lotni almashtirish';

  @override
  String get qcChangeTargetBody =>
      'Yangi nazorat loti boshlanganda yoki laboratoriya o‘rtacha va SD ni qayta hisoblaganda ishlating. Yangi qiymatlar tanlangan vaqtdan (odatda hozirdan) amal qiladi; oldingi seriyalar o‘sha paytdagi maqsad bilan baholanishda davom etadi.';

  @override
  String get qcErrTarget => 'O‘rtacha va noldan katta SD kiriting.';

  @override
  String qcSince(String date) {
    return '$date dan beri';
  }

  @override
  String qcPreviousTarget(String target, String date) {
    return 'Oldingi: $target ($date dan)';
  }

  @override
  String get qcRulesSource =>
      'Qoidalar: Westgard ko‘p qoidali tartibi (Westgard JO va boshq., Clin Chem 1981; doi:10.1093/clinchem/27.3.493). O‘rganish va tekshirish vositasi — laboratoriyangizning QC tartibini almashtirmaydi.';

  @override
  String get qcErrSave => 'Saqlab bo‘lmadi. Qayta urinib ko‘ring.';

  @override
  String qcErrNotFinite(String label) {
    return '$label: qiymat juda katta yoki juda kichik.';
  }

  @override
  String get qcLevelName => 'Daraja nomi (ixtiyoriy, masalan “Past”)';

  @override
  String get qcStatsExcluded => 'Rad etilgan seriyalar hisobga olinmagan.';

  @override
  String qcStatsFew(int count) {
    return 'n = $count: qiymatlar hali kam — Westgard va boshq. (1981) maqsadni dastlab taxminan 20 ta qiymatdan hisoblaydi.';
  }

  @override
  String qcUseObserved(int count) {
    return 'Kuzatilgan x̄ va SD ni qo‘yish (n = $count)';
  }

  @override
  String get qcEffectiveFrom => 'Amal qilish boshlanishi';

  @override
  String get qcFromNow => 'Hozirdan';

  @override
  String qcFromDate(String date) {
    return '$date dan';
  }

  @override
  String get qcPickDate => 'Sanani tanlash';

  @override
  String qcRunTime(String time) {
    return 'Seriya vaqti: $time';
  }

  @override
  String get qcRunTimeNow => 'hozir';

  @override
  String get qcRunTimeHint =>
      'Kechikib kiritilgan seriya uchun haqiqiy o‘lchash vaqtini tanlang — qoidalar seriyalarni vaqt tartibida tekshiradi.';

  @override
  String qcShowAllRuns(int count) {
    return 'Hammasini ko‘rsatish ($count)';
  }

  @override
  String get qcRejectedExcluded =>
      'Keyingi qoidalar va statistikada ishlatilmaydi';

  @override
  String qcAtEntry(String verdict) {
    return 'Kiritilganda: $verdict';
  }

  @override
  String get qcUndoTarget => 'Oxirgi o‘zgarishni bekor qilish';

  @override
  String qcUndoTargetBody(String target) {
    return 'Joriy maqsad o‘chiriladi va oldingisi qaytariladi: $target. Seriyalar qayta baholanadi.';
  }

  @override
  String get qcBackupTitle => 'Zaxira nusxa';

  @override
  String get qcBackupBody =>
      'QC ma’lumotlari faqat shu qurilmada saqlanadi. Zaxira nusxani (JSON) nusxalab, xavfsiz joyda saqlang; boshqa qurilmada buferdan tiklash mumkin.';

  @override
  String get qcBackupCopy => 'Zaxira nusxani nusxalash';

  @override
  String get qcBackupCopied => 'Zaxira nusxa buferga nusxalandi';

  @override
  String get qcBackupRestore => 'Buferdan tiklash';

  @override
  String qcRestoreConfirm(int sets, int runs) {
    return 'Joriy QC ma’lumotlari buferdagi zaxira nusxa bilan almashtiriladi: $sets ta test, $runs ta seriya.';
  }

  @override
  String get qcRestoreAction => 'Almashtirish';

  @override
  String get qcRestoreInvalid => 'Buferda yaroqli QC zaxira nusxasi topilmadi.';

  @override
  String get qcRestored => 'QC ma’lumotlari tiklandi';

  @override
  String get qcCopyRaw => 'Saqlangan matnni nusxalash';

  @override
  String get qcDiscard => 'O‘qib bo‘lmagan ma’lumotni o‘chirish';

  @override
  String get qcDiscardConfirm =>
      'Avval saqlangan matnni nusxalab oling. O‘chirilgandan keyin uni qaytarib bo‘lmaydi.';

  @override
  String get preTitle => 'Namuna yo‘li';

  @override
  String get preStep1 => 'Tahlilga tayyorlash';

  @override
  String get preStep2 => 'Namuna va qo‘shimchani tanlash';

  @override
  String get preStep3 => 'Olish va identifikatsiya';

  @override
  String get preStep4 => 'Ajratish va saqlash';

  @override
  String get preStep5 => 'Tashish va qabul qilish';

  @override
  String get preNotice =>
      'Probirka rangi, vaqt va harorat aniq probirka, metod va yo‘riqnomaga bog‘lanadi. Universal parametrlar berilmaydi.';

  @override
  String get preOrderTitle => 'Probirkalar tartibi (venepunksiya)';

  @override
  String get preOrderSub =>
      'JSST 2010, 2.3-jadval (NCCLS 2003 konsensusi asosida). Laboratoriyangizning amaldagi tartibini tekshiring.';

  @override
  String preCap(String cap) {
    return 'Qopqoq: $cap';
  }

  @override
  String get preHaemolysisTitle => 'Gemolizga olib keluvchi omillar';

  @override
  String get preTourniquetTitle => 'Jgut';

  @override
  String get preIdTitle => 'Bemorni aniqlash va yorliq';

  @override
  String get calcTitle => 'Kalkulyatorlar';

  @override
  String get calcLearningTag => 'O‘quv kalkulyatori';

  @override
  String get calcDilution => 'Suyultirish';

  @override
  String get calcDilutionSub => 'C₁V₁ = C₂V₂';

  @override
  String get calcUnits => 'Birliklarni o‘tkazish';

  @override
  String get calcUnitsSub => 'Moddaga xos';

  @override
  String get dilC1 => 'C₁ · Boshlang‘ich konsentratsiya';

  @override
  String get dilC2 => 'C₂ · Yakuniy konsentratsiya';

  @override
  String get dilV2 => 'V₂ · Yakuniy hajm (mL)';

  @override
  String get dilNote =>
      'C₁ va C₂ birliklari bir xil bo‘lsin. Oddiy suyultirish modeli: reaksiya, xavfsizlik va hajm o‘zgarishi hisoblanmaydi.';

  @override
  String get dilCalculate => 'Hisoblash';

  @override
  String dilResult(String volume) {
    return 'V₁ = $volume mL';
  }

  @override
  String get dilResultBody =>
      'Boshlang‘ich eritmadan olinadigan hajm. Umumiy hajmni V₂ gacha yetkazing.';

  @override
  String dilDiluent(String volume) {
    return 'Suyultiruvchi ≈ $volume mL (hajmlar qo‘shiladi deb)';
  }

  @override
  String get dilNoDilution => 'C₂ = C₁: suyultirish kerak emas.';

  @override
  String get dilErrorInvalid => 'Har bir maydonga noldan katta son kiriting.';

  @override
  String get dilErrorC2GtC1 =>
      'C₂ C₁ dan katta bo‘lmaydi: suyultirish konsentratsiyani oshirmaydi.';

  @override
  String get dilErrorRange => 'Qiymatlar hisoblash oralig‘idan tashqarida.';

  @override
  String get ucTitle => 'Birliklarni o‘tkazish';

  @override
  String get ucSubtitle =>
      'Har bir moddaning o‘z koeffitsiyenti bor — mg/dL → mmol/L uchun bitta umumiy koeffitsiyent noto‘g‘ri.';

  @override
  String get ucAnalyte => 'Modda';

  @override
  String get ucValue => 'Qiymat';

  @override
  String get ucSwap => 'Birliklarni almashtirish';

  @override
  String get ucConvert => 'O‘tkazish';

  @override
  String ucNote(String mass) {
    return 'Molyar massa $mass g/mol asosida hisoblandi. Laboratoriyalar boshqacha yaxlitlashi mumkin; laboratoriyangiz birligidan foydalaning.';
  }

  @override
  String get ucNotAvailable =>
      'Bu modda uchun tasdiqlangan molyar massa yo‘q, shuning uchun o‘tkazish taklif qilinmaydi.';

  @override
  String get ucErrorInvalid => '0 yoki undan katta son kiriting.';

  @override
  String get ucErrorRange => 'Qiymat hisoblash oralig‘idan tashqarida.';

  @override
  String get calcSectionClinical => 'Klinik formulalar';

  @override
  String get calcSectionLab => 'Laboratoriya';

  @override
  String get calcEgfr => 'eGFR · CKD‑EPI 2021';

  @override
  String get calcEgfrSub => 'Kreatinin, yosh, jins';

  @override
  String get calcAcr => 'Albumin/kreatinin nisbati';

  @override
  String get calcAcrSub => 'Siydik ACR · KDIGO A toifasi';

  @override
  String get calcAnionGap => 'Anion oralig‘i';

  @override
  String get calcAnionGapSub => 'Na, Cl, HCO₃ · K va albumin ixtiyoriy';

  @override
  String get calcCalcium => 'Tuzatilgan kalsiy';

  @override
  String get calcCalciumSub => 'Albumin bo‘yicha · Payne 1973';

  @override
  String get calcLdl => 'LDL va non-HDL xolesterin';

  @override
  String get calcLdlSub => 'Friedewald · Sampson';

  @override
  String get calcOsmo => 'Hisoblangan osmolyallik';

  @override
  String get calcOsmoSub => 'Osmolyal farq bilan';

  @override
  String get calcHba1c => 'HbA1c birliklari va eAG';

  @override
  String get calcHba1cSub => 'NGSP ↔ IFCC · ADAG';

  @override
  String get calcFormulaTag => 'Nashr etilgan formula';

  @override
  String get calcOptional => 'ixtiyoriy';

  @override
  String get calcNotDiagnosis =>
      'O‘rganish va tekshirish uchun hisob vositasi. Tashxis qo‘ymaydi: natijani klinik manzara va laboratoriyangiz referens intervallari bilan birga talqin qiling.';

  @override
  String calcUnitCheck(String field, String value, String unit) {
    return '$field: $value $unit bu birlik uchun odatiy emas — birlik to‘g‘ri tanlanganini tekshiring.';
  }

  @override
  String calcInputs(String list) {
    return 'Kiritilgan: $list';
  }

  @override
  String calcNegativeCheck(String name) {
    return '$name manfiy chiqdi — kiritilgan qiymatlar va birliklarni tekshiring.';
  }

  @override
  String calcUnitGroup(String field) {
    return '$field birligi';
  }

  @override
  String get calcFormula => 'Formula';

  @override
  String get calcLimitations => 'Cheklovlar';

  @override
  String get calcSources => 'Manbalar';

  @override
  String get fieldCreatinine => 'Qon zardobidagi kreatinin';

  @override
  String get fieldAge => 'Yosh, yil';

  @override
  String get fieldSex => 'Jins';

  @override
  String get fieldSodium => 'Natriy (Na⁺)';

  @override
  String get fieldChloride => 'Xlorid (Cl⁻)';

  @override
  String get fieldBicarbonate => 'Bikarbonat (HCO₃⁻)';

  @override
  String get fieldPotassium => 'Kaliy (K⁺)';

  @override
  String get fieldAlbumin => 'Zardob albumini';

  @override
  String get fieldNormalAlbumin =>
      'Laboratoriyangiz qabul qilgan normal albumin';

  @override
  String get fieldCalcium => 'Zardobdagi umumiy kalsiy';

  @override
  String get fieldTotalCholesterol => 'Umumiy xolesterin';

  @override
  String get fieldHdl => 'HDL xolesterin';

  @override
  String get fieldTriglycerides => 'Triglitseridlar';

  @override
  String get fieldGlucose => 'Glyukoza';

  @override
  String get fieldUrea => 'Mochevina (yoki BUN)';

  @override
  String get fieldMeasuredOsmolality => 'O‘lchangan osmolyallik';

  @override
  String get fieldHba1c => 'HbA1c';

  @override
  String get fieldUrineAlbumin => 'Siydikdagi albumin';

  @override
  String get fieldUrineCreatinine => 'Siydikdagi kreatinin';

  @override
  String get sexFemale => 'Ayol';

  @override
  String get sexMale => 'Erkak';

  @override
  String resGfrCategory(String code) {
    return 'KDIGO GFR toifasi: $code';
  }

  @override
  String resAlbCategory(String code) {
    return 'KDIGO albuminuriya toifasi: $code';
  }

  @override
  String get resCategoryBasisSi => 'mg/mmol chegaralari bo‘yicha aniqlandi.';

  @override
  String get resCategoryBasisConv => 'mg/g chegaralari bo‘yicha aniqlandi.';

  @override
  String get resAnionGap => 'Anion oralig‘i';

  @override
  String get resAnionGapK => 'Kaliy bilan';

  @override
  String get resAnionGapAlb => 'Albumin bo‘yicha tuzatilgan (Figge)';

  @override
  String get resCorrectedCa => 'Tuzatilgan kalsiy (Payne)';

  @override
  String get resNonHdl => 'Non-HDL xolesterin';

  @override
  String get resLdlFriedewald => 'LDL xolesterin · Friedewald';

  @override
  String get resLdlSampson => 'LDL xolesterin · Sampson';

  @override
  String get resOsmCalc => 'Hisoblangan osmolyallik';

  @override
  String get resOsmGap => 'Osmolyal farq';

  @override
  String get resEag => 'Taxminiy o‘rtacha glyukoza (eAG)';

  @override
  String errCalcMissing(String field) {
    return 'Son kiriting: $field.';
  }

  @override
  String errCalcImplausible(String field, String min, String max, String unit) {
    return '$field: kalkulyator qabul qiladigan oraliqdan tashqarida ($min–$max$unit). Qiymat va birlikni tekshiring.';
  }

  @override
  String get errEgfrAge =>
      'CKD-EPI 2021 tenglamasi 18 yosh va undan katta ishtirokchilarda ishlab chiqilgan; bolalar uchun hisoblanmaydi.';

  @override
  String errFriedewaldTg(String limit) {
    return 'Hisoblanmadi: triglitseridlar $limit dan oshsa, Friedewald ishonchli emas.';
  }

  @override
  String errSampsonTg(String limit) {
    return 'Hisoblanmadi: Sampson tenglamasi triglitseridlar $limit gacha bo‘lganda tekshirilgan.';
  }

  @override
  String errEagRange(String range) {
    return 'eAG ko‘rsatilmadi: ADAG ma’lumotlari HbA1c $range oralig‘ini qamraydi.';
  }

  @override
  String get errHdlGeTc =>
      'HDL xolesterin umumiy xolesteringa teng yoki undan katta bo‘lishi mumkin emas.';

  @override
  String get errNotPositive =>
      'Hisoblanmadi: natija musbat emas — qiymatlarni tekshiring.';

  @override
  String get errSexMissing => 'Jinsni tanlang.';

  @override
  String get micTitle => 'Mikroskopiya atlasi';

  @override
  String get micSubtitle =>
      'Siydik, qon va parazitlar — litsenziyali mikrofotolar';

  @override
  String get micAtlasError => 'Atlasni ochib bo‘lmadi';

  @override
  String get micNotFound => 'Bunday rasm yoki bo‘lim topilmadi';

  @override
  String micImagesCount(int count) {
    return '$count ta rasm';
  }

  @override
  String micGapsCount(int count) {
    return '$count tasi uchun rasm hali yo‘q';
  }

  @override
  String micResultsCount(int count) {
    return 'Topildi: $count';
  }

  @override
  String get micSearchLabel => 'Atlasdan qidirish';

  @override
  String get micSearchHint => 'Masalan: neytrofil, оксалат, malaria';

  @override
  String get micNoResultsTitle => 'Hech narsa topilmadi';

  @override
  String get micNoResultsBody =>
      'Boshqa nom bilan yoki boshqa tilda yozib ko‘ring (uz, ru, en).';

  @override
  String get micSections => 'Bo‘limlar';

  @override
  String get micEduNotice =>
      'O‘quv rasmlari — tashxis uchun emas. Har rasmda muallif, litsenziya va asl izoh bor. LabGuide tushuntirishlari — draft, mutaxassis tekshiruvi kutilmoqda.';

  @override
  String get micEduTag => 'O‘quv rasmi — tashxis uchun emas';

  @override
  String get micNoImageYet => 'Litsenziyali rasm hali yo‘q';

  @override
  String get micGapWhy => 'Nega yo‘q?';

  @override
  String get micAllGroups => 'Hammasi';

  @override
  String get micSectionQuiz => 'Shu bo‘lim bo‘yicha mashq';

  @override
  String get micZoom => 'Kattalashtirish';

  @override
  String micOpenFull(String name) {
    return '$name — to‘liq ekranda ochish';
  }

  @override
  String micImageSemantics(String name) {
    return 'Mikrofoto: $name';
  }

  @override
  String get micNames => 'Nomi uch tilda';

  @override
  String get micOriginalCaption => 'Asl izoh';

  @override
  String micCaptionLang(String lang) {
    return 'Manba tilida, so‘zma-so‘z · $lang';
  }

  @override
  String get micTranslation => 'Tarjima (LabGuide)';

  @override
  String get micLangEn => 'inglizcha';

  @override
  String get micLangEs => 'ispancha';

  @override
  String get micLangRu => 'ruscha';

  @override
  String get micPreparation => 'Preparat';

  @override
  String get micMagnification => 'Kattalashtirish';

  @override
  String get micStain => 'Bo‘yash';

  @override
  String get micNotStated => 'manbada ko‘rsatilmagan';

  @override
  String get micOnlySource => 'Faqat manbada yozilgan ma’lumot ko‘rsatiladi.';

  @override
  String get micDraftTitle => 'Nimaga e’tibor berish';

  @override
  String get micDraftTag => 'Draft · mutaxassis tekshiruvi kutilmoqda';

  @override
  String get micCreditTitle => 'Muallif va litsenziya';

  @override
  String get micAuthor => 'Muallif';

  @override
  String get micCredit => 'Manba';

  @override
  String get micOwnWork => 'Muallifning o‘z ishi (Own work)';

  @override
  String get micLicense => 'Litsenziya';

  @override
  String get micSourceDate => 'Manbadagi sana';

  @override
  String micLicenseText(String license) {
    return 'Litsenziya matni: $license';
  }

  @override
  String get micSourcePage => 'Manba sahifasi';

  @override
  String get micOriginalFile => 'Asl fayl';

  @override
  String micResized(int width, int height, int origWidth, int origHeight) {
    return 'Ilovadagi nusxa: $width×$height px (asli $origWidth×$origHeight px, faqat kichraytirilgan). Kesilmagan, yozuv qo‘shilmagan.';
  }

  @override
  String micNotResized(int width, int height) {
    return 'Ilovadagi nusxa: $width×$height px, asl o‘lchamda. Kesilmagan, yozuv qo‘shilmagan.';
  }

  @override
  String get micShareAlike =>
      'CC BY-SA: bu rasmdan olingan moslashtirilgan nusxalar ham shu litsenziya ostida tarqatiladi.';

  @override
  String get micCdcTerms =>
      'Foydalanish shartlari (CDC PHIL sahifasidan, so‘zma-so‘z)';

  @override
  String get micCdcFree =>
      'Bepul manba: CDC Public Health Image Library (PHIL), wwwn.cdc.gov/phil';

  @override
  String get micSameEntity => 'Shu turdagi boshqa rasmlar';

  @override
  String get micCreditsTitle => 'Rasmlar mualliflari';

  @override
  String get micCreditsSub => 'Litsenziyalar va manbalar';

  @override
  String micCreditsIntro(String date) {
    return 'Har rasmning litsenziyasi, muallifi va asl izohi manba sahifasidan qayta tekshirilgan ($date). Rasmlar faqat kichraytirilgan: kesilmagan, yozuv qo‘shilmagan, EXIF olib tashlangan. Faqat CC0, CC BY, CC BY-SA, public domain va CDC PHIL rasmlari olinadi.';
  }

  @override
  String get micLicenseTexts => 'Litsenziya matnlari';

  @override
  String get micCreditsRow => 'Mualliflar va litsenziyalar';

  @override
  String get micCreditsRowSub =>
      'Har rasmning manbasi va foydalanish shartlari';

  @override
  String get micClose => 'Yopish';

  @override
  String get micZoomIn => 'Kattalashtirish';

  @override
  String get micZoomOut => 'Kichraytirish';

  @override
  String get micZoomReset => 'Asl ko‘rinish';

  @override
  String get micViewerHint =>
      'Ikki barmoq bilan yoki ikki marta bosib kattalashtiring';

  @override
  String get micHeroEyebrow => 'Mashq';

  @override
  String get micQuizTitle => 'Bu nima?';

  @override
  String get micQuizSubtitle => 'Mikroskopiya mashqi';

  @override
  String get micQuizHeroBody =>
      'Rasmga qarang va to‘g‘ri nomni tanlang: 4 variant, hammasi atlasdan. Javob darhol ko‘rinadi.';

  @override
  String get micQuizCta => 'Mashqni boshlash';

  @override
  String get micQuizScope => 'Qaysi bo‘limdan?';

  @override
  String micQuizScopeChip(String name, int count) {
    return '$name · $count';
  }

  @override
  String micQuizStart(int count) {
    return 'Boshlash · $count ta savol';
  }

  @override
  String micQuizBest(int correct, int total) {
    return 'Eng yaxshi natija: $correct/$total';
  }

  @override
  String get micQuizNoBest => 'Hali natija yo‘q — birinchi raundni boshlang';

  @override
  String get micQuizRules =>
      'Variantlar faqat atlasdagi nomlardan olinadi. Aralash maydon va jurnal panellari mashqqa kirmaydi. Natija faqat shu qurilmada saqlanadi.';

  @override
  String micQuizProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String micQuizStreak(int count) {
    return '$count ketma-ket';
  }

  @override
  String get micQuizPromptArrow => 'Strelka ko‘rsatgan hujayra nima?';

  @override
  String get micQuizPromptCentre => 'Markazdagi hujayra nima?';

  @override
  String get micQuizPromptField => 'Bu maydonda asosan nima ko‘rinadi?';

  @override
  String get micQuizCorrect => 'To‘g‘ri!';

  @override
  String micQuizWrong(String answer) {
    return 'Noto‘g‘ri. To‘g‘ri javob: $answer';
  }

  @override
  String get micQuizOpenCard => 'Rasm kartasini ochish';

  @override
  String get micQuizTapToZoom => 'Kattalashtirish uchun rasmni bosing';

  @override
  String get micQuizResultGreat => 'A’lo natija!';

  @override
  String get micQuizResultGood => 'Yaxshi natija';

  @override
  String get micQuizResultKeep => 'Mashqni davom ettiring';

  @override
  String micQuizScore(int correct, int total) {
    return '$total tadan $correct tasi to‘g‘ri';
  }

  @override
  String micQuizBestStreak(int count) {
    return 'Eng uzun seriya: $count';
  }

  @override
  String get micQuizNewRecord => 'Yangi rekord';

  @override
  String micQuizRetryMistakes(int count) {
    return 'Xatolarni qayta ishlash ($count)';
  }

  @override
  String get micQuizNewRound => 'Yangi raund';

  @override
  String get micQuizChangeScope => 'Boshqa bo‘lim';

  @override
  String get micQuizBackToAtlas => 'Atlasga qaytish';

  @override
  String get insTitle => 'Apparatlar';

  @override
  String get insMindraySub => 'Aniq modelni tanlash kerak';

  @override
  String get insHumanSub => 'Apparat va reagent hujjatlari alohida';

  @override
  String get insOther => 'Boshqa ishlab chiqaruvchi';

  @override
  String get insOtherSub => 'Aniq model va IFU bo‘yicha moslash';

  @override
  String get instSearchLabel => 'Apparat qidirish';

  @override
  String get instSearchHint => 'Model yoki kompaniya';

  @override
  String get instNoResultsTitle => 'Model topilmadi';

  @override
  String get instNoResultsBody =>
      'Katalogda yo‘q apparatni pastdagi tugma bilan qo‘lda qo‘shishingiz mumkin.';

  @override
  String get instMine => 'Mening apparatlarim';

  @override
  String get instDirections => 'Yo‘nalishlar';

  @override
  String instModelsCount(int count) {
    return '$count ta model';
  }

  @override
  String instPlanned(String names) {
    return 'Keyingi bosqich: $names';
  }

  @override
  String get instPlannedBody =>
      'Bu ishlab chiqaruvchilarning modellari rasmiy manbalardan tekshirilgach qo‘shiladi.';

  @override
  String get instAddCustom => 'Ro‘yxatda yo‘q apparatni qo‘shish';

  @override
  String get instAddCustomSub =>
      'Ishlab chiqaruvchi va modelni o‘zingiz kiritasiz';

  @override
  String get instCustomTag => 'Siz kiritgan';

  @override
  String instCatalogNote(String date) {
    return 'Katalog ishlab chiqaruvchilarning rasmiy sahifa va hujjatlaridan tuzilgan ($date holatiga). Har ma’lumot yonida manbasi bor.';
  }

  @override
  String get instChooseMaker => 'Ishlab chiqaruvchini tanlang';

  @override
  String get instChooseModel => 'Modelni tanlang';

  @override
  String get instStatusTitle => 'Ma’lumot holati';

  @override
  String get instStatusDevice => 'Apparat ma’lumoti mavjud';

  @override
  String get instStatusDeviceSub =>
      'Rasmiy sahifa, buklet yoki regulyator hujjatidan';

  @override
  String get instStatusIfu => 'Yo‘riqnoma mavjud';

  @override
  String get instStatusIfuSub =>
      'Rasmiy operator qo‘llanmasi versiyasi bilan solishtirilgan';

  @override
  String get instStatusExpert => 'Mutaxassis tekshirgan';

  @override
  String get instStatusExpertSub =>
      'Mustaqil laboratoriya mutaxassisi ko‘rib chiqqan';

  @override
  String get instStatusDone => 'bor';

  @override
  String get instStatusNotYet => 'hali yo‘q';

  @override
  String get instPurpose => 'Vazifasi';

  @override
  String get instPrinciple => 'Ishlash prinsipi';

  @override
  String get instNotStated => 'Rasmiy manbada ko‘rsatilmagan.';

  @override
  String get instOfficialText => 'Rasmiy matn';

  @override
  String get instKeyFacts => 'Asosiy ma’lumotlar';

  @override
  String get instManual => 'Operator qo‘llanmasi';

  @override
  String get instManualPublic => 'Ochiq e’lon qilingan';

  @override
  String get instManualLogin => 'Login bilan';

  @override
  String get instManualNotPublic => 'Ochiq e’lon qilinmagan';

  @override
  String get instDocsPortal => 'Hujjatlar portali';

  @override
  String get instLoginYes => 'login kerak';

  @override
  String get instLoginNo => 'loginsiz';

  @override
  String get instLoginUnknown => 'login holati tekshirilmagan';

  @override
  String get instMaintenance => 'Kundalik parvarish';

  @override
  String get instMaintenanceNone =>
      'Ishlab chiqaruvchi kundalik parvarish bosqichlarini ochiq e’lon qilmagan. Apparatingiz operator qo‘llanmasidagi “Maintenance” bo‘limiga amal qiling — LabGuide bosqichlarni taxmin qilmaydi.';

  @override
  String get instMaintenanceQuotes =>
      'Ishlab chiqaruvchi ochiq manbada aytgani:';

  @override
  String get instReagentSystem => 'Reagent tizimi';

  @override
  String get instReagentOpen =>
      'Ochiq — boshqa ishlab chiqaruvchi reagentlari uchun ham sozlash mumkin';

  @override
  String get instReagentPartly => 'Qisman ochiq — foydalanuvchi kanallari bor';

  @override
  String get instReagentClosed => 'Yopiq — faqat tizim reagentlari';

  @override
  String get instReagentUnknown => 'Ochiqligi rasmiy manbada ko‘rsatilmagan';

  @override
  String instValidatedReagents(int count) {
    return 'Sozlamasi apparatda bor reagentlar (rasmiy manba bo‘yicha): $count';
  }

  @override
  String get instImageNone =>
      'Litsenziyasi aniq rasm topilmadi — ishlab chiqaruvchi rasmini ruxsatsiz joylamaymiz.';

  @override
  String instImageCredit(String author, String license) {
    return 'Rasm: $author · $license';
  }

  @override
  String get instIllustration =>
      'Sxematik rasm (LabGuide chizgan) — aniq modelning tashqi ko‘rinishi emas.';

  @override
  String get instSources => 'Manbalar';

  @override
  String instAccessed(String date) {
    return 'ko‘rilgan $date';
  }

  @override
  String get instSaveMine => 'Mening apparatim sifatida saqlash';

  @override
  String instSavedCount(int count) {
    return 'Mening apparatlarimda: $count';
  }

  @override
  String get instCalibrate => 'Kalibrlash';

  @override
  String get instQc => 'Sifat nazorati (QC)';

  @override
  String get instSaveTitle => 'Apparatni saqlash';

  @override
  String get instLabel => 'Nomi (ixtiyoriy)';

  @override
  String get instLabelHint => 'masalan, 1-xona yoki zaxira';

  @override
  String get instSerial => 'Seriya raqami (ixtiyoriy)';

  @override
  String get instManualVersion => 'Qo‘llanma versiyasi (ixtiyoriy)';

  @override
  String get instManualVersionHint =>
      'qo‘llanma muqovasidagi versiya yoki sana';

  @override
  String get instSave => 'Saqlash';

  @override
  String get instSaved => 'Saqlandi';

  @override
  String get instRemove => 'Ro‘yxatdan olib tashlash';

  @override
  String get instRemoveConfirm =>
      'Apparat ro‘yxatdan olib tashlansinmi? Kalibrlash jurnalidagi yozuvlar qoladi.';

  @override
  String get instMaker => 'Ishlab chiqaruvchi';

  @override
  String get instModel => 'Model';

  @override
  String get instCategory => 'Yo‘nalish';

  @override
  String get instCustomRequired => 'Ishlab chiqaruvchi va modelni kiriting.';

  @override
  String get instCatalogError => 'Apparatlar katalogini o‘qib bo‘lmadi';

  @override
  String get instOpenCard => 'Apparat kartasi';

  @override
  String get partnerAdLabel => 'Reklama';

  @override
  String get partnerLabel => 'Hamkor';

  @override
  String get partnerOfficialTitle => 'Rasmiy hamkorlar';

  @override
  String get partnerSectionNote =>
      'Hamkor kompaniyalar o‘zi bergan ma’lumot. Yuqoridagi katalog ma’lumotlari, tartibi va tekshiruv holati hamkorlikka bog‘liq emas.';

  @override
  String get partnerKindManufacturer => 'Ishlab chiqaruvchi';

  @override
  String get partnerKindDistributor => 'Rasmiy distribyutor';

  @override
  String get partnerKindService => 'Servis markazi';

  @override
  String get partnerCall => 'Qo‘ng‘iroq';

  @override
  String get partnerTelegram => 'Telegram';

  @override
  String get partnerWebsite => 'Sayt';

  @override
  String get partnerEmail => 'Email';

  @override
  String get partnerBrochure => 'Buklet';

  @override
  String get partnerMore => 'Batafsil';

  @override
  String partnerRegions(String regions) {
    return 'Hududlar: $regions';
  }

  @override
  String partnerRegistration(String number) {
    return 'O‘zbekistonda ro‘yxatdan o‘tganlik guvohnomasi: $number';
  }

  @override
  String get partnerRegistrationNote => 'Raqamni hamkor taqdim etgan.';

  @override
  String get partnerBecome => 'Hamkor bo‘lish';

  @override
  String get partnerBecomeSub => 'Firmalar uchun: apparatlaringiz LabGuide’da';

  @override
  String get partnerNotFoundTitle => 'Hamkor topilmadi';

  @override
  String get partnerNotFoundBody =>
      'E’lon muddati tugagan yoki to‘xtatilgan bo‘lishi mumkin.';

  @override
  String get partnerContacts => 'Aloqa';

  @override
  String get partnerAbout => 'Kompaniya haqida';

  @override
  String get partnerInstruments => 'Bog‘liq apparatlar';

  @override
  String partnerAllModels(String maker) {
    return '$maker: barcha modellar';
  }

  @override
  String get partnerPageNote =>
      'Bu sahifa — reklama. LabGuide hamkor mahsulotini tavsiya qilmaydi; katalog ma’lumotlari va tekshiruv holati hamkorlikka bog‘liq emas.';

  @override
  String get partnerOfferTitle => 'Rasmiy aloqangiz — apparat kartasida';

  @override
  String get partnerOfferBody =>
      'Laboratoriya mutaxassisi apparat haqida o‘qiyotganda rasmiy distribyutor yoki servis markaziga bir bosishda qo‘ng‘iroq qila oladi. Ishlab chiqaruvchilar, rasmiy distribyutorlar va servis markazlari uchun.';

  @override
  String get partnerWhatTitle => 'Nima beriladi';

  @override
  String get partnerWhatCard =>
      'Apparat kartasida “Rasmiy hamkorlar” bo‘limi: logo, qisqa tavsif, hududlar, telefon va Telegram tugmalari.';

  @override
  String get partnerWhatCategory =>
      'Yo‘nalish ichida (masalan, Biokimyo) ixcham “Hamkor” kartasi.';

  @override
  String get partnerWhatLabHome =>
      'Lab bo‘limi bosh sahifasida navbat bilan bitta reklama kartasi.';

  @override
  String get partnerWhatPage =>
      'Hamkor sahifasi: bog‘liq modellar, guvohnoma raqamlari, buklet.';

  @override
  String get partnerWhatReport =>
      'Hisobot: kun va joy bo‘yicha ko‘rsatilishlar va “bog‘lanish” bosilishlari (shaxsiy ma’lumotsiz).';

  @override
  String get partnerAudienceTitle => 'Auditoriya';

  @override
  String get partnerAudienceBody =>
      'LabGuide laboratoriya mutaxassislari, shifokorlar, talabalar va ustozlar uchun — o‘zbek, rus va ingliz tillarida. Foydalanuvchilar soni va rollar taqsimotini kelishuv paytida server statistikasidan ko‘rsatamiz; taxminiy raqam aytmaymiz.';

  @override
  String get partnerRulesTitle => 'Qoidalar';

  @override
  String get partnerRule1 =>
      'Har bir joyda aniq “Reklama” yoki “Hamkor” yorlig‘i turadi.';

  @override
  String get partnerRule2 =>
      'Katalog faktlari, tartibi va tekshiruv holati hamkorlikka bog‘liq emas — pul evaziga o‘zgarmaydi.';

  @override
  String get partnerRule3 =>
      'Tibbiy buyum reklamasi: apparat O‘zbekistonda ro‘yxatdan o‘tgan bo‘lishi kerak; guvohnoma raqami kartada ko‘rsatiladi.';

  @override
  String get partnerRule4 =>
      'Faqat tekshirsa bo‘ladigan ma’lumot: “eng yaxshi”, “100% aniq” kabi isbotsiz da’volar qabul qilinmaydi.';

  @override
  String get partnerRule5 =>
      'Foydalanuvchilarning shaxsiy ma’lumotlari hamkorga berilmaydi.';

  @override
  String get partnerPriceTitle => 'Narx';

  @override
  String get partnerPriceBody =>
      'Narx kelishiladi — joylar, muddat va hududlarga qarab.';

  @override
  String get partnerHowTitle => 'Qanday ulanadi';

  @override
  String get partnerHow1 => 'Pastdagi forma orqali ariza yuboring.';

  @override
  String get partnerHow2 => 'Biz bog‘lanamiz va shartlarni kelishamiz.';

  @override
  String get partnerHow3 =>
      'Logo, tavsif (uz/ru/en), aloqa va guvohnoma raqamlarini yuborasiz.';

  @override
  String get partnerHow4 =>
      'Tekshirilgach e’lon qilinadi; hisobotni muntazam yuboramiz.';

  @override
  String get partnerFormTitle => 'Ariza';

  @override
  String get partnerFormCompany => 'Kompaniya';

  @override
  String get partnerFormContact => 'Mas’ul shaxs';

  @override
  String get partnerFormPhone => 'Telefon';

  @override
  String get partnerFormEmail => 'Email';

  @override
  String get partnerFormProducts => 'Mahsulotlar (apparatlar, modellar)';

  @override
  String get partnerFormMessage => 'Xabar';

  @override
  String get partnerFormHint => 'Telefon yoki emaildan kamida bittasi kerak.';

  @override
  String get partnerFormSend => 'Arizani yuborish';

  @override
  String get partnerFormInvalid =>
      'Kompaniya va mas’ul shaxsni kiriting, telefon yoki emailni to‘g‘ri yozing.';

  @override
  String get partnerSentTitle => 'Ariza yuborildi';

  @override
  String get partnerSentBody =>
      'Javob shu sahifada, “Arizalaringiz” bo‘limida ko‘rinadi. Kerak bo‘lsa, ko‘rsatgan telefon yoki emailingiz orqali bog‘lanamiz.';

  @override
  String get partnerSendAnother => 'Yana ariza yuborish';

  @override
  String get partnerFormSignIn =>
      'Ariza yuborish uchun email bilan kiring — javob shu hisobga keladi.';

  @override
  String get partnerFormUnavailable =>
      'Ariza yuborish hali ulanmagan: bu buildda server sozlanmagan.';

  @override
  String get partnerMyRequests => 'Arizalaringiz';

  @override
  String get partnerReqStatusNew => 'Yangi';

  @override
  String get partnerReqStatusInReview => 'Ko‘rib chiqilmoqda';

  @override
  String get partnerReqStatusAccepted => 'Qabul qilindi';

  @override
  String get partnerReqStatusDeclined => 'Rad etildi';

  @override
  String partnerReqReply(String text) {
    return 'LabGuide javobi: $text';
  }

  @override
  String get partnerPlacementCard => 'Apparat kartasi';

  @override
  String get partnerPlacementCategory => 'Yo‘nalish';

  @override
  String get partnerPlacementLabHome => 'Lab bosh sahifasi';

  @override
  String get partnerPlacementPage => 'Hamkor sahifasi';

  @override
  String get adminPartners => 'Hamkorlar';

  @override
  String get adminPartnersSub => 'Reklama: yaratish, e’lon, statistika';

  @override
  String get adminPartnerRequests => 'Hamkorlik arizalari';

  @override
  String adminPartnerRequestsNew(int count) {
    return 'Yangi arizalar: $count';
  }

  @override
  String get adminPartnerNew => 'Yangi hamkor';

  @override
  String get adminPartnersEmpty => 'Hali hamkor yo‘q';

  @override
  String get adminPartnerStatusDraft => 'Qoralama';

  @override
  String get adminPartnerStatusLive => 'E’lon qilingan';

  @override
  String get adminPartnerStatusPaused => 'To‘xtatilgan';

  @override
  String get adminPartnerExpired => 'Muddati tugagan';

  @override
  String get adminPartnerUpcoming => 'Hali boshlanmagan';

  @override
  String get adminPartnerName => 'Kompaniya nomi';

  @override
  String get adminPartnerKind => 'Turi';

  @override
  String get adminPartnerLogo => 'Logo havolasi (https://…)';

  @override
  String get adminPartnerLogoUpload => 'Logoni yuklash (PNG/JPEG, ≤ 1 MB)';

  @override
  String get adminPartnerLogoTooLarge =>
      'Logo 1 MB dan katta yoki PNG/JPEG emas.';

  @override
  String adminPartnerSummary(String lang) {
    return 'Qisqa tavsif ($lang)';
  }

  @override
  String get adminPartnerRegions => 'Hududlar';

  @override
  String get adminPartnerTelegram => 'Telegram (username)';

  @override
  String get adminPartnerWebsite => 'Sayt (https://…)';

  @override
  String get adminPartnerBrochure => 'Buklet havolasi (https://…)';

  @override
  String get adminPartnerLinks => 'Katalogga bog‘lash';

  @override
  String get adminPartnerMakers => 'Ishlab chiqaruvchilar (barcha modellari)';

  @override
  String get adminPartnerModels => 'Modellar';

  @override
  String get adminPartnerAddModel => 'Model qo‘shish';

  @override
  String get adminPartnerRegNo => 'Guvohnoma raqami (ixtiyoriy)';

  @override
  String get adminPartnerUnlink => 'Olib tashlash';

  @override
  String get adminPartnerPeriodTitle => 'Faollik davri';

  @override
  String get adminPartnerStarts => 'Boshlanish';

  @override
  String get adminPartnerEnds => 'Tugash';

  @override
  String get adminPartnerSave => 'Saqlash';

  @override
  String get adminPartnerSaved => 'Saqlandi';

  @override
  String get adminPartnerPublish => 'E’lon qilish';

  @override
  String get adminPartnerPause => 'To‘xtatish';

  @override
  String get adminPartnerPublished => 'E’lon qilindi';

  @override
  String get adminPartnerPausedMsg => 'To‘xtatildi';

  @override
  String get adminPartnerPublishRules =>
      'E’lon uchun: tavsif, kamida bitta aloqa va kamida bitta bog‘lanish kerak. Reklama har joyda “Reklama” yorlig‘i bilan chiqadi va katalog ma’lumotiga ta’sir qilmaydi.';

  @override
  String get adminPartnerInvalid =>
      'Ma’lumotni tekshiring: nom (2–120 belgi), telefon, Telegram (5–32 belgi), https havolalar, email, sanalar; e’lon uchun — tavsif, aloqa va bog‘lanish.';

  @override
  String get adminPartnerStats => 'Statistika';

  @override
  String get adminStatsImpressions => 'Ko‘rsatilish';

  @override
  String get adminStatsContacts => '“Bog‘lanish” bosilishi';

  @override
  String get adminStatsCtr => 'Bosilish ulushi';

  @override
  String get adminStats7 => 'Oxirgi 7 kun';

  @override
  String get adminStats30 => 'Oxirgi 30 kun';

  @override
  String get adminStatsAll => 'Butun davr';

  @override
  String get adminStatsPeriods => 'Davrlar bo‘yicha';

  @override
  String get adminStatsByPlacement => 'Joylar bo‘yicha (30 kun)';

  @override
  String get adminStatsDaily => 'Kunlar bo‘yicha';

  @override
  String get adminStatsEmpty => 'Hali hodisa yo‘q';

  @override
  String get adminStatsNote =>
      'Hisoblash: ko‘rsatilish — hamkor bloki ekranda chizilgan; bitta qurilmada kuniga har joy uchun bir marta. Faqat hisobga kirgan foydalanuvchilar sanaladi (mehmon va admin — yo‘q). Shaxsiy ma’lumot saqlanmaydi, faqat kunlik hisoblagich (Toshkent vaqti).';

  @override
  String get adminStatsCopy => 'Hisobotni nusxalash';

  @override
  String get adminRequestsEmpty => 'Ariza yo‘q';

  @override
  String get adminRequestReply => 'Javob (arizachi ko‘radi)';

  @override
  String get adminRequestSave => 'Holat va javobni saqlash';

  @override
  String get adminActionPartnerCreated => 'Hamkor yaratildi';

  @override
  String get adminActionPartnerUpdated => 'Hamkor tahrirlandi';

  @override
  String get adminActionPartnerPublished => 'Hamkor e’lon qilindi';

  @override
  String get adminActionPartnerPaused => 'Hamkor to‘xtatildi';

  @override
  String get adminActionPartnerDraft => 'Hamkor qoralamaga qaytdi';

  @override
  String get adminActionPartnerRequest => 'Hamkorlik arizasi ko‘rib chiqildi';

  @override
  String get calStepInstrument => '1. Apparat';

  @override
  String get calStepAnalyte => '2. Analit';

  @override
  String get calStepReagent => '3. Reagent';

  @override
  String get calChooseInstrument =>
      'Avval apparatni tanlang: saqlanganlardan yoki katalogdan.';

  @override
  String get calChange => 'O‘zgartirish';

  @override
  String get calFromCatalog => 'Katalogdan tanlash';

  @override
  String get calAnalyteHint => 'Masalan, glyukoza';

  @override
  String get calReagentMaker => 'Reagent ishlab chiqaruvchisi';

  @override
  String get calReagentMakerName => 'Ishlab chiqaruvchi nomi';

  @override
  String get calDifferentMaker =>
      'Reagent ishlab chiqaruvchisi apparatnikidan boshqa. Moslikni reagent IFU’sidagi apparatlar (application) ro‘yxati va apparatning reagent tizimi bo‘yicha alohida tekshiring.';

  @override
  String calValidated(String doc) {
    return 'Rasmiy manbada ($doc) bu apparatda sozlamasi bor reagentlar:';
  }

  @override
  String get calRefListed => 'Kiritilgan REF shu ro‘yxatda bor.';

  @override
  String get calRefNotListed =>
      'Kiritilgan REF bu ro‘yxatda yo‘q — reagent qutisi va IFU’ni qayta tekshiring.';

  @override
  String get calShowGuide => 'Yo‘riqnomani ko‘rsatish';

  @override
  String get calGuideNeeds =>
      'Apparat, analit, reagent REF va IFU versiyasini kiriting. Lot bu bosqichda shart emas.';

  @override
  String get calGuideFound => 'Tekshirilgan yo‘riqnoma topildi';

  @override
  String get calGuideNoneTitle => 'Tekshirilgan yo‘riqnoma hali yo‘q';

  @override
  String get calGuideNoneBody =>
      'Bu apparat + reagent REF + IFU versiyasi uchun LabGuide’da solishtirilgan yozuv yo‘q. Parametrlarni taxmin qilmaymiz — ularni quyidagi hujjatlardan oling:';

  @override
  String get calGuide1 =>
      'Kalibrator nomi va REF — reagent IFU’sining “Calibration” bo‘limida.';

  @override
  String get calGuide2 =>
      'Kalibrlash nuqtalari soni va usuli — o‘sha bo‘limda.';

  @override
  String get calGuide3 =>
      'Har lotning belgilangan qiymatlari — kalibratorning qiymatlar varag‘ida (lot raqami mos bo‘lsin).';

  @override
  String get calGuide4 =>
      'Qachon qayta kalibrlash kerakligi (lot almashganda, QC rad etilganda, muddat) — IFU’da.';

  @override
  String get calGuide5 =>
      'Kalibrlashdan keyin QC o‘tkazing va natijani yozuvga kiriting.';

  @override
  String get calDocsWhere => 'Hujjatlarni qayerdan topish mumkin';

  @override
  String get calRecordCreate => 'Kalibrlash yozuvini yaratish';

  @override
  String get calRecordTitle => 'Kalibrlash yozuvi';

  @override
  String get calCalibratorName => 'Kalibrator nomi yoki REF (ixtiyoriy)';

  @override
  String get calLotExpiry => 'Lot yaroqlilik muddati (ixtiyoriy)';

  @override
  String get calLevels => 'Kalibrator darajalari';

  @override
  String get calLevelName => 'Daraja';

  @override
  String get calLevelValue => 'Belgilangan qiymat';

  @override
  String get calLevelUnit => 'Birlik';

  @override
  String get calAddLevel => 'Daraja qo‘shish';

  @override
  String get calRemoveLevel => 'Darajani olib tashlash';

  @override
  String get calValuesFromSheet =>
      'Qiymatlarni aynan shu lotning qiymatlar varag‘idan ko‘chiring. LabGuide ularni taxmin qilmaydi va tekshirmaydi.';

  @override
  String get calPerformedOn => 'Bajarilgan sana';

  @override
  String get calOutcome => 'Natija';

  @override
  String get calOutcomeAccepted => 'Qabul qilindi';

  @override
  String get calOutcomeRejected => 'Rad etildi';

  @override
  String get calOutcomePending => 'Kutilmoqda';

  @override
  String get calNote => 'Izoh (ixtiyoriy)';

  @override
  String get calRecordSave => 'Yozuvni saqlash';

  @override
  String get calRecordSaved => 'Kalibrlash yozuvi saqlandi';

  @override
  String get calLotRequired => 'Kalibrator lotini kiriting.';

  @override
  String get calLevelInvalid =>
      'Har daraja uchun nom, qiymat (son) va birlikni kiriting.';

  @override
  String get calLog => 'Kalibrlash jurnali';

  @override
  String get calLogSub => 'Lot, qiymatlar va natija — shu qurilmada';

  @override
  String get calLogEmpty => 'Hali yozuv yo‘q';

  @override
  String get calLogEmptyBody =>
      'Kalibrlashdan keyin yozuv yarating — lot, qiymatlar va natija shu yerda saqlanadi.';

  @override
  String get calDeleteRecord => 'Yozuvni o‘chirish';

  @override
  String get calDeleteRecordConfirm => 'Kalibrlash yozuvi o‘chirilsinmi?';

  @override
  String get calUserEntered => 'Qiymatlar foydalanuvchi tomonidan kiritilgan.';

  @override
  String get calDetailInstrument => 'Apparat';

  @override
  String get calDetailManual => 'Qo‘llanma versiyasi';

  @override
  String get calDetailCalibrator => 'Kalibrator';

  @override
  String get calDetailLotExpiry => 'Lot yaroqlilik muddati';

  @override
  String get calLot => 'Lot';

  @override
  String calAnalyteSelected(String name) {
    return 'Analit: $name';
  }

  @override
  String get libTitle => 'Kutubxona';

  @override
  String get libSubtitle => 'Bilimlaringiz bir joyda.';

  @override
  String get libBooks => 'Kitob va qo‘llanmalar';

  @override
  String get libBooksSub => 'Kitob, qo‘llanma va saytlar katalogi';

  @override
  String get libPacks => 'Oflayn paketlar';

  @override
  String get libPacksSub => 'O‘rnatilgan va kutilayotgan paketlar';

  @override
  String get libSavedSub => 'Saqlangan tahlillar';

  @override
  String get libResearchSub => 'Savol, reja, haqiqiy ma’lumot va manba';

  @override
  String get libSources => 'Manbalar va litsenziyalar';

  @override
  String get libSourcesSub => 'Tekshiruv va foydalanish shartlari';

  @override
  String get booksEmptyTitle => 'Hali kitoblar yo‘q';

  @override
  String get booksEmptyBody =>
      'Kitoblar faqat tarqatish huquqi tasdiqlangandan keyin qo‘shiladi. O‘zingiz qo‘shgan PDF shaxsiy o‘rganish uchun qoladi va tarqatilmaydi.';

  @override
  String get booksCatalogNote =>
      'Katalogdagi materiallar rasmiy sahifaga havola sifatida beriladi. To‘liq matn ilovaga faqat ochiq litsenziya yoki tarqatish ruxsati tasdiqlangandan keyin qo‘shiladi.';

  @override
  String get booksResetFilters => 'Filtrlarni tozalash';

  @override
  String get packsInstalled => 'O‘rnatilgan';

  @override
  String get packsCoreTitle => 'Asosiy kontent';

  @override
  String packsVersion(String version) {
    return 'Versiya $version';
  }

  @override
  String packsSize(String size) {
    return 'Hajm: $size';
  }

  @override
  String packsLanguages(String languages) {
    return 'Tillar: $languages';
  }

  @override
  String packsLicence(String licence) {
    return 'Litsenziya: $licence';
  }

  @override
  String get packsVerified => 'Butunligi tekshirildi (SHA-256)';

  @override
  String get packsUpcoming => 'Kutilayotgan paketlar';

  @override
  String get packsUpcomingBody =>
      'Yuklashdan oldin haqiqiy hajm ko‘rsatiladi. Paketlar kontent tekshiruvidan keyingina nashr etiladi.';

  @override
  String get packsBiochem => 'Biokimyo asoslari';

  @override
  String get packsSpecimensQc => 'Namuna va QC';

  @override
  String get packsMicroscopy => 'Mikroskopiya atlasi';

  @override
  String get packsNotPublished => 'Hali nashr etilmagan';

  @override
  String get packsBuiltIn => 'Ilovaga o‘rnatilgan';

  @override
  String get packsOffline => 'Internetsiz ishlaydi';

  @override
  String get packsCoreState =>
      'Holat: draft — manbali o‘quv namunasi, mustaqil mutaxassis tekshiruvidan hali o‘tmagan';

  @override
  String packsContents(int cards, int questions, int sources) {
    return 'Tarkib: $cards ta karta, $questions ta savol, $sources ta manba';
  }

  @override
  String get packsDownloadable => 'Yuklab olinadigan paketlar';

  @override
  String get packsCatalogLoading => 'Katalog yuklanmoqda…';

  @override
  String get packsCatalogCached => 'Oxirgi saqlangan katalog ko‘rsatilmoqda';

  @override
  String get packsCatalogEmpty => 'Hozircha yuklab olinadigan paket yo‘q';

  @override
  String get packsStatusTest => 'Sinov paketi · klinik paket emas';

  @override
  String get packsStatusDraft => 'Draft · mutaxassis tekshirmagan';

  @override
  String get packsStatusReviewed => 'Mutaxassis tekshirgan';

  @override
  String packsMeta(String version, String size, String languages) {
    return 'Versiya $version · $size · $languages';
  }

  @override
  String packsDownload(String size) {
    return 'Yuklab olish · $size';
  }

  @override
  String packsDownloading(int percent) {
    return 'Yuklanmoqda… $percent %';
  }

  @override
  String packsInstalledVersion(String version, String size) {
    return 'O‘rnatilgan: $version · $size';
  }

  @override
  String packsUpdate(String version) {
    return 'Yangilash: $version';
  }

  @override
  String get packsRemove => 'O‘chirish';

  @override
  String get packsRemoveTitle => 'Paketni o‘chirasizmi?';

  @override
  String get packsRemoveBody =>
      'Paket qurilmadan o‘chiriladi. Keyin uni qayta yuklab olish mumkin.';

  @override
  String get packsFailNetwork =>
      'Internetga ulanib bo‘lmadi. Aloqani tekshirib, qayta urinib ko‘ring.';

  @override
  String get packsFailServer =>
      'Server javob bermadi. Birozdan keyin qayta urinib ko‘ring.';

  @override
  String get packsFailIntegrity =>
      'Paket tekshiruvdan o‘tmadi (hajm yoki SHA-256 mos emas) va o‘rnatilmadi. Avvalgi holat o‘zgarmadi.';

  @override
  String get packsFailIncompatible =>
      'Bu paket ilovaning yangiroq versiyasini talab qiladi.';

  @override
  String get packsFailStorage =>
      'Qurilmaga yozib bo‘lmadi. Bo‘sh joyni tekshiring.';

  @override
  String get packsPlanned => 'Rejalashtirilgan';

  @override
  String get packsPlannedBody =>
      'Kontent mustaqil tekshiruvdan o‘tgach nashr etiladi; hajmi yuklashdan oldin ko‘rsatiladi.';

  @override
  String get savedEmptyTitle => 'Hali xatcho‘p yo‘q';

  @override
  String get savedEmptyBody =>
      'Tahlil kartasida “Saqlash”ni bosing — u shu yerda turadi.';

  @override
  String get sourcesTitle => 'Manbalar va litsenziyalar';

  @override
  String get sourcesContent => 'Analit kartalari';

  @override
  String get sourcesMethods => 'Kalkulyatorlar, QC va preanalitika';

  @override
  String get sourcesBody =>
      'Nashr etiladigan har bir da’vo asl manba, murojaat sanasi, qamrov va tekshiruv holatiga bog‘lanadi.';

  @override
  String get researchTitle => 'Ilmiy ish maydoni';

  @override
  String get researchQuestion => 'Mavzu yoki ilmiy savol';

  @override
  String get researchQuestionHint => 'Mavzuni kiriting';

  @override
  String get researchNotes => 'Maqsad va qaydlar';

  @override
  String get researchNotesHint => 'O‘z ma’lumotlaringiz va manbalaringiz';

  @override
  String get researchSave => 'Qoralamani saqlash';

  @override
  String get researchSaved => 'Qoralama shu qurilmada saqlandi';

  @override
  String get researchAutosave =>
      'Qoralama yozish davomida shu qurilmada avtomatik saqlanadi.';

  @override
  String get researchOutline => 'Reja tuzilmasi';

  @override
  String get researchStep1 => 'Savol va maqsad';

  @override
  String get researchStep2 => 'Manbalar sharhi';

  @override
  String get researchStep3 => 'Metod va haqiqiy ma’lumotlar';

  @override
  String get researchStep4 => 'Natija, cheklov va xulosa';

  @override
  String get researchNoFabrication =>
      'LabGuide natija, bemor ma’lumoti yoki iqtibos to‘qimaydi. Faqat o‘z ma’lumotlaringiz va manbalaringizdan foydalaning.';

  @override
  String get learnTitle => 'Tushunib o‘rganing';

  @override
  String get learnHeroTag => 'Rasmli biokimyo';

  @override
  String get learnHeroTitle => 'Molekuladan amaliyotgacha';

  @override
  String get learnHeroBody => 'Mavzular, mexanizmlar va bilimni tekshirish.';

  @override
  String get learnHeroCta => 'Mavzularni ko‘rish';

  @override
  String get learnClassesSub => 'Ustoz → topshiriq → talaba → natija';

  @override
  String get learnQuiz => 'Izohli test';

  @override
  String learnQuizSub(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta mashq savoli',
    );
    return '$_temp0';
  }

  @override
  String get learnExam => 'Imtihon rejimi';

  @override
  String get learnExamSub => 'Vaqt, mavzu va savollar';

  @override
  String get learnLessonPlan => 'Dars rejasi';

  @override
  String get learnLessonPlanSub => 'Ustoz uchun ish maydoni';

  @override
  String quizProgress(int current, int total) {
    return 'Savol $current / $total';
  }

  @override
  String get quizCorrect => 'To‘g‘ri.';

  @override
  String get quizIncorrect => 'Bu javob to‘g‘ri emas.';

  @override
  String get quizNext => 'Keyingi';

  @override
  String get quizFinish => 'Natijani ko‘rish';

  @override
  String get quizDoneTitle => 'Mashq yakunlandi';

  @override
  String quizScore(int correct, int total) {
    return '$total tadan $correct ta to‘g‘ri';
  }

  @override
  String get quizRestart => 'Qayta boshlash';

  @override
  String quizBasis(String basis) {
    return 'Asos: $basis';
  }

  @override
  String get quizSources => 'Manba';

  @override
  String get quizReviewNote =>
      'Mashq savollari mutaxassis tekshiruvini kutmoqda.';

  @override
  String get quizMistakes => 'Xatolar ustida ishlash';

  @override
  String get quizNoMistakes => 'Xato yo‘q — barakalla.';

  @override
  String get quizYourAnswer => 'Sizning javobingiz';

  @override
  String get quizCorrectAnswer => 'To‘g‘ri javob';

  @override
  String get quizChooseTopic => 'Mavzuni tanlang';

  @override
  String quizTopicMixed(int count) {
    return 'Aralash: $count ta tasodifiy savol';
  }

  @override
  String get quizTopicGeneral => 'Laboratoriya hisoblari';

  @override
  String quizQuestionCount(int count) {
    return '$count ta savol';
  }

  @override
  String get quizOtherTopic => 'Boshqa mavzu';

  @override
  String get quizTopicMistakes => 'Xatolarim ustida ishlash';

  @override
  String quizMastered(int correct, int total) {
    return '$total tadan $correct tasi oxirgi safar to‘g‘ri';
  }

  @override
  String get examTitle => 'Imtihon rejimi';

  @override
  String get examBody =>
      'Vaqtli imtihon va natijalar tarixi o‘rganish moduli bilan qo‘shiladi. Mashq savollari hozir ochiq.';

  @override
  String get examOpenPractice => 'Mashq savollarini ochish';

  @override
  String get classesTitle => 'Guruh va topshiriqlar';

  @override
  String get classesSignInTitle => 'Guruhlar uchun hisobga kiring';

  @override
  String get classesSignInBody =>
      'Guruh yaratish, qo‘shilish va topshiriq yuborish hisobga bog‘langan. Kontentni o‘qish kirishsiz ochiq qoladi.';

  @override
  String get classesSignIn => 'Kirish';

  @override
  String get classesUnavailableTitle => 'Guruhlar serveri hali ulanmagan';

  @override
  String get classesUnavailableBody =>
      'Hech narsa yuborilmaydi va saqlanmaydi. Ulanganda ustoz faqat o‘z guruhini, talaba faqat o‘z natijasini ko‘radi — bu serverda tekshiriladi.';

  @override
  String get profileTitle => 'Profil va sozlamalar';

  @override
  String get profileGuest => 'Mehmon';

  @override
  String get profileGuestSub => 'Kontent hisobsiz ochiq';

  @override
  String get profileDemoSession => 'Demo sessiya · debug build';

  @override
  String get profileRole => 'Yo‘nalish';

  @override
  String get profileRoleSub => 'Bosh sahifa sizga moslashadi';

  @override
  String get profileLanguage => 'Til';

  @override
  String get profileAppearance => 'Tashqi ko‘rinish';

  @override
  String get themeSystem => 'Tizim';

  @override
  String get themeLight => 'Kunduzgi';

  @override
  String get themeDark => 'Tungi';

  @override
  String get profilePurchase => 'Obuna va tiklash';

  @override
  String get profilePurchaseSub => 'Free · Pro';

  @override
  String get profilePrivacy => 'Maxfiylik va yordam';

  @override
  String get profilePrivacySub => 'Ma’lumotlar va hisob boshqaruvi';

  @override
  String get supportTitle => 'Taklif va yordam';

  @override
  String get supportSub => 'Taklif, xatolik yoki savol — javob shu yerda';

  @override
  String get supportNew => 'Yangi murojaat';

  @override
  String get supportEmptyTitle => 'Hali murojaat yo‘q';

  @override
  String get supportEmptyBody =>
      'Taklif, xatolik yoki savolingizni yozing — javob shu yerda ko‘rinadi.';

  @override
  String get supportKind => 'Turi';

  @override
  String get supportKindSuggestion => 'Taklif';

  @override
  String get supportKindBug => 'Xatolik';

  @override
  String get supportKindQuestion => 'Savol';

  @override
  String get supportSubject => 'Mavzu';

  @override
  String get supportSubjectHint => 'Qisqacha: nima haqida?';

  @override
  String get supportMessage => 'Xabar';

  @override
  String get supportMessageHint =>
      'Batafsil yozing: qaysi ekranda, nima qildingiz, nima kutgan edingiz';

  @override
  String get supportAttach => 'Skrinshot biriktirish (ixtiyoriy)';

  @override
  String get supportAttachRemove => 'Rasmni olib tashlash';

  @override
  String get supportAttachTooLarge =>
      'Rasm 5 MB dan katta. Kichikroq rasm tanlang.';

  @override
  String get supportAttachType => 'Faqat PNG yoki JPEG rasm.';

  @override
  String get supportPhiNotice =>
      'Skrinshotda bemorning ismi, tug‘ilgan sanasi, karta raqami yoki boshqa shaxsiy ma’lumoti bo‘lmasin.';

  @override
  String get supportSend => 'Yuborish';

  @override
  String get supportSent => 'Murojaat yuborildi';

  @override
  String get supportReplyHint => 'Javob yozing…';

  @override
  String get supportTeam => 'LabGuide jamoasi';

  @override
  String get supportYou => 'Siz';

  @override
  String get supportUser => 'Foydalanuvchi';

  @override
  String get supportHumanReplies =>
      'Javoblarni LabGuide jamoasi o‘zi yozadi; avtomatik javob yuborilmaydi.';

  @override
  String get supportStatusNew => 'Yangi';

  @override
  String get supportStatusInReview => 'Ko‘rib chiqilmoqda';

  @override
  String get supportStatusAnswered => 'Javob berildi';

  @override
  String get supportStatusClosed => 'Yopildi';

  @override
  String get supportUnread => 'Yangi javob';

  @override
  String supportUnreadCount(int count) {
    return '$count ta yangi javob';
  }

  @override
  String get supportSignInTitle => 'Murojaat uchun hisobga kiring';

  @override
  String get supportSignInBody =>
      'Javobni sizga yetkazish uchun email bilan kirish kerak. Qurilmadagi ma’lumotlaringiz o‘zgarmaydi.';

  @override
  String get supportUnavailableTitle => 'Server hali ulanmagan';

  @override
  String get supportUnavailableBody =>
      'Bu buildda hisoblar, murojaatlar va guruhlar serveri ulanmagan. Ulangach shu yerda ishlaydi.';

  @override
  String get errNetwork => 'Internetga ulanib bo‘lmadi. Qayta urinib ko‘ring.';

  @override
  String get errRateLimited =>
      'Juda ko‘p so‘rov. Birozdan keyin urinib ko‘ring.';

  @override
  String get errInvalidSupport =>
      'Mavzu kamida 3 belgi bo‘lsin, xabar bo‘sh bo‘lmasin.';

  @override
  String get errForbidden => 'Bu amal uchun ruxsat yo‘q.';

  @override
  String get errSessionExpired => 'Sessiya tugagan. Qaytadan kiring.';

  @override
  String get errGeneric => 'Bajarib bo‘lmadi. Qayta urinib ko‘ring.';

  @override
  String get accountDelete => 'Hisobni o‘chirish';

  @override
  String get accountDeleteSub =>
      'Serverdagi hisob, murojaatlar va guruh a’zoligi o‘chadi';

  @override
  String get accountDeleteTitle => 'Hisob o‘chirilsinmi?';

  @override
  String get accountDeleteBody =>
      'Hisobingiz, murojaatlaringiz, biriktirilgan rasmlar va guruh natijalari serverdan butunlay o‘chiriladi. Buni qaytarib bo‘lmaydi. Qurilmadagi QC qaydlari va xatcho‘plar alohida o‘chiriladi.';

  @override
  String get accountDeleted => 'Hisob o‘chirildi';

  @override
  String get adminTitle => 'Admin panel';

  @override
  String get adminSub => 'Statistika, murojaatlar, foydalanuvchilar';

  @override
  String get adminMfaTitle => 'Ikki bosqichli himoya';

  @override
  String get adminMfaEnrollBody =>
      'Admin panel uchun autentifikator ilovasi kerak (Google Authenticator, Microsoft Authenticator, 1Password…). Kalitni ilovaga qo‘shing va u ko‘rsatgan 6 xonali kodni kiriting.';

  @override
  String get adminMfaVerifyBody =>
      'Autentifikator ilovasidagi 6 xonali kodni kiriting.';

  @override
  String get adminMfaSecret => 'Kalit';

  @override
  String get adminMfaCopy => 'Kalitni nusxalash';

  @override
  String get adminMfaOpen => 'Autentifikatorda ochish';

  @override
  String get adminMfaCode => '6 xonali kod';

  @override
  String get adminMfaVerify => 'Tasdiqlash';

  @override
  String get adminMfaWrong =>
      'Kod noto‘g‘ri yoki eskirgan. Ilovadagi yangi kodni kiriting.';

  @override
  String get adminCopied => 'Nusxalandi';

  @override
  String get adminForbiddenTitle => 'Faqat admin uchun';

  @override
  String get adminForbiddenBody =>
      'Admin vakolatini server beradi — ilovadagi rol yoki email buni o‘zgartirmaydi.';

  @override
  String get adminStats => 'Statistika';

  @override
  String get adminRegistered => 'Ro‘yxatdan o‘tgan';

  @override
  String get adminNewToday => 'Bugun yangi';

  @override
  String get adminNew7 => '7 kunda yangi';

  @override
  String get adminNew30 => '30 kunda yangi';

  @override
  String get adminActiveToday => 'Bugun faol';

  @override
  String get adminActive7 => '7 kunda faol';

  @override
  String get adminActive30 => '30 kunda faol';

  @override
  String get adminDefinitions =>
      'Ro‘yxatdan o‘tgan — emailini kod bilan tasdiqlagan hisob; mehmonlar va kodni tasdiqlamaganlar sanalmaydi. Yangi — email birinchi tasdiqlangan kun. Faol — davr ichida ilovani hisobiga kirgan holda kamida bir marta ochgan. Kunlar Toshkent vaqti bo‘yicha; “7 kun” bugun bilan birga.';

  @override
  String get adminByRole => 'Rollar bo‘yicha';

  @override
  String get adminByLanguage => 'Tillar bo‘yicha';

  @override
  String adminNoProfile(int count) {
    return 'Profil hali yaratilmagan: $count';
  }

  @override
  String get adminBilling => 'Free / Pro: billing ulanmagan — ma’lumot yo‘q';

  @override
  String get adminInbox => 'Murojaatlar';

  @override
  String adminAwaiting(int count) {
    return 'Javob kutmoqda: $count';
  }

  @override
  String get adminAllStatuses => 'Hammasi';

  @override
  String get adminUsers => 'Foydalanuvchilar';

  @override
  String get adminAudit => 'Amallar tarixi';

  @override
  String get adminAuditEmpty => 'Hali amal yo‘q';

  @override
  String get adminSearchHint => 'Email bo‘yicha qidirish';

  @override
  String get adminAllRoles => 'Barcha rollar';

  @override
  String get adminAllLanguages => 'Barcha tillar';

  @override
  String get adminShowEmail => 'Emailni ko‘rsatish (jurnalga yoziladi)';

  @override
  String get adminReviewer => 'Kontent tekshiruvchisi (reviewer)';

  @override
  String adminPage(int from, int to, int total) {
    return '$from–$to / $total';
  }

  @override
  String get adminPrev => 'Oldingi';

  @override
  String get adminNext => 'Keyingi';

  @override
  String adminRegisteredOn(String date) {
    return 'Ro‘yxatdan: $date';
  }

  @override
  String adminLastSeen(String date) {
    return 'Oxirgi faollik: $date';
  }

  @override
  String get adminNoUsers => 'Foydalanuvchi topilmadi';

  @override
  String get adminReplyHint => 'Javob matnini o‘zingiz yozing';

  @override
  String get adminSendReply => 'Javob yuborish';

  @override
  String get adminStatus => 'Holat';

  @override
  String get adminRefresh => 'Yangilash';

  @override
  String get adminActionSupportReply => 'Murojaatga javob';

  @override
  String get adminActionSupportStatus => 'Murojaat holati o‘zgardi';

  @override
  String get adminActionRevealEmail => 'Email ko‘rildi';

  @override
  String get adminActionReviewerGranted => 'Reviewer vakolati berildi';

  @override
  String get adminActionReviewerRevoked => 'Reviewer vakolati olindi';

  @override
  String get adminActionAdminGranted => 'Admin vakolati berildi';

  @override
  String get adminActionAdminRevoked => 'Admin vakolati olindi';

  @override
  String get profileSignIn => 'Email orqali kirish';

  @override
  String get profileSignOut => 'Chiqish';

  @override
  String get profileRestartSetup => 'Sozlashni boshidan boshlash';

  @override
  String get profileSignOutTitle => 'Hisobdan chiqilsinmi?';

  @override
  String get profileSignOutBody =>
      'Xatcho‘plar, QC qaydlari, eslatmalar va mashq natijalari shu qurilmada qoladi. Qurilmadan boshqa odam foydalanadigan bo‘lsa, ularni ham o‘chiring.';

  @override
  String get profileSignOutDelete => 'Chiqish va o‘chirish';

  @override
  String profileVersion(String version) {
    return 'Versiya $version';
  }

  @override
  String get purchaseTitle => 'LabGuide Pro';

  @override
  String get purchaseFree => 'Free: demo va bazaviy kartalar.';

  @override
  String get purchasePro =>
      'Pro, oylik yoki yillik: to‘liq nashr etilgan paketlar, kengaytirilgan o‘rganish va laboratoriya vositalari.';

  @override
  String get purchaseNotice =>
      'Do‘kon mahsulotlari ulanmagan. Narxlar App Store / Google Play’dan mahalliy valyutada olinadi. Bu yerda pul yechilmaydi va hali tayyor bo‘lmagan imkoniyat sotilmaydi.';

  @override
  String get purchaseSubscribe => 'Obuna bo‘lish';

  @override
  String get purchaseRestore => 'Xaridni tiklash';

  @override
  String get privacyTitle => 'Maxfiylik va yordam';

  @override
  String get privacyBody =>
      'Mehmon rejimida ilova serverga hech narsa yubormaydi: sozlamalar, xatcho‘plar, QC qaydlari, apparatlaringiz va mashq natijalari shu qurilmada saqlanadi (qurilmaning o‘z zaxira nusxasiga kirishi mumkin). Email bilan kirsangiz — email, rol, til, oxirgi faol kun, murojaatlaringiz va guruh natijalari serverda saqlanadi; reklama va kuzatuv yo‘q. Hisobni istalgan vaqtda o‘chirishingiz mumkin.';

  @override
  String get privacyTerms => 'Foydalanish shartlari';

  @override
  String get privacyTermsSub => 'Yakuniy matn tayyorlanadi';

  @override
  String get privacyDeleteLocal => 'Lokal ma’lumotlarni o‘chirish';

  @override
  String get privacyDeleteLocalSub =>
      'Sozlamalar, xatcho‘plar, qoralamalar, QC qaydlari va mashq natijalari';

  @override
  String get privacyDeleteConfirmTitle => 'Lokal ma’lumotlar o‘chirilsinmi?';

  @override
  String get privacyDeleteConfirmBody =>
      'Shu qurilmadagi sozlamalar, xatcho‘plar, qoralamalar, barcha QC qaydlari (seriyalar va maqsadlar) va mashq natijalari o‘chiriladi. Buni qaytarib bo‘lmaydi — kerak bo‘lsa, avval QC zaxira nusxasini oling (Laboratoriya → Sifat nazorati).';

  @override
  String get privacyDeleted => 'Lokal ma’lumotlar o‘chirildi';

  @override
  String get termsTitle => 'Foydalanish shartlari';

  @override
  String get termsBody =>
      'Yakuniy shartlar, maxfiylik siyosati va klinik foydalanish chegaralari nashrdan oldin tayyorlanadi. LabGuide — ma’lumotnoma va o‘quv vositasi: u tashxis qo‘ymaydi, dori buyurmaydi va laboratoriyangiz tartiblarini almashtirmaydi.';

  @override
  String citePage(String page) {
    return '$page-bet';
  }

  @override
  String get rightsUnknown => 'Tarqatish huquqi tasdiqlanmagan';

  @override
  String get rightsPersonal => 'Faqat shaxsiy o‘rganish uchun — tarqatilmaydi';

  @override
  String get rightsPermitted => 'Tarqatish ruxsati qayd etilgan';

  @override
  String get rightsDenied => 'Tarqatishga ruxsat yo‘q';

  @override
  String get catBiochemistry => 'Biokimyo';

  @override
  String get catClinicalLab => 'Klinik laboratoriya';

  @override
  String get catInstruments => 'Apparatlar';

  @override
  String get catMethods => 'Metodikalar';

  @override
  String get catTests => 'Laboratoriya tahlillari';

  @override
  String get kindBook => 'Kitob';

  @override
  String get kindManual => 'Qo‘llanma';

  @override
  String get kindMethod => 'Metodika';

  @override
  String get kindIfu => 'IFU';

  @override
  String get kindArticle => 'Maqola';

  @override
  String get kindQuestionSet => 'Savollar to‘plami';

  @override
  String get kindWebsite => 'Veb-resurs';

  @override
  String libAccessOpen(String licence) {
    return 'Ochiq litsenziya · $licence';
  }

  @override
  String get libAccessFree => 'Bepul o‘qish · faqat havola';

  @override
  String get libAccessCatalog => 'Faqat katalog yozuvi';

  @override
  String get libOpenSource => 'Rasmiy sahifani ochish';

  @override
  String libChecked(String date) {
    return 'Sahifa va litsenziya tekshirilgan: $date';
  }

  @override
  String libItemPack(String size) {
    return 'Oflayn paket · $size';
  }

  @override
  String get libItemNoPack => 'Umumiy oflayn paket sifatida mavjud emas';

  @override
  String libItemSupersedes(String title) {
    return 'Yangi nashr. Oldingisi: $title';
  }

  @override
  String get libForYou => 'Siz uchun';

  @override
  String get libMoreSections => 'Boshqa bo‘limlar';

  @override
  String get libSearchEntry => 'Kitob, muallif, mavzu qidirish';

  @override
  String libBooksCount(int count) {
    return '$count ta manba · qidiruv va filtrlar';
  }

  @override
  String get libIntake => 'Materiallarni qo‘shish tartibi';

  @override
  String get libIntakeSub =>
      'Domla va muharrir uchun: nima yuboriladi, huquq, tekshiruv';

  @override
  String get libContinueReading => 'O‘qishni davom ettirish';

  @override
  String get libSearchLabel => 'Kutubxonadan qidirish';

  @override
  String get libSearchHint => 'Nomi, muallif, mavzu…';

  @override
  String get libFilterLanguage => 'Til';

  @override
  String get libFilterTopic => 'Mavzu';

  @override
  String get libFilterType => 'Turi';

  @override
  String get libFilterSectionField => 'Yo‘nalish';

  @override
  String get libFilterSectionGroup => 'Tahlillar guruhi';

  @override
  String get libFilterSectionKind => 'Material turi';

  @override
  String get libFilterSectionOpen => 'Qanday ochiladi';

  @override
  String libFilterChoose(String filter) {
    return '$filter: tanlang';
  }

  @override
  String libResultCount(int shown, int total) {
    return '$total ta materialdan $shown tasi';
  }

  @override
  String get libClearFilters => 'Tozalash';

  @override
  String get libFilteredEmptyTitle => 'Bu filtrlar bo‘yicha material yo‘q';

  @override
  String get libFilteredEmptyBody =>
      'Bitta filtrni olib tashlang yoki boshqa so‘z bilan qidiring — masalan, muallif familiyasi yoki “siydik”.';

  @override
  String get libOpenLink => 'Havola · tashqi sayt';

  @override
  String libOpenLinkHint(String host) {
    return 'Brauzerda ochiladi: $host';
  }

  @override
  String get libOpenInApp => 'Ilova ichidagi fayl';

  @override
  String get libOpenInAppHint => 'Ilova ichida o‘qiladi — internet shart emas';

  @override
  String get libOpenDownload => 'Yuklab olinadigan kitob';

  @override
  String libOpenDownloadHint(String size) {
    return 'Yuklab olingach ilova ichida o‘qiladi · $size';
  }

  @override
  String get libOpenPending => 'Kutilmoqda';

  @override
  String get libOpenPendingHint => 'Material hali olinmagan — ochib bo‘lmaydi';

  @override
  String get libOpenReceivedHint =>
      'Fayl qabul qilindi va tekshirilmoqda — hali ochilmaydi';

  @override
  String get libOpenRecordHint =>
      'Faylni tarqatish huquqi qayd etilmagan — ilovada ochilmaydi';

  @override
  String get libOpenLinkShort => 'Havola';

  @override
  String get libOpenInAppShort => 'Ilova ichida';

  @override
  String get libOpenDownloadShort => 'Yuklab olinadigan';

  @override
  String get libOpenRecordShort => 'Faqat yozuv';

  @override
  String get libItemRead => 'O‘qish';

  @override
  String libItemContinue(int page) {
    return '$page-sahifadan davom etish';
  }

  @override
  String get libItemCannotOpen => 'Ochib bo‘lmaydi';

  @override
  String get libDownloadUnavailable =>
      'Yuklab olish serveri hali ulanmagan — kitobni hozircha yuklab bo‘lmaydi.';

  @override
  String get libDetailsTitle => 'Ma’lumotlar';

  @override
  String get libFieldAuthors => 'Muallif';

  @override
  String get libFieldYear => 'Yil';

  @override
  String get libFieldEdition => 'Nashr';

  @override
  String get libFieldPublisher => 'Nashriyot';

  @override
  String get libFieldAccess => 'Kirish';

  @override
  String get libFieldStatus => 'Holat';

  @override
  String get libFieldRights => 'Tarqatish huquqi';

  @override
  String libFieldRightsRecorded(String date, String by) {
    return 'Qayd etilgan: $date · $by';
  }

  @override
  String get libFieldTopics => 'Mavzular';

  @override
  String get libFieldPages => 'Sahifalar';

  @override
  String get libStateNotReceived => 'Hali olinmagan';

  @override
  String get libStateReceived => 'Qabul qilindi, tekshirilmoqda';

  @override
  String get libStateCataloged => 'Kataloglangan';

  @override
  String get libStateLinked => 'Kartalarga bog‘langan';

  @override
  String get libStateReviewed => 'Domla tasdiqlagan';

  @override
  String get libProvidedByTeacher => 'Domla bergan material';

  @override
  String get libItemNotFound => 'Material topilmadi';

  @override
  String get libItemNotFoundBody =>
      'Kontent paketi yangilangan bo‘lishi mumkin. Katalogga qayting.';

  @override
  String get libBackToCatalog => 'Katalogga qaytish';

  @override
  String get readerTitle => 'O‘quvchi';

  @override
  String readerPageOf(int page, int total) {
    return '$page / $total';
  }

  @override
  String get readerToc => 'Mundarija';

  @override
  String get readerTocEmpty => 'Bu faylda mundarija yo‘q';

  @override
  String get readerTocEmptyBody =>
      'Sahifaga o‘ting yoki kerakli joyga xatcho‘p qo‘ying.';

  @override
  String get readerBookmarks => 'Xatcho‘plar';

  @override
  String get readerAddBookmark => 'Shu sahifani belgilash';

  @override
  String get readerBookmarkName => 'Xatcho‘p nomi';

  @override
  String get readerBookmarkNameHint => 'Masalan: muhim jadval';

  @override
  String readerBookmarkSaved(int page) {
    return 'Xatcho‘p saqlandi: $page-sahifa';
  }

  @override
  String get readerBookmarkRemoved => 'Xatcho‘p o‘chirildi';

  @override
  String get readerBookmarkRemove => 'Xatcho‘pni o‘chirish';

  @override
  String get readerBookmarksEmpty => 'Hali xatcho‘p yo‘q';

  @override
  String get readerBookmarksEmptyBody =>
      'Kerakli sahifada “Shu sahifani belgilash”ni bosing — keyin bir bosishda qaytasiz.';

  @override
  String readerPageLabel(int page) {
    return '$page-sahifa';
  }

  @override
  String get readerGoTo => 'Sahifaga o‘tish';

  @override
  String get readerGoToShort => 'Sahifa';

  @override
  String readerGoToHint(int total) {
    return '1 dan $total gacha';
  }

  @override
  String readerGoToError(int total) {
    return '1 dan $total gacha raqam kiriting';
  }

  @override
  String get readerGo => 'O‘tish';

  @override
  String get readerSave => 'Saqlash';

  @override
  String get readerRenameBookmark => 'Xatcho‘p nomini o‘zgartirish';

  @override
  String get libFieldProvidedBy => 'Kimdan';

  @override
  String get libQueryEmptyBody =>
      'Boshqa so‘z bilan qidiring — masalan, muallif familiyasi, “siydik” yoki “biokimyo”.';

  @override
  String get readerZoomIn => 'Kattalashtirish';

  @override
  String get readerZoomOut => 'Kichiklashtirish';

  @override
  String readerResumed(int page) {
    return 'Oxirgi o‘qilgan joy: $page-sahifa';
  }

  @override
  String get readerFromStart => 'Boshidan';

  @override
  String get readerLoading => 'Fayl ochilmoqda…';

  @override
  String get readerFileMissing => 'Fayl topilmadi';

  @override
  String get readerFileMissingBody =>
      'Bu fayl ilova ichida yo‘q. Ilovani yangilab ko‘ring.';

  @override
  String get readerFileCorrupted => 'Fayl tekshiruvdan o‘tmadi';

  @override
  String get readerFileCorruptedBody =>
      'Fayl hajmi yoki nazorat yig‘indisi katalogdagiga mos emas — u buzilgan yoki almashtirilgan bo‘lishi mumkin, shuning uchun ochilmadi.';

  @override
  String get readerOpenFailed => 'PDF ochilmadi';

  @override
  String get readerBlockedTitle => 'Ilova ichida ochilmaydi';

  @override
  String get readerBlockedRights =>
      'Ilovada faqat to‘liq tarqatish huquqi qayd etilgan fayllar ochiladi. Bu material uchun bunday fayl yo‘q.';

  @override
  String get readerBookmarkedPage => 'Bu sahifa belgilangan';

  @override
  String get intakeTitle => 'Materiallarni qo‘shish';

  @override
  String get intakeSubtitle => 'Domla va muharrir uchun qisqa tartib';

  @override
  String intakeStatus(int count) {
    return 'Domlalardan kelgan materiallar: $count. Ro‘yxat material kelishi bilan to‘ldiriladi.';
  }

  @override
  String get intakeWhatTitle => '1. Nima yuboriladi';

  @override
  String get intakeWhat1 =>
      'Kitob, qo‘llanma, metodika yoki IFU fayli (PDF) va uning ma’lumotlari: nomi, muallif, yil va nashr, nashriyot, ISBN, til.';

  @override
  String get intakeWhat2 =>
      'Test savollari: savol, variantlar, to‘g‘ri javob, har variant uchun izoh va manba sahifasi.';

  @override
  String get intakeWhat3 =>
      'Eski va yangi nashr bo‘lsa — ikkalasi ham: farqlar alohida ko‘rib chiqiladi.';

  @override
  String get intakeRightsTitle => '2. Tarqatish huquqi';

  @override
  String get intakeRights1 =>
      'Berilgan PDF o‘z-o‘zidan hammaga tarqatish huquqi degani emas.';

  @override
  String get intakeRights2 =>
      'Fayl ilovada hammaga ochilishi uchun to‘liq huquq qayd etiladi: kim ruxsat bergan (muallif yoki nashriyot), qachon, kim qayd etgan va dalil — ruxsat xati yoki litsenziya havolasi.';

  @override
  String get intakeRights3 =>
      'Qayd bo‘lmasa, material faqat katalog yozuvi yoki shaxsiy foydalanish uchun qoladi.';

  @override
  String get intakeReviewTitle => '3. Qanday tekshiriladi';

  @override
  String get intakeStep1 => 'Kutilmoqda — material hali kelmagan.';

  @override
  String get intakeStep2 => 'Qabul qilindi — fayl keldi va ro‘yxatga yozildi.';

  @override
  String get intakeStep3 =>
      'Kataloglandi — nomi, muallif va nashr tekshirildi. Shundan keyingina undan iqtibos keltiriladi.';

  @override
  String get intakeStep4 =>
      'Bog‘landi — tahlil kartalari va darslarga sahifa raqami bilan bog‘landi.';

  @override
  String get intakeStep5 =>
      'Tasdiqlandi — domla ko‘rib chiqdi. Savollar shungacha “Qoralama” bo‘lib turadi.';

  @override
  String get intakeConflict =>
      'Eski va yangi manba zid bo‘lsa, hech biri fakt sifatida yozilmaydi — ikkala pozitsiya tekshiruvchiga ko‘rsatiladi.';

  @override
  String get intakeNeverTitle => 'Nima qilinmaydi';

  @override
  String get intakeNever1 => 'Kelmagan materialni “mavjud” deb ko‘rsatish.';

  @override
  String get intakeNever2 =>
      'Sahifa raqamini taxmin qilish yoki manbada yo‘q gapni yozish.';

  @override
  String get intakeNever3 => 'Huquqi qayd etilmagan kitobni hammaga tarqatish.';

  @override
  String get intakeContactTitle => '4. Bog‘lanish';

  @override
  String get intakeContactBody =>
      'Material haqida LabGuide jamoasiga yozing: nomi, muallif, nashr va huquq egasi. Faylni topshirish usuli jamoa bilan kelishiladi — ilova orqali PDF yuklab bo‘lmaydi.';

  @override
  String get intakeContactAction => 'LabGuide jamoasiga yozish';

  @override
  String get libReview => 'Tekshiruv navbati';

  @override
  String get libReviewSub => 'Manbalardagi farqlar va qoralamalar';

  @override
  String get reviewDiscrepancies => 'Manbalar orasidagi farqlar';

  @override
  String get rvGateTitle => 'Faqat tekshiruvchilar uchun';

  @override
  String get rvGateBody =>
      'Tekshiruvchi vakolatini admin beradi. Ilovadagi rol (masalan, “Ustoz”) bu huquqni bermaydi.';

  @override
  String get rvSignInTitle => 'Tekshiruv uchun hisobga kiring';

  @override
  String get rvAdminReadOnly =>
      'Admin sifatida qarorlarni ko‘rasiz. Qaror yozish uchun hisobingizga tekshiruvchi vakolatini bering (Admin → Foydalanuvchilar).';

  @override
  String get rvTabCards => 'Kartalar';

  @override
  String get rvTabQuestions => 'Savollar';

  @override
  String get rvTabDiscrepancies => 'Nomuvofiqliklar';

  @override
  String rvMine(String decision) {
    return 'Sizning qaroringiz: $decision';
  }

  @override
  String get rvNotSeen => 'Siz hali ko‘rmagansiz';

  @override
  String rvCount(int count) {
    return 'Qarorlar: $count';
  }

  @override
  String get rvApprove => 'Tasdiqlayman';

  @override
  String get rvChanges => 'O‘zgartirish kerak';

  @override
  String get rvDecisionApprove => 'tasdiqlagan';

  @override
  String get rvDecisionChanges => 'o‘zgartirish so‘ragan';

  @override
  String get rvComment => 'Izoh';

  @override
  String get rvCommentHint =>
      'Nima noto‘g‘ri yoki nimani tekshirish kerak (manba, sahifa)';

  @override
  String get rvCommentRequired => '“O‘zgartirish kerak” uchun izoh yozing.';

  @override
  String get rvSubmit => 'Qarorni yuborish';

  @override
  String get rvSubmitted => 'Qaror yozildi';

  @override
  String get rvNotAuto =>
      'Qaror kartaning holatini o‘zi o‘zgartirmaydi: tahririyat ko‘rib chiqqach, keyingi kontent paketida “Tekshirilgan” bo‘ladi.';

  @override
  String get rvHistory => 'Qarorlar tarixi';

  @override
  String get rvYou => 'Siz';

  @override
  String get rvReviewer => 'Tekshiruvchi';

  @override
  String get rvNoHistory => 'Hali qaror yo‘q';

  @override
  String get rvOpenCard => 'Kartani ochish';

  @override
  String get rvCorrect => 'To‘g‘ri javob';

  @override
  String get rvBasis => 'Asos';

  @override
  String get rvYourDecision => 'Qaroringiz';

  @override
  String get rvAllDone => 'Hammasi ko‘rib chiqilgan';

  @override
  String get analytePreparedBy => 'Tayyorlagan';

  @override
  String get analyteEditorial => 'LabGuide tahririyati';

  @override
  String get analyteSourcesChecked => 'Manbalar ko‘rilgan';

  @override
  String get reviewDiscrepanciesBody =>
      'Eski va yangi manbalar bir-biriga zid bo‘lsa, ikkala pozitsiya mutaxassis tekshiruvi uchun shu yerda ko‘rsatiladi. Hal qilinmaguncha hech biri fakt sifatida nashr etilmaydi.';

  @override
  String get reviewNoDiscrepancies => 'Ochiq farqlar yo‘q.';

  @override
  String reviewDraftQuestions(int count) {
    return 'Qoralama savollar: $count';
  }

  @override
  String reviewDraftCards(int count) {
    return 'Mutaxassis tekshiruvini kutayotgan kartalar: $count';
  }

  @override
  String reviewCatalog(int count) {
    return 'Kataloglangan materiallar: $count';
  }

  @override
  String reviewField(String field) {
    return 'Maydon: $field';
  }

  @override
  String get quizDraftTag => 'Qoralama · tekshirilmagan';

  @override
  String get lessonsTitle => 'Dars mavzulari';
}
