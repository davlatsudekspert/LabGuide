/// Koprologiya (najas tahlili) va ichak parazitologiyasi: namuna yig'ish,
/// makroskopik ko'rsatkichlar, koprogramma elementlari (mushak tolalari,
/// yog', kraxmal, biriktiruvchi to'qima, leykotsit, eritrotsit, shilliq),
/// yashirin qon (FIT va gvayak), boyitish usullari va keng tarqalgan ichak
/// parazitlari tuxum/sistalari morfologiyasi (3 tilda).
///
/// Har da'vo — manba va joy bilan ([CpFact], [CalcRef]). Manbalar shu
/// sessiyada ochib o'qilgan: JSST 2003 qo'llanmasi (4-bob, 105–159-betlar),
/// CDC DPDx sahifalari, MedlinePlus (O&P, najasda leykotsit, FOBT), Merck
/// Manual (malabsorbsiya) va domla darsligi (Kurbonova 2023, 2-bob) —
/// xalqaro manbalarda yo'q koprogramma talqinlari faqat shu darslikdan,
/// "darslik" deb belgilanadi. Rasm o'rniga — ilovaning o'z vektor sxemasi
/// (DPDx rasmlarining bir qismi uchinchi tomonlarga tegishli). Manbalar
/// jadvali: docs/COPROLOGY_SOURCES.md.
library;

import '../content/content_model.dart';
import '../tools/calc_info.dart';

typedef _T = LocalizedText;

const coproCheckedAt = '2026-10-18';

abstract final class CpSources {
  static const who2003 = CalcSources.whoBasicLab2003;
  static const kurbonova2023 = CalcSource(
    id: 'book-kurbonova-2023',
    citation:
        'Kurbonova Z.Ch. Klinik laboratoriya tashxisi: darslik. Toshkent: '
        'Toshkent tibbiyot akademiyasi, 2023',
    url: null,
  );
  static const mlOp = CalcSource(
    id: 'medlineplus-ova-parasite',
    citation:
        'MedlinePlus. Ova and Parasite Test. National Library of Medicine',
    url: 'https://medlineplus.gov/lab-tests/ova-and-parasite-test/',
  );
  static const mlWbc = CalcSource(
    id: 'medlineplus-stool-wbc',
    citation:
        'MedlinePlus. White Blood Cell (WBC) in Stool. National Library of '
        'Medicine',
    url: 'https://medlineplus.gov/lab-tests/white-blood-cell-wbc-in-stool/',
  );
  static const mlFobt = CalcSource(
    id: 'medlineplus-fobt',
    citation:
        'MedlinePlus. Fecal Occult Blood Test (FOBT). National Library of '
        'Medicine',
    url: 'https://medlineplus.gov/lab-tests/fecal-occult-blood-test-fobt/',
  );
  static const merck = CalcSource(
    id: 'merck-malabsorption',
    citation:
        'Malik Z. Overview of Malabsorption. Merck Manual Professional '
        'Version, 2025',
    url:
        'https://www.merckmanuals.com/professional/gastrointestinal-disorders/'
        'malabsorption-syndromes/overview-of-malabsorption',
  );
  static const dpdxAscaris = CalcSource(
    id: 'dpdx-ascariasis',
    citation: 'CDC DPDx. Ascariasis (reviewed 2019)',
    url: 'https://www.cdc.gov/dpdx/ascariasis/index.html',
  );
  static const dpdxEnterobius = CalcSource(
    id: 'dpdx-enterobiasis',
    citation: 'CDC DPDx. Enterobiasis (reviewed 2019)',
    url: 'https://www.cdc.gov/dpdx/enterobiasis/index.html',
  );
  static const dpdxHymenolepis = CalcSource(
    id: 'dpdx-hymenolepiasis',
    citation: 'CDC DPDx. Hymenolepiasis (reviewed 2024)',
    url: 'https://www.cdc.gov/dpdx/hymenolepiasis/index.html',
  );
  static const dpdxGiardia = CalcSource(
    id: 'dpdx-giardiasis',
    citation: 'CDC DPDx. Giardiasis (reviewed 2024)',
    url: 'https://www.cdc.gov/dpdx/giardiasis/index.html',
  );
  static const dpdxAmebiasis = CalcSource(
    id: 'dpdx-amebiasis',
    citation: 'CDC DPDx. Amebiasis (reviewed 2019)',
    url: 'https://www.cdc.gov/dpdx/amebiasis/index.html',
  );
  static const dpdxTrichuris = CalcSource(
    id: 'dpdx-trichuriasis',
    citation: 'CDC DPDx. Trichuriasis (reviewed 2024)',
    url: 'https://www.cdc.gov/dpdx/trichuriasis/index.html',
  );
  static const dpdxTaenia = CalcSource(
    id: 'dpdx-taeniasis',
    citation: 'CDC DPDx. Taeniasis (reviewed 2024)',
    url: 'https://www.cdc.gov/dpdx/taeniasis/index.html',
  );
  static const dpdxProc = CalcSource(
    id: 'dpdx-stool-processing',
    citation: 'CDC DPDx. Stool specimens — specimen processing (reviewed 2016)',
    url:
        'https://www.cdc.gov/dpdx/diagnosticprocedures/stool/specimenproc.html',
  );

  static const all = [
    who2003,
    kurbonova2023,
    mlOp,
    mlWbc,
    mlFobt,
    merck,
    dpdxAscaris,
    dpdxEnterobius,
    dpdxHymenolepis,
    dpdxGiardia,
    dpdxAmebiasis,
    dpdxTrichuris,
    dpdxTaenia,
    dpdxProc,
  ];
}

/// Bo'lim asoslangan adabiyot — sahifa boshidagi "Manbalar" paneli (D-65).
const cpLeadRefs = [
  CalcRef(CpSources.kurbonova2023, ''),
  CalcRef(CpSources.who2003, ''),
  CalcRef(CpSources.merck, ''),
  CalcRef(CpSources.dpdxProc, ''),
];

// ───────────────────────── Lokatorlar ─────────────────────────

const _w = CpSources.who2003;
const _k = CpSources.kurbonova2023;

const _wCollect = CalcRef(_w, '4.2.1 Collection of specimens, p. 107');
const _wVisual = CalcRef(_w, '4.2.2 Visual examination, p. 107');
const _wMicro = CalcRef(_w, '4.2.3 Microscopic examination, p. 107');
const _wDispatch = CalcRef(_w, '4.2.4 Dispatch of stools, p. 109–110');
const _wTrophEh = CalcRef(_w, '4.3.1 Entamoeba histolytica, p. 113');
const _wTrophG = CalcRef(_w, '4.3.1 Giardia intestinalis, p. 115');
const _wCystEh = CalcRef(_w, '4.3.2 Cysts: Entamoeba histolytica, p. 118');
const _wCystG = CalcRef(_w, '4.3.2 Cysts: Giardia intestinalis, p. 121');
const _wCystMicro = CalcRef(
  _w,
  '4.3.2 Microscopic examination of cysts, p. 122–123',
);
const _wLeuko = CalcRef(_w, '4.3.2 Leukocytes; Pus, p. 125');
const _wEggs = CalcRef(_w, '4.4.1 Identification of eggs, p. 126–127');
const _wAscaris = CalcRef(_w, '4.4.1 Ascaris lumbricoides, p. 127–128, 133');
const _wEnterobius = CalcRef(_w, '4.4.1 Enterobius vermicularis, p. 135–137');
const _wHnana = CalcRef(_w, '4.4.1 Hymenolepis nana, p. 139');
const _wTaenia = CalcRef(_w, '4.4.1 Taenia saginata and T. solium, p. 143–144');
const _wTrichuris = CalcRef(_w, '4.4.1 Trichuris trichiura, p. 144');
const _wNotEggs = CalcRef(
  _w,
  '4.4.1 Features not to be mistaken for eggs, p. 144–145',
);
const _wConc = CalcRef(
  _w,
  '4.5 Techniques for concentrating parasites, p. 152',
);
const _wWillis = CalcRef(_w, '4.5.1 Flotation technique (Willis), p. 152–153');
const _wFormolEther = CalcRef(
  _w,
  '4.5.2 Formaldehyde–ether sedimentation, p. 153–154',
);
const _wOccult = CalcRef(
  _w,
  '4.6 Chemical test for occult blood in stools, p. 157',
);

const _kPurpose = CalcRef(_k, '2-bob, najas tahlili, p. 38');
const _kMacro = CalcRef(_k, '2.1 Makroskopik tekshirish, p. 38–39');
const _kColour = CalcRef(_k, '2.1 Najas rangi, p. 39–40');
const _kAdmix = CalcRef(_k, '2.1 Patologik aralashmalar, p. 41');
const _kReaction = CalcRef(_k, '2.2 Najas reaksiyasi, p. 41–42');
const _kMicroTable = CalcRef(_k, '2.3 Najas mikroskopiyasi (jadval), p. 44–45');
const _kMuscle = CalcRef(_k, '2.3 Mushak tolasi, p. 45');
const _kConn = CalcRef(_k, '2.3 Biriktiruvchi to‘qima, p. 46');
const _kFat = CalcRef(_k, '2.3 Neytral yog‘ va yog‘ kislotalari, p. 46');
const _kStarch = CalcRef(_k, '2.3 Kraxmal, p. 46');
const _kMucus = CalcRef(_k, '2.3 Shilliq, p. 46–47');
const _kLeuko = CalcRef(_k, '2.3 Leykotsitlar, p. 47');
const _kRbc = CalcRef(_k, '2.3 Eritrotsitlar, p. 47');

const _mlOpCollect = CalcRef(
  CpSources.mlOp,
  'What happens during an ova and parasite test?',
);
const _mlOpRes = CalcRef(CpSources.mlOp, 'What do the results mean?');
const _mlWbcUse = CalcRef(CpSources.mlWbc, 'What is it used for?');
const _mlWbcRes = CalcRef(CpSources.mlWbc, 'What do the results mean?');
const _mlFobtWhat = CalcRef(
  CpSources.mlFobt,
  'What is a fecal occult blood test?',
);
const _mlFobtHow = CalcRef(
  CpSources.mlFobt,
  'What happens during a fecal occult blood test?',
);
const _mlFobtPrep = CalcRef(
  CpSources.mlFobt,
  'Will I need to do anything to prepare for the test?',
);
const _mlFobtRes = CalcRef(CpSources.mlFobt, 'What do the results mean?');
const _mlFobtElse = CalcRef(
  CpSources.mlFobt,
  'Is there anything else I need to know about a fecal occult blood test?',
);
const _merckConfirm = CalcRef(
  CpSources.merck,
  'Diagnosis: Confirming malabsorption',
);

