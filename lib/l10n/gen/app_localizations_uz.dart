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
      'Kontentni o‘qish uchun hisob shart emas. Kirish sinxronlash va guruhlar uchun kerak.';

  @override
  String get welcomeBenefitDoctorTitle => 'Shifokor uchun';

  @override
  String get welcomeBenefitDoctorBody =>
      'Natija, unga ta’sir qiluvchi omillar va kasallik bo‘yicha tahlillar';

  @override
  String get welcomeBenefitLabTitle => 'Laboratoriya mutaxassisi uchun';

  @override
  String get welcomeBenefitLabBody =>
      'Sifat nazorati, namuna olish, apparatlar va kalkulyatorlar';

  @override
  String get welcomeBenefitLearnTitle => 'Talaba va ustoz uchun';

  @override
  String get welcomeBenefitLearnBody =>
      'Mavzular, izohli savollar, imtihon va guruhlar';

  @override
  String get stateLoading => 'Yuklanmoqda…';

  @override
  String get homeTileTests => 'Me’yor, sabablar va talqin';

  @override
  String get homeTileCalculators => 'eGFR, ACR, suyultirish va boshqalar';

  @override
  String get homeTileSampling => 'Probirka, saqlash va tashish';

  @override
  String get homeTileSaved => 'Belgilanganlarga tez qaytish';

  @override
  String get homeTileDiff => 'Hisoblagich va hujayralar atlasi';

  @override
  String get homeTileCalibration => 'Apparat, reagent va IFU mosligi';

  @override
  String get homeTileInstruments => 'Ish prinsipi va metodikalar';

  @override
  String get homeTileExam => 'Vaqtli sinov imtihoni';

  @override
  String get homeTileTopics => 'Mavzu, izoh va mashq';

  @override
  String get homeTileClasses => 'Talabalar va topshiriqlar';

  @override
  String get homeTileLecture => 'Taqdimot va ekranga uzatish';

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
  String get roleStudent => 'Talaba';

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
  String get homeHeroDoctorCta => 'Tahlilni qidirish';

  @override
  String get condGuideTitle => 'Kasallik bo‘yicha tahlillar';

  @override
  String get condGuideEyebrow => 'Shifokor qo‘llanmasi';

  @override
  String get condGuideBody =>
      'Har bir holat uchun: avval qaysi tahlil, keyin qaysi — va natija nimaga ishora qilishi mumkin.';

  @override
  String get condGuideSearch => 'Kasallik yoki tahlilni qidiring…';

  @override
  String get condGuideAll => 'Barcha holatlar';

  @override
  String condCount(int count) {
    return '$count ta holat';
  }

  @override
  String condSystemCount(int count) {
    return '$count ta tizim';
  }

  @override
  String get condListSubtitle =>
      'Qaysi holatda qaysi tahlil — va natija nimaga ishora qilishi mumkin';

  @override
  String get condSearchLabel => 'Holatlarni qidirish';

  @override
  String get condSearchHint => 'Diabet, anemiya, qalqonsimon bez, TSH…';

  @override
  String get condEmptyTitle => 'Holat topilmadi';

  @override
  String get condEmptyBody =>
      'Boshqa nom, so‘zlashuv nomi yoki tahlil nomi bilan qidiring (masalan, «qand kasalligi»).';

  @override
  String get condTierFirstLine => 'Birinchi navbatda';

  @override
  String get condTierAdditional => 'Qo‘shimcha';

  @override
  String get condTierMonitoring => 'Kuzatuv';

  @override
  String get condTierFirstLineHint =>
      'Holat shubha qilinganda avval buyuriladi';

  @override
  String get condTierAdditionalHint =>
      'Aniqlashtirish, sababni izlash yoki farqlash uchun';

  @override
  String get condTierMonitoringHint =>
      'Tashxisdan keyin yoki davolash davomida';

  @override
  String get condPatternsTitle => 'Natija naqshlari';

  @override
  String get condPatternsHint =>
      '«Mana bu chiqsa — mana bu ehtimoli bor». Talqin ehtimoliy: yakuniy xulosani shifokor klinik ma’lumotlar bilan birga chiqaradi.';

  @override
  String get condNotDiagnosticTitle => 'Tashxis qo‘yish vositasi emas';

  @override
  String get condNotDiagnosticBody =>
      'Qo‘llanma tahlillarni rejalashtirishga yordam beradi. Klinik baholash va yakuniy qaror — shifokorda. Matn manbalarga asoslangan, manbalar har kartada ko‘rsatilgan.';

  @override
  String get condCautionsTitle => 'E’tibor bering';

  @override
  String get condNoCard => 'Karta hali yo‘q';

  @override
  String get condCopyList => 'Tahlillar ro‘yxatini nusxalash';

  @override
  String get condCopyListSub => 'Yo‘llanma yoki xabar uchun tayyor matn';

  @override
  String get condCopied => 'Ro‘yxat nusxalandi';

  @override
  String condReferralTitle(String name) {
    return '$name — tahlillar';
  }

  @override
  String get condReferralFooter =>
      'LabGuide qo‘llanmasi. Tashxis vositasi emas — yakuniy qaror shifokorda.';

  @override
  String get condAnalyteSection => 'Qaysi holatlarda tekshiriladi';

  @override
  String get condTestsEntrySub =>
      'Holatni tanlang — kerakli tahlillar va natija naqshlari';

  @override
  String get condSearchSection => 'Holatlar';

  @override
  String condRowFirstLine(String tests) {
    return 'Avval: $tests';
  }

  @override
  String get condSysEndocrine => 'Endokrin tizim';

  @override
  String get condSysKidney => 'Buyrak va siydik yo‘llari';

  @override
  String get condSysLiver => 'Jigar va o‘t yo‘llari';

  @override
  String get condSysDigestive => 'Oshqozon osti bezi va ichak';

  @override
  String get condSysCardio => 'Yurak va qon tomirlar';

  @override
  String get condSysBlood => 'Qon va qon ivishi';

  @override
  String get condSysInfection => 'Infeksiyalar';

  @override
  String get condSysRheumatology => 'Revmatologiya';

  @override
  String get condSysBone => 'Suyak va kalsiy almashinuvi';

  @override
  String get condSysPregnancy => 'Homiladorlik va reproduktiv salomatlik';

  @override
  String get condSysProstate => 'Prostata';

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
  String get homeHeroStudentCta => 'Kunlik savollarni boshlash';

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
  String get featureSaved => 'Saqlanganlar';

  @override
  String get featureCalibration => 'Kalibrlash';

  @override
  String get featureQc => 'Sifat nazorati (QC)';

  @override
  String get featureTopics => 'Mavzular';

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
  String get statusVerified => 'Tekshirilgan';

  @override
  String get statusPublished => 'Nashr etilgan';

  @override
  String get statusSourcedSample => 'Manbalarga asoslangan';

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
      'Bu kartada hozircha faqat tuzilma bor. Klinik matn manbalar bilan birga qo‘shiladi — umumiy matn tayyor deb ko‘rsatilmaydi.';

  @override
  String get analyteNotWritten =>
      'Hali yozilmagan: matn manbalar bilan birga qo‘shiladi.';

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
  String get analyteReview => 'Tayyorlanishi va manbalar';

  @override
  String get analyteReviewPending => 'Mutaxassis tekshiruvi kutilmoqda';

  @override
  String get analyteReviewApproved => 'Tekshirilgan';

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
  String get sectionResults => 'Natija nimani bildiradi';

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
  String get labHeroEyebrow => 'Apparat → reagent → usul';

  @override
  String get labHeroTitle => 'Kalibrlash';

  @override
  String get labSectionsTitle => 'Bo‘limlar va atlaslar';

  @override
  String get labToolsTitle => 'Ish vositalari';

  @override
  String get labHeroBody => 'Aniq modelga mos yo‘riqnoma va nazorat.';

  @override
  String get labHeroCta => 'Kalibrlashni ochish';

  @override
  String get labQcSub => 'Nazorat kartalari va qoidalar';

  @override
  String get labPreanalytics => 'Preanalitika';

  @override
  String get labPreanalyticsSub => 'Namunani olish, saqlash va tashish';

  @override
  String get labCalculatorsSub => 'eGFR, ACR, suyultirish va boshqalar';

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
  String get qcJumpToAddRun => 'Seriya kiritish — pastda';

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
  String get qcGuidesTitle => 'Yo‘riqnomalar';

  @override
  String get qgRejected => 'QC rad etilsa nima qilish';

  @override
  String get qgRejectedSub => 'To‘xtatish, sabab izlash, qayta tekshirish';

  @override
  String get qgEqa => 'Tashqi sifat nazorati (EQA)';

  @override
  String get qgEqaSub => 'Nima u, qanday ishlaydi, natija yomon bo‘lsa';

  @override
  String get qgCritical => 'Kritik qiymatlar';

  @override
  String get qgCriticalSub => 'Ro‘yxatni kim tuzadi va qanday xabar beriladi';

  @override
  String get qgWhatToDo => 'Nima qilish kerak?';

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
  String get preTitle => 'Preanalitika';

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
      'Probirka rangi, vaqt va harorat aniq probirka, metod va yo‘riqnomaga bog‘lanadi. Yuqoridagi muddatlar — JSST jadvalidan umumiy yo‘naltirish; laboratoriyangiz qoidasi ustun.';

  @override
  String get diffTitle => 'Leykoformula';

  @override
  String get diffSubtitle => 'Hujayralarni tanish, sanash, talqin';

  @override
  String get diffLabCardBody =>
      'Qo‘lda sanash hisoblagichi, hujayralar atlasi va talqin';

  @override
  String get diffHeroTitle => 'Leykoformulani ishonch bilan o‘qing';

  @override
  String get diffHeroBody =>
      'Hujayralar sxemasi, katta tugmali hisoblagich, talqin va surtma texnikasi — bir joyda.';

  @override
  String get diffStartCount => 'Sanashni boshlash';

  @override
  String diffResumeCount(int count, int target) {
    return 'Sanashni davom ettirish ($count/$target)';
  }

  @override
  String get diffCellsTitle => 'Hujayralarni tanish';

  @override
  String diffCellsSub(int count) {
    return '$count ta hujayra: o‘lcham, yadro, sitoplazma, donachalar';
  }

  @override
  String get diffConfusionsTitle => 'Ko‘p adashtiriladiganlar';

  @override
  String get diffConfusionsSub =>
      'Reaktiv limfotsit yoki monotsit? Tayoqcha yoki segment?';

  @override
  String get diffCounterTitle => 'Sanash hisoblagichi';

  @override
  String get diffCounterSub =>
      'Bosish +1, uzoq bosish −1; 100 yoki 200 hujayra';

  @override
  String get diffHistoryTitle => 'Saqlangan natijalar';

  @override
  String diffHistorySub(int count) {
    return '$count ta natija — faqat shu qurilmada';
  }

  @override
  String get diffInterpretTitle => 'Talqin';

  @override
  String get diffInterpretSub =>
      'Chapga siljish, neytrofiliya, limfotsitoz va boshqalar';

  @override
  String get diffTechniqueTitle => 'Surtma texnikasi va xatolar';

  @override
  String get diffTechniqueSub => 'Tayyorlash, bo‘yash, qayerda sanash';

  @override
  String get diffQuizTitle => '“Bu qaysi hujayra?” mashqi';

  @override
  String diffQuizSub(int count) {
    return '$count ta savol, sxematik rasmlar bilan';
  }

  @override
  String get diffLearnSub =>
      'Hujayralar atlasi, hisoblagich va “Bu qaysi hujayra?” mashqi';

  @override
  String get diffSourcesTitle => 'Manbalar';

  @override
  String get diffSchematicCaption =>
      'Sxematik rasm (LabGuide chizgan) — mikrofoto emas';

  @override
  String get diffScaleNote =>
      'Barcha sxemalar bir xil masshtabda; atrofdagi eritrotsitlar (~7,5 mkm) o‘lchamni taqqoslash uchun.';

  @override
  String get diffRelatedCards => 'Tahlil kartalari';

  @override
  String get diffSize => 'O‘lcham';

  @override
  String get diffNucleus => 'Yadro';

  @override
  String get diffCytoplasm => 'Sitoplazma';

  @override
  String get diffGranules => 'Donachalar';

  @override
  String get diffKeySign => 'Asosiy belgi';

  @override
  String get diffSeenIn => 'Qachon uchraydi';

  @override
  String get diffReferTitle => 'Shifokor yoki gematologga yuboring';

  @override
  String get diffReferBody =>
      'Blast yoki aniqlab bo‘lmagan hujayra ko‘rsangiz — o‘zingiz talqin qilmang. Surtmani laboratoriyangiz tartibiga ko‘ra gematolog yoki shifokor ko‘rib chiqsin.';

  @override
  String get diffCompareA => 'Chapda';

  @override
  String get diffCompareB => 'O‘ngda';

  @override
  String get diffFeature => 'Belgi';

  @override
  String get diffTip => 'Maslahat';

  @override
  String get diffOpenCell => 'Batafsil';

  @override
  String get diffTargetLabel => 'Nechta hujayra sanaladi';

  @override
  String get diffWbcLabel => 'Leykotsitlar (WBC), ×10⁹/L — ixtiyoriy';

  @override
  String get diffWbcHint => 'masalan, 7,5';

  @override
  String get diffWbcInvalid => 'Musbat son kiriting (masalan, 7,5)';

  @override
  String get diffTapHint => 'Bosish: +1 · Uzoq bosish: −1';

  @override
  String get diffUndo => 'Oxirgisini bekor qilish';

  @override
  String get diffReset => 'Qaytadan';

  @override
  String get diffResetTitle => 'Sanash tozalansinmi?';

  @override
  String diffResetBody(int count) {
    return '$count ta sanalgan hujayra o‘chadi.';
  }

  @override
  String get diffResetConfirm => 'Tozalash';

  @override
  String diffDoneTitle(int target) {
    return '$target ta hujayra sanaldi';
  }

  @override
  String get diffDoneBody =>
      'Sanash to‘xtatildi. Natijani tekshiring, saqlang yoki nusxalang.';

  @override
  String get diffBlocked => 'Maqsadga yetildi — bosish qo‘shilmadi';

  @override
  String get diffResultTitle => 'Natija';

  @override
  String get diffColCell => 'Hujayra';

  @override
  String get diffColCount => 'Soni';

  @override
  String get diffColAbs => '×10⁹/L';

  @override
  String get diffAbsNeedWbc => 'Mutlaq sonlar uchun WBC ni kiriting.';

  @override
  String get diffOtherWarning =>
      '“Boshqa” hujayralar sanaldi. Blast yoki noma’lum hujayra bo‘lsa — surtmani gematolog yoki shifokor ko‘rsin.';

  @override
  String get diffSave => 'Tarixga saqlash';

  @override
  String get diffSaved => 'Natija saqlandi (faqat shu qurilmada)';

  @override
  String get diffLabelField => 'Namuna belgisi (ixtiyoriy, bemor ismisiz)';

  @override
  String get diffLabelHint => 'masalan, 12-namuna';

  @override
  String get diffCopy => 'Nusxalash';

  @override
  String get diffCopied => 'Natija nusxalandi';

  @override
  String diffCopyHeader(int total) {
    return 'Leykoformula ($total ta hujayra)';
  }

  @override
  String get diffCopyFooter =>
      'LabGuide · qo‘lda sanash. Referens — laboratoriya blankasida.';

  @override
  String diffWbcLine(String value) {
    return 'WBC: $value ×10⁹/L';
  }

  @override
  String diffButtonSemantics(String cell, int count) {
    return '$cell: $count. Bosing — qo‘shish, uzoq bosing — ayirish.';
  }

  @override
  String get diffDecrementAction => 'Bittaga kamaytirish';

  @override
  String get diffEfEntry => 'Mikroskop rejimi: ko‘rmasdan sanash';

  @override
  String get diffEfEntrySub =>
      'Ekran katta zonalarga bo‘linadi; har bosishda tovush va tebranish';

  @override
  String get diffEfTitle => 'Ko‘rmasdan sanash';

  @override
  String get diffEfExit => 'Chiqish';

  @override
  String get diffEfUndoZone => 'Bekor qilish';

  @override
  String get diffEfUndoHint => 'yoki ikki barmoq bilan bosing';

  @override
  String diffEfZoneSemantics(String cell, int count, int total, int target) {
    return '$cell: $count. Jami $total / $target.';
  }

  @override
  String diffEfAnnounce(String cell, int count, int total) {
    return '$cell $count. Jami $total';
  }

  @override
  String diffEfUndone(String cell, int total) {
    return 'Bekor qilindi: $cell. Jami $total';
  }

  @override
  String get diffEfNothingToUndo => 'Bekor qiladigan bosish yo‘q';

  @override
  String get diffEfShowResult => 'Natijani ko‘rish';

  @override
  String get diffEfVoiceOn => 'Ovozli buyruqlarni yoqish';

  @override
  String get diffEfVoiceOff => 'Ovozli buyruqlarni to‘xtatish';

  @override
  String get diffEfSettingsTitle => 'Mikroskop rejimi';

  @override
  String get diffEfSettingsSub => 'Mikroskopdan ko‘z uzmasdan sanash uchun';

  @override
  String get diffEfStart => 'Sanashni boshlash';

  @override
  String get diffEfHowTitle => 'Qanday ishlaydi';

  @override
  String get diffEfHowBody =>
      'Telefonni stolga qo‘ying va mikroskopdan ko‘z uzmasdan zonalarni bosing. Har bosishda qisqa tovush va hujayra turiga xos tebranish; har 10-hujayrada — ikki tonli signal va uzun tebranish; maqsadga (100 yoki 200) yetganda — uch notali signal va sanash to‘xtaydi. Sanash oddiy hisoblagich bilan umumiy.';

  @override
  String get diffEfZonesTitle => 'Zonalar';

  @override
  String get diffEfHandLabel => 'Qaysi qo‘l bilan bosasiz';

  @override
  String get diffEfHandRight => 'O‘ng qo‘l';

  @override
  String get diffEfHandLeft => 'Chap qo‘l';

  @override
  String get diffEfHandHint =>
      '1-zona bosh barmoqqa eng yaqin — pastki burchakda.';

  @override
  String get diffEfOtherZone => '“Boshqa (blast…)” zonasi';

  @override
  String get diffEfOtherZoneSub => 'O‘chirilsa — 6 ta zona, har biri kattaroq';

  @override
  String get diffEfUndoSwitch => 'Tepada katta “Bekor” zonasi';

  @override
  String get diffEfUndoSwitchSub =>
      'Ikki barmoq bilan bosish har doim oxirgi bosishni bekor qiladi';

  @override
  String get diffEfOrderTitle => 'Zonalar tartibi';

  @override
  String get diffEfOrderHint =>
      '1 — bosh barmoqqa eng yaqin zona. Ko‘p uchraydigan hujayralarni yuqoriga qo‘ying.';

  @override
  String diffEfMoveUp(String cell) {
    return 'Yuqoriga: $cell';
  }

  @override
  String diffEfMoveDown(String cell) {
    return 'Pastga: $cell';
  }

  @override
  String get diffEfSignalsTitle => 'Signallar';

  @override
  String get diffEfSound => 'Tovush';

  @override
  String get diffEfSoundSub => 'Balandligi telefon ovozi bilan boshqariladi';

  @override
  String get diffEfHaptics => 'Tebranish';

  @override
  String get diffEfHapticsSub =>
      'Telefon sozlamalarida tebranish o‘chirilgan bo‘lsa sezilmaydi';

  @override
  String get diffEfPatternsTitle => 'Tebranish naqshlari';

  @override
  String get diffEfPatternsHint =>
      'Qatorni bosib sinab ko‘ring. Sezilishi telefon modeliga bog‘liq.';

  @override
  String diffEfPattern(int count, String strength) {
    return '$count × $strength';
  }

  @override
  String get diffEfPulseLight => 'yengil';

  @override
  String get diffEfPulseMedium => 'o‘rtacha';

  @override
  String get diffEfPulseHeavy => 'kuchli';

  @override
  String get diffEfPatternTen => 'Har 10-hujayra';

  @override
  String get diffEfPatternTenDesc => '+ uzun tebranish';

  @override
  String get diffEfPatternDone => 'Maqsadga yetildi';

  @override
  String get diffEfPatternDoneDesc => '2 × kuchli + uzun';

  @override
  String get diffEfPatternUndoDesc => 'kuchli + qisqa';

  @override
  String get diffEfScreenTitle => 'Ekran';

  @override
  String get diffEfAwake => 'Ekranni yoqiq ushlash';

  @override
  String get diffEfAwakeSub =>
      'Sanash paytida ekran o‘chmaydi — batareya tezroq sarflanadi';

  @override
  String get diffVoiceTitle => 'Ovoz bilan sanash';

  @override
  String get diffVoiceExperimental => 'Eksperimental';

  @override
  String get diffVoiceSwitch => 'Ovozli buyruqlar';

  @override
  String get diffVoiceSwitchSub =>
      'Hujayra nomini ayting — +1; “bekor” — oxirgi bosishni bekor qiladi';

  @override
  String get diffVoiceLangLabel => 'Buyruqlar tili';

  @override
  String get diffVoiceLangAuto => 'Avtomatik';

  @override
  String get diffVoiceLangUz => 'O‘zbekcha';

  @override
  String get diffVoiceLangRu => 'Ruscha';

  @override
  String get diffVoiceLangEn => 'Inglizcha';

  @override
  String get diffVoiceLangHint =>
      'Avtomatik: ilova tili qurilmada mavjud bo‘lmasa — rus, keyin ingliz tili. O‘zbek tili Apple diktovka tillari ro‘yxatida yo‘q; Android’da qurilmaga bog‘liq.';

  @override
  String get diffVoiceWordsTitle => 'Qaysi so‘zlarni aytish kerak';

  @override
  String get diffVoicePrivacyTitle => 'Ovoz qayerda qayta ishlanadi';

  @override
  String get diffVoicePrivacyIos =>
      'iOS: nutq faqat qurilmada tanilishi talab qilinadi. Bu til uchun qurilmada tanish bo‘lmasa, rejim ishlamaydi — ovoz serverga yuborilmaydi. LabGuide ovozni saqlamaydi va hech qayerga yubormaydi.';

  @override
  String get diffVoicePrivacyAndroid =>
      'Android: nutq faqat telefonning o‘zida (oflayn) tanilganda ishlaydi — Android 12+ va qurilmada oflayn tanish kerak. Bo‘lmasa rejim yoqilmaydi, ovoz serverga yuborilmaydi. LabGuide ovozni saqlamaydi va hech qayerga yubormaydi.';

  @override
  String get diffVoiceNoNames =>
      'Faqat hujayra nomlarini ayting — bemor ismi yoki boshqa ma’lumotlarni aytmang.';

  @override
  String get diffVoiceAccuracy =>
      'Tanish aniqligi shovqin, talaffuz va qurilmaga bog‘liq. Har buyruqdan keyin signalni tinglang; xato bo‘lsa “bekor” deng. Natijani saqlashdan oldin tekshiring.';

  @override
  String get diffVoiceConsentTitle => 'Ovozli buyruqlarni yoqasizmi?';

  @override
  String get diffVoiceConsentAction => 'Tushundim, yoqish';

  @override
  String get diffVoiceStarting => 'Mikrofon ishga tushmoqda…';

  @override
  String diffVoiceListening(String lang) {
    return 'Tinglanmoqda · $lang';
  }

  @override
  String diffVoiceFallback(String lang) {
    return 'Ilova tili uchun qurilmada nutqni tanish topilmadi — so‘zlarni shu tilda ayting: $lang.';
  }

  @override
  String diffVoiceHeard(String text) {
    return 'Eshitildi: «$text»';
  }

  @override
  String diffVoiceNotUnderstood(String text) {
    return 'Buyruq topilmadi: «$text»';
  }

  @override
  String get diffVoicePermissionDenied =>
      'Mikrofon yoki nutqni tanishga ruxsat berilmagan, shuning uchun ovozli buyruqlar ishlamaydi. Ruxsatni telefon sozlamalarida LabGuide uchun berish mumkin. Zonalar bilan sanash ishlayveradi.';

  @override
  String get diffVoiceUnavailable =>
      'Bu qurilmada nutqni tanish xizmati mavjud emas. Zonalar bilan sanash ishlayveradi.';

  @override
  String get diffVoiceLanguageUnavailable =>
      'Tanlangan til uchun qurilmada nutqni tanish yo‘q. Sozlamalarda boshqa tilni tanlang.';

  @override
  String get diffVoiceOnDeviceUnavailable =>
      'Qurilmada (oflayn) nutqni tanish yo‘q. Ovoz serverga yuborilmasligi uchun ovozli buyruqlar o‘chirildi.';

  @override
  String get diffVoiceFailed => 'Nutqni tanish to‘xtadi. Qayta urinib ko‘ring.';

  @override
  String get diffVoiceRetry => 'Qayta urinish';

  @override
  String get diffHistoryEmptyTitle => 'Hali saqlangan natija yo‘q';

  @override
  String get diffHistoryEmptyBody =>
      'Sanashni tugatib, “Tarixga saqlash” ni bosing.';

  @override
  String get diffHistoryClear => 'Hammasini o‘chirish';

  @override
  String get diffHistoryClearTitle => 'Tarix o‘chirilsinmi?';

  @override
  String diffHistoryClearBody(int count) {
    return '$count ta natija shu qurilmadan o‘chadi.';
  }

  @override
  String get diffDeleted => 'Natija o‘chirildi';

  @override
  String get diffHistoryLocalNote =>
      'Natijalar faqat shu qurilmada saqlanadi va serverga yuborilmaydi. Profil → “Lokal ma’lumotlarni o‘chirish” ularni ham o‘chiradi.';

  @override
  String get diffInterpretIntro =>
      'Talqin doim referens oraliq va klinik holat bilan birga qilinadi. Referens — laboratoriyangiz blankasida; quyidagi sabablar faqat ehtimoliy, tashxis emas.';

  @override
  String get diffPossibleCauses => 'Ehtimoliy sabablar';

  @override
  String get diffAbsNote =>
      'Bitta tur keskin ko‘paysa, boshqalarning foizi kamayadi. Shuning uchun mutlaq sonlarga (ulush × WBC) qarang.';

  @override
  String get diffRangesTitle => 'Nega ilova “me’yor” bermaydi?';

  @override
  String get diffRangesBody =>
      'Ochiq manbalar va MDH darsligida kattalar uchun misol oraliqlar (%) turlicha. Hisobotda faqat laboratoriyangiz blankasidagi referens ishlatiladi; bolalar uchun oraliqlar yoshga qarab boshqacha.';

  @override
  String get diffRangesWho => 'JSST 2003';

  @override
  String get diffRangesMedline => 'MedlinePlus';

  @override
  String get diffRangesClassic => 'MDH darsligi (1984)';

  @override
  String get diffRangesClassicNote =>
      'Klassik (MDH darsliklari) oraliqlar faqat solishtirish uchun berilgan: ular hanuz ko‘p blankalarda uchraydi, lekin manbalar bir-biridan farq qiladi. Asosiy mezon — laboratoriyangiz blankasidagi referens.';

  @override
  String get refTitle => 'Jadvallar va algoritmlar';

  @override
  String get refSub =>
      'Anemiya, sariqlik, jigar sindromlari, parazitlar, eskirgan usullar';

  @override
  String get refIntro =>
      'Kitoblar va rasmiy manbalarga asoslangan qisqa jadvallar. Har bo‘lim ostida manbalar ko‘rsatilgan.';

  @override
  String get refOpenSub => 'Jadval va algoritm';

  @override
  String get refNotFound => 'Bunday jadval topilmadi.';

  @override
  String get analyteReuseCitationOnly =>
      'Kitob: faqat manba sifatida keltirilgan, matn ko‘chirilmagan';

  @override
  String get diffQuizPrompt => 'Bu qaysi hujayra?';

  @override
  String get diffQuizIntro =>
      'Sxematik rasmga qarab hujayrani tanlang. Savollar har safar aralashtiriladi; javobdan keyin farqlovchi belgi ko‘rsatiladi.';

  @override
  String get diffQuizStart => 'Mashqni boshlash';

  @override
  String get diffRealSmear => 'Haqiqiy surtma';

  @override
  String get diffRealSmearNote =>
      'Mikroskopiya atlasidagi litsenziyali mikrofoto. Muallif va litsenziya — rasmni ochganda.';

  @override
  String get diffAtlasRow => 'Haqiqiy qon surtmalari';

  @override
  String get diffAtlasRowSub =>
      'Mikroskopiya atlasidagi litsenziyali mikrofotolar';

  @override
  String diffQuizExtended(int count) {
    return 'Kengaytirilgan mashq ($count ta savol)';
  }

  @override
  String get diffQuizExtendedIntro =>
      'Rasmli savollarga qo‘shimcha: yadro, sitoplazma va donachalar tavsifidan hujayrani toping.';

  @override
  String get diffQuizDescribed => 'Tavsifga ko‘ra bu qaysi hujayra?';

  @override
  String diffHistoryMore(int count) {
    return 'Yana $count ta natija qurilmada saqlangan';
  }

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
  String get prePatientTitle => 'Bemor tayyorgarligi';

  @override
  String get preTubeForTestTitle => 'Qaysi tahlilga qaysi probirka';

  @override
  String get preTubeForTestSub =>
      'Rang va o‘rin — yuqoridagi JSST tartibidan. Probirka turlari laboratoriyada farq qilishi mumkin.';

  @override
  String preTubeSlot(String tube, int n) {
    return '$tube · tartibda $n-o‘rin';
  }

  @override
  String get preTubeNone => 'Alohida probirka — JSST tartibida yo‘q';

  @override
  String get preMixTitle => 'Probirkani aralashtirish';

  @override
  String get preStabilityTitle => 'Namuna barqarorligi';

  @override
  String get preStabilitySub =>
      'Ajratilgan zardob yoki plazma qancha saqlanadi (JSST, WHO/DIL/LAB/99.1). Laboratoriyangiz va reagent yo‘riqnomasi ustun.';

  @override
  String get preStabilityRoom => '20–25 °C (xona)';

  @override
  String get preStorageTitle => 'Saqlash qoidalari';

  @override
  String get preUrgentTitle => 'Saqlab bo‘lmaydi — darhol tekshiriladi';

  @override
  String get preBooksNote =>
      'Darsliklar (Selivanov 2005, Aripova 2007, Lyubina 1984) — qo‘shimcha manba. Raqamlar faqat JSST yoki MedlinePlus tasdiqlaganda ko‘rsatiladi.';

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
  String get calcSectionManual => 'Qo‘lda usullar';

  @override
  String get mcChamber => 'Hisob kamerasi';

  @override
  String get mcChamberSub => 'Goryayev, Neubauer: hujayra/µL va ×10⁹/L';

  @override
  String get mcDiff => 'Leykoformula: mutlaq sonlar';

  @override
  String get mcDiffSub => 'WBC × %, yadroli eritrotsitlar bo‘yicha tuzatish';

  @override
  String get mcRetic => 'Retikulotsitlar';

  @override
  String get mcReticSub => '%, tuzatilgan % va RPI';

  @override
  String get mcLight => 'Light mezonlari';

  @override
  String get mcLightSub => 'Plevra suyuqligi: ekssudat yoki transsudat';

  @override
  String get mcColour => 'Rang ko‘rsatkichi';

  @override
  String get mcColourSub => 'Nega ilova MCH va MCHC ni tavsiya qiladi';

  @override
  String get mcNechiporenko => 'Nechiporenko usuli';

  @override
  String get mcNechiporenkoSub =>
      '1 ml siydikdagi leykotsit, eritrotsit va silindrlar';

  @override
  String get mcAddis => 'Kakovskiy–Addis usuli';

  @override
  String get mcAddisSub => 'Sutkada siydik bilan chiqadigan shaklli elementlar';

  @override
  String get mcZimnitsky => 'Zimnitskiy sinamasi';

  @override
  String get mcZimnitskySub => 'Kunduzgi va tungi diurez, zichlik amplitudasi';

  @override
  String get mcClassicTag => 'MDH klassik usuli';

  @override
  String get mcClassicTitle => 'Klassik darslik oraliqlari';

  @override
  String get mcClassicNote =>
      'Bu referens interval, diagnostik chegara emas. Laboratoriyangiz blankasidagi oraliq asosiy; natija bu oraliq bilan avtomatik solishtirilmaydi.';

  @override
  String get mfCells => 'Sanalgan hujayralar';

  @override
  String get mfSquares => 'Sanalgan kvadratlar soni';

  @override
  String get mfSquareArea => 'Bitta kvadrat maydoni';

  @override
  String get mfDepth => 'Kamera chuqurligi';

  @override
  String get mfDilution => 'Suyultirish darajasi (1:20 uchun — 20)';

  @override
  String get mfWbc => 'Leykotsitlar (WBC)';

  @override
  String get mfSeg => 'Segment yadroli neytrofillar';

  @override
  String get mfBand => 'Tayoqcha yadroli neytrofillar';

  @override
  String get mfEos => 'Eozinofillar';

  @override
  String get mfBaso => 'Bazofillar';

  @override
  String get mfLymph => 'Limfotsitlar';

  @override
  String get mfMono => 'Monotsitlar';

  @override
  String get mfOther => 'Boshqa hujayralar';

  @override
  String get mfNrbc => 'Yadroli eritrotsitlar, 100 leykotsitga';

  @override
  String get mfReticCounted => 'Sanalgan retikulotsitlar';

  @override
  String get mfRbcExamined => 'Ko‘rilgan eritrotsitlar';

  @override
  String get mfHct => 'Gematokrit (Ht)';

  @override
  String get mfRbc => 'Eritrotsitlar (RBC)';

  @override
  String get mfMaturation => 'Yetilish koeffitsiyenti';

  @override
  String get mfMaturationAuto => 'Avto';

  @override
  String get mfPfProtein => 'Suyuqlik: umumiy oqsil';

  @override
  String get mfSerumProtein => 'Zardob: umumiy oqsil';

  @override
  String get mfPfLdh => 'Suyuqlik: LDH';

  @override
  String get mfSerumLdh => 'Zardob: LDH';

  @override
  String get mfLdhUln => 'Zardob LDH ning yuqori chegarasi';

  @override
  String get mfLeukoCounted => 'Leykotsitlar (A, sanalgan)';

  @override
  String get mfEryCounted => 'Eritrotsitlar (A, sanalgan)';

  @override
  String get mfCastsCounted => 'Silindrlar (A, sanalgan)';

  @override
  String get mfUrineCentrifuged => 'Sentrifugalangan siydik, ml';

  @override
  String get mfCountedVolume => 'Sanalgan to‘r';

  @override
  String get mfGoryaevWhole => 'Goryaev, butun to‘r — 0,9 µL';

  @override
  String get mfGoryaev100 => 'Goryaev, 100 katta kvadrat — 0,4 µL';

  @override
  String get mfFuchsWhole => 'Fuchs–Rosenthal, butun to‘r — 3,2 µL';

  @override
  String get mfSediment => 'Qoldirilgan cho‘kma';

  @override
  String get mfCollected => 'Yig‘ilgan siydik, ml';

  @override
  String get mfCollectHours => 'Yig‘ish vaqti, soat';

  @override
  String mfPortion(int n, String time) {
    return '$n-porsiya ($time), ml';
  }

  @override
  String mfPortionSg(int n) {
    return '$n-porsiya, zichlik';
  }

  @override
  String get mfFluidIntake => 'Sutkada ichilgan suyuqlik, ml';

  @override
  String get mfZimDay => 'Kunduzgi porsiyalar (1–4)';

  @override
  String get mfZimNight => 'Tungi porsiyalar (5–8)';

  @override
  String get mfSameUnit =>
      'Juftlikdagi ikki qiymat bir xil birlikda bo‘lsin (masalan, ikkalasi g/L, ikkalasi U/L).';

  @override
  String get mrCellsPerUl => 'hujayra/µL';

  @override
  String get mrVolume => 'Sanalgan hajm';

  @override
  String get mrWbcUsed => 'Tuzatilgan WBC';

  @override
  String get mrNrbc => 'Yadroli eritrotsitlar';

  @override
  String get mrPercentSum => 'Foizlar yig‘indisi';

  @override
  String get mrAbsolute => 'Mutlaq sonlar';

  @override
  String get mrNoCorrection =>
      'Yadroli eritrotsitlar kiritilmagan — WBC tuzatilmadi.';

  @override
  String get mrReticAbs => 'Mutlaq son';

  @override
  String get mrReticCorrected => 'Tuzatilgan %';

  @override
  String get mrRpi => 'Retikulotsit ishlab chiqarish indeksi (RPI)';

  @override
  String mrMaturationAuto(String factor, String hct) {
    return 'Koeffitsiyent $factor: Ht $hct % ga eng yaqin jadval nuqtasi (ilova qoidasi).';
  }

  @override
  String mrMaturationChosen(String factor) {
    return 'Koeffitsiyent $factor: siz tanladingiz.';
  }

  @override
  String get mrNoRbc => 'Mutlaq son uchun RBC ni kiriting.';

  @override
  String get mrExudate => 'Ekssudat mezonlariga mos';

  @override
  String get mrTransudate => 'Hech bir mezon bajarilmadi — transsudatga mos';

  @override
  String get mrIncomplete =>
      'Ikki mezon bajarilmadi; uchinchisi uchun LDH yuqori chegarasini kiriting';

  @override
  String get mrPerMlUrine => '1 ml siydikda';

  @override
  String get mrPerDay => 'Sutkada';

  @override
  String mrPerUlSediment(String value) {
    return '1 µL cho‘kmada: $value';
  }

  @override
  String get mrPortion12 => 'Sentrifugaga olinadigan 12 daqiqalik siydik';

  @override
  String get mrDiuresisTotal => 'Sutkalik diurez';

  @override
  String get mrDiuresisDay => 'Kunduzgi diurez (1–4)';

  @override
  String get mrDiuresisNight => 'Tungi diurez (5–8)';

  @override
  String get mrDayNightRatio => 'Kunduzgi : tungi';

  @override
  String get mrIntakePercent => 'Ichilgan suyuqlikka nisbatan';

  @override
  String get mrSgRange => 'Zichlik: eng past – eng yuqori';

  @override
  String get mrSgAmplitude => 'Zichlik amplitudasi';

  @override
  String get mrNotGiven => 'kiritilmagan';

  @override
  String get mErrNoUrine =>
      'Kamida bitta porsiyada siydik hajmi va zichligi kerak.';

  @override
  String get mErrSediment =>
      'Cho‘kma hajmi sentrifugalangan siydikdan kam bo‘lishi kerak.';

  @override
  String get mrProteinRatio => 'Oqsil: suyuqlik ÷ zardob (> 0,5)';

  @override
  String get mrLdhRatio => 'LDH: suyuqlik ÷ zardob (> 0,6)';

  @override
  String get mrLdhUln => 'Suyuqlik LDH ÷ yuqori chegara (> 2/3)';

  @override
  String get mrMet => 'bajarildi';

  @override
  String get mrNotMet => 'bajarilmadi';

  @override
  String get mrNotAssessed => 'baholanmadi';

  @override
  String mErrSum(String sum) {
    return 'Foizlar yig‘indisi $sum — 100 bo‘lishi kerak. Qatorlarni tekshiring.';
  }

  @override
  String get mErrReticGtExamined =>
      'Retikulotsitlar ko‘rilgan eritrotsitlardan ko‘p bo‘la olmaydi.';

  @override
  String mErrWhole(String field, String min, String max) {
    return '$field: butun son kiriting ($min–$max).';
  }

  @override
  String get ciWhatTitle => 'Bu nima?';

  @override
  String get ciWhat =>
      'Rang ko‘rsatkichi — MDH laboratoriyalarida an’anaviy ishlatiladigan nisbiy ko‘rsatkich: bitta eritrotsitdagi gemoglobin miqdorini “normaga” nisbatan baholaydi. Eritrotsitlarning gipo-, normo- yoki giperxromligini ko‘rsatish uchun ishlatiladi.';

  @override
  String get ciWhyTitle => 'Nega ilova uni hisoblamaydi';

  @override
  String get ciWhy =>
      'Formulasi uchun biz tekshira oladigan birlamchi ochiq manba topilmadi. Ilova manbasiz raqam yoki formula bermaydi.';

  @override
  String get ciUseTitle => 'O‘rniga nima ishlatiladi';

  @override
  String get ciUse =>
      'Bitta eritrotsitdagi gemoglobinni MCH (o‘rtacha gemoglobin miqdori, pg) to‘g‘ridan-to‘g‘ri ifodalaydi, eritrotsitdagi gemoglobin konsentratsiyasini esa MCHC. Gematologik analizator ikkalasini ham beradi. Gipo-/giperxromiyani shu ko‘rsatkichlar va laboratoriyangiz referens intervallari bo‘yicha baholang.';

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
  String get calcAcrSub => 'Siydik ACR · KDIGO A kategoriyasi';

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
  String get calcCalciumCaution =>
      'Albumin bo‘yicha tuzatilgan kalsiy ko‘pincha kalsiy holatini noto‘g‘ri baholaydi, ayniqsa albumin past bo‘lsa yoki buyrak faoliyati buzilganda. Imkon bo‘lsa, ionlashgan kalsiyni o‘lchang — u afzal.';

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
    return 'KDIGO GFR kategoriyasi: $code';
  }

  @override
  String resAlbCategory(String code) {
    return 'KDIGO albuminuriya kategoriyasi: $code';
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
  String get micSearchHint => 'Masalan: neytrofil, oksalat, bezgak';

  @override
  String get micNoResultsTitle => 'Hech narsa topilmadi';

  @override
  String get micNoResultsBody =>
      'Boshqa nom bilan yoki boshqa tilda yozib ko‘ring (uz, ru, en).';

  @override
  String get micSections => 'Bo‘limlar';

  @override
  String get micEduNotice =>
      'O‘quv rasmlari — tashxis uchun emas. Har rasmda muallif, litsenziya va asl izoh bor.';

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
  String get micCreditTitle => 'Muallif va litsenziya';

  @override
  String get micAuthor => 'Muallif';

  @override
  String get micAuthorPage => 'Muallif sahifasi';

  @override
  String get micLabelBySource => 'Nomi manba izohi bo‘yicha';

  @override
  String get micLabelNoQuiz => 'Mashqqa kirmaydi';

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
      'Sxematik rasm (LabGuide chizgan) — yo‘nalishni bezash uchun, aniq apparat ko‘rinishi emas.';

  @override
  String get instImageMissing => 'Model rasmi hozircha mavjud emas';

  @override
  String get instImageMissingSub =>
      'Aynan shu modelning ruxsatli rasmi topilmadi. Tashqi ko‘rinishini ishlab chiqaruvchi sahifasida ko‘ring.';

  @override
  String get instMakerSource => 'Ishlab chiqaruvchi manbasi';

  @override
  String get instImageTapToZoom => 'Kattalashtirish uchun rasmni bosing';

  @override
  String instImageRightsChecked(String date) {
    return 'Huquq tekshirilgan: $date';
  }

  @override
  String instImageSemantics(String model) {
    return '$model fotosi';
  }

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
  String get instSaveFailed => 'Saqlab bo‘lmadi. Qayta urinib ko‘ring.';

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
  String get learnHeroTag => 'Mavzular va mashq';

  @override
  String get learnHeroTitle => 'Molekuladan amaliyotgacha';

  @override
  String get learnHeroBody =>
      'Mavzu tanlab, savollar bilan bilimingizni tekshiring.';

  @override
  String get learnHeroCta => 'Mavzuni tanlash';

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
  String toifaTopic(String topic) {
    String _temp0 = intl.Intl.selectLogic(topic, {
      'safety_ethics': 'Xavfsizlik va etika',
      'qc_lab_management': 'Sifat nazorati va boshqaruv',
      'preanalytics': 'Preanalitika',
      'hematology_cells': 'Qon hujayralari',
      'hemopoiesis_leukemia': 'Qon yaratilishi va leykozlar',
      'anemias': 'Anemiyalar',
      'hemostasis': 'Gemostaz',
      'biochemistry_proteins_enzymes': 'Oqsillar va fermentlar',
      'carbohydrates_diabetes': 'Uglevodlar va diabet',
      'lipids': 'Lipidlar',
      'liver_pigments': 'Jigar va pigmentlar',
      'kidney_nitrogen': 'Buyrak va azot almashinuvi',
      'water_electrolytes_acid_base': 'Suv-elektrolit va kislota-asos',
      'minerals_vitamins': 'Minerallar va vitaminlar',
      'hormones': 'Gormonlar',
      'urinalysis': 'Siydik tahlili',
      'stool_coprology': 'Koprologiya',
      'csf_body_fluids': 'Likvor va biologik suyuqliklar',
      'sputum_tb': 'Balg‘am va sil',
      'cytology_gyn': 'Sitologiya',
      'std_microscopy': 'JYYI mikroskopiyasi',
      'parasitology': 'Parazitologiya',
      'immunology_serology': 'Immunologiya va serologiya',
      'molecular_pcr': 'Molekulyar diagnostika (PZR)',
      'tumor_markers': 'O‘sma markerlari',
      'cardiac_markers': 'Kardiomarkerlar',
      'orphan_screening': 'Skrining va orfan kasalliklar',
      'other': 'Boshqa mavzular',
    });
    return '$_temp0';
  }

  @override
  String get toifaTitle => 'Bilim va malakani baholash';

  @override
  String get toifaSubtitle => 'Klinik laboratoriya diagnostikasi (KDL)';

  @override
  String get toifaEyebrow => 'KDL · bilim va malaka';

  @override
  String get toifaEntryBody =>
      'Rasmiy ro‘yxatdagi savollar: 50 savollik test, mavzu bo‘yicha mashq, og‘zaki bilet va xatolar ustida ishlash.';

  @override
  String get toifaEntryBodyShort =>
      'Test, og‘zaki bilet va xatolar ustida ishlash — rasmiy ro‘yxat asosida.';

  @override
  String get toifaEntryTagTest => 'Test · 50 savol';

  @override
  String get toifaEntryTagOral => 'Og‘zaki · 5 savol';

  @override
  String toifaEntryTestActive(int done, int total) {
    return 'Test davom etmoqda: $done / $total javob';
  }

  @override
  String toifaEntryTicketActive(int done, int total) {
    return 'Og‘zaki bilet davom etmoqda: $done / $total';
  }

  @override
  String get toifaOpen => 'Boshlash';

  @override
  String get toifaContinue => 'Davom ettirish';

  @override
  String get toifaUzbekOnly => 'Rasmiy matn — o‘zbekcha';

  @override
  String get toifaUzbekNotice =>
      'Attestatsiya savollarining rasmiy matni o‘zbekcha. Interfeys tili rus yoki ingliz bo‘lsa — yordamchi tarjima ko‘rsatiladi, asl matnni istalgan vaqt ko‘rish mumkin. Baholash rasmiy o‘zbekcha matn va kalit bo‘yicha.';

  @override
  String get toifaShowOriginal => 'Asl matnni ko‘rish';

  @override
  String get toifaHideOriginal => 'Asl matnni yashirish';

  @override
  String get toifaOriginalTitle => 'Rasmiy matn (o‘zbekcha)';

  @override
  String get toifaTranslationAux =>
      'Tarjima yordamchi; baholash rasmiy o‘zbekcha matn bo‘yicha.';

  @override
  String get toifaLoadError => 'Savollar bankini ochib bo‘lmadi';

  @override
  String get toifaYourCategory => 'Kategoriyangiz';

  @override
  String get toifaCatSecond => '3–2-kategoriya';

  @override
  String get toifaCatFirst => '1-kategoriya';

  @override
  String get toifaCatHighest => 'Oliy kategoriya';

  @override
  String get toifaCategoryHint =>
      'Og‘zaki bilet shu kategoriya ro‘yxatidan tuziladi. Test savollari barcha kategoriyalar uchun umumiy.';

  @override
  String get toifaReadyTest => 'Test';

  @override
  String get toifaReadyOral => 'Og‘zaki';

  @override
  String get toifaPrepare => 'Baholash';

  @override
  String get toifaTestTitle => 'Bilim testi';

  @override
  String toifaTestRowSub(int count, int bank) {
    return '$count ta tasodifiy savol · bankda $bank ta';
  }

  @override
  String get toifaPracticeTitle => 'Mavzu bo‘yicha mashq';

  @override
  String toifaPracticeRowSub(int count) {
    return '$count ta mavzu · javobdan keyin kalit va izoh';
  }

  @override
  String get toifaOralTitle => 'Og‘zaki bilet';

  @override
  String toifaOralRowSub(String category, int count) {
    return '$category: $count ta savoldan 5 tasi';
  }

  @override
  String get toifaOralRowPick => 'Avval kategoriyangizni tanlang';

  @override
  String toifaOralRowActive(int done, int total) {
    return 'Davom etmoqda: $done / $total baholandi';
  }

  @override
  String get toifaMistakesTitle => 'Xatolar ustida ishlash';

  @override
  String toifaMistakesRowSub(int tests, int oral) {
    return 'Test xatolari: $tests · og‘zaki “bilmadim”: $oral';
  }

  @override
  String get toifaMistakesRowEmpty => 'Hozircha xato yo‘q';

  @override
  String get toifaProgressTitle => 'Rivojlanish';

  @override
  String get toifaProgressRowSub => 'Mavzular bo‘yicha natija va tayyorlik';

  @override
  String get toifaAboutTitle => 'Manba va tekshiruv';

  @override
  String get toifaListSource =>
      'Manba: Rasmiy attestatsiya savollari ro‘yxati (KDL, 119)';

  @override
  String toifaAboutList(int tests, int oral) {
    return 'Ro‘yxatda $tests ta test va $oral ta og‘zaki savol (kategoriyalar bo‘yicha takrorlar birlashtirilgan).';
  }

  @override
  String toifaAboutKeys(int disputed, int ambiguous) {
    return 'Kalit — ro‘yxatda belgilangan javob, ball shu bo‘yicha hisoblanadi. LabGuide $disputed ta savolda kalitni bahsli, $ambiguous tasida noaniq deb topdi — ularda izoh va manba ko‘rsatiladi.';
  }

  @override
  String toifaAboutKeyless(int count) {
    return '$count ta savolda ro‘yxatda kalit belgilanmagan — ular test va mashqqa kiritilmadi.';
  }

  @override
  String toifaAboutOral(int ready, int total) {
    return 'Og‘zaki javob rejalari — LabGuide tayyorlagan o‘quv yordami ($ready / $total ta reja manbalar bilan).';
  }

  @override
  String toifaTestSubtitle(int count) {
    return '$count ta savol · rasmiy ro‘yxatdan tasodifiy';
  }

  @override
  String get toifaFormatTitle => 'Format';

  @override
  String toifaFormatStep1(int count, int bank) {
    return 'Bankdagi $bank ta savoldan tasodifiy $count tasi.';
  }

  @override
  String get toifaFormatStep2 =>
      'Har savolda bitta javob; variantlar ro‘yxatdagi tartibda.';

  @override
  String get toifaFormatStep3 =>
      'Yakunda xatolar tahlili: rasmiy kalit va LabGuide izohi.';

  @override
  String get toifaTimeLabel => 'Vaqt, daqiqa';

  @override
  String get toifaNoTime => 'Vaqtsiz';

  @override
  String get toifaTimeHelper =>
      'Rasmiy vaqt chegarasi ilovada belgilanmagan — o‘zingiz tanlang yoki bo‘sh qoldiring.';

  @override
  String get toifaTimeError =>
      '1 dan 240 gacha daqiqa kiriting yoki bo‘sh qoldiring';

  @override
  String get toifaPassLabel => 'O‘tish chegarasi, %';

  @override
  String get toifaNoPass => 'Belgilanmagan';

  @override
  String get toifaPassHelper =>
      'Bu siz tanlagan chegara, rasmiy o‘tish bali emas.';

  @override
  String get toifaPassError =>
      '1 dan 100 gacha foiz kiriting yoki bo‘sh qoldiring';

  @override
  String get toifaScoringNotice =>
      'Ball rasmiy kalit bo‘yicha hisoblanadi — imtihonda shu javob talab qilinadi. Kalit bahsli savollarda natijada LabGuide izohi ham ko‘rsatiladi.';

  @override
  String get toifaTestStart => 'Testni boshlash';

  @override
  String get toifaTodayEyebrow => 'Bugun';

  @override
  String toifaTodayGoal(int count) {
    return 'Maqsad: $count ta savol yoki 1 bilet';
  }

  @override
  String get toifaTodayDone => 'Bugungi maqsad bajarildi';

  @override
  String toifaTodayProgress(int answered, int goal) {
    return '$answered/$goal savol';
  }

  @override
  String toifaTodayCorrect(int percent) {
    return '$percent% to‘g‘ri';
  }

  @override
  String toifaTodayTickets(int count) {
    return 'biletlar: $count';
  }

  @override
  String toifaStreakDays(int count) {
    return '$count kun ketma-ket';
  }

  @override
  String get toifaTodayNone => 'Bugun hali mashg‘ulot bo‘lmadi.';

  @override
  String get toifaTodayTomorrow => 'Ertaga ham davom eting — seriya uzilmasin.';

  @override
  String toifaWeekLabel(String values) {
    return 'So‘nggi 7 kun: $values';
  }

  @override
  String get toifaGoalLabel => 'Kunlik maqsad';

  @override
  String toifaGoalOption(int count) {
    return '$count savol';
  }

  @override
  String get toifaGoalHint =>
      'Yoki 1 ta og‘zaki bilet — qaysi biri oldin bajarilsa.';

  @override
  String get toifaReminderTitle => 'LabGuide · Bilim va malaka';

  @override
  String toifaReminderBody(int count) {
    return 'Bugungi mashg‘ulot sizni kutmoqda — $count ta savol yoki 1 bilet';
  }

  @override
  String get toifaReminderChannel => 'Bilim va malaka eslatmasi';

  @override
  String get toifaOfferTitle => 'Ertaga davom etamizmi?';

  @override
  String get toifaOfferBody =>
      'Eslatma vaqtini tanlang. Maqsadni bajargan kuningiz eslatma kelmaydi.';

  @override
  String toifaOfferOn(String time) {
    return 'Ertaga soat $time da eslatamiz.';
  }

  @override
  String get toifaModeTitle => 'Rejim';

  @override
  String get toifaModeExam => 'Imtihon rejimi';

  @override
  String get toifaModeExamSub =>
      'Vaqt bilan; ball va xatolar oxirida — haqiqiy imtihondek.';

  @override
  String get toifaModePractice => 'Mashq rejimi — xato darhol ko‘rinadi';

  @override
  String get toifaModePracticeSub =>
      'Har javobdan keyin to‘g‘ri javob va izoh; vaqt yo‘q.';

  @override
  String get toifaDrillStep2 =>
      'Javob bergan zahoti to‘g‘ri yoki xato ko‘rinadi: rasmiy kalit va (bo‘lsa) izoh, manba.';

  @override
  String get toifaDrillStep3 =>
      'Ilova yopilsa ham joyidan davom etasiz; yakunda xatolarni qayta ishlash.';

  @override
  String get toifaDrillStart => 'Mashqni boshlash';

  @override
  String toifaDrillActive(int answered, int total) {
    return 'Mashq davom etmoqda: $answered/$total';
  }

  @override
  String get toifaDrillTitle => 'Mashq rejimi';

  @override
  String get toifaDrillRework => 'Xatolarni qayta ishlash';

  @override
  String toifaDrillScore(int right, int wrong) {
    return 'To‘g‘ri: $right · xato: $wrong';
  }

  @override
  String get toifaDrillFinishEarly => 'Hozircha yakunlash';

  @override
  String get toifaDrillFinishBody =>
      'Javobsiz savollar noto‘g‘ri sanaladi. Berilgan javoblar xatolar ro‘yxatida qoladi.';

  @override
  String get toifaDrillDiscardTitle => 'Mashq to‘xtatilsinmi?';

  @override
  String get toifaDrillNone => 'Davom etayotgan mashq yo‘q';

  @override
  String get toifaDrillNew => 'Yangi test';

  @override
  String toifaDrillUnanswered(int count) {
    return 'Javobsiz: $count';
  }

  @override
  String get toifaThinkHint =>
      'Javobni o‘ylab ko‘ring: ovoz chiqarib ayting yoki qog‘ozga yozing. So‘ng rejani ochib solishtiring.';

  @override
  String toifaThinkTimer(int minutes) {
    return '$minutes daqiqa o‘ylash';
  }

  @override
  String toifaThinkLeft(String time) {
    return 'O‘ylash vaqti: $time';
  }

  @override
  String get toifaThinkUp => 'Vaqt tugadi — endi rejani ochib solishtiring.';

  @override
  String get toifaThinkStop => 'Taymerni to‘xtatish';

  @override
  String get toifaChecklistToggle =>
      'Javob rejasini taqqoslash uchun asosiy so‘zlar';

  @override
  String get toifaChecklistHint =>
      'Javobingizda bo‘lganlarini belgilang (faqat qurilmada, yozish shart emas).';

  @override
  String toifaChecklistCount(int done, int total) {
    return '$done/$total belgilandi';
  }

  @override
  String get toifaRepeatTitle => 'Takrorlash kerak';

  @override
  String get toifaRepeatNote =>
      '“Qisman” va “Bilmadim” savollari keyingi biletlarda birinchi bo‘lib qaytadi.';

  @override
  String get toifaRepeatNone =>
      'Hammasini bildingiz — keyingi biletda yangi savollar.';

  @override
  String get toifaPracticeSubtitle => 'Javobdan keyin darhol kalit';

  @override
  String toifaPracticeMixed(int count) {
    return 'Aralash: $count ta savol';
  }

  @override
  String get toifaPracticeMistakes => 'Xatolarni qayta ishlash';

  @override
  String get toifaBackToTopics => 'Mavzular';

  @override
  String get toifaPracticeRight => 'Javobingiz rasmiy kalitga mos.';

  @override
  String get toifaPracticeWrong => 'Javobingiz rasmiy kalitga mos emas.';

  @override
  String toifaListNumber(int number) {
    return '№ $number';
  }

  @override
  String get toifaOfficialKey => 'Rasmiy kalit';

  @override
  String get toifaLabGuideNote => 'LabGuide izohi';

  @override
  String get toifaVerdictDisputed => 'Kalit bahsli';

  @override
  String get toifaVerdictAmbiguous => 'Savol noaniq';

  @override
  String toifaSuggested(String options) {
    return 'LabGuide fikricha: $options';
  }

  @override
  String get toifaScoredByOfficial =>
      'Ball rasmiy kalit bo‘yicha hisoblanadi — imtihonda shu javob talab qilinadi.';

  @override
  String get toifaNoOfficialKey =>
      'Ro‘yxatda kalit belgilanmagan — bu savol baholanmaydi.';

  @override
  String get toifaNoteNoSource => 'Izoh uchun manba ko‘rsatilmagan.';

  @override
  String get toifaRelatedCards => 'Bog‘liq kartalar';

  @override
  String toifaOralSubtitle(int count) {
    return '$count ta savol · tayyorlanish va o‘zini baholash';
  }

  @override
  String toifaOralPool(String category, int count) {
    return '$category: ro‘yxatda $count ta savol';
  }

  @override
  String get toifaOralHowTitle => 'Qanday ishlaydi';

  @override
  String toifaOralStep1(int count) {
    return 'Kategoriyangiz ro‘yxatidan tasodifiy $count ta savol.';
  }

  @override
  String get toifaOralStep2 => 'Javoblarni o‘ylab yoki yozib tayyorlaning.';

  @override
  String get toifaOralStep3 =>
      'Javob rejasini ko‘rib, o‘zingizni baholang: bildim, qisman yoki bilmadim.';

  @override
  String get toifaPickCategoryFirst => 'Avval kategoriyani tanlang';

  @override
  String get toifaDrawTicket => 'Bilet olish';

  @override
  String get toifaTicketTitle => 'Biletingiz';

  @override
  String get toifaPrepHint =>
      'Ilovaga yozish shart emas. Har savolga javobni o‘ylab ko‘ring — ovoz chiqarib ayting yoki qog‘ozga yozing. So‘ng javob rejasi bilan solishtirib, o‘zingizni baholaysiz.';

  @override
  String get toifaShowPlans => 'Savollarga birma-bir javob berish';

  @override
  String get toifaShowPlan => 'Javob rejasini ko‘rish';

  @override
  String get toifaNewTicket => 'Yangi bilet';

  @override
  String get toifaNewTicketBody =>
      'Joriy bilet o‘rniga yangi 5 ta savol olinadi. Berilgan baholar saqlanib qoladi.';

  @override
  String get toifaRevealHint =>
      'Avval javobingizni eslang yoki yozib oling, so‘ng rejani oching.';

  @override
  String get toifaPlanTitle => 'Javob rejasi';

  @override
  String get toifaPlanPending => 'LabGuide tayyorlagan';

  @override
  String get toifaPlanMissing => 'Bu savol uchun reja hali tayyorlanmagan.';

  @override
  String get toifaPlanNotChecked => 'Bu rejaga manba hali biriktirilmagan.';

  @override
  String get toifaReferenceTitle =>
      'Referens interval (namuna, laboratoriyaga qarab)';

  @override
  String get toifaCutoffTitle => 'Diagnostik chegara (qo‘llanma)';

  @override
  String get toifaWrongLabel => 'Noto‘g‘ri';

  @override
  String get toifaRightLabel => 'To‘g‘ri';

  @override
  String get toifaNeedsSource => 'Manba kerak — ustozdan aniqlashtirilmoqda';

  @override
  String get toifaUnverifiedNote =>
      'Izoh manba bilan tasdiqlanmagan — taklif berilmaydi.';

  @override
  String toifaAgentChecked(String date) {
    return 'Manbalar bilan solishtirilgan: $date';
  }

  @override
  String get toifaHeld => 'Aniqlashtirilmoqda';

  @override
  String get toifaHeldBody =>
      'Savol matni aniqlashtirilguncha biletga va baholashga kirmaydi.';

  @override
  String toifaAboutHeld(int count) {
    return '$count ta savol aniqlashtirilguncha bilet va testdan chiqarilgan.';
  }

  @override
  String get toifaPitfallsTitle => 'Eskirgan / ko‘p uchraydigan xato';

  @override
  String get toifaRateTitle => 'O‘zingizni baholang';

  @override
  String get toifaRateHint =>
      'Baho faqat shu qurilmada saqlanadi va “Xatolar ustida ishlash”da ko‘rinadi.';

  @override
  String get toifaRateKnew => 'Bildim';

  @override
  String get toifaRatePartial => 'Qisman';

  @override
  String get toifaRateUnknown => 'Bilmadim';

  @override
  String get toifaTicketDone => 'Bilet yakunlandi';

  @override
  String toifaTicketSummary(int knew, int partial, int unknown) {
    return 'Bildim: $knew · qisman: $partial · bilmadim: $unknown';
  }

  @override
  String get toifaRatingsSaved =>
      'Baholar saqlandi. Savolni bosib rejani qayta ko‘rish va bahoni o‘zgartirish mumkin.';

  @override
  String get toifaRatingSaved => 'Baho saqlandi';

  @override
  String get toifaMistakesSubtitle => 'Test xatolari va og‘zaki savollar';

  @override
  String get toifaMistakesEmpty => 'Hozircha xato yo‘q';

  @override
  String get toifaMistakesEmptyBody =>
      'Test yoki mashqda xato qilgan savollaringiz va og‘zaki biletda “bilmadim” degan savollaringiz shu yerda yig‘iladi.';

  @override
  String toifaMistakesTests(int count) {
    return 'Test xatolari · $count';
  }

  @override
  String toifaMistakesOralUnknown(int count) {
    return 'Og‘zaki: bilmadim · $count';
  }

  @override
  String toifaMistakesOralPartial(int count) {
    return 'Og‘zaki: qisman · $count';
  }

  @override
  String toifaMoreMistakes(int count) {
    return 'Yana $count ta xato — “Xatolarni qayta ishlash” orqali mashq qiling.';
  }

  @override
  String get toifaNothingHere => 'Bu yerda hozircha hech narsa yo‘q.';

  @override
  String get toifaProgressSubtitle => 'Mavzular bo‘yicha natija va tayyorlik';

  @override
  String get toifaReadyTitle => 'Taxminiy tayyorlik';

  @override
  String get toifaReadyCaption =>
      'Test va og‘zaki natijalar o‘rtachasi. LabGuide hisobi — rasmiy baho emas.';

  @override
  String toifaReadyTestDetail(int done, int total) {
    return 'Test: $done / $total savol o‘zlashtirildi';
  }

  @override
  String toifaReadyOralDetail(int done, int total) {
    return 'Og‘zaki: $done / $total “bildim”';
  }

  @override
  String get toifaProgressPickCategory =>
      'Og‘zaki natija kategoriyangiz ro‘yxati bo‘yicha hisoblanadi — kategoriyani tanlang:';

  @override
  String get toifaRecentTests => 'So‘nggi testlar';

  @override
  String get toifaPassedShort => 'Chegaradan o‘tdi';

  @override
  String get toifaNotPassedShort => 'Chegaraga yetmadi';

  @override
  String get toifaByTopicNote =>
      'Eng zaif mavzular birinchi. Test — oxirgi javobi to‘g‘ri savollar; og‘zaki — “bildim” deb baholanganlar.';

  @override
  String toifaBarTest(int done, int total) {
    return 'Test: $done / $total';
  }

  @override
  String toifaBarOral(int done, int total) {
    return 'Og‘zaki: $done / $total';
  }

  @override
  String examPassMet(int percent) {
    return 'Chegaradan o‘tdi (≥$percent%)';
  }

  @override
  String examPassMissed(int percent) {
    return 'Chegaraga yetmadi ($percent%)';
  }

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
      'Mashq savollari o‘quv maqsadida; natija rasmiy baho emas.';

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
  String get dailyTitle => 'Kunlik savol';

  @override
  String get dailyCardStart => 'Bugungi 5 ta savol';

  @override
  String get dailyCardStartSub =>
      '2–3 daqiqa. Har kuni yangi savollar, javobdan keyin izoh va manba.';

  @override
  String dailyCardProgress(int count, int total) {
    return '$total tadan $count tasiga javob berildi';
  }

  @override
  String dailyCardDone(int correct, int total) {
    return 'Bugun bajarildi: $total tadan $correct ta to‘g‘ri';
  }

  @override
  String get dailyCardDoneSub => 'Ertaga yangi 5 ta savol bo‘ladi.';

  @override
  String get dailyStart => 'Boshlash';

  @override
  String get dailyContinue => 'Davom etish';

  @override
  String get dailyShowResult => 'Natijani ko‘rish';

  @override
  String dailyStreakDays(int count) {
    return '$count kun ketma-ket';
  }

  @override
  String get dailyStreakTitle => 'Ketma-ketlik';

  @override
  String get dailyStreakCurrent => 'Joriy seriya';

  @override
  String get dailyStreakBest => 'Eng uzun seriya';

  @override
  String dailyDaysShort(int count) {
    return '$count kun';
  }

  @override
  String get dailyFreezeAvailable => 'Bu haftalik muzlatish bor';

  @override
  String get dailyFreezeUsed => 'Bu haftalik muzlatish ishlatildi';

  @override
  String get dailyFreezeRule =>
      'Bir kunni o‘tkazib yuborsangiz, seriya uzilmaydi — haftasiga bir marta (muzlatish). Muzlatilgan kun seriyaga qo‘shilmaydi; ketma-ket ikki kun o‘tkazilsa, seriya qaytadan boshlanadi.';

  @override
  String get dailyFreezeSaved =>
      'Kecha o‘tkazib yuborildi — muzlatish seriyani saqlab qoldi.';

  @override
  String get dailyStreakStart =>
      'Bugungi savollarni bajaring — seriya shu kundan boshlanadi.';

  @override
  String get dailyKeepStreak =>
      'Seriyani saqlash uchun bugungi savollarni bajaring.';

  @override
  String get dailyEmpty => 'Bugun uchun savol topilmadi';

  @override
  String get dailyReviewTitle => 'Bugungi savollar';

  @override
  String get dailySourceToifa =>
      'Savollar rasmiy ro‘yxatdan olinadi — faqat kaliti LabGuide tekshiruvidan o‘tganlari.';

  @override
  String get dailyReminderTitle => 'LabGuide: kunlik savol';

  @override
  String get dailyReminderBody => 'Bugungi 5 ta savol tayyor — 2–3 daqiqa.';

  @override
  String get dailyReminderChannel => 'Kunlik eslatma';

  @override
  String get dailyReminderSetting => 'Kunlik eslatma';

  @override
  String dailyReminderAt(String time) {
    return 'Har kuni soat $time da';
  }

  @override
  String get dailyReminderOff => 'O‘chiq';

  @override
  String get dailyReminderTime => 'Eslatma vaqti';

  @override
  String get dailyOfferTitle => 'Har kuni eslatib turaymi?';

  @override
  String get dailyOfferBody =>
      'Tanlagan vaqtingizda bitta bildirishnoma. Savollarni bajargan kuningiz eslatma kelmaydi. Istalgan payt o‘chirib qo‘yasiz.';

  @override
  String get dailyOfferYes => 'Eslatmani yoqish';

  @override
  String get dailyOfferNo => 'Kerak emas';

  @override
  String get dailyReminderDenied =>
      'Bildirishnomaga ruxsat berilmadi, eslatma o‘chiq qoldi. Telefon sozlamalarida LabGuide uchun bildirishnomalarni yoqib, qayta urinib ko‘ring.';

  @override
  String get dailyReminderUnavailable =>
      'Bu qurilmada eslatmani yoqib bo‘lmadi.';

  @override
  String dailyReminderOnSnack(String time) {
    return 'Eslatma yoqildi: har kuni soat $time da';
  }

  @override
  String get dailyReminderNote =>
      'Eslatma faqat shu qurilmada rejalashtiriladi (server yo‘q). Telefon quvvatni tejash uchun uni bir necha daqiqa kechiktirishi mumkin. Ilova 7 kun ochilmasa, eslatmalar to‘xtaydi.';

  @override
  String get shareResult => 'Natijani ulashish';

  @override
  String get shareSheetTitle => 'Natija kartochkasi';

  @override
  String get shareSheetBody =>
      'Rasmda ismingiz yoki boshqa shaxsiy ma’lumot yo‘q.';

  @override
  String get shareFailed =>
      'Ulashish oynasini ochib bo‘lmadi. Qayta urinib ko‘ring.';

  @override
  String get shareKindDaily => 'Kunlik savol';

  @override
  String get shareKindExam => 'Mashq imtihoni';

  @override
  String get shareKindToifa => 'Bilim testi mashqi';

  @override
  String get shareCorrectCaption => 'to‘g‘ri javob';

  @override
  String get shareFooter => 'Laboratoriya bo‘yicha qo‘llanma va mashqlar';

  @override
  String get shareToifaNote => 'LabGuide mashq natijasi';

  @override
  String shareText(String kind, int correct, int total, int percent) {
    return 'LabGuide · $kind: $correct/$total ($percent%)';
  }

  @override
  String get quizTopicMistakes => 'Xatolarim ustida ishlash';

  @override
  String quizMastered(int correct, int total) {
    return '$total tadan $correct tasi oxirgi safar to‘g‘ri';
  }

  @override
  String get examTitle => 'Imtihon rejimi';

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
  String get examSubtitle =>
      'Vaqtli sinov: mavzular, savollar soni va vaqtni tanlang. Internetsiz ishlaydi.';

  @override
  String get examActiveTitle => 'Tugallanmagan imtihon';

  @override
  String examActiveBody(int answered, int total, String time) {
    return '$answered/$total javob · $time qoldi';
  }

  @override
  String get examResume => 'Davom ettirish';

  @override
  String get examDiscard => 'Imtihonni to‘xtatish';

  @override
  String get examDiscardTitle => 'Imtihon to‘xtatilsinmi?';

  @override
  String get examDiscardBody =>
      'Javoblar o‘chadi va natija tarixga yozilmaydi.';

  @override
  String get examDiscardAction => 'To‘xtatish';

  @override
  String get examTopics => 'Mavzular';

  @override
  String get examAllTopics => 'Hammasi';

  @override
  String examPoolCount(int count) {
    return 'Tanlangan mavzularda $count ta savol';
  }

  @override
  String get examSettings => 'Sozlamalar';

  @override
  String get examCount => 'Savollar soni';

  @override
  String examCountHint(int max) {
    return '1 dan $max gacha';
  }

  @override
  String examCountError(int max) {
    return '1 dan $max gacha son kiriting';
  }

  @override
  String examCountAll(int count) {
    return 'Barcha $count ta';
  }

  @override
  String get examTime => 'Vaqt, daqiqa';

  @override
  String get examTimeHint => '1–180 daqiqa · odatda 1 daqiqa / savol';

  @override
  String get examTimeError => '1 dan 180 gacha daqiqa kiriting';

  @override
  String examMinutes(int count) {
    return '$count daq';
  }

  @override
  String get examRulesNotice =>
      'Savollar va variantlar tasodifiy tartibda. Yakunlashgacha javobni o‘zgartirish, savolni belgilab keyin qaytish mumkin. Vaqt ilova yopiq bo‘lsa ham davom etadi; tugasa, imtihon o‘zi yakunlanadi.';

  @override
  String get examStart => 'Imtihonni boshlash';

  @override
  String get examReplaceTitle => 'Tugallanmagan imtihon bor';

  @override
  String get examReplaceBody =>
      'Yangisini boshlasangiz, oldingisi javoblari bilan o‘chadi.';

  @override
  String get examHistory => 'Natijalar tarixi';

  @override
  String get examHistoryEmpty =>
      'Hali imtihon topshirilmagan. Birinchi natijangiz shu yerda chiqadi — u faqat shu qurilmada saqlanadi.';

  @override
  String examHistoryStats(int count, int avg, int best) {
    return 'So‘nggi $count ta: o‘rtacha $avg% · eng yaxshi $best%';
  }

  @override
  String examHistoryRow(String date, int correct, int total, String time) {
    return '$date · $correct/$total · $time';
  }

  @override
  String get examHistoryClear => 'Tarixni tozalash';

  @override
  String get examHistoryClearBody =>
      'Barcha imtihon natijalari shu qurilmadan o‘chiriladi.';

  @override
  String examProgressLabel(String values) {
    return 'So‘nggi natijalar: $values';
  }

  @override
  String get examProgressOld => 'Eskiroq → yangi';

  @override
  String get examProgressLast => 'Oxirgisi';

  @override
  String get examSettled => 'Oldingi imtihon vaqti tugagani uchun yakunlandi';

  @override
  String get examOpenResult => 'Natija';

  @override
  String get examTitleAll => 'Barcha mavzular';

  @override
  String examTitleTopics(String first, int more) {
    return '$first va yana $more ta';
  }

  @override
  String get examReworkTitle => 'Xatolar ustida ishlash';

  @override
  String get examQuestionMissing => 'Bu savol joriy kontent to‘plamida yo‘q.';

  @override
  String get examMap => 'Savollar xaritasi';

  @override
  String get examFinish => 'Yakunlash';

  @override
  String get examFinishTitle => 'Imtihon yakunlansinmi?';

  @override
  String examFinishBody(int unanswered, int flagged) {
    return 'Javobsiz: $unanswered ta, belgilangan: $flagged ta. Yakunlangach javoblarni o‘zgartirib bo‘lmaydi.';
  }

  @override
  String get examFinishBodyAll =>
      'Barcha savollarga javob berildi. Yakunlangach javoblarni o‘zgartirib bo‘lmaydi.';

  @override
  String get examFinishClassTitle => 'Test yakunlansinmi?';

  @override
  String get examFinishClassBody => 'Javoblar ustozga yuboriladi.';

  @override
  String get examFlag => 'Belgilash';

  @override
  String get examFlagged => 'Belgilangan';

  @override
  String get examLegendAnswered => 'Javob berilgan';

  @override
  String get examLegendEmpty => 'Javobsiz';

  @override
  String get examLegendFlagged => 'Belgilangan';

  @override
  String examQuestionN(int n) {
    return '$n-savol';
  }

  @override
  String examAnsweredOf(int answered, int total) {
    return '$answered/$total javob berildi';
  }

  @override
  String get examPrev => 'Oldingi';

  @override
  String get examNext => 'Keyingi';

  @override
  String examTimeLeft(String time) {
    return 'Qolgan vaqt: $time';
  }

  @override
  String examElapsed(String time) {
    return 'O‘tgan vaqt: $time';
  }

  @override
  String get examNoActive => 'Faol imtihon yo‘q';

  @override
  String get examNoActiveBody =>
      'U yakunlangan yoki to‘xtatilgan. Yangi imtihonni sozlab boshlang.';

  @override
  String get examNew => 'Yangi imtihon';

  @override
  String get examSaving => 'Natija saqlanmoqda…';

  @override
  String get examResultTitle => 'Natija';

  @override
  String get examResultMissing => 'Natija topilmadi';

  @override
  String get examBand90 => 'A’lo natija!';

  @override
  String get examBand70 => 'Yaxshi natija!';

  @override
  String get examBand50 => 'Yomon emas — xatolarni ko‘rib chiqing';

  @override
  String get examBand0 => 'Mashq qiling — siz uddalaysiz';

  @override
  String get examCorrectN => 'To‘g‘ri';

  @override
  String get examWrongN => 'Xato';

  @override
  String get examSkippedN => 'Javobsiz';

  @override
  String get examSpent => 'Vaqt';

  @override
  String get examTimedOut => 'Vaqt tugadi — avtomatik yakunlandi';

  @override
  String examDeltaUp(int n) {
    return 'Oldingi urinishdan +$n%';
  }

  @override
  String examDeltaDown(int n) {
    return 'Oldingi urinishdan −$n%';
  }

  @override
  String get examDeltaSame => 'Oldingi urinish bilan bir xil';

  @override
  String examReworkMistakes(int count) {
    return 'Xatolarni qayta ishlash · $count';
  }

  @override
  String get examAnalysis => 'Xatolar tahlili';

  @override
  String examFilterMistakes(int count) {
    return 'Xatolar · $count';
  }

  @override
  String examFilterAll(int count) {
    return 'Hammasi · $count';
  }

  @override
  String get examNoAnswer => 'Javob berilmagan';

  @override
  String get examWrongTag => 'Xato';

  @override
  String get examWhyWrong => 'Nega bu javob emas';

  @override
  String get examNoSource => 'Bu savolga manba ko‘rsatilmagan.';

  @override
  String get examSourceMissing =>
      'Bu imtihonning savollar banki ilovada topilmadi';

  @override
  String get examMultiHint => 'Bir nechta to‘g‘ri javob — hammasini belgilang';

  @override
  String get examNoExplanation => 'Bu savolga izoh hali yozilmagan.';

  @override
  String get examByTopic => 'Mavzular bo‘yicha';

  @override
  String get examByTopicNote =>
      'Eng past natijali mavzu birinchi — shundan boshlang.';

  @override
  String get classesSubtitle =>
      'Ustoz guruh ochadi va topshiriq beradi, talabalar kod bilan qo‘shilib yechadi.';

  @override
  String get classesTryExam => 'Internetsiz imtihonni ochish';

  @override
  String get classesLoading => 'Yuklanmoqda…';

  @override
  String get classesInvalid =>
      'Server ma’lumotni qabul qilmadi — maydonlarni tekshiring.';

  @override
  String get classesCodeNotFound =>
      'Bu kod bilan guruh topilmadi. Kodni ustozdan qayta tekshirib oling.';

  @override
  String get classesCreate => 'Guruh yaratish';

  @override
  String get classesCreateSub => 'Ustoz uchun: kod oling va topshiriq bering';

  @override
  String get classesJoin => 'Kod bilan qo‘shilish';

  @override
  String get classesJoinSub => 'Talaba uchun: ustoz bergan 8 belgili kod';

  @override
  String get classesRoleNote =>
      'Ilovadagi rol server huquqi bermaydi: guruhni faqat o‘zini ustoz sifatida ro‘yxatdan o‘tkazgan hisob ochadi va faqat o‘z guruhlarini boshqaradi.';

  @override
  String get classesMine => 'Mening guruhlarim';

  @override
  String get classesEmpty => 'Hali guruh yo‘q';

  @override
  String get classesEmptyBody =>
      'Guruh yarating yoki ustozingiz bergan kod bilan qo‘shiling.';

  @override
  String get classesRoleTeacher => 'Ustoz';

  @override
  String get classesRoleStudent => 'Talaba';

  @override
  String classesMembers(int count) {
    return '$count a’zo';
  }

  @override
  String get classesCreateIntro =>
      'Guruhni ochgan ustoz faqat shu guruhni boshqaradi. Talabalar siz bergan kod yoki QR bilan qo‘shiladi.';

  @override
  String get classesGroupName => 'Guruh nomi';

  @override
  String get classesGroupNameHint => 'Masalan, Biokimyo 2-kurs';

  @override
  String classesLengthError(int min, int max) {
    return '$min–$max belgi kiriting';
  }

  @override
  String get classesDisplayName => 'Taxallus (ixtiyoriy)';

  @override
  String get classesDisplayNameHint =>
      'Masalan, Yulduz — bo‘sh qoldirsangiz, tartib raqami';

  @override
  String get classesDisplayNameHintTeacher => 'Masalan, Karimova N.A.';

  @override
  String get classesDisplayNameNote =>
      'Ism-familiya serverda saqlanmaydi: talabalar taxallus yoki tartib raqami bilan ko‘rinadi. Real ismni faqat o‘z qurilmangizda belgi sifatida yozishingiz mumkin.';

  @override
  String get classesCreateAction => 'Guruhni yaratish';

  @override
  String get classesCreated => 'Guruh yaratildi — kodni talabalarga yuboring';

  @override
  String get classesJoinIntro => 'Ustozingiz bergan kodni kiriting.';

  @override
  String get classesCode => 'Taklif kodi';

  @override
  String get classesCodeError => 'Kod 8 ta harf va raqamdan iborat';

  @override
  String get classesJoinNote =>
      'Haqiqiy ismingizni yozmang. Ustoz faqat taxallusingiz (yoki tartib raqamingiz) va topshiriq natijalaringizni ko‘radi; boshqa talabalar sizni ko‘rmaydi. Emailingiz ko‘rsatilmaydi.';

  @override
  String get classesJoinAction => 'Qo‘shilish';

  @override
  String get classesJoined => 'Guruhga qo‘shildingiz';

  @override
  String classesYouTeacher(int count) {
    return 'Siz — ustoz · $count a’zo';
  }

  @override
  String get classesYouStudent => 'Siz — talaba';

  @override
  String get classesGroupMissing =>
      'Guruh topilmadi yoki siz endi a’zo emassiz';

  @override
  String get classesBackToList => 'Guruhlar ro‘yxatiga';

  @override
  String get classesAssignments => 'Topshiriqlar';

  @override
  String get classesNoAssignmentsTeacher =>
      'Hali topshiriq yo‘q. Savol bankidan mavzu va sonni tanlab topshiriq bering.';

  @override
  String get classesNoAssignmentsStudent => 'Hozircha topshiriq yo‘q';

  @override
  String get classesNoAssignmentsStudentBody =>
      'Ustoz topshiriq berganda shu yerda paydo bo‘ladi.';

  @override
  String get classesNoDue => 'muddatsiz';

  @override
  String classesDue(String date) {
    return 'muddat $date';
  }

  @override
  String classesSubmittedOf(int done, int total) {
    return '$done/$total topshirdi';
  }

  @override
  String classesMembersTitle(int count) {
    return 'Talabalar · $count';
  }

  @override
  String get classesNoStudents => 'Hali talaba qo‘shilmagan — kodni yuboring.';

  @override
  String get classesMemberNoWork => 'Hali topshirmagan';

  @override
  String classesMemberSummary(int done, int total, int avg) {
    return '$done/$total topshiriq · o‘rtacha $avg%';
  }

  @override
  String get classesRemove => 'Guruhdan chiqarish';

  @override
  String classesRemoveTitle(String name) {
    return '$name guruhdan chiqarilsinmi?';
  }

  @override
  String get classesRemoveBody =>
      'U guruhni va yangi topshiriqlarni ko‘rmaydi. Topshirgan natijalari o‘chmaydi.';

  @override
  String get classesRemoveAction => 'Chiqarish';

  @override
  String classesStatusDone(int score, int total) {
    return 'Topshirildi · $score/$total';
  }

  @override
  String get classesStatusInProgress => 'Davom etmoqda';

  @override
  String get classesStatusPending => 'Yuborilmagan';

  @override
  String get classesStatusOverdue => 'Muddat o‘tgan';

  @override
  String get classesStatusNew => 'Yangi';

  @override
  String get classesStudentNote =>
      'Ustoz faqat siz yozgan ismni va topshiriq natijalaringizni ko‘radi.';

  @override
  String get classesLeave => 'Guruhdan chiqish';

  @override
  String get classesLeaveTitle => 'Guruhdan chiqasizmi?';

  @override
  String get classesLeaveBody =>
      'Qayta qo‘shilish uchun ustozdan kod kerak bo‘ladi. Topshirgan natijalaringiz ustozda qoladi.';

  @override
  String get classesLeaveAction => 'Chiqish';

  @override
  String get classesDeleteGroup => 'Guruhni o‘chirish';

  @override
  String classesDeleteGroupTitle(String name) {
    return '«$name» guruhi o‘chirilsinmi?';
  }

  @override
  String get classesDeleteGroupBody =>
      'Guruh, undagi topshiriqlar va talabalar natijalari butunlay o‘chadi. Qaytarib bo‘lmaydi.';

  @override
  String get classesDeleteGroupAction => 'O‘chirish';

  @override
  String get classesInviteTitle => 'Taklif kodi';

  @override
  String get classesInviteBody =>
      'Talabalar QR kodni telefon kamerasi bilan skanerlaydi va “Ilovada ochish” ni bosadi — yoki: O‘rganish → Guruh va topshiriqlar → Kod bilan qo‘shilish.';

  @override
  String get classesCopyCode => 'Kodni nusxalash';

  @override
  String get classesCopyInvite => 'Taklif matnini nusxalash';

  @override
  String get classesCopied => 'Nusxalandi';

  @override
  String classesInviteText(String name, String code) {
    return 'LabGuide ilovasidagi “$name” guruhiga qo‘shiling: O‘rganish → Guruh va topshiriqlar → Kod bilan qo‘shilish. Kod: $code';
  }

  @override
  String get classesAssignmentTitle => 'Topshiriq nomi';

  @override
  String get classesTimeLimit => 'Vaqt chegarasi, daqiqa';

  @override
  String get classesNoLimit => 'Vaqtsiz';

  @override
  String get classesDueNone => 'Muddatsiz';

  @override
  String classesDueDays(int count) {
    return '$count kun';
  }

  @override
  String get classesDuePick => 'Sana tanlash';

  @override
  String get classesDueNoneBody =>
      'Muddat yo‘q — talabalar istalgan vaqtda topshiradi.';

  @override
  String classesDueAt(String date) {
    return 'Muddat: $date gacha';
  }

  @override
  String classesPreview(int count) {
    return 'Tanlangan savollar · $count';
  }

  @override
  String get classesReshuffle => 'Boshqa savollar';

  @override
  String get classesKeyNotice =>
      'Talabalar to‘g‘ri javoblarni oldindan ko‘rmaydi — ball serverda hisoblanadi. Har talaba bir marta topshiradi.';

  @override
  String get classesSendAssignment => 'Topshiriqni berish';

  @override
  String get classesSubmitted => 'Javoblar yuborildi';

  @override
  String get classesSubmitNetwork =>
      'Internet yo‘q — javoblar qurilmada saqlandi. Keyin qayta yuboring.';

  @override
  String get classesSubmitRejected =>
      'Server javoblarni qabul qilmadi: vaqt yoki muddat tugagan, yoki topshiriq avval topshirilgan.';

  @override
  String get classesAssignmentMissing => 'Topshiriq topilmadi';

  @override
  String get classesMetricQuestions => 'Savollar';

  @override
  String get classesMetricLimit => 'Vaqt chegarasi';

  @override
  String get classesMetricDue => 'Muddat';

  @override
  String get classesMetricSubmitted => 'Topshirdi';

  @override
  String get classesMetricAverage => 'O‘rtacha ball';

  @override
  String get classesPendingTitle => 'Javoblar hali yuborilmagan';

  @override
  String get classesPendingBody =>
      'Ular qurilmada saqlangan. Internet ulanganda qayta yuboring — server vaqt chegarasi ichida qabul qiladi.';

  @override
  String get classesResend => 'Qayta yuborish';

  @override
  String get classesOverdueTitle => 'Muddat o‘tgan';

  @override
  String get classesOverdueBody => 'Bu topshiriqni endi topshirib bo‘lmaydi.';

  @override
  String classesOutdatedPack(int count) {
    return 'Bu topshiriqdagi $count ta savol ilovangizdagi to‘plamda yo‘q. Ilovani yangilang.';
  }

  @override
  String classesStartNotice(int minutes) {
    return 'Boshlaganingizdan so‘ng $minutes daqiqa beriladi — vaqt to‘xtamaydi, tugaganda javoblar o‘zi yuboriladi. Bir marta topshiriladi; yuborish uchun internet kerak.';
  }

  @override
  String get classesStartNoticeNoLimit =>
      'Vaqt chegarasi yo‘q. Javoblar bir marta yuboriladi, qayta topshirib bo‘lmaydi; yuborish uchun internet kerak.';

  @override
  String get classesStart => 'Boshlash';

  @override
  String classesSubmittedAt(String date) {
    return 'Topshirildi: $date';
  }

  @override
  String get classesServerScore => 'Ball serverda hisoblandi';

  @override
  String get classesResults => 'Natijalar';

  @override
  String get classesColStudent => 'Talaba';

  @override
  String get classesColScore => 'Ball · %';

  @override
  String get classesNotSubmitted => 'Topshirmagan';

  @override
  String get classesByQuestion => 'Savollar bo‘yicha';

  @override
  String get classesByQuestionEmpty => 'Hali hech kim topshirmagan.';

  @override
  String classesWrongOf(int wrong, int total) {
    return '$wrong/$total xato';
  }

  @override
  String get classesSending => 'Javoblar yuborilmoqda…';

  @override
  String get classesMyProgress => 'Mening natijalarim';

  @override
  String classesDoneOf(int done, int total) {
    return '$done/$total topshiriq bajarildi';
  }

  @override
  String classesAverage(int avg) {
    return 'O‘rtacha ball: $avg%';
  }

  @override
  String get classesStudentResultTitle => 'Talaba natijasi';

  @override
  String get classesStudentAnswer => 'Talaba javobi';

  @override
  String get classesInviteMore => 'Yana talaba taklif qilish';

  @override
  String get profileTitle => 'Profil va sozlamalar';

  @override
  String get profileGuest => 'Mehmon';

  @override
  String get profileGuestSub => 'Kontent hisobsiz ochiq';

  @override
  String get profileGuestLocal => 'Ma’lumotlar faqat shu qurilmada';

  @override
  String get profileDemoSession => 'Demo sessiya · debug build';

  @override
  String get profileRole => 'Yo‘nalish';

  @override
  String get profileRoleSub => 'Bosh sahifa sizga moslashadi';

  @override
  String get profileLanguage => 'Til';

  @override
  String get profileUnits => 'Birliklar';

  @override
  String get profileUnitsSi => 'SI (mmol/L, µmol/L)';

  @override
  String get profileUnitsConventional => 'An’anaviy (mg/dL)';

  @override
  String get profileAttestation => 'Bilim va malakani baholash';

  @override
  String get profileAttestationShow => 'Ko‘rsatish';

  @override
  String get profileAttestationNone => 'Yashirish';

  @override
  String get profileAttestationNote =>
      'Bilim va malakani baholash bo‘limi barcha tillarda va barcha davlatlarda ko‘rinadi. Bo‘limni ilovadan olib tashlash uchun “Yashirish” ni tanlang.';

  @override
  String get profileAppearance => 'Tashqi ko‘rinish';

  @override
  String get themeSystem => 'Tizim';

  @override
  String get themeLight => 'Kunduzgi';

  @override
  String get themeDark => 'Tungi';

  @override
  String get themeTitle => 'Mavzu';

  @override
  String get themeRowSub => 'Ilova ranglari va sarlavha shrifti';

  @override
  String get themeCurrent => 'Joriy mavzu';

  @override
  String get themeClassicName => 'Klassik';

  @override
  String get themeClassicDesc => 'LabGuide yashil ranglari';

  @override
  String get themeIvoryName => 'Ivory';

  @override
  String get themeIvoryDesc =>
      'Fil suyagi, qora va oltin, nafis serif sarlavhalar';

  @override
  String get themeModeSection => 'Kunduzgi yoki tungi';

  @override
  String get themeSelected => 'Tanlangan';

  @override
  String get profilePrivacy => 'Maxfiylik va ma’lumotlar';

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
      'Hisobingiz, kirish usullari (Google/Apple bog‘lanishi), guruhlardagi a’zolik va natijalaringiz, “Taklif va yordam” murojaatlari va hamjamiyatdagi savol-javoblaringiz serverdan butunlay o‘chiriladi. Ustoz bo‘lsangiz, yaratgan guruhlaringiz ham o‘chadi. Buni qaytarib bo‘lmaydi. Ilova ichida yuborgan shikoyatlar matni hisobga bog‘lanmagan holda qoladi. Qurilmadagi ma’lumotlar ham tozalanadi.';

  @override
  String get accountDeleted => 'Hisob o‘chirildi';

  @override
  String get adminTitle => 'Admin panel';

  @override
  String get adminSub => 'Moderatsiya, murojaatlar, kontent, adminlar';

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
  String get privacyTitle => 'Maxfiylik va ma’lumotlar';

  @override
  String get privacyBody =>
      'Asosiy bo‘limlar hisobsiz (mehmon rejimida) ishlaydi: sozlamalar, xatcho‘plar, QC qaydlari, apparatlaringiz va mashq natijalari shu qurilmada saqlanadi. Hisob ixtiyoriy (email kodi, Google yoki Apple bilan) — guruhlar, hamjamiyat va “Taklif va yordam” uchun kerak. Bunda ma’lumotlar Cloudflare serverida (Sharqiy Yevropa, O‘zbekistondan tashqarida) saqlanadi: email faqat hash va niqoblangan ko‘rinishda, kirish usuli, rol, til, oxirgi faollik vaqti (daqiqagacha); guruhda — taxallus yoki tartib raqami, test javoblari va ballar; murojaat va shikoyat matnlari. Google/Apple’dan faqat hisob identifikatori va email olinadi, token saqlanmaydi. Ustoz faqat o‘z guruhini ko‘radi. Reklama, analitika va kuzatuv yo‘q. To‘liq matn — “Maxfiylik siyosati” havolasida.';

  @override
  String get privacyBodyLocal =>
      'Bu buildda server ulanmagan: ilova serverga hech narsa yubormaydi. Sozlamalar, xatcho‘plar, QC qaydlari, apparatlaringiz va mashq natijalari shu qurilmada saqlanadi (qurilmaning o‘z zaxira nusxasiga kirishi mumkin). Reklama va kuzatuv yo‘q.';

  @override
  String get privacyTerms => 'Foydalanish shartlari';

  @override
  String get privacyTermsSub =>
      'Ilovadan va hisobingizdan foydalanish qoidalari';

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
      'LabGuide — klinik laboratoriya bo‘yicha bepul ma’lumotnoma va o‘quv ilovasi. Ilovadan foydalanib, siz quyidagi shartlarga rozilik bildirasiz.\n\n1. Tibbiy cheklov. LabGuide tashxis qo‘ymaydi, davolash yoki dori buyurmaydi va laboratoriyangizning tasdiqlangan tartiblari, reagent va analizator yo‘riqnomalari (IFU) hamda shifokor xulosasini almashtirmaydi. Har bir ma’lumot ostida manbasi ko‘rsatilgan; qaror qabul qilishda asl manba va o‘z muassasangiz qoidalariga tayaning.\n\n2. Hisob. Ba’zi imkoniyatlar (guruhlar, testlar, hamjamiyat, murojaatlar) uchun email orqali ro‘yxatdan o‘tish kerak. Hisobingiz xavfsizligi va u orqali qilingan harakatlar uchun o‘zingiz javobgarsiz. Hisobni istalgan vaqtda Profil → Hisobni o‘chirish orqali o‘chirishingiz mumkin.\n\n3. Ustoz va talaba guruhlari. Talaba guruhga qo‘shilganda ustoz uning taxallusi (yoki tartib raqami) va test natijalarini ko‘radi. Ustoz guruhni faqat o‘quv maqsadida boshqaradi.\n\n4. Foydalanuvchi kontenti. Hamjamiyatda va murojaatlarda yozganlaringiz uchun o‘zingiz javobgarsiz. Haqoratli, noqonuniy, reklama, boshqa shaxsning shaxsiy ma’lumoti yoki roziligisiz intim tasvirlar joylash qat’iyan taqiqlanadi. Bunday kontent o‘chiriladi, qoidabuzar hisobi cheklanishi yoki o‘chirilishi mumkin. Har bir xabarni “Shikoyat” orqali bildirishingiz mumkin.\n\n5. Mualliflik huquqi. Ilova matnlari, slaydlari, testlari va dizayni LabGuide mualliflariga tegishli; tashqi manbalar o‘z litsenziyasi bilan ko‘rsatilgan. Ularni tijorat maqsadida nusxalash va tarqatish mumkin emas.\n\n6. Xizmat. Ilova “boricha” taqdim etiladi; uzilishlar va xatolar bo‘lishi mumkin, biz ularni imkon qadar tez tuzatamiz. Shartlar o‘zgarsa, ilovada xabar beramiz.\n\n7. Maxfiylik. Ma’lumotlaringiz qanday ishlatilishi maxfiylik siyosatida yozilgan: labguide.nfcstore.uz/privacy\n\n8. Aloqa: labguide@nfcstore.uz';

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
  String get libIntake => 'Materiallarni qo‘shish';

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
  String get libItemUnavailable => 'Material sizning tilingizda mavjud emas';

  @override
  String get libItemUnavailableBody =>
      'Bu material hozircha faqat boshqa tilda mavjud. Interfeys tilini o‘zgartiring yoki katalogga qayting.';

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
  String get intakeStep5 => 'Tasdiqlandi — domla ko‘rib chiqdi.';

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
  String get lessonsTitle => 'Dars mavzulari';

  @override
  String get analyteTreatmentGoals => 'Davolash maqsadi';

  @override
  String get analyteTreatmentGoalsNotice =>
      'Davolash maqsadi shifokor tomonidan bemorning to‘liq xavf baholashi asosida belgilanadi; ilova xavf kategoriyasini aniqlamaydi.';

  @override
  String get analyteTreatmentGoalsNotRef =>
      'Davolash maqsadi referens interval ham, diagnostik chegara ham emas. Qo‘llanmalar xavf guruhlarini turlicha belgilaydi — qiymatlarni faqat bitta jadval ichida solishtiring.';

  @override
  String analyteGoalHistorical(String current) {
    return 'Tarixiy yo‘riqnoma, o‘rniga: $current. Faqat kontekst uchun ko‘rsatilgan — hozirgi davolash qarorlari uchun emas.';
  }

  @override
  String analyteGoalGuideline(String name, String year) {
    return '$name · $year';
  }

  @override
  String get analyteAgentCheck => 'Manbalar bilan solishtirilgan';

  @override
  String get analyteExpertApproval => 'Mutaxassis tasdig‘i';

  @override
  String classesSeat(String n) {
    return 'Talaba $n';
  }

  @override
  String classesQrLabel(String code) {
    return 'Taklif kodi QR: $code';
  }

  @override
  String get classesTeacherRegisterEyebrow => 'Ustoz';

  @override
  String get classesTeacherRegisterTitle =>
      'O‘zingizni ustoz sifatida ro‘yxatdan o‘tkazing';

  @override
  String get classesTeacherRegisterBody =>
      'Ustoz o‘z guruhini ochadi va faqat o‘z talabalari natijasini ko‘radi. Bu admin huquqi emas va boshqa guruhlarga ta’sir qilmaydi.';

  @override
  String get classesTeacherRegister => 'Ustoz sifatida ro‘yxatdan o‘tish';

  @override
  String get classesLocalNameTitle => 'Belgi (faqat shu qurilmada)';

  @override
  String get classesLocalNameBody =>
      'Masalan, talabaning ismi. Serverga yuborilmaydi va talaba ko‘rmaydi.';

  @override
  String get classesLocalNameHint => 'Bo‘sh — belgini o‘chirish';

  @override
  String get classesLocalNameSave => 'Saqlash';

  @override
  String get classroomPlanTitle => 'O‘quv rejasi';

  @override
  String get classroomPlanSub =>
      'Kunlar bo‘yicha mavzular: ma’ruza, savol-javob, test';

  @override
  String get classroomTopicsTitle => 'Mavzular';

  @override
  String get classroomTopicsSub => 'Ustoz ochgan mavzular va testlar';

  @override
  String get classroomProgramEyebrow => 'O‘quv dasturi';

  @override
  String classroomPlanProgress(int done, int total) {
    return '$done/$total mavzu testi yakunlangan';
  }

  @override
  String get classroomStartNone =>
      'Boshlanish sanasi belgilanmagan — jadval kun tartibi bilan';

  @override
  String classroomStartAt(String date) {
    return '1-o‘quv kuni: $date';
  }

  @override
  String get classroomStartNote =>
      'Sanalar taxminiy (yakshanba o‘tkaziladi, bayramlar hisobga olinmaydi) va faqat shu qurilmada saqlanadi.';

  @override
  String get classroomStartPick => 'Boshlanish sanasini belgilash';

  @override
  String classroomDayN(int n) {
    return '$n-kun';
  }

  @override
  String classroomWeekN(int n) {
    return '$n-hafta';
  }

  @override
  String classroomHours(int n) {
    return '$n soat';
  }

  @override
  String get classroomTypeLecture => 'Ma’ruza';

  @override
  String get classroomTypePractical => 'Amaliy';

  @override
  String get classroomTypeSeminar => 'Seminar';

  @override
  String get classroomTypeAttestation => 'Attestatsiya';

  @override
  String get classroomTypeOther => 'Mashg‘ulot';

  @override
  String get classroomStatusClosed => 'Ochilmagan';

  @override
  String get classroomStatusOpened => 'Ochildi';

  @override
  String get classroomStatusLectured => 'O‘tildi';

  @override
  String get classroomStatusOral => 'Savol-javob o‘tdi';

  @override
  String get classroomStatusTestRunning => 'Test davom etmoqda';

  @override
  String get classroomStatusTestDone => 'Test yakunlandi';

  @override
  String get classroomNoCurriculumTitle => 'O‘quv dasturi hali qo‘shilmagan';

  @override
  String get classroomNoCurriculumBody =>
      'Kurs jadvali (modul → mavzu → materiallar) ilovaning keyingi versiyasida keladi. Hozircha guruh topshiriqlaridan foydalaning.';

  @override
  String get classroomCurriculumError => 'O‘quv dasturini o‘qib bo‘lmadi';

  @override
  String get classroomNoTopicsStudent => 'Ustoz hali mavzu ochmagan';

  @override
  String get classroomNoTopicsStudentBody =>
      'Mavzu ochilganda materiallar va test shu yerda chiqadi.';

  @override
  String get classroomTopicTitle => 'Mavzu';

  @override
  String get classroomTopicMissing => 'Mavzu o‘quv dasturida topilmadi';

  @override
  String get classroomTopicNotOpened => 'Bu mavzu hali ochilmagan';

  @override
  String get classroomOpenNote =>
      'Ochilgandan keyin talabalar mavzu materiallarini ko‘radi.';

  @override
  String get classroomOpenTopic => 'Talabalarga ochish';

  @override
  String classroomStep(int n) {
    return '$n-bosqich';
  }

  @override
  String get classroomStageLecture => 'Ma’ruza';

  @override
  String get classroomStageLectureBody =>
      'Mavzuni katta ekranda slaydlar bilan ko‘rsating (internetsiz ham ishlaydi).';

  @override
  String get classroomStageOral => 'Og‘zaki savol-javob';

  @override
  String classroomStageOralBody(int count) {
    return 'Savollar ro‘yxati va javob rejasi. So‘ralgan: $count.';
  }

  @override
  String get classroomStageTest => 'Guruh testi';

  @override
  String get classroomStageTestBody =>
      'Savollarni tanlang va testni boshlang — talabalarda darhol ochiladi.';

  @override
  String get classroomStageDone => 'O‘tildi';

  @override
  String get classroomMarkDone => 'O‘tildi deb belgilash';

  @override
  String get classroomOralOpen => 'Savollar ro‘yxati';

  @override
  String get classroomTestPrepare => 'Testni tayyorlash';

  @override
  String get classroomTestResults => 'Natijalar paneli';

  @override
  String get classroomTestFinish => 'Testni yakunlash';

  @override
  String get classroomTestFinishTitle => 'Test yakunlansinmi?';

  @override
  String get classroomTestFinishBody =>
      'Yangi urinish qabul qilinmaydi. Boshlab qo‘yganlar javobini yuborishi uchun 2 daqiqa qoladi.';

  @override
  String classroomTestSubmitted(int done, int total) {
    return '$done/$total talaba topshirdi';
  }

  @override
  String get classroomTestNotStarted => 'Ustoz hali testni boshlamagan.';

  @override
  String get classroomTestOpenStudent => 'Test ochiq — yechish';

  @override
  String get classroomMaterials => 'Mavzu materiallari';

  @override
  String get classroomNoMaterials =>
      'Ilovada bu mavzuga bog‘langan material hali yo‘q.';

  @override
  String get classroomGapNote =>
      'Ilovada bu mavzu bo‘yicha material kam — ustoz o‘z manbalaridan to‘ldiradi.';

  @override
  String get classroomKindAnalyte => 'Tahlil kartasi';

  @override
  String get classroomKindCondition => 'Holat';

  @override
  String get classroomKindReference => 'Jadval';

  @override
  String get classroomKindAtlas => 'Mikroskopiya atlasi';

  @override
  String get classroomKindTool => 'Kalkulyator va asbob';

  @override
  String get classroomToolQc => 'Sifat nazorati';

  @override
  String get classroomToolPreanalytics => 'Preanalitika';

  @override
  String get classroomToolInstruments => 'Apparatlar';

  @override
  String get classroomToolCalibration => 'Kalibrlash jurnali';

  @override
  String get classroomToolDifferential => 'Leykoformula';

  @override
  String get classroomPlanRecommended => 'LabGuide tavsiya etgan amaliy reja';

  @override
  String get classroomOralNotice =>
      'Savollar avtomatik tanlangan nomzodlar; javob rejasi — o‘quv yordami. “So‘raldi” va baholar faqat shu qurilmada saqlanadi.';

  @override
  String get classroomOralEmpty => 'Bu mavzu uchun og‘zaki savol topilmadi';

  @override
  String classroomCandidate(int n) {
    return 'Nomzod savol $n';
  }

  @override
  String get classroomOralPlan => 'Qisqa javob rejasi';

  @override
  String get classroomOralNoPlan => 'Javob rejasi hali yozilmagan.';

  @override
  String get classroomOralAsked => 'So‘raldi';

  @override
  String classroomOralGrade(int count) {
    return 'Talabalarni baholash ($count)';
  }

  @override
  String get classroomOralGradeTitle => 'Kim qanday javob berdi';

  @override
  String get classroomOralGradeNote =>
      'Faqat shu qurilmada; serverga yuborilmaydi.';

  @override
  String get classroomGradeKnew => 'Bildi';

  @override
  String get classroomGradePartial => 'Qisman';

  @override
  String get classroomGradeDidNot => 'Bilmadi';

  @override
  String get classroomCandidatesNotice =>
      'Nomzod savollar avtomatik tanlangan. Har birini va kalitini ko‘rib chiqing: ball ko‘rsatilgan kalit bo‘yicha serverda hisoblanadi.';

  @override
  String classroomCandidatesTitle(int picked, int total) {
    return 'Nomzodlar · tanlandi $picked/$total';
  }

  @override
  String get classroomPickAll => 'Hammasi';

  @override
  String get classroomPickNone => 'Bekor qilish';

  @override
  String classroomKeyShown(String answer) {
    return 'Kalit: $answer';
  }

  @override
  String get classroomKeyFlagged => 'Kalit bahsli';

  @override
  String get classroomPickAtLeastOne => 'Kamida bitta savol tanlang';

  @override
  String get classroomPickMax => 'Ko‘pi bilan 50 ta savol';

  @override
  String classroomTestStart(int count) {
    return 'Testni boshlash · $count savol';
  }

  @override
  String get classroomTestStarted => 'Test boshlandi — talabalarda ochildi';

  @override
  String classroomTestTitle(String topic) {
    return 'Test: $topic';
  }

  @override
  String get classroomTestAlready => 'Bu mavzu testi allaqachon boshlangan';

  @override
  String get classroomTestNoCandidates =>
      'Bu mavzu uchun test savoli topilmadi';

  @override
  String get classroomTestNoCandidatesBody =>
      'Guruh topshirig‘ini qo‘lda tuzishingiz mumkin (Yangi topshiriq).';

  @override
  String get lectureTitle => 'Ma’ruza';

  @override
  String get lectureListTitle => 'Ma’ruza rejimi';

  @override
  String get lectureListSub =>
      'Mavzuni tanlang — slaydlar katta ekranda, internetsiz';

  @override
  String get lectureStart => 'Ma’ruzani boshlash';

  @override
  String get lectureClose => 'Ma’ruzani yopish';

  @override
  String lectureCounter(int current, int total) {
    return '$current / $total';
  }

  @override
  String get lecturePrev => 'Orqaga';

  @override
  String get lectureNext => 'Oldinga';

  @override
  String get lectureGoals => 'Maqsad';

  @override
  String get lectureKeyPoints => 'Asosiy tushunchalar';

  @override
  String get lectureConcepts => 'Asosiy tahlillar';

  @override
  String get lectureConditions => 'Klinik holatlar';

  @override
  String get lectureTables => 'Jadvallar va algoritmlar';

  @override
  String get lectureAtlas => 'Mikroskopiya';

  @override
  String get lectureTools => 'Hisoblash va asboblar';

  @override
  String lectureQuestionN(int n) {
    return 'Savol $n';
  }

  @override
  String get lectureEndEyebrow => 'Keyingi qadam';

  @override
  String get lectureEndTitle => 'Savol-javob va test';

  @override
  String get lectureEndOral => 'Og‘zaki savol-javob — ustoz so‘raydi';

  @override
  String get lectureEndTest => 'Guruh testi — ilovada, vaqt bilan';

  @override
  String get lectureDraftNotice =>
      'Taqdimot manbalarga asoslangan — darsdan oldin mazmunni ko‘rib chiqing';

  @override
  String get lectureUzOnly => 'Bu taqdimot hozircha faqat o‘zbek tilida';

  @override
  String get lectureNotesShow => 'Ustoz izohini ko‘rsatish';

  @override
  String get lectureNotesHide => 'Ustoz izohini yashirish';

  @override
  String get lectureTeacherNote => 'Ustoz uchun izoh';

  @override
  String get lectureAutoModeAuto => 'Avto';

  @override
  String get lectureAutoModeManual => 'Qo‘lda';

  @override
  String get lectureAutoPause => 'Pauza';

  @override
  String get lectureAutoResume => 'Davom etish';

  @override
  String lectureAutoSeconds(int n) {
    return '$n soniya';
  }

  @override
  String get lectureAutoToggleLabel => 'Slaydlarni avtomatik varaqlash';

  @override
  String get lectureAutoSpeedTitle => 'Varaqlash tezligi';

  @override
  String get cmTitle => 'Hamjamiyat · Savol-javob';

  @override
  String get cmHomeSub =>
      'Tasdiqlangan laboratoriya mutaxassislari javob beradi';

  @override
  String get cmAsk => 'Savol berish';

  @override
  String get cmAllQuestions => 'Barcha savollar';

  @override
  String get cmEmptyTitle => 'Hali savollar yo‘q';

  @override
  String get cmEmptyBody => 'Birinchi savolni siz bering.';

  @override
  String cmTopicLinkAnalyte(int count) {
    return 'Bu tahlil bo‘yicha savollar ($count)';
  }

  @override
  String cmTopicLinkCondition(int count) {
    return 'Bu holat bo‘yicha savollar ($count)';
  }

  @override
  String get cmTopicLinkSub => 'Hamjamiyat · mutaxassislar javoblari';

  @override
  String cmTopicLabel(String name) {
    return 'Mavzu: $name';
  }

  @override
  String get cmMyQuestions => 'Mening savollarim';

  @override
  String get cmMyQuestionsSub => 'Bergan savollaringiz va javoblar';

  @override
  String get cmVerifyTitle => 'Mutaxassis tasdiqlash';

  @override
  String get cmVerifySub => 'Javob yozish uchun hujjat yuklang';

  @override
  String get cmBadgeAi => '✓ Mutaxassis (hujjat avtomatik tekshirilgan)';

  @override
  String get cmBadgeManual => '✓ Tasdiqlangan mutaxassis';

  @override
  String get cmBadgeInfo =>
      '“Hujjat avtomatik tekshirilgan” — hujjatni inson emas, sun’iy intellekt modeli tekshirgan. Noto‘g‘ri belgi haqida shikoyat qilish mumkin.';

  @override
  String get cmMember => 'Foydalanuvchi';

  @override
  String get cmYou => 'siz';

  @override
  String get cmVerifyInfoTitle => 'Avtomatik tekshiruv — fayl saqlanmaydi';

  @override
  String get cmVerifyInfo =>
      'Hujjatni sun’iy intellekt modeli (Cloudflare Workers AI) avtomatik tekshiradi — uni inson ko‘rmaydi. Fayl hech qayerda saqlanmaydi va tekshiruvdan so‘ng darhol o‘chadi. Serverda faqat natija qoladi: rol, mamlakat, holat va sana. Avtomatik tekshiruv xato qilishi mumkin; boshqa foydalanuvchilar noto‘g‘ri belgi haqida shikoyat qilsa, belgi admin ko‘rib chiqquncha to‘xtatiladi.';

  @override
  String get cmVerifyRole => 'Kasbingiz';

  @override
  String get cmRoleLaborant => 'Laborant';

  @override
  String get cmRoleBiochemist => 'Biokimyogar';

  @override
  String get cmRoleKdlDoctor => 'KDL shifokori';

  @override
  String get cmRoleTeacher => 'Ustoz';

  @override
  String get cmRoleOther => 'Boshqa';

  @override
  String get cmRoleClinicalLab => 'Klinik laborator diagnostika';

  @override
  String get cmVerifyCountry => 'Mamlakat (2 harfli kod, masalan UZ)';

  @override
  String get cmVerifyCountryError => '2 harfli mamlakat kodini kiriting';

  @override
  String get cmVerifyDocHint =>
      'Diplom, sertifikat yoki ish joyidan hujjat. JPEG yoki PNG surat, 5 MB gacha. PDF bo‘lsa — birinchi sahifasini suratga oling. Bemor ma’lumotini yoping.';

  @override
  String get cmVerifyCamera => 'Suratga olish';

  @override
  String get cmVerifyGallery => 'Galereyadan tanlash';

  @override
  String get cmVerifyRemove => 'Boshqasini tanlash';

  @override
  String get cmVerifySubmit => 'Avtomatik tekshiruvga yuborish';

  @override
  String get cmVerifyAttempts => 'Kuniga 3 tagacha urinish.';

  @override
  String get cmStatusNone => 'Hali tasdiqlanmagan';

  @override
  String get cmStatusVerified => 'Tasdiqlangan';

  @override
  String get cmStatusRejected =>
      'Hujjat qabul qilinmadi. Muassasa va mutaxassislik aniq ko‘rinadigan suratda qayta urinib ko‘ring.';

  @override
  String get cmStatusSuspended =>
      'Foydalanuvchilar shikoyati sababli hamjamiyatdagi hisobingiz to‘xtatilgan. Admin ko‘rib chiqadi.';

  @override
  String cmVerifiedAt(String date) {
    return 'Tasdiqlangan: $date';
  }

  @override
  String get cmMethodAi => 'Usul: avtomatik (AI)';

  @override
  String get cmMethodManual => 'Usul: hujjat qo‘lda tekshirilgan';

  @override
  String get cmErrTooLarge => 'Fayl 5 MB dan katta.';

  @override
  String get cmErrType => 'Faqat JPEG yoki PNG surat.';

  @override
  String get cmErrAi =>
      'Avtomatik tekshiruv hozir ishlamayapti. Keyinroq urinib ko‘ring.';

  @override
  String get cmErrNotVerified =>
      'Javob va ovoz faqat tasdiqlangan mutaxassislarga.';

  @override
  String get cmErrContact =>
      'Matndan email va telefon raqamini (va bemor ma’lumotini) olib tashlang.';

  @override
  String get cmErrLength => 'Sarlavha 10–200, matn 10–4000 belgi bo‘lsin.';

  @override
  String get cmErrAlreadyVerified => 'Siz allaqachon tasdiqlangansiz.';

  @override
  String get cmErrRevoked =>
      'Mutaxassis maqomingizni admin bekor qilgan. Avtomatik qayta tekshiruv mavjud emas.';

  @override
  String get cmAskTitleField => 'Savol sarlavhasi';

  @override
  String get cmAskBodyField => 'Batafsil';

  @override
  String get cmAskNoPatient =>
      'Bemorning ismi, telefoni va boshqa shaxsiy ma’lumotini yozmang. Javoblar — hamkasblar tajribasi, shaxsiy tibbiy maslahat emas.';

  @override
  String get cmAskSend => 'Savolni joylash';

  @override
  String get cmAskSent => 'Savol joylandi';

  @override
  String get cmSignInTitle => 'Ishtirok etish uchun hisobga kiring';

  @override
  String get cmSignInBody =>
      'Hisobga kirgan har kim savol beradi. Tasdiqlangan mutaxassislar javob yozadi.';

  @override
  String cmAnswers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta javob',
      zero: 'Javob yo‘q',
    );
    return '$_temp0';
  }

  @override
  String get cmAnswerField => 'Javobingiz';

  @override
  String get cmAnswerSend => 'Javobni yuborish';

  @override
  String get cmAnswerOnlySpecialists =>
      'Javobni faqat tasdiqlangan mutaxassislar yozadi.';

  @override
  String get cmBest => 'Eng yaxshi javob';

  @override
  String get cmMarkBest => 'Eng yaxshi deb belgilash';

  @override
  String get cmUnmarkBest => 'Belgini olish';

  @override
  String cmUpvote(int count) {
    return 'Foydali ($count)';
  }

  @override
  String get cmReport => 'Shikoyat';

  @override
  String get cmReportTitle => 'Shikoyat sababi';

  @override
  String get cmReasonSpam => 'Spam yoki reklama';

  @override
  String get cmReasonWrong => 'Noto‘g‘ri yoki xavfli ma’lumot';

  @override
  String get cmReasonAbuse => 'Haqoratli';

  @override
  String get cmReasonFake => 'Soxta mutaxassis';

  @override
  String get cmReasonPatient => 'Bemor ma’lumoti bor';

  @override
  String get cmReasonOther => 'Boshqa';

  @override
  String get cmReportSent => 'Shikoyat yuborildi. Rahmat.';

  @override
  String get cmTranslate => 'Tarjima qilish';

  @override
  String get cmMachineTranslation => 'Mashina tarjimasi';

  @override
  String get cmShowOriginal => 'Asl matn';

  @override
  String get cmShowTranslation => 'Tarjima';

  @override
  String get cmPin => 'Qadash';

  @override
  String get cmUnpin => 'Qadashni olish';

  @override
  String get cmPinned => 'Qadalgan';

  @override
  String get cmDelete => 'O‘chirish';

  @override
  String get cmDeleteConfirm => 'Bu post o‘chirilsinmi?';

  @override
  String get cmDeleted => 'O‘chirildi';

  @override
  String get cmLoadMore => 'Yana ko‘rsatish';

  @override
  String get cmNotAdvice =>
      'Javoblar — hamkasblar tajribasi, shaxsiy tibbiy maslahat emas.';

  @override
  String get cmRulesTitle => 'Hamjamiyat qoidalari';

  @override
  String get cmRulesIntro =>
      'LabGuide hamjamiyati — klinik laboratoriya diagnostikasi bo‘yicha tajriba almashish joyi.';

  @override
  String get cmRulesExpand => 'Qoidalarni ochish';

  @override
  String get cmRulesCollapse => 'Qoidalarni yopish';

  @override
  String get cmRulesH1 => 'Nima muhokama qilinadi';

  @override
  String get cmRulesA1 =>
      'tahlil natijalarini talqin qilish (nomuvofiq natijalar, soxta oshish/pasayish)';

  @override
  String get cmRulesA2 =>
      'preanalitika: qon olish, probirkalar, saqlash, gemoliz';

  @override
  String get cmRulesA3 => 'sifat nazorati (QC, Westgard qoidalari), kalibrovka';

  @override
  String get cmRulesA4 => 'analizatorlar va reagentlar bilan ishlash tajribasi';

  @override
  String get cmRulesA5 =>
      'gematologiya, mikroskopiya, biokimyo, immunologiya, siydik tahlili';

  @override
  String get cmRulesA6 =>
      'bilim va malakani baholash hamda o‘qish bo‘yicha savollar';

  @override
  String get cmRulesH2 => 'Qanday yozish kerak';

  @override
  String get cmRulesB1 =>
      'sarlavhada savolning mohiyati (masalan: “Kaliy yuqori, gemoliz yo‘q — nima sabab?”)';

  @override
  String get cmRulesB2 =>
      'batafsil qismida: qaysi tahlil, natija va birligi, usul yoki analizator, nima qilib ko‘rdingiz';

  @override
  String get cmRulesB3 =>
      'birliklarni aniq yozing: avval SI, qavs ichida an’anaviy (masalan 7,0 mmol/L (126 mg/dL))';

  @override
  String get cmRulesB4 => 'bir postda — bitta savol';

  @override
  String get cmRulesH3 => 'Nima yozilmaydi';

  @override
  String get cmRulesC1 =>
      'bemorning ismi, telefoni, manzili, karta raqami va shaxsini aniqlaydigan har qanday ma’lumot';

  @override
  String get cmRulesC2 =>
      'reklama, boshqa mavzular, haqoratli so‘zlar; intim yoki shaxsiy rasm va materiallarni egasining roziligisiz joylash qat’iyan taqiqlanadi';

  @override
  String get cmRulesC3 =>
      'bemor uchun shaxsiy davolash tavsiyasi — bu yerda hamkasblar tajribasi, shifokor maslahati emas';

  @override
  String get cmRulesH4 => 'Kim yoza oladi';

  @override
  String get cmRulesD1 => 'savolni — ro‘yxatdan o‘tgan har bir foydalanuvchi';

  @override
  String get cmRulesD2Pre =>
      'javobni — faqat “✓ Mutaxassis” belgisi bor tasdiqlangan mutaxassislar (';

  @override
  String get cmRulesD2Link => 'Profil → Mutaxassis tasdiqlash';

  @override
  String get cmRulesD2Post =>
      '; diplom yoki sertifikat rasmini yuklang; hujjat saqlanmaydi)';

  @override
  String get cmRulesD3 =>
      'qoidaga zid post ko‘rsangiz — “Shikoyat” tugmasini bosing';

  @override
  String get cmRulesOutro =>
      'Boshqa tildagi postlarni o‘qish uchun “Tarjima qilish” tugmasidan foydalaning. Hurmat va aniqlik — asosiy qoidamiz.';

  @override
  String get cmAdminTitle => 'Hamjamiyat moderatsiyasi';

  @override
  String get cmAdminSub => 'Shikoyat qilinganlar: tiklash yoki bekor qilish';

  @override
  String get cmAdminEmpty => 'Bu ro‘yxat bo‘sh';

  @override
  String cmAdminReporters(int count) {
    return '$count ta shikoyatchi';
  }

  @override
  String get cmAdminRestore => 'Tiklash';

  @override
  String get cmAdminRevoke => 'Tasdiqni bekor qilish';

  @override
  String get cmAdminSuspended => 'To‘xtatilgan';

  @override
  String get cmAdminVerified => 'Tasdiqlangan';

  @override
  String get cmAdminRejected => 'Rad etilgan';

  @override
  String get cmAdminDone => 'Bajarildi';

  @override
  String get cmOwnerTag => 'Asoschi';

  @override
  String get cmLaunchTitle => 'Hamjamiyatni ishga tushirish';

  @override
  String get cmLaunchBody =>
      'Bir marta bosing: hisobingiz asoschi sifatida tasdiqlanadi va boshlang‘ich savol-javoblar qo‘shiladi. Qayta bossangiz, takrorlanmaydi.';

  @override
  String get cmLaunchButton => 'Ishga tushirish';

  @override
  String cmLaunchDone(int questions, int answers) {
    return 'Tayyor: asoschi tasdiqlandi. Qo‘shildi: $questions ta savol, $answers ta javob.';
  }

  @override
  String get cmLaunchAlready =>
      'Hamjamiyat allaqachon ishga tushirilgan: asoschi tasdiqlangan, yangi narsa qo‘shilmadi.';

  @override
  String get cmLaunchNotOwner =>
      'Bu hisob asoschi sifatida ruxsat etilmagan. Asoschi emaili bilan kiring.';

  @override
  String get cmLaunchMfaHint =>
      'Hamjamiyatni ishga tushirish uchun avval ikki bosqichli himoyani tasdiqlang: autentifikator ilovasidagi 6 xonali kodni kiriting. Shundan keyin “Hamjamiyatni ishga tushirish” tugmasi chiqadi.';

  @override
  String get diffFbSound => 'Bosishda tovush';

  @override
  String get diffFbHaptics => 'Bosishda tebranish';

  @override
  String get diffFbOn => 'yoqilgan';

  @override
  String get diffFbOff => 'o‘chirilgan';

  @override
  String get admYouSuper => 'Siz — egasi (super admin)';

  @override
  String get admYouAdmin => 'Siz — admin';

  @override
  String get adm2faOn =>
      'Ikki bosqichli himoya (2FA) tasdiqlangan. Har bir admin amali uchun so‘raladi.';

  @override
  String get admReportsQueue => 'Shikoyatlar va a’zolar';

  @override
  String get admReportsSub =>
      'To‘xtatilganlar navbati, tasdiqlangan va rad etilgan a’zolar';

  @override
  String get admLaunchRow => 'Hamjamiyatni ishga tushirish';

  @override
  String get admLaunchRowSub =>
      'Asoschi tasdig‘i va boshlang‘ich savol-javoblar (bir marta)';

  @override
  String admPending(int count) {
    return 'Kutmoqda: $count';
  }

  @override
  String get admQueueEmpty => 'Navbat bo‘sh';

  @override
  String get admNotConnected => 'Bu serverda hali ulanmagan';

  @override
  String get admReview => 'Kontent tekshiruvi';

  @override
  String admReviewSub(int cards, int questions) {
    return 'Tekshirilmagan: $cards ta karta, $questions ta savol';
  }

  @override
  String get admTeam => 'Adminlar boshqaruvi';

  @override
  String admTeamCount(int count) {
    return 'Adminlar: $count';
  }

  @override
  String get admTeamSubManage => 'Email bo‘yicha qo‘shish va olib tashlash';

  @override
  String get admTeamSubView => 'Ro‘yxat (o‘zgartirish — faqat egasi)';

  @override
  String get admLegacyNote =>
      'Statistika, foydalanuvchilar, amallar tarixi va hamkorlar bo‘limlari bu serverga hali ko‘chirilmagan — tayyor bo‘lganda shu yerda chiqadi.';

  @override
  String get admOther => 'Boshqa bo‘limlar';

  @override
  String get admTeamIntro =>
      'Admin barcha admin bo‘limlariga to‘liq kiradi: hamjamiyat moderatsiyasi, murojaatlar, kontent tekshiruvi. Vakolatni faqat server beradi va har amal uchun 2FA kodi so‘raladi.';

  @override
  String get admTeamOwnerOnly =>
      'Adminlarni faqat egasi (super admin) qo‘shadi va olib tashlaydi.';

  @override
  String get admAddTitle => 'Admin qo‘shish';

  @override
  String get admAddEmail => 'Email (masalan, Gmail)';

  @override
  String get admAddHint =>
      'Vakolat shu email bilan kirib, 2FA ni yoqqanda kuchga kiradi; hisobi bo‘lsa — darhol.';

  @override
  String get admAddButton => 'Admin qilish';

  @override
  String get admAddConfirmTitle => 'Admin qilinsinmi?';

  @override
  String admAddConfirmBody(String email) {
    return '$email barcha admin bo‘limlariga to‘liq kiradi. Istalgan vaqtda olib tashlashingiz mumkin.';
  }

  @override
  String admAdded(String email) {
    return 'Qo‘shildi: $email';
  }

  @override
  String get admInvalidEmail => 'Email noto‘g‘ri. Masalan: ism@gmail.com';

  @override
  String get admErrAlready => 'Bu email allaqachon admin.';

  @override
  String get admErrSuper =>
      'Bu email — egasi (super admin), u allaqachon admin.';

  @override
  String admErrTooMany(int max) {
    return 'Adminlar chegarasi: $max ta. Avval birini olib tashlang.';
  }

  @override
  String admListTitle(int count) {
    return 'Adminlar ($count)';
  }

  @override
  String get admKindSuper => 'Egasi · super admin';

  @override
  String admKindGranted(String date) {
    return 'Admin · qo‘shilgan $date';
  }

  @override
  String get admNotSignedIn =>
      'Hali kirmagan — vakolat birinchi kirishda kuchga kiradi';

  @override
  String get admYou => 'Siz';

  @override
  String get admRemove => 'Olib tashlash';

  @override
  String get admRemoveTitle => 'Admin olib tashlansinmi?';

  @override
  String admRemoveBody(String email) {
    return '$email admin vakolatini darhol yo‘qotadi — barcha qurilmalarda. Hisobi va boshqa ma’lumotlari o‘chmaydi.';
  }

  @override
  String admRemoved(String email) {
    return 'Olib tashlandi: $email';
  }

  @override
  String get admSuperNote =>
      'Egasi maxfiy server sozlamasida (LG_ADMIN_EMAILS) — ilovadan olib tashlanmaydi.';

  @override
  String get admNoGranted => 'Hali qo‘shilgan admin yo‘q.';

  @override
  String get cmAdminRevokeTitle => 'Tasdiq bekor qilinsinmi?';

  @override
  String get cmAdminRevokeBody =>
      'A’zoning mutaxassis belgisi olinadi va u AI orqali qayta tasdiqlana olmaydi. Savol berishda davom etishi mumkin.';

  @override
  String get cmAdminRestoreTitle => 'A’zo tiklansinmi?';

  @override
  String get cmAdminRestoreBody =>
      'To‘xtatishdan oldingi holat qaytadi, postlari yana ko‘rinadi. Eski shikoyatlar qayta sanalmaydi.';

  @override
  String get adminActionGrantAdded => 'Admin qo‘shildi';

  @override
  String get adminActionGrantRemoved => 'Admin olib tashlandi';

  @override
  String get cytoTitle => 'Sitologiya';

  @override
  String get cytoSubtitle => 'Ginekologik surtma: hujayralar va xulosalar';

  @override
  String get cytoHeroTitle => 'Surtmani tushunib o‘qing';

  @override
  String get cytoHeroBody =>
      'Hujayralar rasmlari, tozalik darajasi, Bethesda tasnifi va mashq — bir joyda.';

  @override
  String get cytoHeroCta => 'Hujayralarni ko‘rish';

  @override
  String get cytoSchematicCaption =>
      'Izohli sxema (LabGuide) — mikrofoto emas, masshtab va ranglar shartli.';

  @override
  String get cytoCellsTitle => 'Hujayralarni tanish';

  @override
  String cytoCellsSub(int n) {
    return '$n ta element: rasm va asosiy belgi';
  }

  @override
  String get cytoDegreeTitle => 'Qin surtmasining tozalik darajasi';

  @override
  String get cytoDegreeSub => 'I–IV daraja: ko‘rganingizni belgilang';

  @override
  String get cytoBethesdaTitle => 'Bethesda tasnifi';

  @override
  String get cytoBethesdaSub => 'PAP-test xulosasi nimani anglatadi';

  @override
  String get cytoTechniqueTitle => 'Surtma olish va bo‘yash';

  @override
  String get cytoTechniqueSub => 'Tayyorgarlik, fiksatsiya, bo‘yash, xatolar';

  @override
  String get cytoQuizTitle => 'Bu qaysi hujayra?';

  @override
  String cytoQuizSub(int n) {
    return '$n ta savol, rasm bo‘yicha';
  }

  @override
  String get cytoQuizIntro =>
      'Rasmga qarang va to‘g‘ri nomni tanlang: 4 variant. Javobdan keyin asosiy belgi ko‘rsatiladi.';

  @override
  String get cytoQuizPrompt => 'Bu nima?';

  @override
  String get cytoQuizStart => 'Mashqni boshlash';

  @override
  String get cytoLook => 'Ko‘rinishi';

  @override
  String get cytoKey => 'Asosiy belgi';

  @override
  String get cytoMeaning => 'Nimani anglatadi';

  @override
  String get cytoConfuse => 'Nima bilan adashtiriladi';

  @override
  String get cytoRefer => 'Sitolog yoki shifokorga ko‘rsating';

  @override
  String get cytoDegreeIntro =>
      'Mikroskopda ko‘rganingizni belgilang — ilova an’anaviy tasnif bo‘yicha darajani ko‘rsatadi. Eng og‘ir belgi hal qiladi.';

  @override
  String get cytoLacto => 'Laktobatsillalar';

  @override
  String get cytoLeuko => 'Leykotsitlar';

  @override
  String get cytoFlora => 'Boshqa flora';

  @override
  String get cytoMany => 'Ko‘p';

  @override
  String get cytoFew => 'Oz';

  @override
  String get cytoNone => 'Yo‘q';

  @override
  String get cytoSingle => 'Yakka';

  @override
  String get cytoVeryMany => 'Juda ko‘p';

  @override
  String get cytoMixed => 'Aralash (kokklar)';

  @override
  String get cytoPathogenic => 'Patogen (trixomonada va b.)';

  @override
  String cytoDegreeResult(int n) {
    return '$n-daraja';
  }

  @override
  String get cytoDegreeTable => 'Darajalar jadvali';

  @override
  String get cytoDegreeNote =>
      'An’anaviy tasnif (A. Heurlein, 1910; MDH mamlakatlari amaliyoti). Rossiya tavsiyalari (ROAG 2019) uni faqat tarixiy ahamiyatga ega deb hisoblaydi; bakterial vaginoz uchun xalqaro mezonlar — Amsel va Nugent.';

  @override
  String get cytoDegreeSourceNote =>
      'Quyida tasnif va bakterial vaginoz mezonlari manbalari; ular farq qilgan joyda ikkalasi ham ko‘rsatilgan.';

  @override
  String get cytoBethesdaIntro =>
      'Bachadon bo‘yni surtmasi xulosasi Bethesda tizimida shunday yoziladi. Keyingi qadamni shifokor belgilaydi.';

  @override
  String get cytoMethod => 'Bo‘yoq / preparat';

  @override
  String get cytoMarksTitle => 'Rasmdagi belgilar';

  @override
  String get cytoNoPhoto =>
      'Haqiqiy mikrofoto hali qo‘shilmagan — faqat ruxsati tekshirilgan rasm qo‘shiladi.';

  @override
  String get cytoLabCardBody =>
      'Hujayralar sxemasi, tozalik darajasi, Bethesda va mashq';

  @override
  String get spermTitle => 'Spermogramma';

  @override
  String get spermLabCardBody =>
      'Me’yorlar (JSST 2021), sanash hisoblagichi, baholash va atamalar';

  @override
  String get homeSearchHint => 'Tahlil, apparat yoki mavzu qidirish';

  @override
  String get searchTitle => 'Qidiruv';

  @override
  String get searchPrompt =>
      'Nom, qisqartma yoki sinonimni yozing — lotin yoki kirillda, ruscha yoki inglizcha ham bo‘ladi.';

  @override
  String get searchSectionLibrary => 'O‘quv materiallari';

  @override
  String get searchSectionSections => 'Bo‘limlar';

  @override
  String get diffAssessTitle => 'Me’yor bilan solishtirish';

  @override
  String get diffAssessNote =>
      'Bu tashxis emas: natija blanka me’yori bilan solishtirildi va nimaga ishora qilishi mumkinligi ko‘rsatildi. Xulosani shifokor beradi.';

  @override
  String get diffAssessNeedWbc =>
      'Mutlaq sonlar bo‘yicha baholash uchun leykotsitlar sonini (WBC) kiriting — hozir faqat tayoqcha yadrolilar foizi baholandi.';

  @override
  String get diffAssessAllNormal => 'Barcha ko‘rsatkichlar me’yor oralig‘ida.';

  @override
  String diffAssessIncomplete(int counted, int target) {
    return 'Solishtirish sanash tugagach chiqadi: $target ta hujayradan $counted tasi sanaldi. Tugallanmagan sanashdagi ulushlar ishonchsiz.';
  }

  @override
  String get diffFlagHigh => 'Yuqori';

  @override
  String get diffFlagLow => 'Past';

  @override
  String get diffFlagNormal => 'Me’yorda';

  @override
  String get diffMeasureNeutrophils => 'Neytrofillar (jami)';

  @override
  String get diffMeasureLymphocytes => 'Limfotsitlar';

  @override
  String get diffMeasureMonocytes => 'Monotsitlar';

  @override
  String get diffMeasureEosinophils => 'Eozinofillar';

  @override
  String get diffMeasureBasophils => 'Bazofillar';

  @override
  String get diffMeasureBands => 'Tayoqcha yadroli neytrofillar';

  @override
  String diffAssessRange(String range) {
    return 'me’yor $range';
  }

  @override
  String diffAssessMaySuggest(String finding) {
    return 'Ishora qilishi mumkin: $finding';
  }

  @override
  String get diffAssessAboutFinding => 'Bu talqin haqida batafsil';

  @override
  String get diffAssessReferBody =>
      'Blast yoki noma’lum hujayra, og‘ir neytropeniya (< 0,5 ×10⁹/L) yoki yaqqol eozinofiliya (> 1,5 ×10⁹/L): natija va surtmani shifokor yoki gematologga zudlik bilan ko‘rsating.';

  @override
  String get diffLimitsTitle => 'Blanka me’yorlari';

  @override
  String get diffLimitsSub =>
      'Laboratoriyangiz blankasidagi oraliqlarni kiriting — baholash shular bo‘yicha qilinadi. Pastki chegara bo‘sh qolsa, tekshirilmaydi.';

  @override
  String get diffLimitsLow => 'Pastki chegara';

  @override
  String get diffLimitsHigh => 'Yuqori chegara';

  @override
  String get diffLimitsInvalid =>
      'Noto‘g‘ri oraliq: pastki chegara yuqoridan kichik bo‘lsin.';

  @override
  String get diffLimitsReset => 'Manbadagi qiymatlarga qaytarish';

  @override
  String get diffLimitsSourceNote =>
      'Sukut qiymatlari — kattalar uchun 95 % oraliq (Harrison’s Manual of Medicine, 20-nashr, 64-1-jadval); tayoqchalar — Lyubina 1984, 6-jadval. MSD qo‘llanmasi ta’riflari farq qiladi: eozinofiliya > 0,5 ×10⁹/L (bu yerda sukut yuqori chegara 0,7), limfopeniya < 1,0 ×10⁹/L (bu yerda sukut pastki chegara 1,5). Bolalarda va ayrim etnik guruhlarda (masalan, Duffy-manfiy) me’yor farq qiladi.';

  @override
  String get cytoAdequacyTitle => 'Namuna sifati';

  @override
  String get cytoAdequacySub =>
      'Bethesda 2014: yaroqli yoki yo‘q, ko‘p uchraydigan artefaktlar';

  @override
  String get cytoArtefactsTitle => 'Ko‘p uchraydigan artefaktlar';

  @override
  String get cytoReactiveTitle => 'Reaktiv o‘zgarishlar va atipiya farqi';

  @override
  String get cytoReactiveSub =>
      'Yallig‘lanish, repair, nur, BIV — ASC-US va LSIL bilan solishtirish';

  @override
  String get cytoReactiveIntro =>
      'Bethesda tizimida reaktiv hujayra o‘zgarishlari (yallig‘lanish va repair, limfotsitar servitsit, nur ta’siri, BIV) — NILM ichidagi o‘smaga aloqasiz topilmalar.';

  @override
  String get cytoCompareTitle => 'Yonma-yon solishtirish';

  @override
  String get cytoCompareNone => 'keltirilgan manbalarda alohida mezon yo‘q';

  @override
  String get cytoReactiveTypesTitle => 'Reaktiv o‘zgarish turlari';

  @override
  String get cytoMaturationTitle => 'Yetilish indeksi';

  @override
  String get cytoMaturationSub => 'Parabazal : oraliq : yuzaki — hisoblagich';

  @override
  String get cytoMiCalcTitle => 'Hisoblagich';

  @override
  String get cytoMiParabasal => 'Parabazal hujayralar';

  @override
  String get cytoMiIntermediate => 'Oraliq hujayralar';

  @override
  String get cytoMiSuperficial => 'Yuzaki hujayralar';

  @override
  String get cytoMiEmpty =>
      'Yakka hujayralar sonini kiriting (butun son); kamida bittasi 0 dan katta bo‘lsin.';

  @override
  String get cytoMiResult => 'Yetilish indeksi (parabazal : oraliq : yuzaki)';

  @override
  String cytoMiTotal(int n) {
    return 'Sanalgan hujayralar: $n';
  }

  @override
  String get cytoMiCaveat =>
      'Bu faqat arifmetika. Talqin yosh, sikl kuni, homiladorlik, gormonlar va yallig‘lanishga bog‘liq — uni sitolog yoki shifokor beradi.';

  @override
  String get cytoOtherTitle => 'Boshqa namunalar';

  @override
  String get cytoOtherSub =>
      'Siydik, seroz suyuqliklar, balg‘am: xulosa kategoriyalari';

  @override
  String get cytoOtherIntro =>
      'Qisqa sharh: faqat xalqaro xulosa kategoriyalarining nomlari. Mezonlar va xavf ko‘rsatkichlari — manbalarda.';

  @override
  String get cytoCategoriesTitle => 'Kategoriyalar';

  @override
  String get contactPrivacyPolicy => 'Maxfiylik siyosati';

  @override
  String get bloodGroupTitle => 'Qon guruhi';

  @override
  String get bloodGroupLabCardBody =>
      'ABO va RhD: usullar, moslik, nomuvofiqliklar, mashq';

  @override
  String get autoPresTitle => 'Avtomatik taqdimot';

  @override
  String get autoPresEntrySub => 'Ilovadagi manbali mazmundan slaydlar';

  @override
  String get autoPresPickerSub =>
      'Mavzu yoki tahlillarni tanlang. Slaydlar faqat ilovadagi manbali mazmundan yig‘iladi — hech narsa to‘qilmaydi.';

  @override
  String get autoPresLanguageNote =>
      'Slaydlar ilova tilida tuziladi. Bu tilda yo‘q mazmun o‘tkazib yuboriladi — tillar aralashtirilmaydi.';

  @override
  String get autoPresModeTopic => 'Mavzu bo‘yicha';

  @override
  String get autoPresModeTests => 'Tahlillar bo‘yicha';

  @override
  String get autoPresSearch => 'Tahlil qidirish';

  @override
  String get autoPresSearchHint => 'Nomi, qisqartmasi yoki sinonimi';

  @override
  String autoPresSelectedCount(int count, int max) {
    return 'Tanlandi: $count / $max';
  }

  @override
  String autoPresLimitReached(int max) {
    return 'Bitta taqdimotda $max tadan ko‘p tahlil bo‘lmaydi.';
  }

  @override
  String get autoPresNoResults => 'Tahlil topilmadi.';

  @override
  String get autoPresOptQuiz => 'Savol slaydlari';

  @override
  String get autoPresOptQuizSub =>
      'Tanlangan mazmun bo‘yicha savollar; javob bosilganda ochiladi.';

  @override
  String get autoPresOptGeneral => 'Umumiy preanalitika';

  @override
  String get autoPresOptGeneralSub =>
      'Probirkalar tartibi, gemoliz, jgut (JSST, 2010).';

  @override
  String get autoPresPreview => 'Slaydlarni ko‘rish';

  @override
  String get autoPresPickFirst =>
      'Avval mavzu yoki kamida bitta tahlilni tanlang.';

  @override
  String get autoPresPreviewTitle => 'Slaydlar ko‘rinishi';

  @override
  String get autoPresPreviewSub =>
      'Slaydlar tartibini o‘zgartiring yoki olib tashlang, so‘ng boshlang.';

  @override
  String autoPresSlideCount(int count) {
    return '$count ta slayd';
  }

  @override
  String get autoPresStart => 'Boshlash';

  @override
  String get autoPresMoveUp => 'Yuqoriga';

  @override
  String get autoPresMoveDown => 'Pastga';

  @override
  String get autoPresRemove => 'Slaydni olib tashlash';

  @override
  String get autoPresRestore => 'Olib tashlanganlarni qaytarish';

  @override
  String get autoPresSourcesPinned =>
      'Manbalar slaydi — qolgan slaydlardan avtomatik yig‘iladi';

  @override
  String get autoPresEmptyTitle => 'Manbali mazmun yetarli emas';

  @override
  String get autoPresEmptyBody =>
      'Bu tanlov bo‘yicha ilovada joriy tilda manbali mazmun yo‘q, shuning uchun slayd yaratilmadi. Hech narsa o‘zimizdan to‘qilmaydi.';

  @override
  String autoPresNoticeStructureOnly(String name) {
    return '$name: kartada hali matn yo‘q — o‘tkazib yuborildi.';
  }

  @override
  String autoPresNoticeNoContent(String name) {
    return '$name: slayd uchun manbali matn yo‘q — o‘tkazib yuborildi.';
  }

  @override
  String autoPresNoticeLang(int count) {
    return 'Bu tilda yo‘q, shuning uchun o‘tkazib yuborildi: $count ta. Tillar aralashtirilmaydi.';
  }

  @override
  String get autoPresDeckTitleTests => 'Laboratoriya tahlillari';

  @override
  String autoPresMoreItems(int count) {
    return 'yana $count ta';
  }

  @override
  String autoPresPackSource(String version) {
    return 'LabGuide, kontent paketi $version — slaydlar manbali kartalardan avtomatik yig‘ilgan';
  }

  @override
  String autoPresSourceLine(String text) {
    return 'Manba: $text';
  }

  @override
  String get autoPresColIndicator => 'Ko‘rsatkich';

  @override
  String get autoPresColValue => 'Qiymat';

  @override
  String get autoPresColTarget => 'Maqsad';

  @override
  String get autoPresColTube => 'Probirka';

  @override
  String get autoPresColCap => 'Qopqoq rangi';

  @override
  String get autoPresShowAnswer => 'Javobni ko‘rsatish';

  @override
  String get autoPresHideAnswer => 'Javobni yashirish';

  @override
  String get autoPresAnswerLabel => 'Javob';

  @override
  String get autoPresTplTitle => 'Sarlavha';

  @override
  String get autoPresTplBullets => 'Bandlar';

  @override
  String get autoPresTplTable => 'Jadval';

  @override
  String get autoPresTplFigure => 'Rasm';

  @override
  String get autoPresTplQa => 'Savol';

  @override
  String get instSchematicCaption => 'Sxematik tasvir — aniq model emas';

  @override
  String get instSchematicTapToZoom => 'Kattalashtirish uchun tasvirni bosing';

  @override
  String get instSchematicNotPhoto =>
      'LabGuide chizgan original umumiy sinf sxemasi. Ishlab chiqaruvchining haqiqiy apparat fotosurati emas; ko‘rsatilgan qismlar tamoyil darajasida va aniq modelning o‘ziga xos xususiyatlarini bildirmaydi.';

  @override
  String instSchematicSemantics(String kind) {
    return 'Sxematik tasvir: $kind';
  }

  @override
  String get histoTitle => 'Gistologiya';

  @override
  String get histoLabCardBody =>
      'To‘qimalar va a’zolar: haqiqiy mikrofotolar, belgilar, mashq';

  @override
  String get contactRowTitle => 'Aloqa va shikoyat';

  @override
  String get contactRowSub => 'Savol, shikoyat, xato haqida xabar';

  @override
  String get contactTitle => 'Aloqa';

  @override
  String get contactIntro =>
      'Internetsiz va hisobsiz ham ishlaydi: xat pochta ilovangiz orqali yuboriladi.';

  @override
  String get contactEmailLabel => 'Elektron pochta';

  @override
  String get contactCopy => 'Manzilni nusxalash';

  @override
  String get contactCopied => 'Manzil nusxalandi';

  @override
  String get contactNoMailApp =>
      'Pochta ilovasi ochilmadi. Manzil nusxalandi: xatni istalgan pochta xizmatidan yuboring.';

  @override
  String get contactQuestionTitle => 'Savol va takliflar';

  @override
  String get contactQuestionBody =>
      'Ilova haqida savol bering, mavzu yoki yaxshilash bo‘yicha taklif yuboring.';

  @override
  String get contactQuestionAction => 'Xat yozish';

  @override
  String get contactAdTitle => 'Reklama va hamkorlik';

  @override
  String get contactAdBody =>
      'Laboratoriya apparatlari ishlab chiqaruvchilari, distribyutorlari va servis firmalari LabGuide’da reklama berishi mumkin.\nBizga yozing yoki (ilovangizda bo‘lsa) hamkor arizasidan foydalaning.';

  @override
  String get contactAdAction => 'Reklama bo‘yicha yozish';

  @override
  String get contactReportTitle => 'Shikoyat / xato haqida xabar';

  @override
  String get contactReportBody =>
      'Noto‘g‘ri tibbiy ma’lumot yoki nomaqbul foydalanuvchi kontenti haqida yozing.';

  @override
  String get contactReportHint =>
      'Xatda bo‘lim yoki karta nomini yozing: tezroq topamiz.';

  @override
  String get contactReportAction => 'Shikoyat yuborish';

  @override
  String get contactResponseNote =>
      'Har bir xabarni o‘qiymiz va tasdiqlangan xatolarni tuzatamiz, lekin javob muddatini va’da qila olmaymiz. Bu manzil shoshilinch tibbiy yordam uchun emas.';

  @override
  String get contactPrivacyNote =>
      'Bizga yozsangiz, email manzilingiz va yozganingiz bizga ko‘rinadi.';

  @override
  String contactMailBodyQuestion(String version, String platform) {
    return 'Savol yoki taklifingiz:\n\n\n---\nIlova: LabGuide $version\nPlatforma: $platform';
  }

  @override
  String contactMailBodyAd(String version, String platform) {
    return 'Firma va nimani reklama qilmoqchisiz:\n\n\n---\nIlova: LabGuide $version\nPlatforma: $platform';
  }

  @override
  String contactMailBodyReport(String version, String platform) {
    return 'Bo‘lim / karta nomi:\nNima noto‘g‘ri:\n(Bemor ma’lumotlarini yozmang.)\n\n\n---\nIlova: LabGuide $version\nPlatforma: $platform';
  }

  @override
  String get partnerKindLaboratory => 'Laboratoriya xizmati';

  @override
  String get partnerPlacementHomeLab => 'Bosh sahifa: laboratoriya xizmati';

  @override
  String get partnerPlacementHomeEquipment => 'Bosh sahifa: apparat firmasi';

  @override
  String get homeAdDemoTitle => 'Namuna / Demo — reklama joyi';

  @override
  String get homeAdDemoLabBody =>
      'Bu yerda hamkor laboratoriya xizmati reklamasi chiqadi';

  @override
  String get homeAdDemoEquipmentBody =>
      'Bu yerda apparat firmasi reklamasi chiqadi';

  @override
  String get homeAdDemoCta => 'Reklama joylashtirish';

  @override
  String get cmBlock => 'Foydalanuvchini bloklash';

  @override
  String get cmBlockConfirmTitle => 'Foydalanuvchi bloklansinmi?';

  @override
  String get cmBlockConfirmBody =>
      'Uning savol va javoblari shu qurilmada ko‘rinmaydi. Buni hamjamiyat ro‘yxatidan qaytarish mumkin.';

  @override
  String get cmBlockedDone => 'Foydalanuvchi bloklandi. Postlari yashirildi.';

  @override
  String get cmBlockedHidden =>
      'Muallifni bloklaganingiz uchun bu post yashirilgan.';

  @override
  String cmBlockedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Siz $count ta foydalanuvchini bloklagansiz.',
    );
    return '$_temp0';
  }

  @override
  String get cmUnblockAll => 'Hammasini blokdan chiqarish';

  @override
  String get cmContactLink => 'LabGuide bilan aloqa (muammo haqida xabar)';

  @override
  String get authOr => 'yoki';

  @override
  String get authSignInApple => 'Apple bilan kirish';

  @override
  String get authSignInGoogle => 'Google bilan kirish';

  @override
  String get authSocialFailed =>
      'Kirib bo‘lmadi. Ulanishni tekshirib qayta urinib ko‘ring yoki email kodidan foydalaning.';

  @override
  String get authSocialEmailUnverified =>
      'Bu hisobning emaili tasdiqlanmagan, shuning uchun u bilan kirib bo‘lmaydi. Email kodidan foydalaning.';

  @override
  String get authSocialEmailRequired =>
      'Bu hisob email manzilini bermadi. Email kodidan foydalaning.';

  @override
  String get accountDeleteAppleNote =>
      'Siz Apple orqali kirgansiz, shuning uchun hisobni o‘chirishdan oldin Apple tasdiq so‘raydi. Bu LabGuide’ni Apple ID’ngizdan ham uzadi.';

  @override
  String get accountDeleteAppleCancelled =>
      'Hech narsa o‘chirilmadi: Apple tasdig‘i bekor qilindi.';

  @override
  String get urinTitle => 'Siydik tahlili';

  @override
  String get urinLabCardBody =>
      'Yig‘ish, test-chiziq, cho‘kma rasmlari, natijani o‘qish, mashq';

  @override
  String get coagTitle => 'Koagulogramma';

  @override
  String get coagLabCardBody =>
      'PT/INR, APTT, fibrinogen, D-dimer, namuna, DIC bali';

  @override
  String get coproTitle => 'Najas tahlili va parazitlar';

  @override
  String get coproLabCardBody =>
      'Koprogramma, yashirin qon, tuxum va sistalar kaliti (sxema)';

  @override
  String get admPanelAccess =>
      'Kirish: egasi emaili (ADMIN_EMAILS) va email kodi. Server har so‘rovda qayta tekshiradi.';

  @override
  String get admOverview => 'Umumiy ko‘rsatkichlar';

  @override
  String admOverviewSub(int total, int online, int week) {
    return 'Ro‘yxatdan o‘tgan: $total · onlayn: $online · 7 kunda yangi: $week';
  }

  @override
  String get admComplaintsRow => 'Ilova shikoyatlari';

  @override
  String admComplaintsRowSub(int count) {
    return 'Ochiq: $count';
  }

  @override
  String get admReportsRow => 'Hamjamiyat shikoyatlari';

  @override
  String admReportsRowSub(int count) {
    return 'Ko‘rilmagan postlar: $count';
  }

  @override
  String admEmailNote(String email) {
    return 'Email orqali yozilgan shikoyat va savollar $email manziliga keladi — ularni pochtada ko‘ring (ilovaga tushmaydi).';
  }

  @override
  String get admUsersSub =>
      'Email yoki taxallus bo‘yicha qidirish, rol, to‘xtatish';

  @override
  String get admAuditSub => 'Har bir admin amali yoziladi';

  @override
  String get admStoreTitle => 'Yuklab olishlar va sotuvlar';

  @override
  String get admStoreBody =>
      'Do‘kondan yuklab olishlar sonini server ko‘rmaydi — uni App Store Connect va Google Play Console ko‘rsatadi. Ilovada analitika SDK yo‘q (maxfiylik siyosati). Bu paneldagi sonlar — emailini tasdiqlab ro‘yxatdan o‘tgan hisoblar.';

  @override
  String get admSales => 'Sotuvlar: 0 (hozircha to‘lov yo‘q)';

  @override
  String get admAppStoreConnect => 'App Store Connect';

  @override
  String get admPlayConsole => 'Google Play Console';

  @override
  String get admStatsAccounts => 'Hisoblar';

  @override
  String get admOnlineNow => 'Hozir onlayn (5 daqiqa)';

  @override
  String get admSuspendedAccounts => 'To‘xtatilgan hisoblar';

  @override
  String get admStatsActiveNote =>
      'Onlayn va faol — ilovadan serverga so‘rov yuborgan hisob. Faqat daqiqa va kun yoziladi; IP va qurilma saqlanmaydi.';

  @override
  String get admChartTitle => 'Yangi hisoblar — oxirgi 14 kun';

  @override
  String admChartBar(String date, int count) {
    return '$date: $count ta yangi hisob';
  }

  @override
  String admChartTotal(int count) {
    return '14 kunda jami: $count';
  }

  @override
  String get admStatsObjects => 'Asosiy obyektlar';

  @override
  String get admStatsGroupsCount => 'Guruhlar';

  @override
  String get admStatsTeachers => 'Ro‘yxatdan o‘tgan ustozlar';

  @override
  String get admStatsStudents => 'Guruhlardagi talabalar';

  @override
  String get admStatsAssignments => 'Test sessiyalari';

  @override
  String get admStatsResults => 'Test natijalari';

  @override
  String get admStatsQuestions => 'Hamjamiyat savollari';

  @override
  String get admStatsAnswers => 'Hamjamiyat javoblari';

  @override
  String get admStatsComplaintsOpen => 'Ochiq shikoyatlar';

  @override
  String get admStatsComplaintsResolved => 'Hal qilingan shikoyatlar';

  @override
  String get admStatsReportsOpen => 'Hamjamiyat: ko‘rilmagan shikoyatlar';

  @override
  String get admStatsAwaiting => 'Murojaatlar: javob kutmoqda';

  @override
  String admStatsUpdated(String time) {
    return 'Yangilandi: $time';
  }

  @override
  String get admComplaintsTitle => 'Ilova shikoyatlari';

  @override
  String get admApple12Note =>
      'Nomaqbul kontent haqidagi shikoyatlarni tez ko‘rib chiqing (Apple 1.2 — o‘z vaqtida javob talab qilinadi; maqsad — 24 soat).';

  @override
  String get admFilterOpen => 'Ochiq';

  @override
  String get admFilterResolved => 'Hal qilingan';

  @override
  String get admAllKinds => 'Barcha turlar';

  @override
  String get complaintKindComplaint => 'Shikoyat';

  @override
  String get complaintKindInappropriate => 'Nomaqbul kontent';

  @override
  String get complaintKindBug => 'Xato';

  @override
  String get complaintKindAd => 'Reklama';

  @override
  String get complaintKindOther => 'Boshqa';

  @override
  String get admComplaintsEmpty => 'Bu ro‘yxatda shikoyat yo‘q';

  @override
  String get admComplaintAnon => 'Mehmon (hisobsiz)';

  @override
  String admComplaintFrom(String email) {
    return 'Yuboruvchi: $email';
  }

  @override
  String admComplaintTarget(String ref) {
    return 'Ishora: $ref';
  }

  @override
  String get admComplaintNote => 'Admin izohi';

  @override
  String get admComplaintNoteHint => 'Nima qilindi? (faqat adminlar ko‘radi)';

  @override
  String get admComplaintSaveNote => 'Izohni saqlash';

  @override
  String get admComplaintResolve => 'Hal qilindi';

  @override
  String get admComplaintReopen => 'Qayta ochish';

  @override
  String admComplaintResolvedOn(String date) {
    return 'Hal qilingan: $date';
  }

  @override
  String get admSaved => 'Saqlandi';

  @override
  String get admReportsEmpty => 'Bu ro‘yxatda shikoyat yo‘q';

  @override
  String get admReportOpen => 'Ochiq';

  @override
  String get admReportDismissed => 'Rad etilgan';

  @override
  String get admReportResolved => 'Hal qilingan';

  @override
  String get admReportKindQuestion => 'Savol';

  @override
  String get admReportKindAnswer => 'Javob';

  @override
  String admReportCount(int reports, int reporters) {
    return '$reports ta shikoyat · $reporters kishi';
  }

  @override
  String admReportReasons(String reasons) {
    return 'Sabab: $reasons';
  }

  @override
  String get admReportDeleted => 'Post o‘chirilgan';

  @override
  String get admReportAuthorSuspended => 'Muallif to‘xtatilgan';

  @override
  String get admReportOpenPost => 'Postni ochish';

  @override
  String get admReportDismiss => 'Asossiz';

  @override
  String get admReportResolve => 'Hal qilindi';

  @override
  String get admReportSuspend => 'Muallifni to‘xtatish';

  @override
  String get admReportDismissTitle => 'Shikoyat rad etilsinmi?';

  @override
  String get admReportDismissBody =>
      'Shikoyatlar yopiladi va avtomatik to‘xtatishga sanalmaydi. Amal jurnalga yoziladi.';

  @override
  String get admReportResolveTitle => 'Hal qilindi deb belgilansinmi?';

  @override
  String get admReportResolveBody =>
      'Chora ko‘rilgan (masalan, post o‘chirilgan). Amal jurnalga yoziladi.';

  @override
  String get admReportSuspendTitle => 'Muallif to‘xtatilsinmi?';

  @override
  String get admReportSuspendBody =>
      'Muallif hamjamiyatda yoza olmaydi, postlari yashiriladi. Amal jurnalga yoziladi.';

  @override
  String get admSearchModeEmail => 'Email';

  @override
  String get admSearchModeName => 'Taxallus';

  @override
  String get admSearchEmail => 'To‘liq email (aniq moslik)';

  @override
  String get admSearchName => 'Guruhdagi taxallus (kamida 2 belgi)';

  @override
  String get admUsersSearchNote =>
      'Email serverda ochiq saqlanmaydi: hisob faqat to‘liq email bo‘yicha topiladi va niqoblangan ko‘rinishda chiqadi.';

  @override
  String get admSearch => 'Qidirish';

  @override
  String get admStatusActive => 'Faol';

  @override
  String get admStatusSuspended => 'To‘xtatilgan';

  @override
  String get admUserAdminTag => 'Admin';

  @override
  String get admUserTitle => 'Foydalanuvchi';

  @override
  String get admUserRole => 'Rol';

  @override
  String get admRoleChanged => 'Rol o‘zgartirildi';

  @override
  String get admRoleSelfNote =>
      'O‘z rolingizni va holatingizni bu yerda o‘zgartirib bo‘lmaydi.';

  @override
  String admUserFacts(int owned, int joined, int threads, int complaints) {
    return 'Guruhlar: $owned (ustoz) · $joined (talaba) · murojaatlar: $threads · shikoyatlar: $complaints';
  }

  @override
  String get admAccountTitle => 'Hisob holati';

  @override
  String get admAccountSuspend => 'Hisobni to‘xtatish';

  @override
  String get admAccountSuspendTitle => 'Hisob to‘xtatilsinmi?';

  @override
  String get admAccountSuspendBody =>
      'Barcha qurilmalardan chiqariladi va qayta kira olmaydi (email kodi, Google, Apple). Ilova unga aloqa manzilini ko‘rsatadi. Amal jurnalga yoziladi.';

  @override
  String get admAccountReactivate => 'Qayta faollashtirish';

  @override
  String get admAccountReactivateTitle => 'Hisob qayta faollashtirilsinmi?';

  @override
  String get admAccountReactivateBody =>
      'Foydalanuvchi yana kira oladi. Amal jurnalga yoziladi.';

  @override
  String get admAccountAdminNote => 'Admin hisobini to‘xtatib bo‘lmaydi.';

  @override
  String get admUserCommunity => 'Hamjamiyat holati';

  @override
  String get admCommunityNone => 'Oddiy a’zo';

  @override
  String admUserCommunityFacts(int questions, int answers, int reporters) {
    return 'Savollar: $questions · javoblar: $answers · shikoyatchilar: $reporters';
  }

  @override
  String get admCommunitySuspend => 'Hamjamiyatda to‘xtatish';

  @override
  String get admCommunitySuspendTitle => 'Hamjamiyatda to‘xtatilsinmi?';

  @override
  String get admCommunitySuspendBody =>
      'Bu hisob savol va javob yoza olmaydi, postlari yashiriladi. Ilovaning qolgan qismi ishlaydi. Amal jurnalga yoziladi.';

  @override
  String get admErrOwner => 'Egasi hisobini to‘xtatib bo‘lmaydi.';

  @override
  String get admErrSelf => 'O‘zingizga bu amalni qo‘llab bo‘lmaydi.';

  @override
  String get admErrName => 'Taxallus 2–40 belgi bo‘lsin.';

  @override
  String admAuditBy(String actor) {
    return 'Bajaruvchi: $actor';
  }

  @override
  String get admAuditSystem => 'Tizim';

  @override
  String get adminActionReportDismissed => 'Hamjamiyat shikoyati rad etildi';

  @override
  String get adminActionReportResolved => 'Hamjamiyat shikoyati hal qilindi';

  @override
  String get adminActionCommunitySuspended => 'Hamjamiyatda to‘xtatildi';

  @override
  String get adminActionCommunityRestored => 'Hamjamiyatda tiklandi';

  @override
  String get adminActionCommunityRevoked => 'Mutaxassis tasdig‘i bekor qilindi';

  @override
  String get adminActionAutoSuspended =>
      'Shikoyatlar bo‘yicha avtomatik to‘xtatildi';

  @override
  String get adminActionPostDeleted => 'Post o‘chirildi';

  @override
  String get adminActionPinned => 'Savol qadalishi o‘zgardi';

  @override
  String get adminActionAccountDeleted => 'Hisob o‘chirildi';

  @override
  String get adminActionMfa => '2FA yoqildi';

  @override
  String get adminActionTeacher => 'Ustoz ro‘yxatdan o‘tdi';

  @override
  String get adminActionRoleChanged => 'Rol o‘zgartirildi';

  @override
  String get adminActionAccountSuspended => 'Hisob to‘xtatildi';

  @override
  String get adminActionAccountReactivated => 'Hisob qayta faollashtirildi';

  @override
  String get adminActionComplaintNote => 'Shikoyatga izoh yozildi';

  @override
  String get adminActionComplaintResolved => 'Shikoyat hal qilindi';

  @override
  String get adminActionComplaintReopened => 'Shikoyat qayta ochildi';

  @override
  String get adminActionIdentityLinked => 'Kirish usuli bog‘landi';

  @override
  String get complaintFormTitle => 'Ilova ichidan shikoyat yuborish';

  @override
  String get complaintFormBody =>
      'Nomaqbul kontent, xato yoki boshqa muammo haqida yozing — LabGuide jamoasi ko‘rib chiqadi (odatda 24 soat ichida).';

  @override
  String get complaintKindLabel => 'Turi';

  @override
  String get complaintText => 'Matn';

  @override
  String get complaintTextHint => 'Nima bo‘ldi? Qaysi ekran yoki post?';

  @override
  String complaintTarget(String ref) {
    return 'Ishora: $ref';
  }

  @override
  String get complaintSend => 'Shikoyat yuborish';

  @override
  String get complaintSent => 'Yuborildi. Rahmat — ko‘rib chiqamiz.';

  @override
  String get complaintTooShort => 'Kamida 5 belgi yozing.';

  @override
  String complaintRateLimited(int minutes) {
    return 'Juda ko‘p yuborildi: soatiga 5 ta. $minutes daqiqadan keyin qayta urinib ko‘ring.';
  }

  @override
  String get complaintAnonNote =>
      'Hisobsiz yuborsangiz, sizga javob bera olmaymiz. Javob kerak bo‘lsa — hisobga kiring yoki email yozing.';

  @override
  String get complaintPhiNote =>
      'Bemorning ismi yoki boshqa shaxsiy ma’lumotini yozmang.';

  @override
  String get complaintFailed =>
      'Yuborilmadi. Internetni tekshirib, qayta urinib ko‘ring.';

  @override
  String authAccountSuspended(String email) {
    return 'Hisobingiz to‘xtatilgan. Savol bo‘lsa, yozing: $email';
  }

  @override
  String get admSectionComplaints => 'Shikoyatlar';

  @override
  String get bloodMorphTitle => 'Qon morfologiyasi';

  @override
  String get bloodMorphLabCardBody =>
      'Eritrotsitlar, trombotsitlar, anemiyalar: haqiqiy mikrofotolar, yordamchi, mashq';

  @override
  String get lectureSearchLabel => 'Taqdimotlarni qidirish';

  @override
  String get lectureSearchHint =>
      'Mavzu, tahlil yoki slayd sarlavhasi (masalan: glyukoza)';

  @override
  String get lectureFilterAll => 'Hammasi';

  @override
  String get lectureFilterProtocols => 'Amaliy protokollar';

  @override
  String lectureFilterModule(int n) {
    return '$n-modul';
  }

  @override
  String get lectureLangAll => 'Barcha tillar';

  @override
  String lectureDecksCount(int count) {
    return '$count ta taqdimot';
  }

  @override
  String lectureSlidesCount(int count) {
    return '$count slayd';
  }

  @override
  String lectureSlidesMatch(int count) {
    return '$count ta slayd mos';
  }

  @override
  String lectureMoreSlides(int count) {
    return 'yana $count ta';
  }

  @override
  String lectureResultsFound(int count) {
    return '$count ta taqdimot topildi';
  }

  @override
  String get lectureNoResultsTitle => 'Hech narsa topilmadi';

  @override
  String get lectureNoResultsBody =>
      'Boshqa so‘z yoki filtrni sinab ko‘ring. Qidiruv o‘zbekcha (lotin yoki kirill), ruscha va inglizcha ishlaydi.';

  @override
  String get lectureClearFilters => 'Qidiruv va filtrni tozalash';

  @override
  String lectureLangFallback(String wanted, String shown) {
    return 'Bu taqdimot $wanted tilida yo‘q — $shown tilida ko‘rsatilmoqda';
  }

  @override
  String get lectureDeckLoadFailed => 'Taqdimotni ochib bo‘lmadi';

  @override
  String get lectureFullscreen => 'To‘liq ekran';

  @override
  String get lectureFullscreenExit => 'To‘liq ekrandan chiqish';

  @override
  String get lectureSourcesTitle => 'Slayd manbalari';

  @override
  String get lectureSourcesOpen => 'Manbalarni to‘liq ko‘rish';

  @override
  String lectureSourcesCount(int count) {
    return 'Manbalar: $count';
  }

  @override
  String lectureSourceLocator(String loc) {
    return 'Bo‘lim/sahifa: $loc';
  }

  @override
  String get lectureSourcesHint =>
      'To‘liq ro‘yxat — oxirgi «Adabiyotlar» slaydida.';

  @override
  String get lectureRotateTitle =>
      'Ekranni gorizontal (albom) holatga aylantiraymizmi?';

  @override
  String get lectureRotateBody =>
      'Gorizontal holatda slayd butun ekranni egallaydi. «Yo‘q» — ekran aylanmaydi, slayd joriy holatda ko‘rsatiladi.';

  @override
  String get lectureRotateCastBody =>
      'Televizor va monitorlar gorizontal: uzatishda gorizontal holat tavsiya etiladi.';

  @override
  String get lectureRotateYes => 'Ha';

  @override
  String get lectureRotateNo => 'Yo‘q';

  @override
  String get lectureRotateRemember => 'Qayta so‘ramaslik';

  @override
  String get lectureOrientationMenu => 'Taqdimotda ekran holati';

  @override
  String get lectureOrientationAsk => 'Doim so‘rash';

  @override
  String get lectureOrientationLandscape => 'Doim gorizontal';

  @override
  String get lectureOrientationKeep => 'Aylantirmaslik';

  @override
  String get lectureMore => 'Boshqa amallar';

  @override
  String get lectureCast => 'Ekranga uzatish';

  @override
  String get lectureCastTitle => 'Televizor yoki monitorga uzatish';

  @override
  String get lectureCastHow =>
      'Uzatish telefonning o‘z «ekranni takrorlash» funksiyasi orqali ishlaydi: televizorda telefon ekrani ko‘rinadi. Taqdimot rejimida ekranda faqat slayd bo‘ladi (tugmalarsiz), ekran o‘chmaydi.';

  @override
  String get lectureCastStepsAndroid =>
      '1. Telefon va televizor bitta Wi‑Fi tarmog‘ida bo‘lsin.\n2. «Ekranni uzatish» (Cast, Smart View, Miracast — nomi telefonga qarab) ni oching va televizorni tanlang.\n3. Ilovaga qayting va «Taqdimotni boshlash» ni bosing.';

  @override
  String get lectureCastStepsIos =>
      '1. iPhone/iPad va televizor (Apple TV yoki AirPlay qo‘llaydigan) bitta Wi‑Fi tarmog‘ida bo‘lsin.\n2. Boshqaruv markazini oching (yuqori o‘ng burchakdan pastga suring) → «Ekranni takrorlash» (Screen Mirroring) → televizorni tanlang.\n3. Ilovaga qayting va «Taqdimotni boshlash» ni bosing.';

  @override
  String get lectureCastOpenSettings => 'Uzatish sozlamasini ochish';

  @override
  String get lectureCastSettingsFailed =>
      'Sozlamani ochib bo‘lmadi — telefon sozlamalari yoki tezkor panelidan «Ekranni uzatish» ni toping.';

  @override
  String get lectureCastStart => 'Taqdimotni boshlash';

  @override
  String get lecturePresenter => 'Taqdimotchi rejimi';

  @override
  String get lecturePresenterNext => 'Keyingi slayd';

  @override
  String get lecturePresenterLast => 'Bu oxirgi slayd';

  @override
  String get lecturePresenterTimer => 'Vaqt';

  @override
  String get lecturePresenterReset => 'Vaqtni qaytadan boshlash';

  @override
  String get lecturePresenterNote =>
      'Taqdimotchi rejimi faqat shu qurilmada. Televizorga uzatilsa, televizorda ham shu ko‘rinish chiqadi (ekran takrorlanadi) — auditoriya uchun «To‘liq ekran» dan foydalaning.';

  @override
  String get topicTestAction => 'Mavzu testi';

  @override
  String get topicTestPreparing => 'Bu mavzu uchun savollar tayyorlanmoqda';

  @override
  String get topicTestPreparingShort => 'Savollar tayyorlanmoqda';

  @override
  String topicTestPreparingBody(int count) {
    return 'Testga faqat tekshirilgan savollar qo‘yiladi. Hozircha bu mavzu bo‘yicha $count ta bor — kamida 3 ta kerak.';
  }

  @override
  String topicTestIntro(int count) {
    return '$count ta savol · har javobdan keyin to‘g‘ri javob va izoh';
  }

  @override
  String get topicTestSavedNote =>
      'Chiqib ketsangiz ham javoblar saqlanadi — keyin shu joydan davom ettirasiz.';

  @override
  String get topicTestSourcesNote =>
      'Savollar faqat tekshirilgan manbalardan: kaliti tasdiqlangan rasmiy savollar va manbasi ko‘rsatilgan mashq savollari.';

  @override
  String get topicTestStart => 'Testni boshlash';

  @override
  String topicTestResume(int answered, int total) {
    return 'Davom ettirish · $answered/$total';
  }

  @override
  String topicTestBest(int score, int total) {
    return 'Eng yaxshi natija: $score/$total';
  }

  @override
  String topicTestBadgeLabel(int score, int total) {
    return 'Mavzu testi, eng yaxshi natija $score / $total';
  }

  @override
  String get topicTestRetake => 'Qayta topshirish';

  @override
  String get topicTestNextTopic => 'Keyingi mavzu';

  @override
  String get topicTestOpenSlide => 'Slaydni ko‘rish';

  @override
  String get topicTestOpenDeckStart => 'Taqdimotni boshidan ko‘rish';

  @override
  String get topicTestHistory => 'Natijalar tarixi';

  @override
  String get topicTestAssign => 'Guruhga topshirish';

  @override
  String topicTestLimitBody(int minutes) {
    return 'Har bir talabaga boshlagan paytidan $minutes daqiqa beriladi. Vaqt tugasa, javoblar o‘zi yuboriladi.';
  }

  @override
  String get topicTestLimitNoneBody =>
      'Vaqt chegarasi yo‘q — talaba testni muddat ichida istalgan vaqtda yechadi.';

  @override
  String get topicTestOpenFor => 'Test qancha vaqt ochiq turadi';

  @override
  String get topicTestAssignSub =>
      'Talabalar QR yoki kod bilan qo‘shilib yechadi, natijalar sizda chiqadi';

  @override
  String get topicTestSelf => 'O‘zim yechib ko‘rish';

  @override
  String get topicTestSelfSub =>
      'Faqat sizda saqlanadi, talabalarga yuborilmaydi';

  @override
  String get topicTestAssignIntro =>
      'Talabalar testni o‘z telefonida muddatgacha topshiradi; ball serverda hisoblanadi.';

  @override
  String get topicTestGroups => 'Guruhlar';

  @override
  String get topicTestNoGroups => 'Sizda hali guruh yo‘q';

  @override
  String get topicTestNoGroupsBody =>
      'Avval guruh oching va talabalarni taklif qiling — keyin testni shu yerdan topshirasiz.';

  @override
  String get topicTestPickGroup => 'Kamida bitta guruhni tanlang';

  @override
  String get topicTestReveal => 'To‘g‘ri javoblar talabaga';

  @override
  String get topicTestRevealNow => 'Topshirgach darhol';

  @override
  String get topicTestRevealAfterDue => 'Muddat tugagach';

  @override
  String get topicTestRevealNeedsDue =>
      '“Muddat tugagach” uchun topshirish muddatini tanlang';

  @override
  String topicTestSent(int count) {
    return 'Test yuborildi: $count ta guruh';
  }

  @override
  String topicTestTitle(String title) {
    return 'Mavzu testi: $title';
  }

  @override
  String get topicTestSentList => 'Yuborilgan testlar';

  @override
  String topicTestAnswersLater(String date) {
    return 'To‘g‘ri javoblar muddat tugagach ($date) yoki ustoz testni yakunlaganda ochiladi';
  }

  @override
  String get topicTestDistribution => 'Natijalar taqsimoti';

  @override
  String get topicTestHardest => 'Eng qiyin savollar';

  @override
  String get topicTestAssignedTitle => 'Topshirilgan testlar';

  @override
  String get topicTestMenu => 'Amallar';

  @override
  String get topicTestOpenLecture => 'Taqdimotni ochish';

  @override
  String get topicTestCreateGroup => 'Guruh ochish';

  @override
  String topicTestStudents(int count) {
    return '$count ta talaba';
  }

  @override
  String topicTestReworkMistakes(int count) {
    return 'Xatolarni takrorlash · $count';
  }

  @override
  String get cmErrAbusive =>
      'Matnda haqoratli yoki so‘kinish so‘zlari bor. Iltimos, hurmat bilan qayta yozing — hamjamiyat qoidalari shuni talab qiladi.';

  @override
  String get admDeleteTitle => 'Hisobni o‘chirish';

  @override
  String get admDeleteNote =>
      'Email orqali kelgan o‘chirish so‘rovi uchun (30 kun ichida bajariladi). Tasdiq uchun foydalanuvchining to‘liq emailini kiriting — server uning aynan shu hisobga tegishliligini tekshiradi. Hisob, guruh a’zoligi, hamjamiyat postlari, murojaatlar va kirish usullari butunlay o‘chadi; Apple bilan kirgan bo‘lsa, Apple tokenini bekor qilish urinib ko‘riladi. Qaytarib bo‘lmaydi; amal jurnalga yoziladi.';

  @override
  String get admDeleteEmail => 'Foydalanuvchining to‘liq emaili';

  @override
  String get admDeleteButton => 'Hisobni butunlay o‘chirish';

  @override
  String get admDeleteConfirmTitle => 'Hisob butunlay o‘chirilsinmi?';

  @override
  String admDeleteConfirmBody(String email) {
    return '$email hisobi va unga bog‘liq hamma ma’lumot o‘chiriladi. Bu amalni qaytarib bo‘lmaydi.';
  }

  @override
  String get admDeleteDone => 'Hisob o‘chirildi';

  @override
  String get admDeleteMismatch =>
      'Bu email shu hisobga tegishli emas — tekshirib, qayta kiriting.';

  @override
  String analyteSourcesBased(String sources) {
    return 'Manbalarga asoslangan: $sources';
  }

  @override
  String get sourcesPanelTitle => 'Manbalar';

  @override
  String get sourcesDisclaimer =>
      'O‘quv ma’lumotnomasi, tashxis emas: natijani shifokor klinik ma’lumotlar bilan baholaydi; referens oraliqlar laboratoriya va usulga bog‘liq.';

  @override
  String get refBooksNote =>
      'Kitoblar faqat manba sifatida keltirilgan — matn va rasmlar ko‘chirilmagan. Xulosa — shifokorda.';

  @override
  String sourceLine(String cite) {
    return 'Manba: $cite';
  }

  @override
  String get packsCoreSources =>
      'Manbalarga asoslangan o‘quv ma’lumotnomasi — har kartada adabiyot ro‘yxati bor';

  @override
  String get examPracticeNotice =>
      'Natija — ichki mashq uchun, rasmiy baho emas.';

  @override
  String sourcesPanelMore(int count) {
    return '+ yana $count ta manba — pastdagi ro‘yxatda';
  }

  @override
  String get classesPasteLink => 'Havolani qo‘yish';

  @override
  String get classesPasteNoCode =>
      'Nusxada taklif kodi topilmadi. Ustoz yuborgan havola yoki kodni nusxalang.';

  @override
  String get classesScanTip =>
      'QR kodni telefon kamerasi bilan skanerlang va ochilgan sahifada “Ilovada ochish” ni bosing — kod shu yerga o‘zi tushadi.';

  @override
  String get qrScanAction => 'QR kodni skanerlash';

  @override
  String get qrScanHint =>
      'Ustoz bergan guruh yoki test QR kodini ramka ichiga to‘g‘rilang';

  @override
  String get qrScanTorchOn => 'Chiroqni yoqish';

  @override
  String get qrScanTorchOff => 'Chiroqni o‘chirish';

  @override
  String get qrScanTypeCode => 'Kodni yozish yoki qo‘yish';

  @override
  String get qrScanNotInvite => 'Bu QR kod LabGuide guruh taklifi emas';

  @override
  String get qrScanDeniedTitle => 'Kameraga ruxsat berilmagan';

  @override
  String get qrScanDeniedBody =>
      'QR kodni o‘qish uchun sozlamalarda LabGuide’ga kamera ruxsatini bering. Kamera kadri faqat telefonda o‘qiladi — rasm saqlanmaydi va yuborilmaydi. Yoki kodni qo‘lda yozing yoki havolani qo‘ying.';

  @override
  String get qrScanOpenSettings => 'Sozlamalarni ochish';

  @override
  String get qrScanFailedTitle => 'Kamerani ochib bo‘lmadi';

  @override
  String get qrScanFailedBody =>
      'Kodni qo‘lda yozing yoki ustoz yuborgan havolani qo‘ying.';

  @override
  String get qrScanStarting => 'Kamera ochilmoqda…';

  @override
  String get classesJoinOpensTest =>
      'Qo‘shilgach ustoz bergan test darhol ochiladi.';

  @override
  String get classesJoinSignInTitle => 'Guruhga qo‘shilish uchun kiring';

  @override
  String get classesJoinSignInBody =>
      'Google, Apple yoki email kodi bilan — bir daqiqa. Natijangiz ustozga shu hisob orqali boradi; taklif kodi saqlanib qoladi.';

  @override
  String get classesNicknameTaken =>
      'Bu taxallus guruhda band — boshqasini yozing.';

  @override
  String get classesNicknameAbusive =>
      'Taxallusda nojo‘ya so‘z bor — boshqasini yozing.';

  @override
  String get classesTestQr => 'Test QR';

  @override
  String get classesTestQrBody =>
      'Talabalar skanerlaydi → kiradi → taxallus → shu test ochiladi. Natijalar shu sahifada o‘zi yangilanadi.';

  @override
  String get classesInviteLink => 'Havolani nusxalash';

  @override
  String get classesLiveNote =>
      'Natijalar har 10 soniyada o‘zi yangilanadi. Pastga torting — hozir yangilash.';

  @override
  String get boardOpen => 'Katta ekran';

  @override
  String get boardJoined => 'Guruhda';

  @override
  String get boardStarted => 'Yechmoqda';

  @override
  String get boardSubmitted => 'Topshirdi';

  @override
  String get boardStatusWaiting => 'Kutilmoqda';

  @override
  String get boardStatusSolving => 'Yechmoqda…';

  @override
  String get boardScan => 'Skanerlang va qo‘shiling';

  @override
  String get boardAnswersAfterClose =>
      'To‘g‘ri javoblar test yakunlangach ko‘rsatiladi.';

  @override
  String get boardEmpty => 'Hali hech kim yo‘q — QR ni skanerlang.';

  @override
  String get boardClose => 'Katta ekrandan chiqish';

  @override
  String get actionClose => 'Yopish';

  @override
  String get variantToggle => 'Har bir talabaga boshqa savollar';

  @override
  String variantOnBody(int pool, int n) {
    return 'Har talabaga mavzudagi $pool ta savoldan $n tasi tushadi — kichik mavzular bo‘yicha teng taqsimlanadi.';
  }

  @override
  String get variantOffBody =>
      'Hamma talabaga bir xil savollar (tartibi aralashtiriladi).';

  @override
  String variantDisabledBody(int pool, int need) {
    return 'Mavzuda $pool ta savol bor — har talabaga boshqa to‘plam uchun kamida $need ta kerak (savollar sonidan 2 barobar). Savollar sonini kamaytiring.';
  }

  @override
  String get variantUnsupported => 'Variantli test bu serverda qo‘llanmaydi.';

  @override
  String variantPoolTitle(int pool) {
    return 'Savollar hovuzi ($pool)';
  }

  @override
  String get variantLabel => 'Variantli test';

  @override
  String variantPerStudent(int n, int pool) {
    return 'Har talabaga $n ta savol, hovuzda $pool ta';
  }

  @override
  String variantReceived(int n) {
    return '$n ta talabaga tushdi';
  }

  @override
  String get homeResumeCta => 'Davom ettirish';

  @override
  String homeResumeBody(String title) {
    return 'Oxirgi ochilgan: $title';
  }

  @override
  String get homeHeroLabToifaCta => 'Bugungi baholash mashg‘uloti';

  @override
  String get helpTitle => 'Yordam va aloqa';

  @override
  String get helpSub => 'Ilovada yozish yoki email — savol, taklif, shikoyat';

  @override
  String get helpIntro =>
      'Qulay yo‘lni tanlang: ilova ichidagi yozishma (javob shu yerga keladi) yoki email (shikoyat, maxfiylik so‘rovi).';

  @override
  String get learnSectionQuizzesTitle => 'Bo‘lim mashqlari';

  @override
  String learnSectionQuizRow(String section) {
    return '$section — mashq';
  }

  @override
  String get classesNicknameInvalid =>
      'Taxallusda faqat harf, raqam, bo‘shliq va . _ \' - bo‘lishi mumkin; harf yoki raqam bilan boshlanib tugasin (emoji va !?@ kabi belgilarsiz).';

  @override
  String get classesGroupFull =>
      'Guruh to‘lgan (200 kishi) — ustozingizga ayting.';

  @override
  String get classesCodeAmbiguous =>
      'Kodda 0, O, 1 va I belgilari bo‘lmaydi. Kodni ustozdan qayta tekshiring yoki QR’ni skanerlang.';

  @override
  String get classesOwnGroupTitle => 'Siz bu guruhning ustozisiz';

  @override
  String get classesOwnGroupBody =>
      'Bu hisob guruhni ochgan, shuning uchun unga talaba bo‘lib qo‘shila olmaydi (Profildagi rolni almashtirish buni o‘zgartirmaydi). Talaba sifatida sinash uchun boshqa hisob bilan kiring yoki testni talaba ko‘rinishida sinab ko‘ring.';

  @override
  String get classesOwnGroupOpen => 'Ustoz sifatida ochish';

  @override
  String get classesSwitchAccount => 'Boshqa hisob bilan kirish';

  @override
  String get classesPreviewAsStudent => 'Talaba ko‘rinishida sinash';

  @override
  String get classesPreviewNote =>
      'Sinov rejimi: javoblar serverga yuborilmaydi va natijalar ro‘yxatida ko‘rinmaydi.';

  @override
  String classesPreviewResult(int correct, int total) {
    return 'Sinov tugadi: $correct / $total to‘g‘ri. Natija yuborilmadi.';
  }

  @override
  String get classesGiveTopicTest => 'Mavzu testi berish';

  @override
  String get classesGiveTopicTestSub =>
      'Mavzuni tanlang — keyingi sahifada savollar soni, variantli test, muddat va javoblar qachon ochilishi.';

  @override
  String get classesTopicSearchHint => 'Mavzuni qidiring (masalan, anemiya)';

  @override
  String get classesTopicNoMatch => 'Testi tayyor mavzu topilmadi';

  @override
  String classesTopicQuestions(int count) {
    return '$count ta savol';
  }

  @override
  String examDeadlineAt(String date) {
    return 'Muddat: $date';
  }

  @override
  String get classesScanAskNick =>
      'Qo‘shilishdan oldin taxallusingizni yozing — ustoz natijangizni shu nom bilan ko‘radi (ixtiyoriy: bo‘sh qoldirsangiz, tartib raqami). So‘ng «Qo‘shilish».';

  @override
  String get classesMyNickname => 'Taxallusim';

  @override
  String get classesNoNickname => 'Yo‘q — ustozda tartib raqamingiz ko‘rinadi';

  @override
  String get classesNicknameSaved => 'Taxallus saqlandi';

  @override
  String get classesNicknameNote =>
      'Haqiqiy ismingizni yozmang. Bo‘sh qoldirsangiz — tartib raqami.';

  @override
  String get rolesTeacherRegisterNote =>
      '«Davom etish» hisobingizni ustoz sifatida ro‘yxatdan o‘tkazadi: faqat o‘zingiz ochgan guruhlarni boshqarasiz va ularning natijalarini ko‘rasiz (admin huquqi emas).';

  @override
  String get rolesTeacherSignInNote =>
      'Guruh ochish uchun hisobga kiring — kirgan hisob guruh yaratishda bir bosishda ustoz sifatida ro‘yxatdan o‘tadi.';

  @override
  String get classesGiveGeneralTest => 'Umumiy test berish';

  @override
  String get generalTestSub => 'Bir nechta mavzudan — 50 tagacha savol';

  @override
  String get generalTestIntro =>
      'Mavzularni tanlang — savollar ular orasida teng taqsimlanadi. Talabalar testni o‘z telefonida topshiradi, ball serverda hisoblanadi.';

  @override
  String get generalTestSources => 'Savollar qayerdan';

  @override
  String get generalTestSearchHint => 'Mavzuni qidiring (masalan, anemiya)';

  @override
  String get generalSourceToifa => 'Bilim va malaka savollari';

  @override
  String get generalSourceToifaSub =>
      'Rasmiy KDL ro‘yxati, kalitlari tekshirilgan';

  @override
  String get generalSourceLecture => 'Ma’ruza mavzulari';

  @override
  String get generalSourceLectureSub => 'Butun modul yoki alohida kun';

  @override
  String get generalSourcePack => 'Analizlar bo‘yicha';

  @override
  String get generalSourcePackSub => 'Analiz kartalari savollari';

  @override
  String get generalSourceToifaShort => 'Bilim va malaka';

  @override
  String get generalSourceLectureShort => 'Ma’ruza';

  @override
  String get generalSourcePackShort => 'Analizlar';

  @override
  String get generalSelectAll => 'Hammasini tanlash';

  @override
  String get generalAllShort => 'hammasi';

  @override
  String generalDays(int count) {
    return 'Kunlar · $count';
  }

  @override
  String generalSelected(int topics, int questions) {
    return 'Tanlandi: $topics ta mavzu · $questions ta savol';
  }

  @override
  String get generalPickTopic => 'Kamida bitta mavzuni tanlang';

  @override
  String generalTestTitle(String topics) {
    return 'Umumiy test: $topics';
  }

  @override
  String get generalTestNameHint => 'Masalan, 1-oraliq nazorat';

  @override
  String get calSafeKind => 'Yozuv turi';

  @override
  String get calSafeKindTraining => 'O‘quv';

  @override
  String get calSafeKindLab => 'Laboratoriya';

  @override
  String get calSafeTrainingTag => 'O‘quv';

  @override
  String get calSafeTrainingNote =>
      'O‘quv yozuvi: bu laboratoriya dalili emas.';

  @override
  String get calSafeApprovedBy => 'Tasdiqlagan (ism / lavozim)';

  @override
  String get calSafeApprovedAt => 'Tasdiqlangan sana';

  @override
  String get calSafeApproverRequired =>
      '«Qabul qilindi» uchun vakolatli shaxsning ismi yoki lavozimini kiriting.';

  @override
  String get calSafeQcAfter => 'Kalibrlashdan keyingi QC';

  @override
  String get calSafeQcPass => 'QC o‘tdi';

  @override
  String get calSafeQcFail => 'QC o‘tmadi';

  @override
  String get calSafeQcNotRun => 'QC o‘tkazilmagan';

  @override
  String get calSafeQcNotRunWarn => 'Kalibrlashdan keyin QC o‘tkazilmagan';

  @override
  String get calSafeQcPassRequired =>
      '«Qabul qilindi» faqat kalibrlashdan keyingi QC o‘tgandagina mumkin.';

  @override
  String get calSafeSopRef => 'SOP havolasi (ixtiyoriy)';

  @override
  String get calSafeLegacyTag => 'Eski yozuv, tasdiqlanmagan';

  @override
  String get calSafeHistory => 'Tarix';

  @override
  String get calSafeHistoryEmpty => 'Tarix yozuvlari yo‘q.';

  @override
  String get calSafeAuditCreated => 'Yaratildi';

  @override
  String get calSafeAuditEdited => 'Tahrirlandi';

  @override
  String get calSafeAuditDeleted => 'O‘chirildi';

  @override
  String get calSafeHistoryNote =>
      'Yozuv o‘chirilsa ham tarix qoladi. Uni faqat «Lokal ma’lumotlarni o‘chirish» tozalaydi.';

  @override
  String get labDirSection => 'Laboratoriya yo‘nalishlari (ma’lumotnoma)';

  @override
  String get labDirSectionSub => 'Platforma va test alohida kartalarda';

  @override
  String labDirRowTitle(String name) {
    return '$name — ma’lumotnoma kartalari';
  }

  @override
  String get labDirTb => 'Sil (TB) diagnostikasi';

  @override
  String get labDirHiv => 'OIV laboratoriya diagnostikasi';

  @override
  String get labDirTag => 'Ma’lumotnoma';

  @override
  String get labDirNotVerified => 'Hali kiritilmagan';

  @override
  String get labDirKindPlatform => 'Platforma (apparat)';

  @override
  String get labDirKindTest => 'Test';

  @override
  String get labDirKindMethod => 'Usul';

  @override
  String get labDirVsTest => 'Platforma va test';

  @override
  String get labDirTechnology => 'Texnologiya';

  @override
  String get labDirSpecimens => 'Namunalar';

  @override
  String get labDirTasks => 'Vazifalar';

  @override
  String get labDirPrinciple => 'Ishlash tamoyili';

  @override
  String get labDirLimitations => 'Cheklovlar';

  @override
  String get labDirQc => 'Sifat nazorati va kalibrlash';

  @override
  String get labDirErrors => 'Preanalitik va analitik xatolar';

  @override
  String get labDirBiosafety => 'Biologik xavfsizlik';

  @override
  String get labDirModels => 'Rasmiy manbada tasdiqlangan modellar';

  @override
  String get labDirLinked => 'Bog‘langan kartalar';

  @override
  String get labDirStatusNeedsReview =>
      'Tekshiruv holati: manbalar quyida keltirilgan; mutaxassis xulosasi hali kiritilmagan';

  @override
  String get labDirManufacturerNote =>
      'Ishlab chiqaruvchi sahifasi (reklama materiali), yo‘riqnoma emas';

  @override
  String get labDirVirology => 'Virusologiya';

  @override
  String get labDirBacteriology => 'Bakteriologiya';

  @override
  String get labDirMycology => 'Mikologiya';

  @override
  String get labDirParasitology => 'Parazitologiya';

  @override
  String get labDirHematology => 'Gematologiya';

  @override
  String get labDirCoagulation => 'Koagulologiya (gemostaz)';

  @override
  String get labDirTransfusion => 'Transfuziologiya';

  @override
  String get labDirBiochemistry => 'Klinik biokimyo';

  @override
  String get labDirImmunology => 'Immunologiya';

  @override
  String get labDirUrinalysis => 'Siydik tahlili';

  @override
  String get labDirCytology => 'Sitologiya';

  @override
  String get labDirHistology => 'Gistologiya';

  @override
  String get labDirOncology => 'Onkologiya';

  @override
  String get labDirGenetics => 'Genetika';

  @override
  String get labDirMolecular => 'Molekulyar diagnostika';

  @override
  String get labDirToxicology => 'Toksikologiya';

  @override
  String get labDirReproductive => 'Reproduktiv tibbiyot';

  @override
  String get labDirNeonatal => 'Neonatal laboratoriya diagnostikasi';

  @override
  String get labDirTransplant => 'Transplantologiya';

  @override
  String get labDirGeneral => 'Umumiy laboratoriya';

  @override
  String get labDirDisclaimer =>
      'Faqat o‘quv ma’lumotnomasi. Ilova tashxis qo‘ymaydi va amaliy protokol emas; qaror — vakolatli laboratoriya va shifokorniki.';

  @override
  String get labDirEmpty => 'Bu yo‘nalishda kartalar yo‘q.';

  @override
  String get labDirPlatformClassNote =>
      'Sinf/texnologiya bo‘yicha ma’lumot — aniq model uchun tasdiqlanmagan';

  @override
  String get labSchemGcMs =>
      'GC-MS apparat sinfi — tashuvchi gaz ballon, avtonamunaoluvchili gaz xromatografi va termostatdagi kapillyar kolonka, ion manbai, kvadrupol mass-analizator, detektor, vakuum nasoslari va ma’lumotlar tizimi';

  @override
  String get labSchemLcMs =>
      'LC-MS apparat sinfi — erituvchi idishlari, nasos, avtonamunaoluvchi, kolonka termostati, elektropurkash ion manbai, kvadrupol mass-analizator, detektor, vakuum nasoslari va ma’lumotlar tizimi';

  @override
  String get labSchemMaldiTof =>
      'MALDI-TOF mass-spektrometr sinfi — namuna dog‘lari bor nishon plastina, lazer, tezlatuvchi to‘rlar, uchish trubasi, detektor, vakuum nasosi va spektr ekrani';

  @override
  String get labSchemMicrobialIdAst =>
      'Avtomatik mikrobiologik identifikatsiya va sezuvchanlik tizimi sinfi — suspenziya probirkalari va test kartalari bor kasseta, optik skanerli inkubator-o‘quvchi, yuklash kamerasi va monitor';

  @override
  String get labSchemBloodCulture =>
      'Avtomatik gemokultura tizimi sinfi — qatorlab flakonlar joylangan inkubator shkaf (har flakon tubida sensor va holat chirog‘i) va monitor; yonida aerob va anaerob flakonlar';

  @override
  String get labSchemMycobacterialCulture =>
      'Mikobakteriyalar uchun avtomatik suyuq muhit tizimi sinfi — probirkalar tortmalari va holat chiroqlari bor inkubator-o‘quvchi, monitor; yonida tubida fluoressent kislorod sensori bor probirkalar';

  @override
  String get labSchemFlowCytometer =>
      'Oqim sitometri sinfi — qobiq suyuqligi va chiqindi idishlari, gidrodinamik fokuslash, lazer, oqim kyuvetasi, to‘g‘ri sochilish detektori, dixroik ko‘zgular ortidagi yon sochilish va fluoressensiya detektorlari, namuna probirkasi va nuqtali diagramma ekrani';

  @override
  String get labSchemRealTimePcr =>
      'Real vaqt PCR amplifikatori sinfi — quduqchali termoblok, isitiladigan qopqoq, fluoressensiya yo‘li kesigi (qo‘zg‘atuvchi nur manbai va filtri → termoblokdagi reaksiya probirkasi → nurlanish filtri → detektor), probirkalar qatori va kuchayish egri chiziqlari ekrani';

  @override
  String get labSchemCartridgeMolecular =>
      'Kartrijli yopiq molekulyar platforma sinfi — alohida modulli apparat (bittasi ochiq, ichida kartrij), bir martalik ko‘p kamerali kartrij, namuna idishi va monitor';

  @override
  String get labSchemCoagAnalyzer =>
      'Avtomatik koagulometr sinfi — sovutilgan reagent joylari, o‘lchash kyuvetalari, pipetka qo‘li, sitratli probirkalar, optik laxta aniqlash (yorug‘lik manbai, kyuveta, fotodetektor) va ivish egri chizig‘i ekrani';

  @override
  String get labSchemElisaReader =>
      'Mikroplanshet (ELISA) o‘quvchisi va yuvish qurilmasi sinfi — rangli 96 quduqchali planshet tashuvchisi bor o‘quvchi, quduqcha orqali detektorga optik yo‘l, ignalar qatori bor yuvish qurilmasi, yuvish eritmasi va chiqindi idishlari';

  @override
  String get labSchemBscClass2 =>
      'II sinf biologik xavfsizlik shkafi, yon kesim — xona havosi old ochiqlikdan old panjaraga kiradi, HEPA filtrdan o‘tgan havo ish yuzasi ustidan pastga oqadi, orqa kanal orqali ventilyatorga qaytadi, bir qismi ikkinchi HEPA filtr orqali chiqariladi';

  @override
  String get labSchemAutoclave =>
      'Stol usti bug‘li avtoklav sinfi — tagligi va o‘ralgan buyumlari bor kamera, zichlagichli ochiq eshik, bosim va harorat ko‘rsatkichlari, xavfsizlik klapani va suv idishi';

  @override
  String get labSchemBloodGasIse =>
      'Qon gazlari va elektrolitlar (ISE) analizatori sinfi — displey, printer, qon gazi shprisi ulangan namuna zondi, o‘lchash kanali bo‘ylab elektrodli sensor kassetasi va reagent paketi';

  @override
  String get labSchemHba1cAnalyzer =>
      'Ixcham HbA1c analizatori sinfi — displey, tugmalar, printer, namuna oluvchi qo‘lli EDTA butun qon probirkalari rakasi, reagent idishlari va chiqindi idishi';

  @override
  String get labSchemLabFridge =>
      'Harorat monitoringli laboratoriya sovutgich-muzlatgichi sinfi — shtativ va reagentlar bor shisha eshikli sovutgich, muzlatgich bo‘limi, buferli flakondagi datchik va tashqaridagi raqamli ma’lumot yozgich';

  @override
  String get labSchemFluorescenceMicroscope =>
      'LED fluoressent mikroskop sinfi — LED epi-yoritgich moduli va filtr surgichi bor tik mikroskop, obyektivlar, preparatli stolik; ichki rasmda qorong‘i fonda yorqin sarg‘ish-yashil tayoqchalar (auramin bilan bo‘yalgan batsillalar shunday ko‘rinadi)';

  @override
  String get labSchemCasa =>
      'Kompyuterli sperma tahlili (CASA) sinfi — kamerali va isitiladigan stolikli mikroskop, hisoblash kamerasi, harakatchan spermatozoidlar izlari ko‘rinadigan kompyuter ekraniga kabel';

  @override
  String get labSchemGelCardSystem =>
      'Gel (mikrokolonka) karta tizimi sinfi — karta sentrifugasi, inkubator va oltita mikronaychali kattalashtirilgan gel karta: musbatda eritrotsitlar gel ustida yoki ichida qoladi, manfiyda tubida tugma hosil qiladi';

  @override
  String get labSchemEsrAnalyzer =>
      'EChT sinfi — tik naychali Westergren shtativi (cho‘kkan eritrotsitlar ustida tiniq plazma) va yopiq probirkali, optik o‘qish chizig‘i bor avtomatik o‘quvchi';

  @override
  String get labSchemAggregometer =>
      'Trombotsit agregometri va viskoelastik analizator sinfi — aralashtiriladigan kyuvetali, yorug‘lik manbai va fotodetektorli yorug‘lik o‘tkazuvchi agregometr, agregatsiya egri chiziqlari; kosacha va pinli kanallari bor viskoelastik analizator va laxta trassasi';

  @override
  String get labSchemElectrophoresis =>
      'Elektroforez apparati sinfi — simli tok manbai, bufer bo‘limlari, elektrodlar, pilikchalar va bo‘yalgan oqsil fraksiyalari bor tashuvchi muhitli kamera, ko‘tarilgan qopqoq va skan egri chizig‘ini ko‘rsatuvchi densitometr';

  @override
  String get labSchemOsmometer =>
      'Muzlash nuqtasi osmometri sinfi — namuna probirkasi joylangan sovutish bloki, namunaga botirilgan termistor zondi, aralashtirgich sim, muzlash egri chizig‘i ko‘rsatilgan displey, tugmalar va kichik probirkalar';

  @override
  String get labSchemTlc =>
      'Yupqa qatlam xromatografiyasi jihozlari — qopqoqli shisha kamera, erituvchi va plastina (start chizig‘i, ajralgan dog‘lar, erituvchi fronti); rivojlantirilgan plastina ustida UB lampa: dog‘lar fluoressent fonda qorong‘i ko‘rinadi';

  @override
  String get labSchemAnalyticalBalance =>
      'Gravimetrik kalibrlash jihozlari — shamoldan himoya qutili analitik tarozi va tortish idishi, suv quyayotgan pipetka, termometrli suv idishi';

  @override
  String get imgDiagramCalibrationOverviewAlt =>
      'Kalibrlash tartibi sxemasi: 1 model, reagent va yo‘riqnoma versiyasi; 2 kalibrator loti, qiymatlar aynan shu lotning qiymatlar varag‘idan; 3 metodga mos tayyorlash; 4 yo‘riqnoma bo‘yicha kalibrlash. Qaror: kalibrlashdan keyingi QC o‘tdimi? Ha — vakolatli shaxs qabul qiladi; yo‘q — qabul qilinmaydi, sabab IFU va SOP bo‘yicha izlanadi. Parametrlar faqat mos IFU’dan olinadi.';

  @override
  String get imgDiagramDifferentialCountAlt =>
      'Leykoformulani qo‘lda sanash sxemasi: 1 surtmani baholang (tekis, chiziq va teshiksiz; yomon bo‘lsa — yangisini tayyorlang); 2 ×100 immersiyada bir qavatli zonada, bir yo‘nalishda, maydonlarni takrorlamay sanang; 3 SOP bo‘yicha, odatda 100 hujayra sanang; 4 har bir tur ulushi %, mutlaq son = ulush × WBC. Qaror: blast yoki aniqlanmagan hujayra bormi? Ha — o‘zingiz talqin qilmang, surtmani gematolog yoki shifokor ko‘rsin; yo‘q — laboratoriya blankasidagi referens interval bilan solishtiring.';

  @override
  String get imgDiagramQcDecisionAlt =>
      'Sifat nazorati seriyasi bo‘yicha qaror sxemasi: 1 nazorat materiallarini o‘lchash; 2 qiymatlarni Levey–Jennings grafigiga maqsadli o‘rtacha ± SD bo‘yicha qo‘yish. Qaror: rad qoidasi buzildimi (1-3s, 2-2s, R-4s, 4-1s, 10x)? Yo‘q — seriya qabul qilinadi (faqat 1-2s — ogohlantirish). Ha — seriya rad etiladi: tekshiruv to‘xtatiladi, bemor natijalari berilmaydi; sabab izlanadi, nazorat shunchaki takrorlanmaydi; tuzatilib, QC va bemor namunalari qayta tekshiriladi; QC tiklangach natija beriladi, choralar yoziladi.';

  @override
  String get imgDiagramPreanalyticsAlt =>
      'Preanalitik bosqich sxemasi, besh qadam: 1 tahlilga tayyorlash (bemor tayyorgarligi); 2 namuna va qo‘shimchani tanlash (tahlilga mos probirka, olish tartibi); 3 olish va identifikatsiya (to‘liq ism yo‘llanmaga mos); 4 ajratish va saqlash, namuna barqarorligi muddatida; 5 tashish va qabul qilish, yorliq va yo‘llanmani qayta tekshirish. Qaror: namuna yaroqlimi? Ha — tahlil; yo‘q — laboratoriya SOP’iga ko‘ra.';

  @override
  String get imgDiagramPhotometryAlt =>
      'Absorbsion fotometriya sxemasi: nur manbai, filtr (to‘lqin uzunligi λ), optik yo‘li ℓ bo‘lgan kyuveta, detektor va natija. Tushayotgan nur I0, o‘tgan nur I; yutilish (optik zichlik) A = log10(I0/I); Buger–Lambert–Ber qonuni A = ε·ℓ·c. Blank, standart va namuna o‘lchanadi; C = (A namuna ÷ A standart) × C standart. Chiziqlilik chegarasidan oshsa — suyultirib takrorlanadi va natija suyultirish darajasiga ko‘paytiriladi. To‘lqin uzunligi, blank va chegaralar — reagent IFU’siga ko‘ra.';

  @override
  String get imgDiagramEducationalFeedbackAlt =>
      'Test natijasidan o‘rganish sxemasi: 1 savollarga javob bering; 2 natijani ko‘ring. Qaror: xato bormi? Yo‘q — qayta boshlash yoki boshqa mavzu. Ha — 3 xatolar ustida ishlash: to‘g‘ri javob va izoh; 4 faqat xato javob berilgan savollarni qayta ishlash, so‘ng yana javob berish. Ilova ishlash tartibi, laboratoriya jarayoni emas.';

  @override
  String get imgDiagramCaption =>
      'LabGuide uchun chizilgan umumiy sxema. Apparatingiz IFU si va laboratoriya SOP i ustun.';

  @override
  String get imgDiagramTapToZoom => 'Kattalashtirish uchun sxemani bosing';

  @override
  String get stepUpTitle => 'Shaxsingizni tasdiqlang';

  @override
  String stepUpBodyEmail(String email) {
    return 'Bu amal uchun yangi tasdiq kerak. $email manziliga yuborilgan 6 xonali kodni kiriting.';
  }

  @override
  String get stepUpBodyEmailNoAddress =>
      'Bu amal uchun yangi tasdiq kerak. Emailingizga yuborilgan 6 xonali kodni kiriting.';

  @override
  String get stepUpBodyTotp =>
      'Bu amal uchun yangi tasdiq kerak. Autentifikator ilovasidagi 6 xonali kodni kiriting.';

  @override
  String get stepUpConfirm => 'Tasdiqlash';

  @override
  String get stepUpCancelled =>
      'Bajarilmadi: bu amal uchun yangi tasdiq kodi kerak.';

  @override
  String get admRevokeSessions => 'Barcha qurilmalardan chiqarish';

  @override
  String get admRevokeSessionsBody =>
      'Foydalanuvchi barcha qurilmalardan chiqariladi. Hisob faol qoladi — u qayta kira oladi.';

  @override
  String admRevokeSessionsDone(int count) {
    return 'Tugatilgan sessiyalar: $count.';
  }

  @override
  String get profileSignOutAll => 'Barcha qurilmalardan chiqish';

  @override
  String get profileSignOutAllBody =>
      'Shu telefonda va hisobingizga kirilgan boshqa barcha qurilmalarda chiqasiz. Shu qurilmadagi ma’lumotlar saqlanadi.';

  @override
  String get profileSignOutAllDone => 'Barcha qurilmalardan chiqildi.';

  @override
  String get schemPartsPanelTitle => 'Qismlari va ishlash prinsipi';

  @override
  String get schemPartsPanelHint =>
      'Rasmdagi raqamlar bo‘yicha qismlar, prinsip va natija';

  @override
  String get schemPartsPartsTitle => 'Asosiy qismlar';

  @override
  String get schemPartsPrincipleTitle => 'Ishlash prinsipi';

  @override
  String get schemPartsResultTitle => 'Natija';

  @override
  String get schemPartsClassNote =>
      'Qismlar apparat sinfi uchun umumiy, tamoyil darajasida ko‘rsatilgan; aniq modelda joylashuvi va tuzilishi boshqacha bo‘lishi mumkin.';

  @override
  String get schemPartsChemistrySamplesName => 'Namuna joyi';

  @override
  String get schemPartsChemistrySamplesFn =>
      'Probirkalar rakada turadi; zond namunani shu yerdan oladi.';

  @override
  String get schemPartsChemistryReagentsName =>
      'Sovutiladigan reagent karuseli';

  @override
  String get schemPartsChemistryReagentsFn =>
      'Reagent idishlari sovuqda saqlanadi; kerakli reagent zond tagiga buriladi.';

  @override
  String get schemPartsChemistryProbesName => 'Namuna va reagent zondlari';

  @override
  String get schemPartsChemistryProbesFn =>
      'Aniq hajmda namuna va reagentni olib, reaksiya kyuvetasiga quyadi.';

  @override
  String get schemPartsChemistryReactionName =>
      'Reaksiya karuseli (kyuvetalar)';

  @override
  String get schemPartsChemistryReactionFn =>
      'Kyuvetalardagi aralashma 37 °C da ushlanadi; karusel ularni fotometr oldidan o‘tkazadi.';

  @override
  String get schemPartsChemistryPhotometerName => 'Fotometr';

  @override
  String get schemPartsChemistryPhotometerFn =>
      'Lampa nuri kyuvetadan o‘tadi; panjarali yoki filtrli optika tanlangan to‘lqin uzunligida yutilishni o‘lchaydi.';

  @override
  String get schemPartsChemistryWaterName => 'Tozalangan suv idishi';

  @override
  String get schemPartsChemistryWaterFn =>
      'Zond va kyuvetalarni yuvish hamda suyultirish uchun suv beradi.';

  @override
  String get schemPartsChemistryWasteName => 'Suyuq chiqindi idishi';

  @override
  String get schemPartsChemistryWasteFn =>
      'Yuvish suvi va ishlatilgan reaksiya aralashmalari shu yerga to‘planadi.';

  @override
  String get schemPartsChemistryComputerName => 'Kompyuter va dastur';

  @override
  String get schemPartsChemistryComputerFn =>
      'Testlarni buyuradi, kalibrlashni yuritadi, natijani hisoblab hisobot beradi.';

  @override
  String get schemPartsChemistryPrinciple =>
      'Zondlar namuna va reagentni reaksiya kyuvetasiga quyadi, aralashma 37 °C da inkubatsiya qilinadi. Fotometr kyuvetadan o‘tgan nurning tanlangan to‘lqin uzunligidagi yutilishini o‘lchaydi. Konsentratsiya kalibrlash bo‘yicha hisoblanadi; ko‘p modellarda Na, K, Cl ionselektiv elektrod (ISE) bilan o‘lchanadi.';

  @override
  String get schemPartsChemistryResult =>
      'Har bir test bo‘yicha analit konsentratsiyasi (masalan, glyukoza, ferment faolligi, elektrolitlar): yutilish o‘zgarishidan kalibrlash bo‘yicha hisoblangan qiymat va hisobot.';

  @override
  String get schemPartsPhotometerDisplayName => 'Displey va klaviatura';

  @override
  String get schemPartsPhotometerDisplayFn =>
      'Usul, to‘lqin uzunligi va standart tanlanadi; natija va egri chiziq shu yerda ko‘rinadi.';

  @override
  String get schemPartsPhotometerNeedleName => 'So‘rish ignasi';

  @override
  String get schemPartsPhotometerNeedleFn =>
      'Tayyor aralashmani probirkadan o‘lchash kyuvetasiga so‘rib oladi.';

  @override
  String get schemPartsPhotometerCellName =>
      'O‘lchash kamerasi (oqim kyuvetasi)';

  @override
  String get schemPartsPhotometerCellFn =>
      'Lampa → interferension filtr → kyuveta → fotodetektor: yutilish shu yerda o‘lchanadi.';

  @override
  String get schemPartsPhotometerPrinterName => 'Termoprinter';

  @override
  String get schemPartsPhotometerPrinterFn =>
      'Natijalarni qog‘ozga chop etadi.';

  @override
  String get schemPartsPhotometerWasteName => 'Chiqindi idishi';

  @override
  String get schemPartsPhotometerWasteFn =>
      'O‘lchangan aralashma va yuvish suyuqligi shu yerga oqadi.';

  @override
  String get schemPartsPhotometerReagentsName => 'Reagent idishlari';

  @override
  String get schemPartsPhotometerReagentsFn =>
      'Reagentlar apparatdan tashqarida; operator ularni namunaga qo‘lda qo‘shadi.';

  @override
  String get schemPartsPhotometerPrinciple =>
      'Operator namuna va reagentni qo‘lda pipetkalaydi va inkubatsiya qiladi. Apparat aralashmani igna bilan oqim kyuvetasiga so‘radi (yoki kvadrat kyuveta qo‘yiladi); lampa nuri tanlangan interferension filtrdan o‘tadi va fotodetektor yutilishni o‘lchaydi. Konsentratsiya standart yoki omil bo‘yicha hisoblanadi.';

  @override
  String get schemPartsPhotometerResult =>
      'Yutilish qiymati va undan hisoblangan konsentratsiya; natija displeyda ko‘rinadi va chop etiladi.';

  @override
  String get schemPartsHematology5AutoloaderName => 'Avtoyuklagich va raka';

  @override
  String get schemPartsHematology5AutoloaderFn =>
      'Yopiq probirkalarni aralashtirib, navbat bilan namuna olish joyiga uzatadi.';

  @override
  String get schemPartsHematology5ProbeName => 'Namuna zondi (ochiq rejim)';

  @override
  String get schemPartsHematology5ProbeFn =>
      'Qo‘lda tutilgan ochiq probirkadan belgilangan hajmdagi qonni so‘radi.';

  @override
  String get schemPartsHematology5ImpedanceName => 'Impedans kamerasi';

  @override
  String get schemPartsHematology5ImpedanceFn =>
      'Tor teshikdan o‘tgan har bir eritrotsit va trombotsit elektr impulsini beradi: sanash va hajm.';

  @override
  String get schemPartsHematology5LaserName => 'Lazerli oqim kyuvetasi';

  @override
  String get schemPartsHematology5LaserFn =>
      'Leykotsitlar birma-bir lazer nuridan o‘tadi va sochilish (hamda fluoressensiya) bo‘yicha turlarga ajratiladi.';

  @override
  String get schemPartsHematology5DisplayName => 'Displey (skatterogramma)';

  @override
  String get schemPartsHematology5DisplayFn =>
      'Natijalar, skatterogramma va gistogrammalarni ko‘rsatadi.';

  @override
  String get schemPartsHematology5ReagentsName => 'Reagentlar';

  @override
  String get schemPartsHematology5ReagentsFn =>
      'Suyultiruvchi, lizislovchi va bo‘yovchi eritmalar shlanglar orqali beriladi.';

  @override
  String get schemPartsHematology5WasteName => 'Chiqindi idishi';

  @override
  String get schemPartsHematology5WasteFn =>
      'Ishlatilgan suyultirmalar va yuvish eritmalari to‘planadi.';

  @override
  String get schemPartsHematology5Principle =>
      'Qon so‘riladi, suyultiriladi va bir nechta kanalga bo‘linadi. Eritrotsit va trombotsitlar impedans usulida sanaladi: hujayra tor teshikdan o‘tganda qarshilik impulsi hosil bo‘ladi, uning kattaligi hujayra hajmini bildiradi. Leykotsitlar differensiali oqim sitometriyasida lazer nurining sochilishi (ba’zi modellarda bo‘yoq fluoressensiyasi bilan) bo‘yicha aniqlanadi; gemoglobin eritrotsitlar lizisidan keyin fotometrik o‘lchanadi.';

  @override
  String get schemPartsHematology5Result =>
      'Umumiy qon tahlili (CBC) parametrlari: hujayralar soni va eritrotsit indekslari, leykotsitlarning 5 qismli differensiali, skatterogramma va gistogrammalar.';

  @override
  String get schemPartsHematology3PrinterName => 'Termoprinter';

  @override
  String get schemPartsHematology3PrinterFn =>
      'Natijalar va gistogrammalarni chop etadi.';

  @override
  String get schemPartsHematology3DisplayName => 'Displey (3 ta gistogramma)';

  @override
  String get schemPartsHematology3DisplayFn =>
      'Natijalar hamda WBC, RBC va PLT gistogrammalarini ko‘rsatadi (rasmdagi shakllar sxematik).';

  @override
  String get schemPartsHematology3ProbeName => 'Namuna zondi';

  @override
  String get schemPartsHematology3ProbeFn =>
      'Ochiq probirkadan oz hajmdagi qonni so‘radi.';

  @override
  String get schemPartsHematology3ImpedanceName => 'Impedans kamerasi';

  @override
  String get schemPartsHematology3ImpedanceFn =>
      'Hujayra teshikdan o‘tganda impuls hosil bo‘ladi: impulslar soni — hujayralar soni, kattaligi — hajmi.';

  @override
  String get schemPartsHematology3ReagentsName =>
      'Suyultiruvchi va lizislovchi eritma';

  @override
  String get schemPartsHematology3ReagentsFn =>
      'Qonni suyultirish va eritrotsitlarni eritish (lizis) uchun.';

  @override
  String get schemPartsHematology3WasteName => 'Chiqindi idishi';

  @override
  String get schemPartsHematology3WasteFn =>
      'Ishlatilgan suyuqliklar shu yerga to‘planadi.';

  @override
  String get schemPartsHematology3Principle =>
      'Qon suyultiriladi; eritrotsit va trombotsitlar impedans (Kulter) usulida sanaladi va hajm bo‘yicha gistogramma tuziladi. Leykotsitlar lizisdan keyin hajmi bo‘yicha uch guruhga ajratiladi; gemoglobin fotometrik o‘lchanadi.';

  @override
  String get schemPartsHematology3Result =>
      'CBC va leykotsitlarning 3 qismli differensiali (limfotsitlar, o‘rta hujayralar, granulotsitlar), uchta gistogramma (WBC, RBC, PLT).';

  @override
  String get schemPartsImmunoassaySamplesName => 'Namuna rakasi';

  @override
  String get schemPartsImmunoassaySamplesFn =>
      'Probirkalar shu yerga qo‘yiladi; zond namunani oladi.';

  @override
  String get schemPartsImmunoassayReagentsName =>
      'Sovutilgan reagent paketlari';

  @override
  String get schemPartsImmunoassayReagentsFn =>
      'Mikrozarrachalar, belgili konjugat va boshqa reagentlar sovuqda saqlanadi.';

  @override
  String get schemPartsImmunoassayProbesName => 'Pipetkalovchi zondlar';

  @override
  String get schemPartsImmunoassayProbesFn =>
      'Namuna va reagentlarni reaksiya kyuvetasiga quyadi.';

  @override
  String get schemPartsImmunoassayCuvettesName => 'Kyuveta bunkeri';

  @override
  String get schemPartsImmunoassayCuvettesFn =>
      'Bir martalik reaksiya kyuvetalarini inkubatorga uzatadi.';

  @override
  String get schemPartsImmunoassayIncubatorName => 'Inkubator halqasi';

  @override
  String get schemPartsImmunoassayIncubatorFn =>
      'Kyuvetalar doimiy haroratda ushlanadi, antigen–antitana reaksiyasi boradi.';

  @override
  String get schemPartsImmunoassayWashName =>
      'Yuvish stansiyasi (magnit ajratish)';

  @override
  String get schemPartsImmunoassayWashFn =>
      'Magnit mikrozarrachalarni ushlab turadi, bog‘lanmagan moddalar yuvib tashlanadi.';

  @override
  String get schemPartsImmunoassayLuminometerName => 'Luminometr (detektor)';

  @override
  String get schemPartsImmunoassayLuminometerFn =>
      'Belgi chiqargan yorug‘likni fotonlarni sanash orqali o‘lchaydi.';

  @override
  String get schemPartsImmunoassaySolidwasteName => 'Qattiq chiqindi tortmasi';

  @override
  String get schemPartsImmunoassaySolidwasteFn =>
      'Ishlatilgan kyuvetalar va uchliklar yig‘iladi.';

  @override
  String get schemPartsImmunoassayLiquidsName => 'Tizim eritmalari';

  @override
  String get schemPartsImmunoassayLiquidsFn =>
      'Yuvish va tizim eritmalari idishlari.';

  @override
  String get schemPartsImmunoassayPrinciple =>
      'Namuna reagent bilan kyuvetada inkubatsiya qilinadi: analit magnit mikrozarrachalardagi antitana yoki antigen bilan bog‘lanadi. Magnit zarrachalarni ushlab turganda bog‘lanmagan moddalar yuviladi; so‘ng belgi (ferment, akridiniy efiri yoki ECL belgisi) yorug‘lik chiqaradi. Luminometr fotonlarni sanaydi, signal kalibrlash egri chizig‘i bo‘yicha konsentratsiyaga aylantiriladi.';

  @override
  String get schemPartsImmunoassayResult =>
      'Gormonlar, o‘sma va yurak markerlari kabi analitlar konsentratsiyasi yoki sifatiy natija (musbat/manfiy), yorug‘lik signalidan kalibrlash bo‘yicha hisoblangan.';

  @override
  String get schemPartsUrineStripSampleName => 'Siydik namunasi va test-chiziq';

  @override
  String get schemPartsUrineStripSampleFn =>
      'Chiziq siydikka qisqa botiriladi; maydonchalar reaksiyaga kirishadi.';

  @override
  String get schemPartsUrineStripTrayName => 'Chiziq lotogi (uzatgich)';

  @override
  String get schemPartsUrineStripTrayFn =>
      'Chiziq shu yerga qo‘yiladi va o‘qish kallagi ostiga suriladi.';

  @override
  String get schemPartsUrineStripHeadName =>
      'O‘qish kallagi (LED va fotosensor)';

  @override
  String get schemPartsUrineStripHeadFn =>
      'Maydonchalarni bir necha to‘lqin uzunlikdagi nur bilan yoritadi va qaytgan nurni o‘lchaydi.';

  @override
  String get schemPartsUrineStripDisplayName => 'Displey';

  @override
  String get schemPartsUrineStripDisplayFn =>
      'Natijalar va apparat holatini ko‘rsatadi.';

  @override
  String get schemPartsUrineStripPrinterName => 'Printer';

  @override
  String get schemPartsUrineStripPrinterFn => 'Natijalarni chop etadi.';

  @override
  String get schemPartsUrineStripBinName => 'Ishlatilgan chiziqlar qutisi';

  @override
  String get schemPartsUrineStripBinFn =>
      'O‘qilgan chiziqlar shu yerga tushadi.';

  @override
  String get schemPartsUrineStripPrinciple =>
      'Test-chiziq siydikka botiriladi; har maydonchadagi reagent o‘z moddasi bilan rang beradi. Apparat chiziqni o‘qish kallagi ostidan o‘tkazadi: turli to‘lqin uzunlikdagi LEDlar maydonchalarni yoritadi, fotosensor qaytgan nurni o‘lchaydi (reflektometriya). Rang intensivligi yarim miqdoriy darajaga aylantiriladi.';

  @override
  String get schemPartsUrineStripResult =>
      'Har maydoncha bo‘yicha sifatiy yoki yarim miqdoriy natija (masalan, glyukoza, oqsil, qon, leykotsitlar, nitrit, pH, nisbiy zichlik) va bosma hisobot.';

  @override
  String get schemPartsUrineSystemTransportName => 'Namuna transport yo‘li';

  @override
  String get schemPartsUrineSystemTransportFn =>
      'Probirkali rakalarni modullar oldidan navbat bilan o‘tkazadi.';

  @override
  String get schemPartsUrineSystemStripName => 'Kimyoviy modul (test-chiziq)';

  @override
  String get schemPartsUrineSystemStripFn =>
      'Chiziq maydonchalarini reflektometriya va tasvir orqali o‘qiydi.';

  @override
  String get schemPartsUrineSystemNeedlesName => 'Namuna ignalari';

  @override
  String get schemPartsUrineSystemNeedlesFn =>
      'Har modul probirkadan o‘z ignasi bilan namuna oladi.';

  @override
  String get schemPartsUrineSystemCameraName =>
      'Cho‘kma moduli (mikroskop va kamera)';

  @override
  String get schemPartsUrineSystemCameraFn =>
      'Siydik zarrachalarining raqamli mikroskopik tasvirlarini oladi.';

  @override
  String get schemPartsUrineSystemDisplayName =>
      'Displey (zarracha tasvirlari)';

  @override
  String get schemPartsUrineSystemDisplayFn =>
      'Tasniflangan zarracha tasvirlari va natijalar ko‘rib chiqiladi.';

  @override
  String get schemPartsUrineSystemReagentsName => 'Reagent va yuvish eritmasi';

  @override
  String get schemPartsUrineSystemReagentsFn =>
      'Modullarni yuvish va o‘lchash uchun eritmalar.';

  @override
  String get schemPartsUrineSystemWasteName => 'Chiqindi idishi';

  @override
  String get schemPartsUrineSystemWasteFn =>
      'Ishlatilgan suyuqliklar to‘planadi.';

  @override
  String get schemPartsUrineSystemPrinciple =>
      'Namuna rakalari transport yo‘li bo‘ylab ikki modulga boradi. Kimyoviy modul test-chiziq maydonchalarini reflektometriya bilan o‘qiydi. Cho‘kma moduli siydikni mikroskop orqali raqamli suratga oladi; dastur zarrachalarni (eritrotsit, leykotsit, silindr, kristall va boshqalar) tasniflaydi, tasvirlarni ekranda ko‘rib chiqish mumkin.';

  @override
  String get schemPartsUrineSystemResult =>
      'Chiziq kimyosi natijalari va cho‘kma elementlari (eritrotsit, leykotsit, silindr, kristall, bakteriya va boshq.) soni yoki kategoriyasi, ko‘rib chiqish uchun tasvirlar bilan.';

  @override
  String get schemPartsMassSpecGcGasName => 'Tashuvchi gaz ballon';

  @override
  String get schemPartsMassSpecGcGasFn =>
      'Inert gaz (odatda geliy) namunani kolonka bo‘ylab olib yuradi.';

  @override
  String get schemPartsMassSpecGcAutosamplerName => 'Avtonamunaoluvchi';

  @override
  String get schemPartsMassSpecGcAutosamplerFn =>
      'Flakondan namunani shpris bilan olib, injektorga kiritadi.';

  @override
  String get schemPartsMassSpecGcInjectorName => 'Injektor (bug‘lantirgich)';

  @override
  String get schemPartsMassSpecGcInjectorFn =>
      'Qizdirilgan kirish joyi: suyuq namuna bug‘lanib, gaz oqimiga qo‘shiladi.';

  @override
  String get schemPartsMassSpecGcColumnName => 'Termostat va kapillyar kolonka';

  @override
  String get schemPartsMassSpecGcColumnFn =>
      'Harorat dasturi bo‘yicha qizdiriladi; moddalar kolonkada ajraladi.';

  @override
  String get schemPartsMassSpecGcTransferName => 'Issiq uzatish liniyasi';

  @override
  String get schemPartsMassSpecGcTransferFn =>
      'Ajralgan moddalarni kondensatsiyasiz mass-spektrometrga o‘tkazadi.';

  @override
  String get schemPartsMassSpecGcSourceName => 'Ion manbai';

  @override
  String get schemPartsMassSpecGcSourceFn =>
      'Molekulalarni ionlaydi (GC-MS da ko‘pincha elektron zarbasi bilan), ionlar bo‘laklarga ajraladi.';

  @override
  String get schemPartsMassSpecGcAnalyserName => 'Mass-analizator (kvadrupol)';

  @override
  String get schemPartsMassSpecGcAnalyserFn =>
      'Elektr maydoni ionlarni m/z bo‘yicha ajratadi va navbat bilan o‘tkazadi.';

  @override
  String get schemPartsMassSpecGcDetectorName =>
      'Detektor (elektron ko‘paytirgich)';

  @override
  String get schemPartsMassSpecGcDetectorFn =>
      'Kelgan ionlarni kuchaytirilgan elektr signaliga aylantiradi.';

  @override
  String get schemPartsMassSpecGcVacuumName => 'Vakuum nasoslari';

  @override
  String get schemPartsMassSpecGcVacuumFn =>
      'Turbomolekulyar va forvakuum nasoslari yuqori vakuum hosil qiladi — ionlarning havo molekulalari bilan to‘qnashuvi kamayadi.';

  @override
  String get schemPartsMassSpecGcDataName => 'Ma’lumotlar tizimi';

  @override
  String get schemPartsMassSpecGcDataFn =>
      'Xromatogramma va spektrlarni yozadi, kutubxona bilan solishtiradi.';

  @override
  String get schemPartsMassSpecGcPrinciple =>
      'Namuna injektorda bug‘lanadi, tashuvchi gaz (odatda geliy) uni termostatdagi kapillyar kolonkaga olib kiradi. Moddalar uchuvchanligi va kolonka bilan o‘zaro ta’siriga ko‘ra turli vaqtda chiqadi (ushlanish vaqti). Mass-spektrometrda ular ionlanadi, ionlar massa/zaryad nisbati (m/z) bo‘yicha ajratiladi va detektor qayd etadi.';

  @override
  String get schemPartsMassSpecGcResult =>
      'Xromatogramma (signal — ushlanish vaqti bo‘yicha) va har cho‘qqining mass-spektri (m/z — nisbiy intensivlik); moddalar spektrlar kutubxonasi yoki standartlar bilan solishtirib aniqlanadi.';

  @override
  String get schemPartsMassSpecLcSolventsName =>
      'Harakatlanuvchi faza idishlari';

  @override
  String get schemPartsMassSpecLcSolventsFn =>
      'Erituvchilar (masalan, suv va organik erituvchi) nasosga beriladi.';

  @override
  String get schemPartsMassSpecLcPumpName => 'Yuqori bosimli nasos';

  @override
  String get schemPartsMassSpecLcPumpFn =>
      'Erituvchilarni barqaror oqim bilan kolonka orqali haydaydi.';

  @override
  String get schemPartsMassSpecLcAutosamplerName => 'Avtonamunaoluvchi';

  @override
  String get schemPartsMassSpecLcAutosamplerFn =>
      'Flakondan namunani olib, oqimga kiritadi.';

  @override
  String get schemPartsMassSpecLcColumnName => 'Kolonka (termostatda)';

  @override
  String get schemPartsMassSpecLcColumnFn =>
      'Moddalar kolonka fazasi bilan o‘zaro ta’siriga ko‘ra ajraladi.';

  @override
  String get schemPartsMassSpecLcEsiName => 'Elektropurkash ion manbai (ESI)';

  @override
  String get schemPartsMassSpecLcEsiFn =>
      'Kolonkadan chiqqan suyuqlikni zaryadlangan tomchilarga purkab, ionlar hosil qiladi.';

  @override
  String get schemPartsMassSpecLcAnalyserName => 'Mass-analizator (kvadrupol)';

  @override
  String get schemPartsMassSpecLcAnalyserFn =>
      'Elektr maydoni ionlarni m/z bo‘yicha ajratadi va navbat bilan o‘tkazadi.';

  @override
  String get schemPartsMassSpecLcDetectorName =>
      'Detektor (elektron ko‘paytirgich)';

  @override
  String get schemPartsMassSpecLcDetectorFn =>
      'Kelgan ionlarni kuchaytirilgan elektr signaliga aylantiradi.';

  @override
  String get schemPartsMassSpecLcVacuumName => 'Vakuum nasoslari';

  @override
  String get schemPartsMassSpecLcVacuumFn =>
      'Mass-analizator ichida yuqori vakuumni saqlaydi.';

  @override
  String get schemPartsMassSpecLcDataName => 'Ma’lumotlar tizimi';

  @override
  String get schemPartsMassSpecLcDataFn =>
      'Xromatogramma va spektrlarni yozadi, miqdorni hisoblaydi.';

  @override
  String get schemPartsMassSpecLcPrinciple =>
      'Nasos suyuq harakatlanuvchi fazani yuqori bosimda kolonka orqali haydaydi, avtonamunaoluvchi namunani oqimga kiritadi. Moddalar kolonkada ajralib, turli vaqtda chiqadi. Elektropurkash (ESI) manbaida suyuqlik zaryadlangan tomchilarga purkaladi va moddalar gaz fazasidagi ionlarga aylanadi; ionlar m/z bo‘yicha ajratiladi va detektor qayd etadi.';

  @override
  String get schemPartsMassSpecLcResult =>
      'Xromatogramma va mass-spektrlar; maqsadli moddalar (dori vositalari, metabolitlar, biomarkerlar) aniqlanadi va kalibratorlar bo‘yicha konsentratsiyasi hisoblanadi.';

  @override
  String get schemPartsMaldiTofTargetName => 'Nishon plastina';

  @override
  String get schemPartsMaldiTofTargetFn =>
      'Namuna va matritsa dog‘lari shu yerda; plastina vakuum kamerasiga kiritiladi.';

  @override
  String get schemPartsMaldiTofLaserName => 'Lazer';

  @override
  String get schemPartsMaldiTofLaserFn =>
      'Qisqa impuls matritsa bilan birga oqsillarni bug‘latadi va ionlaydi.';

  @override
  String get schemPartsMaldiTofGridsName => 'Tezlatuvchi elektrodlar';

  @override
  String get schemPartsMaldiTofGridsFn =>
      'Yuqori kuchlanish ionlarni tezlatib, uchish trubasiga yo‘naltiradi.';

  @override
  String get schemPartsMaldiTofTubeName => 'Uchish trubasi (TOF)';

  @override
  String get schemPartsMaldiTofTubeFn =>
      'Vakuumdagi truba: ionlar m/z ga ko‘ra turli tezlikda uchadi.';

  @override
  String get schemPartsMaldiTofDetectorName => 'Detektor';

  @override
  String get schemPartsMaldiTofDetectorFn =>
      'Har ionning yetib kelish vaqtini qayd etadi.';

  @override
  String get schemPartsMaldiTofVacuumName => 'Vakuum nasosi';

  @override
  String get schemPartsMaldiTofVacuumFn =>
      'Ion manbai va trubada vakuum hosil qiladi.';

  @override
  String get schemPartsMaldiTofDatabaseName => 'Kompyuter va spektrlar bazasi';

  @override
  String get schemPartsMaldiTofDatabaseFn =>
      'Spektrni etalon spektrlar bilan solishtirib, ehtimollik bahosini beradi.';

  @override
  String get schemPartsMaldiTofPrinciple =>
      'Koloniya plastinaga surtiladi va matritsa bilan qoplanib kristallanadi. Lazer impulsi oqsillarni (asosan ribosomal) bug‘latadi va ionlaydi. Elektr maydoni ionlarni tezlatadi; uchish trubasida yengil ionlar og‘irlaridan oldin detektorga yetadi — uchish vaqti m/z ni bildiradi. Spektr ma’lumotlar bazasidagi etalon spektrlar bilan solishtiriladi.';

  @override
  String get schemPartsMaldiTofResult =>
      'Mass-spektr (oqsil «barmoq izi») va mikroorganizm nomi ehtimollik bahosi (log-ball) bilan; natija boshqa klinik va laboratoriya ma’lumotlari bilan birga talqin qilinadi.';

  @override
  String get schemPartsMicrobialIdAstCardName => 'Test kartasi (64 quduqcha)';

  @override
  String get schemPartsMicrobialIdAstCardFn =>
      'Quduqchalarda antibiotiklar suyultirmalari (AST) yoki biokimyoviy substratlar (ID) bor.';

  @override
  String get schemPartsMicrobialIdAstSuspensionName => 'Suspenziya probirkasi';

  @override
  String get schemPartsMicrobialIdAstSuspensionFn =>
      'Standart zichlikdagi bakterial suspenziya; karta somoni shu probirkaga botiriladi.';

  @override
  String get schemPartsMicrobialIdAstFillingName => 'To‘ldirish kamerasi';

  @override
  String get schemPartsMicrobialIdAstFillingFn =>
      'Vakuum suspenziyani somon orqali karta quduqchalariga tortadi.';

  @override
  String get schemPartsMicrobialIdAstIncubatorName => 'Inkubator';

  @override
  String get schemPartsMicrobialIdAstIncubatorFn =>
      'Kartalar o‘qishlar orasida doimiy haroratda saqlanadi.';

  @override
  String get schemPartsMicrobialIdAstScannerName => 'Optik skaner';

  @override
  String get schemPartsMicrobialIdAstScannerFn =>
      'Har 15 daqiqada har quduqchadan o‘tgan nurni o‘lchaydi.';

  @override
  String get schemPartsMicrobialIdAstSoftwareName => 'Kompyuter va dastur';

  @override
  String get schemPartsMicrobialIdAstSoftwareFn =>
      'O‘sish egri chiziqlaridan MIK va talqin kategoriyasini hisoblab, hisobot beradi.';

  @override
  String get schemPartsMicrobialIdAstPrinciple =>
      'Toza kulturadan standart zichlikdagi suspenziya tayyorlanadi va karta somoni orqali vakuumda kartaga to‘ldiriladi. AST kartasi quduqchalarida antibiotiklar turli suyultirmalarda bo‘ladi (MIK usulining kichiklashtirilgan avtomatik shakli). Optik skaner har 15 daqiqada quduqchalardan o‘tgan nurni o‘lchaydi: o‘sish nurni susaytiradi; dastur o‘sish dinamikasidan MIKni hisoblaydi.';

  @override
  String get schemPartsMicrobialIdAstResult =>
      'Har antibiotik uchun MIK qiymati va talqin kategoriyasi (masalan, sezuvchan yoki chidamli); identifikatsiya kartasida — mikroorganizm turi.';

  @override
  String get schemPartsBloodCultureVialsName => 'Gemokultura flakonlari';

  @override
  String get schemPartsBloodCultureVialsFn =>
      'Aerob va anaerob ozuqa muhitli flakonlar; ichiga bemor qoni solinadi.';

  @override
  String get schemPartsBloodCultureSensorName => 'CO₂ sensori (flakon tubida)';

  @override
  String get schemPartsBloodCultureSensorFn =>
      'Bo‘yoq CO₂ bilan reaksiyaga kirib, fluoressensiyasini o‘zgartiradi.';

  @override
  String get schemPartsBloodCultureIncubatorName => 'Inkubator shkafi';

  @override
  String get schemPartsBloodCultureIncubatorFn =>
      'Flakonlar uyachalarda doimiy haroratda saqlanadi.';

  @override
  String get schemPartsBloodCultureReaderName => 'O‘qish tizimi';

  @override
  String get schemPartsBloodCultureReaderFn =>
      'Har uyacha ostidagi nur manbai va detektor sensorni har o‘n daqiqada o‘lchaydi.';

  @override
  String get schemPartsBloodCulturePositiveName => 'Musbat flakon chirog‘i';

  @override
  String get schemPartsBloodCulturePositiveFn =>
      'O‘sish aniqlangan flakonni ko‘rsatadi.';

  @override
  String get schemPartsBloodCultureSoftwareName => 'Kompyuter va dastur';

  @override
  String get schemPartsBloodCultureSoftwareFn =>
      'Har flakonning o‘sish egri chizig‘i va holatini ko‘rsatadi.';

  @override
  String get schemPartsBloodCulturePrinciple =>
      'Qon solingan flakonlar inkubatorga qo‘yiladi. Mikroorganizmlar o‘sganda CO₂ ajraladi; flakon tubidagi sensor bo‘yog‘i CO₂ bilan reaksiyaga kirib, fluoressensiyani oshiradi. Apparat sensorni har o‘n daqiqada o‘qiydi; algoritm CO₂ hosil bo‘lish tezligi va umumiy ortishiga qarab flakonni musbat deb belgilaydi.';

  @override
  String get schemPartsBloodCultureResult =>
      'Har flakon holati: musbat (o‘sish aniqlandi) yoki protokol oxirida manfiy, musbatlikkacha vaqt va o‘sish egri chizig‘i. Musbat flakon keyingi mikrobiologik tekshiruvga yuboriladi.';

  @override
  String get schemPartsMycobacterialCultureTubeName => 'MGIT probirkasi';

  @override
  String get schemPartsMycobacterialCultureTubeFn =>
      'Suyuq 7H9 muhiti va o‘sish qo‘shimchasi (OADC) bilan; namuna shu yerga ekiladi.';

  @override
  String get schemPartsMycobacterialCultureSensorName =>
      'Fluoressent kislorod sensori';

  @override
  String get schemPartsMycobacterialCultureSensorFn =>
      'Kislorod kamayganda UB nurida yorqin fluoressensiya beradi.';

  @override
  String get schemPartsMycobacterialCultureDrawerName =>
      'Probirka tortmasi (inkubatsiya va o‘qish)';

  @override
  String get schemPartsMycobacterialCultureDrawerFn =>
      'Har uyachada probirka inkubatsiya qilinadi va fluoressensiyasi muntazam o‘lchanadi.';

  @override
  String get schemPartsMycobacterialCultureLightsName => 'Holat chiroqlari';

  @override
  String get schemPartsMycobacterialCultureLightsFn =>
      'Musbat yoki tugallangan probirkalarni ko‘rsatadi.';

  @override
  String get schemPartsMycobacterialCulturePanelName => 'Apparat displeyi';

  @override
  String get schemPartsMycobacterialCulturePanelFn =>
      'Tortmalar holati va ogohlantirishlarni ko‘rsatadi.';

  @override
  String get schemPartsMycobacterialCultureSoftwareName =>
      'Kompyuter (GU egri chiziqlari)';

  @override
  String get schemPartsMycobacterialCultureSoftwareFn =>
      'O‘sish va DST natijalarini yozadi; nazorat va dorili probirkalar egri chiziqlari solishtiriladi.';

  @override
  String get schemPartsMycobacterialCulturePrinciple =>
      'MGIT probirkasida o‘zgartirilgan Middlebrook 7H9 suyuq muhiti va tubida kislorodga sezgir fluoressent sensor bor. Mikobakteriyalar o‘sganda erigan kislorod sarflanadi va sensor UB nurida yorqinroq fluoressensiya beradi. Apparat har probirkani avtomatik o‘qiydi va intensivlikni o‘sish birliklari (GU) sifatida yozadi. DSTda dorili probirka GU qiymati nazorat probirkasiniki bilan solishtiriladi.';

  @override
  String get schemPartsMycobacterialCultureResult =>
      'Musbat yoki manfiy kultura va GU egri chizig‘i; DSTda birinchi qator preparatlari uchun apparat sezuvchan/chidamli talqinini beradi, ikkinchi qator uchun GU qiymatlarini foydalanuvchi talqin qiladi.';

  @override
  String get schemPartsFlowCytometerSheathName => 'Qobiq suyuqligi idishi';

  @override
  String get schemPartsFlowCytometerSheathFn =>
      'Namuna oqimini o‘rab, uni ingichka markaziy oqimga siqadi.';

  @override
  String get schemPartsFlowCytometerSampleName => 'Namuna probirkasi va zond';

  @override
  String get schemPartsFlowCytometerSampleFn =>
      'Bo‘yalgan hujayra suspenziyasi shu yerdan so‘riladi.';

  @override
  String get schemPartsFlowCytometerFlowcellName =>
      'Oqim kyuvetasi (gidrodinamik fokuslash)';

  @override
  String get schemPartsFlowCytometerFlowcellFn =>
      'Hujayralar birma-bir lazer nuri kesib o‘tgan nuqtadan o‘tadi.';

  @override
  String get schemPartsFlowCytometerLaserName => 'Lazer';

  @override
  String get schemPartsFlowCytometerLaserFn =>
      'Hujayralarni yoritadi va floroxromlarni qo‘zg‘atadi.';

  @override
  String get schemPartsFlowCytometerFscName =>
      'To‘g‘ri sochilish (FSC) detektori';

  @override
  String get schemPartsFlowCytometerFscFn =>
      'Nur yo‘nalishidagi sochilishni o‘lchaydi — u hujayra o‘lchamiga bog‘liq.';

  @override
  String get schemPartsFlowCytometerSscName =>
      'Yon sochilish va fluoressensiya detektorlari';

  @override
  String get schemPartsFlowCytometerSscFn =>
      'Nurga yon tomondan yig‘ilgan yorug‘lik dixroik ko‘zgu va filtrlar bilan ranglarga ajratilib, alohida detektorlarga tushadi.';

  @override
  String get schemPartsFlowCytometerWasteName => 'Chiqindi idishi';

  @override
  String get schemPartsFlowCytometerWasteFn =>
      'O‘lchangan namuna va qobiq suyuqligi to‘planadi.';

  @override
  String get schemPartsFlowCytometerComputerName =>
      'Kompyuter (nuqtali diagrammalar)';

  @override
  String get schemPartsFlowCytometerComputerFn =>
      'Signallardan nuqtali diagramma tuzadi; populyatsiyalar darvoza (gating) bilan ajratiladi.';

  @override
  String get schemPartsFlowCytometerPrinciple =>
      'Hujayralar odatda floroxrom bilan belgilangan antitanalar bilan bo‘yaladi. Qobiq suyuqligi namuna oqimini gidrodinamik fokuslab, hujayralarni bir qatorga tizadi; har hujayra lazer nuridan o‘tadi. To‘g‘ri sochilish (FSC) hujayra o‘lchamini, yon sochilish (SSC) ichki tuzilishini, fluoressensiya esa belgilarni bildiradi; elektronika signallarni raqamlashtiradi.';

  @override
  String get schemPartsFlowCytometerResult =>
      'Nuqtali diagramma va gistogrammalar; hujayra populyatsiyalarining ulushi va soni (masalan, kalibrlovchi zarrachalar yordamida CD4+ T-hujayralarning absolyut soni).';

  @override
  String get schemPartsRealTimePcrTubesName => 'PCR probirkalari (qator)';

  @override
  String get schemPartsRealTimePcrTubesFn =>
      'Reaksiya aralashmasi va namuna; shaffof qopqoq orqali o‘qiladi.';

  @override
  String get schemPartsRealTimePcrLidName => 'Isitiladigan qopqoq';

  @override
  String get schemPartsRealTimePcrLidFn =>
      'Probirka qopqoqlarida bug\' to‘planishining oldini oladi.';

  @override
  String get schemPartsRealTimePcrBlockName => 'Termoblok (Peltye)';

  @override
  String get schemPartsRealTimePcrBlockFn =>
      'Denaturatsiya, praymer birikishi va sintez haroratlarini tez almashtiradi.';

  @override
  String get schemPartsRealTimePcrSourceName => 'Qo‘zg‘atuvchi nur manbai';

  @override
  String get schemPartsRealTimePcrSourceFn =>
      'Bo‘yoq yoki zondni qo‘zg‘atadigan nur beradi.';

  @override
  String get schemPartsRealTimePcrExfilterName =>
      'Qo‘zg‘atish filtri (kanal tanlash)';

  @override
  String get schemPartsRealTimePcrExfilterFn =>
      'Har bir bo‘yoq kanali uchun kerakli qo‘zg‘atuvchi nurni ajratadi.';

  @override
  String get schemPartsRealTimePcrTubeName =>
      'Termoblokdagi reaksiya probirkasi';

  @override
  String get schemPartsRealTimePcrTubeFn =>
      'Qo‘zg‘atuvchi nur probirkadagi bo‘yoq yoki zondga tushadi; u amplikon miqdoriga mutanosib fluoressensiya chiqaradi.';

  @override
  String get schemPartsRealTimePcrEmfilterName => 'Nurlanish filtri';

  @override
  String get schemPartsRealTimePcrEmfilterFn =>
      'Faqat bo‘yoq chiqargan fluoressent nurni o‘tkazadi, qo‘zg‘atuvchi nurni to‘sadi.';

  @override
  String get schemPartsRealTimePcrDetectorName => 'Detektor';

  @override
  String get schemPartsRealTimePcrDetectorFn =>
      'Probirkalardan kelgan fluoressensiyani har siklda o‘lchaydi.';

  @override
  String get schemPartsRealTimePcrSoftwareName =>
      'Dastur (kuchayish egri chiziqlari)';

  @override
  String get schemPartsRealTimePcrSoftwareFn =>
      'Egri chiziqlar, chegara chizig‘i va Cq qiymatlarini hisoblaydi.';

  @override
  String get schemPartsRealTimePcrPrinciple =>
      'Termoblok har siklda haroratni almashtiradi: qizdirish DNK zanjirlarini ajratadi, sovutishda praymerlar birikadi, issiqqa chidamli polimeraza yangi zanjir quradi — nishon har siklda taxminan ikki barobar ko‘payadi (RNK avval teskari transkriptaza bilan kDNK ga aylantiriladi). Optik modul har siklda interkalyatsiyalanuvchi bo‘yoq yoki zond fluoressensiyasini o‘lchaydi; signal amplikon to‘planishiga mutanosib.';

  @override
  String get schemPartsRealTimePcrResult =>
      'Kuchayish egri chiziqlari va har namuna uchun Cq (Ct) — fluoressensiya chegarani kesib o‘tgan sikl; Cq qancha past bo‘lsa, boshlang‘ich nishon shuncha ko‘p. Miqdoriy testlarda konsentratsiya standartlar bo‘yicha hisoblanadi (masalan, OIV-1 virus yuklamasi, nusxa/ml).';

  @override
  String get schemPartsCartridgeMolecularCartridgeName =>
      'Bir martalik kartrij';

  @override
  String get schemPartsCartridgeMolecularCartridgeFn =>
      'Namuna va reagent kameralari bor yopiq kartrij; barcha bosqichlar ichida bajariladi.';

  @override
  String get schemPartsCartridgeMolecularTubeName => 'Reaksiya naychasi';

  @override
  String get schemPartsCartridgeMolecularTubeFn =>
      'Kartrijning shu qismida amplifikatsiya va fluoressent detektsiya bo‘ladi.';

  @override
  String get schemPartsCartridgeMolecularSpecimenName => 'Namuna idishi';

  @override
  String get schemPartsCartridgeMolecularSpecimenFn =>
      'Balg‘am kabi namuna yig‘iladi va reagent bilan aralashtiriladi.';

  @override
  String get schemPartsCartridgeMolecularModuleName => 'Apparat moduli';

  @override
  String get schemPartsCartridgeMolecularModuleFn =>
      'Kartrij shu yerga qo‘yiladi va avtomatik ishlanadi; modullar bir-biridan mustaqil.';

  @override
  String get schemPartsCartridgeMolecularSoftwareName => 'Kompyuter va dastur';

  @override
  String get schemPartsCartridgeMolecularSoftwareFn =>
      'Jarayonni boshqaradi va talqin qilingan natijani beradi.';

  @override
  String get schemPartsCartridgeMolecularPrinciple =>
      'Namuna reagent bilan aralashtirilib kartrijga quyiladi, kartrij modulga qo‘yiladi. Keyingi bosqichlar yopiq kartrij ichida avtomatik: namunani qayta ishlash, nuklein kislotani ajratish, amplifikatsiya (real vaqt PCR) va detektsiya. Operator kartrijni ochmaydi, bu amplikon bilan ifloslanish xavfini kamaytiradi.';

  @override
  String get schemPartsCartridgeMolecularResult =>
      'Xpert MTB/RIF uchun: M. tuberculosis kompleksi aniqlandi yoki aniqlanmadi, rifampitsinga chidamlilik aniqlandi yoki aniqlanmadi — 2 soatdan kam vaqtda.';

  @override
  String get schemPartsCoagAnalyzerSamplesName => 'Sitratli probirkalar rakasi';

  @override
  String get schemPartsCoagAnalyzerSamplesFn =>
      'Havorang qopqoqli natriy sitratli probirkalar; plazma shu yerdan olinadi.';

  @override
  String get schemPartsCoagAnalyzerReagentsName => 'Sovutilgan reagent bloki';

  @override
  String get schemPartsCoagAnalyzerReagentsFn =>
      'Tromboplastin va boshqa reagentlar sovuqda saqlanadi.';

  @override
  String get schemPartsCoagAnalyzerArmName => 'Pipetkalovchi qo‘l';

  @override
  String get schemPartsCoagAnalyzerArmFn =>
      'Plazma va reagentni kyuvetaga aniq hajmda quyadi.';

  @override
  String get schemPartsCoagAnalyzerCuvettesName => 'O‘lchash kyuvetalari';

  @override
  String get schemPartsCoagAnalyzerCuvettesFn =>
      'Plazma isitiladi; reagent qo‘shilgach laxta hosil bo‘lishi kuzatiladi.';

  @override
  String get schemPartsCoagAnalyzerLightName => 'Yorug‘lik manbai';

  @override
  String get schemPartsCoagAnalyzerLightFn =>
      'Kyuvetadan o‘tadigan nur beradi.';

  @override
  String get schemPartsCoagAnalyzerDetectorName => 'Fotodetektor';

  @override
  String get schemPartsCoagAnalyzerDetectorFn =>
      'Laxta hosil bo‘lganda o‘tgan nur o‘zgarishini qayd etadi.';

  @override
  String get schemPartsCoagAnalyzerDisplayName =>
      'Displey (ivish egri chizig‘i)';

  @override
  String get schemPartsCoagAnalyzerDisplayFn =>
      'Ivish egri chizig‘i, vaqt va hisoblangan INR.';

  @override
  String get schemPartsCoagAnalyzerPrinciple =>
      'Zond sitratli plazmani kyuvetaga quyadi va isitadi, so‘ng reagent qo‘shiladi (PT uchun tromboplastin: to‘qima omili, kalsiy va fosfolipidlar). Fibrin laxtasi hosil bo‘lganda aralashma loyqalanadi: optik usulda o‘tgan nur o‘zgarishi, mexanik usulda esa harakatning to‘xtashi qayd etiladi. Shu paytgacha o‘tgan vaqt — ivish vaqti.';

  @override
  String get schemPartsCoagAnalyzerResult =>
      'Ivish vaqti soniyalarda va ivish egri chizig‘i; PT uchun INR bemor PT, o‘rtacha normal PT va reagentning ISI qiymati bo‘yicha hisoblanadi.';

  @override
  String get schemPartsElisaReaderPlateName => '96 quduqchali mikroplanshet';

  @override
  String get schemPartsElisaReaderPlateFn =>
      'Reaksiya va rang quduqchalarda; tashuvchi planshetni o‘quvchiga olib kiradi.';

  @override
  String get schemPartsElisaReaderLampName => 'Yorug‘lik manbai (lampa)';

  @override
  String get schemPartsElisaReaderLampFn =>
      'Quduqchadan o‘tadigan nurni beradi.';

  @override
  String get schemPartsElisaReaderFilterName => 'Optik filtr';

  @override
  String get schemPartsElisaReaderFilterFn =>
      'Faqat kerakli to‘lqin uzunligini o‘tkazadi.';

  @override
  String get schemPartsElisaReaderWellName => 'O‘lchanayotgan quduqcha';

  @override
  String get schemPartsElisaReaderWellFn =>
      'Rangli eritma nurning bir qismini yutadi.';

  @override
  String get schemPartsElisaReaderDetectorName => 'Fotodetektor';

  @override
  String get schemPartsElisaReaderDetectorFn =>
      'O‘tgan nurni o‘lchaydi; undan yutilish hisoblanadi.';

  @override
  String get schemPartsElisaReaderWasherName => 'Yuvish qurilmasi ignalari';

  @override
  String get schemPartsElisaReaderWasherFn =>
      'Quduqchalarga yuvish eritmasini quyadi va so‘rib oladi.';

  @override
  String get schemPartsElisaReaderBufferName => 'Yuvish eritmasi idishi';

  @override
  String get schemPartsElisaReaderBufferFn =>
      'Yuvish qurilmasiga bufer beradi.';

  @override
  String get schemPartsElisaReaderWasteName => 'Chiqindi idishi';

  @override
  String get schemPartsElisaReaderWasteFn => 'So‘rilgan suyuqlik to‘planadi.';

  @override
  String get schemPartsElisaReaderPrinciple =>
      'Planshet quduqchalarida antigen–antitana reaksiyasi bosqichma-bosqich boradi; bosqichlar orasida yuvish qurilmasi bog‘lanmagan moddalarni yuvib tashlaydi. Oxirida substrat qo‘shiladi va ferment rang hosil qiladi. O‘quvchi har quduqchadan tanlangan to‘lqin uzunlikdagi nurni o‘tkazib, yutilishni (optik zichlik) o‘lchaydi; noma’lum namunalar standart egri chiziq bo‘yicha hisoblanadi.';

  @override
  String get schemPartsElisaReaderResult =>
      'Har quduqcha uchun optik zichlik (OD) qiymatlari; standart egri chiziq bo‘yicha konsentratsiya yoki chegara qiymatga (cut-off) nisbatan sifatiy natija (musbat/manfiy).';

  @override
  String get schemPartsBscClass2OpeningName => 'Old ochiqlik (kiruvchi havo)';

  @override
  String get schemPartsBscClass2OpeningFn =>
      'Xona havosi shu yerdan ichkariga so‘riladi — operator himoyalanadi.';

  @override
  String get schemPartsBscClass2GrilleName => 'Old panjara';

  @override
  String get schemPartsBscClass2GrilleFn =>
      'Kiruvchi havo va ish zonasi old qismidagi havo shu yerga so‘riladi; uni to‘smaslik kerak.';

  @override
  String get schemPartsBscClass2WorkzoneName => 'Ish zonasi va ish yuzasi';

  @override
  String get schemPartsBscClass2WorkzoneFn =>
      'Namunalar bilan shu yerda ishlanadi; ustidan toza havo pastga oqadi.';

  @override
  String get schemPartsBscClass2DownflowName => 'Tushuvchi oqim HEPA filtri';

  @override
  String get schemPartsBscClass2DownflowFn =>
      'Ish zonasiga tushadigan havoni zarrachalardan tozalaydi.';

  @override
  String get schemPartsBscClass2FanName => 'Ventilyator';

  @override
  String get schemPartsBscClass2FanFn => 'Havoni kanallar orqali aylantiradi.';

  @override
  String get schemPartsBscClass2ExhaustName => 'Chiqish HEPA filtri';

  @override
  String get schemPartsBscClass2ExhaustFn =>
      'Tashqariga chiqadigan havoni tozalaydi — atrof-muhit himoyalanadi.';

  @override
  String get schemPartsBscClass2PlenumName => 'Orqa havo kanali';

  @override
  String get schemPartsBscClass2PlenumFn =>
      'Panjaradan so‘rilgan havoni ventilyatorga qaytaradi.';

  @override
  String get schemPartsBscClass2SashName => 'Old oyna';

  @override
  String get schemPartsBscClass2SashFn =>
      'Operator yuzini himoyalaydi va old ochiqlik balandligini belgilaydi.';

  @override
  String get schemPartsBscClass2Principle =>
      'Ventilyator havoni aylantiradi. Xona havosi old ochiqlikdan old panjaraga so‘riladi — operator himoyalanadi. HEPA filtrdan o‘tgan toza havo ish yuzasi ustidan pastga oqadi — material himoyalanadi. Ortiqcha havo chiqish HEPA filtri orqali tashqariga chiqariladi — atrof-muhit himoyalanadi.';

  @override
  String get schemPartsBscClass2Result =>
      'Bu o‘lchov asbobi emas: natija — xavfsiz ish muhiti (operator, material va atrof-muhit himoyasi). Ish samaradorligi havo oqimi va filtrlarni muntazam sinash va sertifikatlash bilan tasdiqlanadi.';

  @override
  String get schemPartsAutoclaveChamberName => 'Bosimli kamera';

  @override
  String get schemPartsAutoclaveChamberFn =>
      'Yuklama shu yerda bosim ostidagi to‘yingan bug‘da ushlanadi.';

  @override
  String get schemPartsAutoclaveDoorName => 'Zichlagichli eshik va qulf';

  @override
  String get schemPartsAutoclaveDoorFn =>
      'Kamerani germetik yopadi; bosim bor paytda ochilmaydi.';

  @override
  String get schemPartsAutoclaveTrayName => 'Yuklama tagligi';

  @override
  String get schemPartsAutoclaveTrayFn =>
      'Buyumlar bug\' erkin aylanadigan qilib joylanadi.';

  @override
  String get schemPartsAutoclavePressureName => 'Manometr';

  @override
  String get schemPartsAutoclavePressureFn => 'Kameradagi bosimni ko‘rsatadi.';

  @override
  String get schemPartsAutoclaveThermometerName => 'Termometr';

  @override
  String get schemPartsAutoclaveThermometerFn =>
      'Kameradagi haroratni ko‘rsatadi.';

  @override
  String get schemPartsAutoclaveValveName => 'Xavfsizlik klapani';

  @override
  String get schemPartsAutoclaveValveFn =>
      'Bosim haddan oshsa, bug‘ni chiqarib yuboradi.';

  @override
  String get schemPartsAutoclaveWaterName => 'Suv idishi';

  @override
  String get schemPartsAutoclaveWaterFn =>
      'Bug\' hosil qilish uchun suv shu yerga quyiladi.';

  @override
  String get schemPartsAutoclavePrinciple =>
      'Kameradagi havo chiqarilib, o‘rniga to‘yingan bug\' kiradi. Bosim suvning qaynash haroratini oshiradi, shuning uchun bug\' 121 °C yoki 132 °C kabi yuqori haroratga yetadi. Bug\' buyumlarga tegib, issiqlik bilan mikroorganizmlarni nobud qiladi; jarayonni bug\' sifati, bosim, harorat va vaqt belgilaydi. Qolgan havo bug‘ning yuklamaga tegishiga to‘sqinlik qiladi.';

  @override
  String get schemPartsAutoclaveResult =>
      'Sterillangan yuklama va sikl parametrlari (vaqt, harorat, bosim) yozuvi; samaradorlik kimyoviy va biologik indikatorlar bilan tekshiriladi.';

  @override
  String get schemPartsBloodGasIseSyringeName => 'Geparinli shprisdagi namuna';

  @override
  String get schemPartsBloodGasIseSyringeFn =>
      'Arterial yoki boshqa butun qon havo pufakchalarisiz keltiriladi.';

  @override
  String get schemPartsBloodGasIseProbeName => 'Namuna kiritish zondi';

  @override
  String get schemPartsBloodGasIseProbeFn =>
      'Qonni shprisdan o‘lchash kanaliga so‘radi.';

  @override
  String get schemPartsBloodGasIseSensorsName => 'Sensorlar (elektrodlar)';

  @override
  String get schemPartsBloodGasIseSensorsFn =>
      'pH, pCO₂, pO₂ va elektrolitlar uchun alohida elektrodlar.';

  @override
  String get schemPartsBloodGasIseChannelName => 'O‘lchash kanali';

  @override
  String get schemPartsBloodGasIseChannelFn =>
      'Namuna barcha sensorlar ustidan o‘tadi; kanal haroratda ushlanadi.';

  @override
  String get schemPartsBloodGasIsePackName => 'Reagent paketi';

  @override
  String get schemPartsBloodGasIsePackFn => 'Kalibrlash va yuvish eritmalari.';

  @override
  String get schemPartsBloodGasIseDisplayName => 'Displey';

  @override
  String get schemPartsBloodGasIseDisplayFn =>
      'O‘lchangan va hisoblangan qiymatlarni ko‘rsatadi.';

  @override
  String get schemPartsBloodGasIsePrinterName => 'Printer';

  @override
  String get schemPartsBloodGasIsePrinterFn => 'Natijalarni chop etadi.';

  @override
  String get schemPartsBloodGasIsePrinciple =>
      'Geparinli shprisdagi butun qon zond orqali o‘lchash kanaliga so‘riladi va sensorlar ustidan o‘tadi. pH va pCO₂ potensiometriya, pO₂ amperometriya bilan o‘lchanadi; Na, K, Cl va ionlangan Ca ionselektiv elektrodlarda o‘lchanadi. sO₂ kooksimetriya bilan o‘lchanadi yoki hisoblanadi; umumiy CO₂, bikarbonat va asos ortiqchasi (BE) o‘lchangan qiymatlardan hisoblanadi.';

  @override
  String get schemPartsBloodGasIseResult =>
      'pH, pCO₂, pO₂, sO₂, elektrolitlar va metabolitlar (glyukoza, laktat va boshq.) hamda hisoblangan bikarbonat va BE — kislota-asos holati va oksigenatsiya ko‘rsatkichlari.';

  @override
  String get schemPartsHba1cAnalyzerRackName => 'EDTA probirkalar rakasi';

  @override
  String get schemPartsHba1cAnalyzerRackFn =>
      'Binafsha qopqoqli, butun qonli probirkalar.';

  @override
  String get schemPartsHba1cAnalyzerArmName => 'Namuna oluvchi qo‘l';

  @override
  String get schemPartsHba1cAnalyzerArmFn =>
      'Qonni probirkadan avtomatik olib, o‘lchash tizimiga uzatadi.';

  @override
  String get schemPartsHba1cAnalyzerReagentsName => 'Reagent idishlari';

  @override
  String get schemPartsHba1cAnalyzerReagentsFn =>
      'Analizator usuliga mos reagent yoki bufer eritmalari.';

  @override
  String get schemPartsHba1cAnalyzerDisplayName => 'Displey';

  @override
  String get schemPartsHba1cAnalyzerDisplayFn =>
      'HbA1c natijasi va ish holatini ko‘rsatadi.';

  @override
  String get schemPartsHba1cAnalyzerPrinterName => 'Printer';

  @override
  String get schemPartsHba1cAnalyzerPrinterFn => 'Natijalarni chop etadi.';

  @override
  String get schemPartsHba1cAnalyzerWasteName => 'Chiqindi idishi';

  @override
  String get schemPartsHba1cAnalyzerWasteFn =>
      'Ishlatilgan eritmalar va namuna to‘planadi.';

  @override
  String get schemPartsHba1cAnalyzerPrinciple =>
      'Analizator EDTA li butun qon namunasini avtomatik oladi va HbA1c ulushini o‘lchaydi. O‘lchash usuli analizatorga bog‘liq: ion almashinuv xromatografiyasi, boronat-affin xromatografiya, immunoanaliz, fermentativ usul yoki kapillyar elektroforez — chizma usulni ko‘rsatmaydi. HbA1c glyukozaning gemoglobin beta-zanjiri N-uchidagi valinga fermentsiz birikishidan hosil bo‘ladi.';

  @override
  String get schemPartsHba1cAnalyzerResult =>
      'HbA1c natijasi NGSP (%) va IFCC (mmol/mol) birliklarida; u taxminan 2–3 oylik glikemiya nazoratini aks ettiradi.';

  @override
  String get schemPartsLabFridgeControllerName =>
      'Boshqaruv paneli (termostat)';

  @override
  String get schemPartsLabFridgeControllerFn =>
      'Belgilangan haroratni ushlab turadi va joriy haroratni ko‘rsatadi.';

  @override
  String get schemPartsLabFridgeFridgeName => 'Sovutgich bo‘limi';

  @override
  String get schemPartsLabFridgeFridgeFn =>
      'Namunalar, reagentlar va nazorat materiallari javonlarda saqlanadi.';

  @override
  String get schemPartsLabFridgeProbeName => 'Buferli flakondagi datchik';

  @override
  String get schemPartsLabFridgeProbeFn =>
      'Mahsulot haroratini o‘lchaydi, eshik ochilgandagi qisqa tebranishlarni yumshatadi.';

  @override
  String get schemPartsLabFridgeLoggerName => 'Raqamli ma’lumot yozgich (DDL)';

  @override
  String get schemPartsLabFridgeLoggerFn =>
      'Haroratni muntazam yozadi va me’yordan chiqsa ogohlantiradi.';

  @override
  String get schemPartsLabFridgeFreezerName => 'Muzlatgich bo‘limi';

  @override
  String get schemPartsLabFridgeFreezerFn =>
      'Muzlatilgan alikvotlar (masalan, nazorat materiali) saqlanadi.';

  @override
  String get schemPartsLabFridgePrinciple =>
      'Sovutish agregati bo‘limni belgilangan oraliqda ushlab turadi, haroratni termostat boshqaradi. Buferli flakondagi datchik mahsulot haroratini aks ettiradi (havo haroratining qisqa tebranishlari yumshaydi). Raqamli ma’lumot yozgich (DDL) haroratni muntazam yozib boradi va me’yordan chiqsa ogohlantiradi; zaxira harorat nazorati qurilmasi ham tavsiya etiladi.';

  @override
  String get schemPartsLabFridgeResult =>
      'Uzluksiz harorat yozuvi (min/maks, me’yordan chiqishlar va ogohlantirishlar) — namuna va reagentlar to‘g‘ri saqlanganini hujjatlashtirish uchun.';

  @override
  String get schemPartsFluorescenceMicroscopeEyepiecesName => 'Okulyarlar';

  @override
  String get schemPartsFluorescenceMicroscopeEyepiecesFn =>
      'Tasvirni kuzatish uchun.';

  @override
  String get schemPartsFluorescenceMicroscopeLedName => 'LED yoritgich';

  @override
  String get schemPartsFluorescenceMicroscopeLedFn =>
      'Simob lampasi o‘rniga qo‘zg‘atuvchi nur beradi.';

  @override
  String get schemPartsFluorescenceMicroscopeCubeName => 'Filtr kubigi';

  @override
  String get schemPartsFluorescenceMicroscopeCubeFn =>
      'Qo‘zg‘atuvchi filtr, dixroik ko‘zgu va nurlanish filtri nurni ajratadi.';

  @override
  String get schemPartsFluorescenceMicroscopeObjectiveName => 'Obyektiv';

  @override
  String get schemPartsFluorescenceMicroscopeObjectiveFn =>
      'Nurni preparatga yo‘naltiradi va tasvirni kattalashtiradi.';

  @override
  String get schemPartsFluorescenceMicroscopeStageName => 'Preparatli stolik';

  @override
  String get schemPartsFluorescenceMicroscopeStageFn =>
      'Auramin bilan bo‘yalgan balg‘am surtmasi shu yerga qo‘yiladi.';

  @override
  String get schemPartsFluorescenceMicroscopeFocusName => 'Fokus vintlari';

  @override
  String get schemPartsFluorescenceMicroscopeFocusFn =>
      'Tasvir aniqligini sozlaydi.';

  @override
  String get schemPartsFluorescenceMicroscopeFieldName => 'Ko‘rish maydoni';

  @override
  String get schemPartsFluorescenceMicroscopeFieldFn =>
      'Qorong‘i fonda sarg‘ish-yashil yorqin tayoqchalar — bo‘yalgan batsillalar.';

  @override
  String get schemPartsFluorescenceMicroscopePrinciple =>
      'Surtma auramin (floroxrom) bilan bo‘yaladi; mikobakteriya devori bo‘yoqni ushlab qoladi. LED yoritgich qo‘zg‘atuvchi ko‘k nurni filtr kubigi va obyektiv orqali preparatga yuboradi. Bo‘yalgan batsillalar uzunroq to‘lqinli (sarg‘ish-yashil) nur chiqaradi; nurlanish filtri qo‘zg‘atuvchi nurni to‘sadi, shuning uchun batsillalar qorong‘i fonda yorqin ko‘rinadi.';

  @override
  String get schemPartsFluorescenceMicroscopeResult =>
      'Mikroskopiya xulosasi: kislotaga chidamli batsillalar (yorqin tayoqchalar) topildi yoki topilmadi, topilsa — miqdoriy darajasi.';

  @override
  String get schemPartsCasaCameraName => 'Raqamli kamera';

  @override
  String get schemPartsCasaCameraFn =>
      'Mikroskop tasvirini kadrlar ketma-ketligi sifatida yozadi.';

  @override
  String get schemPartsCasaMicroscopeName => 'Mikroskop (obyektiv)';

  @override
  String get schemPartsCasaMicroscopeFn =>
      'Spermatozoidlarni kattalashtiradi, odatda fazali kontrast bilan.';

  @override
  String get schemPartsCasaStageName => 'Isitiladigan stolik';

  @override
  String get schemPartsCasaStageFn =>
      'Namuna haroratini barqaror ushlaydi — harakatchanlik haroratga bog‘liq.';

  @override
  String get schemPartsCasaChamberName => 'Hisoblash kamerasi';

  @override
  String get schemPartsCasaChamberFn =>
      'Belgilangan chuqurlikdagi kamera namuna qatlamini bir xil qalinlikda beradi.';

  @override
  String get schemPartsCasaSoftwareName => 'Kompyuter va dastur';

  @override
  String get schemPartsCasaSoftwareFn =>
      'Izlarni tiklaydi va kinematik ko‘rsatkichlarni hisoblaydi.';

  @override
  String get schemPartsCasaPrinciple =>
      'Sperma namunasi hisoblash kamerasiga solinadi va isitiladigan stolikka qo‘yiladi. Kamera mikroskop orqali ketma-ket kadrlar oladi; dastur boshchalarni topib, har bir harakatchan spermatozoid izini tiklaydi va harakat kinematikasini hisoblaydi. Kamida 200 ta harakatchan hujayra izi tahlil qilinadi.';

  @override
  String get schemPartsCasaResult =>
      'Kinematik ko‘rsatkichlar (masalan, egri chiziqli, to‘g‘ri chiziqli va o‘rtacha yo‘l tezligi) va harakat turlari; JSST qo‘llanmasiga ko‘ra harakatchanlik foizi ishonchsiz bo‘lishi mumkin — chiqindi zarrachalar harakatsiz hujayra deb olinishi mumkin.';

  @override
  String get schemPartsGelCardSystemCentrifugeName => 'Karta sentrifugasi';

  @override
  String get schemPartsGelCardSystemCentrifugeFn =>
      'Kartalarni belgilangan tezlik va vaqtda aylantiradi.';

  @override
  String get schemPartsGelCardSystemIncubatorName => 'Inkubator';

  @override
  String get schemPartsGelCardSystemIncubatorFn =>
      'Antiglobulin testi uchun kartalarni inkubatsiya qiladi.';

  @override
  String get schemPartsGelCardSystemCardName => 'Gel karta';

  @override
  String get schemPartsGelCardSystemCardFn =>
      'Plastik karta: har mikronaychada gel yoki shisha munchoq matritsasi.';

  @override
  String get schemPartsGelCardSystemChamberName => 'Reaksiya kamerasi';

  @override
  String get schemPartsGelCardSystemChamberFn =>
      'Eritrotsitlar va zardob (yoki reagent) shu yerda aralashadi.';

  @override
  String get schemPartsGelCardSystemGelName => 'Gel ustuni (matritsa)';

  @override
  String get schemPartsGelCardSystemGelFn =>
      'Agglyutinatlarni ushlab qoladi, yakka eritrotsitlarni o‘tkazadi; antiglobulin yoki anti-A, anti-B saqlashi mumkin.';

  @override
  String get schemPartsGelCardSystemPositiveName => 'Musbat reaksiya';

  @override
  String get schemPartsGelCardSystemPositiveFn =>
      'Eritrotsitlar gel ustida yoki ichida qoladi.';

  @override
  String get schemPartsGelCardSystemNegativeName => 'Manfiy reaksiya';

  @override
  String get schemPartsGelCardSystemNegativeFn =>
      'Eritrotsitlar naycha tubida tugma hosil qiladi.';

  @override
  String get schemPartsGelCardSystemPrinciple =>
      'Mikronaychaning yuqori reaksiya kamerasiga eritrotsit suspenziyasi va zardob (yoki reagent) solinadi va inkubatsiya qilinadi. Sentrifugalanganda eritrotsitlar gel yoki shisha munchoq matritsasiga haydaladi, zardob esa yuqorida qoladi. Agglyutinatlar (masalan, antitana qoplagan va antiglobulin bog‘lagan hujayralar) gelda tutiladi — musbat; agglyutinatsiyaga uchramagan hujayralar tubiga tushib tugma hosil qiladi — manfiy. Antiglobulin testi uchun yuvish kerak emas.';

  @override
  String get schemPartsGelCardSystemResult =>
      'Har mikronaychadagi reaksiya: musbat (agglyutinatlar gel ustida yoki ichida, kuchi darajalanadi) yoki manfiy (tubida tugma); shundan qon guruhi yoki to‘g‘ri antiglobulin testi xulosasi chiqariladi.';

  @override
  String get schemPartsEsrAnalyzerStandName => 'Westergren shtativi';

  @override
  String get schemPartsEsrAnalyzerStandFn =>
      'Naychalarni qat’iy tik holatda ushlab turadi.';

  @override
  String get schemPartsEsrAnalyzerTubeName => 'Westergren naychasi';

  @override
  String get schemPartsEsrAnalyzerTubeFn =>
      'Darajalangan standart naycha, ichki diametri 2,5 mm.';

  @override
  String get schemPartsEsrAnalyzerBoundaryName => 'Plazma–eritrotsit chegarasi';

  @override
  String get schemPartsEsrAnalyzerBoundaryFn =>
      'Bir soatdan keyin shu chegaragacha bo‘lgan masofa millimetrda o‘qiladi.';

  @override
  String get schemPartsEsrAnalyzerReaderName => 'Avtomatik o‘quvchi';

  @override
  String get schemPartsEsrAnalyzerReaderFn =>
      'Yopiq probirkalarda cho‘kishni avtomatik o‘lchaydi.';

  @override
  String get schemPartsEsrAnalyzerTubesName => 'Yopiq probirkalar';

  @override
  String get schemPartsEsrAnalyzerTubesFn => 'Namuna probirkasi ochilmaydi.';

  @override
  String get schemPartsEsrAnalyzerSensorsName => 'Optik datchiklar';

  @override
  String get schemPartsEsrAnalyzerSensorsFn =>
      'Plazma va eritrotsit ustuni chegarasini aniqlaydi.';

  @override
  String get schemPartsEsrAnalyzerDisplayName => 'Displey';

  @override
  String get schemPartsEsrAnalyzerDisplayFn => 'Natijalarni ko‘rsatadi.';

  @override
  String get schemPartsEsrAnalyzerPrinciple =>
      'Antikoagulyantli qon standart tik naychada (Westergren, ichki diametri 2,5 mm) og‘irlik kuchi ta’sirida bir soat cho‘kadi; tiniq plazma ustunining balandligi millimetrda o‘qiladi. Yallig‘lanishda oqsillar ko‘payib, eritrotsitlarning tanga ustunlari (rouleaux) hosil bo‘lishini kuchaytiradi va cho‘kish tezlashadi. Avtomatik o‘quvchilar yopiq probirkalarda plazma–eritrotsit chegarasini optik datchiklar bilan kuzatadi.';

  @override
  String get schemPartsEsrAnalyzerResult =>
      'EChT qiymati mm/soat da; nospetsifik ko‘rsatkich, boshqa tekshiruvlar bilan birga talqin qilinadi.';

  @override
  String get schemPartsAggregometerChannelsName => 'LTA o‘lchash kanallari';

  @override
  String get schemPartsAggregometerChannelsFn =>
      'Kyuvetalar 37 °C da isitiladi va aralashtiriladi.';

  @override
  String get schemPartsAggregometerLightName => 'Yorug‘lik manbai';

  @override
  String get schemPartsAggregometerLightFn =>
      'Kyuvetadan o‘tadigan nur beradi.';

  @override
  String get schemPartsAggregometerCuvetteName =>
      'Kyuveta (plazma va magnit aralashtirgich)';

  @override
  String get schemPartsAggregometerCuvetteFn =>
      'Trombotsitga boy plazma; agonist shu yerga qo‘shiladi.';

  @override
  String get schemPartsAggregometerPhotodetectorName => 'Fotodetektor';

  @override
  String get schemPartsAggregometerPhotodetectorFn =>
      'Agregatsiyada ortgan nur o‘tkazuvchanligini o‘lchaydi.';

  @override
  String get schemPartsAggregometerCurvesName => 'Agregatsiya egri chiziqlari';

  @override
  String get schemPartsAggregometerCurvesFn =>
      'Har kanal bo‘yicha o‘tkazuvchanlik vaqt bo‘yicha.';

  @override
  String get schemPartsAggregometerCupName => 'Qonli kosacha';

  @override
  String get schemPartsAggregometerCupFn =>
      'Sitratli qon kalsiy va aktivator bilan shu yerda ivitiladi.';

  @override
  String get schemPartsAggregometerPinName => 'Pin va burilish datchigi';

  @override
  String get schemPartsAggregometerPinFn =>
      'Fibrin pinni kosacha bilan bog‘laydi; uzatilgan moment qayd etiladi.';

  @override
  String get schemPartsAggregometerTraceName => 'Viskoelastik trassa';

  @override
  String get schemPartsAggregometerTraceFn =>
      'Laxta hosil bo‘lishi, mustahkamligi va erishi grafigi.';

  @override
  String get schemPartsAggregometerPrinciple =>
      'LTA: trombotsitga boy plazma kyuvetada 37 °C da aralashtirib turiladi. Agonist qo‘shilgach trombotsitlar agregatlarga birikadi, plazma tiniqlashadi va o‘tgan nur ortadi — fotodetektor buni egri chiziq sifatida yozadi. TEG/ROTEM: sitratli qon aylanuvchi kosachada kalsiy va aktivator bilan ivitiladi; fibrin pinni kosacha bilan bog‘laydi va uzatilgan burilish momenti trassa sifatida chiziladi.';

  @override
  String get schemPartsAggregometerResult =>
      'LTA: har agonist uchun agregatsiya egri chizig‘i (nur o‘tkazuvchanligi vaqt bo‘yicha). TEG/ROTEM: laxta hosil bo‘lishi, mustahkamligi va fibrinolizni ko‘rsatuvchi viskoelastik trassa.';

  @override
  String get schemPartsElectrophoresisPowerName => 'Tok manbai';

  @override
  String get schemPartsElectrophoresisPowerFn =>
      'Elektrodlarga doimiy kuchlanish beradi.';

  @override
  String get schemPartsElectrophoresisElectrodesName =>
      'Bufer bo‘limlari va elektrodlar';

  @override
  String get schemPartsElectrophoresisElectrodesFn =>
      'Bufer tok o‘tkazadi; katod (−) va anod (+) elektr maydon hosil qiladi.';

  @override
  String get schemPartsElectrophoresisWicksName => 'Pilikchalar';

  @override
  String get schemPartsElectrophoresisWicksFn =>
      'Buferni tashuvchi muhitga yetkazib, elektr zanjirini tutashtiradi.';

  @override
  String get schemPartsElectrophoresisMediumName =>
      'Tashuvchi muhit va fraksiyalar';

  @override
  String get schemPartsElectrophoresisMediumFn =>
      'Agaroza yoki atsetatsellyulozada molekulalar zonalarga ajraladi.';

  @override
  String get schemPartsElectrophoresisCoverName => 'Qopqoq';

  @override
  String get schemPartsElectrophoresisCoverFn =>
      'Bug‘lanishni kamaytiradi va tok urishidan himoyalaydi.';

  @override
  String get schemPartsElectrophoresisDensitometerName => 'Densitometr';

  @override
  String get schemPartsElectrophoresisDensitometerFn =>
      'Bo‘yalgan zonalarning optik zichligini skanerlab, densitogramma chizadi.';

  @override
  String get schemPartsElectrophoresisPrinciple =>
      'Namuna bufer bilan namlangan tashuvchi muhitga (agaroza, atsetatsellyuloza yoki poliakrilamid) qo‘yiladi. Tok manbai elektrodlar orqali elektr maydon hosil qiladi; zaryadlangan molekulalar zaryadi, o‘lchami va shakliga ko‘ra turli tezlikda siljib, zonalarga ajraladi. So‘ng zonalar bo‘yaladi va densitometrda optik zichlik bo‘yicha o‘lchanadi.';

  @override
  String get schemPartsElectrophoresisResult =>
      'Bo‘yalgan fraksiyalar (masalan, zardob oqsillarida albumin, alfa-1, alfa-2, beta, gamma) va densitogramma — har fraksiyaning nisbiy ulushi; namuna nazorat namunalari bilan solishtiriladi.';

  @override
  String get schemPartsOsmometerTubesName => 'Namuna probirkalari';

  @override
  String get schemPartsOsmometerTubesFn =>
      'Kichik hajmdagi siydik yoki zardob.';

  @override
  String get schemPartsOsmometerThermistorName => 'Termistor zondi';

  @override
  String get schemPartsOsmometerThermistorFn =>
      'Namunaga botiriladi va haroratni aniq o‘lchaydi.';

  @override
  String get schemPartsOsmometerBathName => 'Sovutish bloki (vanna)';

  @override
  String get schemPartsOsmometerBathFn =>
      'Namunani muzlash nuqtasidan pastgacha sovutadi.';

  @override
  String get schemPartsOsmometerWireName => 'Aralashtirgich sim';

  @override
  String get schemPartsOsmometerWireFn =>
      'Tebranib, o‘ta sovigan namunada muzlashni boshlaydi.';

  @override
  String get schemPartsOsmometerDisplayName =>
      'Displey (muzlash egri chizig‘i)';

  @override
  String get schemPartsOsmometerDisplayFn =>
      'Harorat egri chizig‘i va osmolyallik natijasi.';

  @override
  String get schemPartsOsmometerPrinciple =>
      'Namuna sovutish blokida muzlash nuqtasidan pastgacha o‘ta sovutiladi, so‘ng aralashtirgich sim tebranishi muzlashni boshlaydi. Ajralgan yashirin issiqlik haroratni muzlash nuqtasigacha ko‘taradi va plato hosil bo‘ladi; uni Uitston ko‘prigi sxemasidagi termistor o‘lchaydi. Erigan zarrachalar muzlash nuqtasini pasaytiradi: 1 kg suvdagi 1 mol erigan zarracha (1 osmol) uni taxminan 1,86 °C ga tushiradi; elektrolitlarda zarrachalar soni dissotsiatsiyaga bog‘liq. O‘lchangan pasayishdan osmolyallik hisoblanadi.';

  @override
  String get schemPartsOsmometerResult =>
      'Siydik yoki zardob osmolyalligi, mOsm/kg — suv kilogrammidagi zarrachalar miqdori (osmolyarlik esa eritma litriga, mOsm/l).';

  @override
  String get schemPartsTlcTankName => 'Rivojlantirish kamerasi (qopqoqli)';

  @override
  String get schemPartsTlcTankFn =>
      'Erituvchi bug‘i bilan to‘yintirilgan yopiq shisha kamera.';

  @override
  String get schemPartsTlcSolventName => 'Harakatlanuvchi faza (erituvchi)';

  @override
  String get schemPartsTlcSolventFn =>
      'Kapillyar kuch bilan plastina bo‘ylab yuqoriga ko‘tariladi.';

  @override
  String get schemPartsTlcPlateName => 'TSX plastinasi (silikagel GF254)';

  @override
  String get schemPartsTlcPlateFn =>
      'Yupqa silikagel qatlami; fluoressent indikator UB nurida yashil yorqinlik beradi.';

  @override
  String get schemPartsTlcOriginName => 'Start chizig‘i';

  @override
  String get schemPartsTlcOriginFn =>
      'Namuna va standart dog‘lari shu chiziqqa tomiziladi.';

  @override
  String get schemPartsTlcFrontName => 'Erituvchi fronti';

  @override
  String get schemPartsTlcFrontFn =>
      'Erituvchi yetib borgan chiziq; Rf ni hisoblash uchun belgilanadi.';

  @override
  String get schemPartsTlcCapillariesName => 'Kapillyarlar';

  @override
  String get schemPartsTlcCapillariesFn =>
      'Namunani kichik dog\' qilib tomizish uchun.';

  @override
  String get schemPartsTlcLampName => 'UB lampa (254 nm)';

  @override
  String get schemPartsTlcLampFn =>
      'Plastinani yoritib, dog‘larni ko‘rinadigan qiladi.';

  @override
  String get schemPartsTlcSpotsName => 'UB nuridagi dog‘lar';

  @override
  String get schemPartsTlcSpotsFn =>
      'Moddalar fluoressensiyani so‘ndiradi va yashil fonda qorong‘i dog\' bo‘lib ko‘rinadi.';

  @override
  String get schemPartsTlcPrinciple =>
      'Namuna va standart dog‘lari start chizig‘iga tomiziladi, plastina pastki cheti erituvchiga tegadigan qilib to‘yintirilgan kameraga qo‘yiladi. Erituvchi ko‘tarilar ekan, moddalar silikagel (statsionar faza) va erituvchi (harakatlanuvchi faza) orasida taqsimlanib, turli masofaga siljiydi. Rivojlantirilgan plastina 254 nm UB nurida ko‘riladi yoki reagent purkab ochiladi.';

  @override
  String get schemPartsTlcResult =>
      'Dog‘lar joylashuvi va Rf qiymatlari (dog\' masofasi / erituvchi fronti masofasi); moddani aniqlash uchun standart bilan solishtiriladi.';

  @override
  String get schemPartsAnalyticalBalancePipetteName =>
      'Pipetka (havo siljitishli)';

  @override
  String get schemPartsAnalyticalBalancePipetteFn =>
      'Kalibrlanayotgan asbob: belgilangan hajmni quyadi.';

  @override
  String get schemPartsAnalyticalBalanceVesselName => 'Tortish idishi';

  @override
  String get schemPartsAnalyticalBalanceVesselFn =>
      'Quyilgan suv shu idishga tushadi va tortiladi.';

  @override
  String get schemPartsAnalyticalBalancePanName => 'Tarozi pallasi';

  @override
  String get schemPartsAnalyticalBalancePanFn => 'Massa shu yerda o‘lchanadi.';

  @override
  String get schemPartsAnalyticalBalanceEnclosureName => 'Shisha himoya qutisi';

  @override
  String get schemPartsAnalyticalBalanceEnclosureFn =>
      'Havo oqimi va changning tortishga ta’sirini kamaytiradi.';

  @override
  String get schemPartsAnalyticalBalanceDisplayName => 'Displey va tugmalar';

  @override
  String get schemPartsAnalyticalBalanceDisplayFn =>
      'Massa ko‘rsatiladi; tara tugmasi idish massasini nolga tushiradi.';

  @override
  String get schemPartsAnalyticalBalanceWaterName => 'Suv idishi';

  @override
  String get schemPartsAnalyticalBalanceWaterFn =>
      'Toza (distillangan) suv, harorati xona haroratiga tenglashtirilgan.';

  @override
  String get schemPartsAnalyticalBalanceThermometerName => 'Termometr';

  @override
  String get schemPartsAnalyticalBalanceThermometerFn =>
      'Suv haroratini o‘lchaydi — zichlik tuzatmasi uchun.';

  @override
  String get schemPartsAnalyticalBalancePrinciple =>
      'Pipetka belgilangan hajmdagi suvni tarozidagi idishga quyadi va suv massasi tortiladi. Massa suv zichligi (harorat bo‘yicha) va havoning ko‘tarish kuchi tuzatmalari bilan hajmga aylantiriladi, shuning uchun suv va havo harorati qayd etiladi. Pipetka «quyish uchun» hajmga kalibrlanadi.';

  @override
  String get schemPartsAnalyticalBalanceResult =>
      'Har quyishning hisoblangan hajmi; nominal hajm bilan solishtirib aniqlik (sistematik xato) va takrorlanuvchanlik baholanadi.';

  @override
  String get howToButton => 'Qanday foydalaniladi?';

  @override
  String get howToStepsTitle => 'Qadamlar';

  @override
  String get howToResultTitle => 'Natijada nima olasiz';

  @override
  String get howToWatchVideo => 'Videoni ko‘rish';

  @override
  String howToVideoMb(String mb) {
    return '$mb MB';
  }

  @override
  String howToVideoNote(String duration) {
    return 'Ovozsiz, subtitrli ekran yozuvi · $duration · brauzer yoki video pleyerda ochiladi';
  }

  @override
  String howToVideoStartsAt(String time) {
    return 'Videoda bu bo‘lim $time dan boshlanadi.';
  }

  @override
  String get howToVideoOffline =>
      'Video uchun internet kerak. Matnli qo‘llanma shu yerda — u internetsiz ishlaydi.';

  @override
  String get howToVideoUnavailable =>
      'Video hozir ochilmadi. Keyinroq urinib ko‘ring — matnli qo‘llanma shu yerda.';

  @override
  String get howToCalibrationStep1 =>
      '«1. Apparat»: katalogdan modelni tanlang yoki ro‘yxatda yo‘q apparatni qo‘shing.';

  @override
  String get howToCalibrationStep2 =>
      '«2. Analit»: tahlil nomini yozing (masalan, glyukoza) va ro‘yxatdan tanlang.';

  @override
  String get howToCalibrationStep3 =>
      '«3. Reagent»: ishlab chiqaruvchi, REF raqami va IFU versiyasini kiriting.';

  @override
  String get howToCalibrationStep4 =>
      '«Yo‘riqnomani ko‘rsatish» ni bosing — ilova moslikni tekshiradi va mos yo‘riqnomani ko‘rsatadi.';

  @override
  String get howToCalibrationStep5 =>
      '«Kalibrlash yozuvini yaratish»: lot, qiymatlar va natijani kiritib, yozuvni saqlang.';

  @override
  String get howToCalibrationStep6 =>
      'Barcha yozuvlar «Kalibrlash jurnali» da — faqat shu qurilmada saqlanadi.';

  @override
  String get howToCalibrationResult =>
      'Apparat, analit va reagentga mos kalibrlash yo‘riqnomasi hamda qurilmadagi kalibrlash jurnali.';

  @override
  String get howToQcStep1 =>
      '«Test qo‘shish»: test nomi, birlik va nazorat darajalarini kiriting.';

  @override
  String get howToQcStep2 =>
      'Har daraja uchun maqsadli o‘rtacha va SD ni kiriting — ilova ularni o‘zi to‘qimaydi.';

  @override
  String get howToQcStep3 =>
      'Har seriyadan keyin nazorat natijalarini yozing va «Seriyani saqlash» ni bosing.';

  @override
  String get howToQcStep4 =>
      'Levey–Jennings grafigi va Westgard qoidalari xulosasini ko‘ring: nazoratda, ogohlantirish yoki rad etilgan.';

  @override
  String get howToQcStep5 =>
      '«Yo‘riqnomalar»: QC rad etilganda nima qilish, tashqi sifat nazorati (EQA) va kritik qiymatlar.';

  @override
  String get howToQcStep6 =>
      'Zaxira: ma’lumotlarni matn sifatida nusxalab, keyin tiklash mumkin.';

  @override
  String get howToQcResult =>
      'Har daraja bo‘yicha Levey–Jennings grafigi va har seriya uchun Westgard xulosasi — shu qurilmada.';

  @override
  String get howToPreanalyticsStep1 =>
      'Tepada — 5 bosqich: tahlilga tayyorlashdan tashish va qabul qilishgacha.';

  @override
  String get howToPreanalyticsStep2 =>
      'Bemor tayyorgarligi: och qoringa, dorilar, jismoniy zo‘riqish — har band manbasi bilan.';

  @override
  String get howToPreanalyticsStep3 =>
      'Probirkalar tartibi: venepunksiyada qaysi probirka qachon to‘ldiriladi (qopqoq rangi bilan).';

  @override
  String get howToPreanalyticsStep4 =>
      'Pastroqda: ajratish, saqlash, tashish va qabul qilish shartlari.';

  @override
  String get howToPreanalyticsStep5 =>
      'Har bandni laboratoriyangiz SOP i bilan solishtiring.';

  @override
  String get howToPreanalyticsResult =>
      'Namuna olishdan oldin va keyin tekshiriladigan qoidalar — manbalari bilan, bir sahifada.';

  @override
  String get howToCalculatorsStep1 =>
      'Kalkulyatorni tanlang: klinik formulalar, qo‘lda usullar yoki laboratoriya.';

  @override
  String get howToCalculatorsStep2 =>
      'Qiymatlarni kiriting va birliklarni tekshiring.';

  @override
  String get howToCalculatorsStep3 =>
      'Kerak bo‘lsa, parametrni (masalan, jins) tanlang va «Hisoblash» ni bosing.';

  @override
  String get howToCalculatorsStep4 =>
      'Natija ostidagi izoh va manbalarni o‘qing: formula cheklovlari shu yerda.';

  @override
  String get howToCalculatorsResult =>
      'Faqat siz kiritgan qiymatlardan hisoblangan natija — formula va manbasi bilan.';

  @override
  String get howToInstrumentsStep1 =>
      'Yo‘nalishni tanlang: biokimyo, gematologiya, immunokimyo yoki siydik tahlili.';

  @override
  String get howToInstrumentsStep2 =>
      'Ishlab chiqaruvchi va modelni tanlang yoki qidiruvga model nomini yozing.';

  @override
  String get howToInstrumentsStep3 =>
      'Model kartasi: «Mening apparatim sifatida saqlash», so‘ng kalibrlash yoki QC ga o‘tish.';

  @override
  String get howToInstrumentsStep4 =>
      '«Laboratoriya yo‘nalishlari (ma’lumotnoma)»: sil, OIV, bakteriologiya va boshqa yo‘nalishlar kartalari.';

  @override
  String get howToInstrumentsStep5 =>
      'Kartadagi sxema — apparat sinfining umumiy tasviri, aniq model emas.';

  @override
  String get howToInstrumentsResult =>
      'Apparat va yo‘nalish bo‘yicha ma’lumotnoma kartalari, sxemalar va kalibrlash/QC ga tez o‘tish.';

  @override
  String get howToMicroscopyStep1 =>
      'Bo‘limni tanlang: siydik cho‘kmasi, periferik qon surtmasi yoki qon parazitlari (bezgak).';

  @override
  String get howToMicroscopyStep2 =>
      'Rasmni bosing: kartada belgilar, muallif va litsenziya.';

  @override
  String get howToMicroscopyStep3 =>
      'Qidiruvga nom yozing (masalan, oksalat yoki neytrofil).';

  @override
  String get howToMicroscopyStep4 =>
      '«Mashqni boshlash»: rasmga qarab 4 variantdan to‘g‘ri nomni tanlang — javob darhol ko‘rinadi.';

  @override
  String get howToMicroscopyStep5 =>
      'Raund oxirida natija; xatolarni qayta ishlash mumkin.';

  @override
  String get howToMicroscopyResult =>
      'Litsenziyali mikrofotolar atlasi va o‘zingizni tekshirish uchun rasmli mashq.';

  @override
  String get howToCoprologyStep1 =>
      '«Namuna yig‘ish»: idish, muddat, bir nechta namuna, konservant.';

  @override
  String get howToCoprologyStep2 =>
      '«Makroskopik tekshiruv»: shakl, rang, reaksiya, aralashmalar.';

  @override
  String get howToCoprologyStep3 =>
      '«Koprogramma mikroskopiyasi»: har element kartasi (mushak tolasi, yog‘, kraxmal va boshqalar).';

  @override
  String get howToCoprologyStep4 =>
      '«Yashirin qon»: FIT va gvayak testi, tayyorgarlik, natija.';

  @override
  String get howToCoprologyStep5 =>
      '«Ichak parazitlari»: boyitish usullari, tuxum va sistalar kaliti (sxema).';

  @override
  String get howToCoprologyStep6 =>
      'Pastda — amaliy protokollar (taqdimot) va tahlil kartalari.';

  @override
  String get howToCoprologyResult =>
      'Namuna olishdan natijagacha koprologiya ma’lumotnomasi — manbalari bilan; bu tashxis emas.';

  @override
  String get howToAssessmentStep1 =>
      'Kategoriyangizni tanlang (3–2, 1 yoki oliy) va kunlik maqsadni belgilang.';

  @override
  String get howToAssessmentStep2 =>
      '«Bilim testi»: rasmiy ro‘yxatdan tasodifiy savollar bilan test.';

  @override
  String get howToAssessmentStep3 =>
      '«Mavzu bo‘yicha mashq»: javobdan keyin darhol kalit va izoh.';

  @override
  String get howToAssessmentStep4 =>
      '«Og‘zaki bilet»: bilet oling, tayyorlaning, javob rejasini ko‘rib, o‘zingizni baholang.';

  @override
  String get howToAssessmentStep5 =>
      '«Xatolar ustida ishlash» va «Rivojlanish»: xatolarni qayta ishlang, mavzular bo‘yicha natijani kuzating.';

  @override
  String get howToAssessmentStep6 =>
      'Bo‘lim barcha tillarda va barcha davlatlarda mavjud. Yashirish uchun: Profil → «Bilim va malakani baholash» → «Yashirish».';

  @override
  String get howToAssessmentResult =>
      'Rasmiy ro‘yxat savollari bo‘yicha mashq, natijalaringiz va xatolar tahlili — bilimingizni o‘zingiz tekshirish uchun.';

  @override
  String get howToDifferentialStep1 =>
      '«Hujayralarni tanish»: har hujayraning o‘lchami, yadrosi, sitoplazmasi va donachalari.';

  @override
  String get howToDifferentialStep2 =>
      '«Sanashni boshlash»: bosish +1, uzoq bosish −1; 100 yoki 200 hujayra.';

  @override
  String get howToDifferentialStep3 =>
      'Sanash tugagach natijani tarixga saqlang — «Saqlangan natijalar», faqat shu qurilmada.';

  @override
  String get howToDifferentialStep4 =>
      '«Leykoformula: mutlaq sonlar»: WBC va foizlardan mutlaq sonlar.';

  @override
  String get howToDifferentialStep5 =>
      '«Talqin» va «“Bu qaysi hujayra?” mashqi» bilan bilimingizni mustahkamlang.';

  @override
  String get howToDifferentialResult =>
      'Foizli leykoformula, qurilmada saqlangan natijalar, talqin bo‘yicha ma’lumot va mashq.';

  @override
  String get howToCytologyStep1 =>
      '«Hujayralarni tanish»: har elementning rasmi va asosiy belgisi.';

  @override
  String get howToCytologyStep2 =>
      '«Qin surtmasining tozalik darajasi»: ko‘rganingizni belgilang — ilova darajani ko‘rsatadi.';

  @override
  String get howToCytologyStep3 =>
      '«Bethesda tasnifi»: PAP-test xulosasi nimani anglatadi.';

  @override
  String get howToCytologyStep4 =>
      'Namuna sifati, reaktiv o‘zgarishlar va yetilish indeksi — alohida sahifalarda.';

  @override
  String get howToCytologyStep5 => '«Bu qaysi hujayra?»: rasm bo‘yicha mashq.';

  @override
  String get howToCytologyResult =>
      'Ginekologik surtma bo‘yicha o‘quv ma’lumotnomasi, tozalik darajasi va mashq; tashxis emas.';

  @override
  String get howToSpermogramStep1 =>
      '«Asosiy ko‘rsatkichlar»: JSST 2021 pastki referens chegaralari.';

  @override
  String get howToSpermogramStep2 =>
      '«Sanash hisoblagichi»: harakatchanlik va morfologiyani sanash.';

  @override
  String get howToSpermogramStep3 =>
      '«Natijani baholash»: qiymatlarni kiriting — ular JSST chegaralari bilan solishtiriladi.';

  @override
  String get howToSpermogramStep4 =>
      '«Atamalar» va «Preanalitika»: oligo-, asteno-, terato-; tiyilish, namuna olish, yetkazish.';

  @override
  String get howToSpermogramStep5 =>
      '«Mashq»: savollar bilan bilimingizni tekshiring.';

  @override
  String get howToSpermogramResult =>
      'JSST 2021 chegaralari bilan solishtirilgan natija, atamalar va mashq — o‘quv ma’lumotnomasi.';

  @override
  String get howToBloodGroupStep1 =>
      '«ABO va RhD asoslari»: antigenlar, antitelalar, to‘g‘ri va teskari usul.';

  @override
  String get howToBloodGroupStep2 =>
      '«Usullar» va «Moslik»: plastinka, probirka, gel-karta; moslik sinamalari.';

  @override
  String get howToBloodGroupStep3 =>
      '«Nomuvofiqlik va xatolar»: to‘g‘ri va teskari natija farqi, kuchsiz D.';

  @override
  String get howToBloodGroupStep4 =>
      '«Reaksiya naqshini o‘qish»: natijalarni belgilang — ilova o‘quv talqinini ko‘rsatadi.';

  @override
  String get howToBloodGroupStep5 =>
      '«Mashq»; transfuziya bo‘yicha qaror — faqat mahalliy protokol asosida.';

  @override
  String get howToBloodGroupResult =>
      'ABO va RhD bo‘yicha o‘quv ma’lumotnomasi va reaksiya naqshining o‘quv talqini.';

  @override
  String get howToHistologyStep1 =>
      '«To‘qimalar va a’zolar»: epiteliy, biriktiruvchi, muskul, nerv; jigar, buyrak.';

  @override
  String get howToHistologyStep2 =>
      'Rasmni oching: haqiqiy mikrofoto, asosiy belgi va nimaga qarash.';

  @override
  String get howToHistologyStep3 =>
      '«Bo‘yash usullari»: H&E, Masson, elastik, kumush, PAS, LFB.';

  @override
  String get howToHistologyStep4 => '«Bu qaysi to‘qima?»: rasm bo‘yicha mashq.';

  @override
  String get howToHistologyStep5 =>
      '«Rasmlar mualliflari»: har rasmning muallifi va litsenziyasi.';

  @override
  String get howToHistologyResult =>
      'Litsenziyali mikrofotolar bilan to‘qimalar atlasi, bo‘yash usullari va mashq.';

  @override
  String get howToUrinalysisStep1 =>
      '«Namuna yig‘ish va saqlash»: ertalabki, o‘rta porsiya, vaqt, sovutish.';

  @override
  String get howToUrinalysisStep2 =>
      '«Fizik xossalar»: rangi, tiniqligi, hidi, nisbiy zichligi.';

  @override
  String get howToUrinalysisStep3 =>
      '«Test-chiziq (kimyoviy tekshiruv)»: 10 maydoncha — ma’nosi, xalaqitlar, tasdiqlash.';

  @override
  String get howToUrinalysisStep4 =>
      '«Cho‘kma mikroskopiyasi»: hujayralar, silindrlar, kristallar, mikroorganizmlar.';

  @override
  String get howToUrinalysisStep5 =>
      '«Natijani o‘qish» va «Mashq: bu nima?» — bilimingizni tekshiring.';

  @override
  String get howToUrinalysisResult =>
      'Siydik tahlili bo‘yicha bosqichma-bosqich ma’lumotnoma, natijani o‘qish yordamchisi va mashq.';

  @override
  String get howToBloodMorphStep1 =>
      '«Normal eritrotsit va nimaga qarash»: o‘lcham, rang, shakl, kiritmalar.';

  @override
  String get howToBloodMorphStep2 =>
      '«Eritrotsit o‘zgarishlari»: rasmli kartalar — nimani ko‘rasiz, nimaga ishora qiladi.';

  @override
  String get howToBloodMorphStep3 =>
      '«Trombotsitlar» va «Retikulotsitlar»: sanash tamoyili va artefaktlar.';

  @override
  String get howToBloodMorphStep4 =>
      '«Anemiya tasnifi yordamchisi»: Hb, MCV, RDW → morfologik guruh.';

  @override
  String get howToBloodMorphStep5 =>
      '«Mashq: bu qaysi o‘zgarish?» — rasm va bilim savollari.';

  @override
  String get howToBloodMorphResult =>
      'Periferik qon surtmasi bo‘yicha rasmli ma’lumotnoma, anemiya tasnifi yordamchisi va mashq.';

  @override
  String get howToCoagulogramStep1 =>
      '«Testlar nimani o‘lchaydi»: PT/INR, APTT, trombin vaqti, fibrinogen, D-dimer.';

  @override
  String get howToCoagulogramStep2 =>
      '«Namuna talablari»: 3,2 % sitrat, 9:1 nisbat, vaqt, preanalitik xatolar.';

  @override
  String get howToCoagulogramStep3 =>
      '«Natijani o‘qish yordamchisi»: PT, APTT va trombotsitlar → manbadagi ehtimoliy sabablar.';

  @override
  String get howToCoagulogramStep4 =>
      '«ISTH ochiq DIC bali»: qiymatlarni kiriting — bal hisoblanadi.';

  @override
  String get howToCoagulogramStep5 =>
      '«Antikoagulyant monitoringi»: varfarin — INR, geparin — APTT/anti-Xa.';

  @override
  String get howToCoagulogramResult =>
      'Gemostaz testlari bo‘yicha ma’lumotnoma, natijani o‘qish yordamchisi va DIC bali — manbalari bilan.';

  @override
  String get proPayTierPro => 'Pro';

  @override
  String get proPayTierProSub =>
      'Pullik rejalar: Talaba Pro, Ustoz Pro, Mutaxassis Pro va Premium';

  @override
  String get proPayTierTeacher => 'Ustoz Pro';

  @override
  String get proPayTierTeacherSub =>
      'Ustoz uchun (ustoz paneli): test yaratish, talabalarni biriktirish, guruhlar va natijalarni boshqarish.';

  @override
  String get proPayFree =>
      'Bepul imkoniyatlar bepul qoladi va kunlik cheklovsiz ishlaydi. Sinov yoki obuna tugasa, faqat pullik imkoniyatlar yopiladi.';

  @override
  String get proPayFeatQuestions =>
      'Mavzular bo‘yicha mashq va kartadan mini-test';

  @override
  String get proPayFeatExam => 'Imtihon simulyatsiyasi (vaqtli test)';

  @override
  String get proPayFeatToifa =>
      'To‘liq savollar banki: rasmiy test va mavzular bo‘yicha mashq';

  @override
  String get proPayFeatWeak => 'Zaif mavzular tahlili natijada';

  @override
  String get proPayFeatAtlas => 'Mikroskopiya atlasi mashqlari';

  @override
  String get proPayFeatHistory => 'Natijalarning to‘liq tarixi';

  @override
  String get proPayFeatAllPro => 'Talaba Pro rejasidagi hamma imkoniyat';

  @override
  String get proPayFeatGroups =>
      'Guruhlar: talabalarni qo‘shish, baholar va natijalar hisoboti';

  @override
  String get proPayFeatAssignments => 'Guruh topshiriqlari (vaqtli testlar)';

  @override
  String get proPayFeatLecture =>
      'Ma’ruza rejimi: mavzu bo‘yicha avtomatik taqdimot';

  @override
  String get proPayFeatLabCount => 'Leykoformula: sanash va natijani saqlash';

  @override
  String get proPayFeatLabAbsolute => 'Leykoformula: foiz va mutlaq sonlar';

  @override
  String get proPayFeatLabEvaluate => 'Leykoformula: natijani baholash';

  @override
  String get proPayFeatLabSections =>
      'Laboratoriya bo‘limlari: sitologiya, spermogramma, qon guruhi, gistologiya, siydik tahlili, qon morfologiyasi, koprologiya';

  @override
  String get proPayFeatLabCoag => 'Koagulogramma';

  @override
  String get proPayFeatLabInstruments => 'Apparatlar katalogi';

  @override
  String get proPayFeatLabDirections => 'Laboratoriya yo‘nalishlari kartalari';

  @override
  String get proPayFeatLabCalibration => 'Kalibrlash va kalibrlash jurnali';

  @override
  String get proPayFeatLabQc => 'Sifat nazorati (QC)';

  @override
  String get proPayFeatLabCalculators => 'Laboratoriya kalkulyatorlari';

  @override
  String get proPayPlanMonthly => 'Oylik';

  @override
  String get proPayPlanYearly => 'Yillik';

  @override
  String get proPayUnitDay => 'kun';

  @override
  String get proPayUnitWeek => 'hafta';

  @override
  String get proPayUnitMonth => 'oy';

  @override
  String get proPayUnitYear => 'yil';

  @override
  String proPayDays(int count) {
    return '$count kun';
  }

  @override
  String proPayWeeks(int count) {
    return '$count hafta';
  }

  @override
  String proPayMonths(int count) {
    return '$count oy';
  }

  @override
  String proPayYears(int count) {
    return '$count yil';
  }

  @override
  String proPayPricePer(String price, String period) {
    return '$price / $period';
  }

  @override
  String proPayTrial(String trial, String price) {
    return '$trial bepul, keyin $price. Narx va yangilanish shartlari do‘kon oynasida ko‘rsatilganidek.';
  }

  @override
  String get proPayStartTrial => 'Bepul sinovni boshlash';

  @override
  String get proPaySubscribe => 'Obuna bo‘lish';

  @override
  String get proPayCurrent => 'Faol obuna';

  @override
  String get proPayRestore => 'Xaridni tiklash';

  @override
  String get proPayManage => 'Obunani boshqarish yoki bekor qilish';

  @override
  String get proPayTerms => 'Foydalanish shartlari (EULA)';

  @override
  String get proPayPrivacy => 'Maxfiylik siyosati';

  @override
  String proPayDisclosure(String store) {
    return 'Obuna avtomatik yangilanadi. Narx va davr xariddan oldin $store oynasida ko‘rsatiladi; pul faqat siz shu oynada o‘zingiz tasdiqlaganingizdan keyin yechiladi (do‘kon bepul sinov yoki boshlang‘ich taklif ko‘rsatsa — u tugagach, narx va yangilanish shartlari do‘kon oynasidagidek). To‘lov $store hisobingizdan olinadi. Joriy davr tugashidan kamida 24 soat oldin bekor qilinmasa, obuna xuddi shu davr va narxda yangilanadi va to‘lov davr tugashidan oldingi 24 soat ichida olinadi. Obunani $store hisob sozlamalarida boshqarish va bekor qilish mumkin; LabGuide hisobini o‘chirish obunani bekor qilmaydi. Qaytarish so‘rovlarini $store ko‘rib chiqadi.';
  }

  @override
  String get proPayGuestNote =>
      'Obuna, xaridni tiklash va bepul sinov uchun hisobga kiring. Ilovaning bepul qismi hisobsiz ham ishlayveradi.';

  @override
  String get proPaySignInRequired =>
      'Obuna bo‘lish va xaridni tiklash uchun avval hisobga kiring.';

  @override
  String get proPayLockedPro =>
      'Bu imkoniyat pullik rejalarda: Talaba Pro, Ustoz Pro, Mutaxassis Pro yoki Premium.';

  @override
  String get proPayLockedTeacher =>
      'Bu imkoniyat Ustoz Pro yoki Premium rejasida.';

  @override
  String get proPayLockedLab =>
      'Bu imkoniyat Mutaxassis Pro yoki Premium rejasida.';

  @override
  String get proPayAllOpen => 'Hozir barcha imkoniyatlar ochiq.';

  @override
  String get proPayTestBuildOpen =>
      'Sinov versiyasi: barcha imkoniyatlar ochiq.';

  @override
  String proPayStatusTeacher(String date) {
    return 'Ustoz Pro faol · $date gacha';
  }

  @override
  String get proPayStatusTeacherNoEnd => 'Ustoz Pro faol';

  @override
  String get proPayStatusDevice =>
      'Obuna shu qurilmada faol. Boshqa qurilmalarda ham ishlashi uchun hisobga kiring.';

  @override
  String get proPaySuccess => 'Obuna faollashdi. Rahmat!';

  @override
  String get proPayRestored => 'Xarid tiklandi.';

  @override
  String get proPayPending =>
      'To‘lov tasdiqlanishi kutilmoqda. Tasdiqlangach obuna avtomatik ochiladi.';

  @override
  String get proPayNothingFound => 'Tiklanadigan faol obuna topilmadi.';

  @override
  String get proPayOwnedByOther =>
      'Bu xarid boshqa LabGuide hisobiga bog‘langan. O‘sha hisob bilan kiring.';

  @override
  String get proPayFailed =>
      'Xarid yakunlanmadi. Internetni tekshirib, qayta urinib ko‘ring. Pul yechilgan bo‘lsa, «Xaridni tiklash» ni bosing.';

  @override
  String get proPayUnavailable =>
      'Do‘kon hozir javob bermayapti. Keyinroq urinib ko‘ring.';

  @override
  String proPayDeleteAccountNote(String store) {
    return 'Obuna hisob bilan birga bekor bo‘lmaydi: uni $store sozlamalarida bekor qiling.';
  }

  @override
  String get proRowTitle => 'Obuna va tiklash';

  @override
  String get proRowSub => 'Free · Pro · Premium';

  @override
  String get proPurchaseTitle => 'Pro va Premium rejalari';

  @override
  String get proStatusTitle => 'Holat';

  @override
  String proStatusPro(String date) {
    return 'Pro faol · $date gacha';
  }

  @override
  String get proStatusProNoEnd => 'Pro faol';

  @override
  String proStatusOffline(String date) {
    return 'Internetsiz: oxirgi tekshiruv $date';
  }

  @override
  String proHistoryHidden(int count, int limit) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Yana $count ta eski natija saqlangan',
    );
    return '$_temp0 — bepul rejimda oxirgi $limit tasi ko‘rinadi. Hech narsa o‘chirilmagan.';
  }

  @override
  String get proNothingGated =>
      'Hozircha pullik deb belgilangan imkoniyat yo‘q: hamma narsa ochiq.';

  @override
  String get proPlanStudent => 'Talaba Pro';

  @override
  String get proPlanTeacher => 'Ustoz Pro';

  @override
  String get proPlanSpecialist => 'Mutaxassis Pro';

  @override
  String get proPlanPremium => 'Premium';

  @override
  String get proPayTierStudent => 'Talaba Pro';

  @override
  String get proPayTierStudentSub =>
      'O‘qish uchun: ustoz bergan testlar, natijalar tarixi, imtihon simulyatsiyasi, PDF/CSV eksport va qo‘shimcha materiallar.';

  @override
  String get proPayTierSpecialist => 'Mutaxassis Pro';

  @override
  String get proPayTierSpecialistSub =>
      'Laboratoriya mutaxassisi uchun: professional laboratoriya funksiyalari.';

  @override
  String get proPayTierPremium => 'Premium';

  @override
  String get proPayTierPremiumSub =>
      'Hammasi birga: Talaba Pro, Ustoz Pro va Mutaxassis Pro imkoniyatlari.';

  @override
  String get proPayStatusAdminGrant => 'Pro administrator tomonidan berilgan';

  @override
  String proPayStatusAdminGrantUntil(String date) {
    return 'Pro administrator tomonidan berilgan · $date gacha';
  }

  @override
  String get proGrantRow => 'Pro berish';

  @override
  String get proGrantRowSub =>
      'Email manziliga Pro huquqini berish yoki bekor qilish';

  @override
  String get proGrantTitle => 'Pro berish';

  @override
  String get proGrantIntro =>
      'Email manziliga Pro huquqini bering. Hisob hali bo‘lmasa, hisob ochilganda yoki birinchi kirishda amalga oshadi. Do‘kon obunasi o‘zgarmaydi: ikkalasidan yuqorisi amal qiladi.';

  @override
  String get proGrantEmail => 'Email';

  @override
  String get proGrantTier => 'Daraja';

  @override
  String get proGrantDuration => 'Muddat';

  @override
  String get proGrantNote => 'Izoh (ixtiyoriy)';

  @override
  String proGrantDays(int count) {
    return '$count kun';
  }

  @override
  String get proGrantUntilRevoked => 'Bekor qilinguncha';

  @override
  String get proGrantExtend => 'Mavjud grantni uzaytirish (almashtirmasdan)';

  @override
  String get proGrantSubmit => 'Pro berish';

  @override
  String get proGrantConfirmTitle => 'Pro berilsinmi?';

  @override
  String proGrantConfirmBody(String email, String plan, String duration) {
    return '$email manziliga «$plan» rejasi beriladi. Muddat: $duration.';
  }

  @override
  String proGrantDone(String email) {
    return 'Pro berildi: $email';
  }

  @override
  String proGrantReplaced(String email) {
    return 'Mavjud grant almashtirildi: $email';
  }

  @override
  String proGrantExtended(String email) {
    return 'Grant uzaytirildi: $email';
  }

  @override
  String proGrantListTitle(int count) {
    return 'Faol va kutilayotgan ($count)';
  }

  @override
  String get proGrantEmpty => 'Hozircha grant yo‘q.';

  @override
  String get proGrantPending => 'Hisob kutilmoqda: kirgach boshlanadi';

  @override
  String proGrantUntil(String date) {
    return '$date gacha';
  }

  @override
  String get proGrantRevoke => 'Qaytarib olish';

  @override
  String get proGrantRevokeTitle => 'Grant qaytarib olinsinmi?';

  @override
  String proGrantRevokeBody(String email) {
    return '$email Pro huquqini darhol yo‘qotadi. Do‘kon obunasi (bo‘lsa) saqlanadi.';
  }

  @override
  String proGrantRevoked(String email) {
    return 'Qaytarib olindi: $email';
  }

  @override
  String get proGrantErrNote =>
      'Izoh 200 belgidan oshmasin va maxsus belgilarsiz bo‘lsin.';

  @override
  String get proGrantErrPending =>
      'Kutilayotgan grantni uzaytirib bo‘lmaydi: uni almashtiring.';

  @override
  String get proGrantErrDuration => 'Uzaytirish uchun muddat tanlang.';

  @override
  String get proGrantErrMany =>
      'Faol grantlar chegarasiga yetildi. Avval keraksizini bekor qiling.';

  @override
  String get proGrantErrTierMix =>
      'Bu darajalar bir-birini qamramaydi, shuning uchun uzaytirib bo‘lmaydi. Kerakli darajani tanlab, mavjud grantni almashtiring.';

  @override
  String get proSubTitle => 'Obuna';

  @override
  String get proSubRowSub => 'Rejalar, holatingiz va xaridni tiklash';

  @override
  String get proSubAllFree =>
      'Hozircha hamma imkoniyat bepul. Rejalar hali faol emas — hech narsa sotilmayapti.';

  @override
  String get proSubStatusTitle => 'Holatingiz';

  @override
  String get proSubStatusFree => 'Bepul';

  @override
  String proSubStatusTrial(String plan, String days) {
    return '$plan · bepul sinov: $days qoldi';
  }

  @override
  String proSubStatusPlan(String plan) {
    return '$plan rejasi faol';
  }

  @override
  String proSubStatusPlanUntil(String plan, String date) {
    return '$plan rejasi faol · $date gacha';
  }

  @override
  String proSubStatusAdmin(String plan) {
    return '$plan — administrator bergan';
  }

  @override
  String proSubStatusAdminUntil(String plan, String date) {
    return '$plan — administrator bergan · $date gacha';
  }

  @override
  String get proSubPlansTitle => 'Rejalar';

  @override
  String get proSubPriceNote =>
      'Narxlar do‘kondan olinadi va mahalliy valyutada ko‘rsatiladi. Aniq narx va davr xariddan oldin do‘kon oynasida ko‘rinadi.';

  @override
  String proSubUnlocks(String list) {
    return 'Kiradi: $list';
  }

  @override
  String get proSubCapLearner => 'Talaba Pro';

  @override
  String get proSubCapTeacherPanel => 'Ustoz Pro';

  @override
  String get proSubCapLab => 'Mutaxassis Pro';

  @override
  String get proSubNothingGated =>
      'Hozir bu reja hech narsani yopmaydi: hammasi bepul.';

  @override
  String get proSubTeacherNote =>
      'Ustoz paneli faqat Ustoz Pro yoki Premium rejasida, professional laboratoriya funksiyalari esa faqat Mutaxassis Pro yoki Premium rejasida bo‘ladi. Rolni o‘zgartirish ularni ochmaydi. Bugungi bepul imkoniyatlar bepul qoladi.';

  @override
  String proSubTrialTitle(int days) {
    return '$days kunlik bepul sinov';
  }

  @override
  String get proSubTrialOncePerPhone =>
      'Bir marta beriladi: bitta telefonga, hisobga va emailga bitta sinov. Boshqa hisob bilan ham, hisobni o‘chirib qayta ochganda ham qayta berilmaydi. Hisobga kirish va tasdiqlangan email kerak.';

  @override
  String get proSubTrialUsed => 'Bu hisob bepul sinovdan foydalangan.';

  @override
  String get proSubTrialNotActive => 'Bepul sinov hali yoqilmagan.';

  @override
  String get proSubTrialGuest => 'Bepul sinov uchun hisobga kiring.';

  @override
  String get proPrivacyTrialNote =>
      'Bepul sinov: 7 kunlik bepul sinov bir telefonga bir marta beriladi. Buning uchun serverda sinov sanalari, reja, platforma va emailingiz (kanonik ko‘rinishda) hamda qurilma belgisining faqat kalitli, qaytarib bo‘lmaydigan xeshi saqlanadi — xom email, qurilma identifikatori yoki attestatsiya tokeni saqlanmaydi. Hisob o‘chirilganda yozuv hisobdan uziladi, lekin sinov qayta berilmasligi uchun 24 oy saqlanadi, so‘ng avtomatik o‘chiriladi. Batafsil — Maxfiylik siyosatida.';

  @override
  String proSubTrialBody(int days) {
    return 'Tanlangan rejaning pullik imkoniyatlarini $days kun bepul sinab ko‘rasiz. Bir marta beriladi; karta yoki to‘lov usuli kerak emas, pul yechilmaydi, o‘zi pullik obunaga aylanmaydi. Tugagach faqat pullik imkoniyatlar yopiladi; bepul imkoniyatlar va ma’lumotlaringiz qoladi.';
  }

  @override
  String proSubTrialStart(String plan) {
    return 'Bepul sinovni boshlash: $plan';
  }

  @override
  String get proSubTrialConfirmTitle => 'Bepul sinov boshlansinmi?';

  @override
  String proSubTrialConfirmBody(String plan, String date) {
    return '$plan: pullik imkoniyatlar $date gacha bepul. Bir marta beriladi, to‘lov usuli yo‘q, pul yechilmaydi va sinov pullik obunaga aylanmaydi. Shu sanadan keyin faqat pullik imkoniyatlar yopiladi; bepul imkoniyatlar va ma’lumotlaringiz qoladi.';
  }

  @override
  String get proSubTrialConfirm => 'Sinovni boshlash';

  @override
  String get proSubTrialCancel => 'Hozir emas';

  @override
  String proSubTrialStarted(String date) {
    return 'Bepul sinov boshlandi — pullik imkoniyatlar $date gacha ochiq.';
  }

  @override
  String get proSubTrialNotOnPlatform =>
      'Bu qurilmada bepul sinov hozircha mavjud emas. Barcha bepul imkoniyatlar odatdagidek ishlaydi.';

  @override
  String get proSubTrialHasAccess =>
      'Sizda pullik reja allaqachon bor, sinov kerak emas.';

  @override
  String get proSubTrialPlanNotAllowed =>
      'Ustoz Pro sinovi — serverda ustoz sifatida ro‘yxatdan o‘tganlar uchun, Mutaxassis Pro sinovi — tasdiqlangan mutaxassislar uchun, Premium sinovi — ikkalasi ham bo‘lganlar uchun. Talaba Pro sinovini sinab ko‘ring.';

  @override
  String get proSubTrialEmail =>
      'Sinov uchun hisobingizning tasdiqlangan emaili kerak.';

  @override
  String get proSubTrialDevice =>
      'Bu qurilmani tasdiqlab bo‘lmadi, shuning uchun sinov bu yerda boshlanmaydi.';

  @override
  String get proSubTrialSubscribed => 'Sizda amaldagi obuna bor.';

  @override
  String get proSubEnded =>
      'Pullik reja muddati tugadi: faqat pullik imkoniyatlar yopildi. Bepul imkoniyatlar ishlashda davom etadi va ma’lumotlaringiz saqlanadi.';

  @override
  String get proSubPriceYearlyNote =>
      'Yillik reja narxi yiliga bir marta, ko‘rsatilgan summada olinadi.';

  @override
  String get proSubWithoutSubscription =>
      'Ilovadan obunasiz foydalanish mumkin: bepul imkoniyatlar bepul qoladi.';

  @override
  String get proGrantCustom => 'Boshqa muddat (son)';

  @override
  String get proGrantUnitDays => 'kun';

  @override
  String get proGrantUnitMonths => 'oy (30 kun)';

  @override
  String proGrantErrRange(int max) {
    return 'Muddat 1 dan $max kungacha bo‘lishi kerak (1 oy = 30 kun).';
  }

  @override
  String get proPayGuestBuyNote =>
      'Talaba Pro va Mutaxassis Pro rejalarini hisobsiz sotib olish va tiklash mumkin. Ustoz Pro va Premium ustoz panelini o‘z ichiga oladi — ular uchun hisobga kirish kerak. Keyinroq hisobga kirsangiz, xarid hisobingizga o‘tadi.';

  @override
  String get proPayGuestAccountOnly =>
      'Bu reja ustoz panelini o‘z ichiga oladi — obuna uchun hisobga kiring.';

  @override
  String get proPayGuestLinked =>
      'Bu xarid LabGuide hisobiga bog‘langan. Undan foydalanish uchun o‘sha hisobga kiring.';

  @override
  String proPayIntroPrice(String intro, String length, String price) {
    return '$length — $intro, keyin $price';
  }

  @override
  String get proPayStoreOfferNote =>
      'Bu App Store / Google Play taklifi — LabGuide bepul sinovidan alohida. Taklifga kim haqli ekanini do‘kon hal qiladi; bekor qilinmasa obuna avtomatik yangilanadi.';

  @override
  String proSubWillNotRenew(String date) {
    return 'Avtomatik yangilash o‘chirilgan: $date gacha amal qiladi, keyin reja tugaydi.';
  }

  @override
  String get proSubStoreTrial =>
      'Do‘kon sinov davri — bekor qilinmasa, obuna do‘kon narxida avtomatik yangilanadi.';

  @override
  String proSubWillChange(String plan) {
    return 'Keyingi yangilanishdan: $plan rejasi.';
  }

  @override
  String get proPayCancelPathApple =>
      'iPhone va iPad’da: Sozlamalar → ismingiz → Obunalar → LabGuide → Obunani bekor qilish.';

  @override
  String get proPayCancelPathGoogle =>
      'Android’da: Google Play → profil belgisi → To‘lovlar va obunalar → Obunalar → LabGuide → Obunani bekor qilish.';

  @override
  String proPayStoreTrialNote(String store) {
    return 'Do‘konda bepul sinov yoki boshlang‘ich taklif ko‘rsatilsa, uning muddati, keyingi narx va yangilanish shartlari $store oynasida ko‘rsatilganidek bo‘ladi: tasdiqlashdan oldin o‘qing. Bu ilovadagi bepul sinovdan alohida.';
  }

  @override
  String proPayRefundNote(String store) {
    return 'To‘lovni qaytarish so‘rovlarini $store o‘z qoidalariga ko‘ra ko‘rib chiqadi: so‘rovni $store hisobingiz orqali yuboring. LabGuide bank kartangiz ma’lumotini ko‘rmaydi.';
  }

  @override
  String proPayRefundedStatus(String store) {
    return 'Xarid $store tomonidan qaytarilgan yoki bekor qilingan: pullik imkoniyatlar yopildi. Bepul imkoniyatlar va ma’lumotlaringiz saqlanadi.';
  }

  @override
  String proPayCancelledUntil(String date) {
    return 'Obuna bekor qilingan: pullik imkoniyatlar $date gacha ishlaydi, shundan keyin faqat pullik qism yopiladi.';
  }

  @override
  String proPayGraceNote(String store) {
    return 'To‘lovda muammo bor. Pullik imkoniyatlar hozircha saqlanmoqda: $store da to‘lov usulini yangilang.';
  }

  @override
  String get proPayOfflineNote =>
      'Internet yo‘q: oxirgi tekshirilgan holat ko‘rsatilmoqda. Pullik imkoniyatlar cheklangan muddat ishlaydi va ulanishdan keyin yangilanadi; bepul qism odatdagidek ishlaydi.';

  @override
  String get proPayOfflineAction =>
      'Internet yo‘q. Xarid yoki tiklash uchun ulanishni tekshirib, qayta urinib ko‘ring.';

  @override
  String get proPayAgreeNote =>
      'Obuna bo‘lish yoki sinovni boshlash orqali Foydalanish shartlari va Maxfiylik siyosatini qabul qilasiz (havolalar quyida).';

  @override
  String get proPayFeatAssignedTests => 'Ustoz bergan testlar';

  @override
  String get proPayFeatExport =>
      'Natijalarni PDF va CSV ko‘rinishida yuklab olish';

  @override
  String get proPayFeatMaterials => 'Qo‘shimcha materiallar';

  @override
  String get proPayFeatCreateTests => 'Test yaratish va talabalarga berish';

  @override
  String get proPayFeatAttachStudents => 'Talabalarni biriktirish';

  @override
  String get proPayFeatManageResults => 'Natijalarni boshqarish';

  @override
  String get proPayFeatProLab => 'Professional laboratoriya funksiyalari';

  @override
  String get proTermsBody =>
      'LabGuide — klinik laboratoriya bo‘yicha ma’lumotnoma va o‘quv ilovasi. Asosiy imkoniyatlar bepul; pullik rejalar (Talaba Pro, Ustoz Pro, Mutaxassis Pro, Premium) qo‘shimcha imkoniyatlar beradi. Ilovadan foydalanib, siz quyidagi shartlarga rozilik bildirasiz.\n\n1. Tibbiy cheklov. LabGuide tashxis qo‘ymaydi, davolash yoki dori buyurmaydi va laboratoriyangizning tasdiqlangan tartiblari, reagent va analizator yo‘riqnomalari (IFU) hamda shifokor xulosasini almashtirmaydi. Har bir ma’lumot ostida manbasi ko‘rsatilgan; qaror qabul qilishda asl manba va o‘z muassasangiz qoidalariga tayaning.\n\n2. Hisob. Ba’zi imkoniyatlar (guruhlar, testlar, hamjamiyat, murojaatlar, pullik rejalar va bepul sinov) uchun email orqali ro‘yxatdan o‘tish kerak. Hisobingiz xavfsizligi va u orqali qilingan harakatlar uchun o‘zingiz javobgarsiz. Hisobni istalgan vaqtda Profil → Hisobni o‘chirish orqali o‘chirishingiz mumkin; bu do‘kon obunasini bekor qilmaydi.\n\n3. Ustoz va talaba guruhlari. Talaba guruhga qo‘shilganda ustoz uning taxallusi (yoki tartib raqami) va test natijalarini ko‘radi. Ustoz guruhni faqat o‘quv maqsadida boshqaradi.\n\n4. Foydalanuvchi kontenti. Hamjamiyatda va murojaatlarda yozganlaringiz uchun o‘zingiz javobgarsiz. Haqoratli, noqonuniy, reklama, boshqa shaxsning shaxsiy ma’lumoti yoki roziligisiz intim tasvirlar joylash qat’iyan taqiqlanadi. Bunday kontent o‘chiriladi, qoidabuzar hisobi cheklanishi yoki o‘chirilishi mumkin. Har bir xabarni “Shikoyat” orqali bildirishingiz mumkin.\n\n5. Pullik rejalar va bepul sinov. Pullik rejalar Apple App Store yoki Google Play orqali avtomatik yangilanuvchi obuna sifatida sotiladi. Narx va davr xariddan oldin do‘kon oynasida ko‘rsatiladi; pul faqat siz shu oynada tasdiqlaganingizdan keyin yechiladi. Obunani do‘kon sozlamalarida istalgan vaqtda bekor qilish mumkin; qaytarish so‘rovlarini do‘kon ko‘rib chiqadi. 7 kunlik bepul sinov bir marta beriladi va karta talab qilmaydi. Sinov yoki obuna tugagach faqat pullik imkoniyatlar yopiladi; bepul imkoniyatlar va ma’lumotlaringiz qoladi.\n\n6. Mualliflik huquqi. Ilova matnlari, slaydlari, testlari va dizayni LabGuide mualliflariga tegishli; tashqi manbalar o‘z litsenziyasi bilan ko‘rsatilgan. Ularni tijorat maqsadida nusxalash va tarqatish mumkin emas.\n\n7. Xizmat. Ilova “boricha” taqdim etiladi; uzilishlar va xatolar bo‘lishi mumkin, biz ularni imkon qadar tez tuzatamiz. Shartlar o‘zgarsa, ilovada xabar beramiz.\n\n8. Maxfiylik. Ma’lumotlaringiz qanday ishlatilishi maxfiylik siyosatida yozilgan: labguide.nfcstore.uz/privacy. Shartlarning to‘liq matni: labguide.nfcstore.uz/terms\n\n9. Aloqa: labguide@nfcstore.uz';

  @override
  String get proPrivacyBody =>
      'Asosiy bo‘limlar hisobsiz (mehmon rejimida) ishlaydi: sozlamalar, xatcho‘plar, QC qaydlari, apparatlaringiz va mashq natijalari shu qurilmada saqlanadi. Hisob ixtiyoriy (email kodi, Google yoki Apple bilan) — guruhlar, hamjamiyat, “Taklif va yordam”, pullik rejalar va bepul sinov uchun kerak. Bunda ma’lumotlar Cloudflare serverida (Sharqiy Yevropa, O‘zbekistondan tashqarida) saqlanadi: email faqat hash va niqoblangan ko‘rinishda, kirish usuli, rol, til, oxirgi faollik vaqti (daqiqagacha); guruhda — taxallus yoki tartib raqami, test javoblari va ballar; murojaat va shikoyat matnlari. Google/Apple’dan faqat hisob identifikatori va email olinadi, token saqlanmaydi. Ustoz faqat o‘z guruhini ko‘radi. Obuna to‘lovini Apple yoki Google qayta oladi: bank kartangiz ma’lumotini LabGuide ko‘rmaydi; serverimiz do‘kon tranzaksiya identifikatorlarini tekshiradi. Bepul sinov uchun sanalar va faqat kalitli xeshlar (email va qurilma belgisidan) saqlanadi. Reklama, analitika va kuzatuv yo‘q. To‘liq matn — “Maxfiylik siyosati” havolasida.';

  @override
  String get proAccountDeleteBody =>
      'Hisobingiz, kirish usullari (Google/Apple bog‘lanishi), guruhlardagi a’zolik va natijalaringiz, “Taklif va yordam” murojaatlari, hamjamiyatdagi savol-javoblaringiz va xaridlarga bog‘langan yozuvlar serverdan butunlay o‘chiriladi. Ustoz bo‘lsangiz, yaratgan guruhlaringiz ham o‘chadi. Buni qaytarib bo‘lmaydi. Do‘kon obunasi bekor bo‘lmaydi: uni App Store yoki Google Play sozlamalarida bekor qiling. Bepul sinovni qayta olishning oldini olish uchun sinov yozuvi hisobdan uzilgan holda cheklangan muddat saqlanadi. Ilova ichida yuborgan shikoyatlar matni hisobga bog‘lanmagan holda qoladi. Qurilmadagi ma’lumotlar ham tozalanadi.';

  @override
  String get proTierNameStudent => 'Talaba Pro';

  @override
  String get proTierNameTeacher => 'Ustoz Pro';

  @override
  String get proTierNameSpecialist => 'Mutaxassis Pro';

  @override
  String get proTierNamePremium => 'Premium';

  @override
  String get proTierSubStudent =>
      'O‘qish uchun qo‘shimcha Pro imkoniyatlari. Bugun bepul bo‘lgan hamma narsa bepul qoladi.';

  @override
  String get proTierSubTeacher =>
      'Ustoz uchun: Talaba Pro imkoniyatlari va ustoz panelining Pro imkoniyatlari. Bugungi bepul guruhlar bepul qoladi.';

  @override
  String get proTierSubSpecialist =>
      'Laborant va shifokor uchun: Talaba Pro imkoniyatlari va professional laboratoriya funksiyalari. Laboratoriya bo‘limi bepul qoladi.';

  @override
  String get proTierSubPremium =>
      'Hamma Pro imkoniyat birga: Talaba Pro, Ustoz Pro va Mutaxassis Pro.';

  @override
  String get proCapLabPro =>
      'professional laboratoriya funksiyalari (kalibrlash jurnali va QC eksporti, QC xulosa hisoboti)';

  @override
  String get proTierNote =>
      'Ustoz panelining Pro imkoniyatlari faqat Ustoz Pro yoki Premium rejasida, professional laboratoriya funksiyalari esa faqat Mutaxassis Pro yoki Premium rejasida bo‘ladi. Ilovada rolni o‘zgartirish ularni ochmaydi. Bugun bepul bo‘lgan hamma narsa — Laboratoriya bo‘limi, atlas, testlar, bilim va malakani baholash, guruhlar va topshiriqlar — bepul qoladi.';

  @override
  String get proLockedLearner =>
      'Bu imkoniyat Talaba Pro, Ustoz Pro, Mutaxassis Pro va Premium rejalarida.';

  @override
  String get proLockedTeacher =>
      'Bu imkoniyat Ustoz Pro yoki Premium rejasida.';

  @override
  String get proLockedLab =>
      'Bu imkoniyat Mutaxassis Pro yoki Premium rejasida.';

  @override
  String get proFeatResultsAnalytics =>
      'Natijalar tahlili: to‘liq tarix, mavzular bo‘yicha trend va zaif mavzular';

  @override
  String get proFeatExamSimulation =>
      'Imtihon simulyatsiyasi: imtihon sharoitida test va batafsil hisobot';

  @override
  String get proFeatResultsExport =>
      'Natijalarni PDF va CSV fayl sifatida eksport qilish';

  @override
  String get proFeatTeacherTests => 'Ustoz yaratgan maxsus testlarni yechish';

  @override
  String get proFeatTeacherTestBuilder =>
      'O‘z testingizni yaratish va tahrirlash';

  @override
  String get proFeatTeacherTestAssign =>
      'Testga talabalar va guruhlarni biriktirish';

  @override
  String get proFeatTeacherResults =>
      'Natijalarni boshqarish: talaba va savol kesimida jamlanma, eksport';

  @override
  String get proFeatCalibrationExport =>
      'Kalibrlash jurnalini CSV va PDF ga eksport qilish';

  @override
  String get proFeatQcReport =>
      'QC xulosa hisoboti va QC ma’lumotini CSV/PDF fayl sifatida eksport qilish';

  @override
  String proTrialConfirmBody(String plan, String date) {
    return '$plan $date gacha bepul. To‘lov usuli yo‘q, pul yechilmaydi va sinov pullik obunaga aylanmaydi. Sinov tugagach faqat pullik imkoniyatlar yopiladi; bepul imkoniyatlar va barcha ma’lumotlaringiz saqlanadi.';
  }

  @override
  String get proGateClosedTitle => 'Bu Pro imkoniyat';

  @override
  String get proGateClosedBody =>
      'Ochish uchun obuna yoki 7 kunlik bepul sinov kerak. Bepul imkoniyatlar va ma’lumotlaringiz saqlanadi.';

  @override
  String get proGateOpenPlans => 'Rejalarni ko‘rish';

  @override
  String get proExportAction => 'Eksport: PDF yoki CSV';

  @override
  String get proExportTitle => 'Faylga eksport';

  @override
  String get proExportPdf => 'PDF hujjat';

  @override
  String get proExportPdfSub => 'Ko‘rish, chop etish va arxiv uchun';

  @override
  String get proExportCsv => 'CSV jadval';

  @override
  String get proExportCsvSub => 'Excel yoki Google Sheets uchun';

  @override
  String get proExportBusy => 'Fayl tayyorlanmoqda…';

  @override
  String get proExportShared => 'Fayl tayyor — ulashish oynasi ochildi.';

  @override
  String get proExportFailed =>
      'Faylni ulashib bo‘lmadi. Qayta urinib ko‘ring.';

  @override
  String get proExportNotClinical =>
      'Faqat siz kiritgan ma’lumotlardan tuzilgan. Klinik qaror emas va laboratoriyaning rasmiy hujjati o‘rnini bosmaydi.';

  @override
  String proExportCreated(String date) {
    return 'Yaratildi: $date';
  }

  @override
  String proExportPage(int page, int total) {
    return '$page / $total';
  }

  @override
  String proCalExportCount(int count) {
    return 'Yozuvlar: $count';
  }

  @override
  String get proCalExportEntry => 'Jurnalni eksport qilish';

  @override
  String get proCalExportEntrySub =>
      'PDF yoki CSV: apparat, reagent, lot, darajalar, natija, tasdiqlagan va tarix';

  @override
  String get proColDate => 'Sana';

  @override
  String get proColAction => 'Amal';

  @override
  String get proColDetail => 'Tafsilot';

  @override
  String get proColStatus => 'Holat';

  @override
  String get proQcReportTitle => 'QC xulosa hisoboti';

  @override
  String get proQcReportEntrySub =>
      'Har daraja va lot bo‘yicha x̄, SD, CV, maqsaddan farq va ishlagan qoidalar; PDF / CSV';

  @override
  String get proQcSummary => 'Umumiy';

  @override
  String get proQcPeriodLabel => 'Davr';

  @override
  String get proQcVerdictsLabel => 'Qabul / ogohlantirish / rad';

  @override
  String get proQcVerdictsHint =>
      'Daraja kartasidagi xulosalar — shu daraja ishtirok etgan qoidalar bo‘yicha; umumiy hisob — butun seriya bo‘yicha.';

  @override
  String get proQcRulesFired => 'Ishlagan qoidalar';

  @override
  String get proQcNoRules => 'Qoida buzilmagan';

  @override
  String get proQcByLevel => 'Darajalar va lotlar bo‘yicha';

  @override
  String get proQcColLevel => 'Daraja';

  @override
  String get proQcColTarget => 'Maqsad (x̄ ± SD)';

  @override
  String get proQcColObserved => 'Kuzatilgan (n, x̄ ± SD)';

  @override
  String get proQcColBias => 'Maqsaddan farq';

  @override
  String get proQcNoRuns =>
      'Hali seriya kiritilmagan — hisobot uchun ma’lumot yo‘q.';

  @override
  String get proSimTitle => 'Imtihon simulyatsiyasi';

  @override
  String get proSimSubtitle =>
      'Imtihon sharoitida test: vaqt va o‘tish chegarasi bilan, batafsil hisobot';

  @override
  String get proSimEntrySub =>
      'Vaqt va o‘tish chegarasi majburiy, savollar ketma-ket, har savol vaqti hisobotda';

  @override
  String get proSimConditions => 'Imtihon sharoiti';

  @override
  String get proSimRule1 =>
      'Vaqt chegarasi majburiy: vaqt tugasa test o‘zi yakunlanadi.';

  @override
  String get proSimRule2 =>
      'Savollar barcha mavzulardan, mavzu hajmiga mutanosib tanlanadi.';

  @override
  String get proSimRule3 =>
      'Savollar ketma-ket: oldingi savolga qaytish va belgilash yo‘q.';

  @override
  String get proSimRule4 =>
      'Natija o‘tish chegarasi bilan baholanadi; hisobotda har savolga sarflangan vaqt va mavzular tahlili bor.';

  @override
  String get proSimBank => 'Savollar banki';

  @override
  String get proSimBankPack => 'Mavzular bo‘yicha savollar';

  @override
  String proSimPool(int count, int topics) {
    return 'Bankda $count ta savol, $topics ta mavzu';
  }

  @override
  String get proSimTimeHelper => '1–240 daqiqa, majburiy';

  @override
  String get proSimPassHelper => '1–100 %, majburiy';

  @override
  String get proSimStart => 'Simulyatsiyani boshlash';

  @override
  String get proSimHistory => 'Oldingi simulyatsiyalar';

  @override
  String get proSimReportTitle => 'Simulyatsiya hisoboti';

  @override
  String get proSimPace => 'Vaqt';

  @override
  String get proSimAvgPerQuestion => 'Bir savolga o‘rtacha';

  @override
  String get proSimSlowest => 'Eng ko‘p vaqt olgan savollar';

  @override
  String get proSimReview => 'Javoblarni ko‘rish';

  @override
  String get proSimTag => 'simulyatsiya';

  @override
  String get proResultsTitle => 'Natijalar tahlili';

  @override
  String get proResultsSubtitle =>
      'Barcha testlar bo‘yicha to‘liq tarix, trend va zaif mavzular';

  @override
  String get proResultsEntrySub =>
      'Barcha banklar bo‘yicha trend, mavzular va zaif joylar; PDF / CSV eksport';

  @override
  String get proResultsEmpty =>
      'Hali natija yo‘q — birinchi testni topshiring.';

  @override
  String get proResultsBankOther => 'Boshqa testlar';

  @override
  String get proResultsSessions => 'Testlar';

  @override
  String get proResultsAverage => 'O‘rtacha';

  @override
  String get proResultsBest => 'Eng yaxshi';

  @override
  String get proResultsLast => 'Oxirgisi';

  @override
  String get proResultsTrend => 'O‘zgarish';

  @override
  String get proResultsAnswered => 'To‘g‘ri javoblar';

  @override
  String get proResultsChart => 'So‘nggi 20 ta natija';

  @override
  String get proResultsWeak => 'Zaif mavzular';

  @override
  String get proResultsNoWeak => 'Zaif mavzu topilmadi.';

  @override
  String get proResultsWeakRule =>
      'Zaif mavzu: kamida 5 ta savol va 60 % dan past aniqlik. O‘zgarish — mavzu uchragan testlarning yangi yarmi eski yarmiga nisbatan.';

  @override
  String get proResultsTopics => 'Mavzular bo‘yicha';

  @override
  String get proResultsNoTopics => 'Bu testlarda mavzu belgisi yo‘q.';

  @override
  String proResultsTopicRow(int correct, int total, int sessions) {
    return '$correct/$total to‘g‘ri · $sessions ta testda';
  }

  @override
  String get proResultsHistory => 'To‘liq tarix';

  @override
  String get proResultsQuestions => 'Savollar';

  @override
  String get proResultsSession => 'Test';

  @override
  String proPoints(String value) {
    return '$value foiz punkti';
  }

  @override
  String get ttEntrySection => 'Ustoz testlari';

  @override
  String get ttEntryTeacher => 'Mening testlarim';

  @override
  String get proTtEntryTeacherSub =>
      'Ustoz Pro: o‘z testlaringiz, topshiriqlar va natijalar';

  @override
  String get ttEntryStudent => 'Ustoz testlari';

  @override
  String get ttEntryStudentSub => 'Ustozingiz bergan maxsus testlar';

  @override
  String get ttEntryInvite => 'Taklifnoma kodi';

  @override
  String get ttEntryInviteSub =>
      'Ustoz bergan 12 belgili kod bilan guruhga qo‘shilish';

  @override
  String get ttTestsTitle => 'Mening testlarim';

  @override
  String get ttNewTest => 'Yangi test';

  @override
  String get ttTestsEmpty => 'Hali test yo‘q';

  @override
  String get ttTestsEmptyBody =>
      'O‘z savollaringizdan yoki ilovadagi savollar nusxasidan test tuzing.';

  @override
  String get ttStatusPublished => 'Nashr etilgan';

  @override
  String get ttStatusUnpublished => 'Nashr etilmagan';

  @override
  String ttQuestionsCount(int count) {
    return '$count ta savol';
  }

  @override
  String ttAssignedCount(int count) {
    return '$count ta topshiriq';
  }

  @override
  String get proTtLockedNote =>
      'Test yaratish, tahrirlash va topshirish — Ustoz Pro rejasida. Avval yaratilgan testlar va natijalar ko‘rinib turadi.';

  @override
  String get ttOfflineCached =>
      'Internet yo‘q — oxirgi saqlangan nusxa ko‘rsatilmoqda.';

  @override
  String get ttEdit => 'Tahrirlash';

  @override
  String get ttAssign => 'Topshirish';

  @override
  String get ttDeleteTest => 'Testni o‘chirish';

  @override
  String get ttDeleteTestBody =>
      'Test, uning topshiriqlari va natijalari o‘chiriladi. Buni qaytarib bo‘lmaydi.';

  @override
  String get ttAssignmentsTitle => 'Topshiriqlar';

  @override
  String get ttNoAssignments => 'Bu test hali topshirilmagan.';

  @override
  String ttDueOn(String date) {
    return 'muddat $date';
  }

  @override
  String ttSubmittedOf(int done, int total) {
    return '$done/$total topshirdi';
  }

  @override
  String get ttClosed => 'Yopilgan';

  @override
  String ttTimeLimit(int minutes) {
    return 'Vaqt: $minutes daqiqa';
  }

  @override
  String get ttNoTimeLimit => 'Vaqt cheklanmagan';

  @override
  String ttPassMark(int percent) {
    return 'O‘tish chegarasi: $percent%';
  }

  @override
  String get ttMustPublish =>
      'Talabalarga topshirish uchun testni nashr eting.';

  @override
  String get ttQuestionsTitle => 'Savollar';

  @override
  String ttQuestionNumber(int n) {
    return '$n-savol';
  }

  @override
  String get ttCorrectAnswer => 'To‘g‘ri javob';

  @override
  String ttFromBank(String bank) {
    return 'Ilovadan nusxa: $bank';
  }

  @override
  String get ttSourceQuiz => 'Mashq savollari';

  @override
  String get ttSourceToifa => 'Baholash banki';

  @override
  String get ttSourceDeck => 'Mavzu testi';

  @override
  String get ttEditTitleNew => 'Yangi test';

  @override
  String get ttEditTitle => 'Testni tahrirlash';

  @override
  String get ttFieldTitle => 'Test nomi';

  @override
  String get ttFieldDescription => 'Izoh (ixtiyoriy)';

  @override
  String get ttFieldTimeLimit => 'Vaqt chegarasi, daqiqa (ixtiyoriy, 1–180)';

  @override
  String get ttFieldPassPercent => 'O‘tish chegarasi, % (ixtiyoriy, 1–100)';

  @override
  String get ttPublishToggle => 'Nashr etilgan';

  @override
  String get ttPublishNote =>
      'Faqat nashr etilgan testni topshirish mumkin. Berilgan topshiriqlar savollarning o‘z nusxasini saqlaydi.';

  @override
  String get ttNoQuestionsYet =>
      'Hali savol yo‘q. O‘zingiz yozing yoki ilovadagi savollardan nusxa oling.';

  @override
  String get ttAddQuestion => 'Savol qo‘shish';

  @override
  String get ttAddFromBank => 'Ilovadagi savollardan';

  @override
  String get ttMoveUp => 'Yuqoriga';

  @override
  String get ttMoveDown => 'Pastga';

  @override
  String get ttRemoveQuestion => 'Savolni olib tashlash';

  @override
  String get ttSave => 'Saqlash';

  @override
  String get ttSaved => 'Saqlandi';

  @override
  String get ttVersionConflict =>
      'Test boshqa qurilmada o‘zgartirilgan. Qayta oching va tahrirni takrorlang.';

  @override
  String get ttErrTitle => 'Nom 3–120 belgi bo‘lsin.';

  @override
  String get ttErrDescription => 'Izoh juda uzun (1000 belgigacha).';

  @override
  String get ttErrNoQuestions => 'Nashr etish uchun kamida bitta savol kerak.';

  @override
  String get ttErrTimeLimit => 'Vaqt: 1–180 daqiqa.';

  @override
  String get ttErrPassPercent => 'O‘tish chegarasi: 1–100%.';

  @override
  String get ttErrQuestionText => 'Savol matnini yozing (1000 belgigacha).';

  @override
  String get ttErrOptions =>
      '2–6 ta variantni to‘ldiring (har biri 300 belgigacha).';

  @override
  String get ttErrDuplicateOptions => 'Variantlar takrorlanmasin.';

  @override
  String get ttErrCorrect => 'To‘g‘ri variantni belgilang.';

  @override
  String get ttErrQuestionGeneric =>
      'Savollarni tekshiring: matn, 2–6 ta har xil variant va bitta to‘g‘ri javob.';

  @override
  String ttErrQuestionAt(int n, String error) {
    return '$n-savol: $error';
  }

  @override
  String get ttErrAbusive => 'Matnda nojo‘ya so‘z bor — boshqacha yozing.';

  @override
  String get ttErrLimitTests =>
      '200 ta test chegarasiga yetdingiz. Yangisi uchun eskilarini o‘chiring.';

  @override
  String get ttErrPlan => 'Bu amal uchun shu imkoniyat bor reja kerak.';

  @override
  String get ttErrTeacherRole =>
      'Avval ustoz sifatida ro‘yxatdan o‘ting: “Guruhlar” bo‘limida guruh oching.';

  @override
  String get ttFieldQuestion => 'Savol matni';

  @override
  String get ttOptionsHint => 'To‘g‘ri variant yonidagi doirachani bosing.';

  @override
  String ttFieldOption(int n) {
    return '$n-variant';
  }

  @override
  String get ttMarkCorrect => 'To‘g‘ri javob deb belgilash';

  @override
  String get ttRemoveOption => 'Variantni olib tashlash';

  @override
  String get ttAddOption => 'Variant qo‘shish';

  @override
  String get ttFieldExplanation =>
      'Izoh (ixtiyoriy, natija bilan ko‘rsatiladi)';

  @override
  String get ttDone => 'Tayyor';

  @override
  String get ttBankTitle => 'Ilovadagi savollar';

  @override
  String get ttBankSubtitle =>
      'Tanlangan savollar testga nusxa sifatida qo‘shiladi; manbasi saqlanadi.';

  @override
  String get ttBankSearch => 'Qidirish';

  @override
  String get ttBankAll => 'Hammasi';

  @override
  String ttBankAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ta savolni qo‘shish',
      zero: 'Savollarni tanlang',
    );
    return '$_temp0';
  }

  @override
  String get ttBankEmpty => 'Savol topilmadi';

  @override
  String ttBankRefine(int count) {
    return '$count tadan birinchi 100 tasi ko‘rsatilmoqda. Qidiruvni aniqlashtiring.';
  }

  @override
  String get ttAssignTitle => 'Testni topshirish';

  @override
  String get ttAssignGroup => 'Guruh';

  @override
  String get ttAssignWho => 'Kimga';

  @override
  String get ttAssignWholeGroup => 'Butun guruhga';

  @override
  String get ttAssignNoGroups =>
      'Avval guruh yarating — talabalar unga kod yoki taklifnoma bilan qo‘shiladi.';

  @override
  String get ttAssignNoStudents =>
      'Guruhda hali talaba yo‘q. Keyin qo‘shilganlar ham testni ko‘radi.';

  @override
  String get ttAssignDue => 'Muddat';

  @override
  String get ttAssignAttempts => 'Urinishlar';

  @override
  String get ttAssignLate =>
      'Muddatdan keyin ham qabul qilish (“kechikkan” deb belgilanadi)';

  @override
  String get ttAssignPrivacy =>
      'Faqat guruhga o‘zi qo‘shilgan talabalar natijasini ko‘rasiz. Talabalarga natija sizga ko‘rinishi haqida ogohlantirish ko‘rsatiladi.';

  @override
  String get ttAssignSubmit => 'Topshirish';

  @override
  String get ttAssigned => 'Test topshirildi';

  @override
  String get ttErrDue => 'Kelajakdagi muddatni tanlang (bir yilgacha).';

  @override
  String get ttErrMemberGone => 'Bu talaba endi guruhda emas.';

  @override
  String get ttErrLimitAssignments =>
      'Faol topshiriqlar juda ko‘p. Avval eskilarini yoping.';

  @override
  String get ttInvitesTitle => 'Taklifnomalar';

  @override
  String get ttInvitesSubtitle =>
      'Talaba kodni kiritadi, sizga nima ko‘rinishini o‘qiydi va rozilik beradi.';

  @override
  String get ttInviteDays => 'Amal qilish muddati';

  @override
  String get ttInviteMaxUses => 'Necha kishi qo‘shila oladi';

  @override
  String get ttInviteCreate => 'Taklifnoma yaratish';

  @override
  String get ttInviteHowTo =>
      'Kodni talabalarga yuboring. Ilovada: Guruhlar → Taklifnoma kodi. Qo‘shilish faqat talaba rozilik bergach bo‘ladi.';

  @override
  String get ttInvitesActive => 'Faol taklifnomalar';

  @override
  String get ttInvitesEmpty => 'Faol taklifnoma yo‘q';

  @override
  String ttInviteUses(int uses, int max) {
    return '$uses/$max marta ishlatildi';
  }

  @override
  String ttInviteUntil(String date) {
    return '$date gacha';
  }

  @override
  String get ttInviteCopy => 'Taklifnomadan nusxa olish';

  @override
  String get ttInviteCopied => 'Taklifnoma nusxalandi';

  @override
  String ttInviteShareText(String group, String code, String link) {
    return 'LabGuide: “$group” guruhiga taklifnoma. Ilovada Guruhlar → Taklifnoma kodi bo‘limiga $code ni kiriting ($link)';
  }

  @override
  String get ttInviteRevoke => 'Bekor qilish';

  @override
  String get ttInviteRevokeBody =>
      'Kod darhol ishlamay qoladi. Qo‘shilib bo‘lgan talabalar guruhda qoladi.';

  @override
  String get ttErrLimitInvites =>
      'Guruhda faol taklifnomalar juda ko‘p. Keraksizlarini bekor qiling.';

  @override
  String get ttInviteAcceptTitle => 'Guruhga taklifnoma';

  @override
  String get ttInviteCodeField => 'Taklifnoma kodi (12 belgi)';

  @override
  String get ttInviteCheck => 'Tekshirish';

  @override
  String get ttInviteGroupTitle => 'Guruh';

  @override
  String get ttInviteConsentTitle => 'Ustozga nima ko‘rinadi';

  @override
  String get ttInviteConsentBody =>
      'Qo‘shilsangiz, ustoz a’zolar ro‘yxatida taxallusingizni (yoki tartib raqamingizni) va ustoz testlaridagi natijalaringizni ko‘radi: javoblar, ball va vaqt. Emailingiz ko‘rinmaydi. Istalgan vaqtda guruhdan chiqishingiz mumkin — ustoz testlari natijalaringiz o‘chiriladi.';

  @override
  String get ttInviteConsentCheck => 'Roziman';

  @override
  String get ttInviteNickname => 'Taxallus (ixtiyoriy)';

  @override
  String get ttInviteAccept => 'Qo‘shilish';

  @override
  String get ttInviteDecline => 'Rad etish';

  @override
  String get ttInviteJoined => 'Guruhga qo‘shildingiz';

  @override
  String get ttInviteAlready => 'Siz bu guruhdasiz';

  @override
  String get ttInviteOpenGroup => 'Guruhni ochish';

  @override
  String get ttInviteOwn => 'Bu sizning guruhingiz';

  @override
  String get ttInviteExpired =>
      'Taklifnoma muddati o‘tgan yoki bekor qilingan. Ustozdan yangi kod so‘rang.';

  @override
  String get ttInviteNotFound => 'Kod topilmadi — tekshirib qayta kiriting.';

  @override
  String get ttResultsTitle => 'Natijalar';

  @override
  String get ttSummaryTitle => 'Jamlanma';

  @override
  String get ttSumTargets => 'Talabalar';

  @override
  String get ttSumSubmitted => 'Topshirdi';

  @override
  String get ttSumAverage => 'O‘rtacha natija';

  @override
  String get ttSumPassRate => 'O‘tganlar';

  @override
  String get ttSumAvgTime => 'O‘rtacha vaqt';

  @override
  String get ttPrivacyTeacher =>
      'Faqat guruhga o‘zi qo‘shilgan talabalar natijasi ko‘rinadi. Talaba guruhdan chiqsa, natijalari o‘chiriladi.';

  @override
  String get ttStudentsTitle => 'Talabalar kesimida';

  @override
  String get ttNoStudentsYet => 'Guruhda hali talaba yo‘q.';

  @override
  String get ttMostMissed => 'Eng ko‘p xato qilingan savollar';

  @override
  String get ttNoResultsYet => 'Hali hech kim topshirmagan.';

  @override
  String get ttQuestionsStatTitle => 'Savollar kesimida';

  @override
  String get ttNoAnswersYet => 'javob hali yo‘q';

  @override
  String ttCorrectPercent(int percent) {
    return '$percent% to‘g‘ri';
  }

  @override
  String get ttStateAssigned => 'Boshlanmagan';

  @override
  String get ttStateStarted => 'Yechilmoqda';

  @override
  String get ttStateSubmitted => 'Topshirilgan';

  @override
  String get ttStateExpired => 'Muddati o‘tgan';

  @override
  String get ttPassed => 'o‘tdi';

  @override
  String get ttNotPassed => 'o‘tmadi';

  @override
  String get ttLate => 'kechikkan';

  @override
  String get ttLateAccepted => 'Kechikkani qabul qilinadi';

  @override
  String ttAttemptsN(int count) {
    return '$count urinish';
  }

  @override
  String ttMinSec(int m, int s) {
    return '$m daq $s s';
  }

  @override
  String get ttExportCsv => 'CSV nusxasini olish';

  @override
  String get ttExportCopied => 'CSV nusxalandi — jadvalga joylashtiring';

  @override
  String get ttCloseAssignment => 'Topshiriqni yopish';

  @override
  String get ttCloseAssignmentBody =>
      'Yangi urinish boshlanmaydi; hozir yechayotganlar 2 daqiqa ichida topshira oladi.';

  @override
  String get ttDeleteAssignment => 'Topshiriqni o‘chirish';

  @override
  String get ttDeleteAssignmentBody =>
      'Topshiriq va uning natijalari o‘chiriladi.';

  @override
  String get ttMyTitle => 'Ustoz testlari';

  @override
  String get ttMySubtitle => 'Ustozingiz bergan maxsus testlar';

  @override
  String get ttMyEmpty => 'Hozircha test yo‘q';

  @override
  String get ttMyEmptyBody => 'Ustoz test topshirganda shu yerda ko‘rinadi.';

  @override
  String ttBest(int percent) {
    return 'eng yaxshi $percent%';
  }

  @override
  String get ttVisibleNoticeTitle => 'Natija ustozingizga ko‘rinadi';

  @override
  String get ttVisibleNotice =>
      'Ustozingiz bu test bo‘yicha taxallusingizni (yoki tartib raqamingizni), javoblaringiz, ball va vaqtni ko‘radi. Emailingiz ko‘rinmaydi.';

  @override
  String get proTtStudentLocked =>
      'Ustoz testini boshlash — Talaba Pro rejasida. Natijalaringiz ko‘rinib turadi.';

  @override
  String get ttLatePolicyAccept =>
      'Muddatdan keyin ham qabul qilinadi (“kechikkan” deb belgilanadi).';

  @override
  String get ttLatePolicyReject => 'Muddatdan keyin boshlab bo‘lmaydi.';

  @override
  String get ttCantClosed => 'Ustoz bu topshiriqni yopgan.';

  @override
  String get ttCantPastDue => 'Muddat o‘tgan.';

  @override
  String get ttCantNoAttempts => 'Urinishlar tugagan.';

  @override
  String get ttStart => 'Testni boshlash';

  @override
  String get ttContinue => 'Davom ettirish';

  @override
  String get ttYourAttempts => 'Urinishlaringiz';

  @override
  String ttAttemptN(int n) {
    return '$n-urinish';
  }

  @override
  String get ttReviewHidden =>
      'To‘g‘ri javoblar urinishlar tugagach, muddat o‘tgach yoki ustoz topshiriqni yopgach ko‘rsatiladi.';

  @override
  String get ttYourAnswer => 'Javobingiz';

  @override
  String get ttNoAnswer => 'javob yo‘q';

  @override
  String ttSubmittedSnack(int score, int total) {
    return 'Topshirildi: $score/$total';
  }

  @override
  String get ttErrTimeOver => 'Vaqt tugagan — bu urinish qabul qilinmadi.';

  @override
  String get ttErrAlreadySubmitted => 'Bu urinish allaqachon topshirilgan.';

  @override
  String ttTimeLeft(String time) {
    return 'Qolgan vaqt: $time';
  }

  @override
  String get ttSubmit => 'Topshirish';

  @override
  String get ttSubmitConfirmTitle => 'Javoblarni topshirasizmi?';

  @override
  String ttSubmitUnanswered(int count) {
    return '$count ta savolga javob berilmagan.';
  }

  @override
  String get ttSubmitFinal => 'Topshirgach javoblarni o‘zgartirib bo‘lmaydi.';

  @override
  String get ttSubmitVisible => 'Natija ustozingizga ko‘rinadi.';

  @override
  String get ttSubmitFailedSaved =>
      'Topshirib bo‘lmadi. Javoblar qurilmada saqlandi — qayta urinib ko‘ring.';
}
