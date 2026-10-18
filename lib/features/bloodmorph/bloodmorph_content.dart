/// Qon morfologiyasi (periferik qon surtmasi): normal eritrotsit va nimaga
/// qarash, eritrotsit o'zgarishlari (rasmli kartalar), trombotsitlar,
/// retikulotsitlar, anemiya tasnifi yordamchisi, surtma sifati va
/// artefaktlar, "Bu qaysi o'zgarish?" mashqi (3 tilda).
///
/// Har da'vo — manba va joy bilan ([BmFact], [CalcRef]); manbada yo'q narsa
/// yozilmaydi; "nimaga ishora qilishi mumkin" — tashxis emas. Rasmlar —
/// Wikimedia Commons'dagi erkin litsenziyali (CC0 / CC BY / CC BY-SA)
/// mikrofotolar: litsenziya, muallif va asl izoh fayl sahifasidan
/// tekshirilgan ([bmCheckedAt]); faqat kichraytirilgan
/// (tool/bloodmorph_images.py). Leykotsitlar — leykoformula bo'limida,
/// analit kartalari — kontent paketida (takrorlanmaydi). Kontent mutaxassis
/// tekshiruvidan o'tmagan — ekranda "qoralama" belgisi (gistologiya,
/// sitologiya kabi). Manbalar jadvali: docs/BLOODMORPH_SOURCES.md.
library;

import '../content/content_model.dart';
import '../reference/reference_sources.dart';
import '../tools/calc_info.dart';
import 'bloodmorph_logic.dart';

typedef _T = LocalizedText;

/// Rasm litsenziyasi va izohi tekshirilgan sana.
const bmCheckedAt = '2026-10-17';

abstract final class BmSources {
  /// JSST qo'llanmasi: surtma tayyorlash, bo'yash, eritrotsit shakllari,
  /// retikulotsit va trombotsit sanash (9.10–9.14).
  static const who2003 = CalcSources.whoBasicLab2003;
  static const adewoyin2014 = CalcSource(
    id: 'bm-adewoyin-2014',
    citation:
        'Adewoyin AS, Nwogoh B. Peripheral blood film — a review. Ann Ib '
        'Postgrad Med. 2014;12(2):71–79. PMC4415389 (CC BY-NC 3.0)',
    url: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC4415389/',
  );
  static const msdAnemia = CalcSource(
    id: 'bm-msd-evaluation-of-anemia',
    citation:
        'Gerber GF. Evaluation of Anemia. MSD Manual Professional Version '
        '(full review May 2024)',
    url:
        'https://www.msdmanuals.com/professional/hematology-and-oncology/'
        'approach-to-the-patient-with-anemia/evaluation-of-anemia',
  );
  static const takami2026 = RefSources.takami2026;
  static const cattaneo2025 = CalcSource(
    id: 'bm-cattaneo-2025-ptcp',
    citation:
        'Cattaneo M. Pseudothrombocytopenia and other conditions associated '
        'with spuriously low platelet counts. Haematologica. '
        '2025;110(8):1677–1692. doi:10.3324/haematol.2024.286234 '
        '(CC BY-NC 4.0)',
    url: 'https://doi.org/10.3324/haematol.2024.286234',
  );
  static const chueh2022 = CalcSources.chueh2022;
  static const whoHb2024 = RefSources.whoHb2024;
  static const whoFerritin2020 = RefSources.whoFerritin2020;
  static const jung2011 = CalcSource(
    id: 'bm-jung-2011-neuroacanthocytosis',
    citation:
        'Jung HH, Danek A, Walker RH. Neuroacanthocytosis syndromes. '
        'Orphanet J Rare Dis. 2011;6:68. doi:10.1186/1750-1172-6-68 '
        '(CC BY 2.0)',
    url: 'https://doi.org/10.1186/1750-1172-6-68',
  );
  static const zama2020 = CalcSource(
    id: 'bm-zama-2020-stomatocytosis',
    citation:
        'Zama D, Giulietti G, Muratore E, et al. A novel PIEZO1 mutation in '
        'a patient with dehydrated hereditary stomatocytosis: a case report '
        'and a brief review of literature. Ital J Pediatr. 2020;46:102. '
        'doi:10.1186/s13052-020-00864-x (CC BY 4.0)',
    url: 'https://doi.org/10.1186/s13052-020-00864-x',
  );

  /// Kurs adabiyoti (Google Drive "KDL" papkasi) — faqat iqtibos, matn
  /// ko'chirilmagan. Word nusxasida bet raqamlari yo'q — lokator bo'lim.
  static const najmitdinov1998 = RefSources.najmitdinov1998;
  static const saidov2017 = CalcSource(
    id: 'book-saidov-2017',
    citation:
        'Саидов С.А., Исаджанов М.С. Қоннинг умумий клиник ва иммунофермент '
        'таҳлиллари: референс кўрсаткичлари аҳамияти. Тошкент: Тошкент '
        'фармацевтика институти; 2017',
    url: null,
  );

  /// Rasm izohlari (nima tasvirlangani, bo'yoq) — fayl sahifalari;
  /// lokator — fayl nomi.
  static const commonsFiles = CalcSource(
    id: 'bm-commons-file-pages',
    citation:
        'Wikimedia Commons — file description pages of the pictures used '
        '(checked $bmCheckedAt)',
    url: 'https://commons.wikimedia.org/',
  );

  static const all = [
    who2003,
    adewoyin2014,
    msdAnemia,
    takami2026,
    cattaneo2025,
    chueh2022,
    whoHb2024,
    whoFerritin2020,
    jung2011,
    zama2020,
    najmitdinov1998,
    saidov2017,
    commonsFiles,
  ];
}

// ── Lokatorlar ──
const _wLook = CalcRef(BmSources.who2003, '9.10.4, p. 305');
const _wTable = CalcRef(BmSources.who2003, '9.10.4, Table 9.10, p. 305');
const _wNormal = CalcRef(BmSources.who2003, '9.10.4, p. 306');
const _wP307 = CalcRef(BmSources.who2003, '9.10.4, p. 307');
const _wP308 = CalcRef(BmSources.who2003, '9.10.4, p. 308');
const _wP309 = CalcRef(BmSources.who2003, '9.10.4, p. 309');
const _wPrep = CalcRef(BmSources.who2003, '9.10.3, p. 300–302');
const _wStain = CalcRef(BmSources.who2003, '9.10.3, p. 303–305');
const _wRetic = CalcRef(BmSources.who2003, '9.12, p. 316–318');
const _wPlt = CalcRef(BmSources.who2003, '9.14, p. 321');
const _aPrep = CalcRef(
  BmSources.adewoyin2014,
  'Preparation of a peripheral blood film slide',
);
const _aInterp = CalcRef(
  BmSources.adewoyin2014,
  'Interpreting a peripheral blood film',
);
const _aRbc = CalcRef(BmSources.adewoyin2014, 'Red cell morphology');
const _aT1 = CalcRef(BmSources.adewoyin2014, 'Red cell morphology, Table 1');
const _aPlt = CalcRef(BmSources.adewoyin2014, 'Platelet morphology');
const _aReport = CalcRef(
  BmSources.adewoyin2014,
  'Reporting a peripheral blood film',
);
const _mIndices = CalcRef(
  BmSources.msdAnemia,
  'Complete blood count and RBC indices',
);
const _mSmear = CalcRef(BmSources.msdAnemia, 'Peripheral smear');
const _mRetic = CalcRef(BmSources.msdAnemia, 'Reticulocyte count');
const _mTable = CalcRef(
  BmSources.msdAnemia,
  'Table: Characteristics of Common Anemias',
);
const _tT3 = CalcRef(BmSources.takami2026, 'Table 3');
const _tT4 = CalcRef(BmSources.takami2026, 'Table 4');
const _tT5 = CalcRef(BmSources.takami2026, 'Table 5');
const _tStep2 = CalcRef(
  BmSources.takami2026,
  'Step 2: Evaluate the RBC lineage',
);
const _tStep5 = CalcRef(
  BmSources.takami2026,
  'Step 5: Always consider spurious results',
);
const _cAbs = CalcRef(BmSources.cattaneo2025, 'Abstract');
const _cEpi = CalcRef(BmSources.cattaneo2025, 'Epidemiology');
const _cMech = CalcRef(
  BmSources.cattaneo2025,
  'Mechanism of formation of platelet clumps',
);
const _cDx = CalcRef(
  BmSources.cattaneo2025,
  'Diagnosis of pseudothrombocytopenia',
);
const _cSat = CalcRef(BmSources.cattaneo2025, 'Platelet satellitism');
const _cGiant = CalcRef(
  BmSources.cattaneo2025,
  'Presence of large/giant platelets',
);
const _chCrc = CalcRef(BmSources.chueh2022, 'Laboratory tests for screening');
const _chSmear = CalcRef(BmSources.chueh2022, 'Peripheral blood smear');
const _whoHb = CalcRef(BmSources.whoHb2024, 'Table 2, p. 9');
const _whoFer = CalcRef(
  BmSources.whoFerritin2020,
  'Executive summary, Table 1',
);
const _jung = CalcRef(BmSources.jung2011, 'Definition');
const _zama = CalcRef(BmSources.zama2020, 'Background');
const _najRbc = CalcRef(
  BmSources.najmitdinov1998,
  'Кириш: Қоннинг аҳамияти — эритроцит (3–13-расмлар матни)',
);
const _najRetic = CalcRef(
  BmSources.najmitdinov1998,
  'Кириш: Қоннинг аҳамияти — ретикулоцит (14-расм матни)',
);
const _saidovRdw = CalcRef(BmSources.saidov2017, 'RDW, p. 36');

// Rasm izohi (fayl sahifasi) — faqat rasmdagi narsani tavsiflash uchun.
const _fTear = CalcRef(
  BmSources.commonsFiles,
  'File:Tear drop poikilocytes.jpg',
);
const _fStomato = CalcRef(BmSources.commonsFiles, 'File:Stomatocytes.jpg');
const _fAgglut = CalcRef(
  BmSources.commonsFiles,
  'File:Red cell agglutination.jpg',
);

/// Bitta da'vo va uning manbalari.
class BmFact {
  const BmFact(this.text, this.refs);

  final LocalizedText text;
  final List<CalcRef> refs;
}

/// Wikimedia Commons rasmi: muallif, litsenziya, asl izoh.
class BmImage {
  const BmImage({
    required this.file,
    required this.commonsTitle,
    required this.author,
    required this.license,
    required this.licenseUrl,
    required this.caption,
    required this.captionTr,
    required this.width,
    required this.height,
    required this.originalWidth,
    required this.originalHeight,
    this.stain,
  });

  /// `assets/bloodmorph/img/<file>.jpg`.
  final String file;

  /// Commons'dagi fayl nomi (`File:` siz).
  final String commonsTitle;
  final String author;
  final String license;
  final String licenseUrl;

  /// Fayl sahifasidagi izoh, so'zma-so'z (inglizcha).
  final String caption;

  /// Izohning LabGuide tarjimasi (qisqa, faqat nima tasvirlangani).
  final LocalizedText captionTr;

  /// Bo'yoq — faqat fayl sahifasida yozilgan bo'lsa.
  final LocalizedText? stain;

  /// Ilovadagi nusxa o'lchami va asl fayl o'lchami (px).
  final int width;
  final int height;
  final int originalWidth;
  final int originalHeight;

  String get asset => 'assets/bloodmorph/img/$file.jpg';

  String get sourcePage =>
      'https://commons.wikimedia.org/wiki/'
      '${Uri.encodeComponent('File:${commonsTitle.replaceAll(' ', '_')}')}';
}

enum BmGroup { size, colour, shape, inclusion, arrangement, platelet }

/// Bitta morfologik topilma (eritrotsit yoki trombotsit o'zgarishi).
class BmFinding {
  const BmFinding({
    required this.id,
    required this.group,
    required this.name,
    required this.image,
    required this.see,
    required this.pointsTo,
    this.aka,
    this.confuse,
    this.refer,
    this.analytes = const [],
    this.quiz = true,
  });

  final String id;
  final BmGroup group;
  final LocalizedText name;

  /// Boshqa nomlari (sinonimlar).
  final LocalizedText? aka;

  /// `null` — mos, aniq belgilangan erkin rasm topilmagan.
  final BmImage? image;

  /// "Nimani ko'rasiz".
  final List<BmFact> see;

  /// "Nimaga ishora qilishi mumkin" (tashxis emas).
  final BmFact pointsTo;

  /// Nima bilan adashtiriladi.
  final BmFact? confuse;

  /// Kimga / qachon yuborish (o'ziga xos eslatma; umumiy eslatma — BmL).
  final BmFact? refer;

  /// Kontent paketidagi tegishli tahlil kartalari (id).
  final List<String> analytes;

  /// "Bu qaysi o'zgarish?" mashqiga kiradimi.
  final bool quiz;

  List<BmFact> get facts => [...see, pointsTo, ?confuse, ?refer];

  /// Kartadagi barcha manbalar, takrorsiz (tartib bilan).
  List<CalcRef> get refs => bmUniqueRefs(facts);
}

List<CalcRef> bmUniqueRefs(Iterable<BmFact> facts) {
  final seen = <String>{};
  return [
    for (final f in facts)
      for (final r in f.refs)
        if (seen.add('${r.source.id}|${r.locator}')) r,
  ];
}

/// Sarlavhali bo'lim (normal eritrotsit, sifat, retikulotsitlar...).
class BmSection {
  const BmSection({
    required this.id,
    required this.title,
    required this.facts,
    this.image,
  });

  final String id;
  final LocalizedText title;
  final List<BmFact> facts;
  final BmImage? image;
}

// ───────────────────────── Rasmlar ─────────────────────────

const _cc0 = 'CC0 1.0';
const _cc0Url = 'https://creativecommons.org/publicdomain/zero/1.0/';
const _bySa3 = 'CC BY-SA 3.0';
const _bySa3Url = 'https://creativecommons.org/licenses/by-sa/3.0/';
const _bySa4 = 'CC BY-SA 4.0';
const _bySa4Url = 'https://creativecommons.org/licenses/by-sa/4.0/';
const _by2 = 'CC BY 2.0';
const _by2Url = 'https://creativecommons.org/licenses/by/2.0/';
const _by3 = 'CC BY 3.0';
const _by3Url = 'https://creativecommons.org/licenses/by/3.0/';
const _erhabor = 'Prof. Osaro Erhabor';
const _erhaborBySa = 'Prof. Erhabor Osaro';
const _mourao = 'Paulo Henrique Orlandi Mourao';
const _haggstrom = 'Mikael Häggström, M.D.';
const _uthman = 'Ed Uthman';

// BM_IMAGES_BEGIN (tool/bloodmorph_images.py o'lchamlarni shu yerga mos
// qiladi; qo'lda o'zgartirilsa — skriptni qayta ishga tushiring.)
const _imgPoly = BmImage(
  file: 'polychromasia',
  commonsTitle: 'Polychromasia.jpg',
  author: _erhabor,
  license: _cc0,
  licenseUrl: _cc0Url,
  caption:
      'Polychromasia is a term used to describe the heterogeneous staining '
      'of red blood cells of different ages. The larger (macrocytic) younger '
      'cells often stain blue. Polychromatic red cells are commonly seen '
      'following haemolysis, treatment with haematinics (iron, folate and '
      'vit B12), haemorrhage, haemolysis and dyserythropoiesis.',
  captionTr: _T({
    'uz':
        'Polixromaziya: turli yoshdagi eritrotsitlarning har xil bo‘yalishi; '
        'yirikroq yosh hujayralar ko‘pincha ko‘kish',
    'ru':
        'Полихромазия: неодинаковая окраска эритроцитов разного возраста; '
        'более крупные молодые клетки часто голубоватые',
    'en':
        'Polychromasia: uneven staining of red cells of different ages; the '
        'larger young cells often stain blue',
  }),
  width: 900,
  height: 720,
  originalWidth: 2560,
  originalHeight: 2048,
);

const _imgSphero = BmImage(
  file: 'spherocytes',
  commonsTitle: 'Hereditary Spherocytosis smear 2010-03-17.JPG',
  author: _mourao,
  license: _bySa3,
  licenseUrl: _bySa3Url,
  caption: 'Peripheral blood smear from patient with hereditary spherocytosis.',
  captionTr: _T({
    'uz': 'Irsiy sferotsitozli bemorning periferik qon surtmasi',
    'ru': 'Мазок периферической крови больного наследственным сфероцитозом',
    'en': 'Peripheral blood film from a patient with hereditary spherocytosis',
  }),
  width: 900,
  height: 673,
  originalWidth: 1712,
  originalHeight: 1281,
);

const _imgTarget = BmImage(
  file: 'target_cells',
  commonsTitle: 'Target cells.jpg',
  author: _erhabor,
  license: _cc0,
  licenseUrl: _cc0Url,
  caption:
      'Target cells (Codocytes, Leptocytes or Mexican hat cells). They are '
      'red cells with a central area of intense staining surrounded by a '
      'ring of less intensely stained periphery and then a further ring of '
      'dense staining at the edge of the cell. Target cells are commonly seen '
      'in blood film of patients with liver disease, thalassaemia or '
      'sickle-cell disease, iron-deficiency anaemia and in splenectomised '
      'patients.',
  captionTr: _T({
    'uz':
        'Nishonsimon hujayralar (kodotsitlar): markazi to‘q, atrofida och '
        'halqa, cheti yana to‘q',
    'ru':
        'Мишеневидные клетки (кодоциты): тёмный центр, светлое кольцо и снова '
        'тёмный край',
    'en':
        'Target cells (codocytes): dark centre, a paler ring, then a dark rim',
  }),
  width: 900,
  height: 720,
  originalWidth: 2560,
  originalHeight: 2048,
);

const _imgSchisto = BmImage(
  file: 'schistocytes',
  commonsTitle: 'Schizocyte smear 2009-12-22.JPG',
  author: _mourao,
  license: _bySa3,
  licenseUrl: _bySa3Url,
  caption: 'Schizocytes (hemolytic-uremic syndrome).',
  captionTr: _T({
    'uz':
        'Shizotsitlar (gemolitik-uremik sindrom); rasmda strelkalar bilan '
        'ko‘rsatilgan',
    'ru':
        'Шизоциты (гемолитико-уремический синдром); на снимке отмечены '
        'стрелками',
    'en': 'Schistocytes (haemolytic uraemic syndrome); arrowed in the picture',
  }),
  width: 900,
  height: 676,
  originalWidth: 1063,
  originalHeight: 798,
);

const _imgSickle = BmImage(
  file: 'sickle_cells',
  commonsTitle: 'Sickle Cell Disease.jpg',
  author: _erhabor,
  license: _cc0,
  licenseUrl: _cc0Url,
  caption:
      'Sickle Cell (Drepanocytes) are found in patient with sickle cell '
      'anaemia and other sickle syndromes but not in sickle trait. They are '
      'banana shaped red cells. They are commonly seen in patients with '
      'sickle cell anaemia- a  hereditary blood disorder characterized by an '
      'abnormality in the oxygen-carrying haemoglobin molecule in the '
      'cytoplasm of the red cells resulting  in the formation of  abnormal, '
      'rigid, sickle shape red cells.',
  captionTr: _T({
    'uz':
        'O‘roqsimon hujayralar (drepanotsitlar), o‘roqsimon hujayrali anemiya',
    'ru': 'Серповидные клетки (дрепаноциты) при серповидноклеточной анемии',
    'en': 'Sickle cells (drepanocytes) in sickle cell anaemia',
  }),
  width: 900,
  height: 720,
  originalWidth: 1280,
  originalHeight: 1024,
);

const _imgTear = BmImage(
  file: 'teardrop_cells',
  commonsTitle: 'Teardrop Cells smear 2009-09-22.JPG',
  author: _mourao,
  license: _bySa3,
  licenseUrl: _bySa3Url,
  caption: 'Teardrop Cells (dacrocytes).',
  captionTr: _T({
    'uz': 'Tomchisimon hujayralar (dakriotsitlar)',
    'ru': 'Каплевидные клетки (дакриоциты)',
    'en': 'Teardrop cells (dacrocytes)',
  }),
  width: 900,
  height: 675,
  originalWidth: 1242,
  originalHeight: 932,
);

const _imgEllipto = BmImage(
  file: 'elliptocytes',
  commonsTitle: 'Hereditary Elliptocytosis 6 0.jpg',
  author: 'Dr Erhabor Osaro',
  license: _bySa3,
  licenseUrl: _bySa3Url,
  caption:
      'Case of Hereditary Elliptocytosis (Ovalocytosis) characterized by the '
      'presence of oval or elongated cigar-shaped red cells.',
  captionTr: _T({
    'uz':
        'Irsiy elliptotsitoz (ovalotsitoz): oval yoki cho‘zinchoq, '
        'sigaraga o‘xshash eritrotsitlar',
    'ru':
        'Наследственный эллиптоцитоз (овалоцитоз): овальные или вытянутые '
        'сигаровидные эритроциты',
    'en':
        'Hereditary elliptocytosis (ovalocytosis): oval or elongated '
        'cigar-shaped red cells',
  }),
  width: 900,
  height: 720,
  originalWidth: 2560,
  originalHeight: 2048,
);

