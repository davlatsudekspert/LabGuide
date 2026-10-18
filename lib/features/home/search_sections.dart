import 'package:material_ui/material_ui.dart';

import '../../l10n/gen/app_localizations.dart';
import '../bloodgroup/bloodgroup_screens.dart';
import '../bloodmorph/bloodmorph_screens.dart';
import '../content/analyte_search.dart';
import '../cytology/cytology_screens.dart';
import '../histology/histology_screens.dart';
import '../microscopy/microscopy_widgets.dart';
import '../spermogram/spermogram_screens.dart';
import '../toifa/toifa_screens.dart' show toifaBase;
import '../urinalysis/urinalysis_screens.dart';
import '../coagulogram/coag_screens.dart';
import '../coprology/copro_screens.dart';

/// Umumiy qidiruvdagi “Bo'limlar” guruhi uchun bitta bo'lim: laboratoriya
/// bo'limlari va vositalari (leykoformula, sitologiya, QC, kalibrlash, …).
/// Nomlar uch tilda (ilova matnlaridan), sinonim va qisqartmalar esa lotin,
/// kirill va ruscha/inglizcha yozuvda shu yerda.
class SearchSection {
  const SearchSection({
    required this.id,
    required this.route,
    required this.icon,
    required this.title,
    required this.synonyms,
    this.toifaOnly = false,
    this.teacherOnly = false,
  });

  final String id;

  /// `openInTab(..., exact: true)` bilan ochiladigan manzil.
  final String route;
  final IconData icon;
  final String Function(AppLocalizations l) title;

  /// Qo'shimcha atamalar: sinonim, qisqartma, boshqa yozuvdagi nomlar.
  final List<String> synonyms;

  /// Faqat toifa bo'limi ko'rinadigan foydalanuvchiga (`toifaVisible`).
  final bool toifaOnly;

  /// Faqat ustoz roliga.
  final bool teacherOnly;
}

