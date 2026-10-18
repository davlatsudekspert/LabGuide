/// Koagulogramma: har bir test nimani o‘lchaydi (PT/INR, APTT, trombin vaqti,
/// fibrinogen (Clauss), D-dimer), namuna talablari va preanalitik xatolar,
/// natijani o‘qish yordamchisi (PT/APTT/trombotsit — ehtimoliy sabablar),
/// ISTH ochiq DIC bali va antikoagulyant monitoringi eslatmalari (3 tilda).
///
/// Har da'vo — manba va joy bilan ([CgFact], [CalcRef]); manbada yo'q narsa
/// yozilmaydi. Manbalar shu sessiyada ochib o'qilgan: WFH laboratoriya
/// qo'llanmasi (3-nashr, 2025; 3- va 5-qismlar), Magnette va boshq. 2016
/// (Thromb J, ochiq), Toh va boshq. 2016 (Ann Lab Med, ochiq), Iba va boshq.
/// 2019 (J Clin Med, ochiq), Wada va boshq. 2014 (J Intensive Care, ochiq),
/// CHEST 2012 (Ageno; Garcia — PMC), MedlinePlus (PT/INR, PTT, D-dimer).
/// Me'yoriy oraliqlar reagent va analizatorga bog'liq — faqat manbadagi
/// misol shu izoh bilan ko'rsatiladi. Manbalar jadvali:
/// docs/COAGULOGRAM_SOURCES.md.
library;

import '../content/content_model.dart';
import '../tools/calc_info.dart';

typedef _T = LocalizedText;

/// Manbalar qayta tekshirilgan sana.
const coagCheckedAt = '2026-10-18';

abstract final class CgSources {
  static const wfhPart3 = CalcSource(
    id: 'coag-wfh-2025-p3',
    citation:
        'Hickey K. Sample integrity and preanalytical variables. In: '
        'de Lima Montalvão S, Kitchen S, eds. Diagnosis of Hemophilia and '
        'Other Bleeding Disorders: A Laboratory Manual, 3rd ed. World '
        'Federation of Hemophilia, 2025. Part 3',
    url: 'https://www1.wfh.org/publications/files/pdf-2537.pdf',
  );
  static const wfhPart5 = CalcSource(
    id: 'coag-wfh-2025-p5',
    citation:
        'Khasiani A. Initial evaluation of hemostasis. In: de Lima Montalvão '
        'S, Kitchen S, eds. Diagnosis of Hemophilia and Other Bleeding '
        'Disorders: A Laboratory Manual, 3rd ed. World Federation of '
        'Hemophilia, 2025. Part 5',
    url: 'https://www1.wfh.org/publications/files/pdf-2550.pdf',
  );
  static const magnette2016 = CalcSource(
    id: 'coag-magnette-2016',
    citation:
        'Magnette A, Chatelain M, Chatelain B, Ten Cate H, Mullier F. '
        'Pre-analytical issues in the haemostasis laboratory: guidance for '
        'the clinical laboratories. Thromb J. 2016. '
        'doi:10.1186/s12959-016-0123-z',
    url: 'https://doi.org/10.1186/s12959-016-0123-z',
  );
  static const toh2016 = CalcSource(
    id: 'coag-toh-2016',
    citation:
        'Toh CH, Alhamdi Y, Abrams ST. Current pathological and laboratory '
        'considerations in the diagnosis of disseminated intravascular '
        'coagulation. Ann Lab Med. 2016. doi:10.3343/alm.2016.36.6.505',
    url: 'https://doi.org/10.3343/alm.2016.36.6.505',
  );
  static const iba2019 = CalcSource(
    id: 'coag-iba-2019',
    citation:
        'Iba T, Levy JH, Raj A, Warkentin TE. Advance in the management of '
        'sepsis-induced coagulopathy and disseminated intravascular '
        'coagulation. J Clin Med. 2019. doi:10.3390/jcm8050728',
    url: 'https://doi.org/10.3390/jcm8050728',
  );
  static const wada2014 = CalcSource(
    id: 'coag-wada-2014',
    citation:
        'Wada H, Matsumoto T, Yamashita Y. Diagnosis and treatment of '
        'disseminated intravascular coagulation (DIC) according to four DIC '
        'guidelines. J Intensive Care. 2014. doi:10.1186/2052-0492-2-15',
    url: 'https://doi.org/10.1186/2052-0492-2-15',
  );
  static const ageno2012 = CalcSource(
    id: 'coag-chest-ageno-2012',
    citation:
        'Ageno W, Gallus AS, Wittkowsky A, Crowther M, Hylek EM, Palareti G. '
        'Oral anticoagulant therapy: Antithrombotic Therapy and Prevention of '
        'Thrombosis, 9th ed: ACCP Guidelines. Chest. 2012. '
        'doi:10.1378/chest.11-2292',
    url: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC3278051/',
  );
  static const garcia2012 = CalcSource(
    id: 'coag-chest-garcia-2012',
    citation:
        'Garcia DA, Baglin TP, Weitz JI, Samama MM. Parenteral '
        'anticoagulants: Antithrombotic Therapy and Prevention of Thrombosis, '
        '9th ed: ACCP Guidelines. Chest. 2012. doi:10.1378/chest.11-2291',
    url: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC3278070/',
  );
  static const mlPt = CalcSource(
    id: 'medlineplus-pt-inr',
    citation:
        'MedlinePlus. Prothrombin Time Test and INR (PT/INR). National '
        'Library of Medicine',
    url: 'https://medlineplus.gov/lab-tests/prothrombin-time-test-and-inr-ptinr/',
  );
  static const mlPtt = CalcSource(
    id: 'medlineplus-ptt',
    citation:
        'MedlinePlus. Partial Thromboplastin Time (PTT) Test. National '
        'Library of Medicine',
    url: 'https://medlineplus.gov/lab-tests/partial-thromboplastin-time-ptt-test/',
  );
  static const mlDdimer = CalcSource(
    id: 'medlineplus-d-dimer',
    citation: 'MedlinePlus. D-Dimer Test. National Library of Medicine',
    url: 'https://medlineplus.gov/lab-tests/d-dimer-test/',
  );

  static const all = [
    wfhPart3,
    wfhPart5,
    magnette2016,
    toh2016,
    iba2019,
    wada2014,
    ageno2012,
    garcia2012,
    mlPt,
    mlPtt,
    mlDdimer,
  ];
}

// ───────────────────────── Lokatorlar ─────────────────────────

const _w3 = CgSources.wfhPart3;
const _w5 = CgSources.wfhPart5;
const _mg = CgSources.magnette2016;
const _toh = CgSources.toh2016;
const _iba = CgSources.iba2019;
const _wada = CgSources.wada2014;
const _oac = CgSources.ageno2012;
const _par = CgSources.garcia2012;

const _w3Collect = CalcRef(_w3, 'Blood Collection, p. 21');
const _w3Formula = CalcRef(_w3, 'Blood Collection: citrate formula, p. 21–22');
const _w3Ppp = CalcRef(_w3, 'Platelet Poor Plasma (PPP), p. 22');
const _w3Interf = CalcRef(_w3, 'Interfering Substances, p. 22');
const _w3Storage = CalcRef(_w3, 'Storage; Thawing, p. 22');

const _w5Pt = CalcRef(_w5, 'Prothrombin Time (PT), p. 32–33');
const _w5Aptt = CalcRef(_w5, 'Activated Partial Thromboplastin Time, p. 34–35');
const _w5Mix = CalcRef(_w5, 'Mixing Tests; Table 8, p. 36–38');
const _w5Tt = CalcRef(_w5, 'Thrombin Clotting Time, p. 39–40');
const _w5Rept = CalcRef(_w5, 'Reptilase Time; Table 10, p. 40–41');
const _w5Clauss = CalcRef(_w5, 'Fibrinogen (Modified Clauss Assay), p. 41–42');
const _w5PtFib = CalcRef(_w5, 'PT-Derived Fibrinogen Test, p. 43');
const _w5Bt = CalcRef(_w5, 'Bleeding Time Test: Notes, p. 32');

const _mgTubes = CalcRef(_mg, 'Sample tubes and anticoagulant; Table 1');
const _mgOrder = CalcRef(_mg, 'Sequence of drawing blood');
const _mgBlood = CalcRef(_mg, 'Blood sampling');
const _mgFill = CalcRef(_mg, 'Filling the tubes');
const _mgMix = CalcRef(_mg, 'Mixing the samples; Table 2');
const _mgExam = CalcRef(_mg, 'Examination of samples');
const _mgTransport = CalcRef(_mg, 'Transportation of samples; Table 3');
const _mgReject = CalcRef(_mg, 'Specimen rejection; Table 4');
const _mgCentr = CalcRef(_mg, 'Centrifugation; Table 5');
const _mgStorage = CalcRef(_mg, 'Storage conditions; Table 6');
const _mgPatient = CalcRef(_mg, 'Variables during sample collection');

const _tohTable = CalcRef(_toh, 'Table 1 (ISTH DIC scoring criteria)');
const _tohGeneral = CalcRef(
  _toh,
  'The laboratory aspects: 1. General principles',
);
const _tohScore = CalcRef(
  _toh,
  'The laboratory aspects: 2. Composite scoring systems',
);
const _tohPt = CalcRef(_toh, '3. Specific test considerations: 1) PT and aPTT');
const _tohPlt = CalcRef(
  _toh,
  '3. Specific test considerations: 2) Platelet count',
);
const _tohFib = CalcRef(
  _toh,
  '3. Specific test considerations: 3) Fibrinogen level',
);
const _tohFrm = CalcRef(
  _toh,
  '3. Specific test considerations: 4) Fibrin-related markers',
);
const _ibaTable = CalcRef(
  _iba,
  'Table 1 (ISTH overt DIC and SIC scoring systems)',
);
const _wadaDx = CalcRef(_wada, 'Diagnosis of DIC');

const _oacInr = CalcRef(
  _oac,
  '1.5 Monitoring Anticoagulant Intensity: the INR; Table 2',
);
const _oacRange = CalcRef(_oac, '1.8 Optimal Intensity Ranges');
const _oacDabi = CalcRef(
  _oac,
  '2.5 Monitoring Anticoagulant Intensity (dabigatran)',
);
const _oacRiva = CalcRef(
  _oac,
  '3.5 Monitoring Anticoagulant Intensity (rivaroxaban)',
);
const _parUfh = CalcRef(_par, '1.1.4 Monitoring (UFH)');
const _parLmwh = CalcRef(_par, '1.2.3 Monitoring Antithrombotic Effect (LMWH)');

const _mlPtUse = CalcRef(CgSources.mlPt, 'What is it used for?');
const _mlPtRes = CalcRef(CgSources.mlPt, 'What do the results mean?');
const _mlPttUse = CalcRef(CgSources.mlPtt, 'What is it used for?');
const _mlPttRes = CalcRef(CgSources.mlPtt, 'What do the results mean?');
const _mlDdUse = CalcRef(CgSources.mlDdimer, 'What is it used for?');
const _mlDdRes = CalcRef(CgSources.mlDdimer, 'What do the results mean?');

// ───────────────────────── Model ─────────────────────────

/// Bitta da'vo va uning manbalari.
class CgFact {
  const CgFact(this.text, this.refs);

  final LocalizedText text;
  final List<CalcRef> refs;
}

/// Bir nechta da'voning manbalari, takrorsiz (tartib bilan).
List<CalcRef> cgRefsOf(Iterable<CgFact> facts) {
  final seen = <String>{};
  return [
    for (final f in facts)
      for (final r in f.refs)
        if (seen.add('${r.source.id}|${r.locator}')) r,
  ];
}

/// Sarlavhali bo'lim.
class CgSection {
  const CgSection(this.title, this.facts);

  final LocalizedText title;
  final List<CgFact> facts;
}