const _imgStomato = BmImage(
  file: 'stomatocytes',
  commonsTitle: 'Stomatocytes.jpg',
  author: _erhabor,
  license: _cc0,
  licenseUrl: _cc0Url,
  caption:
      'Stomatocytes are red cells with a characteristic oval or rectangular '
      'shaped central pallor,. They often result from a loss of concavity on '
      'one side. They are commonly seen in the blood film of patients with '
      'liver disease, electrolyte imbalance and in cases of hereditary '
      'stomatocytosis.',
  captionTr: _T({
    'uz':
        'Stomatotsitlar: markaziy och joyi oval yoki to‘rtburchak '
        '(og‘izsimon) eritrotsitlar',
    'ru':
        'Стоматоциты: эритроциты с овальным или прямоугольным '
        '(ротовидным) центральным просветлением',
    'en':
        'Stomatocytes: red cells with an oval or rectangular (mouth-like) '
        'central pallor',
  }),
  width: 900,
  height: 720,
  originalWidth: 1280,
  originalHeight: 1024,
);

const _imgAcantho = BmImage(
  file: 'acanthocytes',
  commonsTitle: 'Acanthocytes 4.jpg',
  author: _erhaborBySa,
  license: _bySa4,
  licenseUrl: _bySa4Url,
  caption: 'Acantocytosis',
  captionTr: _T({
    'uz': 'Akantotsitoz',
    'ru': 'Акантоцитоз',
    'en': 'Acanthocytosis',
  }),
  width: 900,
  height: 720,
  originalWidth: 1280,
  originalHeight: 1024,
);

const _imgEchino = BmImage(
  file: 'echinocytes',
  commonsTitle: 'Crenated red cells 11.jpg',
  author: _erhaborBySa,
  license: _bySa4,
  licenseUrl: _bySa4Url,
  caption: 'A film showing crenated red cells.',
  captionTr: _T({
    'uz': 'Burishgan (krenatsiyali) eritrotsitlar surtmasi',
    'ru': 'Мазок с зубчатыми (кренированными) эритроцитами',
    'en': 'A film showing crenated red cells',
  }),
  width: 900,
  height: 720,
  originalWidth: 2560,
  originalHeight: 2048,
);

const _imgStipple = BmImage(
  file: 'basophilic_stippling',
  commonsTitle: 'Basophilic stippling 2.jpg',
  author: _erhaborBySa,
  license: _bySa4,
  licenseUrl: _bySa4Url,
  caption: 'Slide show red cells with Basophilic Stippling',
  captionTr: _T({
    'uz': 'Bazofil punktatsiyali eritrotsitlar',
    'ru': 'Эритроциты с базофильной пунктацией',
    'en': 'Red cells with basophilic stippling',
  }),
  width: 900,
  height: 720,
  originalWidth: 2560,
  originalHeight: 2048,
);

const _imgHowell = BmImage(
  file: 'howell_jolly',
  commonsTitle: 'Howell-Jolly smear 2010-11-17.JPG',
  author: _mourao,
  license: _bySa3,
  licenseUrl: _bySa3Url,
  caption:
      'Howell-Jolly bodies: small, round inclusions seen in erythrocytes, '
      'found in various anemias and after splenectomy.',
  captionTr: _T({
    'uz':
        'Xauell–Jolli tanachalari: eritrotsit ichidagi kichik yumaloq '
        'kiritmalar',
    'ru': 'Тельца Хауэлла–Жолли: мелкие круглые включения в эритроцитах',
    'en': 'Howell–Jolly bodies: small round inclusions in red cells',
  }),
  width: 900,
  height: 673,
  originalWidth: 1386,
  originalHeight: 1036,
);

const _imgRouleaux = BmImage(
  file: 'rouleaux',
  commonsTitle: 'Rouleaux Red Cells.jpg',
  author: _erhabor,
  license: _cc0,
  licenseUrl: _cc0Url,
  caption:
      'Rouleaux are stacked red cells resulting from the presence of high '
      'levels of circulating acute-phase proteins. Rouleaux are commonly seen '
      'in patients with myeloma, other  paraproteinaemia, autoimmune '
      'disorders and chronic inflammation.',
  captionTr: _T({
    'uz': '“Tanga ustunchalari” (rouleaux): ustma-ust terilgan eritrotsitlar',
    'ru': 'Монетные столбики: эритроциты, сложенные стопкой',
    'en': 'Rouleaux: stacked red cells',
  }),
  width: 900,
  height: 720,
  originalWidth: 2560,
  originalHeight: 2048,
);

const _imgAgglut = BmImage(
  file: 'agglutination',
  commonsTitle: 'Red cell agglutination.jpg',
  author: _erhaborBySa,
  license: _bySa4,
  licenseUrl: _bySa4Url,
  caption:
      'A case of red cell agglutination in a patient with cold agglutinin '
      'disease.',
  captionTr: _T({
    'uz': 'Sovuq agglyutininlar kasalligida eritrotsitlar agglyutinatsiyasi',
    'ru': 'Агглютинация эритроцитов при болезни холодовых агглютининов',
    'en': 'Red cell agglutination in cold agglutinin disease',
  }),
  width: 900,
  height: 720,
  originalWidth: 1280,
  originalHeight: 1024,
);

const _imgGiantPlt = BmImage(
  file: 'giant_platelet',
  commonsTitle: 'Micrograph of a giant platelet.jpg',
  author: _haggstrom,
  license: _cc0,
  licenseUrl: _cc0Url,
  caption: 'Micrograph of a giant platelet',
  captionTr: _T({
    'uz': 'Gigant trombotsit',
    'ru': 'Гигантский тромбоцит',
    'en': 'A giant platelet',
  }),
  width: 330,
  height: 301,
  originalWidth: 427,
  originalHeight: 389,
);

const _imgClump = BmImage(
  file: 'platelet_clumping',
  commonsTitle: 'Platelet Clumping 8.jpg',
  author: _erhaborBySa,
  license: _bySa4,
  licenseUrl: _bySa4Url,
  caption:
      'An example of platelet clumping in a peripheral blood film (Psudo- '
      'thrombocytopenia).',
  captionTr: _T({
    'uz': 'Surtmada trombotsitlar to‘plami (psevdotrombotsitopeniya)',
    'ru': 'Агрегаты тромбоцитов в мазке (псевдотромбоцитопения)',
    'en': 'Platelet clumping on a blood film (pseudothrombocytopenia)',
  }),
  width: 900,
  height: 720,
  originalWidth: 2560,
  originalHeight: 2048,
);

const _imgSatellite = BmImage(
  file: 'platelet_satellitism',
  commonsTitle: 'Platelet Satellitism smear 2009-09-11.JPG',
  author: _mourao,
  license: _bySa3,
  licenseUrl: _bySa3Url,
  caption:
      'Platelet Satellitism: platelet adherence to neutrophils only seen in '
      'EDTA anticoagulated blood.',
  captionTr: _T({
    'uz':
        'Trombotsit satellitizmi: trombotsitlar neytrofilga yopishgan '
        '(faqat EDTA li qonda)',
    'ru':
        'Сателлитизм тромбоцитов: тромбоциты прилипли к нейтрофилу (только в '
        'крови с ЭДТА)',
    'en':
        'Platelet satellitism: platelets stuck to a neutrophil (EDTA blood '
        'only)',
  }),
  width: 900,
  height: 677,
  originalWidth: 1640,
  originalHeight: 1233,
);

const _imgAniso = BmImage(
  file: 'anisocytosis',
  commonsTitle: 'Anisocytosis 2.jpg',
  author: _erhaborBySa,
  license: _bySa4,
  licenseUrl: _bySa4Url,
  caption: 'Red Cells show marked variation in size (Anisocytosis)',
  captionTr: _T({
    'uz': 'Eritrotsitlar o‘lchami keskin har xil (anizotsitoz)',
    'ru': 'Выраженные различия эритроцитов по размеру (анизоцитоз)',
    'en': 'Marked variation in red cell size (anisocytosis)',
  }),
  width: 900,
  height: 720,
  originalWidth: 1280,
  originalHeight: 1024,
);

const _imgIda = BmImage(
  file: 'iron_deficiency',
  commonsTitle:
      'Iron-deficiency Anemia, Peripheral Blood Smear (4422704616).jpg',
  author: _uthman,
  license: _by2,
  licenseUrl: _by2Url,
  caption:
      'This is a trashy smear, but it does show an extremely advanced case '
      'of the microcytic/hypochromic anemia characteristic of iron '
      'deficiency. The mean corpuscular volume (MCV) was 55 fL (reference '
      'range: 80 - 94 fL).',
  captionTr: _T({
    'uz':
        'Temir tanqisligiga xos, juda rivojlangan mikrotsitar-gipoxrom anemiya '
        '(MCV 55 fL); muallif surtma sifati past ekanini aytgan',
    'ru':
        'Резко выраженная микроцитарная гипохромная анемия, характерная для '
        'дефицита железа (MCV 55 фл); автор отмечает низкое качество мазка',
    'en':
        'Very advanced microcytic hypochromic anaemia typical of iron '
        'deficiency (MCV 55 fL); the author notes the smear is of poor '
        'quality',
  }),
  width: 900,
  height: 599,
  originalWidth: 1711,
  originalHeight: 1139,
);

const _imgRetic = BmImage(
  file: 'reticulocytes',
  commonsTitle: 'Reticulocytes Human Blood Supravital Stain.jpg',
  author: 'Ed Uthman, MD',
  license: _by3,
  licenseUrl: _by3Url,
  caption:
      'Supravital stain of a smear of human blood from a patient with '
      'hemolytic anemia. The reticulocytes are the cells with the dark blue '
      'dots and curved linear structures (reticulum) in the cytoplasm.',
  captionTr: _T({
    'uz':
        'Gemolitik anemiyali bemor qoni, supravital bo‘yash: retikulotsitlarda '
        'to‘q ko‘k nuqtalar va egri ipchalar (retikulum)',
    'ru':
        'Кровь больного гемолитической анемией, суправитальная окраска: в '
        'ретикулоцитах тёмно-синие точки и изогнутые нити (ретикулум)',
    'en':
        'Blood from a patient with haemolytic anaemia, supravital stain: '
        'reticulocytes show dark blue dots and curved threads (reticulum)',
  }),
  stain: _T({
    'uz': 'Supravital bo‘yash',
    'ru': 'Суправитальная окраска',
    'en': 'Supravital stain',
  }),
  width: 900,
  height: 600,
  originalWidth: 1008,
  originalHeight: 672,
);
// BM_IMAGES_END

// ───────────────────────── Umumiy eslatmalar ─────────────────────────

/// Har kartada: surtma xulosasi kim tomonidan va qanday baholanadi.
const bmReferGeneral = BmFact(
  _T({
    'uz':
        'Surtma natijasi bemorning klinik ma’lumoti va umumiy qon tahlili '
        '(indekslar, ECHT) bilan birga talqin qilinadi; muhim o‘zgarish '
        'bo‘lsa, xulosani gematolog (laborator shifokor) imzolaydi. Bu '
        'ilova tashxis qo‘ymaydi.',
    'ru':
        'Мазок интерпретируют вместе с клиническими данными пациента и общим '
        'анализом крови (индексы, СОЭ); при существенных изменениях '
        'заключение подписывает гематолог (врач лаборатории). Приложение '
        'диагноз не ставит.',
    'en':
        'A film is interpreted together with the patient’s clinical details '
        'and the blood count (indices, ESR); when there is a significant '
        'abnormality the report is signed by a haematologist (laboratory '
        'physician). This app does not make a diagnosis.',
  }),
  [_aInterp, _aReport],
);

// ───────────────────────── Normal eritrotsit ─────────────────────────

const bmNormalSections = <BmSection>[
  BmSection(
    id: 'normal',
    title: _T({
      'uz': 'Normal eritrotsit',
      'ru': 'Нормальный эритроцит',
      'en': 'The normal red cell',
    }),
    facts: [
      BmFact(
        _T({
          'uz':
              'Ikki tomoni botiq disk, diametri taxminan 7–8 µm; markazida '
              'och joy (diametrning qariyb uchdan biri) bor, ichida kiritma '
              'yo‘q.',
          'ru':
              'Двояковогнутый диск диаметром около 7–8 мкм; в центре '
              'просветление (примерно треть диаметра), включений нет.',
          'en':
              'A biconcave disc about 7–8 µm across, with a central pallor of '
              'roughly a third of the diameter and no inclusions.',
        }),
        [_aRbc],
      ),
      BmFact(
        _T({
          'uz':
              'JSST qo‘llanmasida: o‘lchami 6–8 µm, yumaloq, gardishi to‘q '
              'pushti, markazi och pushti yoki rangsiz; Leyshman bo‘yog‘ida '
              'eritrotsitlar pushti-qizil.',
          'ru':
              'В руководстве ВОЗ: размер 6–8 мкм, округлый, периферия '
              'насыщенно-розовая, центр бледно-розовый или бесцветный; при '
              'окраске по Лейшману эритроциты розово-красные.',
          'en':
              'In the WHO manual: 6–8 µm, round, deep pink at the periphery '
              'and pale pink or colourless in the centre; red cells stain '
              'pink-red with Leishman stain.',
        }),
        [_wNormal, _wTable],
      ),
      BmFact(
        _T({
          'uz':
              'Mikroskopda o‘lchamni solishtirish uchun: normal eritrotsit '
              'kichik limfotsit yadrosi kattaligida.',
          'ru':
              'Ориентир размера под микроскопом: нормальный эритроцит '
              'сопоставим с ядром малого лимфоцита.',
          'en':
              'A size yardstick under the microscope: a normal red cell is '
              'about the size of a small lymphocyte’s nucleus.',
        }),
        [_aRbc],
      ),
      BmFact(
        _T({
          'uz':
              'Kurs adabiyotida: normal eritrotsit 6–9 µm, o‘rtacha diametri '
              '7,2 µm; 6 µm dan kichigi — mikrotsit, 9–12 µm — makrotsit, '
              '12 µm dan kattasi — megalotsit.',
          'ru':
              'В учебнике курса: нормальный эритроцит 6–9 мкм, средний '
              'диаметр 7,2 мкм; меньше 6 мкм — микроцит, 9–12 мкм — макроцит, '
              'больше 12 мкм — мегалоцит.',
          'en':
              'In the course textbook: a normal red cell is 6–9 µm, mean '
              'diameter 7.2 µm; under 6 µm is a microcyte, 9–12 µm a '
              'macrocyte, over 12 µm a megalocyte.',
        }),
        [_najRbc],
      ),
    ],
  ),
  BmSection(
    id: 'where',
    title: _T({
      'uz': 'Surtmaning qayeriga qarash kerak',
      'ru': 'Куда смотреть в мазке',
      'en': 'Where to look on the film',
    }),
    facts: [
      BmFact(
        _T({
          'uz':
              'Eritrotsitlarni yupqa uchidan sal oldinroq ko‘ring: u yerda '
              'hujayralar bir-biriga tegib turadi, lekin ustma-ust tushmaydi. '
              'Qalin uchida ular juda zich, eng yupqa uchida esa juda siyrak.',
          'ru':
              'Эритроциты оценивают чуть раньше тонкого края: там клетки '
              'касаются друг друга, но не наслаиваются. В толстой части они '
              'слишком плотные, на самом тонком крае — слишком редкие.',
          'en':
              'Look at the red cells just before the thin end: there they '
              'touch but do not overlap. At the thick end they are packed too '
              'closely, at the very thin end there are too few.',
        }),
        [_wLook],
      ),
      BmFact(
        _T({
          'uz':
              'Surtmaning boshi (qalin qismi)da hujayralar zichligi '
              'dumidagidan ikki baravar ko‘p — undan qochiladi. Patli uchi '
              'trombotsit to‘plamlari va yirik hujayralar (monotsit, '
              'blastlar) uchun ko‘riladi.',
          'ru':
              'В головной (толстой) части плотность клеток вдвое выше, чем в '
              'хвосте, — её избегают. Пёрышко (тонкий край) просматривают на '
              'агрегаты тромбоцитов и крупные клетки (моноциты, бласты).',
          'en':
              'The head (thick part) has twice the cell density of the tail '
              'and is avoided. The feathered end is checked for platelet '
              'clumps and large cells (monocytes, blasts).',
        }),
        [_aInterp],
      ),
    ],
  ),
  BmSection(
    id: 'size',
    title: _T({
      'uz': 'O‘lcham: anizotsitoz',
      'ru': 'Размер: анизоцитоз',
      'en': 'Size: anisocytosis',
    }),
    image: _imgAniso,
    facts: [
      BmFact(
        _T({
          'uz':
              'Anizotsitoz — turli o‘lchamdagi eritrotsitlar birga uchrashi '
              '(masalan, 9 µm va 6 µm li hujayralar aralash); ko‘p turdagi '
              'anemiyalarda uchraydi.',
          'ru':
              'Анизоцитоз — присутствие эритроцитов разного размера '
              '(например, клетки 9 мкм и 6 мкм вперемешку); встречается при '
              'многих видах анемий.',
          'en':
              'Anisocytosis means red cells of different sizes together (for '
              'example 9 µm cells mixed with 6 µm cells); it is seen in many '
              'types of anaemia.',
        }),
        [_wP309],
      ),
      BmFact(
        _T({
          'uz':
              'Analizatorda o‘lchamlar farqi RDW bilan, o‘rtacha hajm MCV bilan '
              'ifodalanadi. MCV faqat o‘rtachani ko‘rsatadi: mikrotsit va '
              'makrotsitlar aralash bo‘lsa, MCV me’yorda chiqib, faqat RDW '
              'yuqori bo‘lishi mumkin.',
          'ru':
              'Анализатор выражает разброс размеров через RDW, средний объём — '
              'через MCV. MCV отражает лишь среднее: при смеси микро- и '
              'макроцитов MCV может быть в норме, а повышен только RDW.',
          'en':
              'Analysers express size variation as RDW and mean volume as '
              'MCV. MCV is only an average: with mixed microcytes and '
              'macrocytes it can be normal while only the RDW is high.',
        }),
        [_mIndices, _tT3],
      ),
      BmFact(
        _T({
          'uz':
              'RDW ning “me’yori” manbadan manbaga farq qiladi (masalan, '
              '11–15 % yoki kattalarda 11,5–14,5 %) — o‘z laboratoriyangiz '
              'oralig‘idan foydalaning.',
          'ru':
              '«Норма» RDW в разных источниках различается (например, '
              '11–15 % или у взрослых 11,5–14,5 %) — пользуйтесь интервалом '
              'своей лаборатории.',
          'en':
              'The “normal” RDW differs between sources (for example 11–15% '
              'or 11.5–14.5% in adults) — use your own laboratory’s range.',
        }),
        [_aRbc, _saidovRdw],
      ),
    ],
  ),
  BmSection(
    id: 'colour',
    title: _T({
      'uz': 'Rang: gipoxromiya va polixromaziya',
      'ru': 'Цвет: гипохромия и полихромазия',
      'en': 'Colour: hypochromia and polychromasia',
    }),
    image: _imgIda,
    facts: [
      BmFact(
        _T({
          'uz':
              'Eritrotsit rangi undagi gemoglobin miqdorini aks ettiradi. '
              'Gipoxromiya — gemoglobin kam (ko‘pincha temir tanqisligi); '
              'giperxrom hujayralarda markaziy och joy bo‘lmaydi (masalan, '
              'sferotsitlar, o‘roqsimon hujayralar).',
          'ru':
              'Окраска эритроцита отражает содержание гемоглобина. Гипохромия — '
              'гемоглобина мало (чаще всего дефицит железа); у гиперхромных '
              'клеток нет центрального просветления (например, сфероциты, '
              'серповидные клетки).',
          'en':
              'A red cell’s colour reflects its haemoglobin content. '
              'Hypochromia means low haemoglobin (most often iron '
              'deficiency); hyperchromic cells lack central pallor (for '
              'example spherocytes, sickle cells).',
        }),
        [_aRbc],
      ),
      BmFact(
        _T({
          'uz':
              'Indekslar bo‘yicha “gipoxromiya” — MCHC 30 g/dL (300 g/L) dan '
              'past; sferotsitlarda MCHC oshishi mumkin.',
          'ru':
              'По индексам «гипохромия» — MCHC ниже 30 г/дл (300 г/л); при '
              'сфероцитах MCHC может быть повышена.',
          'en':
              'In terms of indices, “hypochromia” means an MCHC below 30 g/dL '
              '(300 g/L); spherocytes can raise the MCHC.',
        }),
        [_mIndices],
      ),
      BmFact(
        _T({
          'uz':
              'Polixromaziya — Rayt bo‘yog‘ida ko‘kish tusli eritrotsitlar; '
              'bular retikulotsitlar (ichida RNK bor). Ular retikulotsitlar '
              'ishlab chiqarilishini taxminiy baholashga yordam beradi.',
          'ru':
              'Полихромазия — голубоватые эритроциты при окраске по Райту; это '
              'ретикулоциты (содержат РНК). Она даёт грубую оценку продукции '
              'ретикулоцитов.',
          'en':
              'Polychromasia is bluish red cells on a Wright stain; these are '
              'reticulocytes (they contain RNA). It gives a rough estimate of '
              'reticulocyte production.',
        }),
        [_mRetic, _aRbc],
      ),
      BmFact(
        _T({
          'uz':
              'Diqqat: surtma nam havoda sekin qurisa, markaziy och joy '
              'chegarasi keskin yaltiroq chiziq bo‘lib qoladi va gipoxromiyani '
              'baholash qiyinlashadi.',
          'ru':
              'Внимание: если мазок медленно сохнет во влажном воздухе, граница '
              'центрального просветления становится резкой и блестящей, и '
              'гипохромию оценить трудно.',
          'en':
              'Caution: a film that dries slowly in humid air shows an '
              'artefactual sharp refractile border around the central pallor, '
              'making hypochromia hard to assess.',
        }),
        [_aPrep],
      ),
    ],
  ),
  BmSection(
    id: 'shape',
    title: _T({
      'uz': 'Shakl: poykilotsitoz',
      'ru': 'Форма: пойкилоцитоз',
      'en': 'Shape: poikilocytosis',
    }),
    facts: [
      BmFact(
        _T({
          'uz':
              'Poykilotsitoz — qonda har xil shakldagi eritrotsitlar (yumaloq, '
              'oval, uchburchak, noksimon, botiq) birga uchrashi; ko‘p og‘ir '
              'anemiyalarda va miyelofibrozda uchraydi.',
          'ru':
              'Пойкилоцитоз — эритроциты разной формы в крови (круглые, '
              'овальные, треугольные, грушевидные, с вдавлениями); бывает при '
              'многих тяжёлых анемиях и миелофиброзе.',
          'en':
              'Poikilocytosis means red cells of different shapes in the blood '
              '(round, oval, triangular, pear-shaped, indented); it is seen in '
              'many severe anaemias and in myelofibrosis.',
        }),
        [_wP309],
      ),
      BmFact(
        _T({
          'uz':
              'Shakl o‘zgarishlari anemiya sababiga muhim ishora beradi — '
              'har bir shakl alohida kartada.',
          'ru':
              'Изменения формы — важная подсказка к причине анемии; каждая '
              'форма разобрана в отдельной карточке.',
          'en':
              'Shape changes are important clues to the cause of anaemia — '
              'each shape has its own card.',
        }),
        [_aRbc],
      ),
      BmFact(
        _T({
          'uz':
              'Kurs adabiyotida: anizotsitoz bilan birga doimo poykilotsitoz '
              'kuzatiladi; og‘ir anemiyalarda shizotsitlar ham uchraydi.',
          'ru':
              'В учебнике курса: вместе с анизоцитозом всегда наблюдается '
              'пойкилоцитоз; при тяжёлых анемиях встречаются и шизоциты.',
          'en':
              'In the course textbook: anisocytosis is always accompanied by '
              'poikilocytosis; in severe anaemias schistocytes also appear.',
        }),
        [_najRbc],
      ),
    ],
  ),
  BmSection(
    id: 'inclusions',
    title: _T({
      'uz': 'Kiritmalar va joylashuv',
      'ru': 'Включения и расположение',
      'en': 'Inclusions and arrangement',
    }),
    facts: [
      BmFact(
        _T({
          'uz':
              'Kiritmalar ko‘pincha eritrotsit yetilishining buzilishi, '
              'oksidlovchi shikast yoki infeksiya natijasi: Xauell–Jolli '
              'tanachalari, bazofil punktatsiya, Pappenxaym tanachalari, '
              'parazitlar (plazmodiy, babeziya).',
          'ru':
              'Включения чаще всего — результат нарушения созревания, '
              'окислительного повреждения или инфекции: тельца Хауэлла–Жолли, '
              'базофильная пунктация, тельца Паппенгейма, паразиты '
              '(плазмодии, бабезии).',
          'en':
              'Inclusions usually result from defective maturation, oxidant '
              'injury or infection: Howell–Jolly bodies, basophilic stippling, '
              'Pappenheimer bodies, parasites (Plasmodium, Babesia).',
        }),
        [_aRbc],
      ),
      BmFact(
        _T({
          'uz':
              'Ayrim kiritmalar faqat supravital bo‘yashda ko‘rinadi: Xeynts '
              'tanachalari (denaturatsiyalangan gemoglobin), HbH kiritmalari, '
              'retikulotsitlar to‘ri.',
          'ru':
              'Некоторые включения видны только при суправитальной окраске: '
              'тельца Гейнца (денатурированный гемоглобин), включения HbH, '
              'сеточка ретикулоцитов.',
          'en':
              'Some inclusions are seen only with supravital staining: Heinz '
              'bodies (denatured haemoglobin), HbH inclusions, the '
              'reticulocyte network.',
        }),
        [_aRbc],
      ),
      BmFact(
        _T({
          'uz':
              'Joylashuv ham ahamiyatli: “tanga ustunchalari” (rouleaux) va '
              'agglyutinatsiya — alohida kartalarda.',
          'ru':
              'Важно и расположение клеток: монетные столбики и агглютинация — '
              'в отдельных карточках.',
          'en':
              'Arrangement matters too: rouleaux and agglutination have their '
              'own cards.',
        }),
        [_aRbc],
      ),
    ],
  ),
];