const _dAscaris = CalcRef(CpSources.dpdxAscaris, 'Egg morphology');
const _dEnterobius = CalcRef(
  CpSources.dpdxEnterobius,
  'Egg morphology; Laboratory Diagnosis',
);
const _dHnana = CalcRef(CpSources.dpdxHymenolepis, 'Egg morphology');
const _dGiardia = CalcRef(
  CpSources.dpdxGiardia,
  'Morphology; Laboratory Diagnosis',
);
const _dAmeba = CalcRef(
  CpSources.dpdxAmebiasis,
  'Clinical Presentation; Microscopic Detection',
);
const _dAmebaMol = CalcRef(
  CpSources.dpdxAmebiasis,
  'Antigen Detection; Molecular Diagnosis',
);
const _dTrichuris = CalcRef(CpSources.dpdxTrichuris, 'Egg morphology');
const _dTaenia = CalcRef(
  CpSources.dpdxTaenia,
  'Egg morphology; species identification',
);
const _dProc = CalcRef(CpSources.dpdxProc, 'Concentration procedures');

// ───────────────────────── Model ─────────────────────────

class CpFact {
  const CpFact(this.text, this.refs);

  final LocalizedText text;
  final List<CalcRef> refs;
}

List<CalcRef> cpRefsOf(Iterable<CpFact> facts) {
  final seen = <String>{};
  return [
    for (final f in facts)
      for (final r in f.refs)
        if (seen.add('${r.source.id}|${r.locator}')) r,
  ];
}

class CpSection {
  const CpSection(this.title, this.facts);

  final LocalizedText title;
  final List<CpFact> facts;
}

/// Koprogramma mikroskopik elementi.
class CpElement {
  const CpElement({
    required this.id,
    required this.name,
    required this.look,
    required this.normal,
    required this.meaning,
    this.confuse,
  });

  final String id;
  final LocalizedText name;

  /// Qanday ko'rinadi / qanday aniqlanadi.
  final List<CpFact> look;

  /// Me'yorda (manbada aytilgani).
  final CpFact normal;

  /// Nimaga ishora qilishi mumkin (tashxis emas).
  final List<CpFact> meaning;

  /// Nima bilan adashtiriladi.
  final CpFact? confuse;

  List<CpFact> get facts => [...look, normal, ...meaning, ?confuse];

  List<CalcRef> get refs => cpRefsOf(facts);
}

/// Parazit sxemasi turi (ilovaning o'z vektor chizmasi).
enum CpShape {
  ascaris,
  enterobius,
  hymenolepis,
  giardia,
  entamoeba,
  trichuris,
  taenia,
}

/// Nisbiy o'lcham diagrammasi uchun oraliq (µm, manbadagi uzunlik).
class CpSize {
  const CpSize(this.min, this.max, this.ref);

  final double min;
  final double max;
  final CalcRef ref;
}

class CpParasite {
  const CpParasite({
    required this.id,
    required this.latin,
    required this.common,
    required this.stage,
    required this.shape,
    required this.size,
    required this.look,
    required this.notes,
    required this.analyteId,
  });

  final String id;

  /// Lotincha nom (barcha tillarda bir xil).
  final String latin;
  final LocalizedText common;

  /// Diagnostik bosqich: tuxum yoki sista.
  final LocalizedText stage;
  final CpShape shape;

  /// DPDx bo'yicha uzunlik oralig'i (diagramma uchun).
  final CpSize size;

  /// Morfologiya kaliti (o'lcham, shakl, qobiq, ichidagisi).
  final List<CpFact> look;

  /// Namuna, farqlash va boshqa eslatmalar.
  final List<CpFact> notes;

  /// Pack'dagi tahlil kartasi.
  final String analyteId;

  List<CpFact> get facts => [...look, ...notes];

  List<CalcRef> get refs => cpRefsOf(facts);
}

// ───────────────────────── 1. Namuna yig'ish ─────────────────────────

const cpCollectSections = <CpSection>[
  CpSection(
    _T({
      'uz': 'Idish va yetkazish',
      'ru': 'Контейнер и доставка',
      'en': 'Container and delivery',
    }),
    [
      CpFact(
        _T({
          'uz':
              'Taxminan 100 g najas toza, quruq, konservantsiz, qopqog‘i '
              'buraladigan idishga olinadi; chiqqan gijja yoki bo‘g‘imlar ham '
              'qo‘shiladi. Siydik aralashgan namuna (masalan, tuvakdan) qabul '
              'qilinmaydi; qopqoqsiz idish qoldirilmaydi; qo‘lqopsiz '
              'tekshirilmaydi.',
          'ru':
              'Около 100 г кала собирают в чистый сухой контейнер без '
              'консервантов с завинчивающейся крышкой; выделившихся гельминтов '
              'или членики тоже передают. Пробу с мочой (например, из судна) '
              'не принимают; контейнер не оставляют открытым; без перчаток не '
              'исследуют.',
          'en':
              'Collect about 100 g of faeces in a clean, dry, screw-top '
              'container without preservative, including any worms or '
              'segments passed. Never accept stool mixed with urine (e.g. from '
              'a bedpan), never leave it uncovered, never examine without '
              'gloves.',
        }),
        [_wCollect],
      ),
      CpFact(
        _T({
          'uz':
              'Parazitologik tekshiruv: yig‘ilgandan keyin 1–4 soat ichida. '
              'Bir vaqtda bir nechta namuna kelsa, avval suyuq va shilliq yoki '
              'qonli namunalar ko‘riladi — ularda harakatchan amyobalar bo‘lishi '
              'mumkin (tez nobud bo‘ladi).',
          'ru':
              'Паразитологическое исследование: в течение 1–4 ч после сбора. '
              'Если пришло несколько проб, первыми смотрят жидкие и со слизью '
              'или кровью — в них могут быть подвижные амёбы (быстро гибнут).',
          'en':
              'For parasites, examine within 1–4 hours of collection. When '
              'several arrive together, examine liquid stools and those with '
              'mucus or blood first — they may contain motile amoebae, which '
              'die quickly.',
        }),
        [_wCollect],
      ),
      CpFact(
        _T({
          'uz':
              'Koprogramma (darslik): najas defekatsiyadan keyin 8–12 soat '
              'ichida tekshiriladi. Huqna, surgi, shamcha, kanakunjut yoki '
              'vazelin moyidan keyin va rangni o‘zgartiruvchi dorilar (temir, '
              'vismut, bariy) qabul qilingandan keyingi najas yaramaydi.',
          'ru':
              'Копрограмма (учебник): кал исследуют в течение 8–12 ч после '
              'дефекации. Не подходит кал после клизмы, слабительных, свечей, '
              'касторового или вазелинового масла и препаратов, меняющих цвет '
              '(железо, висмут, барий).',
          'en':
              'Coprogram (textbook): examine within 8–12 h of defecation. '
              'Stool after an enema, laxatives, suppositories, castor or '
              'paraffin oil, or colour-changing drugs (iron, bismuth, barium) '
              'is unsuitable.',
        }),
        [_kPurpose],
      ),
    ],
  ),
  CpSection(
    _T({
      'uz': 'Bir nechta namuna',
      'ru': 'Несколько проб',
      'en': 'Several specimens',
    }),
    [
      CpFact(
        _T({
          'uz':
              'Parazitlar har kuni najasda chiqmasligi mumkin — bir necha kun '
              'davomida bir nechta namuna topilish ehtimolini oshiradi; manfiy '
              'natija namunada parazit yetarli emasligini ham anglatishi '
              'mumkin.',
          'ru':
              'Паразиты могут выделяться не каждый день — несколько проб за '
              'несколько дней повышают выявляемость; отрицательный результат '
              'может означать и недостаточное количество паразитов в пробе.',
          'en':
              'Parasites may not appear in stool every day — several samples '
              'over a few days increase detection; a negative result can also '
              'mean too few parasites in the sample.',
        }),
        [_mlOpCollect, _mlOpRes],
      ),
      CpFact(
        _T({
          'uz':
              'Amyobiaz: o‘n kun ichida ketma-ket uchta namuna aniqlash '
              'imkonini oshiradi. Lyambliozda ham takroriy namuna kerak '
              'bo‘lishi mumkin.',
          'ru':
              'Амёбиаз: три последовательные пробы в течение десяти дней '
              'повышают выявляемость. При лямблиозе тоже может потребоваться '
              'повторное исследование.',
          'en':
              'Amoebiasis: three consecutive samples within ten days improve '
              'detection. Giardiasis may also need repeated sampling.',
        }),
        [_dAmeba, _dGiardia],
      ),
    ],
  ),
  CpSection(
    _T({
      'uz': 'Konservant (boshqa laboratoriyaga yuborish)',
      'ru': 'Консервант (отправка в другую лабораторию)',
      'en': 'Preservative (sending to another laboratory)',
    }),
    [
      CpFact(
        _T({
          'uz':
              '10 % formalin (1 qism najas : 3 qism) tuxum va sistalarni idish '
              'zich yopiq bo‘lsa cheksiz saqlaydi, lekin vegetativ shakllarni '
              'saqlamaydi; PVA fiksatori barcha shakllarni saqlaydi.',
          'ru':
              '10 % формалин (1 часть кала : 3 части) бесконечно сохраняет '
              'яйца и цисты при плотно закрытом контейнере, но не '
              'вегетативные формы; фиксатор ПВС сохраняет все формы.',
          'en':
              '10% formalin (1 part stool : 3 parts) preserves eggs and cysts '
              'indefinitely in a tightly closed container but not vegetative '
              'forms; PVA fixative preserves all forms.',
        }),
        [_wDispatch],
      ),
    ],
  ),
];

// ───────────────────────── 2. Makroskopiya ─────────────────────────