/// Koagulogramma testi kartasi.
class CgTest {
  const CgTest({
    required this.id,
    required this.name,
    required this.measures,
    required this.notes,
    this.analyteId,
  });

  final String id;
  final LocalizedText name;

  /// Nimani o'lchaydi.
  final List<CgFact> measures;

  /// Talqin, cheklovlar, me'yor haqidagi izoh.
  final List<CgFact> notes;

  /// Pack'dagi tahlil kartasi (havola).
  final String? analyteId;

  List<CgFact> get facts => [...measures, ...notes];
}

// ───────────────────────── 1. Testlar ─────────────────────────

/// Barcha testlar uchun umumiy: me'yor laboratoriyaga bog'liq.
const cgTestsGeneral = <CgFact>[
  CgFact(
    _T({
      'uz':
          'PT va APTT me’yoriy oraliqlari reagent, koagulometr va mahalliy '
          'aholiga bog‘liq — har laboratoriya o‘z oralig‘ini belgilaydi. '
          'Ilovada “me’yor” raqami berilmaydi; quyidagi sonlar faqat '
          'manbadagi misol.',
      'ru':
          'Референтные интервалы ПВ и АЧТВ зависят от реагента, коагулометра '
          'и местной популяции — каждая лаборатория устанавливает свой '
          'интервал. Приложение не даёт «нормы»; числа ниже — только '
          'примеры из источника.',
      'en':
          'PT and APTT reference intervals depend on the reagent, the '
          'coagulometer and the local population — each laboratory sets its '
          'own. The app gives no “normal” figure; numbers below are only '
          'the source’s examples.',
    }),
    [_w5Pt, _w5Aptt],
  ),
];

const cgTests = <CgTest>[
  CgTest(
    id: 'pt',
    analyteId: 'pt-inr',
    name: _T({
      'uz': 'Protrombin vaqti (PT) va INR',
      'ru': 'Протромбиновое время (ПВ) и МНО',
      'en': 'Prothrombin time (PT) and INR',
    }),
    measures: [
      CgFact(
        _T({
          'uz':
              'PT tashqi (ekstrinsik) va umumiy yo‘l butunligini baholaydi: '
              'V, VII va X omillarga sezgir, II omilga (protrombin) kamroq. '
              'Reagent — tromboplastin (to‘qima omili va fosfolipidlar).',
          'ru':
              'ПВ оценивает внешний и общий пути: чувствительно к факторам V, '
              'VII и X, меньше — к фактору II (протромбину). Реагент — '
              'тромбопластин (тканевой фактор и фосфолипиды).',
          'en':
              'PT assesses the extrinsic and common pathways: it is sensitive '
              'to factors V, VII and X, less so to factor II (prothrombin). '
              'The reagent is thromboplastin (tissue factor and '
              'phospholipids).',
        }),
        [_w5Pt],
      ),
      CgFact(
        _T({
          'uz':
              'INR = (bemor PT / o‘rtacha normal PT)^ISI. ISI — mahalliy '
              'tromboplastinning JSST xalqaro standartiga nisbatan '
              'sezgirligi; reagent qancha sezgir bo‘lsa, ISI shuncha past.',
          'ru':
              'МНО = (ПВ пациента / среднее нормальное ПВ)^МИЧ. МИЧ — '
              'чувствительность местного тромбопластина относительно '
              'международного стандарта ВОЗ; чем чувствительнее реагент, тем '
              'ниже МИЧ.',
          'en':
              'INR = (patient PT / mean normal PT)^ISI. ISI expresses the '
              'local thromboplastin’s responsiveness against the WHO '
              'international reference; the more responsive the reagent, the '
              'lower the ISI.',
        }),
        [_oacInr],
      ),
    ],
    notes: [
      CgFact(
        _T({
          'uz':
              'Qo‘llanilishi: varfarin (vitamin K antagonisti) ta’sirini '
              'kuzatish; g‘ayrioddiy qon ketish yoki tromb sababini izlash; '
              'operatsiyadan oldin; jigar kasalligi va vitamin K '
              'yetishmovchiligini tekshirish.',
          'ru':
              'Применение: контроль варфарина (антагониста витамина K); поиск '
              'причины необычного кровотечения или тромбов; перед операцией; '
              'проверка при болезни печени и дефиците витамина K.',
          'en':
              'Uses: monitoring warfarin (a vitamin K antagonist); finding the '
              'cause of unusual bleeding or clots; before surgery; checking '
              'for liver disease and vitamin K deficiency.',
        }),
        [_mlPtUse],
      ),
      CgFact(
        _T({
          'uz':
              'PTni uzaytirishi mumkin: jigar kasalligi, vitamin K '
              'yetishmovchiligi, DIC, VKA, to‘g‘ridan-to‘g‘ri peroral '
              'antikoagulyantlar (dozaga bog‘liq), tashqi yo‘l omillariga '
              'antitanalar. Yengil II, V, VII, X yetishmovchiligida uzayish '
              'kam; II yetishmovchiligida PT me’yorda bo‘lishi mumkin.',
          'ru':
              'Удлинять ПВ могут: болезнь печени, дефицит витамина K, ДВС, '
              'АВК, прямые оральные антикоагулянты (дозозависимо), антитела к '
              'факторам внешнего пути. При лёгком дефиците II, V, VII, X '
              'удлинение минимально; при дефиците II ПВ может быть в норме.',
          'en':
              'PT may be prolonged by liver disease, vitamin K deficiency, '
              'DIC, VKAs, direct oral anticoagulants (dose-dependently) and '
              'antibodies to extrinsic-pathway factors. In mild deficiency of '
              'II, V, VII or X prolongation may be minimal; in FII deficiency '
              'the PT may be normal.',
        }),
        [_w5Pt],
      ),
      CgFact(
        _T({
          'uz':
              'INR muammolari: noto‘g‘ri namuna (sitrat konsentratsiyasi, '
              'saqlash vaqti va harorati, kam to‘ldirish), noto‘g‘ri ISI yoki '
              'o‘rtacha normal PT, lupus antikoagulyanti, varfarin '
              'boshlanishida va jigar kasalligida ishonchliligi pastligi, '
              'INR > 4,5 da aniqlik kamligi.',
          'ru':
              'Проблемы МНО: ошибки пробы (концентрация цитрата, время и '
              'температура хранения, недолив), неверный МИЧ или среднее '
              'нормальное ПВ, волчаночный антикоагулянт, низкая надёжность в '
              'начале терапии варфарином и при болезни печени, меньшая '
              'точность при МНО > 4,5.',
          'en':
              'INR pitfalls: pre-test sample errors (citrate concentration, '
              'storage time and temperature, underfilling), wrong ISI or mean '
              'normal PT, lupus anticoagulant, poor reliability at warfarin '
              'onset and in liver disease, less reliability above INR 4.5.',
        }),
        [_oacInr],
      ),
    ],
  ),
  CgTest(
    id: 'aptt',
    analyteId: 'aptt',
    name: _T({
      'uz': 'Faollashgan qisman tromboplastin vaqti (APTT)',
      'ru': 'Активированное частичное тромбопластиновое время (АЧТВ)',
      'en': 'Activated partial thromboplastin time (APTT)',
    }),
    measures: [
      CgFact(
        _T({
          'uz':
              'Ichki va umumiy yo‘l omillari yetishmovchiligi yoki '
              'ingibitorlarini aniqlaydi. Me’yoriy PT bilan birga — VIII, '
              'IX, XI, XII omillar yetishmovchiligi uchun eng foydali '
              'skrining. Reagent: suyultirilgan fosfolipid va kontakt '
              'faollashtiruvchi (kremniy, ellag kislotasi, kaolin), so‘ng '
              'kalsiy xlorid; vaqt soniyalarda.',
          'ru':
              'Выявляет дефицит или ингибиторы факторов внутреннего и общего '
              'путей. Вместе с нормальным ПВ — самый полезный скрининг '
              'дефицита факторов VIII, IX, XI, XII. Реагент: разведённые '
              'фосфолипиды и контактный активатор (кремнезём, эллаговая '
              'кислота, каолин), затем хлорид кальция; время в секундах.',
          'en':
              'Detects deficiencies or inhibitors of intrinsic and common '
              'pathway factors. With a normal PT it is the most useful screen '
              'for deficiencies of factors VIII, IX, XI and XII. Reagent: '
              'diluted phospholipid plus a contact activator (silica, ellagic '
              'acid, kaolin), then calcium chloride; time in seconds.',
        }),
        [_w5Aptt],
      ),
    ],
    notes: [
      CgFact(
        _T({
          'uz':
              'Qo‘llanilishi: qon ketish/ko‘karish sababini izlash (masalan, '
              'gemofiliya), geparin bilan davolashni kuzatish, lupus va '
              'antifosfolipid sindromi bilan bog‘liq ivish muammolari.',
          'ru':
              'Применение: поиск причины кровотечений/синяков (например, '
              'гемофилия), контроль терапии гепарином, нарушения свёртывания '
              'при волчанке и антифосфолипидном синдроме.',
          'en':
              'Uses: finding the cause of bleeding or bruising (e.g. '
              'haemophilia), monitoring heparin, clotting problems with lupus '
              'and antiphospholipid syndrome.',
        }),
        [_mlPttUse],
      ),
      CgFact(
        _T({
          'uz':
              'Uzayishi: gemofiliya A yoki B, fon Villebrand kasalligi, jigar '
              'kasalligi, vitamin K yetishmovchiligi, ortiqcha geparin, lupus '
              'antikoagulyanti, ba’zi leykozlar. Qisqarishi: DIC ning erta '
              'bosqichi, yallig‘lanish/homiladorlikda omillar ko‘payishi.',
          'ru':
              'Удлинение: гемофилия A или B, болезнь Виллебранда, болезнь '
              'печени, дефицит витамина K, избыток гепарина, волчаночный '
              'антикоагулянт, некоторые лейкозы. Укорочение: ранняя стадия '
              'ДВС, повышение факторов при воспалении, беременности.',
          'en':
              'Prolonged in haemophilia A or B, von Willebrand disease, liver '
              'disease, vitamin K deficiency, excess heparin, lupus '
              'anticoagulant and some leukaemias. Shortened in early DIC and '
              'with raised clotting factors (inflammation, pregnancy).',
        }),
        [_mlPttRes],
      ),
      CgFact(
        _T({
          'uz':
              'Reagentlar sezgirligi turlicha; ellag kislotali reagentda '
              'prekallikrein yoki YuMK yetishmovchiligida ham APTT me’yorda '
              'bo‘lishi mumkin. O‘tkir fazada VIII ko‘tarilsa, IX yoki XI '
              'kamayishini “yashirishi” mumkin — anamnez qon ketishga ishora '
              'qilsa, me’yoriy APTTda ham omil tahlillari asosli.',
          'ru':
              'Чувствительность реагентов различна; с реагентом на эллаговой '
              'кислоте АЧТВ может быть нормальным даже при дефиците '
              'прекалликреина или ВМК. Повышенный в острой фазе фактор VIII '
              'может «маскировать» снижение IX или XI — при кровоточивости в '
              'анамнезе анализ факторов оправдан и при нормальном АЧТВ.',
          'en':
              'Reagent sensitivity varies; with an ellagic-acid reagent the '
              'APTT can be normal even in PKK or HMWK deficiency. A raised '
              'acute-phase FVIII can mask reduced FIX or FXI — with a bleeding '
              'history, factor assays may be justified despite a normal APTT.',
        }),
        [_w5Aptt],
      ),
    ],
  ),
  CgTest(
    id: 'tt',
    name: _T({
      'uz': 'Trombin vaqti (TT)',
      'ru': 'Тромбиновое время (ТВ)',
      'en': 'Thrombin time (TT)',
    }),
    measures: [
      CgFact(
        _T({
          'uz':
              'Trombin bilan fibrinogen o‘rtasidagi reaksiyani aks ettiradi. '
              'Uzayadi: fibrinogen juda past (< 1,0 g/l), geparin yoki '
              'geparinsimon moddalar, to‘g‘ridan-to‘g‘ri trombin '
              'ingibitorlari, fibrin/fibrinogen parchalanish mahsulotlari, '
              'disfibrinogenemiya (tug‘ma yoki jigar kasalligida).',
          'ru':
              'Отражает реакцию тромбина с фибриногеном. Удлиняется при очень '
              'низком фибриногене (< 1,0 г/л), гепарине и гепариноподобных '
              'веществах, прямых ингибиторах тромбина, продуктах деградации '
              'фибрина/фибриногена, дисфибриногенемии (врождённой или при '
              'болезни печени).',
          'en':
              'Reflects the thrombin–fibrinogen reaction. Prolonged with very '
              'low fibrinogen (< 1.0 g/l), heparin or heparin-like '
              'substances, direct thrombin inhibitors, fibrin/fibrinogen '
              'degradation products and dysfibrinogenaemia (congenital or in '
              'liver disease).',
        }),
        [_w5Tt],
      ),
    ],
    notes: [
      CgFact(
        _T({
          'uz':
              'Manbadagi misol: trombin konsentratsiyasi normal plazma '
              'pulida taxminan 15 soniyada ivish beradigan qilib tanlanadi; '
              'natija shu reagent va analizatorga xos oraliq bilan beriladi. '
              'Namuna 4 soat ichida, geparin gumon qilinsa 2 soat ichida '
              'tekshiriladi.',
          'ru':
              'Пример из источника: концентрацию тромбина подбирают так, '
              'чтобы пул нормальной плазмы свёртывался примерно за 15 с; '
              'результат выдают с интервалом для данного реагента и '
              'анализатора. Пробу исследуют в течение 4 ч, при подозрении на '
              'гепарин — в течение 2 ч.',
          'en':
              'Source example: the thrombin is diluted to clot pooled normal '
              'plasma in about 15 s; results are reported with a range '
              'specific to the reagent and instrument. Test within 4 h, '
              'within 2 h if heparin is suspected.',
        }),
        [_w5Tt],
      ),
      CgFact(
        _T({
          'uz':
              'Uzaygan TT sababini ajratish: protamin sulfat qo‘shilganda '
              'nazoratdan 2 s ichiga qaytsa — geparin. Reptilaza vaqti '
              'geparin va trombin ingibitorlariga sezmaydi: TT uzaygan, '
              'reptilaza me’yorda — geparin yoki trombin ingibitori; ikkalasi '
              'teng uzaygan — gipo-/afibrinogenemiya yoki DIC.',
          'ru':
              'Причина удлинённого ТВ: если с протамина сульфатом ТВ '
              'возвращается в пределы 2 с от контроля — гепарин. Рептилазное '
              'время нечувствительно к гепарину и ингибиторам тромбина: ТВ '
              'удлинено, рептилазное в норме — гепарин или ингибитор '
              'тромбина; оба удлинены одинаково — гипо-/афибриногенемия или '
              'ДВС.',
          'en':
              'Telling causes apart: if protamine sulphate brings the TT back '
              'to within 2 s of the control, heparin is present. Reptilase '
              'time is unaffected by heparin and thrombin inhibitors: TT long '
              'with normal reptilase — heparin or a thrombin inhibitor; both '
              'equally long — hypo-/afibrinogenaemia or DIC.',
        }),
        [_w5Tt, _w5Rept],
      ),
    ],
  ),
  CgTest(
    id: 'fibrinogen',
    analyteId: 'fibrinogen',
    name: _T({
      'uz': 'Fibrinogen (Clauss usuli)',
      'ru': 'Фибриноген (метод Клаусса)',
      'en': 'Fibrinogen (Clauss method)',
    }),
    measures: [
      CgFact(
        _T({
          'uz':
              'Plazma 1:10 suyultiriladi va yuqori konsentratsiyali trombin '
              'qo‘shiladi; ivish vaqti fibrinogen konsentratsiyasiga bog‘liq '
              'va natija kalibrlash egri chizig‘idan o‘qiladi (egri mahalliy '
              'reagentlar bilan tuziladi).',
          'ru':
              'Плазму разводят 1:10 и добавляют тромбин высокой '
              'концентрации; время свёртывания зависит от концентрации '
              'фибриногена, результат читают по калибровочной кривой '
              '(строится на местных реагентах).',
          'en':
              'Plasma is diluted 1:10 and high-concentration thrombin is '
              'added; clotting time depends on fibrinogen concentration and '
              'the result is read from a calibration curve built with local '
              'reagents.',
        }),
        [_w5Clauss],
      ),
    ],
    notes: [
      CgFact(
        _T({
          'uz':
              'Ko‘p fibrin/fibrinogen parchalanish mahsulotlari va yuqori '
              'dozali fraksiyalanmagan geparin fibrinogenni soxta past '
              'ko‘rsatishi mumkin.',
          'ru':
              'Высокие продукты деградации фибрина/фибриногена и высокие дозы '
              'нефракционированного гепарина могут ложно занижать '
              'фибриноген.',
          'en':
              'High fibrin/fibrinogen degradation products and high-dose '
              'unfractionated heparin can falsely lower the result.',
        }),
        [_w5Clauss, _tohFib],
      ),
      CgFact(
        _T({
          'uz':
              'PT dan hisoblangan fibrinogen juda past (< 1,5 g/l) yoki '
              'yuqori (> 5 g/l) darajada va disfibrinogenemiyada Claussdan '
              'ancha yuqori chiqishi mumkin; yetishmovchilik skriningi va '
              'antikoagulyant olayotganlar uchun Clauss tavsiya etiladi.',
          'ru':
              'Фибриноген, рассчитанный по ПВ, при очень низком (< 1,5 г/л) '
              'или высоком (> 5 г/л) уровне и при дисфибриногенемии может '
              'быть намного выше, чем по Клауссу; для скрининга дефицита и у '
              'пациентов на антикоагулянтах рекомендуют метод Клаусса.',
          'en':
              'PT-derived fibrinogen can read much higher than Clauss at very '
              'low (< 1.5 g/l) or high (> 5 g/l) levels and in '
              'dysfibrinogenaemia; Clauss is recommended for deficiency '
              'screening and in patients on anticoagulants.',
        }),
        [_w5PtFib],
      ),
      CgFact(
        _T({
          'uz':
              'DIC da: < 1 g/l past sezgir (22 %), lekin juda o‘ziga xos '
              '(100 %); fibrinogen o‘tkir faza oqsili bo‘lgani uchun '
              'pasayish dinamikasi muhimroq.',
          'ru':
              'При ДВС: уровень < 1 г/л малочувствителен (22 %), но очень '
              'специфичен (100 %); поскольку фибриноген — белок острой фазы, '
              'важнее динамика снижения.',
          'en':
              'In DIC a level < 1 g/l has low sensitivity (22%) but high '
              'specificity (100%); as fibrinogen is an acute-phase reactant, '
              'a falling trend matters more.',
        }),
        [_tohFib],
      ),
    ],
  ),
  CgTest(
    id: 'ddimer',
    analyteId: 'd-dimer',
    name: _T({'uz': 'D-dimer', 'ru': 'D-димер', 'en': 'D-dimer'}),
    measures: [
      CgFact(
        _T({
          'uz':
              'D-dimer — qon laxtasi erigandagi oqsil bo‘lagi; organizm laxta '
              'hosil qilmayotgan yoki parchalamayotgan bo‘lsa, odatda qonda '
              'bo‘lmaydi. Chuqur vena trombozi, o‘pka emboliyasi, DIC ga '
              'shubhada va DIC davosini kuzatishda qo‘llanadi.',
          'ru':
              'D-димер — фрагмент белка, образующийся при растворении сгустка; '
              'обычно в крови не определяется, если в организме не '
              'образуются и не разрушаются сгустки. Применяют при подозрении '
              'на тромбоз глубоких вен, ТЭЛА, ДВС и для контроля лечения '
              'ДВС.',
          'en':
              'D-dimer is a protein fragment released when a clot dissolves; '
              'it is not usually found unless clots are being formed and '
              'broken down. Used when DVT, pulmonary embolism or DIC is '
              'suspected and to monitor DIC treatment.',
        }),
        [_mlDdUse],
      ),
    ],
    notes: [
      CgFact(
        _T({
          'uz':
              'Past/me’yoriy natija tromboz ehtimoli kamligini bildiradi '
              '(antikoagulyant soxta manfiy qilishi mumkin). Yuqori natija '
              'faqat trombozda emas: homiladorlik, yurak kasalligi, '
              'revmatoid artrit, yaqinda operatsiya, keksalik, harakatsizlik.',
          'ru':
              'Низкий/нормальный результат означает, что тромбоз маловероятен '
              '(антикоагулянты могут дать ложноотрицательный). Высокий — не '
              'только при тромбозе: беременность, болезни сердца, '
              'ревматоидный артрит, недавняя операция, пожилой возраст, '
              'иммобилизация.',
          'en':
              'A low/normal result means a clotting disorder is unlikely '
              '(anticoagulants can cause a false negative). High levels are '
              'not only from clots: pregnancy, heart disease, rheumatoid '
              'arthritis, recent surgery, older age and immobility.',
        }),
        [_mlDdRes],
      ),
      CgFact(
        _T({
          'uz':
              'Turli tijorat testlari me’yorlari turlicha va bir-birini '
              'almashtirmaydi; ko‘p testlar venoz tromboembolizmni '
              'istisno qilish uchun ishlab chiqilgan. Buyrak/jigar '
              'yetishmovchiligida tozalanish sekinlashib, daraja oshishi '
              'mumkin.',
          'ru':
              'Нормы разных коммерческих тестов различаются и '
              'невзаимозаменяемы; большинство тестов разработано для '
              'исключения ВТЭ. При почечной/печёночной недостаточности '
              'уровень может расти из-за замедленного выведения.',
          'en':
              'Commercial assays have different, non-interchangeable normal '
              'ranges; most were developed to exclude venous '
              'thromboembolism. Renal or liver impairment can raise levels '
              'through reduced clearance.',
        }),
        [_tohFrm],
      ),
    ],
  ),
];