// ───────────────────────── Eritrotsit o'zgarishlari ─────────────────────────

const bmFindings = <BmFinding>[
  // ── O'lcham ──
  BmFinding(
    id: 'microcytes',
    group: BmGroup.size,
    name: _T({'uz': 'Mikrotsitlar', 'ru': 'Микроциты', 'en': 'Microcytes'}),
    image: _imgIda,
    analytes: ['mcv', 'rdw', 'ferritin', 'iron'],
    see: [
      BmFact(
        _T({
          'uz': 'Kichik eritrotsitlar — taxminan 5 µm.',
          'ru': 'Мелкие эритроциты — около 5 мкм.',
          'en': 'Small red cells — about 5 µm.',
        }),
        [_wP307],
      ),
      BmFact(
        _T({
          'uz':
              'Ko‘pincha gipoxromiya bilan birga; indekslar bo‘yicha '
              'mikrotsitar — MCV < 80 fL.',
          'ru':
              'Часто вместе с гипохромией; по индексам микроцитарная — MCV '
              '< 80 фл.',
          'en':
              'Often together with hypochromia; by indices, microcytic means '
              'MCV < 80 fL.',
        }),
        [_aRbc, _mIndices],
      ),
    ],
    pointsTo: BmFact(
      _T({
        'uz':
            'Ko‘pincha temir tanqisligi anemiyasi, talassemiyalar, '
            'sideroblast anemiya; ayrim surunkali kasallik anemiyasida MCV '
            'past yoki chegarada bo‘ladi.',
        'ru':
            'Чаще железодефицитная анемия, талассемии, сидеробластная анемия; '
            'при части анемий хронических заболеваний MCV снижен или на '
            'границе нормы.',
        'en':
            'Most often iron-deficiency anaemia, thalassaemias, sideroblastic '
            'anaemia; in some anaemia of chronic disease the MCV is low or '
            'borderline.',
      }),
      [_wP307, _mIndices],
    ),
    confuse: BmFact(
      _T({
        'uz':
            'Sferotsitlardan farqlash kerak: sferotsit ham kichik, lekin '
            'mukammal yumaloq va to‘qroq bo‘yalgan, markazi och emas.',
        'ru':
            'Нужно отличать от сфероцитов: сфероцит тоже мелкий, но идеально '
            'круглый, окрашен темнее, без центрального просветления.',
        'en':
            'Distinguish from spherocytes: a spherocyte is also small but '
            'perfectly round, more darkly stained, without central pallor.',
      }),
      [_wP307, _wP308, _aRbc],
    ),
  ),
  BmFinding(
    id: 'macrocytes',
    group: BmGroup.size,
    name: _T({
      'uz': 'Makrotsitlar (oval va yumaloq)',
      'ru': 'Макроциты (овальные и круглые)',
      'en': 'Macrocytes (oval and round)',
    }),
    image: null,
    analytes: ['mcv', 'vitamin-b12', 'folate', 'reticulocytes'],
    see: [
      BmFact(
        _T({
          'uz':
              'Katta eritrotsitlar — 9–10 µm; indekslar bo‘yicha makrotsitar — '
              'MCV > 100 fL.',
          'ru':
              'Крупные эритроциты — 9–10 мкм; по индексам макроцитарная — MCV '
              '> 100 фл.',
          'en':
              'Large red cells — 9–10 µm; by indices, macrocytic means MCV '
              '> 100 fL.',
        }),
        [_wP307, _mIndices],
      ),
      BmFact(
        _T({
          'uz':
              'Makrotsitlar oval yoki yumaloq bo‘ladi — bu farqning '
              'diagnostik ahamiyati bor.',
          'ru':
              'Макроциты бывают овальными или круглыми — это различие имеет '
              'диагностическое значение.',
          'en':
              'Macrocytes may be oval or round — the difference matters '
              'diagnostically.',
        }),
        [_aRbc],
      ),
    ],
    pointsTo: BmFact(
      _T({
        'uz':
            'Oval makrotsitlar — megaloblast anemiya (B12 yoki folat '
            'tanqisligi), miyelodisplaziya, gidroksikarbamid; yumaloq '
            'makrotsitlar — jigar kasalligi, alkogol. Ko‘p retikulotsit ham '
            'MCV ni oshiradi.',
        'ru':
            'Овальные макроциты — мегалобластная анемия (дефицит B12 или '
            'фолата), миелодисплазия, гидроксикарбамид; круглые макроциты — '
            'болезнь печени, алкоголь. Много ретикулоцитов тоже повышает MCV.',
        'en':
            'Oval macrocytes — megaloblastic anaemia (B12 or folate '
            'deficiency), myelodysplasia, hydroxycarbamide; round macrocytes — '
            'liver disease, alcohol. Many reticulocytes also raise the MCV.',
      }),
      [_aRbc, _mIndices],
    ),
    confuse: BmFact(
      _T({
        'uz':
            'Retikulotsitlardan (polixromatofil hujayralardan) farqlash '
            'kerak — ular ham yirik.',
        'ru':
            'Нужно отличать от ретикулоцитов (полихроматофильных клеток) — '
            'они тоже крупные.',
        'en':
            'Distinguish from reticulocytes (polychromatic cells) — they are '
            'large too.',
      }),
      [_wP307, _mIndices],
    ),
  ),
  // ── Rang ──
  BmFinding(
    id: 'polychromasia',
    group: BmGroup.colour,
    name: _T({
      'uz': 'Polixromaziya (polixromatofiliya)',
      'ru': 'Полихромазия (полихроматофилия)',
      'en': 'Polychromasia (polychromatophilia)',
    }),
    image: _imgPoly,
    analytes: ['reticulocytes'],
    see: [
      BmFact(
        _T({
          'uz':
              'Romanovskiy (Rayt) bo‘yog‘ida ko‘kish-kulrang tusli, odatda '
              'yirikroq eritrotsitlar — bular retikulotsitlar.',
          'ru':
              'При окраске по Романовскому (Райту) — голубовато-серые, '
              'обычно более крупные эритроциты; это ретикулоциты.',
          'en':
              'On a Romanowsky (Wright) stain — bluish-grey, usually larger '
              'red cells; these are reticulocytes.',
        }),
        [_mRetic, _aRbc],
      ),
    ],
    pointsTo: BmFact(
      _T({
        'uz':
            'Ilikning faol javobi: o‘tkir qon yo‘qotish, gemoliz yoki '
            'davodan keyingi tiklanish. Retikulotsitlarni taxminiy '
            'baholaydi — aniq son supravital bo‘yash bilan sanaladi.',
        'ru':
            'Активный ответ костного мозга: острая кровопотеря, гемолиз или '
            'восстановление после лечения. Даёт грубую оценку ретикулоцитов — '
            'точное число считают при суправитальной окраске.',
        'en':
            'An active marrow response: acute blood loss, haemolysis or '
            'recovery after treatment. It is a rough estimate — the exact '
            'count needs a supravital stain.',
      }),
      [_mRetic, _mTable],
    ),
    confuse: BmFact(
      _T({
        'uz':
            'Makrotsitlar bilan adashtirmang: polixromatofil hujayra '
            'ko‘kish tusi bilan ajralib turadi.',
        'ru':
            'Не путайте с макроцитами: полихроматофильная клетка отличается '
            'голубоватым оттенком.',
        'en':
            'Do not confuse with macrocytes: a polychromatic cell stands out '
            'by its bluish tint.',
      }),
      [_wP307, _mRetic],
    ),
  ),
  // ── Shakl ──
  BmFinding(
    id: 'spherocytes',
    group: BmGroup.shape,
    name: _T({'uz': 'Sferotsitlar', 'ru': 'Сфероциты', 'en': 'Spherocytes'}),
    image: _imgSphero,
    analytes: ['mchc', 'reticulocytes', 'ldh', 'bilirubin-total'],
    see: [
      BmFact(
        _T({
          'uz':
              'Kichik (taxminan 6 µm), mukammal yumaloq, odatdagidan to‘qroq '
              'bo‘yalgan, markaziy och joyi yo‘q hujayralar.',
          'ru':
              'Мелкие (около 6 мкм), идеально круглые, окрашены темнее '
              'обычного, без центрального просветления.',
          'en':
              'Small (about 6 µm), perfectly round, more darkly stained '
              'cells without central pallor.',
        }),
        [_wP308, _aRbc],
      ),
    ],
    pointsTo: BmFact(
      _T({
        'uz':
            'Gemolitik anemiyalar: irsiy sferotsitoz, issiq antitelali '
            'autoimmun gemolitik anemiya, ABO nomosligi, og‘ir kuyish. '
            'Sferotsitlarda MCHC oshishi mumkin.',
        'ru':
            'Гемолитические анемии: наследственный сфероцитоз, '
            'аутоиммунная гемолитическая анемия с тепловыми антителами, '
            'несовместимость по ABO, тяжёлые ожоги. При сфероцитах MCHC может '
            'быть повышена.',
        'en':
            'Haemolytic anaemias: hereditary spherocytosis, warm autoimmune '
            'haemolytic anaemia, ABO incompatibility, severe burns. '
            'Spherocytes can raise the MCHC.',
      }),
      [_aT1, _wP308, _mIndices, _chSmear],
    ),
    confuse: BmFact(
      _T({
        'uz':
            'Mikrotsitlardan farqi: mikrotsitning markazida och joy bor, '
            'sferotsit esa bir tekis to‘q.',
        'ru':
            'Отличие от микроцитов: у микроцита есть центральное '
            'просветление, сфероцит окрашен равномерно и темно.',
        'en':
            'Difference from microcytes: a microcyte keeps a central pallor, '
            'a spherocyte is evenly dark.',
      }),
      [_wP307, _wP308],
    ),
    refer: BmFact(
      _T({
        'uz':
            'Immun gemolizni ajratish uchun antiglobulin (Kumbs) testi, '
            'gemoliz belgilari (retikulotsitlar, LDG, bilirubin) — shifokor '
            'qaroriga ko‘ra.',
        'ru':
            'Для выделения иммунного гемолиза — антиглобулиновая проба '
            '(Кумбса), признаки гемолиза (ретикулоциты, ЛДГ, билирубин) — по '
            'решению врача.',
        'en':
            'To identify immune haemolysis — the antiglobulin (Coombs) test '
            'and haemolysis markers (reticulocytes, LDH, bilirubin), as the '
            'doctor decides.',
      }),
      [_mTable],
    ),
  ),
  BmFinding(
    id: 'target-cells',
    group: BmGroup.shape,
    name: _T({
      'uz': 'Nishonsimon hujayralar (kodotsitlar)',
      'ru': 'Мишеневидные клетки (кодоциты)',
      'en': 'Target cells (codocytes)',
    }),
    image: _imgTarget,
    analytes: ['hemoglobin-electrophoresis', 'mcv', 'ferritin'],
    see: [
      BmFact(
        _T({
          'uz':
              'Markazi va gardishi yaxshi bo‘yalgan, oralig‘ida rangsiz halqa '
              '— nishonga o‘xshaydi; o‘lchami 6–8 µm.',
          'ru':
              'Центр и периферия хорошо окрашены, между ними бесцветное кольцо '
              '— похоже на мишень; размер 6–8 мкм.',
          'en':
              'The centre and the rim stain well with a colourless ring '
              'between them — like a target; 6–8 µm.',
        }),
        [_wNormal],
      ),
    ],
    pointsTo: BmFact(
      _T({
        'uz':
            'Talassemiyalar, boshqa gemoglobinopatiyalar (HbC, HbSC), '
            'o‘roqsimon hujayrali anemiya, temir tanqisligi, jigar kasalligi, '
            'splenektomiyadan keyin. Sabab — hujayra hajmi va gemoglobini '
            'o‘rtasidagi nomutanosiblik (gemoglobin kam yoki membrana ortiqcha).',
        'ru':
            'Талассемии, другие гемоглобинопатии (HbC, HbSC), '
            'серповидноклеточная анемия, дефицит железа, болезни печени, после '
            'спленэктомии. Причина — несоответствие объёма клетки и '
            'гемоглобина (мало гемоглобина или избыток мембраны).',
        'en':
            'Thalassaemias, other haemoglobinopathies (HbC, HbSC), sickle cell '
            'anaemia, iron deficiency, liver disease, after splenectomy. The '
            'cause is a mismatch between cell volume and haemoglobin (too '
            'little haemoglobin or excess membrane).',
      }),
      [_wNormal, _aT1, _mSmear],
    ),
    confuse: BmFact(
      _T({
        'uz':
            'Kurs adabiyotida: yakka nishonsimon hujayralar normal surtmada '
            'ham, turli anemiyalarda ham uchrashi mumkin.',
        'ru':
            'В учебнике курса: единичные мишеневидные клетки могут '
            'встречаться и в нормальном мазке, и при разных анемиях.',
        'en':
            'In the course textbook: occasional target cells may be seen both '
            'in normal films and in various anaemias.',
      }),
      [_najRbc],
    ),
  ),
  BmFinding(
    id: 'schistocytes',
    group: BmGroup.shape,
    name: _T({
      'uz': 'Shizotsitlar (eritrotsit bo‘laklari)',
      'ru': 'Шизоциты (фрагменты эритроцитов)',
      'en': 'Schistocytes (red cell fragments)',
    }),
    aka: _T({
      'uz': 'dubulg‘asimon hujayralar, keratotsitlar',
      'ru': 'шлемовидные клетки, кератоциты',
      'en': 'helmet cells, keratocytes',
    }),
    image: _imgSchisto,
    analytes: ['platelets', 'ldh', 'creatinine', 'd-dimer', 'fibrinogen'],
    see: [
      BmFact(
        _T({
          'uz':
              'Bo‘laklangan eritrotsitlar; o‘lchami normal yoki biroz kichik; '
              'turlari — dubulg‘asimon hujayra, keratotsit.',
          'ru':
              'Фрагментированные эритроциты нормального или чуть меньшего '
              'размера; варианты — шлемовидные клетки, кератоциты.',
          'en':
              'Fragmented red cells, normal size or slightly smaller; forms '
              'include helmet cells and keratocytes.',
        }),
        [_wP308, _aT1],
      ),
    ],
    pointsTo: BmFact(
      _T({
        'uz':
            'Trombotik mikroangiopatiya: DVS (tarqalgan tomir ichi qon '
            'ivishi), trombotik trombotsitopenik purpura, gemolitik-uremik '
            'sindrom; shuningdek yurak klapani gemolizi.',
        'ru':
            'Тромботическая микроангиопатия: ДВС-синдром, тромботическая '
            'тромбоцитопеническая пурпура, гемолитико-уремический синдром; '
            'также гемолиз на клапанах сердца.',
        'en':
            'Thrombotic microangiopathy: DIC, thrombotic thrombocytopenic '
            'purpura, haemolytic uraemic syndrome; also valvular haemolysis.',
      }),
      [_aT1, _mSmear],
    ),
    confuse: BmFact(
      _T({
        'uz':
            'Eritrotsit bo‘laklari analizatorda trombotsit deb sanalib, '
            'trombotsitlar sonini soxta oshirishi mumkin — surtmada tekshiring.',
        'ru':
            'Фрагменты эритроцитов анализатор может посчитать тромбоцитами и '
            'ложно завысить их число — проверьте в мазке.',
        'en':
            'Red cell fragments may be counted as platelets by the analyser, '
            'falsely raising the platelet count — check the film.',
      }),
      [_aPlt, _tT4],
    ),
    refer: BmFact(
      _T({
        'uz':
            'Shoshilinch: anemiya + trombotsitopeniya + gemoliz belgilari — '
            'TMA yoki DVS bo‘lishi mumkin; zudlik bilan shifokorga xabar '
            'bering (LDG, gaptoglobin, surtma, mutaxassis).',
        'ru':
            'Срочно: анемия + тромбоцитопения + признаки гемолиза — возможна '
            'ТМА или ДВС; немедленно сообщите врачу (ЛДГ, гаптоглобин, '
            'мазок, специалист).',
        'en':
            'Urgent: anaemia + thrombocytopenia + haemolysis may mean TMA or '
            'DIC — tell the doctor immediately (LDH, haptoglobin, film, '
            'specialist).',
      }),
      [_tT5],
    ),
  ),
  BmFinding(
    id: 'sickle-cells',
    group: BmGroup.shape,
    name: _T({
      'uz': 'O‘roqsimon hujayralar (drepanotsitlar)',
      'ru': 'Серповидные клетки (дрепаноциты)',
      'en': 'Sickle cells (drepanocytes)',
    }),
    image: _imgSickle,
    analytes: ['hemoglobin-electrophoresis', 'reticulocytes'],
    see: [
      BmFact(
        _T({
          'uz':
              'Cho‘ziq va ingichka, ko‘pincha bir yoki ikki uchi egilgan va '
              'o‘tkirlashgan hujayralar.',
          'ru':
              'Вытянутые узкие клетки, часто с одним или обоими изогнутыми '
              'заострёнными концами.',
          'en':
              'Elongated, narrow cells, often with one or both ends curved and '
              'pointed.',
        }),
        [_wP307],
      ),
    ],
    pointsTo: BmFact(
      _T({
        'uz':
            'O‘roqsimon hujayrali sindromlar (HbSS, HbSC, HbS-β-talassemiya); '
            'yonida yadroli eritrotsitlar, nishonsimon hujayralar va ko‘pincha '
            'makrotsitlar bo‘ladi.',
        'ru':
            'Серповидноклеточные синдромы (HbSS, HbSC, HbS-β-талассемия); '
            'рядом бывают ядросодержащие эритроциты, мишеневидные клетки и '
            'часто макроциты.',
        'en':
            'Sickle cell syndromes (HbSS, HbSC, HbS-β-thalassaemia); nucleated '
            'red cells, target cells and often macrocytes may be seen too.',
      }),
      [_aT1, _wP307],
    ),
    refer: BmFact(
      _T({
        'uz':
            'Tasdiq — gemoglobin elektroforezi (HbS); nam preparatdagi '
            'o‘roqlanish testi JSST qo‘llanmasida (9.11).',
        'ru':
            'Подтверждение — электрофорез гемоглобина (HbS); тест '
            'серповидности во влажном препарате описан в руководстве ВОЗ '
            '(9.11).',
        'en':
            'Confirmation is by haemoglobin electrophoresis (HbS); the '
            'wet-preparation sickling test is in the WHO manual (9.11).',
      }),
      [_mTable, CalcRef(BmSources.who2003, '9.11, p. 314–315')],
    ),
  ),
  BmFinding(
    id: 'teardrop-cells',
    group: BmGroup.shape,
    name: _T({
      'uz': 'Tomchisimon hujayralar (dakriotsitlar)',
      'ru': 'Каплевидные клетки (дакриоциты)',
      'en': 'Teardrop cells (dacrocytes)',
    }),
    image: _imgTear,
    analytes: ['platelets', 'wbc-count'],
    see: [
      BmFact(
        _T({
          'uz':
              'Ko‘z yoshi tomchisi (yoki nok) shaklidagi eritrotsitlar — '
              'poykilotsitlarning bir turi.',
          'ru':
              'Эритроциты в форме слезы (или груши) — одна из форм '
              'пойкилоцитов.',
          'en':
              'Red cells shaped like a teardrop (or a pear) — one kind of '
              'poikilocyte.',
        }),
        [_fTear, _aT1, _najRbc],
      ),
    ],
    pointsTo: BmFact(
      _T({
        'uz':
            'Miyelofibroz, ilikning infiltratsiyasi (miyeloftiz), suyak '
            'ko‘migidan tashqari qon yaratilishi; shuningdek talassemiyalar, '
            'megaloblast anemiya, og‘ir temir tanqisligi, miyelodisplaziya, '
            'irsiy elliptotsitoz.',
        'ru':
            'Миелофиброз, инфильтрация костного мозга (миелофтиз), '
            'экстрамедуллярное кроветворение; также талассемии, '
            'мегалобластная анемия, тяжёлый дефицит железа, миелодисплазия, '
            'наследственный эллиптоцитоз.',
        'en':
            'Myelofibrosis, marrow infiltration (myelophthisis), '
            'extramedullary haemopoiesis; also thalassaemias, '
            'megaloblastic anaemia, severe iron deficiency, myelodysplasia, '
            'hereditary elliptocytosis.',
      }),
      [_aT1, _mTable],
    ),
    refer: BmFact(
      _T({
        'uz':
            'Yadroli eritrotsitlar va yosh granulotsitlar bilan birga bo‘lsa '
            '(leykoeritroblastik surtma), ilik infiltratsiyasini istisno '
            'qilish uchun gematologga.',
        'ru':
            'Если вместе с ядросодержащими эритроцитами и молодыми '
            'гранулоцитами (лейкоэритробластическая картина) — к гематологу, '
            'чтобы исключить инфильтрацию костного мозга.',
        'en':
            'If seen with nucleated red cells and immature granulocytes (a '
            'leucoerythroblastic film) — refer to a haematologist to exclude '
            'marrow infiltration.',
      }),
      [_aRbc, _mTable],
    ),
  ),
  BmFinding(
    id: 'elliptocytes',
    group: BmGroup.shape,
    name: _T({
      'uz': 'Elliptotsitlar (ovalotsitlar)',
      'ru': 'Эллиптоциты (овалоциты)',
      'en': 'Elliptocytes (ovalocytes)',
    }),
    image: _imgEllipto,
    analytes: ['mcv', 'reticulocytes'],
    see: [
      BmFact(
        _T({
          'uz':
              'Oval hujayralar, o‘lchami normal (taxminan 8 µm); gardishi, '
              'ayniqsa qutblarida, to‘qroq bo‘yalgan.',
          'ru':
              'Овальные клетки нормального размера (около 8 мкм); периферия, '
              'особенно на полюсах, окрашена темнее.',
          'en':
              'Oval cells of normal size (about 8 µm); the rim, especially at '
              'the poles, stains darker.',
        }),
        [_wP308],
      ),
    ],
    pointsTo: BmFact(
      _T({
        'uz':
            'Irsiy elliptotsitoz (elliptotsitlar > 25 %); shuningdek temir '
            'tanqisligi, pernitsioz anemiya, o‘roqsimon hujayrali kasallik, '
            'talassemiyalar, miyelofibroz. Yengil irsiy elliptotsitozda '
            'gemoliz bo‘lmasligi mumkin.',
        'ru':
            'Наследственный эллиптоцитоз (эллиптоцитов > 25 %); также дефицит '
            'железа, пернициозная анемия, серповидноклеточная болезнь, '
            'талассемии, миелофиброз. При лёгком наследственном эллиптоцитозе '
            'гемолиза может не быть.',
        'en':
            'Hereditary elliptocytosis (> 25% elliptocytes); also iron '
            'deficiency, pernicious anaemia, sickle cell disease, '
            'thalassaemias, myelofibrosis. Mild hereditary elliptocytosis may '
            'have no haemolysis.',
      }),
      [_aT1, _wP309, _chSmear],
    ),
    confuse: BmFact(
      _T({
        'uz':
            'Oval makrotsitlar bilan adashtirmang: elliptotsit odatdagi '
            'o‘lchamda, oval makrotsit esa yirik (megaloblast anemiyada).',
        'ru':
            'Не путайте с овальными макроцитами: эллиптоцит нормального '
            'размера, овальный макроцит крупный (при мегалобластной анемии).',
        'en':
            'Do not confuse with oval macrocytes: an elliptocyte is of normal '
            'size, an oval macrocyte is large (megaloblastic anaemia).',
      }),
      [_wP308, _aRbc],
    ),
  ),
  BmFinding(
    id: 'stomatocytes',
    group: BmGroup.shape,
    name: _T({
      'uz': 'Stomatotsitlar',
      'ru': 'Стоматоциты',
      'en': 'Stomatocytes',
    }),
    image: _imgStomato,
    analytes: ['alt', 'mcv'],
    see: [
      BmFact(
        _T({
          'uz':
              'Markazdagi och joy yumaloq emas — og‘izga o‘xshash, cho‘ziq '
              '(tirqishsimon) dog‘.',
          'ru':
              'Центральное просветление не круглое — вытянутое, щелевидное, '
              'похожее на рот.',
          'en':
              'The central pallor is not round but an elongated, mouth-shaped '
              'slit.',
        }),
        [_zama, _fStomato],
      ),
    ],
    pointsTo: BmFact(
      _T({
        'uz':
            'Artefakt (nam havoda sekin qurish), jigar kasalligi, alkogolizm, '
            'Rh-null fenotipi, obstruktiv o‘pka kasalligi; irsiy '
            'stomatotsitoz (degidratatsiyalangan shaklida gemoliz bor, lekin '
            'surtmada stomatotsitlar kam bo‘lishi mumkin).',
        'ru':
            'Артефакт (медленное высыхание во влажном воздухе), болезни '
            'печени, алкоголизм, фенотип Rh-null, обструктивные болезни '
            'лёгких; наследственный стоматоцитоз (при дегидратированной форме '
            'гемолиз есть, но в мазке стоматоцитов может быть мало).',
        'en':
            'Artefact (slow drying in humid air), liver disease, alcoholism, '
            'Rh-null phenotype, obstructive lung disease; hereditary '
            'stomatocytosis (in the dehydrated form haemolysis is present, yet '
            'stomatocytes may be scarce on the film).',
      }),
      [_aT1, _zama],
    ),
    confuse: BmFact(
      _T({
        'uz':
            'Avval artefaktni istisno qiling: yangi, tez quritilgan surtmada '
            'qayta ko‘ring.',
        'ru':
            'Сначала исключите артефакт: посмотрите свежий, быстро высушенный '
            'мазок.',
        'en':
            'Rule out artefact first: look again at a fresh, quickly dried '
            'film.',
      }),
      [_aT1, _aPrep],
    ),
  ),
  BmFinding(
    id: 'acanthocytes',
    group: BmGroup.shape,
    name: _T({'uz': 'Akantotsitlar', 'ru': 'Акантоциты', 'en': 'Acanthocytes'}),
    aka: _T({
      'uz': 'tikanli (“spur”) hujayralar',
      'ru': 'шпоровидные клетки (spur cells)',
      'en': 'spur cells',
    }),
    image: _imgAcantho,
    analytes: ['alt', 'creatinine'],
    see: [
      BmFact(
        _T({
          'uz': 'Tikansimon o‘simtalari bor, shakli buzilgan eritrotsitlar.',
          'ru': 'Деформированные эритроциты с шиповидными выростами.',
          'en': 'Deformed red cells with spike-like protrusions.',
        }),
        [_jung],
      ),
    ],
    pointsTo: BmFact(
      _T({
        'uz':
            'Jigar kasalligi, buyrak yetishmovchiligi, abetalipoproteinemiya '
            '(va boshqa lipoprotein buzilishlari), “spur cell” anemiya, '
            'piruvatkinaza tanqisligi; kam uchraydigan neyroakantotsitoz '
            'sindromlari.',
        'ru':
            'Болезни печени, почечная недостаточность, абеталипопротеинемия '
            '(и другие нарушения липопротеинов), анемия со шпоровидными '
            'клетками, дефицит пируваткиназы; редкие синдромы '
            'нейроакантоцитоза.',
        'en':
            'Liver disease, renal failure, abetalipoproteinaemia (and other '
            'lipoprotein disorders), spur cell anaemia, pyruvate kinase '
            'deficiency; rare neuroacanthocytosis syndromes.',
      }),
      [_aT1, _jung],
    ),
    confuse: BmFact(
      _T({
        'uz':
            'Exinotsitlar (krenatsiyali hujayralar) bilan adashtirmang — '
            'ular ko‘pincha saqlash yoki quritish artefakti; ikkalasi ham '
            'alohida kartada.',
        'ru':
            'Не путайте с эхиноцитами (кренированными клетками) — они часто '
            'артефакт хранения или высушивания; обе формы — в отдельных '
            'карточках.',
        'en':
            'Do not confuse with echinocytes (crenated cells) — these are '
            'often a storage or drying artefact; both have their own cards.',
      }),
      [_aT1],
    ),
  ),
  BmFinding(
    id: 'echinocytes',
    group: BmGroup.shape,
    name: _T({
      'uz': 'Exinotsitlar (krenatsiyali hujayralar)',
      'ru': 'Эхиноциты (кренированные клетки)',
      'en': 'Echinocytes (crenated cells)',
    }),
    aka: _T({
      'uz': '“burr” hujayralar',
      'ru': 'клетки-«репейники» (burr cells)',
      'en': 'burr cells',
    }),
    image: _imgEchino,
    analytes: ['creatinine'],
    see: [
      BmFact(
        _T({
          'uz':
              'Gardishi tishli-burishgan (krenatsiyali), chegarasi yaltiroq '
              'eritrotsitlar.',
          'ru':
              'Эритроциты с зубчатым (кренированным) краем и блестящей '
              'границей.',
          'en': 'Crenated red cells with refractile borders.',
        }),
        [_aPrep, _aT1],
      ),
    ],
    pointsTo: BmFact(
      _T({
        'uz':
            'Ko‘pincha in vitro artefakt: qon uzoq saqlangan, surtma nam '
            'havoda sekin qurigan yoki noto‘g‘ri fiksatsiya qilingan. '
            'Haqiqiy sabablar — uremiya, ovqatlanish yetishmovchiligi.',
        'ru':
            'Чаще артефакт in vitro: длительное хранение крови, медленное '
            'высыхание мазка во влажном воздухе или неправильная фиксация. '
            'Истинные причины — уремия, недостаточное питание.',
        'en':
            'Most often an in-vitro artefact: prolonged storage, slow drying '
            'in humid air or improper fixation. True causes include uraemia '
            'and malnutrition.',
      }),
      [_aT1, _aPrep, _aRbc],
    ),
    confuse: BmFact(
      _T({
        'uz':
            'Akantotsitlar bilan adashtirmang; xulosa yozishdan oldin yangi '
            'olingan qondan tayyorlangan surtmada tekshiring.',
        'ru':
            'Не путайте с акантоцитами; прежде чем включать в заключение, '
            'проверьте мазок из свежевзятой крови.',
        'en':
            'Do not confuse with acanthocytes; before reporting, check a film '
            'made from freshly drawn blood.',
      }),
      [_aT1, _aPrep],
    ),
  ),
  // ── Kiritmalar ──
  BmFinding(
    id: 'basophilic-stippling',
    group: BmGroup.inclusion,
    name: _T({
      'uz': 'Bazofil punktatsiya',
      'ru': 'Базофильная пунктация',
      'en': 'Basophilic stippling',
    }),
    image: _imgStipple,
    analytes: ['hemoglobin-electrophoresis', 'mcv'],
    see: [
      BmFact(
        _T({
          'uz':
              'Eritrotsit sitoplazmasida ko‘p mayda ko‘k-qora nuqtalar '
              '(denaturatsiyalangan RNK bo‘lakchalari).',
          'ru':
              'Множество мелких сине-чёрных точек в цитоплазме эритроцита '
              '(фрагменты денатурированной РНК).',
          'en':
              'Many fine blue-black dots in the red cell cytoplasm (denatured '
              'RNA fragments).',
        }),
        [_wP309, _aRbc],
      ),
    ],
    pointsTo: BmFact(
      _T({
        'uz':
            'Talassemiyalar, qo‘rg‘oshin yoki mishyak bilan zaharlanish, '
            'beqaror gemoglobinlar, og‘ir infeksiyalar, sideroblast va '
            'megaloblast anemiya, pirimidin-5′-nukleotidaza tanqisligi.',
        'ru':
            'Талассемии, отравление свинцом или мышьяком, нестабильные '
            'гемоглобины, тяжёлые инфекции, сидеробластная и мегалобластная '
            'анемия, дефицит пиримидин-5′-нуклеотидазы.',
        'en':
            'Thalassaemias, lead or arsenic poisoning, unstable haemoglobins, '
            'severe infections, sideroblastic and megaloblastic anaemia, '
            'pyrimidine 5′-nucleotidase deficiency.',
      }),
      [_aRbc, _wP309, _mTable],
    ),
    confuse: BmFact(
      _T({
        'uz': 'Bo‘yoq cho‘kmasi (zarrachalari) bilan adashtirmang.',
        'ru': 'Не путайте с осадком (частицами) красителя.',
        'en': 'Do not confuse with stain deposit.',
      }),
      [_wP309],
    ),
  ),
  BmFinding(
    id: 'howell-jolly',
    group: BmGroup.inclusion,
    name: _T({
      'uz': 'Xauell–Jolli tanachalari',
      'ru': 'Тельца Хауэлла–Жолли',
      'en': 'Howell–Jolly bodies',
    }),
    image: _imgHowell,
    analytes: ['blood-smear'],
    see: [
      BmFact(
        _T({
          'uz':
              'Eritrotsit ichida bitta yoki bir nechta yirik binafsha '
              'donacha — yadro (DNK) qoldig‘i.',
          'ru':
              'Одна или несколько крупных пурпурных гранул в эритроците — '
              'остатки ядра (ДНК).',
          'en':
              'One or more large purple granules in a red cell — nuclear (DNA) '
              'remnants.',
        }),
        [_wP309, _aRbc],
      ),
    ],
    pointsTo: BmFact(
      _T({
        'uz':
            'Splenektomiyadan keyin, anatomik yoki funksional aspleniya '
            '(taloq ularni “tozalamaydi”); shuningdek gemolitik va megaloblast '
            'anemiyalar.',
        'ru':
            'После спленэктомии, при анатомической или функциональной '
            'асплении (селезёнка их не удаляет); также гемолитические и '
            'мегалобластные анемии.',
        'en':
            'After splenectomy, anatomical or functional asplenia (the spleen '
            'no longer removes them); also haemolytic and megaloblastic '
            'anaemias.',
      }),
      [_aRbc, _wP309],
    ),
    confuse: BmFact(
      _T({
        'uz': 'Eritrotsit ustida yotgan trombotsit bilan adashtirmang.',
        'ru': 'Не путайте с тромбоцитом, лежащим на эритроците.',
        'en': 'Do not confuse with a platelet lying on top of a red cell.',
      }),
      [_wP309],
    ),
  ),
  // ── Joylashuv ──
  BmFinding(
    id: 'rouleaux',
    group: BmGroup.arrangement,
    name: _T({
      'uz': '“Tanga ustunchalari” (rouleaux)',
      'ru': 'Монетные столбики (rouleaux)',
      'en': 'Rouleaux',
    }),
    image: _imgRouleaux,
    analytes: ['esr', 'total-protein'],
    see: [
      BmFact(
        _T({
          'uz':
              'Eritrotsitlar tangalar kabi ustma-ust terilgan; fon ko‘kish '
              'bo‘lishi mumkin.',
          'ru':
              'Эритроциты сложены стопкой, как монеты; фон может быть '
              'голубоватым.',
          'en': 'Red cells stacked like coins; the background may be bluish.',
        }),
        [_aRbc],
      ),
    ],
    pointsTo: BmFact(
      _T({
        'uz':
            'Ko‘kish fon bilan — paraproteinemiya / plazmatik hujayrali '
            'diskraziya (masalan, miyeloma); makroglobulinemiyalarda ham.',
        'ru':
            'С голубоватым фоном — парапротеинемия / плазмоклеточная '
            'дискразия (например, миелома); также при макроглобулинемиях.',
        'en':
            'With a bluish background — paraproteinaemia / plasma cell '
            'dyscrasia (for example myeloma); also in macroglobulinaemias.',
      }),
      [_aRbc],
    ),
    confuse: BmFact(
      _T({
        'uz':
            'Agglyutinatsiya bilan adashtirmang: ustunchalar — tanga kabi '
            'terilgan qatorlar, agglyutinatsiya — to‘dalar (alohida kartada).',
        'ru':
            'Не путайте с агглютинацией: столбики — стопки, как монеты, '
            'агглютинация — скопления (отдельная карточка).',
        'en':
            'Do not confuse with agglutination: rouleaux are coin-like stacks, '
            'agglutination is clumps (separate card).',
      }),
      [_aRbc, _fAgglut],
    ),
  ),
  BmFinding(
    id: 'agglutination',
    group: BmGroup.arrangement,
    name: _T({
      'uz': 'Eritrotsitlar agglyutinatsiyasi',
      'ru': 'Агглютинация эритроцитов',
      'en': 'Red cell agglutination',
    }),
    image: _imgAgglut,
    analytes: ['rbc-count', 'mcv', 'mchc'],
    see: [
      BmFact(
        _T({
          'uz':
              'Eritrotsitlar bir-biriga yopishib, to‘dalar (agglyutinatlar) '
              'hosil qilgan.',
          'ru': 'Эритроциты слипаются в скопления (агглютинаты).',
          'en': 'Red cells stuck together in clumps (agglutinates).',
        }),
        [_mTable, _fAgglut],
      ),
    ],
    pointsTo: BmFact(
      _T({
        'uz':
            'Sovuq agglyutininlar kasalligi, Valdenström makroglobulinemiyasi.',
        'ru':
            'Болезнь холодовых агглютининов, макроглобулинемия '
            'Вальденстрема.',
        'en': 'Cold agglutinin disease, Waldenström macroglobulinaemia.',
      }),
      [_aRbc, _mTable],
    ),
    confuse: BmFact(
      _T({
        'uz':
            'Analizatorga ham ta’sir qiladi: sovuq agglyutininlar RBC ni '
            'soxta pasaytiradi, MCV va MCHC ni soxta oshiradi (soxta '
            'makrotsitoz).',
        'ru':
            'Влияет и на анализатор: холодовые агглютинины ложно снижают RBC '
            'и ложно повышают MCV и MCHC (ложный макроцитоз).',
        'en':
            'It affects the analyser too: cold agglutinins falsely lower the '
            'RBC and falsely raise the MCV and MCHC (spurious macrocytosis).',
      }),
      [_tT4, _mTable],
    ),
  ),
];