const cpMacroSections = <CpSection>[
  CpSection(
    _T({
      'uz': 'Miqdor, shakl va konsistensiya',
      'ru': 'Количество, форма и консистенция',
      'en': 'Amount, form and consistency',
    }),
    [
      CpFact(
        _T({
          'uz':
              'JSST yozuvi: shakllangan, yumshoq shakllangan, shakllanmagan '
              'yoki suyuq; rang, konsistensiya va ko‘rinadigan qon yoki '
              'ekssudat qayd etiladi.',
          'ru':
              'Запись по ВОЗ: оформленный, мягкий оформленный, неоформленный '
              'или жидкий; отмечают цвет, консистенцию и видимую кровь или '
              'экссудат.',
          'en':
              'WHO recording: formed, soft formed, unformed or liquid; note '
              'colour, consistency and visible blood or exudate.',
        }),
        [_wVisual],
      ),
      CpFact(
        _T({
          'uz':
              'Darslik me’yori: sutkasiga 150–200 g, shakllangan, silindrsimon. '
              '“Qo‘y qumalog‘i” — doimiy qabziyat; lentasimon — to‘g‘ri yoki '
              'sigmasimon ichak spazmi; mazsimon — me’da osti bezi '
              'yetishmovchiligi; suyuq — peristaltika tezlashishi, ekssudat va '
              'shilliq ko‘pligi; ko‘piksimon — bijg‘ish.',
          'ru':
              'Норма по учебнику: 150–200 г в сутки, оформленный, '
              'цилиндрический. «Овечий» — хронический запор; лентовидный — '
              'спазм прямой или сигмовидной кишки; мазевидный — '
              'недостаточность поджелудочной железы; жидкий — ускоренная '
              'перистальтика, много экссудата и слизи; пенистый — брожение.',
          'en':
              'Textbook norm: 150–200 g a day, formed, cylindrical. '
              '“Sheep-dung” pellets — chronic constipation; ribbon-like — '
              'rectal or sigmoid spasm; greasy, ointment-like — pancreatic '
              'insufficiency; liquid — fast peristalsis, much exudate and '
              'mucus; frothy — fermentation.',
        }),
        [_kMacro],
      ),
    ],
  ),
  CpSection(_T({'uz': 'Rang', 'ru': 'Цвет', 'en': 'Colour'}), [
    CpFact(
      _T({
        'uz':
            'JSST: qora — (yashirin) qon; jigarrang, och sariq — yog‘; oq — '
            'obstruktiv sariqlik.',
        'ru':
            'ВОЗ: чёрный — (скрытая) кровь; коричневый, бледно-жёлтый — жир; '
            'белый — обтурационная желтуха.',
        'en':
            'WHO: black — (occult) blood; brown, pale yellow — fat; white — '
            'obstructive jaundice.',
      }),
      [_wVisual],
    ),
    CpFact(
      _T({
        'uz':
            'Darslik: me’yorda aralash ovqatda jigarrang. Qizil — pastki '
            'bo‘limlardan qon ketishi (polip, gemorroy, yarali kolit, o‘sma); '
            'qora — yuqori bo‘limlardan ko‘p qon ketishi yoki temir, vismut '
            'preparatlari; oq — o‘t yo‘li to‘sig‘i, virusli gepatit yoki '
            'bariy. Ovqat (lavlagi, ismaloq va b.) ham rangni o‘zgartiradi.',
        'ru':
            'Учебник: в норме при смешанном питании коричневый. Красный — '
            'кровотечение из нижних отделов (полип, геморрой, язвенный '
            'колит, опухоль); чёрный — обильное кровотечение из верхних '
            'отделов или препараты железа, висмута; белый — обтурация '
            'желчных путей, вирусный гепатит или барий. Пища (свёкла, шпинат '
            'и др.) тоже меняет цвет.',
        'en':
            'Textbook: brown on a mixed diet. Red — bleeding from the lower '
            'tract (polyp, haemorrhoids, ulcerative colitis, tumour); black — '
            'heavy upper-tract bleeding, or iron or bismuth; white — biliary '
            'obstruction, viral hepatitis, or barium. Foods (beetroot, '
            'spinach etc.) also change colour.',
      }),
      [_kColour],
    ),
  ]),
  CpSection(
    _T({
      'uz': 'Reaksiya va aralashmalar',
      'ru': 'Реакция и примеси',
      'en': 'Reaction and admixtures',
    }),
    [
      CpFact(
        _T({
          'uz':
              'Darslik: reaksiya me’yorda neytral yoki kuchsiz ishqoriy '
              '(ko‘krak yoshidagi bolada kislotali). Ishqoriy — oqsilga boy '
              'ovqat, yomon hazm, qabziyatli kolit, chirish dispepsiyasi; '
              'kislotali — uglevod ko‘p iste’mol qilinganda.',
          'ru':
              'Учебник: реакция в норме нейтральная или слабощелочная (у '
              'грудных детей кислая). Щелочная — белковая пища, плохое '
              'переваривание, колит с запорами, гнилостная диспепсия; кислая '
              '— избыток углеводов.',
          'en':
              'Textbook: reaction normally neutral or weakly alkaline (acid in '
              'breast-fed infants). Alkaline — protein-rich food, poor '
              'digestion, colitis with constipation, putrefactive dyspepsia; '
              'acid — high carbohydrate intake.',
        }),
        [_kReaction],
      ),
      CpFact(
        _T({
          'uz':
              'Ko‘rinadigan qon yoki shilliq (qizil yoki oq tolalar) yozib '
              'qo‘yiladi va to‘g‘ridan-to‘g‘ri tekshiriladi; qon masalan, '
              'yarali kolit yoki shistosomozda bo‘lishi mumkin. Darslik: '
              'shilliq — ichak yallig‘lanishi; yiring — og‘ir yallig‘lanish '
              '(dizenteriya, yarali kolit, ichak sili).',
          'ru':
              'Видимую кровь или слизь (красные или белые тяжи) отмечают и '
              'исследуют прямо; кровь возможна, например, при язвенном колите '
              'или шистосомозе. Учебник: слизь — воспаление кишечника; гной — '
              'тяжёлое воспаление (дизентерия, язвенный колит, туберкулёз '
              'кишечника).',
          'en':
              'Visible blood or mucus (red or white streaks) is recorded and '
              'examined directly; blood may occur e.g. in ulcerative colitis '
              'or schistosomiasis. Textbook: mucus — intestinal inflammation; '
              'pus — severe inflammation (dysentery, ulcerative colitis, '
              'intestinal TB).',
        }),
        [_wVisual, _wMicro, _kAdmix],
      ),
    ],
  ),
];

// ───────────────────────── 3. Mikroskopiya elementlari ─────────────────────────

const cpMicroIntro = <CpFact>[
  CpFact(
    _T({
      'uz':
          'To‘g‘ridan-to‘g‘ri mikroskopiya (fiziologik eritma va yod): '
          'harakatchan trofozoitlar, o‘rtacha miqdordagi tuxum va sistalar, '
          'eritrotsitlar, hujayra qoldiqlari va ortiqcha yog‘ni aniqlaydi.',
      'ru':
          'Прямая микроскопия (физраствор и йод): выявляет подвижные '
          'трофозоиты, яйца и цисты в умеренном количестве, эритроциты, '
          'клеточный детрит и избыток жира.',
      'en':
          'Direct microscopy (saline and iodine): detects motile '
          'trophozoites, eggs and cysts in moderate numbers, erythrocytes, '
          'cellular debris and excess fat.',
    }),
    [_wMicro],
  ),
  CpFact(
    _T({
      'uz':
          'Darslik koprogrammasi: nativ, Lyugol va metilen ko‘ki bilan '
          'preparatlar, 10× va 40× obyektiv. Normal jadval: mushak tolasi '
          'yo‘q yoki hazm bo‘lgan yakka tolalar; biriktiruvchi to‘qima, '
          'neytral yog‘, yog‘ kislotalari, kraxmal, shilliq yo‘q; sovun '
          'sezilarsiz; leykotsit 0–5 ko‘rish maydonida.',
      'ru':
          'Копрограмма по учебнику: нативный препарат, с Люголем и '
          'метиленовым синим, объективы 10× и 40×. Норма: мышечных волокон '
          'нет или единичные переваренные; соединительной ткани, '
          'нейтрального жира, жирных кислот, крахмала, слизи нет; мыла '
          'незначительно; лейкоциты 0–5 в поле зрения.',
      'en':
          'Coprogram per the textbook: native, Lugol and methylene-blue '
          'preparations, ×10 and ×40 objectives. Normal table: no muscle '
          'fibres or single digested ones; no connective tissue, neutral fat, '
          'fatty acids, starch or mucus; soaps insignificant; leukocytes 0–5 '
          'per field.',
    }),
    [_kMicroTable],
  ),
];