// ───────────────────────── 2. Namuna va preanalitika ─────────────────────────

const cgSampleSections = <CgSection>[
  CgSection(
    _T({
      'uz': 'Probirka va antikoagulyant',
      'ru': 'Пробирка и антикоагулянт',
      'en': 'Tube and anticoagulant',
    }),
    [
      CgFact(
        _T({
          'uz':
              'Natriy sitrat 0,105–0,109 mol/l (3,2 %). Laboratoriya bitta '
              'sitrat konsentratsiyasi va bitta probirka turidan foydalanib, '
              'me’yoriy oraliqni shunga tuzadi; plastik va shisha probirkalar '
              'o‘zaro almashtirilmaydi.',
          'ru':
              'Цитрат натрия 0,105–0,109 моль/л (3,2 %). Лаборатория '
              'использует одну концентрацию цитрата и один тип пробирок и '
              'строит на них референтный интервал; пластиковые и стеклянные '
              'пробирки не взаимозаменяемы.',
          'en':
              'Sodium citrate 0.105–0.109 mol/l (3.2%). The laboratory uses '
              'one citrate concentration and one tube type and builds its '
              'reference interval on them; plastic and glass tubes are not '
              'interchangeable.',
        }),
        [_w3Collect, _mgTubes],
      ),
      CgFact(
        _T({
          'uz':
              '3,8 % sitrat kalsiyni ko‘proq bog‘laydi: me’yor 3,2 % bo‘yicha '
              'tuzilgan bo‘lsa, PT va APTT uzayib, fibrinogen past chiqishi '
              'mumkin; INR odatda yuqoriroq bo‘ladi.',
          'ru':
              '3,8 % цитрат сильнее связывает кальций: если норма построена '
              'для 3,2 %, ПВ и АЧТВ могут удлиняться, фибриноген — '
              'занижаться; МНО обычно выше.',
          'en':
              '3.8% citrate binds more calcium: if the reference interval is '
              'based on 3.2%, PT and APTT may be prolonged and fibrinogen '
              'underestimated; INR values tend to be higher.',
        }),
        [_mgTubes, _oacInr],
      ),
    ],
  ),
  CgSection(
    _T({'uz': 'Qon olish', 'ru': 'Взятие крови', 'en': 'Drawing the sample'}),
    [
      CgFact(
        _T({
          'uz':
              'Igna: kattalarda 19–21G (Magnette: 19–22G), bolalarda 22–23G. '
              'Jgut birinchi probirka to‘la boshlashi bilan bo‘shatiladi '
              '(< 1 daqiqa) — uzoq jgut gemokonsentratsiya, fibrinogen va '
              'VII, VIII, XII omillar oshishiga olib keladi.',
          'ru':
              'Игла: у взрослых 19–21G (Magnette: 19–22G), у детей 22–23G. '
              'Жгут снимают, как только начинает заполняться первая пробирка '
              '(< 1 мин): долгий жгут даёт гемоконцентрацию, рост '
              'фибриногена и факторов VII, VIII, XII.',
          'en':
              'Needle: 19–21G in adults (Magnette: 19–22G), 22–23G in '
              'children. Release the tourniquet as the first tube starts to '
              'fill (< 1 min) — prolonged stasis raises fibrinogen and '
              'factors VII, VIII and XII through haemoconcentration.',
        }),
        [_w3Collect, _mgBlood],
      ),
      CgFact(
        _T({
          'uz':
              'Tartib: qon ekmasi/steril probirka → koagulyatsiya → oddiy/gel '
              '→ qo‘shimchali probirkalar (EDTA, geparin aralashib ketmasin). '
              'Oddiy koagulogramma uchun “tashlab yuboriladigan” probirka '
              'shart emas, lekin “kapalak” yoki kateterdan olinganda kerak — '
              'aks holda nay havosi probirkani kam to‘ldiradi.',
          'ru':
              'Порядок: гемокультура/стерильные → коагуляционные → '
              'простые/гелевые → пробирки с добавками (не допускать переноса '
              'ЭДТА, гепарина). Для рутинной коагулограммы «сбросная» '
              'пробирка не нужна, но нужна при взятии через «бабочку» или '
              'катетер — иначе воздух трубки приводит к недоливу.',
          'en':
              'Order: blood culture/sterile → coagulation → plain/gel → '
              'additive tubes (to avoid EDTA or heparin carry-over). A '
              'discard tube is not needed for routine tests, but is needed '
              'with butterfly sets or catheters — the tubing air otherwise '
              'underfills the tube.',
        }),
        [_mgOrder, _w3Collect],
      ),
      CgFact(
        _T({
          'uz':
              'Shpritsdan probirka tiqinini teshib qon o‘tkazish gemolizga '
              'olib keladi — tavsiya etilmaydi. Ko‘pik va pufaksiz, erkin '
              'oqim bilan olinadi; qiyin olingan bo‘lsa, bu yozib qo‘yiladi.',
          'ru':
              'Перенос крови из шприца с прокалыванием пробки вызывает '
              'гемолиз — так делать не следует. Кровь берут без пены и '
              'пузырей, свободным током; о трудном взятии делают отметку.',
          'en':
              'Transferring blood from a syringe by piercing the stopper '
              'causes haemolysis and should be avoided. Draw without foam or '
              'bubbles with free flow; record a difficult draw.',
        }),
        [_mgBlood],
      ),
    ],
  ),
  CgSection(
    _T({
      'uz': 'To‘ldirish chizig‘i (9:1) va gematokrit',
      'ru': 'Метка заполнения (9:1) и гематокрит',
      'en': 'Fill line (9:1) and haematocrit',
    }),
    [
      CgFact(
        _T({
          'uz':
              'Qon : sitrat = 9 : 1. Manbalar chegarasi farq qiladi: WFH '
              '(ICSH 2021 ga tayanib) — kamida 80 % nominal hajm; Magnette '
              '2016 — > 90 % yoki probirkadagi belgigacha. Kam to‘ldirishda '
              'ortiqcha sitrat ivish vaqtini uzaytiradi.',
          'ru':
              'Кровь : цитрат = 9 : 1. Пороги в источниках различаются: WFH '
              '(со ссылкой на ICSH 2021) — не менее 80 % номинального '
              'объёма; Magnette 2016 — > 90 % или до метки на пробирке. При '
              'недоливе избыток цитрата удлиняет время свёртывания.',
          'en':
              'Blood : citrate = 9 : 1. Sources differ on the threshold: WFH '
              '(citing ICSH 2021) — at least 80% of nominal volume; Magnette '
              '2016 — > 90% or to the tube’s mark. Underfilling leaves excess '
              'citrate and prolongs clotting times.',
        }),
        [_w3Collect, _mgFill],
      ),
      CgFact(
        _T({
          'uz':
              'Bitta tadqiqot (Magnette keltirgan): 89 % dan kam to‘ldirishda '
              'APTT, 78 % dan kamda fibrinogen, 67 % dan kamda VIII omil '
              'klinik ahamiyatli siljiydi; PT 67 % da ham nisbatan ishonchli.',
          'ru':
              'По данным, приведённым у Magnette: при заполнении < 89 % '
              'клинически значимо смещается АЧТВ, < 78 % — фибриноген, '
              '< 67 % — фактор VIII; ПВ относительно надёжно даже при 67 %.',
          'en':
              'Data cited by Magnette: below 89% fill the APTT shows a '
              'clinically significant bias, below 78% fibrinogen, below 67% '
              'factor VIII; the PT stays relatively reliable even at 67%.',
        }),
        [_mgFill],
      ),
      CgFact(
        _T({
          'uz':
              'Gematokrit > 55 % bo‘lsa, 9:1 nisbatini saqlash uchun sitrat '
              'hajmi kamaytiriladi: C = 1,85·10⁻³ × (100 − Ht) × V, bunda C — '
              'sitrat (ml), V — qon (ml), Ht — gematokrit (%). Manbadagi '
              'misol: Ht 70 %, V 4,5 ml → C ≈ 0,25 ml.',
          'ru':
              'При гематокрите > 55 % объём цитрата уменьшают, чтобы '
              'сохранить 9:1: C = 1,85·10⁻³ × (100 − Ht) × V, где C — цитрат '
              '(мл), V — кровь (мл), Ht — гематокрит (%). Пример источника: '
              'Ht 70 %, V 4,5 мл → C ≈ 0,25 мл.',
          'en':
              'With haematocrit > 55% the citrate volume is reduced to keep '
              '9:1: C = 1.85×10⁻³ × (100 − Hct) × V, where C is citrate (ml), '
              'V blood (ml), Hct haematocrit (%). Source example: Hct 70%, '
              'V 4.5 ml → C ≈ 0.25 ml.',
        }),
        [_w3Formula],
      ),
    ],
  ),
  CgSection(
    _T({
      'uz': 'Aralashtirish, tashish, sentrifuga',
      'ru': 'Перемешивание, доставка, центрифугирование',
      'en': 'Mixing, transport, centrifugation',
    }),
    [
      CgFact(
        _T({
          'uz':
              'Olingandan keyin darhol 3–6 marta to‘liq ag‘darib aralashtiring '
              '(WFH: 3–5 marta); silkitmang — gemoliz va faollashuv ivish '
              'vaqtini qisqartirishi mumkin.',
          'ru':
              'Сразу после взятия 3–6 раз полностью переверните пробирку '
              '(WFH: 3–5 раз); не встряхивайте — гемолиз и активация могут '
              'укорачивать время свёртывания.',
          'en':
              'Immediately invert 3–6 times end-over-end (WFH: 3–5 times); do '
              'not shake — haemolysis and activation can shorten clotting '
              'times.',
        }),
        [_mgMix, _w3Collect],
      ),
      CgFact(
        _T({
          'uz':
              'Xona haroratida (15–25 °C), tik holatda, yopiq, imkon qadar '
              'tez (afzali 1 soat ichida) tashiladi. Sovutish tavsiya '
              'etilmaydi: fon Villebrand omili va VIII soxta past chiqishi '
              'mumkin.',
          'ru':
              'Доставка при комнатной температуре (15–25 °C), вертикально, '
              'закрытой, как можно быстрее (лучше в течение 1 ч). Охлаждение '
              'не рекомендуется: фактор Виллебранда и VIII могут ложно '
              'снижаться.',
          'en':
              'Transport at room temperature (15–25 °C), upright, capped and '
              'as fast as possible (preferably within 1 h). Do not '
              'refrigerate: VWF and factor VIII can fall falsely.',
        }),
        [_mgTransport, _mgStorage],
      ),
      CgFact(
        _T({
          'uz':
              'Trombotsitga kambag‘al plazma: Magnette — 1500 g, kamida 15 '
              'daqiqa, tormozsiz; WFH (CLSI 2024) — > 1700 g, 10 daqiqa. '
              'Sovutgichli sentrifugadan qoching. Muzlatiladigan plazma ikki '
              'marta sentrifugalanadi (trombotsit < 10×10⁹/l).',
          'ru':
              'Бедная тромбоцитами плазма: Magnette — 1500 g не менее 15 мин '
              'без тормоза; WFH (CLSI 2024) — > 1700 g 10 мин. Избегайте '
              'охлаждаемой центрифуги. Плазму для заморозки центрифугируют '
              'дважды (тромбоциты < 10×10⁹/л).',
          'en':
              'Platelet-poor plasma: Magnette — 1500 g for at least 15 min, '
              'brake off; WFH (CLSI 2024) — > 1700 g for 10 min. Avoid '
              'refrigerated centrifuges. Plasma to be frozen is '
              'double-spun (platelets < 10×10⁹/l).',
        }),
        [_mgCentr, _w3Ppp],
      ),
    ],
  ),
  CgSection(
    _T({
      'uz': 'Tekshirishgacha vaqt',
      'ru': 'Время до исследования',
      'en': 'Time to testing',
    }),
    [
      CgFact(
        _T({
          'uz':
              'Umumiy qoida — 4 soat ichida (mahalliy ma’lumot uzoqroq '
              'barqarorlikni tasdiqlamasa). PT/INR namunasi xona haroratida '
              '24 soatgacha barqaror; APTT — 4 soat ichida yangi plazmada.',
          'ru':
              'Общее правило — в течение 4 ч (если местные данные не '
              'подтверждают большую стабильность). Проба для ПВ/МНО стабильна '
              'до 24 ч при комнатной температуре; АЧТВ — в течение 4 ч на '
              'свежей плазме.',
          'en':
              'General rule: within 4 h unless local data confirm longer '
              'stability. PT/INR samples are stable up to 24 h at room '
              'temperature; APTT within 4 h on fresh plasma.',
        }),
        [_w3Storage, _mgStorage],
      ),
      CgFact(
        _T({
          'uz':
              'Fraksiyalanmagan geparin olayotgan bemor: trombotsit omili 4 '
              'geparinni neytrallaydi — sitratli probirka 1 soat ichida '
              'sentrifugalanib, 4 soat ichida tekshiriladi.',
          'ru':
              'Пациент на нефракционированном гепарине: тромбоцитарный фактор '
              '4 нейтрализует гепарин — цитратную пробирку центрифугируют в '
              'течение 1 ч и исследуют в течение 4 ч.',
          'en':
              'Patients on unfractionated heparin: platelet factor 4 '
              'neutralises heparin — centrifuge the citrate tube within 1 h '
              'and test within 4 h.',
        }),
        [_w3Storage, _mgStorage],
      ),
      CgFact(
        _T({
          'uz':
              'Ajratilgan plazma: PT/INR uchun sovutilmaydi (sovuqda VII '
              'faollashib, PT qisqarishi mumkin). Uzoq saqlash: −24 °C da 3 '
              'oy, ~6 oy uchun −70 °C; eritish 37 °C suv hammomida 3–5 '
              'daqiqa, qayta muzlatilmaydi.',
          'ru':
              'Отделённая плазма для ПВ/МНО не охлаждается (холодовая '
              'активация VII может укорачивать ПВ). Длительное хранение: '
              '−24 °C — 3 мес., около 6 мес. — −70 °C; оттаивание в водяной '
              'бане 37 °C 3–5 мин, повторно не замораживать.',
          'en':
              'Separated plasma for PT/INR is not refrigerated (cold '
              'activation of FVII can shorten the PT). Longer storage: −24 °C '
              'for 3 months, −70 °C for about 6 months; thaw at 37 °C for '
              '3–5 min and do not refreeze.',
        }),
        [_mgStorage, _w3Storage],
      ),
    ],
  ),
];