/// Eritrotsit yoki trombotsit topilmasi (id bo'yicha).
BmFinding? bmFinding(String id) {
  for (final f in [...bmFindings, ...bmPlatelets]) {
    if (f.id == id) return f;
  }
  return null;
}

// ───────────────────────── Trombotsitlar ─────────────────────────

const bmPlateletIntro = <BmFact>[
  BmFact(
    _T({
      'uz':
          'Trombotsitlar — ilikdagi megakariotsit sitoplazmasidan ajralgan '
          'bo‘lakchalar; taxminan eritrotsitning uchdan biri kattaligida, '
          'dag‘al donador; Leyshman bo‘yog‘ida binafsha-pushti.',
      'ru':
          'Тромбоциты — фрагменты цитоплазмы мегакариоцитов костного мозга; '
          'размером примерно с треть эритроцита, с грубой зернистостью; при '
          'окраске по Лейшману сиренево-розовые.',
      'en':
          'Platelets are fragments budded off marrow megakaryocytes; about a '
          'third of a red cell in size, coarsely granular; mauve-pink with '
          'Leishman stain.',
    }),
    [_aPlt, _wTable],
  ),
  BmFact(
    _T({
      'uz':
          'Taxminiy baholash (JSST): ×100 obyektivda 20 ta maydonda '
          'trombotsitlar sanaladi va maydondagi eritrotsitlar taxmin '
          'qilinadi; trombotsit/eritrotsit nisbati eritrotsitlar soniga '
          'ko‘paytirilib, trombotsitlar soni taxmin qilinadi. Adewoyin: '
          'normada ×100 maydonda taxminan 7–15 trombotsit; maydondagi bitta '
          'trombotsit qonda taxminan 15–20 ×10⁹/L ga to‘g‘ri keladi.',
      'ru':
          'Ориентировочная оценка (ВОЗ): под объективом ×100 считают '
          'тромбоциты в 20 полях и прикидывают число эритроцитов в поле; '
          'отношение тромбоциты/эритроциты умножают на число эритроцитов. '
          'Adewoyin: в норме около 7–15 тромбоцитов в поле ×100; один '
          'тромбоцит в поле соответствует примерно 15–20 ×10⁹/л в крови.',
      'en':
          'Rough estimate (WHO): with the ×100 objective count platelets in '
          '20 fields and estimate red cells per field; multiply the '
          'platelet/red cell ratio by the red cell count. Adewoyin: normally '
          'about 7–15 platelets per ×100 field; one platelet per field '
          'corresponds to roughly 15–20 ×10⁹/L in the blood.',
    }),
    [_wPlt, _aPlt],
  ),
  BmFact(
    _T({
      'uz':
          'Kutilmaganda past trombotsit soni har doim surtmada tekshiriladi: '
          'to‘plamlar, gigant trombotsitlar yoki fibrin iplari bormi.',
      'ru':
          'Неожиданно низкий счёт тромбоцитов всегда проверяют в мазке: нет '
          'ли агрегатов, гигантских тромбоцитов или нитей фибрина.',
      'en':
          'An unexpectedly low platelet count is always checked on the film: '
          'look for clumps, giant platelets or fibrin strands.',
    }),
    [_tStep5, _cDx, _cAbs],
  ),
];

