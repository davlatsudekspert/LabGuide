// “Qanday foydalaniladi?” (how-to) — bo‘limlar ro‘yxati va matnlari.
//
// Har bo‘lim uchun: sarlavha (bo‘limning mavjud ARB nomi), 4–6 qisqa qadam
// va “natijada nima olasiz” qatori — hammasi ARB (uz/ru/en) dan. Qadamlar
// docs/video/<nn>_<mavzu>.md dagi storyboardlardan olingan va faqat
// haqiqatan ishlaydigan ekranlarni tilga oladi (`routes` — qadamlar tilga
// olgan ekranlar; test/unit/howto_registry_test.dart ular routerda borligini
// tekshiradi). Video hozircha hech bir bo‘limga qo‘shilmagan: `videoUrl`
// faqat haqiqiy video ro‘yxatga olinganda to‘ldiriladi.
import '../../l10n/gen/app_localizations.dart';

/// How-to bor bo‘limlar. `id` — marshrutga bog‘liq bo‘lmagan barqaror nom.
enum HowToSection {
  calibration,
  qc,
  preanalytics,
  calculators,
  instruments,
  microscopy,
  coprology,
  assessment,
  differential,
  cytology,
  spermogram,
  bloodGroup,
  histology,
  urinalysis,
  bloodMorph,
  coagulogram;

  String get id => name;
}

typedef HowToText = String Function(AppLocalizations l);

class HowToContent {
  const HowToContent({
    required this.section,
    required this.title,
    required this.steps,
    required this.result,
    this.routes = const [],
    this.videoUrl,
  });

  final HowToSection section;
  final HowToText title;
  final List<HowToText> steps;
  final HowToText result;

  /// Qadamlarda tilga olingan ekranlar (faqat test uchun dalil).
  final List<String> routes;

  /// Ro‘yxatga olingan video havolasi (https). Hozir hech biri yo‘q —
  /// `null` bo‘lsa, how-to oynasida video haqida hech narsa ko‘rsatilmaydi.
  final String? videoUrl;

  String get id => section.id;
}