/// Ko'p uchraydigan preanalitik xatolar.
const cgErrors = <CgFact>[
  CgFact(
    _T({
      'uz':
          'Kam to‘ldirilgan probirka yoki gematokrit > 55 % da sitrat '
          'tuzatilmagan — 9:1 buziladi, PT va APTT uzayadi.',
      'ru':
          'Недолив пробирки или неисправленный цитрат при гематокрите '
          '> 55 % — нарушается 9:1, удлиняются ПВ и АЧТВ.',
      'en':
          'Underfilled tube, or citrate not adjusted for haematocrit > 55% — '
          'the 9:1 ratio is lost and PT and APTT lengthen.',
    }),
    [_mgFill, _w3Collect],
  ),
  CgFact(
    _T({
      'uz':
          'Gemoliz: ayniqsa APTT o‘zgaradi (uzayishi yoki qisqarishi), PT va '
          'D-dimer oshishi, antitrombin va fibrinogen pasayishi mumkin; WFH — '
          'gemolizlangan namuna tekshirilmaydi (tomir ichidagi gemolizdan '
          'tashqari).',
      'ru':
          'Гемолиз: особенно меняется АЧТВ (удлинение или укорочение), '
          'возможны рост ПВ и D-димера, снижение антитромбина и фибриногена; '
          'WFH — гемолизированную пробу не исследуют (кроме '
          'внутрисосудистого гемолиза).',
      'en':
          'Haemolysis: APTT is affected most (longer or shorter); PT and '
          'D-dimer may rise, antithrombin and fibrinogen fall; WFH: do not '
          'test haemolysed samples (except with intravascular haemolysis).',
    }),
    [_mgExam, _w3Interf],
  ),
  CgFact(
    _T({
      'uz':
          'Laxta (in vitro): sekin to‘lish, uzoq jgut, tomirni ko‘p '
          'paypaslash sabab; laxtali namuna qabul qilinmaydi.',
      'ru':
          'Сгусток in vitro: медленное заполнение, долгий жгут, многократные '
          'попытки пункции; проба со сгустком отклоняется.',
      'en':
          'In-vitro clot: slow filling, prolonged tourniquet, repeated '
          'needle manipulation; a clotted sample is rejected.',
    }),
    [_mgExam, _mgReject],
  ),
  CgFact(
    _T({
      'uz':
          'Noto‘g‘ri tartib yoki ifloslanish (EDTA, geparin, ivish '
          'faollashtiruvchi) — natija xato, qayta olish kerak. Geparinli '
          'kateterdan olingan namuna ham xato beradi.',
      'ru':
          'Неверный порядок или контаминация (ЭДТА, гепарин, активатор '
          'свёртывания) — результат ошибочен, нужна повторная проба. Проба из '
          'гепаринизированного катетера также искажает результат.',
      'en':
          'Wrong order of draw or contamination (EDTA, heparin, clot '
          'activator) gives erroneous results and needs a redraw; samples '
          'from heparin-contaminated lines also mislead.',
    }),
    [_mgOrder, _w5Clauss],
  ),
  CgFact(
    _T({
      'uz':
          'Sovutilgan butun qon (VIII, fon Villebrand omili soxta past — '
          'gemofiliya A yoki fVk ga noto‘g‘ri shubha), kechikish (V, VIII '
          'labil omillar kamayadi), tushib ketgan namuna — rad etiladi.',
      'ru':
          'Охлаждённая цельная кровь (ложно низкие VIII и фактор Виллебранда '
          '— ложное подозрение на гемофилию A или БВ), задержка (снижение '
          'лабильных V, VIII), упавшая пробирка — отклоняется.',
      'en':
          'Refrigerated whole blood (falsely low FVIII and VWF — false '
          'suspicion of haemophilia A or VWD), delay (loss of labile FV and '
          'FVIII), and a dropped tube — reject.',
    }),
    [_mgStorage, _mgTransport],
  ),
  CgFact(
    _T({
      'uz':
          'Lipemiya va ikterus optik o‘qishga xalaqit berishi mumkin — '
          'mexanik usul yoki lipidni kamaytirish; WFH: odatiy testlarga '
          'ikterus odatda ta’sir qilmaydi.',
      'ru':
          'Липемия и иктеричность могут мешать оптическому детектированию — '
          'механический метод или удаление липидов; WFH: на рутинные тесты '
          'иктеричность обычно не влияет.',
      'en':
          'Lipaemia and icterus may interfere with optical detection — use '
          'mechanical detection or lipid removal; WFH: icterus usually does '
          'not affect routine assays.',
    }),
    [_mgExam, _w3Interf],
  ),
  CgFact(
    _T({
      'uz':
          'Bemor omillari: stress va jismoniy yuklama VIII va fVo ni '
          'vaqtincha oshiradi, homiladorlik fibrinogen, VII, VIII, X, fVo va '
          'D-dimerni oshiradi; dori-darmonlar haqida ma’lumot laboratoriya '
          'uchun zarur.',
      'ru':
          'Факторы пациента: стресс и нагрузка временно повышают VIII и VWF, '
          'беременность — фибриноген, VII, VIII, X, VWF и D-димер; сведения '
          'о лекарствах необходимы лаборатории.',
      'en':
          'Patient factors: stress and exercise transiently raise FVIII and '
          'VWF; pregnancy raises fibrinogen, FVII, FVIII, FX, VWF and '
          'D-dimer; the laboratory needs the drug history.',
    }),
    [_w3Collect, _mgPatient],
  ),
];