const bmPlatelets = <BmFinding>[
  BmFinding(
    id: 'giant-platelets',
    group: BmGroup.platelet,
    name: _T({
      'uz': 'Yirik va gigant trombotsitlar',
      'ru': 'Крупные и гигантские тромбоциты',
      'en': 'Large and giant platelets',
    }),
    image: _imgGiantPlt,
    analytes: ['platelets', 'mpv'],
    see: [
      BmFact(
        _T({
          'uz':
              'Gigant trombotsit — taxminan normal eritrotsit kattaligida yoki '
              'undan katta.',
          'ru':
              'Гигантский тромбоцит — примерно с нормальный эритроцит или '
              'крупнее.',
          'en':
              'A giant platelet is about the size of a normal red cell or '
              'larger.',
        }),
        [_aPlt],
      ),
    ],
    pointsTo: BmFact(
      _T({
        'uz':
            'Ko‘pincha tug‘ma yoki orttirilgan trombotsitopeniyada uchraydi; '
            'trombotsitopeniya bilan yuqori yetilmagan trombotsit fraksiyasi '
            '(IPF) — irsiy makrotrombotsitopeniya (masalan, MYH9) ehtimoli.',
        'ru':
            'Чаще при врождённой или приобретённой тромбоцитопении; '
            'тромбоцитопения с высокой фракцией незрелых тромбоцитов (IPF) — '
            'возможна наследственная макротромбоцитопения (например, MYH9).',
        'en':
            'Mostly in congenital or acquired thrombocytopenia; '
            'thrombocytopenia with a high immature platelet fraction (IPF) '
            'raises the possibility of inherited macrothrombocytopenia (e.g. '
            'MYH9).',
      }),
      [_cAbs, _tT5],
    ),
    confuse: BmFact(
      _T({
        'uz':
            'Analizator trombotsitlarni o‘lchami (1,5–3 µm) bo‘yicha ajratadi: '
            'gigant trombotsitlar sanalmay, soni soxta past (va WBC soxta '
            'yuqori) chiqishi mumkin; bunday bemorlarda mikroskopda qo‘lda '
            'sanash tavsiya etiladi.',
        'ru':
            'Анализатор отличает тромбоциты по размеру (1,5–3 мкм): '
            'гигантские тромбоциты не учитываются, и счёт может быть ложно '
            'низким (а WBC ложно высоким); у таких пациентов рекомендуют '
            'ручной подсчёт под микроскопом.',
        'en':
            'Analysers recognise platelets by size (1.5–3 µm): giant platelets '
            'are missed, so the count may be falsely low (and the WBC falsely '
            'high); manual counting by microscopy is recommended in these '
            'patients.',
      }),
      [_cGiant, _tT4],
    ),
  ),
  BmFinding(
    id: 'platelet-clumps',
    group: BmGroup.platelet,
    name: _T({
      'uz': 'Trombotsit to‘plamlari (psevdotrombotsitopeniya)',
      'ru': 'Агрегаты тромбоцитов (псевдотромбоцитопения)',
      'en': 'Platelet clumps (pseudothrombocytopenia)',
    }),
    image: _imgClump,
    analytes: ['platelets'],
    see: [
      BmFact(
        _T({
          'uz':
              'Kamida beshta bir-biriga yopishgan trombotsit — to‘plam; ular '
              'odatda surtma chetlari va dumida (patli uchida) topiladi.',
          'ru':
              'Агрегат — не менее пяти слипшихся тромбоцитов; обычно их '
              'находят по краям и в хвосте (пёрышке) мазка.',
          'en':
              'A clump is at least five attached platelets; clumps are usually '
              'found at the margins and the tail (feathered end) of the film.',
        }),
        [_cDx, _aInterp],
      ),
    ],
    pointsTo: BmFact(
      _T({
        'uz':
            'EDTA ga bog‘liq, harorat va vaqtga bog‘liq, antitana vositasidagi '
            'in vitro agglyutinatsiya — psevdotrombotsitopeniya: zararsiz '
            'artefakt, davolash talab qilmaydi (barcha qon tahlillarining '
            'taxminan 0,1 %). Antitanalar asosan 4–20 °C da faol, 37 °C da '
            'deyarli nofaol.',
        'ru':
            'ЭДТА-зависимая, зависящая от температуры и времени, '
            'опосредованная антителами агглютинация in vitro — '
            'псевдотромбоцитопения: доброкачественный артефакт, лечения не '
            'требует (около 0,1 % всех анализов крови). Антитела активны в '
            'основном при 4–20 °C и практически неактивны при 37 °C.',
        'en':
            'EDTA-dependent, temperature- and time-dependent, antibody-mediated '
            'agglutination in vitro — pseudothrombocytopenia: a benign '
            'artefact needing no treatment (about 0.1% of all blood counts). '
            'The antibodies work mainly at 4–20 °C and are practically '
            'inactive at 37 °C.',
      }),
      [_cAbs, _cEpi, _cMech],
    ),
    confuse: BmFact(
      _T({
        'uz':
            'Kichik to‘plamlarni analizator leykotsit deb sanashi mumkin — '
            'soxta leykotsitoz; ogohlantiruvchi belgilar (flag) bo‘lmasa ham, '
            'to‘plam istisno qilinmaydi — tashxis faqat surtmada qo‘yiladi.',
        'ru':
            'Мелкие агрегаты анализатор может принять за лейкоциты — ложный '
            'лейкоцитоз; отсутствие флагов не исключает агрегаты — диагноз '
            'ставят только по мазку.',
        'en':
            'Small clumps may be counted as leukocytes — spurious '
            'leukocytosis; the absence of flags does not exclude clumps — the '
            'diagnosis rests on the film.',
      }),
      [_cDx],
    ),
    refer: BmFact(
      _T({
        'uz':
            'Natijani “trombotsitopeniya” deb chiqarmang: surtmani ko‘ring, '
            'EDTA namunasini olingandan keyin darhol sanang; muqobil '
            'antikoagulant (sitrat, geparin) har doim ham yordam bermaydi.',
        'ru':
            'Не выдавайте результат как «тромбоцитопения»: посмотрите мазок, '
            'посчитайте пробу с ЭДТА сразу после взятия; альтернативный '
            'антикоагулянт (цитрат, гепарин) помогает не всегда.',
        'en':
            'Do not report it as “thrombocytopenia”: look at the film and '
            'count the EDTA sample immediately after collection; an '
            'alternative anticoagulant (citrate, heparin) does not always '
            'help.',
      }),
      [_cDx, _cAbs, _tStep5],
    ),
  ),
  BmFinding(
    id: 'platelet-satellitism',
    group: BmGroup.platelet,
    name: _T({
      'uz': 'Trombotsit satellitizmi',
      'ru': 'Сателлитизм тромбоцитов',
      'en': 'Platelet satellitism',
    }),
    image: _imgSatellite,
    analytes: ['platelets'],
    see: [
      BmFact(
        _T({
          'uz':
              'Trombotsitlar neytrofil atrofiga yopishib, “halqa” hosil '
              'qilgan; ba’zan leykotsit trombotsitni yutgan yoki '
              'trombotsit-leykotsit to‘plami bo‘ladi.',
          'ru':
              'Тромбоциты прилипли вокруг нейтрофила «венчиком»; иногда '
              'лейкоцит фагоцитирует тромбоциты или образуются '
              'тромбоцитарно-лейкоцитарные агрегаты.',
          'en':
              'Platelets stick around a neutrophil like a rosette; sometimes '
              'the leukocyte phagocytoses platelets or platelet–leukocyte '
              'clumps form.',
        }),
        [_cSat, _cAbs],
      ),
    ],
    pointsTo: BmFact(
      _T({
        'uz':
            'EDTA li qonda in vitro hodisa: IgG antitanalar trombotsit '
            'GPIIb-IIIa si va neytrofil Fc-retseptori III orasida “ko‘prik” '
            'hosil qiladi; boshqa antikoagulantlarda kuzatilmaydi. Natijada '
            'trombotsit soni soxta pasayadi.',
        'ru':
            'Явление in vitro в крови с ЭДТА: антитела IgG образуют «мостик» '
            'между GPIIb-IIIa тромбоцита и Fc-рецептором III нейтрофила; в '
            'других антикоагулянтах не наблюдается. В итоге счёт тромбоцитов '
            'ложно снижается.',
        'en':
            'An in-vitro phenomenon in EDTA blood: IgG antibodies bridge '
            'platelet GPIIb-IIIa and the neutrophil Fc receptor III; it is not '
            'seen with other anticoagulants. The platelet count is falsely '
            'lowered.',
      }),
      [_cAbs, _cSat],
    ),
  ),
];

// ───────────────────────── Surtma sifati va artefaktlar ─────────────────────

const bmQualitySections = <BmSection>[
  BmSection(
    id: 'sample',
    title: _T({'uz': 'Namuna', 'ru': 'Проба', 'en': 'The sample'}),
    facts: [
      BmFact(
        _T({
          'uz':
              'Antikoagulant — EDTA. Surtmani olingandan keyin 1–2 soat ichida '
              'tayyorlab bo‘lmasa, qonga EDTA qo‘shiladi; geparin '
              'leykotsit va trombotsitlar ko‘rinishini o‘zgartiradi — '
              'ishlatilmaydi.',
          'ru':
              'Антикоагулянт — ЭДТА. Если мазок нельзя приготовить в течение '
              '1–2 часов после взятия, кровь стабилизируют ЭДТА; гепарин '
              'изменяет вид лейкоцитов и тромбоцитов — его не используют.',
          'en':
              'The anticoagulant is EDTA. If the film cannot be made within '
              '1–2 hours of collection, EDTA is added; heparin alters the '
              'appearance of leukocytes and platelets and is not used.',
        }),
        [_wPrep],
      ),
      BmFact(
        _T({
          'uz':
              'Namuna 2 soat ichida tekshirilgani yaxshi; kechikish '
              'hujayralarni buzadi va trombotsit to‘plamlari tufayli '
              'psevdotrombotsitopeniyaga olib kelishi mumkin. Tomizishdan '
              'oldin qon yaxshi aralashtiriladi (kamida 10 marta sekin '
              'ag‘darish).',
          'ru':
              'Пробу лучше исследовать в течение 2 часов; задержка разрушает '
              'клетки и может привести к псевдотромбоцитопении из-за '
              'агрегатов. Перед нанесением кровь тщательно перемешивают (не '
              'менее 10 мягких переворачиваний).',
          'en':
              'Samples are best examined within 2 hours; delay degrades the '
              'cells and can cause pseudothrombocytopenia from platelet '
              'aggregates. Mix the blood well before use (at least 10 gentle '
              'inversions).',
        }),
        [_aPrep],
      ),
    ],
  ),
  BmSection(
    id: 'spread',
    title: _T({
      'uz': 'Surtish: qalin va yupqa',
      'ru': 'Нанесение: толстый и тонкий мазок',
      'en': 'Spreading: thick and thin',
    }),
    facts: [
      BmFact(
        _T({
          'uz':
              'Shpatel 30–45° burchakda tutiladi; qanchalik tez va tik '
              'surtilsa, surtma shunchalik qalin. Anemiyali bemor qoni tezroq '
              'surtiladi.',
          'ru':
              'Шпатель держат под углом 30–45°; чем быстрее и круче движение, '
              'тем толще мазок. Кровь больных анемией размазывают быстрее.',
          'en':
              'Hold the spreader at about 30–45°; the faster and steeper the '
              'stroke, the thicker the film. Blood from anaemic patients is '
              'spread more rapidly.',
        }),
        [_aPrep, _wPrep],
      ),
      BmFact(
        _T({
          'uz':
              'Yaxshi surtma oynaning taxminan uchdan ikki qismini egallaydi '
              'va oval, patsimon uch bilan tugaydi.',
          'ru':
              'Хороший мазок занимает около двух третей стекла и заканчивается '
              'овальным «пёрышком».',
          'en':
              'A good film covers about two-thirds of the slide and ends in an '
              'oval feathered edge.',
        }),
        [_aPrep],
      ),
      BmFact(
        _T({
          'uz':
              'Tekshiring: ko‘ndalang yoki bo‘ylama chiziqlar yo‘q; uchi silliq, '
              'yirtiq emas; juda uzun ham, juda qalin ham emas; yog‘li oyna '
              'qoldirgan teshiklar yo‘q. Yomon surtmada leykoformula '
              'noto‘g‘ri chiqadi va eritrotsit morfologiyasini baholab '
              'bo‘lmaydi.',
          'ru':
              'Проверьте: нет поперечных и продольных полос; край ровный, не '
              'рваный; мазок не слишком длинный и не слишком толстый; нет '
              '«дыр» от жирного стекла. В плохом мазке лейкоформула будет '
              'неверной, а морфологию эритроцитов оценить невозможно.',
          'en':
              'Check: no lines across or along the film; a smooth, not ragged, '
              'end; not too long and not too thick; no holes from a greasy '
              'slide. A badly spread film gives a wrong differential and makes '
              'red cell morphology impossible to report.',
        }),
        [_wPrep],
      ),
      BmFact(
        _T({
          'uz':
              'Har namunadan kamida ikkita surtma tayyorlab, sifati darhol '
              'baholanadi; yomon surtma tashlanib, yangisi tayyorlanadi.',
          'ru':
              'Из каждой пробы готовят не менее двух мазков и сразу оценивают '
              'качество; плохой мазок выбрасывают и делают новый.',
          'en':
              'Make two or more films per sample and assess quality at once; '
              'discard poor films and make new ones.',
        }),
        [_aPrep],
      ),
    ],
  ),
  BmSection(
    id: 'dry-fix',
    title: _T({
      'uz': 'Quritish va fiksatsiya',
      'ru': 'Высушивание и фиксация',
      'en': 'Drying and fixation',
    }),
    facts: [
      BmFact(
        _T({
          'uz':
              'Yaxshi quritish sifatni saqlaydi, ayniqsa nam iqlimda. Nam '
              'havoda sekin qurish — gipoxromiyani baholashni qiyinlashtiradigan '
              'yaltiroq chegara, stomatotsit va exinotsitga o‘xshash '
              'artefaktlar beradi.',
          'ru':
              'Хорошее высушивание сохраняет качество, особенно во влажном '
              'климате. Медленное высыхание во влажном воздухе даёт блестящую '
              'границу (мешает оценить гипохромию) и артефакты, похожие на '
              'стоматоциты и эхиноциты.',
          'en':
              'Proper drying preserves quality, especially in humid climates. '
              'Slow drying in humid air gives a refractile border (hinders '
              'judging hypochromia) and stomatocyte- and echinocyte-like '
              'artefacts.',
        }),
        [_wStain, _aPrep, _aT1],
      ),
      BmFact(
        _T({
          'uz':
              'Quruq surtma metanol bilan fiksatsiya qilinadi (JSST usulida '
              '2–3 daqiqa); 4 soat ichida, yaxshisi 1 soat ichida. Noto‘g‘ri '
              'fiksatsiya artefakt “burr” hujayralar beradi.',
          'ru':
              'Сухой мазок фиксируют метанолом (по методике ВОЗ 2–3 минуты) в '
              'течение 4 часов, лучше в течение часа. Неправильная фиксация '
              'даёт артефактные «репейники» (burr cells).',
          'en':
              'Fix the dry film with methanol (2–3 minutes in the WHO method) '
              'within 4 hours, preferably within 1 hour. Improper fixation '
              'produces artefactual burr cells.',
        }),
        [_wStain, _aPrep],
      ),
    ],
  ),
  BmSection(
    id: 'stain',
    title: _T({
      'uz': 'Bo‘yash muammolari',
      'ru': 'Проблемы окраски',
      'en': 'Staining problems',
    }),
    facts: [
      BmFact(
        _T({
          'uz':
              'Suv pH i: kislotali suv surtmani juda qizil, ishqoriy suv — '
              'juda ko‘k qiladi. Leyshman uchun pH 6,8–7,2 (yaxshisi 7,0–7,2), '
              'May–Grünvald–Gimza uchun 6,8–7,0.',
          'ru':
              'pH воды: кислая вода делает мазок слишком красным, щелочная — '
              'слишком синим. Для Лейшмана pH 6,8–7,2 (лучше 7,0–7,2), для '
              'Май-Грюнвальда–Гимзы 6,8–7,0.',
          'en':
              'Water pH: acid water makes the film too red, alkaline water too '
              'blue. For Leishman pH 6.8–7.2 (preferably 7.0–7.2), for '
              'May–Grünwald–Giemsa 6.8–7.0.',
        }),
        [_wStain],
      ),
      BmFact(
        _T({
          'uz':
              'Bo‘yoq cho‘kmasi surtmada mayda qora nuqtalar bo‘lib ko‘rinadi '
              '(bazofil punktatsiyaga o‘xshatib yuborish mumkin): idish toza '
              'bo‘lsin, bo‘yoqni to‘kmang — buferli suv oqimida yuving.',
          'ru':
              'Осадок красителя выглядит как мелкие чёрные точки (можно принять '
              'за базофильную пунктацию): посуда должна быть чистой, краситель '
              'не сливают, а смывают струёй буферной воды.',
          'en':
              'Stain deposit appears as small black spots (it can mimic '
              'basophilic stippling): keep glassware clean, do not tip the '
              'stain off — wash it off in a stream of buffered water.',
        }),
        [_wStain, _wP309, _aPrep],
      ),
      BmFact(
        _T({
          'uz':
              'Bo‘yash vaqti yangi bo‘yoq partiyasi kelganda yoki bo‘yoq uzoq '
              'saqlanganda qayta moslanadi; ortiqcha bo‘yash va yomon yuvish '
              'cho‘kma beradi. Bo‘yoq sifati har kuni yaxshi tayyorlangan '
              'normal surtma bilan solishtiriladi.',
          'ru':
              'Время окраски заново подбирают для новой партии или долго '
              'хранившегося красителя; перекрашивание и плохая промывка дают '
              'осадок. Качество окраски ежедневно сравнивают с хорошим '
              'нормальным мазком.',
          'en':
              'Re-adjust staining time for a new batch or long-stored stain; '
              'over-staining and poor washing leave deposits. Compare stain '
              'quality daily with a good normal film.',
        }),
        [_wStain, _aPrep],
      ),
    ],
  ),
  BmSection(
    id: 'edta-storage',
    title: _T({
      'uz': 'EDTA da saqlash artefaktlari',
      'ru': 'Артефакты хранения в ЭДТА',
      'en': 'EDTA storage artefacts',
    }),
    facts: [
      BmFact(
        _T({
          'uz':
              'Tahlil kechiksa, saqlangan qonda eritrotsitlar krenatsiyaga '
              'uchraydi (exinotsitlar) — bu artefakt.',
          'ru':
              'При задержке анализа эритроциты в хранившейся крови '
              'кренируются (эхиноциты) — это артефакт.',
          'en':
              'With delayed analysis, red cells in stored blood become crenated '
              '(echinocytes) — an artefact.',
        }),
        [_aRbc, _aT1],
      ),
      BmFact(
        _T({
          'uz':
              'Uzoq saqlash analizatorda MCV ni soxta oshiradi va MCHC ni soxta '
              'pasaytiradi.',
          'ru':
              'Длительное хранение ложно повышает MCV и ложно снижает MCHC на '
              'анализаторе.',
          'en':
              'Prolonged storage falsely raises the MCV and falsely lowers the '
              'MCHC on the analyser.',
        }),
        [_tT4],
      ),
      BmFact(
        _T({
          'uz':
              'EDTA ga bog‘liq trombotsit to‘planishi vaqt o‘tishi bilan '
              'kuchayadi (psevdotrombotsitopeniya) — “Trombotsitlar” '
              'bo‘limiga qarang.',
          'ru':
              'ЭДТА-зависимая агрегация тромбоцитов нарастает со временем '
              '(псевдотромбоцитопения) — см. раздел «Тромбоциты».',
          'en':
              'EDTA-dependent platelet clumping increases with time '
              '(pseudothrombocytopenia) — see “Platelets”.',
        }),
        [_cAbs],
      ),
      BmFact(
        _T({
          'uz':
              'Yirik hujayralar (masalan, monotsitlar) surtma chetiga va patli '
              'uchiga surilib qolishi mumkin; yorilgan (“smudge”) hujayralar '
              'ham artefakt bo‘lishi mumkin — talqinda hisobga oling.',
          'ru':
              'Крупные клетки (например, моноциты) могут смещаться к краям и '
              'в пёрышко мазка; разрушенные («теневые», smudge) клетки тоже '
              'могут быть артефактом — учитывайте это при оценке.',
          'en':
              'Large cells (such as monocytes) may be pushed to the edges and '
              'the feathered end; broken (smudge) cells may also be artefacts '
              '— take this into account.',
        }),
        [_aPrep, _aInterp],
      ),
    ],
  ),
];