const cpElements = <CpElement>[
  CpElement(
    id: 'muscle',
    name: _T({
      'uz': 'Mushak tolalari',
      'ru': 'Мышечные волокна',
      'en': 'Muscle (meat) fibres',
    }),
    look: [
      CpFact(
        _T({
          'uz':
              'Hazm bo‘lgan go‘sht tolalari: 100–200 µm, oval yoki burchaklari '
              'dumaloq to‘rtburchak, tiniq, chiziqsiz (yaxshi hazm bo‘lmaganda '
              'qoldiq chiziqlar), sariq.',
          'ru':
              'Переваренные мясные волокна: 100–200 мкм, овальные или '
              'прямоугольные с закруглёнными углами, прозрачные, без '
              'исчерченности (при плохом переваривании — остаточная), жёлтые.',
          'en':
              'Digested meat fibres: 100–200 µm, oval or rectangular with '
              'rounded corners, transparent without striations (residual lines '
              'when poorly digested), yellow.',
        }),
        [_wNotEggs],
      ),
      CpFact(
        _T({
          'uz':
              'Darslik: hazm bo‘lmagan tolalarda ko‘ndalang yoki bo‘ylama '
              'chiziqlanish saqlanadi.',
          'ru':
              'Учебник: в непереваренных волокнах сохраняется поперечная или '
              'продольная исчерченность.',
          'en':
              'Textbook: undigested fibres keep their transverse or '
              'longitudinal striation.',
        }),
        [_kMuscle],
      ),
    ],
    normal: CpFact(
      _T({
        'uz': 'Darslik: yo‘q yoki kam miqdorda hazm bo‘lgan yakka tolalar.',
        'ru': 'Учебник: нет или единичные переваренные волокна.',
        'en': 'Textbook: none, or a few single digested fibres.',
      }),
      [_kMicroTable, _kMuscle],
    ),
    meaning: [
      CpFact(
        _T({
          'uz':
              'Darslik: ko‘payishi (kreatoreya) — go‘sht yaxshi hazm '
              'bo‘lmaganda. Hazm bo‘lmagan tolalar asosan me’da shirasi '
              'yetishmovchiligida; hazm bo‘lganlari — me’da osti bezi sekretor '
              'yetishmovchiligi, peristaltika kuchayishi, bijg‘ish va chirish '
              'dispepsiyasi, qabziyatli kolitda.',
          'ru':
              'Учебник: увеличение (креаторея) — при плохом переваривании мяса. '
              'Непереваренные волокна — в основном при недостаточности '
              'желудочного сока; переваренные — при секреторной '
              'недостаточности поджелудочной железы, усиленной перистальтике, '
              'бродильной и гнилостной диспепсии, колите с запорами.',
          'en':
              'Textbook: an increase (creatorrhoea) follows poor digestion of '
              'meat. Undigested fibres point mainly to gastric-juice '
              'insufficiency; digested ones to pancreatic secretory '
              'insufficiency, increased peristalsis, fermentative or '
              'putrefactive dyspepsia, colitis with constipation.',
        }),
        [_kMuscle],
      ),
    ],
    confuse: CpFact(
      _T({
        'uz':
            'JSST ularni “tuxum bilan adashtirmaslik kerak bo‘lgan” '
            'tuzilmalar qatorida keltiradi.',
        'ru':
            'ВОЗ относит их к структурам, которые «не следует принимать за '
            'яйца».',
        'en': 'WHO lists them among features “not to be mistaken for eggs”.',
      }),
      [_wNotEggs],
    ),
  ),
  CpElement(
    id: 'connective',
    name: _T({
      'uz': 'Biriktiruvchi to‘qima',
      'ru': 'Соединительная ткань',
      'en': 'Connective tissue',
    }),
    look: [
      CpFact(
        _T({
          'uz':
              'Darslik: nativ preparatda qidiriladi (koprogramma jadvalida '
              'alohida qator).',
          'ru':
              'Учебник: ищут в нативном препарате (отдельная строка таблицы '
              'копрограммы).',
          'en':
              'Textbook: looked for in the native preparation (a separate row '
              'of the coprogram table).',
        }),
        [_kMicroTable],
      ),
    ],
    normal: CpFact(
      _T({
        'uz': 'Darslik: me’yorda bo‘lmaydi.',
        'ru': 'Учебник: в норме отсутствует.',
        'en': 'Textbook: normally absent.',
      }),
      [_kConn],
    ),
    meaning: [
      CpFact(
        _T({
          'uz':
              'Darslik: ovqatning vaqtidan oldin evakuatsiyasi, me’da shirasi '
              'yoki me’da osti bezi yetishmovchiligi, yaxshi chaynalmagan '
              'ovqat. Tog‘ay yoki suyak qoldiqlari patologiya emas.',
          'ru':
              'Учебник: преждевременная эвакуация пищи, недостаточность '
              'желудочного сока или поджелудочной железы, плохо пережёванная '
              'пища. Остатки хряща или кости — не патология.',
          'en':
              'Textbook: premature evacuation, gastric-juice or pancreatic '
              'insufficiency, poorly chewed food. Cartilage or bone fragments '
              'are not pathological.',
        }),
        [_kConn],
      ),
    ],
  ),
  CpElement(
    id: 'fat',
    name: _T({
      'uz': 'Yog‘ (neytral yog‘, yog‘ kislotalari, sovunlar)',
      'ru': 'Жир (нейтральный жир, жирные кислоты, мыла)',
      'en': 'Fat (neutral fat, fatty acids, soaps)',
    }),
    look: [
      CpFact(
        _T({
          'uz':
              'Darslik: farqlash uchun metilen ko‘ki — faqat yog‘ kislotalari '
              'tomchilari bo‘yaladi, neytral yog‘ bo‘yalmaydi.',
          'ru':
              'Учебник: для различения — метиленовый синий: окрашиваются '
              'только капли жирных кислот, нейтральный жир не окрашивается.',
          'en':
              'Textbook: to tell them apart, methylene blue stains only '
              'fatty-acid droplets, not neutral fat.',
        }),
        [_kFat],
      ),
      CpFact(
        _T({
          'uz':
              'JSST: sovunlar 20–100 µm, dumaloq, oval yoki notekis, chetida '
              'markazdan tarqaluvchi chiziqlar; havo pufaklari va moy '
              'tomchilari — mukammal dumaloq, yaltiroq halqa, ichi bo‘sh.',
          'ru':
              'ВОЗ: мыла 20–100 мкм, круглые, овальные или неправильные, с '
              'радиальными линиями у края; пузырьки воздуха и капли масла — '
              'идеально круглые, с блестящим кольцом, пустые внутри.',
          'en':
              'WHO: soaps 20–100 µm, round, oval or irregular with lines '
              'radiating near the rim; air bubbles and oil droplets are '
              'perfectly round with a shiny ring and no content.',
        }),
        [_wNotEggs],
      ),
      CpFact(
        _T({
          'uz':
              'Sudan III bilan surtma — oddiy, ammo miqdoriy bo‘lmagan '
              'skrining; oltin standart — 72 soatlik najasda yog‘ (kuniga '
              '≥ 100 g yog‘li parhezda; > 7 g/kun anormal).',
          'ru':
              'Мазок с Суданом III — простой, но не количественный скрининг; '
              'золотой стандарт — жир в кале за 72 ч (диета ≥ 100 г жира в '
              'сутки; > 7 г/сут — патология).',
          'en':
              'A Sudan III smear is a simple but non-quantitative screen; the '
              'gold standard is 72-h faecal fat (on ≥ 100 g fat/day; > 7 g/day '
              'is abnormal).',
        }),
        [_merckConfirm],
      ),
    ],
    normal: CpFact(
      _T({
        'uz':
            'Darslik: neytral yog‘ va yog‘ kislotalari bo‘lmaydi (ko‘krak '
            'yoshidagi bolada yog‘ kislotalari bo‘lishi mumkin); sovun '
            'sezilarsiz miqdorda.',
        'ru':
            'Учебник: нейтрального жира и жирных кислот нет (у грудных детей '
            'жирные кислоты допустимы); мыла в незначительном количестве.',
        'en':
            'Textbook: no neutral fat or fatty acids (fatty acids can be '
            'normal in breast-fed infants); soaps insignificant.',
      }),
      [_kFat, _kMicroTable],
    ),
    meaning: [
      CpFact(
        _T({
          'uz':
              'Darslik: neytral yog‘ tomchilari — o‘t yetarli ajralmasligi '
              '(mexanik va parenximatoz sariqlik), me’da osti bezi shirasi '
              'yetishmovchiligi, chirish va bijg‘ish dispepsiyasi, '
              'peristaltika kuchayishi.',
          'ru':
              'Учебник: капли нейтрального жира — недостаточное поступление '
              'желчи (механическая и паренхиматозная желтуха), недостаточность '
              'сока поджелудочной железы, гнилостная и бродильная диспепсия, '
              'усиленная перистальтика.',
          'en':
              'Textbook: neutral fat droplets — insufficient bile (obstructive '
              'and parenchymal jaundice), pancreatic juice insufficiency, '
              'putrefactive and fermentative dyspepsia, increased '
              'peristalsis.',
        }),
        [_kFat],
      ),
      CpFact(
        _T({
          'uz':
              'Steatoreya (> 7 g/kun) — malabsorbsiyaning asosiy belgisi; '
              'og‘ir (≥ 40 g/kun) — me’da osti bezi yetishmovchiligi yoki '
              'ingichka ichak shilliq qavati kasalligiga ishora qiladi.',
          'ru':
              'Стеаторея (> 7 г/сут) — главный признак мальабсорбции; тяжёлая '
              '(≥ 40 г/сут) указывает на недостаточность поджелудочной железы '
              'или болезнь слизистой тонкой кишки.',
          'en':
              'Steatorrhoea (> 7 g/day) is the hallmark of malabsorption; '
              'severe (≥ 40 g/day) suggests pancreatic insufficiency or '
              'small-bowel mucosal disease.',
        }),
        [_merckConfirm],
      ),
    ],
  ),
  CpElement(
    id: 'starch',
    name: _T({'uz': 'Kraxmal', 'ru': 'Крахмал', 'en': 'Starch'}),
    look: [
      CpFact(
        _T({
          'uz':
              'JSST: o‘simlik kraxmal donalari 50–100 µm, dumaloq, oval yoki '
              'cho‘zinchoq, qobig‘i notekis qalin, yoriqli; oqish yoki '
              'kulrang-sariq, yod bilan binafsha rangga bo‘yaladi. Kartoshka, '
              'loviya, yams, kassava kabi ovqat qoldig‘i.',
          'ru':
              'ВОЗ: растительные зёрна крахмала 50–100 мкм, круглые, овальные '
              'или вытянутые, с неровной толстой оболочкой и трещинами; '
              'беловатые или серо-жёлтые, с йодом — фиолетовые. Остаток '
              'картофеля, бобов, ямса, маниоки.',
          'en':
              'WHO: plant starch granules 50–100 µm, round, oval or elongated, '
              'with an irregular thick shell and cracks; whitish or '
              'greyish-yellow, violet with iodine. Residue of potatoes, beans, '
              'yams, cassava.',
        }),
        [_wNotEggs],
      ),
    ],
    normal: CpFact(
      _T({
        'uz': 'Darslik: me’yorda bo‘lmaydi.',
        'ru': 'Учебник: в норме отсутствует.',
        'en': 'Textbook: normally absent.',
      }),
      [_kStarch],
    ),
    meaning: [
      CpFact(
        _T({
          'uz':
              'Darslik: ingichka ichak kasalliklari (enterit) va ichak '
              'evakuatsiyasi tezlashganda.',
          'ru':
              'Учебник: при болезнях тонкой кишки (энтерит) и ускоренной '
              'эвакуации.',
          'en':
              'Textbook: small-intestinal disease (enteritis) and rapid '
              'intestinal transit.',
        }),
        [_kStarch],
      ),
    ],
    confuse: CpFact(
      _T({
        'uz':
            'JSST: kraxmal donalari tuxum bilan adashtirilishi mumkin bo‘lgan '
            'tuzilmalar qatorida.',
        'ru':
            'ВОЗ: зёрна крахмала — среди структур, которые можно принять за '
            'яйца.',
        'en': 'WHO lists starch granules among look-alikes of eggs.',
      }),
      [_wNotEggs],
    ),
  ),
  CpElement(
    id: 'leukocytes',
    name: _T({'uz': 'Leykotsitlar', 'ru': 'Лейкоциты', 'en': 'Leukocytes'}),
    look: [
      CpFact(
        _T({
          'uz':
              'JSST: 10–20 µm, dumaloq yoki biroz cho‘ziq, chetlari notekis, '
              'yadrosi noaniq (ba’zan “soxta kariosoma”), sitoplazmasi '
              'yaltiroq, donador. Yiring — ko‘zga xira kulrang tolalar, '
              'mikroskopda parchalangan leykotsitlar to‘plami.',
          'ru':
              'ВОЗ: 10–20 мкм, круглые или слегка вытянутые, с неровным '
              'контуром, ядро нечёткое (иногда «ложная кариосома»), '
              'цитоплазма блестящая, зернистая. Гной — мутные серые тяжи, под '
              'микроскопом скопление распавшихся лейкоцитов.',
          'en':
              'WHO: 10–20 µm, round or slightly elongated with an irregular '
              'outline, indistinct nucleus (sometimes a “false karyosome”), '
              'shiny granular cytoplasm. Pus: opaque greyish streaks; under '
              'the microscope a mass of degenerated leukocytes.',
        }),
        [_wLeuko],
      ),
    ],
    normal: CpFact(
      _T({
        'uz':
            'Darslik: ko‘rish maydonida 0–5 (usulga bog‘liq; MedlinePlus: '
            'odatda juda kam yoki yo‘q).',
        'ru':
            'Учебник: 0–5 в поле зрения (зависит от метода; MedlinePlus: '
            'обычно очень мало или нет).',
        'en':
            'Textbook: 0–5 per field (method-dependent; MedlinePlus: usually '
            'very few if any).',
      }),
      [_kLeuko, _mlWbcRes],
    ),
    meaning: [
      CpFact(
        _T({
          'uz':
              'Topilishi — ovqat hazm qilish yo‘lida yallig‘lanish: ayrim '
              'bakterial infeksiyalar (C. difficile, Salmonella, Shigella, '
              'Campylobacter), yallig‘lanishli ichak kasalligi, amyobiaz. Virus '
              'infeksiyalari, ayrim bakteriyalar va ko‘pchilik parazitlar '
              'odatda leykotsit bermaydi. Manfiy natija yallig‘lanishni istisno '
              'qilmaydi — leykotsitlar tez parchalanadi.',
          'ru':
              'Наличие — воспаление ЖКТ: некоторые бактериальные инфекции '
              '(C. difficile, Salmonella, Shigella, Campylobacter), ВЗК, '
              'амёбиаз. Вирусы, часть бактерий и большинство паразитов обычно '
              'лейкоцитов не дают. Отрицательный результат не исключает '
              'воспаления — лейкоциты быстро разрушаются.',
          'en':
              'Presence means inflammation of the digestive tract: some '
              'bacterial infections (C. difficile, Salmonella, Shigella, '
              'Campylobacter), IBD, amoebiasis. Viral infections, certain '
              'bacteria and most parasites usually do not cause it. A negative '
              'result does not rule out inflammation — leukocytes break down '
              'quickly.',
        }),
        [_mlWbcUse, _mlWbcRes],
      ),
      CpFact(
        _T({
          'uz':
              'Darslik: ko‘payishi — ichak yallig‘lanishi (dizenteriya, yarali '
              'kolit, ichak sili), paraproktal xo‘ppoz yorilishi, o‘sma '
              'parchalanishi. JSST: yiring infeksiya belgisi sifatida qayd '
              'etiladi.',
          'ru':
              'Учебник: увеличение — воспаление кишечника (дизентерия, '
              'язвенный колит, туберкулёз кишечника), прорыв парапроктального '
              'абсцесса, распад опухоли. ВОЗ: гной отмечают как признак '
              'инфекции.',
          'en':
              'Textbook: an increase — intestinal inflammation (dysentery, '
              'ulcerative colitis, intestinal TB), a ruptured perianal '
              'abscess, tumour breakdown. WHO: report pus as a sign of '
              'infection.',
        }),
        [_kLeuko, _wLeuko],
      ),
    ],
  ),
  CpElement(
    id: 'erythrocytes',
    name: _T({'uz': 'Eritrotsitlar', 'ru': 'Эритроциты', 'en': 'Erythrocytes'}),
    look: [
      CpFact(
        _T({
          'uz':
              'To‘g‘ridan-to‘g‘ri preparatda ko‘rinadi; eritrotsit 7,5–8 µm '
              '(JSST tuxum o‘lchamini shu bilan solishtirishni taklif qiladi).',
          'ru':
              'Видны в прямом препарате; эритроцит 7,5–8 мкм (ВОЗ предлагает '
              'сравнивать с ним размер яиц).',
          'en':
              'Seen in the direct preparation; an erythrocyte is 7.5–8 µm '
              '(WHO uses it as a size yardstick for eggs).',
        }),
        [_wMicro, _wEggs],
      ),
    ],
    normal: CpFact(
      _T({
        'uz': 'Darslik: ko‘rish maydonida 0–2 tagacha bo‘lishi mumkin.',
        'ru': 'Учебник: допускается 0–2 в поле зрения.',
        'en': 'Textbook: 0–2 per field may be seen.',
      }),
      [_kRbc],
    ),
    meaning: [
      CpFact(
        _T({
          'uz':
              'Darslik: yuqori bo‘limlardan qon ketganda eritrotsitlar '
              'parchalangan yoki “soya” ko‘rinishida; o‘zgarmaganlari — '
              'gemorroy, yarali kolit, yo‘g‘on ichak o‘smasi parchalanishi, '
              'orqa teshik yoriqlari.',
          'ru':
              'Учебник: при кровотечении из верхних отделов эритроциты '
              'разрушены или в виде «теней»; неизменённые — геморрой, '
              'язвенный колит, распад опухоли толстой кишки, трещины '
              'заднего прохода.',
          'en':
              'Textbook: bleeding from upper segments gives broken or “ghost” '
              'erythrocytes; intact ones suggest haemorrhoids, ulcerative '
              'colitis, a breaking-down colonic tumour or anal fissures.',
        }),
        [_kRbc],
      ),
    ],
    confuse: CpFact(
      _T({
        'uz':
            'E. histolytica invaziv trofozoiti ichida yutilgan eritrotsitlar '
            '(1–20) bo‘lishi mumkin — bu erkin eritrotsit emas.',
        'ru':
            'Инвазивный трофозоит E. histolytica может содержать поглощённые '
            'эритроциты (1–20) — это не свободные эритроциты.',
        'en':
            'An invasive E. histolytica trophozoite may contain ingested '
            'erythrocytes (1–20) — these are not free red cells.',
      }),
      [_wTrophEh],
    ),
  ),
  CpElement(
    id: 'mucus',
    name: _T({'uz': 'Shilliq', 'ru': 'Слизь', 'en': 'Mucus'}),
    look: [
      CpFact(
        _T({
          'uz':
              'Shilliq tiniq; yiring esa ko‘zga xira, kulrang tolalar. Suyuq '
              'najasdagi shilliq parchalarida ko‘pincha G. intestinalis '
              'to‘plamlari bo‘ladi.',
          'ru':
              'Слизь прозрачная; гной — мутные серые тяжи. В хлопьях слизи '
              'жидкого кала часто скопления G. intestinalis.',
          'en':
              'Mucus is transparent; pus forms opaque greyish streaks. Flakes '
              'of mucus in fluid stools often hold clusters of G. '
              'intestinalis.',
        }),
        [_wLeuko, _wTrophG],
      ),
    ],
    normal: CpFact(
      _T({
        'uz': 'Darslik: me’yorda bo‘lmaydi.',
        'ru': 'Учебник: в норме отсутствует.',
        'en': 'Textbook: normally absent.',
      }),
      [_kMucus],
    ),
    meaning: [
      CpFact(
        _T({
          'uz':
              'Darslik: chirish va bijg‘ish dispepsiyasi, qabziyatli surunkali '
              'kolit; yo‘g‘on ichak yallig‘lanishida shilliqda ichak epiteliysi '
              'ko‘p; kataral yallig‘lanish yoki yarada — leykotsitlar; o‘tkir '
              'bakterial dizenteriyada — ko‘p neytrofillar; amyobali '
              'dizenteriyada — eozinofillar.',
          'ru':
              'Учебник: гнилостная и бродильная диспепсия, хронический колит с '
              'запорами; при воспалении толстой кишки в слизи много эпителия; '
              'при катаральном воспалении или язве — лейкоциты; при острой '
              'бактериальной дизентерии — много нейтрофилов; при амёбной — '
              'эозинофилы.',
          'en':
              'Textbook: putrefactive and fermentative dyspepsia, chronic '
              'colitis with constipation; colonic inflammation — much '
              'epithelium in the mucus; catarrhal inflammation or ulcer — '
              'leukocytes; acute bacterial dysentery — many neutrophils; '
              'amoebic dysentery — eosinophils.',
        }),
        [_kMucus],
      ),
    ],
  ),
];