// ───────────────────────── 3. O'qish yordamchisi ─────────────────────────

/// PT va APTT birikmasi.
enum CgPattern { ptOnly, apttOnly, both, normal }

class CgPatternInfo {
  const CgPatternInfo(this.label, this.causes, this.next);

  final LocalizedText label;

  /// Manbada keltirilgan ehtimoliy sabablar.
  final List<CgFact> causes;

  /// Manbada keltirilgan keyingi qadam.
  final List<CgFact> next;

  List<CgFact> get facts => [...causes, ...next];
}

const cgPatternInfo = <CgPattern, CgPatternInfo>{
  CgPattern.ptOnly: CgPatternInfo(
    _T({
      'uz': 'Faqat PT uzaygan (APTT me’yorda)',
      'ru': 'Удлинено только ПВ (АЧТВ в норме)',
      'en': 'PT prolonged, APTT normal',
    }),
    [
      CgFact(
        _T({
          'uz':
              'Omil darajasida: VII omil yetishmovchiligi — PT anormal, APTT '
              'me’yorda (WFH 8-jadval).',
          'ru':
              'На уровне факторов: дефицит фактора VII — ПВ изменено, АЧТВ в '
              'норме (WFH, табл. 8).',
          'en':
              'At factor level: factor VII deficiency — abnormal PT, normal '
              'APTT (WFH Table 8).',
        }),
        [_w5Mix],
      ),
      CgFact(
        _T({
          'uz':
              'PTni uzaytiruvchi holatlar: VKA (varfarin), jigar kasalligi, '
              'vitamin K yetishmovchiligi, DIC, peroral antikoagulyantlar, '
              'tashqi yo‘l omillariga antitanalar; ba’zi PT reagentlari lupus '
              'antikoagulyantiga sezgir.',
          'ru':
              'Состояния, удлиняющие ПВ: АВК (варфарин), болезнь печени, '
              'дефицит витамина K, ДВС, прямые оральные антикоагулянты, '
              'антитела к факторам внешнего пути; часть реагентов ПВ '
              'чувствительна к волчаночному антикоагулянту.',
          'en':
              'Conditions that prolong the PT: VKA (warfarin), liver disease, '
              'vitamin K deficiency, DIC, oral anticoagulants, antibodies to '
              'extrinsic factors; some PT reagents are sensitive to lupus '
              'anticoagulant.',
        }),
        [_w5Pt, _mlPtRes],
      ),
    ],
    [
      CgFact(
        _T({
          'uz':
              '1:1 aralashtirish testi: normal plazma bilan to‘g‘rilansa — '
              'omil yetishmovchiligi; to‘g‘rilanmasa — ingibitor. '
              'To‘g‘rilanish chegarasini har laboratoriya o‘zi belgilaydi.',
          'ru':
              'Тест смешивания 1:1: коррекция нормальной плазмой — дефицит '
              'фактора; нет коррекции — ингибитор. Порог коррекции каждая '
              'лаборатория устанавливает сама.',
          'en':
              '1:1 mixing test: correction with normal plasma suggests factor '
              'deficiency, no correction an inhibitor. Each laboratory sets '
              'its own correction cut-off.',
        }),
        [_w5Mix],
      ),
    ],
  ),
  CgPattern.apttOnly: CgPatternInfo(
    _T({
      'uz': 'Faqat APTT uzaygan (PT me’yorda)',
      'ru': 'Удлинено только АЧТВ (ПВ в норме)',
      'en': 'APTT prolonged, PT normal',
    }),
    [
      CgFact(
        _T({
          'uz':
              'VIII, IX, XI, XII omillar, YuMK, prekallikrein yetishmovchiligi '
              'yoki ingibitor (lupus antikoagulyanti kabi); geparin ham '
              'APTTni uzaytiradi. XII yetishmovchiligi qon ketish xavfi bilan '
              'bog‘liq emas.',
          'ru':
              'Дефицит факторов VIII, IX, XI, XII, ВМК, прекалликреина или '
              'ингибитор (например, волчаночный антикоагулянт); гепарин тоже '
              'удлиняет АЧТВ. Дефицит XII не связан с риском кровотечения.',
          'en':
              'Deficiency of factors VIII, IX, XI, XII, HMWK or PKK, or an '
              'inhibitor (such as lupus anticoagulant); heparin also prolongs '
              'the APTT. FXII deficiency carries no increased bleeding risk.',
        }),
        [_w5Aptt],
      ),
      CgFact(
        _T({
          'uz':
              'Klinik nomlar: gemofiliya A yoki B, fon Villebrand kasalligi, '
              'ortiqcha geparin, lupus antikoagulyanti.',
          'ru':
              'Клинически: гемофилия A или B, болезнь Виллебранда, избыток '
              'гепарина, волчаночный антикоагулянт.',
          'en':
              'Clinically: haemophilia A or B, von Willebrand disease, excess '
              'heparin, lupus anticoagulant.',
        }),
        [_mlPttRes],
      ),
    ],
    [
      CgFact(
        _T({
          'uz':
              'WFH tartibi: avval trombin vaqti (uzaygan bo‘lsa — protamin '
              'bilan; to‘g‘rilansa geparin, bemor geparin olmasa qayta '
              'namuna); so‘ng 1:1 aralashma (50 % dan ko‘p to‘g‘rilanish — '
              'yetishmovchilik, yomon — ingibitor); fosfolipidi yuqori '
              'ikkinchi reagent; VIII, IX, XI tahlillari.',
          'ru':
              'Порядок WFH: сначала тромбиновое время (если удлинено — с '
              'протамином; коррекция = гепарин, при отсутствии гепарина у '
              'пациента — повторная проба); затем смесь 1:1 (коррекция более '
              '50 % — дефицит, плохая — ингибитор); второй реагент с высоким '
              'фосфолипидом; анализ VIII, IX, XI.',
          'en':
              'WFH sequence: thrombin time first (if long, repeat with '
              'protamine; correction = heparin; if the patient is not on '
              'heparin, request a new sample); then a 1:1 mix (> 50% '
              'correction = deficiency, poor = inhibitor); a second, '
              'high-phospholipid reagent; FVIII, FIX and FXI assays.',
        }),
        [_w5Aptt],
      ),
    ],
  ),
  CgPattern.both: CgPatternInfo(
    _T({
      'uz': 'PT ham, APTT ham uzaygan',
      'ru': 'Удлинены и ПВ, и АЧТВ',
      'en': 'Both PT and APTT prolonged',
    }),
    [
      CgFact(
        _T({
          'uz':
              'Umumiy yo‘l: II, V, X omillar yetishmovchiligi — PT va APTT '
              'ikkalasi anormal (WFH 8-jadval); APTT fibrinogen '
              'yetishmovchiligida ham uzayadi.',
          'ru':
              'Общий путь: дефицит факторов II, V, X — изменены и ПВ, и АЧТВ '
              '(WFH, табл. 8); АЧТВ удлиняется и при дефиците фибриногена.',
          'en':
              'Common pathway: deficiency of factor II, V or X — both PT and '
              'APTT abnormal (WFH Table 8); the APTT is also prolonged in '
              'fibrinogen deficiency.',
        }),
        [_w5Mix, _w5Aptt],
      ),
      CgFact(
        _T({
          'uz':
              'Ikkala test ro‘yxatida ham keltirilgan holatlar: jigar '
              'kasalligi va vitamin K yetishmovchiligi; DIC da ham PT, ham '
              'APTT tahlil qilinadi (lekin APTT kech uzayishi mumkin).',
          'ru':
              'Состояния, названные в обоих списках: болезнь печени и дефицит '
              'витамина K; при ДВС оценивают и ПВ, и АЧТВ (но АЧТВ может '
              'удлиняться с запозданием).',
          'en':
              'Conditions named for both tests: liver disease and vitamin K '
              'deficiency; in DIC both PT and APTT are assessed (though APTT '
              'prolongation may lag).',
        }),
        [_mlPtRes, _mlPttRes, _tohPt],
      ),
    ],
    [
      CgFact(
        _T({
          'uz':
              'Fibrinogen (Clauss) va trombin vaqti; DIC ga mos klinik holat '
              'bo‘lsa — ISTH balini hisoblang (trombotsit, PT, fibrinogen, '
              'fibrin bilan bog‘liq marker).',
          'ru':
              'Фибриноген (Клаусс) и тромбиновое время; при клинике, '
              'совместимой с ДВС, — рассчитайте балл ISTH (тромбоциты, ПВ, '
              'фибриноген, фибрин-связанный маркер).',
          'en':
              'Fibrinogen (Clauss) and thrombin time; if the clinical setting '
              'fits DIC, calculate the ISTH score (platelets, PT, '
              'fibrinogen, a fibrin-related marker).',
        }),
        [_w5Tt, _tohGeneral],
      ),
    ],
  ),
  CgPattern.normal: CgPatternInfo(
    _T({
      'uz': 'PT va APTT me’yorda',
      'ru': 'ПВ и АЧТВ в норме',
      'en': 'PT and APTT normal',
    }),
    [
      CgFact(
        _T({
          'uz':
              'Me’yoriy APTT qon ketish kasalligini to‘liq istisno qilmaydi: '
              'VIII baland bo‘lsa, IX yoki XI ning yengil kamayishi '
              'ko‘rinmasligi mumkin.',
          'ru':
              'Нормальное АЧТВ не исключает полностью нарушение гемостаза: '
              'при высоком VIII лёгкое снижение IX или XI может не '
              'проявиться.',
          'en':
              'A normal APTT does not fully exclude a bleeding disorder: with '
              'a high FVIII, mild reductions of FIX or FXI can be missed.',
        }),
        [_w5Aptt],
      ),
    ],
    [
      CgFact(
        _T({
          'uz':
              'Anamnez qon ketishga ishora qilsa — omil tahlillari; fon '
              'Villebrand kasalligiga shubhada: VWF antigeni va faolligi, '
              'VIII, to‘liq qon tahlili (trombotsit soni va morfologiyasi), '
              'PT, APTT, TT, fibrinogen.',
          'ru':
              'При кровоточивости в анамнезе — анализ факторов; при подозрении '
              'на болезнь Виллебранда: антиген и активность VWF, VIII, общий '
              'анализ крови (число и морфология тромбоцитов), ПВ, АЧТВ, ТВ, '
              'фибриноген.',
          'en':
              'With a bleeding history — factor assays; if von Willebrand '
              'disease is suspected: VWF antigen and activity, FVIII, a full '
              'blood count (platelet count and morphology), PT, APTT, TT and '
              'fibrinogen.',
        }),
        [_w5Aptt, _w5Bt],
      ),
    ],
  ),
};