/// Bo'limlar ro'yxati (tartib — bir xil moslikda chiqish tartibi).
const kSearchSections = <SearchSection>[
  SearchSection(
    id: 'differential',
    route: '/lab/differential',
    icon: Icons.bubble_chart_outlined,
    title: _diff,
    synonyms: [
      'leykoformula',
      'leykogramma',
      'leykotsitar formula',
      'leykotsit formulasi',
      'leukoformula',
      'differential',
      'differential count',
      'diff',
      'wbc differential',
      'cbc diff',
      'лейкоформула',
      'лейкограмма',
      'лейкоцитарная формула',
      'формула крови',
      'дифференциальный подсчет',
      'дифф',
    ],
  ),
  SearchSection(
    id: 'cytology',
    route: cytoBase,
    icon: Icons.biotech_outlined,
    title: _cyto,
    synonyms: [
      'sitologiya',
      'citologiya',
      'sitologik',
      'pap',
      'pap test',
      'papanikolau',
      'bethesda',
      'betesda',
      'cytology',
      'cytological',
      'цитология',
      'цитологическое',
      'пап тест',
      'папаниколау',
      'бетесда',
    ],
  ),
  SearchSection(
    id: 'semen',
    route: spermBase,
    icon: Icons.water_drop_outlined,
    title: _sperm,
    synonyms: [
      'spermogramma',
      'spermiogramma',
      'sperma',
      'urug',
      'semen',
      'semen analysis',
      'sperm',
      'who 2021',
      'спермограмма',
      'сперма',
      'эякулят',
      'спермиограмма',
    ],
  ),
  SearchSection(
    id: 'bloodgroup',
    route: bloodGroupBase,
    icon: Icons.bloodtype_outlined,
    title: _bloodGroup,
    synonyms: [
      'qon guruhi',
      'qon guruhlari',
      'qon guruhini aniqlash',
      'abo',
      'rh',
      'rezus',
      'rh faktor',
      'kross match',
      'blood group',
      'blood type',
      'blood typing',
      'abo rh',
      'группа крови',
      'резус',
      'резус фактор',
      'аво',
    ],
  ),
  SearchSection(
    id: 'histology',
    route: histoBase,
    icon: Icons.layers_outlined,
    title: _histo,
    synonyms: [
      'gistologiya',
      'histologiya',
      'gistologik',
      'biopsiya',
      'gematoksilin',
      'eozin',
      'histology',
      'histological',
      'biopsy',
      'hematoxylin',
      'eosin',
      'гистология',
      'биопсия',
      'гематоксилин',
      'эозин',
    ],
  ),
  SearchSection(
    id: 'urinalysis',
    route: urinBase,
    icon: Icons.science_outlined,
    title: _urin,
    synonyms: [
      'siydik tahlili',
      'umumiy siydik tahlili',
      'siydik',
      'siydik cho‘kmasi',
      'siydik tekshiruvi',
      'oam',
      'urinalysis',
      'urine',
      'urine analysis',
      'urine sediment',
      'dipstick',
      'анализ мочи',
      'общий анализ мочи',
      'моча',
      'мочи',
      'осадок мочи',
      'оам',
    ],
  ),
  SearchSection(
    id: 'bloodmorph',
    route: bmBase,
    icon: Icons.blur_circular_rounded,
    title: _bloodMorph,
    synonyms: [
      'qon morfologiyasi',
      'eritrotsitlar',
      'trombotsitlar',
      'retikulotsitlar',
      'anemiya',
      'qon surtmasi',
      'surtma',
      'blood morphology',
      'blood smear',
      'peripheral smear',
      'rbc morphology',
      'platelets',
      'reticulocytes',
      'anemia',
      'морфология крови',
      'мазок крови',
      'эритроциты',
      'тромбоциты',
      'ретикулоциты',
      'анемия',
    ],
  ),
  SearchSection(
    id: 'coagulogram',
    route: coagBase,
    icon: Icons.timer_outlined,
    title: _coag,
    synonyms: [
      'koagulogramma',
      'koagulogram',
      'gemostaz',
      'gemostazogramma',
      'qon ivishi',
      'ivish tizimi',
      'protrombin vaqti',
      'inr',
      'aptt',
      'trombin vaqti',
      'd-dimer',
      'dic bali',
      'coagulogram',
      'coagulation',
      'haemostasis',
      'hemostasis',
      'prothrombin time',
      'thrombin time',
      'clotting tests',
      'коагулограмма',
      'гемостаз',
      'гемостазиограмма',
      'свертываемость',
      'свёртываемость',
      'протромбиновое время',
      'мно',
      'ачтв',
      'тромбиновое время',
      'д-димер',
      'двс',
    ],
  ),
  SearchSection(
    id: 'coprology',
    route: coproBase,
    icon: Icons.bug_report_outlined,
    title: _copro,
    synonyms: [
      'koprogramma',
      'koprologiya',
      'najas',
      'najas tahlili',
      'najas tekshiruvi',
      'gijja',
      'gijja tuxumlari',
      'parazitlar',
      'yashirin qon',
      'lyamblya',
      'askarida',
      'ostritsa',
      'coprogram',
      'coprology',
      'stool analysis',
      'stool test',
      'faeces',
      'feces',
      'ova and parasites',
      'intestinal parasites',
      'occult blood',
      'giardia',
      'pinworm',
      'копрограмма',
      'копрология',
      'анализ кала',
      'кал на яйца глист',
      'яйца гельминтов',
      'кишечные паразиты',
      'скрытая кровь',
      'лямблии',
      'аскарида',
      'острица',
    ],
  ),
  SearchSection(
    id: 'qc',
    route: '/lab/qc',
    icon: Icons.show_chart_rounded,
    title: _qc,
    synonyms: [
      'sifat nazorati',
      'qc',
      'nazorat',
      'ichki nazorat',
      'levey jennings',
      'levi jennings',
      'westgard',
      'vestgard',
      'quality control',
      'контроль качества',
      'ккк',
      'леви дженнингс',
      'вестгард',
    ],
  ),
  SearchSection(
    id: 'preanalytics',
    route: '/lab/preanalytics',
    icon: Icons.vaccines_outlined,
    title: _preanalytics,
    synonyms: [
      'preanalitika',
      'preanalitik',
      'namuna olish',
      'namuna omillari',
      'venepunksiya',
      'gemoliz',
      'preanalytics',
      'preanalytical',
      'pre analytical',
      'sample factors',
      'sampling',
      'hemolysis',
      'преаналитика',
      'преаналитический',
      'взятие образца',
      'факторы образца',
      'гемолиз',
    ],
  ),
  SearchSection(
    id: 'calibration',
    route: '/lab/calibration',
    icon: Icons.tune_rounded,
    title: _calibration,
    synonyms: [
      'kalibrlash',
      'kalibrovka',
      'kalibrator',
      'kalibr',
      'calibration',
      'calibrator',
      'калибровка',
      'калибратор',
    ],
  ),
  SearchSection(
    id: 'calculators',
    route: '/lab/calculators',
    icon: Icons.calculate_outlined,
    title: _calculators,
    synonyms: [
      'kalkulyatorlar',
      'kalkulyator',
      'suyultirish',
      'birliklar',
      'birlik o‘zgartirish',
      'calculators',
      'calculator',
      'dilution',
      'units',
      'unit converter',
      'калькуляторы',
      'калькулятор',
      'разведение',
      'единицы',
      'конвертер единиц',
    ],
  ),
  SearchSection(
    id: 'instruments',
    route: '/lab/instruments',
    icon: Icons.precision_manufacturing_outlined,
    title: _instruments,
    synonyms: [
      'apparatlar',
      'apparat',
      'asboblar',
      'analizator',
      'analizatorlar',
      'metodika',
      'metodikalar',
      'instruments',
      'instrument',
      'analyzers',
      'analyzer',
      'methods',
      'приборы',
      'прибор',
      'анализаторы',
      'анализатор',
      'методики',
    ],
  ),
  SearchSection(
    id: 'microscopy',
    route: microBase,
    icon: Icons.visibility_outlined,
    title: _microscopy,
    synonyms: [
      'mikroskopiya atlasi',
      'mikroskopiya',
      'mikroskop',
      'atlas',
      'microscopy atlas',
      'microscopy',
      'microscope',
      'атлас микроскопии',
      'микроскопия',
      'микроскоп',
      'атлас',
    ],
  ),
  SearchSection(
    id: 'toifa',
    route: toifaBase,
    icon: Icons.workspace_premium_outlined,
    title: _toifa,
    toifaOnly: true,
    synonyms: [
      'toifa',
      'malaka toifasi',
      'toifa imtihoni',
      'attestatsiya',
      'qualification category',
      'category exam',
      'attestation',
      'категория',
      'квалификационная категория',
      'аттестация',
      'экзамен на категорию',
    ],
  ),
  SearchSection(
    id: 'daily',
    route: '/learn/daily',
    icon: Icons.today_outlined,
    title: _daily,
    synonyms: [
      'kunlik savol',
      'kunlik savollar',
      'bugungi savol',
      'daily',
      'daily questions',
      'question of the day',
      'вопросы дня',
      'вопрос дня',
      'ежедневные вопросы',
    ],
  ),
  SearchSection(
    id: 'lecture',
    route: '/learn/lecture',
    icon: Icons.co_present_outlined,
    title: _lecture,
    // Hamma rolga (D-68 Q4): O'rganish tabidagi "Ma'ruza" qatori bilan bir
    // xil — talaba ham mavzu taqdimoti va testini shu yerdan ochadi.
    synonyms: [
      'maruza',
      'maruza rejimi',
      'ma‘ruza',
      'lecture',
      'lecture mode',
      'лекция',
      'режим лекции',
    ],
  ),
];