// ───────────────────────── 4. Yashirin qon ─────────────────────────

const cpOccultSections = <CpSection>[
  CpSection(
    _T({
      'uz': 'FIT va gvayak testi (gFOBT)',
      'ru': 'FIT и гваяковый тест (gFOBT)',
      'en': 'FIT and guaiac test (gFOBT)',
    }),
    [
      CpFact(
        _T({
          'uz':
              'gFOBT — kimyoviy modda (gvayak) bilan, odatda 2–3 alohida '
              'defekatsiyadan namuna. FIT (iFOBT) — gemoglobinga '
              'bog‘lanadigan antitana bilan; qonni gFOBTdan yaxshiroq topadi '
              'deb hisoblanadi; brendga qarab 1–3 namuna.',
          'ru':
              'gFOBT — химический (гваяковый) тест, обычно пробы из 2–3 '
              'отдельных дефекаций. FIT (iFOBT) — с антителом, связывающим '
              'гемоглобин; считается лучше gFOBT в выявлении крови; 1–3 пробы '
              'в зависимости от производителя.',
          'en':
              'gFOBT uses a chemical (guaiac), usually on samples from 2–3 '
              'separate bowel movements. FIT (iFOBT) uses an antibody to '
              'haemoglobin, is considered better at finding blood, and needs '
              '1–3 samples depending on the brand.',
        }),
        [_mlFobtHow],
      ),
      CpFact(
        _T({
          'uz':
              'Ko‘p FOBT uchun maxsus tayyorgarlik kerak emas; ba’zi gFOBT '
              'oldidan cheklanadi: NYaQV (ibuprofen, naproksen, aspirin — '
              'shifokor bilan kelishib), kuniga 250 mg dan ortiq vitamin C, '
              'qizil go‘sht, ayrim xom meva va sabzavotlar.',
          'ru':
              'Для многих FOBT подготовка не нужна; перед некоторыми gFOBT '
              'ограничивают: НПВП (ибупрофен, напроксен, аспирин — по '
              'согласованию с врачом), витамин C более 250 мг в сутки, красное '
              'мясо, некоторые сырые фрукты и овощи.',
          'en':
              'Many FOBTs need no preparation; before some gFOBTs avoid NSAIDs '
              '(ibuprofen, naproxen, aspirin — agree with the doctor), vitamin '
              'C over 250 mg a day, red meat and certain raw fruits and '
              'vegetables.',
        }),
        [_mlFobtPrep],
      ),
      CpFact(
        _T({
          'uz':
              'Laboratoriyadagi kimyoviy sinama (JSST): benzidin kanserogen '
              'bo‘lgani uchun endi tavsiya etilmaydi; tekshiruvdan 1 kun oldin '
              'go‘sht, temir preparatlari va tishni qattiq yuvish '
              'chiqariladi.',
          'ru':
              'Лабораторная химическая проба (ВОЗ): бензидин больше не '
              'рекомендуется — канцероген; за 1 день до исследования исключают '
              'мясо, препараты железа и энергичную чистку зубов.',
          'en':
              'Laboratory chemical test (WHO): benzidine is no longer '
              'recommended as it is carcinogenic; for 1 day before, no meat, '
              'no iron and no vigorous tooth brushing.',
        }),
        [_wOccult],
      ),
    ],
  ),
  CpSection(_T({'uz': 'Natija', 'ru': 'Результат', 'en': 'Result'}), [
    CpFact(
      _T({
        'uz':
            'Musbat natija ovqat hazm qilish yo‘lida qon ketishini bildiradi '
            '(polip, gemorroy, divertikulyoz, yara, yarali kolit, '
            'kolorektal saraton) — bu har doim saraton emas. FOBT yolg‘iz '
            'tashxis qo‘ymaydi; ko‘pincha keyingi qadam — kolonoskopiya.',
        'ru':
            'Положительный результат означает кровотечение в ЖКТ (полипы, '
            'геморрой, дивертикулёз, язвы, язвенный колит, колоректальный '
            'рак) — это не всегда рак. FOBT сам по себе не ставит диагноз; '
            'чаще всего следующий шаг — колоноскопия.',
        'en':
            'A positive result means bleeding somewhere in the digestive '
            'tract (polyps, haemorrhoids, diverticulosis, ulcers, ulcerative '
            'colitis, colorectal cancer) — not always cancer. FOBT alone '
            'cannot diagnose; the most common follow-up is colonoscopy.',
      }),
      [_mlFobtWhat, _mlFobtRes],
    ),
    CpFact(
      _T({
        'uz':
            'Kolorektal saraton skriningi uchun FOBT tanlansa, test har yili '
            'takrorlanadi.',
        'ru':
            'Если для скрининга колоректального рака выбран FOBT, тест '
            'повторяют ежегодно.',
        'en':
            'If FOBT is chosen for colorectal cancer screening, it is '
            'repeated every year.',
      }),
      [_mlFobtElse],
    ),
  ]),
];