/// Trombotsitlar kam bo'lganda qo'shimcha izoh.
const cgLowPlateletsFact = CgFact(
  _T({
    'uz':
        'Trombotsitopeniya — DIC ning eng ko‘p uchraydigan laborator belgisi, '
        'lekin dori, gemodilyutsiya, ilik yetishmovchiligi, splenomegaliya '
        'yoki infeksiyadan ham bo‘lishi mumkin; bitta qiymatdan ko‘ra '
        'dinamika muhim.',
    'ru':
        'Тромбоцитопения — самый частый лабораторный признак ДВС, но может '
        'быть вызвана лекарствами, гемодилюцией, недостаточностью костного '
        'мозга, спленомегалией или инфекцией; важнее динамика, чем одно '
        'значение.',
    'en':
        'Thrombocytopenia is the commonest laboratory feature of DIC but may '
        'also be due to drugs, haemodilution, marrow failure, splenomegaly '
        'or infection; the trend matters more than one value.',
  }),
  [_tohPlt],
);

/// Trombotsit kam va PT uzaygan: jigar kasalligi bilan farqlash.
const cgLowPlateletsPtFact = CgFact(
  _T({
    'uz':
        'PT uzayishi va trombotsitopeniya jigar kasalligida ham bo‘ladi — '
        'fibrin bilan bog‘liq markerlar (D-dimer va b.) oshishi DIC ni '
        'aniqlashga yordam beradi.',
    'ru':
        'Удлинение ПВ и тромбоцитопения бывают и при болезни печени — '
        'повышение фибрин-связанных маркеров (D-димер и др.) помогает '
        'распознать ДВС.',
    'en':
        'Prolonged PT and thrombocytopenia also occur in liver disease — '
        'raised fibrin-related markers (D-dimer etc.) help to identify DIC.',
  }),
  [_tohFrm],
);

// ───────────────────────── 4. ISTH DIC bali ─────────────────────────

/// Hisoblagich oldidan: kim uchun va qanday.
const cgDicIntro = <CgFact>[
  CgFact(
    _T({
      'uz':
          'ISTH SSC (Taylor va boshq., 2001) ochiq DIC bali — Toh 2016 va '
          'Iba 2019 jadvallari bo‘yicha (asl maqola bu muhitda ochilmadi). '
          'Bal faqat ochiq DIC bilan bog‘liq asosiy kasalligi bor bemorda '
          'qo‘llanadi; global testlar: PT, trombotsit, fibrinogen, fibrin '
          'bilan bog‘liq marker.',
      'ru':
          'Балл явного ДВС ISTH SSC (Taylor и соавт., 2001) — по таблицам '
          'Toh 2016 и Iba 2019 (оригинальная статья в этой среде не '
          'открылась). Балл применяют только у пациента с основным '
          'заболеванием, связанным с явным ДВС; глобальные тесты: ПВ, '
          'тромбоциты, фибриноген, фибрин-связанный маркер.',
      'en':
          'ISTH SSC overt DIC score (Taylor et al., 2001) as tabulated by Toh '
          '2016 and Iba 2019 (the original paper could not be opened here). '
          'Use only in a patient with an underlying disorder associated with '
          'overt DIC; global tests: PT, platelet count, fibrinogen and a '
          'fibrin-related marker.',
    }),
    [_tohTable, _ibaTable],
  ),
  CgFact(
    _T({
      'uz':
          'Bitta marker yoki bitta qiymat bilan DIC tashxisi qo‘yilmaydi; '
          'turli vaqtdagi natijalar birikmasi va bemorning asosiy kasalligi '
          'hisobga olinadi.',
      'ru':
          'ДВС не диагностируют по одному маркеру или одному значению; '
          'учитывают сочетание результатов в разные моменты времени и '
          'основное заболевание.',
      'en':
          'DIC is not diagnosed from a single marker or value; results over '
          'time and the underlying disorder are considered together.',
    }),
    [_tohGeneral, _wadaDx],
  ),
];

/// Balning qismlari bo'yicha izohlar.
const cgDicPlatelets = CgFact(
  _T({
    'uz': 'Trombotsit (×10⁹/l): ≥ 100 — 0; < 100 — 1; < 50 — 2.',
    'ru': 'Тромбоциты (×10⁹/л): ≥ 100 — 0; < 100 — 1; < 50 — 2.',
    'en': 'Platelet count (×10⁹/l): ≥ 100 — 0; < 100 — 1; < 50 — 2.',
  }),
  [_tohTable, _ibaTable],
);
const cgDicFrm = CgFact(
  _T({
    'uz':
        'Fibrin bilan bog‘liq marker (D-dimer, FDP): oshmagan — 0; o‘rtacha '
        'oshgan — 2; keskin oshgan — 3. “O‘rtacha” va “keskin” chegaralarini '
        'laboratoriya o‘z testi uchun belgilaydi (Toh: masalan, reanimatsiya '
        'bemorlari namunalarining 25 % va 75 % kvartillari bo‘yicha).',
    'ru':
        'Фибрин-связанный маркер (D-димер, ПДФ): нет повышения — 0; умеренное '
        '— 2; выраженное — 3. Границы «умеренного» и «выраженного» '
        'лаборатория задаёт для своего теста (Toh: например, по квартилям '
        '25 % и 75 % проб пациентов реанимации).',
    'en':
        'Fibrin-related marker (D-dimer, FDP): no increase — 0; moderate — 2; '
        'strong — 3. The laboratory sets the moderate/strong cut-offs for '
        'its own assay (Toh: e.g. 25% and 75% quartiles from intensive-care '
        'samples).',
  }),
  [_tohTable, _tohFrm, _ibaTable],
);
const cgDicPt = CgFact(
  _T({
    'uz':
        'PT uzayishi (soniya): < 3 — 0; ≥ 3 va < 6 — 1; ≥ 6 — 2. Ochilgan '
        'jadvallarda uzayish nimaga nisbatan hisoblanishi (normal nazorat '
        'yoki me’yorning yuqori chegarasi) yozilmagan — laboratoriya '
        'protokoliga amal qiling. ISTH PTni afzal test deb tavsiya qiladi.',
    'ru':
        'Удлинение ПВ (секунды): < 3 — 0; ≥ 3 и < 6 — 1; ≥ 6 — 2. В '
        'открытых таблицах не указано, относительно чего считать удлинение '
        '(нормальный контроль или верхняя граница нормы) — следуйте '
        'протоколу лаборатории. ISTH рекомендует ПВ как тест выбора.',
    'en':
        'PT prolongation (seconds): < 3 — 0; ≥ 3 and < 6 — 1; ≥ 6 — 2. The '
        'tables opened here do not say whether prolongation is counted from '
        'the normal control or the upper reference limit — follow your '
        'laboratory protocol. ISTH recommends the PT as the test of choice.',
  }),
  [_tohTable, _ibaTable, _tohPt],
);
const cgDicFib = CgFact(
  _T({
    'uz': 'Fibrinogen (g/l): ≥ 1 — 0; < 1 — 1.',
    'ru': 'Фибриноген (г/л): ≥ 1 — 0; < 1 — 1.',
    'en': 'Fibrinogen (g/l): ≥ 1 — 0; < 1 — 1.',
  }),
  [_tohTable, _ibaTable],
);