String _diff(AppLocalizations l) => l.diffTitle;
String _cyto(AppLocalizations l) => l.cytoTitle;
String _sperm(AppLocalizations l) => l.spermTitle;
String _bloodGroup(AppLocalizations l) => l.bloodGroupTitle;
String _histo(AppLocalizations l) => l.histoTitle;
String _urin(AppLocalizations l) => l.urinTitle;
String _bloodMorph(AppLocalizations l) => l.bloodMorphTitle;
String _coag(AppLocalizations l) => l.coagTitle;
String _copro(AppLocalizations l) => l.coproTitle;
String _qc(AppLocalizations l) => l.featureQc;
String _preanalytics(AppLocalizations l) => l.labPreanalytics;
String _calibration(AppLocalizations l) => l.featureCalibration;
String _calculators(AppLocalizations l) => l.featureCalculators;
String _instruments(AppLocalizations l) => l.labInstruments;
String _microscopy(AppLocalizations l) => l.micTitle;
String _toifa(AppLocalizations l) => l.toifaTitle;
String _daily(AppLocalizations l) => l.dailyTitle;
String _lecture(AppLocalizations l) => l.lectureTitle;

/// Bo'limlar bo'yicha qidiruv: nom (uch tilda) va sinonimlar; kirillcha
/// o'zbekcha so'rov lotinga o'giriladi ([searchVariants]).
class SectionSearch {
  SectionSearch._()
    : _entries = {
        for (final s in kSearchSections)
          s.id: SearchEntry(
            {
              for (final code in const ['uz', 'ru', 'en'])
                code: normalizeForSearch(
                  s.title(lookupAppLocalizations(Locale(code))),
                ),
            },
            [for (final t in s.synonyms) normalizeForSearch(t)],
          ),
      };

  static final instance = SectionSearch._();

  final Map<String, SearchEntry> _entries;

  /// Moslik bo'yicha tartiblangan bo'limlar. [toifa] — toifa bo'limi
  /// foydalanuvchiga ko'rinadimi; [teacher] — ustoz roli.
  List<SearchSection> search(
    String query, {
    required String lang,
    required bool toifa,
    required bool teacher,
  }) {
    final q = normalizeForSearch(query);
    // Bir belgilik so'rov hamma narsaga mos kelib, shovqin beradi.
    if (q.length < 2) return const [];
    final queries = searchVariants(q);
    final scored = <(SearchSection, int, int)>[];
    for (final (i, s) in kSearchSections.indexed) {
      if ((s.toifaOnly && !toifa) || (s.teacherOnly && !teacher)) continue;
      final score = _entries[s.id]!.bestScore(queries, lang);
      if (score > 0) scored.add((s, score, i));
    }
    scored.sort((a, b) {
      final byScore = b.$2.compareTo(a.$2);
      return byScore != 0 ? byScore : a.$3.compareTo(b.$3);
    });
    return [for (final s in scored) s.$1];
  }
}