// ───────────────────────── 5. Boyitish usullari ─────────────────────────

const cpConcentration = <CpFact>[
  CpFact(
    _T({
      'uz':
          'Boyitish tuxum, lichinka yoki sistalar kam bo‘lganda qo‘llanadi. '
          'Avval albatta to‘g‘ridan-to‘g‘ri mikroskopiya qilinadi — '
          'harakatchan sodda jonivorlar boyitilgan preparatda topilmaydi.',
      'ru':
          'Обогащение применяют, когда яиц, личинок или цист мало. Сначала '
          'обязательно прямая микроскопия — подвижные простейшие в '
          'обогащённом препарате не выявляются.',
      'en':
          'Concentration is used when eggs, larvae or cysts are few. Always do '
          'a direct examination first — motile protozoa are not found in '
          'concentrates.',
    }),
    [_wConc],
  ),
  CpFact(
    _T({
      'uz':
          'Willis flotatsiyasi (to‘yingan NaCl): ankilostomidlar (eng yaxshi '
          'usul), askarida, H. nana, Taenia, trixotsefal tuxumlari uchun; '
          'so‘rg‘ichlilar, shistosomalar, Strongyloides lichinkalari va sodda '
          'jonivorlar uchun yaramaydi.',
      'ru':
          'Флотация по Виллису (насыщенный NaCl): для яиц анкилостомид '
          '(лучший метод), аскарид, H. nana, Taenia, власоглава; не подходит '
          'для сосальщиков, шистосом, личинок Strongyloides и простейших.',
      'en':
          'Willis flotation (saturated NaCl): for eggs of hookworm (best '
          'method), Ascaris, H. nana, Taenia and Trichuris; not suitable for '
          'flukes, Schistosoma, Strongyloides larvae or protozoa.',
    }),
    [_wWillis],
  ),
  CpFact(
    _T({
      'uz':
          'Formalin–efir cho‘ktirish (Allen va Ridley): ≈ 0,5 g najas 7 ml '
          '10 % formalinda, filtrlanadi, 3 ml efir (yoki kamroq yonuvchan etil '
          'atsetat), sentrifuga, cho‘kma ko‘riladi. Rejim manbalarda farq '
          'qiladi: JSST — 2000 g, 1 daqiqa; CDC (formalin–etil atsetat) — '
          '500 × g, 10 daqiqadan ikki marta. Laboratoriya SOP ga amal qiling.',
      'ru':
          'Формалин-эфирное осаждение (Allen и Ridley): ≈ 0,5 г кала в 7 мл '
          '10 % формалина, фильтрация, 3 мл эфира (или менее горючего '
          'этилацетата), центрифугирование, осадок исследуют. Режим в '
          'источниках различается: ВОЗ — 2000 g, 1 мин; CDC '
          '(формалин–этилацетат) — 500 × g дважды по 10 мин. Следуйте СОП '
          'лаборатории.',
      'en':
          'Formalin–ether sedimentation (Allen & Ridley): ≈ 0.5 g stool in '
          '7 ml 10% formalin, strain, add 3 ml ether (or less flammable ethyl '
          'acetate), centrifuge, examine the sediment. Settings differ: WHO — '
          '2000 g for 1 min; CDC (formalin–ethyl acetate) — 500 × g for '
          '10 min, twice. Follow your laboratory SOP.',
    }),
    [_wFormolEther, _dProc],
  ),
  CpFact(
    _T({
      'uz':
          'CDC: umumiy diagnostik laboratoriyalar uchun cho‘ktirish usullari '
          'tavsiya etiladi (oson, xatoga kamroq moyil). Flotatsiya tozaroq '
          'material beradi, lekin tuxum va sista devorlari ko‘pincha '
          'yopishib qoladi va ayrim tuxumlar suzib chiqmaydi.',
      'ru':
          'CDC: для общих диагностических лабораторий рекомендуются методы '
          'осаждения (проще, меньше ошибок). Флотация даёт более чистый '
          'материал, но стенки яиц и цист часто спадаются, а некоторые яйца '
          'не всплывают.',
      'en':
          'CDC: sedimentation is recommended for general diagnostic '
          'laboratories (easier, less error-prone). Flotation gives cleaner '
          'material, but egg and cyst walls often collapse and some eggs do '
          'not float.',
    }),
    [_dProc],
  ),
];

// ───────────────────────── 6. Parazitlar ─────────────────────────

const _egg = _T({'uz': 'Tuxum', 'ru': 'Яйцо', 'en': 'Egg'});
const _cyst = _T({'uz': 'Sista', 'ru': 'Циста', 'en': 'Cyst'});