/// Natija talqini — manba jadvalidagi kabi.
const cgDicOvert = CgFact(
  _T({
    'uz': '≥ 5: ochiq DIC bilan mos keladi — balni har kuni takrorlang.',
    'ru': '≥ 5: совместимо с явным ДВС — повторяйте подсчёт ежедневно.',
    'en': '≥ 5: compatible with overt DIC — repeat scoring daily.',
  }),
  [_tohTable, _ibaTable],
);
const cgDicNonOvert = CgFact(
  _T({
    'uz':
        '< 5: Toh 2016 jadvalida — “noochiq (non-overt) DIC ga ishora qilishi '
        'mumkin”, testlarni takrorlab kuzatish; “me’yoriy” kiritmalar '
        'kuzatuvni to‘xtatish uchun asos emas.',
    'ru':
        '< 5: в таблице Toh 2016 — «может указывать на неявный (non-overt) '
        'ДВС», наблюдение с повторением тестов; «нормальные» значения не '
        'повод прекращать мониторинг.',
    'en':
        '< 5: per Toh 2016 table — “suggestive of non-overt DIC”, keep '
        'repeating the tests; “normal” values are no reason to stop '
        'monitoring.',
  }),
  [_tohTable, _tohScore],
);

// ───────────────────────── 5. Monitoring ─────────────────────────

const cgMonitoringSections = <CgSection>[
  CgSection(
    _T({
      'uz': 'Varfarin (vitamin K antagonisti): INR',
      'ru': 'Варфарин (антагонист витамина K): МНО',
      'en': 'Warfarin (vitamin K antagonist): INR',
    }),
    [
      CgFact(
        _T({
          'uz':
              'VKA nazoratida PT eng ko‘p ishlatiladigan test; natija INR '
              'sifatida beriladi. Dastlabki kunlarda PT asosan VII omil '
              '(yarim umri ≈ 6 soat) kamayishini aks ettiradi.',
          'ru':
              'Для контроля АВК чаще всего используют ПВ; результат выдают '
              'как МНО. В первые дни ПВ отражает в основном снижение фактора '
              'VII (период полужизни ≈ 6 ч).',
          'en':
              'The PT is the most common test for monitoring VKAs, reported '
              'as INR. In the first days the PT mainly reflects the fall of '
              'factor VII (half-life ≈ 6 h).',
        }),
        [_oacInr],
      ),
      CgFact(
        _T({
          'uz':
              'Maqsadli oraliq ko‘rsatmaga bog‘liq; ko‘p ko‘rsatmalarda '
              'o‘rtacha intensivlik — INR taxminan 2,0–3,0 (1,5–2,0 kamroq '
              'samarali bo‘lgan). Maqsadni shifokor belgilaydi.',
          'ru':
              'Целевой диапазон зависит от показания; для многих — умеренная '
              'интенсивность, МНО около 2,0–3,0 (1,5–2,0 оказался менее '
              'эффективным). Цель определяет врач.',
          'en':
              'The target depends on the indication; for many it is '
              'moderate intensity, INR about 2.0–3.0 (1.5–2.0 was less '
              'effective). The clinician sets the target.',
        }),
        [_oacRange],
      ),
      CgFact(
        _T({
          'uz':
              'Laboratoriya kamida o‘rtacha sezgir (ISI < 1,7) tromboplastin '
              'va tasdiqlangan ISI li reagent/asbob juftligini qo‘llashi, '
              'o‘rtacha normal PTni har yangi seriya uchun aniqlashi kerak.',
          'ru':
              'Лаборатории следует применять как минимум умеренно '
              'чувствительный тромбопластин (МИЧ < 1,7) и пары '
              'реагент/прибор с подтверждённым МИЧ, определять среднее '
              'нормальное ПВ для каждой новой серии.',
          'en':
              'Laboratories should use at least moderately responsive '
              'thromboplastins (ISI < 1.7) with validated reagent/instrument '
              'ISI and determine the mean normal PT for each new batch.',
        }),
        [_oacInr],
      ),
    ],
  ),
  CgSection(
    _T({
      'uz': 'Geparin: APTT va anti-Xa',
      'ru': 'Гепарин: АЧТВ и анти-Xa',
      'en': 'Heparin: APTT and anti-Xa',
    }),
    [
      CgFact(
        _T({
          'uz':
              'Fraksiyalanmagan geparin: nazoratdan 1,5–2,5 marta uzun APTT '
              'oralig‘i keng tarqalgan, ammo randomizatsiyalangan '
              'tadqiqotlarda tasdiqlanmagan; javob reagent va koagulometrga '
              'bog‘liq — muassasa oralig‘ini o‘z reagenti va koagulometriga '
              'moslaydi; manba APTTni geparinning anti-Xa bo‘yicha 0,3–0,7 '
              'birlik/ml darajasi bilan solishtiradi.',
          'ru':
              'Нефракционированный гепарин: интервал АЧТВ в 1,5–2,5 раза '
              'больше контроля широко принят, но не подтверждён '
              'рандомизированными исследованиями; ответ зависит от реагента и '
              'коагулометра — учреждение адаптирует интервал к своему '
              'реагенту и коагулометру; источник сопоставляет АЧТВ с уровнем '
              'гепарина 0,3–0,7 ЕД/мл по анти-Xa.',
          'en':
              'Unfractionated heparin: an APTT of 1.5–2.5 times control is '
              'widely accepted but not confirmed by randomised trials; '
              'response varies with reagent and coagulometer, so each '
              'institution adapts its range; the source relates the APTT to '
              'heparin levels of 0.3–0.7 anti-Xa units/ml.',
        }),
        [_parUfh],
      ),
      CgFact(
        _T({
          'uz':
              'Past molekulyar geparin: ko‘pchilik bemorga monitoring '
              'kerak emas; zarur bo‘lsa — anti-Xa darajasi.',
          'ru':
              'Низкомолекулярный гепарин: большинству пациентов мониторинг не '
              'нужен; при необходимости — уровень анти-Xa.',
          'en':
              'Low-molecular-weight heparin: monitoring is not needed for most '
              'patients; when required, measure anti-Xa.',
        }),
        [_parLmwh],
      ),
      CgFact(
        _T({
          'uz':
              'Namuna: geparin olayotganlarda probirka 1 soat ichida '
              'sentrifugalanadi (trombotsit omili 4 geparinni '
              'neytrallaydi).',
          'ru':
              'Проба: у пациентов на гепарине пробирку центрифугируют в '
              'течение 1 ч (тромбоцитарный фактор 4 нейтрализует гепарин).',
          'en':
              'Sample: for patients on heparin, centrifuge within 1 h '
              '(platelet factor 4 neutralises heparin).',
        }),
        [_w3Storage],
      ),
    ],
  ),
  CgSection(
    _T({
      'uz': 'To‘g‘ridan-to‘g‘ri peroral antikoagulyantlar',
      'ru': 'Прямые оральные антикоагулянты',
      'en': 'Direct oral anticoagulants',
    }),
    [
      CgFact(
        _T({
          'uz':
              'Dabigatran: PT va APTT nisbatan sezgir emas, APTT bilan '
              'konsentratsiya bog‘lanishi chiziqli emas; odatiy trombin vaqti '
              'haddan tashqari sezgir — me’yoriy TT dabigatran yo‘qligini '
              'ko‘rsatadi.',
          'ru':
              'Дабигатран: ПВ и АЧТВ относительно нечувствительны, связь АЧТВ '
              'с концентрацией нелинейна; обычное тромбиновое время слишком '
              'чувствительно — нормальное ТВ исключает присутствие '
              'дабигатрана.',
          'en':
              'Dabigatran: PT and APTT are relatively insensitive and the '
              'APTT relation is non-linear; the usual thrombin time is '
              'oversensitive — a normal TT rules out dabigatran.',
        }),
        [_oacDabi],
      ),
      CgFact(
        _T({
          'uz':
              'Rivaroksaban: PT (soniya yoki nisbat) ham, APTT ham uning '
              'ta’sirini kuzatishda qo‘llanmasligi kerak; tromboplastinlar '
              'sezgirligi turlicha va INR buni to‘g‘rilamaydi.',
          'ru':
              'Ривароксабан: ни ПВ (в секундах или как отношение), ни АЧТВ не '
              'следует использовать для контроля его действия; '
              'чувствительность тромбопластинов различна, и МНО её не '
              'корректирует.',
          'en':
              'Rivaroxaban: neither the PT (seconds or ratio) nor the APTT '
              'should be used to monitor its effect; thromboplastin '
              'sensitivities differ and the INR does not correct for this.',
        }),
        [_oacRiva],
      ),
    ],
  ),
];

// ───────────────────────── Bog'liq taqdimot ─────────────────────────

const cgDeckId = 'gemostaz-uchun-venoz-qon-olish';
const cgDeckTitle = _T({
  'uz': 'Gemostaz tizimini tekshirish uchun qon olish va tayyorgarlik',
  'ru': 'Подготовка и взятие крови для исследования системы гемостаза',
  'en': 'Preparation and blood collection for haemostasis tests',
});

// ───────────────────────── Matnlar ─────────────────────────