// ───────────────────────── Retikulotsitlar ─────────────────────────

const bmReticSections = <BmSection>[
  BmSection(
    id: 'principle',
    title: _T({
      'uz': 'Usul tamoyili',
      'ru': 'Принцип метода',
      'en': 'Principle',
    }),
    image: _imgRetic,
    facts: [
      BmFact(
        _T({
          'uz':
              'Retikulotsitlar — ilikdan qonga chiqqan yosh, yadrosiz '
              'eritrotsitlar; ularning soni ilikning eritrotsit ishlab chiqarish '
              'faolligini ko‘rsatadi.',
          'ru':
              'Ретикулоциты — молодые безъядерные эритроциты, вышедшие из '
              'костного мозга в кровь; их число отражает активность '
              'эритропоэза.',
          'en':
              'Reticulocytes are young, non-nucleated red cells released from '
              'the marrow; their number shows how actively the marrow makes '
              'red cells.',
        }),
        [_wRetic],
      ),
      BmFact(
        _T({
          'uz':
              'Ulardagi mayda donachalar to‘ri (RNK, ribosomalar) briliant '
              'krezil ko‘ki bilan supravital bo‘yaladi; surtmada ma’lum '
              'sondagi eritrotsitlar orasida retikulotsitlar sanaladi.',
          'ru':
              'Их зернисто-сетчатая субстанция (РНК, рибосомы) окрашивается '
              'суправитально бриллиантовым крезиловым синим; в мазке считают '
              'ретикулоциты среди определённого числа эритроцитов.',
          'en':
              'Their fine granular network (RNA, ribosomes) is stained '
              'supravitally with brilliant cresyl blue; reticulocytes are '
              'counted among a set number of red cells on the film.',
        }),
        [_wRetic, _aRbc],
      ),
      BmFact(
        _T({
          'uz':
              'Kurs adabiyotida: retikulotsitlar to‘rning saqlanishiga ko‘ra '
              'I–V sinfga bo‘linadi; sog‘lom odamda asosan IV–V sinf, faol '
              'regeneratsiyada yoshroq (III, II, og‘ir anemiyada I) sinflar '
              'paydo bo‘ladi.',
          'ru':
              'В учебнике курса: ретикулоциты делят на классы I–V по '
              'сохранности сеточки; у здорового человека в основном IV–V '
              'класс, при активной регенерации появляются более молодые (III, '
              'II, при тяжёлой анемии I).',
          'en':
              'In the course textbook: reticulocytes are graded I–V by how '
              'much network remains; healthy people have mainly classes IV–V, '
              'while active regeneration brings younger ones (III, II, and I '
              'in severe anaemia).',
        }),
        [_najRetic],
      ),
    ],
  ),
  BmSection(
    id: 'method',
    title: _T({
      'uz': 'Bajarish (JSST qo‘llanmasi)',
      'ru': 'Выполнение (руководство ВОЗ)',
      'en': 'Procedure (WHO manual)',
    }),
    facts: [
      BmFact(
        _T({
          'uz':
              'Probirkaga 2 tomchi filtrlangan krezil ko‘ki eritmasi va 2 '
              'tomchi qon (barmoqdan yoki EDTA li vena qoni) qo‘shib, sekin '
              'aralashtiriladi va 15 daqiqa qoldiriladi.',
          'ru':
              'В пробирку вносят 2 капли профильтрованного раствора '
              'крезилового синего и 2 капли крови (из пальца или венозной с '
              'ЭДТА), осторожно перемешивают и оставляют на 15 минут.',
          'en':
              'Put 2 drops of filtered cresyl blue solution and 2 drops of '
              'blood (finger-prick or EDTA venous) in a tube, mix gently and '
              'leave for 15 minutes.',
        }),
        [_wRetic],
      ),
      BmFact(
        _T({
          'uz':
              'Aralashmadan yupqa surtma tayyorlab, havoda quritiladi. ×100 '
              'immersion obyektivda eritrotsitlar bir-biridan ajralgan uchida '
              'ko‘riladi; ko‘rilgan eritrotsitlar va ular orasidagi '
              'retikulotsitlar alohida sanaladi.',
          'ru':
              'Из смеси готовят тонкий мазок и высушивают на воздухе. Под '
              'иммерсией (×100) смотрят конец мазка, где эритроциты лежат '
              'раздельно; отдельно считают просмотренные эритроциты и '
              'ретикулоциты среди них.',
          'en':
              'Make a thin film from the mixture and air-dry it. With the ×100 '
              'oil objective look at the end where red cells are separated; '
              'keep separate counts of red cells examined and reticulocytes '
              'among them.',
        }),
        [_wRetic],
      ),
    ],
  ),
  BmSection(
    id: 'formula',
    title: _T({
      'uz': 'Hisoblash (manbadagi formula)',
      'ru': 'Расчёт (формула источника)',
      'en': 'Calculation (published formula)',
    }),
    facts: [
      BmFact(
        _T({
          'uz':
              'Ulush: % = retikulotsitlar ÷ ko‘rilgan eritrotsitlar × 100. 500 '
              'ta eritrotsitda n ta retikulotsit bo‘lsa: % = n × 0,2.',
          'ru':
              'Доля: % = ретикулоциты ÷ просмотренные эритроциты × 100. Если '
              'среди 500 эритроцитов n ретикулоцитов: % = n × 0,2.',
          'en':
              'Fraction: % = reticulocytes ÷ red cells examined × 100. With n '
              'reticulocytes among 500 red cells: % = n × 0.2.',
        }),
        [_wRetic],
      ),
      BmFact(
        _T({
          'uz':
              'Mutlaq son: RBC (×10¹²/L) × 2n × 10⁹/L (500 eritrotsitda), '
              'ya’ni RBC × % × 10 (×10⁹/L). Misol: RBC 4,5 va 500 tada 6 ta '
              'retikulotsit → 54 ×10⁹/L.',
          'ru':
              'Абсолютное число: RBC (×10¹²/л) × 2n × 10⁹/л (на 500 '
              'эритроцитов), то есть RBC × % × 10 (×10⁹/л). Пример: RBC 4,5 и 6 '
              'ретикулоцитов на 500 → 54 ×10⁹/л.',
          'en':
              'Absolute count: RBC (×10¹²/L) × 2n × 10⁹/L (per 500 red cells), '
              'i.e. RBC × % × 10 (×10⁹/L). Example: RBC 4.5 and 6 '
              'reticulocytes per 500 → 54 ×10⁹/L.',
        }),
        [_wRetic],
      ),
      BmFact(
        _T({
          'uz':
              'Anemiyaga tuzatish: tuzatilgan son (CRC, %) = retikulotsitlar % × '
              'bemor gematokriti ÷ normal gematokrit (masalan, katta '
              'erkaklarda 45). RPI = CRC ÷ yetilish vaqti (gematokritga '
              'bog‘liq); RPI > 3 — ilik javobi yetarli, < 2 — yetarli emas.',
          'ru':
              'Поправка на анемию: исправленный счёт (CRC, %) = ретикулоциты % × '
              'гематокрит пациента ÷ нормальный гематокрит (например, 45 у '
              'взрослых мужчин). RPI = CRC ÷ время созревания (зависит от '
              'гематокрита); RPI > 3 — адекватный ответ костного мозга, < 2 — '
              'недостаточный.',
          'en':
              'Correction for anaemia: corrected count (CRC, %) = reticulocytes '
              '% × patient haematocrit ÷ normal haematocrit (e.g. 45 for adult '
              'men). RPI = CRC ÷ maturation time (depends on haematocrit); '
              'RPI > 3 means an adequate marrow response, < 2 an inadequate '
              'one.',
        }),
        [_chCrc],
      ),
      BmFact(
        _T({
          'uz':
              'Referens (JSST, taxminiy): kattalar va bolalarda 0,2–2,0 % '
              '(8–110 ×10⁹/L), chaqaloqlarda 2,0–6,0 %. Kurs adabiyotida '
              'sog‘lom odamda 5–10 ‰.',
          'ru':
              'Референтный интервал (ВОЗ, ориентировочно): у взрослых и детей 0,2–2,0 % '
              '(8–110 ×10⁹/л), у новорождённых 2,0–6,0 %. В учебнике курса у '
              'здорового человека 5–10 ‰.',
          'en':
              'Reference (WHO, approximate): adults and children 0.2–2.0% '
              '(8–110 ×10⁹/L), newborns 2.0–6.0%. The course textbook gives '
              '5–10‰ in healthy people.',
        }),
        [_wRetic, _najRetic],
      ),
    ],
  ),
  BmSection(
    id: 'meaning',
    title: _T({
      'uz': 'Nima deydi',
      'ru': 'Что это значит',
      'en': 'What it tells you',
    }),
    facts: [
      BmFact(
        _T({
          'uz':
              'Anemiyada retikulotsitoz — qon yo‘qotish, gemoliz yoki davodan '
              'keyingi tiklanish; anemiyada past yoki “me’yoriy” son — ishlab '
              'chiqarish yetarli emas.',
          'ru':
              'Ретикулоцитоз при анемии — кровопотеря, гемолиз или '
              'восстановление после лечения; низкое или «нормальное» число при '
              'анемии — недостаточная продукция.',
          'en':
              'Reticulocytosis with anaemia means blood loss, haemolysis or '
              'recovery after treatment; a low or “normal” count with anaemia '
              'means inadequate production.',
        }),
        [_mRetic],
      ),
      BmFact(
        _T({
          'uz':
              'Kattalarda mutlaq son taxminan > 80 ×10⁹/L — ilik javobi yetarli '
              'yoki kuchaygan; og‘ir anemiyada taxminan < 20 ×10⁹/L — eritropoez '
              'keskin susaygan. Bular qat’iy chegara emas, taxminiy mo‘ljal.',
          'ru':
              'У взрослых абсолютное число примерно > 80 ×10⁹/л — ответ костного '
              'мозга адекватный или усиленный; при тяжёлой анемии примерно '
              '< 20 ×10⁹/л — эритропоэз резко угнетён. Это ориентиры, а не '
              'жёсткие пороги.',
          'en':
              'In adults an absolute count of roughly > 80 ×10⁹/L means an '
              'appropriate or enhanced marrow response; roughly < 20 ×10⁹/L in '
              'severe anaemia means markedly impaired erythropoiesis. These are '
              'approximate guides, not rigid cut-offs.',
        }),
        [_tStep2],
      ),
    ],
  ),
];

// ───────────────────────── Anemiya yordamchisi ─────────────────────────

/// Takami Table 3 qatori.
class BmPattern {
  const BmPattern(this.pattern, this.differentials, this.clue);

  final LocalizedText pattern;
  final LocalizedText differentials;
  final LocalizedText clue;
}

/// (MCV sinfi, RDW yuqorimi) → Takami 2026 Table 3.
const bmPatterns = <(BmMcvClass, bool), BmPattern>{
  (BmMcvClass.micro, false): BmPattern(
    _T({
      'uz': 'Bir xil mikrotsitoz',
      'ru': 'Однородный микроцитоз',
      'en': 'Uniform microcytosis',
    }),
    _T({
      'uz': 'Talassemiya tashuvchanligi, ayrim surunkali kasallik anemiyasi',
      'ru': 'Носительство талассемии, часть анемий хронических заболеваний',
      'en': 'Thalassaemia trait, some anaemia of chronic disease',
    }),
    _T({
      'uz': 'RBC soni ko‘pincha nisbatan saqlangan; anemiya yengil',
      'ru': 'Число RBC часто относительно сохранено; анемия лёгкая',
      'en': 'RBC count often relatively preserved; mild anaemia',
    }),
  ),
  (BmMcvClass.micro, true): BmPattern(
    _T({
      'uz': 'Har xil mikrotsitoz',
      'ru': 'Неоднородный микроцитоз',
      'en': 'Heterogeneous microcytosis',
    }),
    _T({
      'uz': 'Temir tanqisligi anemiyasi, sideroblast anemiya, aralash holatlar',
      'ru':
          'Железодефицитная анемия, сидеробластная анемия, сочетанные '
          'нарушения',
      'en':
          'Iron-deficiency anaemia, sideroblastic anaemia, combined disorders',
    }),
    _T({
      'uz':
          'Ferritin va transferrin to‘yinishini tekshiring; aralash '
          'populyatsiyalar ko‘p uchraydi',
      'ru':
          'Проверьте ферритин и насыщение трансферрина; смешанные популяции '
          'встречаются часто',
      'en':
          'Check ferritin and transferrin saturation; mixed populations are '
          'common',
    }),
  ),
  (BmMcvClass.normo, false): BmPattern(
    _T({
      'uz': 'Bir xil normotsitoz',
      'ru': 'Однородный нормоцитоз',
      'en': 'Homogeneous normocytosis',
    }),
    _T({
      'uz': 'Surunkali kasallik anemiyasi, erta anemiya, buyrak anemiyasi',
      'ru': 'Анемия хронических заболеваний, ранняя анемия, почечная анемия',
      'en': 'Anaemia of chronic disease, early anaemia, renal anaemia',
    }),
    _T({
      'uz': 'Talqin uchun retikulotsitlar hal qiluvchi',
      'ru': 'Для интерпретации решающее значение имеют ретикулоциты',
      'en': 'The reticulocyte count is critical for interpretation',
    }),
  ),
  (BmMcvClass.normo, true): BmPattern(
    _T({
      'uz': 'Aralash hujayra populyatsiyasi',
      'ru': 'Смешанная популяция клеток',
      'en': 'Mixed cell population',
    }),
    _T({
      'uz':
          'Erta temir tanqisligi, aralash tanqislik (temir + B12/folat), '
          'transfuziyadan keyin, anemiyadan tiklanish',
      'ru':
          'Ранний дефицит железа, сочетанный дефицит (железо + B12/фолат), '
          'после трансфузии, восстановление после анемии',
      'en':
          'Early iron deficiency, combined deficiency (iron + B12/folate), '
          'post-transfusion, recovery from anaemia',
    }),
    _T({
      'uz': 'RDW MCV dan oldin o‘zgarishi mumkin',
      'ru': 'RDW может меняться раньше MCV',
      'en': 'RDW elevation may precede MCV change',
    }),
  ),
  (BmMcvClass.macro, false): BmPattern(
    _T({
      'uz': 'Bir xil makrotsitoz',
      'ru': 'Однородный макроцитоз',
      'en': 'Uniform macrocytosis',
    }),
    _T({
      'uz': 'Alkogol, jigar kasalligi, gipotireoz, ayrim dorilar',
      'ru': 'Алкоголь, болезни печени, гипотиреоз, некоторые лекарства',
      'en': 'Alcohol use, liver disease, hypothyroidism, some medications',
    }),
    _T({
      'uz': 'Ko‘pincha barqaror, megaloblast bo‘lmagan holat',
      'ru': 'Часто стабильная, немегалобластная картина',
      'en': 'Often a stable, non-megaloblastic pattern',
    }),
  ),
  (BmMcvClass.macro, true): BmPattern(
    _T({
      'uz': 'Har xil makrotsitoz',
      'ru': 'Неоднородный макроцитоз',
      'en': 'Heterogeneous macrocytosis',
    }),
    _T({
      'uz': 'B12 tanqisligi, folat tanqisligi, miyelodisplastik sindromlar',
      'ru': 'Дефицит B12, дефицит фолата, миелодиспластические синдромы',
      'en':
          'Vitamin B12 deficiency, folate deficiency, myelodysplastic '
          'syndromes',
    }),
    _T({
      'uz': 'Samarasiz eritropoez va aralash populyatsiyalarni o‘ylang',
      'ru': 'Подумайте о неэффективном эритропоэзе и смешанных популяциях',
      'en': 'Consider ineffective erythropoiesis and mixed populations',
    }),
  ),
};

/// Faqat MCV ma'lum bo'lganda (RDW yo'q) — MSD "RBC indices".
const bmMcvOnly = <BmMcvClass, LocalizedText>{
  BmMcvClass.micro: _T({
    'uz':
        'Mikrotsitar indekslar — gem yoki globin sintezi buzilishi: ko‘pincha '
        'temir tanqisligi, talassemiya; ayrim surunkali kasallik '
        'anemiyasida ham.',
    'ru':
        'Микроцитарные индексы — нарушение синтеза гема или глобина: чаще '
        'дефицит железа, талассемия; бывает и при части анемий хронических '
        'заболеваний.',
    'en':
        'Microcytic indices reflect altered haem or globin synthesis: most '
        'often iron deficiency, thalassaemia; also some anaemia of chronic '
        'disease.',
  }),
  BmMcvClass.normo: _T({
    'uz':
        'Normotsitar indekslar — eritropoetin yetishmasligi yoki unga javob '
        'sustligi (gipoproliferativ anemiya); temir tanqisligi '
        'rivojlanmaguncha qon yo‘qotish.',
    'ru':
        'Нормоцитарные индексы — недостаток эритропоэтина или слабый ответ на '
        'него (гипопролиферативная анемия); кровопотеря до развития дефицита '
        'железа.',
    'en':
        'Normocytic indices occur with deficient erythropoietin or a poor '
        'response to it (hypoproliferative anaemia); haemorrhage before iron '
        'deficiency develops.',
  }),
  BmMcvClass.macro: _T({
    'uz':
        'Makrotsitar indekslar — DNK sintezi buzilishi (B12 yoki folat '
        'tanqisligi, ayrim dorilar) va alkogol; o‘tkir qon ketishida yosh '
        'retikulotsitlar MCV ni qisqa vaqt oshirishi mumkin.',
    'ru':
        'Макроцитарные индексы — нарушение синтеза ДНК (дефицит B12 или '
        'фолата, некоторые лекарства) и алкоголь; при острой кровопотере '
        'молодые ретикулоциты могут кратковременно повысить MCV.',
    'en':
        'Macrocytic indices occur with impaired DNA synthesis (B12 or folate '
        'deficiency, some drugs) and alcohol; acute bleeding may briefly raise '
        'the MCV through young reticulocytes.',
  }),
};

/// Yordamchi natijasi ostidagi manbalar.
const bmHelperRefs = <CalcRef>[
  _whoHb,
  _tT3,
  _mIndices,
  _whoFer,
  _tStep2,
  _mRetic,
  _tT5,
  _saidovRdw,
  _aRbc,
];

// ───────────────────────── Mashq ─────────────────────────

/// Rasmli savollar soni (bir mashqda).
const bmPictureQuizSize = 8;

/// Bilim savollari soni (bir mashqda).
const bmKnowledgeQuizSize = 4;

/// Rasmli savol uchun chalg'ituvchilar: o'xshashlari (3 tadan).
const bmDistractors = <String, List<String>>{
  'microcytes': ['spherocytes', 'macrocytes', 'sickle-cells'],
  'macrocytes': ['polychromasia', 'microcytes', 'elliptocytes'],
  'polychromasia': ['sickle-cells', 'elliptocytes', 'rouleaux'],
  'spherocytes': ['microcytes', 'target-cells', 'stomatocytes'],
  'target-cells': ['stomatocytes', 'spherocytes', 'microcytes'],
  'schistocytes': ['acanthocytes', 'sickle-cells', 'stomatocytes'],
  'sickle-cells': ['elliptocytes', 'teardrop-cells', 'schistocytes'],
  'teardrop-cells': ['sickle-cells', 'stomatocytes', 'spherocytes'],
  'elliptocytes': ['sickle-cells', 'stomatocytes', 'spherocytes'],
  'stomatocytes': ['target-cells', 'spherocytes', 'elliptocytes'],
  'acanthocytes': ['spherocytes', 'target-cells', 'elliptocytes'],
  'echinocytes': ['spherocytes', 'target-cells', 'elliptocytes'],
  'basophilic-stippling': ['howell-jolly', 'target-cells', 'acanthocytes'],
  'howell-jolly': ['basophilic-stippling', 'target-cells', 'spherocytes'],
  'rouleaux': ['agglutination', 'spherocytes', 'elliptocytes'],
  'agglutination': ['rouleaux', 'spherocytes', 'schistocytes'],
  'giant-platelets': ['platelet-clumps', 'platelet-satellitism', 'spherocytes'],
  'platelet-clumps': [
    'platelet-satellitism',
    'giant-platelets',
    'agglutination',
  ],
  'platelet-satellitism': [
    'platelet-clumps',
    'giant-platelets',
    'howell-jolly',
  ],
};

/// Matnli savol: variantlar, to'g'ri javob va asos (manbasi bilan).
class BmKnowQuestion {
  const BmKnowQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correct,
    required this.basis,
  });

  final String id;
  final LocalizedText prompt;
  final List<LocalizedText> options;
  final int correct;
  final BmFact basis;
}