const cpParasites = <CpParasite>[
  CpParasite(
    id: 'ascaris',
    latin: 'Ascaris lumbricoides',
    common: _T({
      'uz': 'Odam askaridasi',
      'ru': 'Аскарида человеческая',
      'en': 'Roundworm',
    }),
    stage: _egg,
    shape: CpShape.ascaris,
    size: CpSize(45, 75, _dAscaris),
    analyteId: 'stool-ova-parasites',
    look: [
      CpFact(
        _T({
          'uz':
              'Urug‘langan tuxum: JSST — 45–70 µm, DPDx — 45–75 µm; oval yoki '
              'dumaloq, qalin qobiq, tashqi qavati g‘adir-budur (mamillyar), '
              'o‘t bilan jigarrang; ichida bitta dumaloq donador massa.',
          'ru':
              'Оплодотворённое яйцо: ВОЗ — 45–70 мкм, DPDx — 45–75 мкм; '
              'овальное или круглое, толстая оболочка с бугристым '
              '(мамиллярным) наружным слоем, окрашенным желчью в коричневый; '
              'внутри одна круглая зернистая масса.',
          'en':
              'Fertilised egg: WHO 45–70 µm, DPDx 45–75 µm; oval or round, '
              'thick shell with a lumpy (mammillated) outer layer stained '
              'brown by bile; one round granular mass inside.',
        }),
        [_wAscaris, _dAscaris],
      ),
      CpFact(
        _T({
          'uz':
              'Urug‘lanmagan tuxum: kattaroq va cho‘ziqroq (JSST 45–90 µm, '
              'DPDx 90 µm gacha), qobig‘i yupqaroq, ichi yirik yaltiroq '
              'donachalar bilan to‘la. Tashqi qavati yo‘q (dekortikatsiyalangan) '
              'shakllar ham uchraydi.',
          'ru':
              'Неоплодотворённое яйцо: крупнее и вытянутее (ВОЗ 45–90 мкм, '
              'DPDx до 90 мкм), оболочка тоньше, внутри крупные блестящие '
              'гранулы. Встречаются формы без наружного слоя '
              '(декортицированные).',
          'en':
              'Unfertilised egg: larger and more elongated (WHO 45–90 µm, DPDx '
              'up to 90 µm), thinner shell, full of large refractile granules. '
              'Decorticated forms without the outer layer also occur.',
        }),
        [_wAscaris, _dAscaris],
      ),
    ],
    notes: [
      CpFact(
        _T({
          'uz':
              'Odatda bir hujayrali chiqadi; 12 soatdan eski namunada 2 yoki 4 '
              'hujayrali tuxumlar ko‘rinishi mumkin. Dekortikatsiyalangan '
              'urug‘lanmagan tuxumni ankilostomid yoki Fasciola tuxumi bilan '
              'adashtirmang.',
          'ru':
              'Обычно выделяется одноклеточным; в пробе старше 12 ч могут быть '
              'яйца с 2 или 4 клетками. Декортицированное неоплодотворённое '
              'яйцо не путайте с яйцом анкилостомид или фасциолы.',
          'en':
              'Usually passed at the one-cell stage; in specimens over 12 h '
              'old 2- or 4-cell eggs may appear. Do not confuse a decorticated '
              'unfertilised egg with hookworm or Fasciola eggs.',
        }),
        [_wEggs, _wAscaris],
      ),
    ],
  ),
  CpParasite(
    id: 'enterobius',
    latin: 'Enterobius vermicularis',
    common: _T({'uz': 'Ostritsa', 'ru': 'Острица', 'en': 'Pinworm'}),
    stage: _egg,
    shape: CpShape.enterobius,
    size: CpSize(50, 60, _dEnterobius),
    analyteId: 'pinworm-test',
    look: [
      CpFact(
        _T({
          'uz':
              'JSST — 50–60 µm; DPDx — 50–60 × 20–30 µm. Oval, aniq '
              'asimmetrik (bir tomoni yassi), qobig‘i silliq va yupqa (qo‘sh '
              'chiziq), rangsiz; ichida donador massa yoki o‘ralgan lichinka '
              '(chiqarilganda qisman embrionlashgan).',
          'ru':
              'ВОЗ — 50–60 мкм; DPDx — 50–60 × 20–30 мкм. Овальное, явно '
              'асимметричное (одна сторона уплощена), оболочка гладкая, '
              'тонкая (двойной контур), бесцветное; внутри зернистая масса '
              'или свёрнутая личинка (выделяется частично эмбрионированным).',
          'en':
              'WHO 50–60 µm; DPDx 50–60 × 20–30 µm. Oval, clearly asymmetrical '
              '(flattened on one side), smooth thin shell (double line), '
              'colourless; contains a granular mass or a curled larva '
              '(partially embryonated when shed).',
        }),
        [_wEnterobius, _dEnterobius],
      ),
    ],
    notes: [
      CpFact(
        _T({
          'uz':
              'Tuxumlar najasda kam uchraydi — anus atrofi burmalaridan '
              'yopishqoq lenta bilan olinadi. DPDx: ertalab, defekatsiya va '
              'yuvinishdan oldin; lenta buyum oynasiga yopishtirilib 10× '
              'obyektivda ko‘riladi.',
          'ru':
              'В кале яйца встречаются редко — их собирают липкой лентой с '
              'перианальных складок. DPDx: утром, до дефекации и умывания; '
              'ленту наклеивают на стекло и смотрят с объективом 10×.',
          'en':
              'Eggs are rarely found in stool — collect from the perianal '
              'folds with adhesive tape. DPDx: in the morning before defecation '
              'and washing; stick the tape on a slide and examine with the ×10 '
              'objective.',
        }),
        [_wEnterobius, _dEnterobius],
      ),
    ],
  ),
  CpParasite(
    id: 'hymenolepis',
    latin: 'Hymenolepis nana',
    common: _T({
      'uz': 'Pakana tasmasimon gijja',
      'ru': 'Карликовый цепень',
      'en': 'Dwarf tapeworm',
    }),
    stage: _egg,
    shape: CpShape.hymenolepis,
    size: CpSize(30, 50, _dHnana),
    analyteId: 'stool-ova-parasites',
    look: [
      CpFact(
        _T({
          'uz':
              'O‘lcham manbalarda farq qiladi: JSST — 40–60 µm, DPDx — 30–50 '
              'µm. Oval, deyarli dumaloq; ikki qavat qobiq, ichki membrana '
              'qutblaridan 4–8 ta qutb iplari chiqadi; ichida olti ilmoqli '
              'onkosfera; juda och kulrang.',
          'ru':
              'Размер в источниках различается: ВОЗ — 40–60 мкм, DPDx — '
              '30–50 мкм. Овальное, почти круглое; двойная оболочка, от '
              'полюсов внутренней мембраны отходят 4–8 полярных нитей; внутри '
              'онкосфера с шестью крючьями; очень бледно-серое.',
          'en':
              'Size differs between sources: WHO 40–60 µm, DPDx 30–50 µm. '
              'Oval, almost round; double shell, 4–8 polar filaments from the '
              'poles of the inner membrane; a six-hooked oncosphere inside; '
              'very pale grey.',
        }),
        [_wHnana, _dHnana],
      ),
    ],
    notes: [
      CpFact(
        _T({
          'uz':
              'H. diminuta tuxumi kattaroq (DPDx 70–85 × 60–80 µm), qutb '
              'iplari yo‘q. Tuxum ko‘p yoki kamligini yozing.',
          'ru':
              'Яйцо H. diminuta крупнее (DPDx 70–85 × 60–80 мкм), полярных '
              'нитей нет. Отмечайте, много яиц или мало.',
          'en':
              'H. diminuta eggs are larger (DPDx 70–85 × 60–80 µm) and lack '
              'polar filaments. Record whether eggs are many or few.',
        }),
        [_dHnana, _wHnana],
      ),
    ],
  ),
  CpParasite(
    id: 'giardia',
    latin: 'Giardia duodenalis (G. intestinalis)',
    common: _T({'uz': 'Lyamblya', 'ru': 'Лямблия', 'en': 'Giardia'}),
    stage: _cyst,
    shape: CpShape.giardia,
    size: CpSize(8, 19, _dGiardia),
    analyteId: 'stool-ova-parasites',
    look: [
      CpFact(
        _T({
          'uz':
              'Sista: JSST — 8–12 µm, DPDx — 8–19 µm (o‘rtacha 10–14); oval, '
              'bir qutbi dumaloqroq; qobig‘i qo‘sh devorli ko‘rinadi; 2–4 '
              'yadro (yetilganida 4); markazda bo‘ylama yaltiroq tola (fibril). '
              'Yod bilan och sariq-yashil yoki ko‘kimtir.',
          'ru':
              'Циста: ВОЗ — 8–12 мкм, DPDx — 8–19 мкм (в среднем 10–14); '
              'овальная, один полюс более округлый; оболочка выглядит '
              'двойной; 2–4 ядра (у зрелой 4); в центре продольная блестящая '
              'фибрилла. С йодом бледно-жёлто-зелёная или голубоватая.',
          'en':
              'Cyst: WHO 8–12 µm, DPDx 8–19 µm (average 10–14); oval, one pole '
              'more rounded; the wall looks double; 2–4 nuclei (4 when '
              'mature); a shiny longitudinal fibril in the centre. Pale '
              'yellow-green or bluish with iodine.',
        }),
        [_wCystG, _dGiardia],
      ),
      CpFact(
        _T({
          'uz':
              'Trofozoit: JSST — 10–18 µm, DPDx — 10–20 µm; noksimon, ikki '
              'yirik yadro; xarakterli harakat faqat yangi suyuq najasda.',
          'ru':
              'Трофозоит: ВОЗ — 10–18 мкм, DPDx — 10–20 мкм; грушевидный, '
              'два крупных ядра; характерное движение — только в свежем '
              'жидком кале.',
          'en':
              'Trophozoite: WHO 10–18 µm, DPDx 10–20 µm; pear-shaped with two '
              'large nuclei; the typical movement is seen only in fresh liquid '
              'stool.',
        }),
        [_wTrophG, _dGiardia],
      ),
    ],
    notes: [
      CpFact(
        _T({
          'uz':
              'Sistalar odatda nam preparatda, trofozoitlar doimiy bo‘yalgan '
              'surtmada topiladi; takroriy namuna kerak bo‘lishi mumkin. '
              'Muqobil — antigen (EIA, immunofluoressensiya) testlari.',
          'ru':
              'Цисты обычно видны во влажном препарате, трофозоиты — в '
              'постоянных окрашенных мазках; может понадобиться повторная '
              'проба. Альтернатива — определение антигена (ИФА, '
              'иммунофлюоресценция).',
          'en':
              'Cysts are usually seen in wet mounts and trophozoites in '
              'permanent stained smears; repeated sampling may be needed. '
              'Antigen tests (EIA, immunofluorescence) are alternatives.',
        }),
        [_dGiardia],
      ),
    ],
  ),
  CpParasite(
    id: 'entamoeba',
    latin: 'Entamoeba histolytica / E. dispar',
    common: _T({
      'uz': 'Dizenteriya amyobasi',
      'ru': 'Дизентерийная амёба',
      'en': 'Dysentery amoeba',
    }),
    stage: _cyst,
    shape: CpShape.entamoeba,
    size: CpSize(12, 15, _dAmeba),
    analyteId: 'stool-ova-parasites',
    look: [
      CpFact(
        _T({
          'uz':
              'Sista: 12–15 µm (JSST ham, DPDx ham), dumaloq; 1–4 yadro '
              '(yetilganida 4), kariosoma kichik, markazda; xromatoid '
              'tanachalar uchi to‘mtoq (kolbasasimon); yosh sistada glikogen '
              'vakuolasi.',
          'ru':
              'Циста: 12–15 мкм (и ВОЗ, и DPDx), круглая; 1–4 ядра (у зрелой '
              '4), кариосома мелкая, центральная; хроматоидные тельца с '
              'тупыми концами (колбасовидные); у молодой цисты гликогеновая '
              'вакуоль.',
          'en':
              'Cyst: 12–15 µm (both WHO and DPDx), round; 1–4 nuclei (4 when '
              'mature) with a small central karyosome; chromatoid bodies with '
              'blunt, rounded ends (sausage-shaped); young cysts may have a '
              'glycogen vacuole.',
        }),
        [_wCystEh, _dAmeba],
      ),
      CpFact(
        _T({
          'uz':
              'E. coli sistasidan farqi: E. coli 12–20 µm, 1–8 yadro, '
              'kariosoma yirik va ekssentrik, xromatoid tanachalar uchi '
              'o‘tkir.',
          'ru':
              'Отличие от цисты E. coli: E. coli 12–20 мкм, 1–8 ядер, '
              'кариосома крупная, эксцентричная, хроматоидные тельца с '
              'острыми концами.',
          'en':
              'Versus E. coli cysts: E. coli is 12–20 µm with 1–8 nuclei, a '
              'large eccentric karyosome and pointed chromatoid bodies.',
        }),
        [_wCystEh, _wCystMicro],
      ),
    ],
    notes: [
      CpFact(
        _T({
          'uz':
              'E. histolytica, E. dispar va E. moshkovskii morfologik jihatdan '
              'farqlanmaydi; trofozoitda yutilgan eritrotsit E. histolytica '
              'uchun klassik, lekin E. dispar da ham kam uchraydi — ishonchli '
              'mezon emas. Turni ajratish — antigen yoki PCR.',
          'ru':
              'E. histolytica, E. dispar и E. moshkovskii морфологически не '
              'различимы; поглощённые эритроциты в трофозоите классически '
              'связаны с E. histolytica, но изредка бывают и у E. dispar — '
              'ненадёжный критерий. Вид различают антигеном или ПЦР.',
          'en':
              'E. histolytica, E. dispar and E. moshkovskii cannot be told '
              'apart by morphology; ingested red cells are classically linked '
              'to E. histolytica but may rarely occur with E. dispar — not a '
              'reliable criterion. Species need antigen detection or PCR.',
        }),
        [_dAmeba, _dAmebaMol],
      ),
    ],
  ),
  CpParasite(
    id: 'trichuris',
    latin: 'Trichuris trichiura',
    common: _T({'uz': 'Qilbosh', 'ru': 'Власоглав', 'en': 'Whipworm'}),
    stage: _egg,
    shape: CpShape.trichuris,
    size: CpSize(50, 55, _dTrichuris),
    analyteId: 'stool-ova-parasites',
    look: [
      CpFact(
        _T({
          'uz':
              'JSST — 50–65 µm; DPDx — 50–55 × 20–25 µm. Bochkasimon, qalin '
              'ikki qavatli qobiq, har qutbida tiniq tiqin; qobig‘i '
              'to‘q sariq, ichi sariq; chiqarilganda embrionlashmagan.',
          'ru':
              'ВОЗ — 50–65 мкм; DPDx — 50–55 × 20–25 мкм. Бочонковидное, '
              'толстая двухслойная оболочка, на каждом полюсе прозрачная '
              'пробка; оболочка оранжевая, содержимое жёлтое; выделяется '
              'неэмбрионированным.',
          'en':
              'WHO 50–65 µm; DPDx 50–55 × 20–25 µm. Barrel-shaped with a thick '
              'two-layered shell and a clear plug at each pole; shell orange, '
              'content yellow; unembryonated when passed.',
        }),
        [_wTrichuris, _dTrichuris],
      ),
    ],
    notes: [
      CpFact(
        _T({
          'uz': 'Tuxum ko‘p yoki kamligini yozing.',
          'ru': 'Отмечайте, много яиц или мало.',
          'en': 'Record whether eggs are many or few.',
        }),
        [_wTrichuris],
      ),
    ],
  ),
  CpParasite(
    id: 'taenia',
    latin: 'Taenia saginata / T. solium',
    common: _T({
      'uz': 'Qoramol va cho‘chqa solityori',
      'ru': 'Бычий и свиной цепни',
      'en': 'Beef and pork tapeworms',
    }),
    stage: _egg,
    shape: CpShape.taenia,
    size: CpSize(30, 35, _dTaenia),
    analyteId: 'stool-ova-parasites',
    look: [
      CpFact(
        _T({
          'uz':
              'DPDx — diametri 30–35 µm, radial chiziqli; JSST matnida — '
              '30–80 µm (manbalar farq qiladi). Dumaloq, juda qalin qobiq; '
              'ichida uch juft yaltiroq ilmoqli onkosfera. JSST: qobig‘i to‘q '
              'sariq-jigarrang.',
          'ru':
              'DPDx — диаметр 30–35 мкм, радиально исчерчены; в тексте ВОЗ — '
              '30–80 мкм (источники различаются). Круглые, очень толстая '
              'оболочка; внутри онкосфера с тремя парами блестящих крючьев. '
              'ВОЗ: оболочка тёмно-жёлто-коричневая.',
          'en':
              'DPDx: 30–35 µm in diameter, radially striated; the WHO text '
              'gives 30–80 µm (sources differ). Round, very thick shell; an '
              'oncosphere with three pairs of shiny hooklets. WHO: shell dark '
              'yellowish-brown.',
        }),
        [_dTaenia, _wTaenia],
      ),
    ],
    notes: [
      CpFact(
        _T({
          'uz':
              'Taenia turlarining tuxumlari bir xil (Echinococcus tuxumiga ham '
              'o‘xshaydi) — tur tuxumdan aniqlanmaydi; bo‘g‘imlar (yon '
              'shoxlar soni: T. saginata 12–30, T. solium 7–13) yoki skoleks '
              'bo‘yicha aniqlanadi. T. saginata tuxumini anus atrofidan ham '
              'olish mumkin.',
          'ru':
              'Яйца всех видов Taenia одинаковы (похожи и на яйца '
              'Echinococcus) — вид по яйцу не определяют; определяют по '
              'членикам (число боковых ветвей матки: T. saginata 12–30, '
              'T. solium 7–13) или сколексу. Яйца T. saginata можно получить и '
              'с перианальной области.',
          'en':
              'Eggs of all Taenia species look identical (and resemble '
              'Echinococcus) — the species cannot be told from eggs; use '
              'proglottids (lateral uterine branches: T. saginata 12–30, T. '
              'solium 7–13) or the scolex. T. saginata eggs can also be '
              'collected perianally.',
        }),
        [_dTaenia, _wTaenia],
      ),
    ],
  ),
];