abstract final class HowToRegistry {
  static final Map<HowToSection, HowToContent> all = {
  HowToSection.calibration: HowToContent(
    section: HowToSection.calibration,
    title: (l) => l.labHeroTitle,
    steps: [
      (l) => l.howToCalibrationStep1,
      (l) => l.howToCalibrationStep2,
      (l) => l.howToCalibrationStep3,
      (l) => l.howToCalibrationStep4,
      (l) => l.howToCalibrationStep5,
      (l) => l.howToCalibrationStep6,
    ],
    result: (l) => l.howToCalibrationResult,
    routes: const [
      '/lab/calibration',
      '/lab/calibration/log',
      '/lab/instruments',
    ],
  ),
  HowToSection.qc: HowToContent(
    section: HowToSection.qc,
    title: (l) => l.qcTitle,
    steps: [
      (l) => l.howToQcStep1,
      (l) => l.howToQcStep2,
      (l) => l.howToQcStep3,
      (l) => l.howToQcStep4,
      (l) => l.howToQcStep5,
      (l) => l.howToQcStep6,
    ],
    result: (l) => l.howToQcResult,
    routes: const [
      '/lab/qc',
      '/lab/qc/new',
      '/lab/qc/rejected',
      '/lab/qc/eqa',
      '/lab/qc/critical',
    ],
  ),
  HowToSection.preanalytics: HowToContent(
    section: HowToSection.preanalytics,
    title: (l) => l.preTitle,
    steps: [
      (l) => l.howToPreanalyticsStep1,
      (l) => l.howToPreanalyticsStep2,
      (l) => l.howToPreanalyticsStep3,
      (l) => l.howToPreanalyticsStep4,
      (l) => l.howToPreanalyticsStep5,
    ],
    result: (l) => l.howToPreanalyticsResult,
    routes: const [
      '/lab/preanalytics',
    ],
  ),
  HowToSection.calculators: HowToContent(
    section: HowToSection.calculators,
    title: (l) => l.calcTitle,
    steps: [
      (l) => l.howToCalculatorsStep1,
      (l) => l.howToCalculatorsStep2,
      (l) => l.howToCalculatorsStep3,
      (l) => l.howToCalculatorsStep4,
    ],
    result: (l) => l.howToCalculatorsResult,
    routes: const [
      '/lab/calculators',
      '/lab/calculators/egfr',
      '/lab/calculators/dilution',
    ],
  ),
  HowToSection.instruments: HowToContent(
    section: HowToSection.instruments,
    title: (l) => l.labInstruments,
    steps: [
      (l) => l.howToInstrumentsStep1,
      (l) => l.howToInstrumentsStep2,
      (l) => l.howToInstrumentsStep3,
      (l) => l.howToInstrumentsStep4,
      (l) => l.howToInstrumentsStep5,
    ],
    result: (l) => l.howToInstrumentsResult,
    routes: const [
      '/lab/instruments',
      '/lab/instruments/c/hematology',
      '/lab/instruments/d/tb',
      '/lab/calibration',
      '/lab/qc',
    ],
  ),
  HowToSection.microscopy: HowToContent(
    section: HowToSection.microscopy,
    title: (l) => l.micTitle,
    steps: [
      (l) => l.howToMicroscopyStep1,
      (l) => l.howToMicroscopyStep2,
      (l) => l.howToMicroscopyStep3,
      (l) => l.howToMicroscopyStep4,
      (l) => l.howToMicroscopyStep5,
    ],
    result: (l) => l.howToMicroscopyResult,
    routes: const [
      '/lab/microscopy',
      '/lab/microscopy/s/urine',
      '/lab/microscopy/quiz',
      '/lab/microscopy/credits',
    ],
  ),
  HowToSection.coprology: HowToContent(
    section: HowToSection.coprology,
    title: (l) => l.coproTitle,
    steps: [
      (l) => l.howToCoprologyStep1,
      (l) => l.howToCoprologyStep2,
      (l) => l.howToCoprologyStep3,
      (l) => l.howToCoprologyStep4,
      (l) => l.howToCoprologyStep5,
      (l) => l.howToCoprologyStep6,
    ],
    result: (l) => l.howToCoprologyResult,
    routes: const [
      '/lab/coprology',
      '/lab/coprology/collect',
      '/lab/coprology/macro',
      '/lab/coprology/micro',
      '/lab/coprology/occult',
      '/lab/coprology/parasites',
    ],
  ),
  HowToSection.assessment: HowToContent(
    section: HowToSection.assessment,
    title: (l) => l.toifaTitle,
    steps: [
      (l) => l.howToAssessmentStep1,
      (l) => l.howToAssessmentStep2,
      (l) => l.howToAssessmentStep3,
      (l) => l.howToAssessmentStep4,
      (l) => l.howToAssessmentStep5,
      (l) => l.howToAssessmentStep6,
    ],
    result: (l) => l.howToAssessmentResult,
    routes: const [
      '/learn/toifa',
      '/learn/toifa/test',
      '/learn/toifa/practice',
      '/learn/toifa/oral',
      '/learn/toifa/mistakes',
      '/learn/toifa/progress',
      '/profile',
    ],
  ),
  HowToSection.differential: HowToContent(
    section: HowToSection.differential,
    title: (l) => l.diffTitle,
    steps: [
      (l) => l.howToDifferentialStep1,
      (l) => l.howToDifferentialStep2,
      (l) => l.howToDifferentialStep3,
      (l) => l.howToDifferentialStep4,
      (l) => l.howToDifferentialStep5,
    ],
    result: (l) => l.howToDifferentialResult,
    routes: const [
      '/lab/differential',
      '/lab/differential/cells',
      '/lab/differential/count',
      '/lab/differential/history',
      '/lab/differential/interpret',
      '/lab/differential/quiz',
      '/lab/calculators/differential',
    ],
  ),
  HowToSection.cytology: HowToContent(
    section: HowToSection.cytology,
    title: (l) => l.cytoTitle,
    steps: [
      (l) => l.howToCytologyStep1,
      (l) => l.howToCytologyStep2,
      (l) => l.howToCytologyStep3,
      (l) => l.howToCytologyStep4,
      (l) => l.howToCytologyStep5,
    ],
    result: (l) => l.howToCytologyResult,
    routes: const [
      '/lab/cytology',
      '/lab/cytology/cells',
      '/lab/cytology/degree',
      '/lab/cytology/bethesda',
      '/lab/cytology/adequacy',
      '/lab/cytology/reactive',
      '/lab/cytology/maturation',
      '/lab/cytology/quiz',
    ],
  ),
  HowToSection.spermogram: HowToContent(
    section: HowToSection.spermogram,
    title: (l) => l.spermTitle,
    steps: [
      (l) => l.howToSpermogramStep1,
      (l) => l.howToSpermogramStep2,
      (l) => l.howToSpermogramStep3,
      (l) => l.howToSpermogramStep4,
      (l) => l.howToSpermogramStep5,
    ],
    result: (l) => l.howToSpermogramResult,
    routes: const [
      '/lab/spermogram',
      '/lab/spermogram/limits',
      '/lab/spermogram/count',
      '/lab/spermogram/assess',
      '/lab/spermogram/terms',
      '/lab/spermogram/preanalytics',
      '/lab/spermogram/quiz',
    ],
  ),
  HowToSection.bloodGroup: HowToContent(
    section: HowToSection.bloodGroup,
    title: (l) => l.bloodGroupTitle,
    steps: [
      (l) => l.howToBloodGroupStep1,
      (l) => l.howToBloodGroupStep2,
      (l) => l.howToBloodGroupStep3,
      (l) => l.howToBloodGroupStep4,
      (l) => l.howToBloodGroupStep5,
    ],
    result: (l) => l.howToBloodGroupResult,
    routes: const [
      '/lab/bloodgroup',
      '/lab/bloodgroup/basics',
      '/lab/bloodgroup/methods',
      '/lab/bloodgroup/compat',
      '/lab/bloodgroup/errors',
      '/lab/bloodgroup/reader',
      '/lab/bloodgroup/quiz',
    ],
  ),
  HowToSection.histology: HowToContent(
    section: HowToSection.histology,
    title: (l) => l.histoTitle,
    steps: [
      (l) => l.howToHistologyStep1,
      (l) => l.howToHistologyStep2,
      (l) => l.howToHistologyStep3,
      (l) => l.howToHistologyStep4,
      (l) => l.howToHistologyStep5,
    ],
    result: (l) => l.howToHistologyResult,
    routes: const [
      '/lab/histology',
      '/lab/histology/items',
      '/lab/histology/stains',
      '/lab/histology/quiz',
      '/lab/histology/credits',
    ],
  ),
  HowToSection.urinalysis: HowToContent(
    section: HowToSection.urinalysis,
    title: (l) => l.urinTitle,
    steps: [
      (l) => l.howToUrinalysisStep1,
      (l) => l.howToUrinalysisStep2,
      (l) => l.howToUrinalysisStep3,
      (l) => l.howToUrinalysisStep4,
      (l) => l.howToUrinalysisStep5,
    ],
    result: (l) => l.howToUrinalysisResult,
    routes: const [
      '/lab/urinalysis',
      '/lab/urinalysis/collect',
      '/lab/urinalysis/physical',
      '/lab/urinalysis/strip',
      '/lab/urinalysis/sediment',
      '/lab/urinalysis/reader',
      '/lab/urinalysis/quiz',
    ],
  ),
  HowToSection.bloodMorph: HowToContent(
    section: HowToSection.bloodMorph,
    title: (l) => l.bloodMorphTitle,
    steps: [
      (l) => l.howToBloodMorphStep1,
      (l) => l.howToBloodMorphStep2,
      (l) => l.howToBloodMorphStep3,
      (l) => l.howToBloodMorphStep4,
      (l) => l.howToBloodMorphStep5,
    ],
    result: (l) => l.howToBloodMorphResult,
    routes: const [
      '/lab/bloodmorph',
      '/lab/bloodmorph/normal',
      '/lab/bloodmorph/rbc',
      '/lab/bloodmorph/platelets',
      '/lab/bloodmorph/retic',
      '/lab/bloodmorph/anemia',
      '/lab/bloodmorph/quiz',
    ],
  ),
  HowToSection.coagulogram: HowToContent(
    section: HowToSection.coagulogram,
    title: (l) => l.coagTitle,
    steps: [
      (l) => l.howToCoagulogramStep1,
      (l) => l.howToCoagulogramStep2,
      (l) => l.howToCoagulogramStep3,
      (l) => l.howToCoagulogramStep4,
      (l) => l.howToCoagulogramStep5,
    ],
    result: (l) => l.howToCoagulogramResult,
    routes: const [
      '/lab/coagulogram',
      '/lab/coagulogram/tests',
      '/lab/coagulogram/sample',
      '/lab/coagulogram/reader',
      '/lab/coagulogram/dic',
      '/lab/coagulogram/monitoring',
    ],
  ),
  };

  static HowToContent of(HowToSection section) => all[section]!;

  /// Matndagi id bo‘yicha (masalan, chuqur havola yoki konfiguratsiyadan).
  /// Noma’lum id — [FormatException].
  static HowToContent byId(String id) {
    for (final s in HowToSection.values) {
      if (s.id == id) return of(s);
    }
    throw FormatException('Noma’lum how-to bo‘limi', id);
  }
}