const bmKnowledge = <BmKnowQuestion>[
  BmKnowQuestion(
    id: 'where-to-look',
    prompt: _T({
      'uz': 'Eritrotsit morfologiyasini surtmaning qaysi qismida baholaysiz?',
      'ru': 'В какой части мазка оценивают морфологию эритроцитов?',
      'en': 'Where on the film do you assess red cell morphology?',
    }),
    options: [
      _T({
        'uz':
            'Yupqa uchidan sal oldin, hujayralar tegib, lekin ustma-ust '
            'tushmagan joyda',
        'ru':
            'Чуть раньше тонкого края, где клетки касаются, но не '
            'наслаиваются',
        'en': 'Just before the thin end, where cells touch but do not overlap',
      }),
      _T({
        'uz': 'Qalin boshida — hujayralar ko‘p bo‘lgani uchun',
        'ru': 'В толстой головке — там больше клеток',
        'en': 'At the thick head, where cells are most numerous',
      }),
      _T({
        'uz': 'Eng yupqa uchining o‘zida',
        'ru': 'На самом тонком крае',
        'en': 'At the very thin end itself',
      }),
      _T({
        'uz': 'Qayeri bo‘lsa ham farqi yo‘q',
        'ru': 'Без разницы, в любом месте',
        'en': 'Anywhere — it makes no difference',
      }),
    ],
    correct: 0,
    basis: BmFact(
      _T({
        'uz':
            'JSST: qalin uchida hujayralar juda zich, eng yupqa uchida juda '
            'kam; ular tegib, ustma-ust tushmagan joyga qaraladi.',
        'ru':
            'ВОЗ: в толстой части клетки слишком плотные, на самом тонком крае '
            'их слишком мало; смотрят там, где они касаются, но не '
            'наслаиваются.',
        'en':
            'WHO: cells are too packed at the thick end and too few at the '
            'very thin end; look where they touch but do not overlap.',
      }),
      [_wLook],
    ),
  ),
  BmKnowQuestion(
    id: 'heparin',
    prompt: _T({
      'uz': 'Morfologiya uchun qaysi antikoagulant ishlatilmaydi?',
      'ru': 'Какой антикоагулянт не используют для морфологии?',
      'en': 'Which anticoagulant is not used for morphology?',
    }),
    options: [
      _T({'uz': 'Geparin', 'ru': 'Гепарин', 'en': 'Heparin'}),
      _T({'uz': 'EDTA', 'ru': 'ЭДТА', 'en': 'EDTA'}),
      _T({
        'uz': 'Antikoagulantsiz, darhol surtilgan qon',
        'ru': 'Кровь без антикоагулянта, сразу размазанная',
        'en': 'Blood spread immediately without anticoagulant',
      }),
      _T({
        'uz': 'Barcha antikoagulantlar bir xil',
        'ru': 'Все антикоагулянты одинаковы',
        'en': 'All anticoagulants are equivalent',
      }),
    ],
    correct: 0,
    basis: BmFact(
      _T({
        'uz':
            'JSST: geparin leykotsit va trombotsitlar ko‘rinishini '
            'o‘zgartiradi; kechikadigan surtma uchun EDTA ishlatiladi.',
        'ru':
            'ВОЗ: гепарин изменяет вид лейкоцитов и тромбоцитов; для '
            'отсроченного мазка используют ЭДТА.',
        'en':
            'WHO: heparin alters the appearance of leukocytes and platelets; '
            'EDTA is used when the film is delayed.',
      }),
      [_wPrep],
    ),
  ),
  BmKnowQuestion(
    id: 'ptcp-first-step',
    prompt: _T({
      'uz':
          'Analizator kutilmaganda juda past trombotsit ko‘rsatdi, bemorda qon '
          'ketish belgisi yo‘q. Birinchi qadam?',
      'ru':
          'Анализатор неожиданно показал очень низкие тромбоциты, '
          'кровоточивости нет. Первый шаг?',
      'en':
          'The analyser shows an unexpectedly very low platelet count and the '
          'patient has no bleeding. First step?',
    }),
    options: [
      _T({
        'uz': 'Surtmada trombotsit to‘plamlarini qidirish',
        'ru': 'Поискать агрегаты тромбоцитов в мазке',
        'en': 'Look for platelet clumps on the film',
      }),
      _T({
        'uz': 'Darhol “og‘ir trombotsitopeniya” deb chiqarish',
        'ru': 'Сразу выдать «тяжёлая тромбоцитопения»',
        'en': 'Report “severe thrombocytopenia” straight away',
      }),
      _T({
        'uz': 'Namunani muzlatgichda saqlab, ertaga qayta sanash',
        'ru': 'Убрать пробу в холодильник и пересчитать завтра',
        'en': 'Refrigerate the sample and recount tomorrow',
      }),
      _T({
        'uz': 'Analizator flag bermagan bo‘lsa — to‘plam yo‘q deb hisoblash',
        'ru': 'Если анализатор не дал флага — агрегатов нет',
        'en': 'If there is no analyser flag, assume there are no clumps',
      }),
    ],
    correct: 0,
    basis: BmFact(
      _T({
        'uz':
            'Psevdotrombotsitopeniya tashxisi faqat EDTA li qon surtmasida '
            'to‘plamlarni ko‘rishga tayanadi; flag yo‘qligi uni istisno '
            'qilmaydi; antitanalar sovuqda faolroq.',
        'ru':
            'Диагноз псевдотромбоцитопении основан только на обнаружении '
            'агрегатов в мазке крови с ЭДТА; отсутствие флага её не '
            'исключает; антитела активнее на холоде.',
        'en':
            'Pseudothrombocytopenia is diagnosed only by seeing clumps on an '
            'EDTA blood film; a missing flag does not exclude it; the '
            'antibodies are more active in the cold.',
      }),
      [_cDx, _cMech],
    ),
  ),
  BmKnowQuestion(
    id: 'retic-500',
    prompt: _T({
      'uz':
          '500 ta eritrotsit orasida 10 ta retikulotsit sanaldi. Retikulotsitlar '
          'ulushi qancha?',
      'ru':
          'Среди 500 эритроцитов насчитано 10 ретикулоцитов. Какова доля '
          'ретикулоцитов?',
      'en':
          '10 reticulocytes were counted among 500 red cells. What is the '
          'reticulocyte percentage?',
    }),
    options: [
      _T({'uz': '2 %', 'ru': '2 %', 'en': '2%'}),
      _T({'uz': '0,2 %', 'ru': '0,2 %', 'en': '0.2%'}),
      _T({'uz': '5 %', 'ru': '5 %', 'en': '5%'}),
      _T({'uz': '20 %', 'ru': '20 %', 'en': '20%'}),
    ],
    correct: 0,
    basis: BmFact(
      _T({
        'uz': '500 tadan n ta: % = n × 0,2 = 10 × 0,2 = 2 %.',
        'ru': 'n из 500: % = n × 0,2 = 10 × 0,2 = 2 %.',
        'en': 'n per 500: % = n × 0.2 = 10 × 0.2 = 2%.',
      }),
      [_wRetic],
    ),
  ),
  BmKnowQuestion(
    id: 'satellitism-edta',
    prompt: _T({
      'uz': 'Trombotsit satellitizmi qaysi qonda kuzatiladi?',
      'ru': 'В какой крови наблюдается сателлитизм тромбоцитов?',
      'en': 'In which blood is platelet satellitism seen?',
    }),
    options: [
      _T({
        'uz': 'EDTA li qonda (in vitro)',
        'ru': 'В крови с ЭДТА (in vitro)',
        'en': 'In EDTA blood (in vitro)',
      }),
      _T({
        'uz': 'Faqat sitratli qonda',
        'ru': 'Только в цитратной крови',
        'en': 'Only in citrated blood',
      }),
      _T({
        'uz': 'Faqat bemor tomirida (in vivo)',
        'ru': 'Только в сосудах пациента (in vivo)',
        'en': 'Only in the patient’s vessels (in vivo)',
      }),
      _T({
        'uz': 'Faqat suyak ko‘migida',
        'ru': 'Только в костном мозге',
        'en': 'Only in bone marrow',
      }),
    ],
    correct: 0,
    basis: BmFact(
      _T({
        'uz':
            'Satellitizm — EDTA ta’sirida trombotsitlarning leykotsitlarga '
            'in vitro yopishishi; boshqa antikoagulantlarda kuzatilmaydi.',
        'ru':
            'Сателлитизм — вызванное ЭДТА прилипание тромбоцитов к '
            'лейкоцитам in vitro; в других антикоагулянтах не наблюдается.',
        'en':
            'Satellitism is EDTA-induced in-vitro adherence of platelets to '
            'leukocytes; it is not seen with other anticoagulants.',
      }),
      [_cAbs, _cSat],
    ),
  ),
  BmKnowQuestion(
    id: 'stippling-vs-deposit',
    prompt: _T({
      'uz': 'Bazofil punktatsiyani nima bilan adashtirish mumkin?',
      'ru': 'С чем можно спутать базофильную пунктацию?',
      'en': 'What can basophilic stippling be confused with?',
    }),
    options: [
      _T({
        'uz': 'Bo‘yoq cho‘kmasi bilan',
        'ru': 'С осадком красителя',
        'en': 'Stain deposit',
      }),
      _T({
        'uz': '“Tanga ustunchalari” bilan',
        'ru': 'С монетными столбиками',
        'en': 'Rouleaux',
      }),
      _T({
        'uz': 'Elliptotsitlar bilan',
        'ru': 'С эллиптоцитами',
        'en': 'Elliptocytes',
      }),
      _T({
        'uz': 'Gigant trombotsitlar bilan',
        'ru': 'С гигантскими тромбоцитами',
        'en': 'Giant platelets',
      }),
    ],
    correct: 0,
    basis: BmFact(
      _T({
        'uz':
            'JSST: bazofil punktatsiya — sitoplazmadagi ko‘k-qora nuqtalar; '
            'bo‘yoq cho‘kmasi bilan adashtirmang.',
        'ru':
            'ВОЗ: базофильная пунктация — сине-чёрные точки в цитоплазме; не '
            'путайте с осадком красителя.',
        'en':
            'WHO: basophilic stippling is blue-black dots in the cytoplasm; do '
            'not confuse it with stain deposit.',
      }),
      [_wP309],
    ),
  ),
  BmKnowQuestion(
    id: 'normal-mcv-high-rdw',
    prompt: _T({
      'uz': 'MCV me’yorda, RDW yuqori. Bu holat haqida qaysi gap to‘g‘ri?',
      'ru': 'MCV в норме, RDW повышен. Какое утверждение верно?',
      'en': 'MCV is normal and RDW is high. Which statement is true?',
    }),
    options: [
      _T({
        'uz':
            'Aralash populyatsiya bo‘lishi mumkin (masalan, erta temir '
            'tanqisligi yoki aralash tanqislik)',
        'ru':
            'Возможна смешанная популяция (например, ранний дефицит железа '
            'или сочетанный дефицит)',
        'en':
            'There may be a mixed population (e.g. early iron deficiency or '
            'combined deficiency)',
      }),
      _T({
        'uz': 'MCV me’yorda — demak, patologiya yo‘q',
        'ru': 'MCV в норме — значит, патологии нет',
        'en': 'MCV is normal, so there is no pathology',
      }),
      _T({
        'uz': 'Bu faqat talassemiya tashuvchanligi',
        'ru': 'Это только носительство талассемии',
        'en': 'This is always thalassaemia trait',
      }),
      _T({
        'uz': 'RDW hech qachon MCV dan oldin o‘zgarmaydi',
        'ru': 'RDW никогда не меняется раньше MCV',
        'en': 'RDW never changes before MCV',
      }),
    ],
    correct: 0,
    basis: BmFact(
      _T({
        'uz':
            'Takami (Table 3): MCV me’yorda + RDW yuqori — aralash populyatsiya '
            '(erta temir tanqisligi, aralash tanqislik, transfuziyadan keyin, '
            'tiklanish); RDW MCV dan oldin o‘zgarishi mumkin.',
        'ru':
            'Takami (Table 3): MCV в норме + RDW повышен — смешанная популяция '
            '(ранний дефицит железа, сочетанный дефицит, после трансфузии, '
            'восстановление); RDW может меняться раньше MCV.',
        'en':
            'Takami (Table 3): normal MCV + high RDW — a mixed population '
            '(early iron deficiency, combined deficiency, post-transfusion, '
            'recovery); RDW may change before MCV.',
      }),
      [_tT3],
    ),
  ),
  BmKnowQuestion(
    id: 'howell-jolly-spleen',
    prompt: _T({
      'uz': 'Xauell–Jolli tanachalari ko‘pincha qachon uchraydi?',
      'ru': 'Когда чаще всего встречаются тельца Хауэлла–Жолли?',
      'en': 'When are Howell–Jolly bodies most typically seen?',
    }),
    options: [
      _T({
        'uz': 'Splenektomiyadan keyin yoki aspleniyada',
        'ru': 'После спленэктомии или при асплении',
        'en': 'After splenectomy or in asplenia',
      }),
      _T({
        'uz': 'Faqat qo‘rg‘oshin bilan zaharlanishda',
        'ru': 'Только при отравлении свинцом',
        'en': 'Only in lead poisoning',
      }),
      _T({
        'uz': 'EDTA da uzoq saqlanganda',
        'ru': 'При долгом хранении в ЭДТА',
        'en': 'After long storage in EDTA',
      }),
      _T({
        'uz': 'Faqat sog‘lom odamda',
        'ru': 'Только у здоровых людей',
        'en': 'Only in healthy people',
      }),
    ],
    correct: 0,
    basis: BmFact(
      _T({
        'uz':
            'Xauell–Jolli tanachalari — DNK qoldiqlari; taloq ularni '
            '“tozalamaganda” (splenektomiya, aspleniya) uchraydi.',
        'ru':
            'Тельца Хауэлла–Жолли — остатки ДНК; встречаются, когда селезёнка '
            'их не удаляет (спленэктомия, аспления).',
        'en':
            'Howell–Jolly bodies are DNA remnants seen when the spleen no '
            'longer removes them (splenectomy, asplenia).',
      }),
      [_aRbc, _wP309],
    ),
  ),
];

// ───────────────────────── Interfeys matnlari ─────────────────────────