/// Nisbiy o'lcham diagrammasidagi taqqoslash: eritrotsit 7,5–8 µm (JSST).
const cpRbcSize = CpSize(7.5, 8, _wEggs);

// ───────────────────────── Bog'liq taqdimotlar ─────────────────────────

class CpDeck {
  const CpDeck(this.id, this.title);

  final String id;
  final LocalizedText title;
}

const cpDeckCoprogram = CpDeck(
  'koprogramma-najas-tahlili',
  _T({
    'uz': 'Najasning umumiy tahlili (koprogramma)',
    'ru': 'Общий анализ кала (копрограмма)',
    'en': 'General stool analysis (coprogram)',
  }),
);
const cpDeckParasites = CpDeck(
  'najas-parazitologik-tekshiruv',
  _T({
    'uz': 'Najasda sodda jonivorlar va gijja tuxumlarini aniqlash',
    'ru': 'Выявление простейших и яиц гельминтов в кале',
    'en': 'Detecting protozoa and helminth eggs in stool',
  }),
);
const cpDeckPinworm = CpDeck(
  'perianal-namuna-ostritsa',
  _T({
    'uz':
        'Perianal burmalardan namuna: ostritsa (Enterobius vermicularis) '
        'tuxumlari',
    'ru': 'Перианальная проба: яйца остриц (Enterobius vermicularis)',
    'en': 'Perianal specimen: pinworm (Enterobius vermicularis) eggs',
  }),
);
const cpDecks = [cpDeckCoprogram, cpDeckParasites, cpDeckPinworm];

// ───────────────────────── Matnlar ─────────────────────────

abstract final class CpL {
  static const subtitle = _T({
    'uz': 'Koprogramma, yashirin qon, ichak parazitlari',
    'ru': 'Копрограмма, скрытая кровь, кишечные паразиты',
    'en': 'Coprogram, occult blood, intestinal parasites',
  });

  /// "Darslik" yorlig'i — manba turi (kafedra darsligi), ogohlantirish emas.
  static const textbookNote = _T({
    'uz': '“Darslik” — domla darsligi (Kurbonova 2023).',
    'ru': '«Учебник» — учебник кафедры (Kurbonova 2023).',
    'en': '“Textbook” means the course textbook (Kurbonova 2023).',
  });
  static const notDiagnosis = _T({
    'uz':
        'Ilova topilma nimaga ishora qilishi mumkinligini manbasi bilan '
        'ko‘rsatadi — bu tashxis emas.',
    'ru':
        'Приложение показывает, на что может указывать находка, с '
        'источником — это не диагноз.',
    'en':
        'The app shows what a finding may point to, with sources — this is '
        'not a diagnosis.',
  });
  static const collectTitle = _T({
    'uz': 'Namuna yig‘ish',
    'ru': 'Сбор пробы',
    'en': 'Specimen collection',
  });
  static const collectSub = _T({
    'uz': 'Idish, muddat, bir nechta namuna, konservant',
    'ru': 'Контейнер, сроки, несколько проб, консервант',
    'en': 'Container, timing, several samples, preservative',
  });
  static const macroTitle = _T({
    'uz': 'Makroskopik tekshiruv',
    'ru': 'Макроскопическое исследование',
    'en': 'Macroscopic examination',
  });
  static const macroSub = _T({
    'uz': 'Shakl, rang, reaksiya, aralashmalar',
    'ru': 'Форма, цвет, реакция, примеси',
    'en': 'Form, colour, reaction, admixtures',
  });
  static const microTitle = _T({
    'uz': 'Koprogramma mikroskopiyasi',
    'ru': 'Микроскопия копрограммы',
    'en': 'Coprogram microscopy',
  });
  static const microSub = _T({
    'uz': 'Mushak tolasi, yog‘, kraxmal, leykotsit, eritrotsit, shilliq',
    'ru': 'Мышечные волокна, жир, крахмал, лейкоциты, эритроциты, слизь',
    'en': 'Muscle fibres, fat, starch, leukocytes, red cells, mucus',
  });
  static const occultTitle = _T({
    'uz': 'Yashirin qon',
    'ru': 'Скрытая кровь',
    'en': 'Occult blood',
  });
  static const occultSub = _T({
    'uz': 'FIT va gvayak testi, tayyorgarlik, natija',
    'ru': 'FIT и гваяковый тест, подготовка, результат',
    'en': 'FIT and guaiac test, preparation, result',
  });
  static const parasitesTitle = _T({
    'uz': 'Ichak parazitlari',
    'ru': 'Кишечные паразиты',
    'en': 'Intestinal parasites',
  });
  static const parasitesSub = _T({
    'uz': 'Boyitish usullari, tuxum va sistalar kaliti (sxema)',
    'ru': 'Методы обогащения, ключ яиц и цист (схема)',
    'en': 'Concentration methods, egg and cyst key (schematic)',
  });
  static const concentrationTitle = _T({
    'uz': 'Boyitish usullari',
    'ru': 'Методы обогащения',
    'en': 'Concentration methods',
  });
  static const parasiteListTitle = _T({
    'uz': 'Tuxum va sistalar',
    'ru': 'Яйца и цисты',
    'en': 'Eggs and cysts',
  });
  static const sizeChartTitle = _T({
    'uz': 'Nisbiy o‘lcham (sxema, DPDx uzunligi)',
    'ru': 'Относительный размер (схема, длина по DPDx)',
    'en': 'Relative size (schematic, DPDx length)',
  });
  static const sizeChartRbc = _T({
    'uz': 'Eritrotsit (JSST)',
    'ru': 'Эритроцит (ВОЗ)',
    'en': 'Erythrocyte (WHO)',
  });
  static const schemeLabel = _T({
    'uz': 'Sxema (foto emas)',
    'ru': 'Схема (не фото)',
    'en': 'Schematic (not a photo)',
  });
  static const schemeNote = _T({
    'uz':
        'Ilovaning o‘z chizmasi: manbadagi asosiy belgilarni ko‘rsatadi, '
        'mikroskopdagi ko‘rinish va rang boshqacha bo‘ladi.',
    'ru':
        'Собственный рисунок приложения: показывает ключевые признаки из '
        'источника, вид и цвет под микроскопом другие.',
    'en':
        'The app’s own drawing of the key features from the sources; the '
        'microscope view and colours differ.',
  });
  static const lookTitle = _T({
    'uz': 'Morfologiya kaliti',
    'ru': 'Ключ морфологии',
    'en': 'Morphology key',
  });
  static const notesTitle = _T({
    'uz': 'Namuna va farqlash',
    'ru': 'Проба и дифференциация',
    'en': 'Specimen and differentiation',
  });
  static const elementLookTitle = _T({
    'uz': 'Qanday ko‘rinadi',
    'ru': 'Как выглядит',
    'en': 'Appearance',
  });
  static const normalTitle = _T({
    'uz': 'Me’yorda',
    'ru': 'В норме',
    'en': 'Normally',
  });
  static const meaningTitle = _T({
    'uz': 'Nimaga ishora qilishi mumkin (tashxis emas)',
    'ru': 'На что может указывать (не диагноз)',
    'en': 'What it may point to (not a diagnosis)',
  });
  static const confuseTitle = _T({
    'uz': 'Nima bilan adashtiriladi',
    'ru': 'С чем путают',
    'en': 'Look-alikes',
  });
  static const relatedTitle = _T({
    'uz': 'Amaliy protokollar (taqdimot)',
    'ru': 'Практические протоколы (презентации)',
    'en': 'Practical protocols (slides)',
  });
  static const relatedCardsTitle = _T({
    'uz': 'Tahlil kartalari',
    'ru': 'Карточки анализов',
    'en': 'Test cards',
  });
  static const openCard = _T({
    'uz': 'Tahlil kartasi',
    'ru': 'Карточка анализа',
    'en': 'Test card',
  });
  static const microUnit = _T({'uz': 'µm', 'ru': 'мкм', 'en': 'µm'});

  static const all = <LocalizedText>[
    subtitle,
    textbookNote,
    notDiagnosis,
    collectTitle,
    collectSub,
    macroTitle,
    macroSub,
    microTitle,
    microSub,
    occultTitle,
    occultSub,
    parasitesTitle,
    parasitesSub,
    concentrationTitle,
    parasiteListTitle,
    sizeChartTitle,
    sizeChartRbc,
    schemeLabel,
    schemeNote,
    lookTitle,
    notesTitle,
    elementLookTitle,
    normalTitle,
    meaningTitle,
    confuseTitle,
    relatedTitle,
    relatedCardsTitle,
    openCard,
    microUnit,
    _egg,
    _cyst,
  ];
}

CpElement? cpElement(String id) {
  for (final e in cpElements) {
    if (e.id == id) return e;
  }
  return null;
}

CpParasite? cpParasite(String id) {
  for (final p in cpParasites) {
    if (p.id == id) return p;
  }
  return null;
}

/// Barcha da'volar (test uchun).
List<CpFact> get cpAllFacts => [
  for (final s in cpCollectSections) ...s.facts,
  for (final s in cpMacroSections) ...s.facts,
  ...cpMicroIntro,
  for (final e in cpElements) ...e.facts,
  for (final s in cpOccultSections) ...s.facts,
  ...cpConcentration,
  for (final p in cpParasites) ...p.facts,
];