abstract final class CgL {
  static const subtitle = _T({
    'uz': 'PT/INR, APTT, TT, fibrinogen, D-dimer · namuna · DIC bali',
    'ru': 'ПВ/МНО, АЧТВ, ТВ, фибриноген, D-димер · проба · балл ДВС',
    'en': 'PT/INR, APTT, TT, fibrinogen, D-dimer · sample · DIC score',
  });
  static const draftNote = _T({
    'uz':
        'Qoralama: mutaxassis tekshiruvidan o‘tmagan. Har band manbali; '
        'me’yoriy oraliqlar laboratoriya usuliga bog‘liq.',
    'ru':
        'Черновик: не проверен специалистом. Каждый пункт с источником; '
        'референтные интервалы зависят от метода лаборатории.',
    'en':
        'Draft: not yet expert-reviewed. Every point is sourced; reference '
        'intervals depend on the laboratory method.',
  });
  static const notDiagnosis = _T({
    'uz':
        'Ilova natija nimaga ishora qilishi mumkinligini manbasi bilan '
        'ko‘rsatadi — bu tashxis emas.',
    'ru':
        'Приложение показывает, на что может указывать результат, с '
        'источником — это не диагноз.',
    'en':
        'The app shows what a result may point to, with sources — this is not '
        'a diagnosis.',
  });
  static const testsTitle = _T({
    'uz': 'Testlar nimani o‘lchaydi',
    'ru': 'Что измеряет каждый тест',
    'en': 'What each test measures',
  });
  static const testsSub = _T({
    'uz': 'PT/INR, APTT, trombin vaqti, fibrinogen, D-dimer',
    'ru': 'ПВ/МНО, АЧТВ, тромбиновое время, фибриноген, D-димер',
    'en': 'PT/INR, APTT, thrombin time, fibrinogen, D-dimer',
  });
  static const sampleTitle = _T({
    'uz': 'Namuna talablari',
    'ru': 'Требования к пробе',
    'en': 'Sample requirements',
  });
  static const sampleSub = _T({
    'uz': '3,2 % sitrat, 9:1, gematokrit, vaqt; preanalitik xatolar',
    'ru': '3,2 % цитрат, 9:1, гематокрит, сроки; преаналитические ошибки',
    'en': '3.2% citrate, 9:1, haematocrit, timing; preanalytical errors',
  });
  static const errorsTitle = _T({
    'uz': 'Ko‘p uchraydigan preanalitik xatolar',
    'ru': 'Частые преаналитические ошибки',
    'en': 'Common preanalytical errors',
  });
  static const readerTitle = _T({
    'uz': 'Natijani o‘qish yordamchisi',
    'ru': 'Помощник чтения результата',
    'en': 'Result reading helper',
  });
  static const readerSub = _T({
    'uz': 'PT, APTT va trombotsit → manbadagi ehtimoliy sabablar',
    'ru': 'ПВ, АЧТВ и тромбоциты → возможные причины из источников',
    'en': 'PT, APTT and platelets → possible causes from sources',
  });
  static const dicTitle = _T({
    'uz': 'ISTH ochiq DIC bali',
    'ru': 'Балл явного ДВС ISTH',
    'en': 'ISTH overt DIC score',
  });
  static const dicSub = _T({
    'uz': 'Trombotsit, D-dimer/FDP, PT, fibrinogen → bal',
    'ru': 'Тромбоциты, D-димер/ПДФ, ПВ, фибриноген → балл',
    'en': 'Platelets, D-dimer/FDP, PT, fibrinogen → score',
  });
  static const monitoringTitle = _T({
    'uz': 'Antikoagulyant monitoringi',
    'ru': 'Мониторинг антикоагулянтов',
    'en': 'Anticoagulant monitoring',
  });
  static const monitoringSub = _T({
    'uz': 'Varfarin — INR, geparin — APTT/anti-Xa, peroral antikoagulyantlar',
    'ru': 'Варфарин — МНО, гепарин — АЧТВ/анти-Xa, ПОАК',
    'en': 'Warfarin — INR, heparin — APTT/anti-Xa, DOACs',
  });
  static const relatedTitle = _T({
    'uz': 'Bog‘liq bo‘limlar',
    'ru': 'Связанные разделы',
    'en': 'Related sections',
  });
  static const relatedCardsTitle = _T({
    'uz': 'Tahlil kartalari',
    'ru': 'Карточки анализов',
    'en': 'Test cards',
  });
  static const deckTitle = _T({
    'uz': 'Amaliy protokol (taqdimot)',
    'ru': 'Практический протокол (презентация)',
    'en': 'Practical protocol (slides)',
  });
  static const generalTitle = _T({
    'uz': 'Umumiy',
    'ru': 'Общее',
    'en': 'General',
  });
  static const measuresTitle = _T({
    'uz': 'Nimani o‘lchaydi',
    'ru': 'Что измеряет',
    'en': 'What it measures',
  });
  static const notesTitle = _T({
    'uz': 'Talqin va cheklovlar',
    'ru': 'Интерпретация и ограничения',
    'en': 'Interpretation and limits',
  });
  static const openCard = _T({
    'uz': 'Tahlil kartasi',
    'ru': 'Карточка анализа',
    'en': 'Test card',
  });

  // Sitrat hisoblagichi.
  static const citrateTitle = _T({
    'uz': 'Gematokrit > 55 %: sitrat hajmi',
    'ru': 'Гематокрит > 55 %: объём цитрата',
    'en': 'Haematocrit > 55%: citrate volume',
  });
  static const citrateHct = _T({
    'uz': 'Gematokrit, %',
    'ru': 'Гематокрит, %',
    'en': 'Haematocrit, %',
  });
  static const citrateVolume = _T({
    'uz': 'Qon hajmi, ml',
    'ru': 'Объём крови, мл',
    'en': 'Blood volume, ml',
  });
  static const citrateResult = _T({
    'uz': 'Sitrat hajmi, ml',
    'ru': 'Объём цитрата, мл',
    'en': 'Citrate volume, ml',
  });
  static const citrateNotNeeded = _T({
    'uz':
        'Gematokrit ≤ 55 %: manba bo‘yicha tuzatish faqat > 55 % da '
        'talab qilinadi — standart probirka.',
    'ru':
        'Гематокрит ≤ 55 %: по источнику коррекция требуется только при '
        '> 55 % — стандартная пробирка.',
    'en':
        'Haematocrit ≤ 55%: the source requires adjustment only above 55% — '
        'use the standard tube.',
  });
  static const invalidNumber = _T({
    'uz': 'To‘g‘ri son kiriting',
    'ru': 'Введите корректное число',
    'en': 'Enter a valid number',
  });

  // O'qish yordamchisi.
  static const readerIntro = _T({
    'uz':
        'Laboratoriyangiz oralig‘iga nisbatan PT, APTT va trombotsit holatini '
        'tanlang. Ilova manbalarda keltirilgan ehtimoliy sabablar va keyingi '
        'qadamlarni ko‘rsatadi.',
    'ru':
        'Выберите состояние ПВ, АЧТВ и тромбоцитов относительно интервала '
        'вашей лаборатории. Приложение покажет возможные причины и '
        'следующие шаги из источников.',
    'en':
        'Choose the PT, APTT and platelet status against your laboratory’s '
        'range. The app shows possible causes and next steps named in the '
        'sources.',
  });
  static const readerEmpty = _T({
    'uz': 'PT va APTT holatini tanlang.',
    'ru': 'Выберите состояние ПВ и АЧТВ.',
    'en': 'Choose the PT and APTT status.',
  });
  static const normal = _T({'uz': 'Me’yorda', 'ru': 'В норме', 'en': 'Normal'});
  static const prolonged = _T({
    'uz': 'Uzaygan',
    'ru': 'Удлинено',
    'en': 'Prolonged',
  });
  static const plateletsLabel = _T({
    'uz': 'Trombotsitlar',
    'ru': 'Тромбоциты',
    'en': 'Platelets',
  });
  static const low = _T({'uz': 'Kam', 'ru': 'Снижены', 'en': 'Low'});
  static const unknown = _T({
    'uz': 'Noma’lum',
    'ru': 'Неизвестно',
    'en': 'Not known',
  });
  static const causesTitle = _T({
    'uz': 'Manbada keltirilgan ehtimoliy sabablar',
    'ru': 'Возможные причины по источникам',
    'en': 'Possible causes named in sources',
  });
  static const nextTitle = _T({
    'uz': 'Keyingi qadam (manba bo‘yicha)',
    'ru': 'Следующий шаг (по источнику)',
    'en': 'Next step (per source)',
  });
  static const readerReferral = _T({
    'uz':
        'Tashxis emas. Natija klinik ma’lumot, takroriy va qo‘shimcha '
        'testlar bilan birga davolovchi shifokor tomonidan baholanadi.',
    'ru':
        'Это не диагноз. Результат оценивает лечащий врач вместе с клиникой, '
        'повторными и дополнительными тестами.',
    'en':
        'Not a diagnosis. The treating clinician interprets the result with '
        'clinical data and repeat or further tests.',
  });
  static const openDic = _T({
    'uz': 'DIC balini hisoblash',
    'ru': 'Рассчитать балл ДВС',
    'en': 'Calculate the DIC score',
  });

  // DIC.
  static const dicPrecondition = _T({
    'uz': 'Bemorda ochiq DIC bilan bog‘liq asosiy kasallik bormi?',
    'ru': 'Есть ли у пациента основное заболевание, связанное с явным ДВС?',
    'en':
        'Does the patient have an underlying disorder associated with overt '
        'DIC?',
  });
  static const yes = _T({'uz': 'Ha', 'ru': 'Да', 'en': 'Yes'});
  static const no = _T({'uz': 'Yo‘q', 'ru': 'Нет', 'en': 'No'});
  static const dicNotApplicable = _T({
    'uz':
        'Manba bo‘yicha bal faqat shunday asosiy kasalligi bor bemorda '
        'qo‘llanadi — hisoblanmaydi.',
    'ru':
        'По источнику балл применяют только у пациента с таким основным '
        'заболеванием — подсчёт не выполняется.',
    'en':
        'Per the source, the score is used only in a patient with such an '
        'underlying disorder — not calculated.',
  });
  static const dicPlatelets = _T({
    'uz': 'Trombotsitlar, ×10⁹/l',
    'ru': 'Тромбоциты, ×10⁹/л',
    'en': 'Platelets, ×10⁹/l',
  });
  static const dicFrm = _T({
    'uz': 'Fibrin bilan bog‘liq marker (D-dimer, FDP)',
    'ru': 'Фибрин-связанный маркер (D-димер, ПДФ)',
    'en': 'Fibrin-related marker (D-dimer, FDP)',
  });
  static const frmNone = _T({
    'uz': 'Oshmagan',
    'ru': 'Не повышен',
    'en': 'No increase',
  });
  static const frmModerate = _T({
    'uz': 'O‘rtacha oshgan',
    'ru': 'Умеренно повышен',
    'en': 'Moderate increase',
  });
  static const frmStrong = _T({
    'uz': 'Keskin oshgan',
    'ru': 'Резко повышен',
    'en': 'Strong increase',
  });
  static const dicPt = _T({
    'uz': 'PT uzayishi, soniya',
    'ru': 'Удлинение ПВ, секунды',
    'en': 'PT prolongation, seconds',
  });
  static const dicFib = _T({
    'uz': 'Fibrinogen, g/l',
    'ru': 'Фибриноген, г/л',
    'en': 'Fibrinogen, g/l',
  });
  static const dicFill = _T({
    'uz': 'Balni ko‘rish uchun barcha maydonlarni to‘ldiring.',
    'ru': 'Заполните все поля, чтобы увидеть балл.',
    'en': 'Fill in all fields to see the score.',
  });
  static const dicTotal = _T({
    'uz': 'Jami bal',
    'ru': 'Сумма баллов',
    'en': 'Total score',
  });
  static const dicCriteria = _T({
    'uz': 'Mezonlar (manba jadvali)',
    'ru': 'Критерии (таблица источника)',
    'en': 'Criteria (source table)',
  });
  static const points = _T({'uz': 'bal', 'ru': 'балл.', 'en': 'pts'});

  /// Barcha matnlar (test: uch tilda to‘liq).
  static const all = <LocalizedText>[
    subtitle,
    draftNote,
    notDiagnosis,
    testsTitle,
    testsSub,
    sampleTitle,
    sampleSub,
    errorsTitle,
    readerTitle,
    readerSub,
    dicTitle,
    dicSub,
    monitoringTitle,
    monitoringSub,
    relatedTitle,
    relatedCardsTitle,
    deckTitle,
    generalTitle,
    measuresTitle,
    notesTitle,
    openCard,
    citrateTitle,
    citrateHct,
    citrateVolume,
    citrateResult,
    citrateNotNeeded,
    invalidNumber,
    readerIntro,
    readerEmpty,
    normal,
    prolonged,
    plateletsLabel,
    low,
    unknown,
    causesTitle,
    nextTitle,
    readerReferral,
    openDic,
    dicPrecondition,
    yes,
    no,
    dicNotApplicable,
    dicPlatelets,
    dicFrm,
    frmNone,
    frmModerate,
    frmStrong,
    dicPt,
    dicFib,
    dicFill,
    dicTotal,
    dicCriteria,
    points,
    cgDeckTitle,
  ];
}

/// Test kartasi id bo'yicha.
CgTest? cgTest(String id) {
  for (final t in cgTests) {
    if (t.id == id) return t;
  }
  return null;
}

/// Hisoblagich va o'qish ekranidagi barcha da'volar (test uchun).
List<CgFact> get cgAllFacts => [
  ...cgTestsGeneral,
  for (final t in cgTests) ...t.facts,
  for (final s in cgSampleSections) ...s.facts,
  ...cgErrors,
  for (final i in cgPatternInfo.values) ...i.facts,
  cgLowPlateletsFact,
  cgLowPlateletsPtFact,
  ...cgDicIntro,
  cgDicPlatelets,
  cgDicFrm,
  cgDicPt,
  cgDicFib,
  cgDicOvert,
  cgDicNonOvert,
  for (final s in cgMonitoringSections) ...s.facts,
];