abstract final class BmL {
  static const subtitle = _T({
    'uz': 'Periferik qon surtmasi: eritrotsitlar, trombotsitlar, anemiyalar',
    'ru': 'Мазок периферической крови: эритроциты, тромбоциты, анемии',
    'en': 'Peripheral blood film: red cells, platelets, anaemias',
  });
  static const draftNote = _T({
    'uz':
        'Qoralama: matn ochiq manbalar (JSST qo‘llanmasi, sharhlar, MSD) va '
        'kurs adabiyoti asosida yozilgan, mutaxassis tekshiruvidan hali '
        'o‘tmagan. Bu o‘quv qo‘llanma — tashxis qo‘ymaydi.',
    'ru':
        'Черновик: текст основан на открытых источниках (руководство ВОЗ, '
        'обзоры, MSD) и литературе курса и ещё не проверен экспертом. Это '
        'учебное пособие — диагноз оно не ставит.',
    'en':
        'Draft: the text is based on open sources (WHO manual, reviews, MSD) '
        'and course literature and has not yet been expert-reviewed. This is '
        'a learning aid — it does not make a diagnosis.',
  });
  static const photoNote = _T({
    'uz':
        'Rasmlar — Wikimedia Commons’dagi erkin litsenziyali haqiqiy '
        'mikrofotolar (muallif va litsenziya har kartada); kartadagi belgi '
        'rasmdagi ba’zi hujayralargagina tegishli bo‘lishi mumkin.',
    'ru':
        'Иллюстрации — настоящие микрофото со свободной лицензией с Wikimedia '
        'Commons (автор и лицензия — в каждой карточке); признак может '
        'относиться лишь к части клеток на снимке.',
    'en':
        'Pictures are real, openly licensed micrographs from Wikimedia Commons '
        '(author and licence on every card); a feature may apply to only some '
        'of the cells pictured.',
  });
  static const normalTitle = _T({
    'uz': 'Normal eritrotsit va nimaga qarash',
    'ru': 'Нормальный эритроцит и на что смотреть',
    'en': 'The normal red cell and what to look at',
  });
  static const normalSub = _T({
    'uz': 'O‘lcham, rang, shakl, kiritmalar; surtmaning qayeriga qarash',
    'ru': 'Размер, цвет, форма, включения; куда смотреть в мазке',
    'en': 'Size, colour, shape, inclusions; where to look',
  });
  static const findingsTitle = _T({
    'uz': 'Eritrotsit o‘zgarishlari',
    'ru': 'Изменения эритроцитов',
    'en': 'Red cell changes',
  });
  static const findingsSub = _T({
    'uz': 'Rasmli kartalar: nimani ko‘rasiz, nimaga ishora qiladi',
    'ru': 'Карточки с фото: что видно, на что может указывать',
    'en': 'Picture cards: what you see, what it may point to',
  });
  static const plateletsTitle = _T({
    'uz': 'Trombotsitlar',
    'ru': 'Тромбоциты',
    'en': 'Platelets',
  });
  static const plateletsSub = _T({
    'uz': 'Normal, gigant, to‘plamlar (EDTA artefakti), satellitizm',
    'ru': 'Норма, гигантские, агрегаты (артефакт ЭДТА), сателлитизм',
    'en': 'Normal, giant, clumps (EDTA artefact), satellitism',
  });
  static const reticTitle = _T({
    'uz': 'Retikulotsitlar',
    'ru': 'Ретикулоциты',
    'en': 'Reticulocytes',
  });
  static const reticSub = _T({
    'uz': 'Sanash tamoyili, %, mutlaq son, tuzatilgan son',
    'ru': 'Принцип подсчёта, %, абсолютное число, поправка',
    'en': 'Counting principle, %, absolute and corrected count',
  });
  static const anemiaTitle = _T({
    'uz': 'Anemiya tasnifi yordamchisi',
    'ru': 'Помощник классификации анемии',
    'en': 'Anaemia classification helper',
  });
  static const anemiaSub = _T({
    'uz': 'Hb, MCV, RDW (+ ferritin, retikulotsitlar) → morfologik guruh',
    'ru': 'Hb, MCV, RDW (+ ферритин, ретикулоциты) → морфологическая группа',
    'en': 'Hb, MCV, RDW (+ ferritin, reticulocytes) → morphologic group',
  });
  static const qualityTitle = _T({
    'uz': 'Surtma sifati va artefaktlar',
    'ru': 'Качество мазка и артефакты',
    'en': 'Film quality and artefacts',
  });
  static const qualitySub = _T({
    'uz': 'Qalin/yupqa, bo‘yash muammolari, EDTA da saqlash',
    'ru': 'Толстый/тонкий, проблемы окраски, хранение в ЭДТА',
    'en': 'Thick/thin, staining problems, EDTA storage',
  });
  static const quizTitle = _T({
    'uz': 'Mashq: bu qaysi o‘zgarish?',
    'ru': 'Тренировка: что это за изменение?',
    'en': 'Practice: which change is this?',
  });
  static const quizSub = _T({
    'uz': 'Rasm bo‘yicha va bilim savollari',
    'ru': 'Вопросы по фото и на знание',
    'en': 'Picture and knowledge questions',
  });
  static const creditsTitle = _T({
    'uz': 'Rasm mualliflari va litsenziyalar',
    'ru': 'Авторы изображений и лицензии',
    'en': 'Picture credits and licences',
  });
  static const creditsSub = _T({
    'uz': 'Har bir rasm: muallif, litsenziya, manba sahifasi',
    'ru': 'Каждое изображение: автор, лицензия, страница источника',
    'en': 'Every picture: author, licence, source page',
  });
  static const creditsIntro = _T({
    'uz':
        'Barcha rasmlar Wikimedia Commons’dan; litsenziya, muallif va asl '
        'izoh $bmCheckedAt da fayl sahifasidan tekshirilgan. Rasmlar faqat '
        'kichraytirilgan (kesilmagan, rangi o‘zgartirilmagan). Bundan '
        'tashqari bo‘lim belgisi — LabGuide’ning o‘z sxemasi.',
    'ru':
        'Все изображения — с Wikimedia Commons; лицензия, автор и исходная '
        'подпись проверены на странице файла $bmCheckedAt. Изображения только '
        'уменьшены (не обрезаны, цвет не менялся). Значок раздела — '
        'собственная схема LabGuide.',
    'en':
        'All pictures are from Wikimedia Commons; licence, author and the '
        'original caption were checked on the file page on $bmCheckedAt. '
        'Pictures are only downscaled (not cropped, colours unchanged). The '
        'section icon is LabGuide’s own schematic.',
  });
  static const groups = {
    BmGroup.size: _T({'uz': 'O‘lcham', 'ru': 'Размер', 'en': 'Size'}),
    BmGroup.colour: _T({'uz': 'Rang', 'ru': 'Цвет', 'en': 'Colour'}),
    BmGroup.shape: _T({'uz': 'Shakl', 'ru': 'Форма', 'en': 'Shape'}),
    BmGroup.inclusion: _T({
      'uz': 'Kiritmalar',
      'ru': 'Включения',
      'en': 'Inclusions',
    }),
    BmGroup.arrangement: _T({
      'uz': 'Joylashuv',
      'ru': 'Расположение',
      'en': 'Arrangement',
    }),
    BmGroup.platelet: _T({
      'uz': 'Trombotsitlar',
      'ru': 'Тромбоциты',
      'en': 'Platelets',
    }),
  };
  static const akaTitle = _T({
    'uz': 'Boshqa nomi',
    'ru': 'Другое название',
    'en': 'Also called',
  });
  static const seeTitle = _T({
    'uz': 'Nimani ko‘rasiz',
    'ru': 'Что видно',
    'en': 'What you see',
  });
  static const pointsTitle = _T({
    'uz': 'Nimaga ishora qilishi mumkin',
    'ru': 'На что может указывать',
    'en': 'What it may point to',
  });
  static const notDiagnosis = _T({
    'uz': 'Bu tashxis emas — ehtimollar ro‘yxati.',
    'ru': 'Это не диагноз — перечень возможностей.',
    'en': 'This is not a diagnosis — a list of possibilities.',
  });
  static const confuseTitle = _T({
    'uz': 'Nima bilan adashtiriladi',
    'ru': 'С чем путают',
    'en': 'Commonly confused with',
  });
  static const referTitle = _T({
    'uz': 'Kimga va qanday yetkaziladi',
    'ru': 'Кому и как передать',
    'en': 'Who to tell and how',
  });
  static const imageTitle = _T({
    'uz': 'Rasm haqida',
    'ru': 'Об изображении',
    'en': 'About the picture',
  });
  static const stain = _T({'uz': 'Bo‘yoq', 'ru': 'Окраска', 'en': 'Stain'});
  static const stainNotStated = _T({
    'uz': 'Manbada ko‘rsatilmagan',
    'ru': 'В источнике не указана',
    'en': 'Not stated in the source',
  });
  static const captionTitle = _T({
    'uz': 'Fayl sahifasidagi asl izoh',
    'ru': 'Исходная подпись на странице файла',
    'en': 'Original caption on the file page',
  });
  static const checked = _T({
    'uz': 'Tekshirilgan',
    'ru': 'Проверено',
    'en': 'Checked',
  });
  static const resized = _T({
    'uz': 'Ilovadagi o‘lcham (asl)',
    'ru': 'Размер в приложении (исходный)',
    'en': 'Size in the app (original)',
  });
  static const noPhoto = _T({
    'uz': 'Mos, aniq belgilangan erkin rasm topilmadi.',
    'ru': 'Подходящего точно подписанного свободного изображения не найдено.',
    'en': 'No suitable, clearly labelled openly licensed picture was found.',
  });
  static const relatedCards = _T({
    'uz': 'Tahlil kartalari',
    'ru': 'Карточки анализов',
    'en': 'Test cards',
  });
  static const leukoLinkTitle = _T({
    'uz': 'Leykotsitlar — leykoformula bo‘limida',
    'ru': 'Лейкоциты — в разделе «Лейкоформула»',
    'en': 'White cells — in the differential count section',
  });
  static const leukoLinkSub = _T({
    'uz': 'Hujayra atlasi, sanash, talqin va mashq',
    'ru': 'Атлас клеток, подсчёт, интерпретация и тренировка',
    'en': 'Cell atlas, counting, interpretation and practice',
  });
  static const normalPlatelets = _T({
    'uz': 'Normal trombotsitlar',
    'ru': 'Нормальные тромбоциты',
    'en': 'Normal platelets',
  });
  static const schemeTitle = _T({
    'uz': 'Sxema: nimaga qarash kerak',
    'ru': 'Схема: на что смотреть',
    'en': 'Diagram: what to look at',
  });
  static const schemeLabel = _T({
    'uz':
        'LabGuide sxemasi (mikrofoto emas): 1 — normal eritrotsit (markazida '
        'och joy ≈ 1/3), 2 — mikrotsit, 3 — makrotsit, 4 — gipoxrom '
        'eritrotsit (keng och markaz), 5 — sferotsit (och joy yo‘q), '
        '6 — kichik limfotsit (yadrosi o‘lcham uchun mo‘ljal).',
    'ru':
        'Схема LabGuide (не микрофото): 1 — нормальный эритроцит '
        '(просветление ≈ 1/3), 2 — микроцит, 3 — макроцит, 4 — гипохромный '
        'эритроцит (широкое просветление), 5 — сфероцит (без просветления), '
        '6 — малый лимфоцит (его ядро — ориентир размера).',
    'en':
        'LabGuide diagram (not a micrograph): 1 — normal red cell (pallor '
        '≈ 1/3), 2 — microcyte, 3 — macrocyte, 4 — hypochromic red cell '
        '(wide pallor), 5 — spherocyte (no pallor), 6 — small lymphocyte '
        '(its nucleus is a size yardstick).',
  });
  static const calcLink = _T({
    'uz': 'Retikulotsitlar kalkulyatorini ochish',
    'ru': 'Открыть калькулятор ретикулоцитов',
    'en': 'Open the reticulocyte calculator',
  });
  static const calcLinkSub = _T({
    'uz': '%, mutlaq son, tuzatilgan %, RPI — kiritilgan sonlardan',
    'ru': '%, абсолютное число, исправленный %, RPI — по вашим данным',
    'en': '%, absolute count, corrected %, RPI — from your numbers',
  });
  static const workedTitle = _T({
    'uz': 'Ishlangan misol',
    'ru': 'Разобранный пример',
    'en': 'Worked example',
  });
  static const workedInput = _T({
    'uz':
        '500 ta eritrotsit orasida 15 ta retikulotsit; RBC 3,0 ×10¹²/L; '
        'gematokrit 30 %.',
    'ru':
        '15 ретикулоцитов среди 500 эритроцитов; RBC 3,0 ×10¹²/л; '
        'гематокрит 30 %.',
    'en':
        '15 reticulocytes among 500 red cells; RBC 3.0 ×10¹²/L; '
        'haematocrit 30%.',
  });
  static const workedPercent = _T({
    'uz': 'Retikulotsitlar, %',
    'ru': 'Ретикулоциты, %',
    'en': 'Reticulocytes, %',
  });
  static const workedAbsolute = _T({
    'uz': 'Mutlaq son, ×10⁹/L',
    'ru': 'Абсолютное число, ×10⁹/л',
    'en': 'Absolute count, ×10⁹/L',
  });
  static const workedCorrected = _T({
    'uz': 'Tuzatilgan son (CRC), % (normal Ht = 45)',
    'ru': 'Исправленный счёт (CRC), % (нормальный Ht = 45)',
    'en': 'Corrected count (CRC), % (normal Hct = 45)',
  });
  static const anemiaIntro = _T({
    'uz':
        'Raqamlarni kiriting — ilova morfologik guruhni va u nimaga ishora '
        'qilishi mumkinligini manbadagi jadval bo‘yicha ko‘rsatadi. '
        'Chegaralar o‘ylab topilmagan: Hb — JSST 2024, MCV/RDW — Takami '
        '2026 (Table 3), ferritin — JSST 2020, retikulotsitlar — Takami 2026.',
    'ru':
        'Введите значения — приложение покажет морфологическую группу и то, '
        'на что она может указывать, по таблице источника. Пороги не '
        'придуманы: Hb — ВОЗ 2024, MCV/RDW — Takami 2026 (Table 3), '
        'ферритин — ВОЗ 2020, ретикулоциты — Takami 2026.',
    'en':
        'Enter the values — the app shows the morphologic group and what it '
        'may point to, using the source table. No invented cut-offs: Hb — WHO '
        '2024, MCV/RDW — Takami 2026 (Table 3), ferritin — WHO 2020, '
        'reticulocytes — Takami 2026.',
  });
  static const populationTitle = _T({
    'uz': 'Guruh (JSST 2024)',
    'ru': 'Группа (ВОЗ 2024)',
    'en': 'Group (WHO 2024)',
  });
  static const populations = {
    BmPopulation.child6to23m: _T({
      'uz': 'Bola, 6–23 oy',
      'ru': 'Ребёнок, 6–23 мес',
      'en': 'Child, 6–23 months',
    }),
    BmPopulation.child24to59m: _T({
      'uz': 'Bola, 24–59 oy',
      'ru': 'Ребёнок, 24–59 мес',
      'en': 'Child, 24–59 months',
    }),
    BmPopulation.child5to11y: _T({
      'uz': 'Bola, 5–11 yosh',
      'ru': 'Ребёнок, 5–11 лет',
      'en': 'Child, 5–11 years',
    }),
    BmPopulation.girl12to14y: _T({
      'uz': 'Qiz, 12–14 yosh (homilador emas)',
      'ru': 'Девочка, 12–14 лет (не беременна)',
      'en': 'Girl, 12–14 years (not pregnant)',
    }),
    BmPopulation.boy12to14y: _T({
      'uz': 'O‘g‘il bola, 12–14 yosh',
      'ru': 'Мальчик, 12–14 лет',
      'en': 'Boy, 12–14 years',
    }),
    BmPopulation.woman15to65: _T({
      'uz': 'Ayol, 15–65 yosh (homilador emas)',
      'ru': 'Женщина, 15–65 лет (не беременна)',
      'en': 'Woman, 15–65 years (not pregnant)',
    }),
    BmPopulation.man15to65: _T({
      'uz': 'Erkak, 15–65 yosh',
      'ru': 'Мужчина, 15–65 лет',
      'en': 'Man, 15–65 years',
    }),
    BmPopulation.pregnantT1: _T({
      'uz': 'Homiladorlik, I trimestr',
      'ru': 'Беременность, I триместр',
      'en': 'Pregnancy, 1st trimester',
    }),
    BmPopulation.pregnantT2: _T({
      'uz': 'Homiladorlik, II trimestr',
      'ru': 'Беременность, II триместр',
      'en': 'Pregnancy, 2nd trimester',
    }),
    BmPopulation.pregnantT3: _T({
      'uz': 'Homiladorlik, III trimestr',
      'ru': 'Беременность, III триместр',
      'en': 'Pregnancy, 3rd trimester',
    }),
  };
  static const fieldHb = _T({
    'uz': 'Gemoglobin (Hb), g/L',
    'ru': 'Гемоглобин (Hb), г/л',
    'en': 'Haemoglobin (Hb), g/L',
  });
  static const fieldMcv = _T({
    'uz': 'MCV, fL',
    'ru': 'MCV, фл',
    'en': 'MCV, fL',
  });
  static const fieldRdw = _T({
    'uz': 'RDW-CV, %',
    'ru': 'RDW-CV, %',
    'en': 'RDW-CV, %',
  });
  static const fieldRdwUpper = _T({
    'uz': 'RDW yuqori chegarasi (laboratoriyangiz), %',
    'ru': 'Верхняя граница RDW (ваша лаборатория), %',
    'en': 'RDW upper limit (your laboratory), %',
  });
  static const rdwUpperHint = _T({
    'uz':
        'Manbada RDW uchun yagona son yo‘q — laboratoriyangiz referens '
        'oralig‘ining yuqori chegarasini kiriting (misollar: 15 % yoki '
        '14,5 %).',
    'ru':
        'Единого числа для RDW в источнике нет — введите верхнюю границу '
        'референтного интервала вашей лаборатории (примеры: 15 % или 14,5 %).',
    'en':
        'The source gives no single RDW number — enter the upper limit of '
        'your laboratory’s reference range (examples: 15% or 14.5%).',
  });
  static const fieldFerritin = _T({
    'uz': 'Ferritin, µg/L (ixtiyoriy)',
    'ru': 'Ферритин, мкг/л (необязательно)',
    'en': 'Ferritin, µg/L (optional)',
  });
  static const inflammation = _T({
    'uz': 'Infeksiya yoki yallig‘lanish bor (CRP/AGP)',
    'ru': 'Есть инфекция или воспаление (CRP/AGP)',
    'en': 'Infection or inflammation present (CRP/AGP)',
  });
  static const fieldRetic = _T({
    'uz': 'Retikulotsitlar, ×10⁹/L (ixtiyoriy)',
    'ru': 'Ретикулоциты, ×10⁹/л (необязательно)',
    'en': 'Reticulocytes, ×10⁹/L (optional)',
  });
  static const invalid = _T({
    'uz': 'Son noto‘g‘ri yoki mumkin bo‘lgan oraliqdan tashqarida',
    'ru': 'Неверное число или вне допустимого диапазона',
    'en': 'Invalid number or out of the plausible range',
  });
  static const resultTitle = _T({
    'uz': 'Natija',
    'ru': 'Результат',
    'en': 'Result',
  });
  static const emptyHint = _T({
    'uz': 'Kamida MCV ni kiriting.',
    'ru': 'Введите хотя бы MCV.',
    'en': 'Enter at least the MCV.',
  });
  static const anaemicYes = _T({
    'uz': 'Hb JSST chegarasidan past — anemiya',
    'ru': 'Hb ниже порога ВОЗ — анемия',
    'en': 'Hb below the WHO cut-off — anaemia',
  });
  static const anaemicNo = _T({
    'uz':
        'Hb JSST chegarasidan past emas — JSST bo‘yicha anemiya yo‘q (indekslar '
        'baribir ko‘rsatiladi)',
    'ru':
        'Hb не ниже порога ВОЗ — анемии по критерию ВОЗ нет (индексы всё равно '
        'показаны)',
    'en':
        'Hb not below the WHO cut-off — no anaemia by the WHO definition '
        '(indices are still shown)',
  });
  static const cutoffLabel = _T({
    'uz': 'Anemiya chegarasi (JSST 2024)',
    'ru': 'Порог анемии (ВОЗ 2024)',
    'en': 'Anaemia cut-off (WHO 2024)',
  });
  static const mcvClasses = {
    BmMcvClass.micro: _T({
      'uz': 'Mikrotsitar (MCV < 80 fL)',
      'ru': 'Микроцитарная (MCV < 80 фл)',
      'en': 'Microcytic (MCV < 80 fL)',
    }),
    BmMcvClass.normo: _T({
      'uz': 'Normotsitar (MCV 80–100 fL)',
      'ru': 'Нормоцитарная (MCV 80–100 фл)',
      'en': 'Normocytic (MCV 80–100 fL)',
    }),
    BmMcvClass.macro: _T({
      'uz': 'Makrotsitar (MCV > 100 fL)',
      'ru': 'Макроцитарная (MCV > 100 фл)',
      'en': 'Macrocytic (MCV > 100 fL)',
    }),
  };
  static const rdwHigh = _T({
    'uz': 'RDW yuqori (har xil o‘lcham)',
    'ru': 'RDW повышен (разнородный размер)',
    'en': 'RDW high (heterogeneous size)',
  });
  static const rdwNormal = _T({
    'uz': 'RDW me’yorda (bir xil o‘lcham)',
    'ru': 'RDW в норме (однородный размер)',
    'en': 'RDW normal (uniform size)',
  });
  static const rdwUnknown = _T({
    'uz':
        'RDW yoki uning yuqori chegarasi kiritilmagan — faqat MCV bo‘yicha '
        'guruh.',
    'ru': 'RDW или его верхняя граница не введены — группа только по MCV.',
    'en': 'RDW or its upper limit not entered — group by MCV only.',
  });
  static const patternTitle = _T({
    'uz': 'Morfologik guruh',
    'ru': 'Морфологическая группа',
    'en': 'Morphologic group',
  });
  static const differentialsTitle = _T({
    'uz': 'Nimaga ishora qilishi mumkin',
    'ru': 'На что может указывать',
    'en': 'What it may point to',
  });
  static const clueTitle = _T({
    'uz': 'Amaliy maslahat',
    'ru': 'Практическая подсказка',
    'en': 'Practical clue',
  });
  static const ferritinTitle = _T({
    'uz': 'Ferritin',
    'ru': 'Ферритин',
    'en': 'Ferritin',
  });
  static const ferritinLow = _T({
    'uz': 'JSST chegarasidan past — temir tanqisligiga mos',
    'ru': 'Ниже порога ВОЗ — соответствует дефициту железа',
    'en': 'Below the WHO cut-off — consistent with iron deficiency',
  });
  static const ferritinNotLow = _T({
    'uz': 'JSST chegarasidan past emas',
    'ru': 'Не ниже порога ВОЗ',
    'en': 'Not below the WHO cut-off',
  });
  static const ferritinNoCutoff = _T({
    'uz':
        'Bu guruh va holat uchun JSST 2020 jadvalida ferritin chegarasi '
        'berilmagan.',
    'ru':
        'Для этой группы и состояния порог ферритина в таблице ВОЗ 2020 не '
        'приведён.',
    'en':
        'The WHO 2020 table gives no ferritin cut-off for this group and '
        'state.',
  });
  static const ferritinInflNote = _T({
    'uz':
        'Ferritin bilan birga yallig‘lanish belgilari (CRP, AGP) baholanadi; '
        'yallig‘lanishda chegara yuqoriroq.',
    'ru':
        'Вместе с ферритином оценивают маркеры воспаления (CRP, AGP); при '
        'воспалении порог выше.',
    'en':
        'Inflammation markers (CRP, AGP) are assessed together with ferritin; '
        'the cut-off is higher with inflammation.',
  });
  static const reticTitleShort = _T({
    'uz': 'Retikulotsitlar',
    'ru': 'Ретикулоциты',
    'en': 'Reticulocytes',
  });
  static const reticBands = {
    BmReticBand.high: _T({
      'uz':
          'Taxminan > 80 ×10⁹/L — ilik javobi yetarli yoki kuchaygan (qon '
          'yo‘qotish, gemoliz yoki tiklanish).',
      'ru':
          'Примерно > 80 ×10⁹/л — ответ костного мозга адекватный или '
          'усиленный (кровопотеря, гемолиз или восстановление).',
      'en':
          'Roughly > 80 ×10⁹/L — appropriate or enhanced marrow response '
          '(blood loss, haemolysis or recovery).',
    }),
    BmReticBand.veryLow: _T({
      'uz':
          'Taxminan < 20 ×10⁹/L — og‘ir anemiya bilan bo‘lsa, eritropoez '
          'keskin susaygan (masalan, ilik yetishmovchiligi).',
      'ru':
          'Примерно < 20 ×10⁹/л — при тяжёлой анемии указывает на резкое '
          'угнетение эритропоэза (например, недостаточность костного мозга).',
      'en':
          'Roughly < 20 ×10⁹/L — with severe anaemia this suggests markedly '
          'impaired erythropoiesis (e.g. marrow failure).',
    }),
    BmReticBand.between: _T({
      'uz':
          '20–80 ×10⁹/L oralig‘ida manbadagi taxminiy mo‘ljallar qo‘llanmaydi: '
          'anemiya bo‘lsa, “me’yoriy” son ham ishlab chiqarish yetarli '
          'emasligini bildirishi mumkin — RPI ni hisoblang.',
      'ru':
          'В диапазоне 20–80 ×10⁹/л ориентиры источника не применимы: при '
          'анемии и «нормальное» число может означать недостаточную продукцию '
          '— рассчитайте RPI.',
      'en':
          'Between 20 and 80 ×10⁹/L the source’s approximate guides do not '
          'apply: with anaemia even a “normal” count may mean inadequate '
          'production — calculate the RPI.',
    }),
  };
  static const ageNote = _T({
    'uz':
        'MCV yosh va jinsga qarab farq qiladi — chegaraga yaqin qiymatlarni '
        'ehtiyotkorlik bilan talqin qiling (ayniqsa bolalarda).',
    'ru':
        'MCV зависит от возраста и пола — пограничные значения '
        'интерпретируйте осторожно (особенно у детей).',
    'en':
        'MCV varies with age and sex — interpret borderline values with '
        'caution (especially in children).',
  });
  static const redFlag = _T({
    'uz':
        'Shoshilinch belgi: anemiya + trombotsitopeniya + gemoliz belgilari '
        '(surtmada shizotsitlar) — zudlik bilan shifokorga.',
    'ru':
        'Тревожный признак: анемия + тромбоцитопения + признаки гемолиза '
        '(шизоциты в мазке) — немедленно к врачу.',
    'en':
        'Red flag: anaemia + thrombocytopenia + haemolysis (schistocytes on '
        'the film) — tell the doctor immediately.',
  });
  static const helperRefer = _T({
    'uz':
        'Bu o‘quv yordamchisi — tashxis qo‘ymaydi. Guruh faqat qayerdan '
        'qidirishni ko‘rsatadi; xulosani surtma, klinik ma’lumot va qo‘shimcha '
        'tahlillar bilan shifokor (gematolog) chiqaradi.',
    'ru':
        'Это учебный помощник — диагноз не ставит. Группа лишь подсказывает, '
        'где искать; заключение делает врач (гематолог) с учётом мазка, '
        'клиники и дополнительных анализов.',
    'en':
        'This is a learning aid — it does not diagnose. The group only shows '
        'where to look; the doctor (haematologist) draws conclusions from the '
        'film, clinical data and further tests.',
  });
  static const tableLink = _T({
    'uz': '“Anemiya: bosqichma-bosqich” jadvali',
    'ru': 'Таблица «Анемия: шаг за шагом»',
    'en': '“Anaemia: step by step” table',
  });
  static const tableLinkSub = _T({
    'uz': 'Jadvallar va algoritmlar bo‘limida',
    'ru': 'В разделе «Таблицы и алгоритмы»',
    'en': 'In Tables and algorithms',
  });
  static const quizIntro = _T({
    'uz':
        'Avval rasmlar: surtmadagi o‘zgarishni toping (4 variantdan biri). '
        'Keyin bir nechta bilim savoli. Har javobdan keyin izoh — kartadagi '
        'manbaga asoslangan.',
    'ru':
        'Сначала фото: определите изменение в мазке (один из 4 вариантов). '
        'Затем несколько вопросов на знание. После каждого ответа — пояснение '
        'по источнику карточки.',
    'en':
        'First pictures: identify the change on the film (one of 4 options). '
        'Then a few knowledge questions. Each answer is followed by an '
        'explanation from the card’s source.',
  });
  static const quizStart = _T({
    'uz': 'Boshlash',
    'ru': 'Начать',
    'en': 'Start',
  });
  static const quizPrompt = _T({
    'uz': 'Bu qaysi o‘zgarish?',
    'ru': 'Что это за изменение?',
    'en': 'Which change is this?',
  });
  static const quizImageLabel = _T({
    'uz': 'Savol rasmi: qon surtmasi mikrofotosi',
    'ru': 'Изображение к вопросу: микрофото мазка крови',
    'en': 'Question picture: blood film micrograph',
  });
}
