/// Siydik tahlili: namuna yig‘ish va saqlash, fizik xossalar, test-chiziq
/// (kimyoviy) reaksiyalari, cho‘kma mikroskopiyasi, natijani o‘qish yordamchisi
/// va mashq (3 tilda).
///
/// Har da'vo — manba va joy bilan ([UrFact], [CalcRef]); manbada yo'q narsa
/// yozilmaydi. Manbalar shu sessiyada ochib o'qilgan: JSST 2003 qo'llanmasi
/// (7-bob, 233–252-betlar), Delanghe va Speeckaert 2014 (Biochem Med, ochiq
/// maqola), AAFP 2005 va 2022 sharhlari. Manbalar bir-biridan farq qilsa —
/// ikkalasi ham ko'rsatiladi. Rasmlar — faqat mikroskopiya atlasidagi erkin
/// litsenziyali fotolar (id bo'yicha havola, nusxa olinmaydi; muallif va
/// litsenziya atlasdan o'qiladi). Rasmi yo'q element — "rasm hozircha yo'q".
/// Har sahifa boshida — bo'lim adabiyoti ("Manbalar" paneli, [urLeadRefs],
/// D-65). Manbalar jadvali: docs/URINALYSIS_SOURCES.md.
library;

import '../content/content_model.dart';
import '../tools/calc_info.dart';

typedef _T = LocalizedText;

/// Manbalar qayta tekshirilgan sana.
const urinCheckedAt = '2026-10-17';

abstract final class UrSources {
  /// JSST qo'llanmasi — ilovada allaqachon bor manba (bir xil yozuv).
  static const who2003 = CalcSources.whoBasicLab2003;
  static const delanghe2014 = CalcSource(
    id: 'urin-delanghe-2014',
    citation:
        'Delanghe J, Speeckaert M. Preanalytical requirements of urinalysis. '
        'Biochem Med (Zagreb). 2014. doi:10.11613/BM.2014.011',
    url: 'https://doi.org/10.11613/BM.2014.011',
  );
  static const simerville2005 = CalcSource(
    id: 'urin-simerville-2005',
    citation:
        'Simerville JA, Maxted WC, Pahira JJ. Urinalysis: a comprehensive '
        'review. Am Fam Physician. 2005',
    url: 'https://www.aafp.org/pubs/afp/issues/2005/0315/p1153.html',
  );
  static const hitzeman2022 = CalcSource(
    id: 'urin-hitzeman-2022',
    citation:
        'Hitzeman N, Greer D, Carpio E. Office-based urinalysis: a '
        'comprehensive review. Am Fam Physician. 2022',
    url:
        'https://www.aafp.org/pubs/afp/issues/2022/0700/'
        'office-based-urinalysis.html',
  );

  static const all = [who2003, delanghe2014, simerville2005, hitzeman2022];
}

/// Bo'lim asoslangan adabiyot — sahifa boshidagi "Manbalar" paneli (D-65).
const urLeadRefs = [
  CalcRef(UrSources.who2003, 'Ch. 7 Examination of urine, p. 233–252'),
  CalcRef(UrSources.delanghe2014, ''),
  CalcRef(UrSources.simerville2005, ''),
  CalcRef(UrSources.hitzeman2022, ''),
];

// ───────────────────────── Lokatorlar ─────────────────────────

const _w = UrSources.who2003;
const _d = UrSources.delanghe2014;
const _a05 = UrSources.simerville2005;
const _a22 = UrSources.hitzeman2022;

const _wTypes = CalcRef(_w, '7.1.1 Types of urine specimen, p. 233');
const _wInfant = CalcRef(_w, '7.1.1 Urine specimens from infants, p. 234');
const _wContainer = CalcRef(_w, '7.1 Collection of urine specimens, p. 233');
const _wAppearance = CalcRef(_w, '7.2.1 Appearance, p. 234');
const _wBlood = CalcRef(_w, '7.2.2 Testing for the presence of blood, p. 234');
const _wPh = CalcRef(_w, '7.2.3 Measuring the pH, p. 235');
const _wPhCrystals = CalcRef(_w, '7.2.3 pH and crystalline deposits, p. 236');
const _wGlucose = CalcRef(_w, '7.2.4 Detection of glucose, p. 236');
const _wProtein = CalcRef(
  _w,
  '7.2.5 Detection and estimation of protein, p. 236–238',
);
const _wKetones = CalcRef(_w, '7.2.6 Detection of ketone bodies, p. 239');
const _wCollectMicro = CalcRef(_w, '7.2.7 Collection of specimens, p. 241');
const _wMicroscopy = CalcRef(_w, '7.2.7 Microscopic examination, p. 241');
const _wRbc = CalcRef(_w, '7.2.7 Erythrocytes, Fig. 7.9, p. 241–242');
const _wWbc = CalcRef(_w, '7.2.7 Leukocytes, Fig. 7.10, p. 242');
const _wPelvic = CalcRef(
  _w,
  '7.2.7 Ureteral and renal pelvic cells, Fig. 7.11, p. 242',
);
const _wRenalCells = CalcRef(_w, '7.2.7 Renal cells, Fig. 7.12, p. 243');
const _wCasts = CalcRef(_w, '7.2.7 Casts, Figs 7.13–7.19, p. 243');
const _wFalseCasts = CalcRef(
  _w,
  '7.2.7 False casts; Miscellaneous foreign substances, p. 244',
);
const _wCrystals = CalcRef(_w, '7.2.7 Crystals, Figs 7.22–7.25, p. 245');
const _wAmorphous = CalcRef(
  _w,
  '7.2.7 Urates; Amorphous debris, Figs 7.26, 7.30–7.31, p. 246–247',
);
const _wRareCrystals = CalcRef(
  _w,
  '7.2.7 Other crystalline deposits, Figs 7.32–7.33, p. 247',
);
const _wDrugCrystals = CalcRef(_w, '7.2.7 Acetyl sulfonamides, p. 248');
const _wFungi = CalcRef(_w, '7.2.7 Fungi, Fig. 7.35, p. 248');
const _wEggs = CalcRef(_w, '7.2.7 Parasite eggs and larvae, p. 248');
const _wSchisto = CalcRef(
  _w,
  '7.2.8 Detection of Schistosoma haematobium infection, p. 249–251',
);
const _wBacteria = CalcRef(_w, '7.2.9 Detection of bacteria, p. 251–252');

const _dPrecautions = CalcRef(_d, 'Which precautions should be implemented?');
const _dSampling = CalcRef(_d, 'Which sampling procedure to choose?');
const _dContainer = CalcRef(_d, 'Which sampling container is preferable?');
const _dTime = CalcRef(
  _d,
  'Transport and preservation: Is it a matter of time?',
);
const _dPreserv = CalcRef(_d, 'Use of preservatives: why, which and when?');
const _dStrip = CalcRef(
  _d,
  'Interfering effect of different urine components on test strip analyses',
);
const _dParticles = CalcRef(_d, 'Particle analysis');
const _dManual = CalcRef(_d, 'Manual methods');
const _dQuality = CalcRef(
  _d,
  'Optimal urine quality management in a routine clinical laboratory',
);
const _dSummary = CalcRef(_d, 'Summary');

const _a05Collect = CalcRef(_a05, 'Specimen Collection');
const _a05Colour = CalcRef(
  _a05,
  'Physical Properties: Color and Odor; Table 1',
);
const _a05Table2 = CalcRef(_a05, 'Dipstick Urinalysis; Table 2');
const _a05Table3 = CalcRef(_a05, 'Table 3');
const _a05Sg = CalcRef(_a05, 'Specific Gravity');
const _a05Hematuria = CalcRef(_a05, 'Hematuria');
const _a05GlomUro = CalcRef(
  _a05,
  'Glomerular, Renal (Nonglomerular) and Urologic Hematuria',
);
const _a05Protein = CalcRef(_a05, 'Proteinuria');
const _a05Ketones = CalcRef(_a05, 'Ketonuria');
const _a05Nitrite = CalcRef(_a05, 'Nitrites');
const _a05Le = CalcRef(_a05, 'Leukocyte Esterase');
const _a05Bili = CalcRef(_a05, 'Bilirubin and Urobilinogen');
const _a05Cells = CalcRef(_a05, 'Microscopic Urinalysis: Cells');
const _a05Casts = CalcRef(_a05, 'Casts; Table 6');
const _a05Crystals = CalcRef(_a05, 'Crystals');
const _a05Bacteria = CalcRef(_a05, 'Bacteriuria');

const _a22Collect = CalcRef(_a22, 'Specimen Collection');
const _a22Sort = CalcRef(_a22, 'SORT: Key Recommendations for Practice');
const _a22Wisely = CalcRef(_a22, 'Best Practices in Urology (Choosing Wisely)');
const _a22Setup = CalcRef(_a22, 'Setting Up In-Office Urinalysis');
const _a22Look = CalcRef(_a22, 'Visual Appearance and Odor; Table 1');
const _a22Dip = CalcRef(_a22, 'Dipstick Urinalysis');
const _a22Table2 = CalcRef(_a22, 'Table 2');
const _a22Table3 = CalcRef(_a22, 'Table 3');
const _a22Sg = CalcRef(_a22, 'Urine Specific Gravity');
const _a22Ph = CalcRef(_a22, 'Urinary pH');
const _a22Bili = CalcRef(_a22, 'Bilirubin and Urobilinogen');
const _a22Glucose = CalcRef(_a22, 'Glucose');
const _a22Ketones = CalcRef(_a22, 'Ketones');
const _a22Protein = CalcRef(_a22, 'Protein; Table 4');
const _a22LeNitrite = CalcRef(_a22, 'Leukocyte Esterase and Nitrites');
const _a22Blood = CalcRef(_a22, 'Blood');
const _a22Rbc = CalcRef(_a22, 'Red Blood Cells');
const _a22Wbc = CalcRef(_a22, 'White Blood Cells');
const _a22Epi = CalcRef(_a22, 'Epithelial Cells');
const _a22Bacteria = CalcRef(_a22, 'Bacteria');
const _a22CrystCasts = CalcRef(_a22, 'Crystals and Casts; eFigures A–B');

// ───────────────────────── Model ─────────────────────────

/// Bitta da'vo va uning manbalari.
class UrFact {
  const UrFact(this.text, this.refs);

  final LocalizedText text;
  final List<CalcRef> refs;
}

/// Bir nechta da'voning manbalari, takrorsiz (tartib bilan).
List<CalcRef> urRefsOf(Iterable<UrFact> facts) {
  final seen = <String>{};
  return [
    for (final f in facts)
      for (final r in f.refs)
        if (seen.add('${r.source.id}|${r.locator}')) r,
  ];
}

/// Sarlavhali bo'lim (yig'ish, fizik xossalar ekranlari).
class UrSection {
  const UrSection(this.title, this.facts);

  final LocalizedText title;
  final List<UrFact> facts;
}

/// Test-chiziq maydonchasi (pH, oqsil...).
class UrPad {
  const UrPad({
    required this.id,
    required this.name,
    required this.detects,
    required this.mayPoint,
    this.falsePos,
    this.falseNeg,
    this.next,
  });

  final String id;
  final LocalizedText name;

  /// Nimani aniqlaydi / me'yor.
  final UrFact detects;

  /// Musbat (o'zgargan) natija nimaga ishora qilishi mumkin.
  final UrFact mayPoint;
  final UrFact? falsePos;
  final UrFact? falseNeg;

  /// Tasdiqlash / keyingi qadam.
  final UrFact? next;

  List<UrFact> get facts => [detects, mayPoint, ?falsePos, ?falseNeg, ?next];
}

enum UrGroup { cells, casts, crystals, organisms }

/// Mikroskopiya atlasidagi rasm (id bo'yicha havola). [atlasEntity] — atlasdagi
/// tur id'si: test rasm nomi karta nomiga mosligini shu orqali tekshiradi.
/// [panel] — ko'p panelli jurnal rasmida qaysi panel shu elementga tegishli.
class UrPic {
  const UrPic(this.atlasId, this.atlasEntity, {this.panel});

  final String atlasId;
  final String atlasEntity;
  final LocalizedText? panel;
}

/// Cho'kma elementi kartasi.
class UrElement {
  const UrElement({
    required this.id,
    required this.group,
    required this.name,
    required this.look,
    required this.meaning,
    this.confuse,
    this.pics = const [],
    this.quiz = false,
  });

  final String id;
  final UrGroup group;
  final LocalizedText name;

  /// Mikroskopda qanday ko'rinadi.
  final List<UrFact> look;

  /// Nimaga ishora qilishi mumkin (tashxis emas).
  final UrFact meaning;

  /// Nima bilan adashtiriladi / qo'shimcha eslatma.
  final UrFact? confuse;

  /// Atlasdagi rasmlar; birinchisi kartada ko'rsatiladi. Bo'sh — "rasm
  /// hozircha yo'q".
  final List<UrPic> pics;

  /// "Bu nima?" mashqiga kiradimi (rasm atlasda mashq uchun yaroqli
  /// bo'lsa).
  final bool quiz;

  List<UrFact> get facts => [...look, meaning, ?confuse];

  List<CalcRef> get refs => urRefsOf(facts);
}

// ───────────────────────── 1. Yig'ish va saqlash ─────────────────────────

const urCollectSections = <UrSection>[
  UrSection(
    _T({'uz': 'Namuna turlari', 'ru': 'Виды проб', 'en': 'Types of specimen'}),
    [
      UrFact(
        _T({
          'uz':
              'Ertalabki birinchi siydik — eng quyuq namuna. Tasodifiy namuna '
              'kunning istalgan vaqtida olinadi (skrining uchun). O‘rta '
              'porsiya: oqim davomida ochiq idishga taxminan 20 ml olinadi va '
              'idish darhol yopiladi. Oxirgi (terminal) porsiya — siydikning '
              'oxirgi qismi.',
          'ru':
              'Первая утренняя моча — самая концентрированная проба. Разовую '
              '(случайную) пробу берут в любое время суток (для скрининга). '
              'Средняя порция: во время мочеиспускания в открытую ёмкость '
              'собирают около 20 мл и сразу закрывают. Терминальная порция — '
              'последняя часть мочи.',
          'en':
              'First morning urine is the most concentrated sample. A random '
              'sample is taken at any time of day (for screening). Midstream: '
              'about 20 ml is caught in an open container during voiding and '
              'the container is closed at once. Terminal urine is the last '
              'portion voided.',
        }),
        [_wTypes],
      ),
      UrFact(
        _T({
          'uz':
              '24 soatlik siydik: birinchi kuni ertalabki siydik to‘kib '
              'yuboriladi, keyingi kun va tundagi butun siydik hamda ertasi '
              'kungi ertalabki birinchi siydik yig‘iladi; idish darhol '
              'laboratoriyaga keltiriladi va hajmi o‘lchab yoziladi.',
          'ru':
              'Суточная моча: в первый день утреннюю мочу выливают, затем '
              'собирают всю мочу за день и ночь и первую утреннюю порцию '
              'следующего дня; ёмкость сразу доставляют в лабораторию, объём '
              'измеряют и записывают.',
          'en':
              '24-hour urine: the first morning void of day 1 is discarded; '
              'all urine for the rest of the day and night is collected, plus '
              'the first morning void of the next day; the bottle goes to the '
              'laboratory at once and the volume is measured and recorded.',
        }),
        [_wTypes],
      ),
      UrFact(
        _T({
          'uz':
              'Amalda ko‘pincha ertalabki birinchi siydikning o‘rta porsiyasi '
              'olinadi. Ammo tunda qovuqda bakteriyalar ko‘payib, silindr va '
              'hujayralarga ta’sir qilishi mumkin — shuning uchun ba’zan '
              'ikkinchi ertalabki siydik (birinchisidan 2–4 soat keyin) tavsiya '
              'etiladi. Birinchi tushgan porsiyada epiteliy, eritrotsit va '
              'leykotsitlar ko‘proq; o‘rta porsiya eng maqbul namuna sifatida '
              'tasdiqlangan.',
          'ru':
              'На практике чаще берут среднюю порцию первой утренней мочи. '
              'Однако за ночь в мочевом пузыре могут размножиться бактерии, '
              'что влияет на цилиндры и клетки, — поэтому иногда рекомендуют '
              'вторую утреннюю мочу (через 2–4 часа после первой). В первой '
              'струе больше эпителия, эритроцитов и лейкоцитов; средняя '
              'порция подтверждена как наиболее подходящая проба.',
          'en':
              'In practice the midstream portion of the first morning urine '
              'is usually taken. Overnight bacterial growth in the bladder can '
              'affect casts and cells, so a second morning urine (voided 2–4 h '
              'after the first) is sometimes recommended. The first-voided '
              'portion contains more epithelial cells, red and white cells; '
              'midstream urine was confirmed as the most appropriate sample.',
        }),
        [_dSampling],
      ),
      UrFact(
        _T({
          'uz':
              'Eritrotsitlar shaklini baholash uchun ertalabki siydik afzal: '
              'shakl osmolyallik va pH ga bog‘liq.',
          'ru':
              'Для оценки формы эритроцитов предпочтительна утренняя моча: '
              'форма зависит от осмоляльности и pH.',
          'en':
              'Morning urine is preferred for red-cell morphology, because '
              'the shape depends on osmolality and pH.',
        }),
        [_dParticles],
      ),
      UrFact(
        _T({
          'uz':
              'Nitrit hosil bo‘lishi uchun bakteriyalar qovuqda taxminan 4 soat '
              'turishi kerak: tez-tez siyganda (go‘daklarda ham) nitrit '
              'testi ko‘pincha soxta manfiy bo‘ladi.',
          'ru':
              'Чтобы образовались нитриты, бактериям нужно около 4 часов в '
              'мочевом пузыре: при частом мочеиспускании (в том числе у '
              'младенцев) нитритный тест часто ложноотрицательный.',
          'en':
              'Bacteria need about four hours in the bladder to produce '
              'nitrite, so false-negative nitrite results are common with '
              'frequent voiding, including in infants.',
        }),
        [_a22LeNitrite],
      ),
      UrFact(
        _T({
          'uz':
              'Go‘daklar: yopishqoq og‘izli plastik qopcha jinsiy a’zo atrofiga '
              'yopishtiriladi va 1–3 soat qoldiriladi. Qopchadagi siydik '
              'dastlabki tahlil uchun yaroqli, lekin ekma uchun tavsiya '
              'etilmaydi; leykotsitar esteraza yoki nitrit musbat chiqsa — '
              'kateter yoki suprapubik punksiya bilan toza namuna olinadi.',
          'ru':
              'Младенцы: пластиковый мочеприёмник с клейким краем фиксируют '
              'вокруг половых органов на 1–3 часа. Моча из мочеприёмника '
              'пригодна для первичного анализа, но не рекомендуется для '
              'посева; при положительной лейкоцитарной эстеразе или нитритах '
              'берут чистую пробу катетером или надлобковой пункцией.',
          'en':
              'Infants: a plastic bag with an adhesive mouth is fixed around '
              'the genitalia for 1–3 hours. A bag specimen is acceptable for '
              'the initial urinalysis but not recommended for culture; if '
              'leukocyte esterase or nitrite is positive, a clean sample is '
              'taken by catheter or suprapubic aspiration.',
        }),
        [_wInfant, _a22Collect, _a22Sort],
      ),
      UrFact(
        _T({
          'uz':
              'Jinsiy yo‘l bilan yuqadigan infeksiyalarni (NAAT) aniqlash '
              'uchun yuvilmasdan olingan ertalabki birinchi oqim o‘rta '
              'porsiyadan yaxshiroq; siydik yo‘li infeksiyasi uchun esa o‘rta '
              'porsiya olinadi.',
          'ru':
              'Для выявления ИППП (NAAT) первая утренняя порция без '
              'подмывания лучше средней порции; для диагностики инфекции '
              'мочевых путей берут среднюю порцию.',
          'en':
              'For sexually transmitted infection testing (NAAT), a first '
              'morning first-void sample without cleansing performs better '
              'than midstream urine; midstream clean-catch is used for '
              'urinary tract infection.',
        }),
        [_a22Wbc],
      ),
      UrFact(
        _T({
          'uz':
              'Shistosomoz (Schistosoma haematobium) tuxumlari soni 10:00–14:00 '
              'oralig‘ida eng ko‘p: shu vaqtda kamida 10 ml terminal porsiya '
              'olinadi va butun namuna ko‘riladi.',
          'ru':
              'Число яиц Schistosoma haematobium максимально с 10:00 до 14:00: '
              'в это время берут не менее 10 мл терминальной порции и '
              'исследуют всю пробу.',
          'en':
              'Schistosoma haematobium egg output peaks between 10:00 and '
              '14:00: collect a terminal urine of at least 10 ml in that window '
              'and examine the whole specimen.',
        }),
        [_wSchisto],
      ),
    ],
  ),
  UrSection(
    _T({
      'uz': 'Gigiyena va idish',
      'ru': 'Гигиена и ёмкость',
      'en': 'Cleansing and container',
    }),
    [
      UrFact(
        _T({
          'uz':
              'Manbalar farq qiladi. JSST (2003): bakteriologik tekshiruvdan '
              'oldin jinsiy a’zolar sovun va suv bilan yuviladi, o‘rta porsiya '
              'steril idishga olinadi. Delanghe (2014): erkaklarda olat boshi, '
              'ayollarda qin dahlizini yuvish soxta musbat ekmalarni taxminan '
              '20 % ga kamaytiradi, lekin sovun va antiseptiklar bakteriyalar '
              'hayotchanligiga ta’sir qilgani uchun tavsiya etilmaydi. '
              'Laboratoriyangiz SOP iga amal qiling.',
          'ru':
              'Источники расходятся. ВОЗ (2003): перед бактериологическим '
              'исследованием половые органы моют водой с мылом, среднюю '
              'порцию собирают в стерильную ёмкость. Delanghe (2014): '
              'обмывание головки полового члена у мужчин и преддверия '
              'влагалища у женщин снижает число ложноположительных посевов '
              'примерно на 20 %, но мыло и антисептики не рекомендуются, так '
              'как влияют на жизнеспособность бактерий. Следуйте СОП вашей '
              'лаборатории.',
          'en':
              'Sources differ. WHO (2003): before bacteriological testing the '
              'genitals are washed with soap and water and a midstream sample '
              'is caught in a sterile flask. Delanghe (2014): washing the glans '
              'penis or the vaginal introitus cuts false-positive cultures by '
              'about 20%, but soap and antiseptics are not recommended because '
              'they affect bacterial viability. Follow your laboratory’s SOP.',
        }),
        [_wBacteria, _dPrecautions],
      ),
      UrFact(
        _T({
          'uz':
              'AAFP sharhlari: 2005-yilgi tadqiqotda yuvib va yuvmasdan '
              'olingan namunalarda ifloslanish darajasi o‘xshash bo‘lgan '
              '(32 % va 29 %); 2022-yilda Amerika mikrobiologiya jamiyati '
              'imkon bo‘lsa yuvib, o‘rta porsiya olishni tavsiya qiladi — '
              'foydasi isbotlanmagan bo‘lsa ham.',
          'ru':
              'Обзоры AAFP: в исследовании, приведённом в 2005 г., частота '
              'загрязнения проб с подмыванием и без него была сходной (32 % и '
              '29 %); в 2022 г. Американское общество микробиологии '
              'рекомендует по возможности подмываться и брать среднюю порцию, '
              'хотя польза не доказана.',
          'en':
              'AAFP reviews: a study cited in 2005 found similar contamination '
              'rates with and without prior cleansing (32% vs 29%); in 2022 the '
              'American Society for Microbiology recommends midstream '
              'collection with cleansing when possible, despite a lack of '
              'evidence that it reduces contamination.',
        }),
        [_a05Collect, _a22Collect],
      ),
      UrFact(
        _T({
          'uz':
              'Idish keng og‘izli, toza va quruq bo‘lsin; ekma uchun — steril. '
              'Yorug‘likka sezgir moddalar (urobilinogen, porfirinlar) uchun '
              'jigarrang (qorong‘i) idish kerak.',
          'ru':
              'Ёмкость — с широким горлом, чистая и сухая; для посева — '
              'стерильная. Для светочувствительных веществ (уробилиноген, '
              'порфирины) нужна ёмкость из тёмного (янтарного) материала.',
          'en':
              'Containers should be wide-mouthed, clean and dry; sterile for '
              'culture. Light-sensitive analytes (urobilinogen, porphyrins) '
              'need amber containers.',
        }),
        [_wContainer, _dContainer],
      ),
      UrFact(
        _T({
          'uz':
              'Vakuumli quyish naychalari kimyoviy tahlil uchun yaroqli, lekin '
              'cho‘kma (zarrachalar) tahlili uchun tavsiya etilmaydi: bosim '
              'farqi silindrlarni parchalaydi (gialin silindrlar kamida 58 %, '
              'hujayrali silindrlar 51 % ga kamaygan).',
          'ru':
              'Вакуумные пробирки для переноса пригодны для химического '
              'анализа, но не рекомендуются для анализа осадка: перепад '
              'давления разрушает цилиндры (гиалиновых — минимум на 58 %, '
              'клеточных — на 51 % меньше).',
          'en':
              'Vacuum transfer tubes are fine for chemistry but not '
              'recommended for particle analysis: the pressure difference '
              'breaks casts (hyaline casts reduced by at least 58%, cellular '
              'casts by 51%).',
        }),
        [_dContainer],
      ),
      UrFact(
        _T({
          'uz':
              'Bitta namunadan ham test-chiziq, ham ekma qilinsa, test-chiziqni '
              'siydikka botirmang — siydikni chiziqqa tomizing: chiziqdagi '
              'moddalar namunani ifloslantiradi. Botirish faqat alohida '
              'ulushda mumkin.',
          'ru':
              'Если из одной пробы делают и тест-полоску, и посев, не '
              'погружайте полоску в мочу — нанесите мочу на полоску: '
              'компоненты полоски загрязняют пробу. Погружать можно только в '
              'отдельную аликвоту.',
          'en':
              'If the same sample is used for a strip and for culture, do not '
              'dip the strip — apply urine to the strip: strip constituents '
              'contaminate the sample. Dipping is acceptable only in a separate '
              'aliquot.',
        }),
        [_dPreserv],
      ),
    ],
  ),
  UrSection(
    _T({
      'uz': 'Vaqt, sovutish, konservantlar',
      'ru': 'Время, охлаждение, консерванты',
      'en': 'Time, refrigeration, preservatives',
    }),
    [
      UrFact(
        _T({
          'uz':
              'JSST: pH yig‘ilgandan keyin 1 soat ichida o‘lchanadi; '
              'mikroskopiya uchun siydik yangi chiqarilgan bo‘lishi kerak.',
          'ru':
              'ВОЗ: pH определяют в течение 1 часа после сбора; для '
              'микроскопии моча должна быть свежевыпущенной.',
          'en':
              'WHO: test the pH within 1 hour of collection; urine for '
              'microscopy must be freshly passed.',
        }),
        [_wPh, _wCollectMicro],
      ),
      UrFact(
        _T({
          'uz':
              'Yevropa siydik tahlili qo‘llanmasi (Delanghe bayoni bo‘yicha): '
              'cho‘kma zarrachalari xona haroratida 1 soatdan kechiktirmay, '
              'sovutilganda — 4 soatgacha ko‘riladi.',
          'ru':
              'Европейское руководство по анализу мочи (в изложении '
              'Delanghe): частицы осадка исследуют не позже 1 часа при '
              'комнатной температуре или до 4 часов при охлаждении.',
          'en':
              'European urinalysis guidelines (as summarised by Delanghe): '
              'examine particles within 1 hour of voiding at room temperature, '
              'or within 4 hours if refrigerated.',
        }),
        [_dParticles],
      ),
      UrFact(
        _T({
          'uz':
              'Darhol tekshirib bo‘lmasa, siydik sovutiladi: 2 soatdan ortiq '
              'kechikish ko‘pincha natijani ishonchsiz qiladi. 2 soat ichida '
              'tahlil qilinmaydigan namunaga harorat nazorati yoki konservant '
              'bo‘lmasa, sifat pasayadi. Yig‘ish vaqti va me’yordan oshgan '
              'kechikish yozib qo‘yiladi.',
          'ru':
              'Если исследовать сразу нельзя, мочу охлаждают: задержка более '
              '2 часов часто делает результат ненадёжным. Без контроля '
              'температуры или консерванта качество пробы, не исследованной '
              'в течение 2 часов, снижается. Время сбора и превышение сроков '
              'документируют.',
          'en':
              'If urine cannot be examined promptly it is refrigerated: delays '
              'of more than 2 hours often make results unreliable. Without '
              'temperature control or a preservative, quality falls for '
              'samples not analysed within 2 hours. Record the collection time '
              'and any delay beyond the limits.',
        }),
        [_a05Collect, _dTime],
      ),
      UrFact(
        _T({
          'uz':
              'Test-chiziq uchun: namuna sovutilgan va 24 soat ichida '
              'tekshirilsa, konservant kerak emas. Muzlatish sovutishning '
              'o‘rnini bosmaydi.',
          'ru':
              'Для тест-полосок: если проба охлаждена и исследуется в течение '
              '24 часов, консервант не нужен. Замораживание не заменяет '
              'охлаждение.',
          'en':
              'For strip tests: no preservative is needed if the sample is '
              'refrigerated and tested within 24 hours. Freezing is not an '
              'alternative to refrigeration.',
        }),
        [_dPreserv],
      ),
      UrFact(
        _T({
          'uz':
              'Sovutilgan siydikda tuzlar (fosfatlar, uratlar) cho‘kadi — '
              'mikroskopiya uchun yaroqsiz bo‘lishi mumkin; kristallar kerak '
              'bo‘lsa, sovutilmagan alohida ulush olinadi. Sovutilgan namuna '
              'tahlildan oldin xona haroratiga keltirilib, yaxshi aralashtiriladi.',
          'ru':
              'В охлаждённой моче выпадают соли (фосфаты, ураты) — она может '
              'быть непригодна для микроскопии; если нужны кристаллы, берут '
              'отдельную неохлаждённую аликвоту. Перед анализом охлаждённую '
              'пробу доводят до комнатной температуры и хорошо перемешивают.',
          'en':
              'Refrigerated urine precipitates salts (phosphates, urates) and '
              'may be unsuitable for microscopy; if crystals are requested, '
              'keep a separate non-refrigerated aliquot. Bring refrigerated '
              'samples to room temperature and mix well before analysis.',
        }),
        [_wCollectMicro, _dParticles, _dQuality],
      ),
      UrFact(
        _T({
          'uz':
              'Turib qolgan siydikda: ishqoriy pH, past nisbiy zichlik va '
              'osmolyallik zarrachalarni tez lizlaydi; xona haroratida bir '
              'necha soat turgan siydikda nitrit soxta musbat bo‘lishi '
              'mumkin; kechikish ketonlarni soxta manfiy qiladi.',
          'ru':
              'В постоявшей моче: щелочной pH, низкая плотность и '
              'осмоляльность быстро лизируют частицы; после нескольких часов '
              'при комнатной температуре нитриты могут быть '
              'ложноположительными; задержка даёт ложноотрицательные кетоны.',
          'en':
              'In standing urine: alkaline pH, low specific gravity and '
              'osmolality lyse particles quickly; several hours at room '
              'temperature can give a false-positive nitrite; delay gives '
              'false-negative ketones.',
        }),
        [_dPreserv, _dStrip, _a22Table2],
      ),
      UrFact(
        _T({
          'uz':
              'Konservantlar: 300 ml siydikka 8–10 tomchi 10 % formaldegid '
              'cho‘kmani mikroskopiya uchun saqlaydi, lekin bunday siydik '
              'boshqa testlarga yaroqsiz. Bor kislotasi pH ni 7 dan past '
              'ushlaydi va oqsil, leykotsit, keton maydonchalarida soxta '
              'manfiy natija beradi. Delanghe kimyoviy konservant o‘rniga '
              'sovutishni tavsiya qiladi.',
          'ru':
              'Консерванты: 8–10 капель 10 % формальдегида на 300 мл мочи '
              'сохраняют осадок для микроскопии, но такая моча непригодна для '
              'других тестов. Борная кислота держит pH ниже 7 и даёт '
              'ложноотрицательные белок, лейкоциты и кетоны на полоске. '
              'Delanghe рекомендует охлаждение вместо химических консервантов.',
          'en':
              'Preservatives: 8–10 drops of 10% formaldehyde per 300 ml '
              'preserve the deposit for microscopy, but such urine is '
              'unsuitable for other tests. Boric acid keeps the pH below 7 and '
              'gives false-negative strip protein, white cells and ketones. '
              'Delanghe recommends refrigeration rather than chemical '
              'preservatives.',
        }),
        [_wCollectMicro, _dPreserv, _dSummary],
      ),
    ],
  ),
];

// ───────────────────────── 2. Fizik xossalar ─────────────────────────

const urPhysicalSections = <UrSection>[
  UrSection(
    _T({
      'uz': 'Rangi va tiniqligi',
      'ru': 'Цвет и прозрачность',
      'en': 'Colour and clarity',
    }),
    [
      UrFact(
        _T({
          'uz':
              'Me’yorda siydik tiniq, somon-sariq rangda (rangi uroxromdan); '
              'quyuq siydik to‘q sariq, ba’zan rangsiz bo‘ladi. JSST natijani '
              'shunday yozadi: tiniq yoki loyqa; rangsiz, och sariq, to‘q '
              'sariq yoki jigarrang.',
          'ru':
              'В норме моча прозрачная, соломенно-жёлтая (цвет — от '
              'урохрома); концентрированная — тёмно-жёлтая, иногда моча '
              'бесцветная. ВОЗ рекомендует записывать: прозрачная или мутная; '
              'бесцветная, бледно-жёлтая, тёмно-жёлтая или коричневая.',
          'en':
              'Normal urine is clear and straw-yellow (the colour comes from '
              'urochrome); concentrated urine is dark yellow, and urine is '
              'occasionally colourless. WHO reports appearance as clear or '
              'cloudy; colourless, pale yellow, deep yellow or brown.',
        }),
        [_wAppearance, _a22Look],
      ),
      UrFact(
        _T({
          'uz':
              'Loyqalik: qon hujayralari yoki ortiqcha tuzlar; ko‘pincha '
              'ishqoriy siydikda cho‘kkan fosfatlar, lekin piuriya ham bo‘lishi '
              'mumkin. Loyqa ko‘rinish infeksiya ehtimolini oshiradi (LR+ ≈ 3).',
          'ru':
              'Мутность: клетки крови или избыток солей; часто — выпавшие '
              'фосфаты в щелочной моче, но возможна и пиурия. Мутный вид '
              'повышает вероятность инфекции (LR+ ≈ 3).',
          'en':
              'Cloudiness: blood cells or excess salts; often precipitated '
              'phosphates in alkaline urine, but pyuria is also possible. A '
              'cloudy appearance raises the likelihood of infection (LR+ ≈ 3).',
        }),
        [_wAppearance, _a05Colour, _a22Table3],
      ),
      UrFact(
        _T({
          'uz':
              'Qizil: gematuriya, gemoglobinuriya, miyoglobinuriya; ovqat — '
              'lavlagi, maymunjon, rovoch; dorilar — fenotiazinlar, fenitoin, '
              'senna. Qaysi biri ekanini test-chiziq va mikroskopiya ajratadi.',
          'ru':
              'Красный: гематурия, гемоглобинурия, миоглобинурия; пища — '
              'свёкла, ежевика, ревень; лекарства — фенотиазины, фенитоин, '
              'сенна. Различить помогают тест-полоска и микроскопия.',
          'en':
              'Red: haematuria, haemoglobinuria, myoglobinuria; foods — beets, '
              'blackberries, rhubarb; drugs — phenothiazines, phenytoin, senna. '
              'The strip and microscopy tell these apart.',
        }),
        [_a22Look, _a05Hematuria],
      ),
      UrFact(
        _T({
          'uz':
              'To‘q sariq: o‘t pigmentlari, chaqaloqlarda siydik kislotasi; '
              'sabzi, fenazopiridin, rifampitsin, sulfasalazin.',
          'ru':
              'Оранжевый: жёлчные пигменты, мочевая кислота у новорождённых; '
              'морковь, феназопиридин, рифампицин, сульфасалазин.',
          'en':
              'Orange: bile pigments, uric acid in newborns; carrots, '
              'phenazopyridine, rifampicin, sulfasalazine.',
        }),
        [_a22Look],
      ),
      UrFact(
        _T({
          'uz':
              'Jigarrang yoki qora-jigarrang: o‘t pigmentlari, miyoglobin, '
              'methemoglobin, melanin, porfiriya; dukkakli (fava) loviya, '
              'levodopa, metronidazol, nitrofurantoin, metildopa, senna.',
          'ru':
              'Коричневый или буро-чёрный: жёлчные пигменты, миоглобин, '
              'метгемоглобин, меланин, порфирия; конские бобы (фава), '
              'леводопа, метронидазол, нитрофурантоин, метилдопа, сенна.',
          'en':
              'Brown or brownish-black: bile pigments, myoglobin, '
              'methaemoglobin, melanin, porphyria; fava beans, levodopa, '
              'metronidazole, nitrofurantoin, methyldopa, senna.',
        }),
        [_a22Look, _wAppearance],
      ),
      UrFact(
        _T({
          'uz':
              'Yashil yoki ko‘k: biliverdin, Pseudomonas; metilen ko‘ki, '
              'amitriptilin, propofol, triamteren, indometatsin.',
          'ru':
              'Зелёный или синий: биливердин, Pseudomonas; метиленовый синий, '
              'амитриптилин, пропофол, триамтерен, индометацин.',
          'en':
              'Green or blue: biliverdin, Pseudomonas; methylene blue, '
              'amitriptyline, propofol, triamterene, indometacin.',
        }),
        [_a22Look],
      ),
      UrFact(
        _T({
          'uz':
              'Oq yoki sutsimon: xilus, lipidlar, infeksiya, fosfatlar, '
              'oksalatlar; propofol. Binafsha: uzoq turgan kateter qopchasida '
              'bakteriyalar metabolitlari. Ko‘pikli: suvsizlanish, aniq '
              'proteinuriya.',
          'ru':
              'Белая или молочная: хилурия, липиды, инфекция, фосфаты, '
              'оксалаты; пропофол. Фиолетовая: метаболиты бактерий в мешке '
              'длительно стоящего катетера. Пенистая: обезвоживание, '
              'выраженная протеинурия.',
          'en':
              'White or milky: chyle, lipids, infection, phosphates, oxalates; '
              'propofol. Purple: bacterial metabolites in a long-term catheter '
              'bag. Foamy: dehydration, frank proteinuria.',
        }),
        [_a22Look],
      ),
    ],
  ),
  UrSection(_T({'uz': 'Hidi', 'ru': 'Запах', 'en': 'Odour'}), [
    UrFact(
      _T({
        'uz':
            'Quyuq siydikning hidi kuchli bo‘lishi mumkin — bu infeksiyani '
            'anglatmaydi. Meva yoki shirin hid — diabetik ketoatsidozga, '
            'ammiak yoki badbo‘y hid — siydik yo‘li infeksiyasi yoki '
            'infeksiyalangan toshga, najas hidi — oqma (fistula) ga ishora '
            'qilishi mumkin; oltingugurtsimon hid sulfanilamid yoki '
            'sarsabil (asparagus) dan bo‘lishi mumkin.',
        'ru':
            'Концентрированная моча может сильно пахнуть — это не означает '
            'инфекцию. Фруктовый или сладкий запах может указывать на '
            'диабетический кетоацидоз, запах аммиака или зловонный — на '
            'инфекцию мочевых путей или инфицированный камень, каловый — на '
            'свищ; серный запах бывает от сульфаниламидов или спаржи.',
        'en':
            'Concentrated urine can smell strong without implying infection. '
            'A fruity or sweet odour may point to diabetic ketoacidosis, an '
            'ammonia-like or foul odour to urinary infection or an infected '
            'stone, a faecal odour to a fistula; a sulfur-like odour can '
            'follow sulfa drugs or asparagus.',
      }),
      [_a05Colour, _a22Look],
    ),
  ]),
  UrSection(
    _T({
      'uz': 'Nisbiy zichlik',
      'ru': 'Относительная плотность',
      'en': 'Specific gravity',
    }),
    [
      UrFact(
        _T({
          'uz':
              'Me’yor 1,003–1,030. 1,010 dan past — nisbatan ko‘p suyuqlik, '
              '1,020 dan yuqori — nisbiy suvsizlanish. Buyrak to‘qimasi '
              'yetishmovchiligida zichlik 1,010 atrofida qotib qoladi '
              '(glomerulyar filtrat zichligi).',
          'ru':
              'Норма 1,003–1,030. Ниже 1,010 — относительная гидратация, выше '
              '1,020 — относительное обезвоживание. При собственно почечной '
              'недостаточности плотность фиксирована около 1,010 (плотность '
              'клубочкового фильтрата).',
          'en':
              'Normal 1.003–1.030. Below 1.010 suggests relative hydration, '
              'above 1.020 relative dehydration. In intrinsic renal '
              'insufficiency it is fixed at about 1.010, the specific gravity '
              'of the glomerular filtrate.',
        }),
        [_a05Sg],
      ),
      UrFact(
        _T({
          'uz':
              '1,020 dan yuqori — suvsizlanish, glyukozuriya yoki '
              'antidiuretik gormonning nomutanosib sekretsiyasi sindromiga; '
              '1,003 dan past — kuchli suyulishga (qandsiz diabet, suv '
              'bilan zaharlanish, buyrak faoliyati buzilishi, buyrak usti '
              'bezi yetishmovchiligi, aldosteronizm) ishora qilishi mumkin. '
              'Test-chiziqdagi zichlik faqat hozirgi suv holatini ko‘rsatadi.',
          'ru':
              'Выше 1,020 может указывать на обезвоживание, глюкозурию или '
              'синдром неадекватной секреции АДГ; ниже 1,003 — на выраженное '
              'разведение (несахарный диабет, водная интоксикация, нарушение '
              'функции почек, надпочечниковая недостаточность, '
              'альдостеронизм). Плотность по полоске отражает лишь текущую '
              'гидратацию.',
          'en':
              'Above 1.020 may point to dehydration, glycosuria or the '
              'syndrome of inappropriate antidiuretic hormone; below 1.003 to '
              'marked dilution (diabetes insipidus, water intoxication, '
              'impaired renal function, adrenal insufficiency, '
              'aldosteronism). Strip specific gravity shows only the current '
              'hydration status.',
        }),
        [_a22Sg],
      ),
    ],
  ),
];

// ───────────────────────── 3. Test-chiziq ─────────────────────────

const urStripGeneral = <UrFact>[
  UrFact(
    _T({
      'uz':
          'Test-chiziq (test-poloska) siydikka botirilib darhol olinadi va '
          'shkalada ko‘rsatilgan vaqtdan keyin rang shkalasi bilan '
          'solishtiriladi. Natija yarim miqdoriy: manfiy, +, ++, +++, ++++ '
          'yoki taxminiy konsentratsiya. Chiziqlar ishlab chiqaruvchi '
          'ko‘rsatmasi bo‘yicha saqlanadi.',
      'ru':
          'Тест-полоску погружают в мочу и сразу вынимают, через указанное '
          'на шкале время сравнивают с цветовой шкалой. Результат '
          'полуколичественный: отрицательно, +, ++, +++, ++++ или примерная '
          'концентрация. Полоски хранят по инструкции производителя.',
      'en':
          'The strip is dipped and removed at once, then compared with the '
          'colour chart after the time stated on the chart. Results are '
          'semi-quantitative: negative, +, ++, +++, ++++ or an approximate '
          'concentration. Store strips as the manufacturer instructs.',
    }),
    [_wBlood],
  ),
  UrFact(
    _T({
      'uz':
          'Odatda 60–120 soniyada o‘qiladi; vaqtga eng sezgiri — '
          'leykotsitar esteraza. Ochiq havoda qolgan chiziqlar nitritni soxta '
          'musbat ko‘rsatadi: 1 hafta ochiq turganda chiziqlarning uchdan '
          'biri, 2 haftada to‘rtdan uchi. Idishni darhol yoping.',
      'ru':
          'Обычно читают через 60–120 секунд; наиболее чувствительна ко '
          'времени лейкоцитарная эстераза. Полоски, оставленные на воздухе, '
          'дают ложноположительные нитриты: через 1 неделю — треть полосок, '
          'через 2 недели — три четверти. Закрывайте тубу сразу.',
      'en':
          'Strips are usually read after 60–120 seconds; leukocyte esterase '
          'is the most time-sensitive. Strips left in open air give false '
          'nitrite positives: a third after one week, three quarters after '
          'two weeks. Close the container at once.',
    }),
    [_a22Dip, _a05Nitrite],
  ),
  UrFact(
    _T({
      'uz':
          'Bitta test-chiziq natijasi bo‘yicha mikrogematuriya tashxisi '
          'qo‘yilmaydi (AUA); bolalarda gematuriya yoki proteinuriya '
          'bo‘yicha tekshiruvdan oldin anormal natija takrorlanadi (AAP) — '
          'Choosing Wisely tavsiyalari. Qon uchun musbat chiziq mikroskopiya '
          'bilan tasdiqlanadi.',
      'ru':
          'Микрогематурию не диагностируют по одной полоске (AUA); у детей '
          'перед обследованием по поводу гематурии или протеинурии '
          'анормальный результат повторяют (AAP) — рекомендации Choosing '
          'Wisely. Положительную реакцию на кровь подтверждают микроскопией.',
      'en':
          'Microhaematuria is not diagnosed from a single strip (AUA); in '
          'children an abnormal strip is repeated before a work-up for '
          'haematuria or proteinuria (AAP) — Choosing Wisely '
          'recommendations. A strip positive for blood is confirmed by '
          'microscopy.',
    }),
    [_a22Wisely, _a22Sort],
  ),
];

const urPads = <UrPad>[
  UrPad(
    id: 'ph',
    name: _T({'uz': 'pH', 'ru': 'pH', 'en': 'pH'}),
    detects: UrFact(
      _T({
        'uz':
            'Yangi siydik biroz kislotali: pH taxminan 6,0 (5,0–7,0) — JSST; '
            '4,5–8 oralig‘ida, ko‘pincha 5,5–6,5 — AAFP. 1 soat ichida '
            'o‘lchanadi.',
        'ru':
            'Свежая моча слабокислая: pH около 6,0 (5,0–7,0) — ВОЗ; в '
            'пределах 4,5–8, чаще 5,5–6,5 — AAFP. Определяют в течение 1 часа.',
        'en':
            'Fresh urine is slightly acid: pH about 6.0 (5.0–7.0) per WHO; '
            '4.5–8, usually 5.5–6.5, per AAFP. Test within 1 hour.',
      }),
      [_wPh, _a22Ph],
    ),
    mayPoint: UrFact(
      _T({
        'uz':
            'Ishqoriy: ureaza hosil qiluvchi bakteriyalar (masalan, Proteus) '
            'bilan infeksiya, sitratga boy yoki vegetarian ovqat, 1-tur '
            'buyrak kanalchalari atsidozi, antatsidlar, karboangidraza '
            'ingibitorlari. Kislotali: oqsilga boy ovqat, nordon mevalar, '
            'atsidemiya. Tosh turini taxmin qilishga yordam beradi: past pH — '
            'siydik kislotasi, sistin, kalsiy oksalat; yuqori pH — kalsiy '
            'fosfat va struvit.',
        'ru':
            'Щелочная: инфекция бактериями, образующими уреазу (например, '
            'Proteus), цитратная или вегетарианская диета, дистальный '
            'почечный канальцевый ацидоз 1 типа, антациды, ингибиторы '
            'карбоангидразы. Кислая: белковая пища, кислые фрукты, ацидемия. '
            'Помогает предположить тип камня: низкий pH — мочевая кислота, '
            'цистин, оксалат кальция; высокий pH — фосфат кальция и струвит.',
        'en':
            'Alkaline: infection with urease-producing bacteria (e.g. '
            'Proteus), citrate-rich or vegetarian diet, type 1 renal tubular '
            'acidosis, antacids, carbonic anhydrase inhibitors. Acid: '
            'protein-rich diet, acidic fruits, acidaemia. It helps suggest a '
            'stone type: low pH — uric acid, cystine, calcium oxalate; high '
            'pH — calcium phosphate and struvite.',
      }),
      [_wPh, _a22Ph, _a22Table2],
    ),
    falsePos: UrFact(
      _T({
        'uz':
            'Turib qolgan siydik yoki ishqoriy dorilar pH ni oshiradi '
            '(pH 9 gacha).',
        'ru': 'Постоявшая моча или щелочные препараты повышают pH (до 9).',
        'en': 'Stale urine or alkaline medication raises the pH (up to 9).',
      }),
      [_dStrip],
    ),
    falseNeg: UrFact(
      _T({
        'uz': 'Formaldegid (konservant) pH ni pasaytiradi.',
        'ru': 'Формальдегид (консервант) снижает pH.',
        'en': 'Formaldehyde (preservative) lowers the pH.',
      }),
      [_dStrip, _a22Table2],
    ),
    next: UrFact(
      _T({
        'uz':
            'pH kristallarni aniqlashda yordam beradi: ba’zilari faqat '
            'kislotali, ba’zilari faqat ishqoriy siydikda cho‘kadi.',
        'ru':
            'pH помогает идентифицировать кристаллы: одни выпадают только в '
            'кислой, другие — только в щелочной моче.',
        'en':
            'pH helps identify crystals: some deposit only in acid urine, '
            'others only in alkaline urine.',
      }),
      [_wPhCrystals],
    ),
  ),
  UrPad(
    id: 'protein',
    name: _T({'uz': 'Oqsil', 'ru': 'Белок', 'en': 'Protein'}),
    detects: UrFact(
      _T({
        'uz':
            'Asosan albuminga sezgir. Taxminiy moslik: iz — 5–10 mg/dL, '
            '1+ ≈ 30, 2+ ≈ 100, 3+ ≈ 300, 4+ ≈ 1000 mg/dL.',
        'ru':
            'Чувствительна в основном к альбумину. Примерное соответствие: '
            'следы — 5–10 мг/дл, 1+ ≈ 30, 2+ ≈ 100, 3+ ≈ 300, 4+ ≈ 1000 мг/дл.',
        'en':
            'Most sensitive to albumin. Approximate equivalents: trace '
            '5–10 mg/dL, 1+ ≈ 30, 2+ ≈ 100, 3+ ≈ 300, 4+ ≈ 1,000 mg/dL.',
      }),
      [_a22Protein],
    ),
    mayPoint: UrFact(
      _T({
        'uz':
            'O‘tkinchi (isitma, jismoniy zo‘riqish, suvsizlanish, stress, '
            'ortostatik) yoki doimiy (glomerulyar, kanalcha, '
            '“to‘lib-toshish”) proteinuriya. Ortostatik proteinuriya zararsiz, '
            '8 soat yotgandan keyingi namunada yo‘qoladi.',
        'ru':
            'Транзиторная (лихорадка, нагрузка, обезвоживание, стресс, '
            'ортостатическая) или стойкая (клубочковая, канальцевая, '
            '«переполнения») протеинурия. Ортостатическая протеинурия '
            'доброкачественна и исчезает в пробе после 8 часов лёжа.',
        'en':
            'Transient (fever, exercise, dehydration, stress, orthostatic) '
            'or persistent (glomerular, tubular, overflow) proteinuria. '
            'Orthostatic proteinuria is benign and absent after 8 hours of '
            'recumbency.',
      }),
      [_a22Protein, _a05Protein, _wProtein],
    ),
    falsePos: UrFact(
      _T({
        'uz':
            'Kuchli buferlangan ishqoriy (pH 9) yoki quyuq siydik, chiziqni '
            'uzoq botirib qo‘yish, idishni to‘rtlamchi ammoniy birikmalari '
            'bilan yuvish, xlorgeksidin, fenazopiridin; qon, qin ajralmasi, '
            'yiring, sperma, ko‘p shilliq aralashishi.',
        'ru':
            'Сильно забуференная щелочная (pH 9) или концентрированная моча, '
            'долгое погружение полоски, мытьё ёмкости четвертичными '
            'аммониевыми соединениями, хлоргексидин, феназопиридин; примесь '
            'крови, влагалищных выделений, гноя, спермы, обильной слизи.',
        'en':
            'Highly buffered alkaline (pH 9) or concentrated urine, leaving '
            'the strip in urine too long, containers cleaned with quaternary '
            'ammonium compounds, chlorhexidine, phenazopyridine; '
            'contamination with blood, vaginal discharge, pus, semen or heavy '
            'mucus.',
      }),
      [_dStrip, _a22Table2],
    ),
    falseNeg: UrFact(
      _T({
        'uz':
            'Suyultirilgan yoki kislotali siydik; albumin bo‘lmagan oqsillar '
            '(globulinlar, yengil zanjirlar — Bens-Jons oqsili) chiziqda '
            'ko‘rinmasligi mumkin.',
        'ru':
            'Разведённая или кислая моча; неальбуминовые белки (глобулины, '
            'лёгкие цепи — белок Бенс-Джонса) полоска может не выявить.',
        'en':
            'Dilute or acid urine; non-albumin proteins (globulins, light '
            'chains — Bence Jones protein) may be missed.',
      }),
      [_dStrip, _a22Protein, _a22Table2],
    ),
    next: UrFact(
      _T({
        'uz':
            'Musbat natija miqdoriy test bilan, masalan, bir martalik '
            'siydikdagi albumin/kreatinin nisbati bilan tekshiriladi; '
            'oqsil chiqishi o‘zgaruvchan bo‘lgani uchun musbat natija boshqa '
            'namunada takrorlanadi.',
        'ru':
            'Положительный результат уточняют количественным тестом, '
            'например отношением альбумин/креатинин в разовой моче; из-за '
            'изменчивости экскреции белка положительный результат повторяют '
            'на других пробах.',
        'en':
            'Follow a positive result with a quantitative test such as a spot '
            'urine albumin/creatinine ratio; because protein excretion varies, '
            'confirm positives on one or more separate samples.',
      }),
      [_a22Sort, _wProtein],
    ),
  ),
  UrPad(
    id: 'glucose',
    name: _T({'uz': 'Glyukoza', 'ru': 'Глюкоза', 'en': 'Glucose'}),
    detects: UrFact(
      _T({
        'uz':
            'Glyukozaoksidaza reaksiyasi. Glyukoza qon plazmasida taxminan '
            '180–200 mg/dL (≈ 10–11 mmol/L) dan oshganda proksimal kanalcha '
            'tashuvchilari (SGLT-2) to‘yinadi va siydikka chiqadi.',
        'ru':
            'Глюкозооксидазная реакция. Глюкоза появляется в моче, когда в '
            'плазме она превышает примерно 180–200 мг/дл (≈ 10–11 ммоль/л) и '
            'переносчики проксимального канальца (SGLT-2) насыщаются.',
        'en':
            'Glucose oxidase reaction. Glucose appears in urine when plasma '
            'glucose exceeds about 180–200 mg/dL (≈ 10–11 mmol/L) and the '
            'proximal tubule transporters (SGLT-2) are overwhelmed.',
      }),
      [_dStrip, _a22Glucose],
    ),
    mayPoint: UrFact(
      _T({
        'uz':
            'Qandli diabet; SGLT-2 ingibitorlari bilan davolash; '
            'homiladorlik; qonda glyukoza oshmasa — Fankoni sindromi '
            '(proksimal kanalcha kasalligi). Benedikt usuli barcha '
            'qaytaruvchi qandlarni (homiladorlarda laktozani ham) aniqlaydi.',
        'ru':
            'Сахарный диабет; лечение ингибиторами SGLT-2; беременность; при '
            'нормальной глюкозе крови — синдром Фанкони (болезнь '
            'проксимального канальца). Метод Бенедикта выявляет все '
            'редуцирующие сахара (у беременных — и лактозу).',
        'en':
            'Diabetes mellitus; SGLT-2 inhibitor treatment; pregnancy; with '
            'normal blood glucose — Fanconi syndrome (a proximal tubule '
            'disorder). The Benedict method detects all reducing sugars '
            '(including lactose in pregnancy).',
      }),
      [_a22Glucose, _a22Table2, _wGlucose],
    ),
    falsePos: UrFact(
      _T({
        'uz':
            'Kuchli oksidlovchi tozalash vositalari (peroksid va b.) bilan '
            'ifloslanish; levodopa.',
        'ru':
            'Загрязнение сильными окислителями (пероксид и др.) из моющих '
            'средств; леводопа.',
        'en':
            'Contamination with strong oxidising cleaning agents (peroxide '
            'etc.); levodopa.',
      }),
      [_dStrip, _a22Table2],
    ),
    falseNeg: UrFact(
      _T({
        'uz':
            'Ko‘p miqdorda askorbin kislota (C vitamini) — test oxirgi '
            'qabuldan kamida 1 kun keyin takrorlanadi; yuqori nisbiy zichlik, '
            'yuqori pH, siydik kislotasi, siydik yo‘li infeksiyasi; ayrim '
            'chiziqlarda — o‘rtacha yuqori ketonlar.',
        'ru':
            'Большие дозы аскорбиновой кислоты (витамин C) — тест повторяют '
            'не ранее чем через сутки после последнего приёма; высокая '
            'плотность, высокий pH, мочевая кислота, инфекция мочевых путей; '
            'для некоторых полосок — умеренно высокие кетоны.',
        'en':
            'Large doses of ascorbic acid (vitamin C) — repeat at least one '
            'day after the last intake; high specific gravity, high pH, uric '
            'acid, urinary infection; with some strips, moderately high '
            'ketones.',
      }),
      [_dStrip, _a22Table2],
    ),
  ),
  UrPad(
    id: 'ketones',
    name: _T({'uz': 'Keton tanachalari', 'ru': 'Кетоны', 'en': 'Ketones'}),
    detects: UrFact(
      _T({
        'uz':
            'Natriy nitroprussid reaksiyasi (binafsha rang). Me’yorda siydikda '
            'keton yo‘q. Beta-gidroksibutirat bu reaksiyada aniqlanmaydi.',
        'ru':
            'Реакция с нитропруссидом натрия (фиолетовое окрашивание). В '
            'норме кетонов в моче нет. Бета-гидроксибутират этой реакцией не '
            'выявляется.',
        'en':
            'Sodium nitroprusside reaction (purple colour). Normal urine has '
            'no ketones. Beta-hydroxybutyrate is not detected by this '
            'reaction.',
      }),
      [_wKetones, _a05Ketones, _dStrip],
    ),
    mayPoint: UrFact(
      _T({
        'uz':
            'Og‘ir yoki davolanmagan qandli diabet (ketoatsidoz), ketogen '
            'parhez, ochlik, homiladorlik; suvsizlanish, qusish, '
            'to‘yib ovqatlanmaslik, og‘ir jismoniy zo‘riqishdan keyin.',
        'ru':
            'Тяжёлый или нелеченый сахарный диабет (кетоацидоз), кетогенная '
            'диета, голодание, беременность; обезвоживание, рвота, '
            'недоедание, после тяжёлой нагрузки.',
        'en':
            'Severe or untreated diabetes (ketoacidosis), ketogenic diet, '
            'starvation, pregnancy; dehydration, vomiting, malnutrition, '
            'after strenuous exercise.',
      }),
      [_wKetones, _a22Ketones],
    ),
    falsePos: UrFact(
      _T({
        'uz':
            'Past pH va yuqori nisbiy zichlikli siydik; levodopa metabolitlari; '
            'sulfgidril guruhli dorilar (kaptopril, mesna); kuchli bo‘yalgan '
            'siydik.',
        'ru':
            'Моча с низким pH и высокой плотностью; метаболиты леводопы; '
            'препараты с сульфгидрильными группами (каптоприл, месна); сильно '
            'окрашенная моча.',
        'en':
            'Urine with low pH and high specific gravity; levodopa '
            'metabolites; drugs with sulfhydryl groups (captopril, mesna); '
            'highly pigmented urine.',
      }),
      [_dStrip, _a05Table2],
    ),
    falseNeg: UrFact(
      _T({
        'uz': 'Noto‘g‘ri saqlash yoki tekshiruvning kechikishi.',
        'ru': 'Неправильное хранение или задержка исследования.',
        'en': 'Improper storage or delayed testing.',
      }),
      [_dStrip, _a22Table2],
    ),
  ),
  UrPad(
    id: 'bilirubin',
    name: _T({'uz': 'Bilirubin', 'ru': 'Билирубин', 'en': 'Bilirubin'}),
    detects: UrFact(
      _T({
        'uz':
            'Faqat bog‘langan (konyugatsiyalangan) bilirubin — u suvda '
            'eriydi; bog‘lanmagan bilirubin glomerul orqali o‘tmaydi. '
            'Me’yorda aniqlanmaydi.',
        'ru':
            'Только связанный (конъюгированный) билирубин — он '
            'водорастворим; несвязанный через клубочек не проходит. В норме '
            'не выявляется.',
        'en':
            'Only conjugated bilirubin, which is water-soluble; unconjugated '
            'bilirubin cannot pass the glomerulus. Normally not detected.',
      }),
      [_a05Bili],
    ),
    mayPoint: UrFact(
      _T({
        'uz':
            'Jigar kasalligi yoki o‘t yo‘llari to‘siqligi (tekshirish kerak).',
        'ru':
            'Болезнь печени или обструкция жёлчных путей (нужно обследование).',
        'en': 'Liver disease or biliary obstruction (needs evaluation).',
      }),
      [_a22Bili, _a22Table2],
    ),
    falsePos: UrFact(
      _T({
        'uz':
            'Fenazopiridin, katta dozada xlorpromazin, etodolak metabolitlari, '
            'indikan.',
        'ru':
            'Феназопиридин, большие дозы хлорпромазина, метаболиты '
            'этодолака, индикан.',
        'en':
            'Phenazopyridine, large doses of chlorpromazine, etodolac '
            'metabolites, indican.',
      }),
      [_dStrip, _a22Table2],
    ),
    falseNeg: UrFact(
      _T({
        'uz':
            'Yorug‘likda turish, katta dozada C vitamini, yuqori nitrit, '
            'selen; muddati o‘tgan chiziq ishonchsiz.',
        'ru':
            'Воздействие света, большие дозы витамина C, высокие нитриты, '
            'селен; полоска с истёкшим сроком ненадёжна.',
        'en':
            'Light exposure, large doses of vitamin C, high nitrite, '
            'selenium; an expired strip is unreliable.',
      }),
      [_dStrip, _a22Table2],
    ),
  ),
  UrPad(
    id: 'urobilinogen',
    name: _T({
      'uz': 'Urobilinogen',
      'ru': 'Уробилиноген',
      'en': 'Urobilinogen',
    }),
    detects: UrFact(
      _T({
        'uz':
            'Ichakda bilirubindan hosil bo‘ladi; me’yorda siydikda oz '
            'miqdorda bo‘ladi.',
        'ru':
            'Образуется из билирубина в кишечнике; в норме в моче есть в '
            'небольшом количестве.',
        'en':
            'Formed from bilirubin in the intestine; normal urine contains '
            'small amounts.',
      }),
      [_a05Bili, _a22Bili],
    ),
    mayPoint: UrFact(
      _T({
        'uz':
            'Oshishi — gemoliz yoki jigar kasalligi (ba’zan me’yorda ham); '
            'kamayishi — o‘t yo‘li to‘siqligi yoki antibiotiklar qabuli.',
        'ru':
            'Повышение — гемолиз или болезнь печени (иногда и в норме); '
            'снижение — обструкция жёлчных путей или приём антибиотиков.',
        'en':
            'Raised — haemolysis or liver disease (sometimes a normal '
            'finding); lowered — bile duct obstruction or antibiotic use.',
      }),
      [_a05Bili, _a22Table2],
    ),
    falsePos: UrFact(
      _T({
        'uz':
            'Fenazopiridin, sulfanilamidlar, p-aminosalitsil kislota; '
            'porfobilinogen; bo‘yalgan siydik.',
        'ru':
            'Феназопиридин, сульфаниламиды, п-аминосалициловая кислота; '
            'порфобилиноген; окрашенная моча.',
        'en':
            'Phenazopyridine, sulfonamides, p-aminosalicylic acid; '
            'porphobilinogen; coloured urine.',
      }),
      [_dStrip, _a22Table2],
    ),
    falseNeg: UrFact(
      _T({
        'uz': 'Noto‘g‘ri saqlash (yorug‘lik), formaldegid, nitritli siydik.',
        'ru': 'Неправильное хранение (свет), формальдегид, нитриты в моче.',
        'en': 'Improper storage (light), formaldehyde, nitrite in the urine.',
      }),
      [_dStrip, _a22Table2],
    ),
  ),
  UrPad(
    id: 'blood',
    name: _T({
      'uz': 'Qon (gemoglobin)',
      'ru': 'Кровь (гемоглобин)',
      'en': 'Blood (haemoglobin)',
    }),
    detects: UrFact(
      _T({
        'uz':
            'Gemoglobinning peroksidaza faolligi: butun eritrotsitlar, erkin '
            'gemoglobin va miyoglobin ham reaksiya beradi. Gematuriyaga '
            'sezgirligi 90 % dan yuqori.',
        'ru':
            'Пероксидазная активность гемоглобина: реагируют целые '
            'эритроциты, свободный гемоглобин и миоглобин. Чувствительность к '
            'гематурии выше 90 %.',
        'en':
            'Peroxidase activity of haemoglobin: intact red cells, free '
            'haemoglobin and myoglobin all react. Sensitivity for haematuria '
            'is above 90%.',
      }),
      [_a05Hematuria, _a22Blood],
    ),
    mayPoint: UrFact(
      _T({
        'uz':
            'Gematuriya, gemoglobinuriya yoki miyoglobinuriya. Eritrotsitlar '
            'ko‘payishi: og‘ir jismoniy zo‘riqishdan keyin, qin '
            'infeksiyalarida, shistosomozda, o‘tkir glomerulonefrit, sistit '
            'yoki uretritda, ayrim o‘smalarda kuzatilishi mumkin.',
        'ru':
            'Гематурия, гемоглобинурия или миоглобинурия. Эритроциты в моче '
            'могут повышаться после тяжёлой нагрузки, при вагинальных '
            'инфекциях, шистосомозе, остром гломерулонефрите, цистите или '
            'уретрите, при некоторых опухолях.',
        'en':
            'Haematuria, haemoglobinuria or myoglobinuria. Red cells may rise '
            'after heavy exercise, in vaginal infections, schistosomiasis, '
            'acute glomerulonephritis, cystitis or urethritis, and with some '
            'tumours.',
      }),
      [_a05Hematuria, _wBlood],
    ),
    falsePos: UrFact(
      _T({
        'uz':
            'Oksidlovchi ifloslantiruvchilar (gipoxlorit), ko‘p bakteriyalar '
            'peroksidazasi, povidon-yod, hayz qoni, sperma, miyoglobin.',
        'ru':
            'Окислители-загрязнители (гипохлорит), пероксидаза большого '
            'количества бактерий, повидон-йод, менструальная кровь, сперма, '
            'миоглобин.',
        'en':
            'Oxidising contaminants (hypochlorite), peroxidase from heavy '
            'bacterial growth, povidone-iodine, menstrual blood, semen, '
            'myoglobin.',
      }),
      [_dStrip],
    ),
    falseNeg: UrFact(
      _T({
        'uz':
            'Tekshiruvning kechikishi, aralashtirilmagan namuna, formalin, '
            'katta dozada C vitamini, kaptopril; yuqori oqsil, nitrit yoki '
            'nisbiy zichlik; pH 5,1 dan past.',
        'ru':
            'Задержка исследования, неперемешанная проба, формалин, большие '
            'дозы витамина C, каптоприл; высокий белок, нитриты или '
            'плотность; pH ниже 5,1.',
        'en':
            'Delayed testing, an unmixed sample, formalin, large doses of '
            'vitamin C, captopril; high protein, nitrite or specific gravity; '
            'pH below 5.1.',
      }),
      [_dStrip, _a05Table2],
    ),
    next: UrFact(
      _T({
        'uz':
            'Mikroskopiya bilan tasdiqlanadi. Chiziq kuchli musbat, cho‘kmada '
            'eritrotsit yo‘q: rangi oddiy suyultirilgan siydikda — '
            'eritrotsitlar lizisi; ochiq qizil siydikda — tomir ichi gemolizi '
            'yoki rabdomioliz ehtimoli. Simptomsiz bemorda o‘tkinchi '
            'gematuriyani istisno qilish uchun tahlil boshqa kunlarda '
            'takrorlanadi.',
        'ru':
            'Подтверждают микроскопией. Полоска резко положительна, а в '
            'осадке эритроцитов нет: при разведённой моче обычного цвета — '
            'лизис эритроцитов; при явно кровянистой моче — возможен '
            'внутрисосудистый гемолиз или рабдомиолиз. У бессимптомного '
            'пациента анализ повторяют в другие дни, чтобы исключить '
            'транзиторную гематурию.',
        'en':
            'Confirm by microscopy. A strongly positive strip with no red '
            'cells in the sediment: in dilute urine of normal colour — red '
            'cell lysis; in grossly bloody urine — possible intravascular '
            'haemolysis or rhabdomyolysis. In asymptomatic patients repeat '
            'on different occasions to rule out transient haematuria.',
      }),
      [_dStrip, _a22Blood],
    ),
  ),
  UrPad(
    id: 'nitrite',
    name: _T({'uz': 'Nitrit', 'ru': 'Нитриты', 'en': 'Nitrite'}),
    detects: UrFact(
      _T({
        'uz':
            'Bakteriyalar siydikdagi nitratni nitritga aylantiradi (ko‘p '
            'gramm-manfiy va ba’zi gramm-musbat bakteriyalar); musbat natija '
            'ular ko‘p (10 000/mL dan ortiq) ekanini ko‘rsatadi. Me’yorda '
            'nitrit yo‘q.',
        'ru':
            'Бактерии превращают нитраты мочи в нитриты (многие '
            'грамотрицательные и некоторые грамположительные); положительный '
            'результат означает, что их много (более 10 000/мл). В норме '
            'нитритов нет.',
        'en':
            'Bacteria reduce urinary nitrate to nitrite (many Gram-negative '
            'and some Gram-positive organisms); a positive test means they '
            'are present in significant numbers (more than 10,000/mL). '
            'Nitrite is normally absent.',
      }),
      [_a05Nitrite],
    ),
    mayPoint: UrFact(
      _T({
        'uz':
            'Siydik yo‘li infeksiyasi: test o‘ziga xos (spetsifik), lekin '
            'sezgirligi past. Simptomli bemorda nitrit infeksiyani kuchli '
            'taxmin qildiradi (LR+ ≈ 13).',
        'ru':
            'Инфекция мочевых путей: тест специфичен, но мало '
            'чувствителен. У пациента с симптомами нитриты сильно указывают '
            'на инфекцию (LR+ ≈ 13).',
        'en':
            'Urinary tract infection: the test is specific but not very '
            'sensitive. In a symptomatic patient nitrite strongly suggests '
            'infection (LR+ ≈ 13).',
      }),
      [_a05Nitrite, _a22Table3, _a22Sort],
    ),
    falsePos: UrFact(
      _T({
        'uz':
            'Ifloslanish; havoda qolgan chiziq; fenazopiridin; xona '
            'haroratida bir necha soat turgan yoki qizil siydik.',
        'ru':
            'Загрязнение; полоска, оставленная на воздухе; феназопиридин; '
            'моча, простоявшая несколько часов при комнатной температуре, '
            'или красная моча.',
        'en':
            'Contamination; strips exposed to air; phenazopyridine; urine '
            'left at room temperature for several hours, or red urine.',
      }),
      [_a05Table2, _dStrip],
    ),
    falseNeg: UrFact(
      _T({
        'uz':
            'Nitrat qaytarmaydigan bakteriyalar (masalan, Enterococcus); '
            'qovuqda 4 soatdan kam turgan siydik; nitratsiz ovqat '
            '(sabzavotsiz); C vitamini; yuqori nisbiy zichlik; pH 6 dan past; '
            'yuqori urobilinogen.',
        'ru':
            'Бактерии, не восстанавливающие нитраты (например, '
            'Enterococcus); моча находилась в пузыре меньше 4 часов; диета '
            'без нитратов (без овощей); витамин C; высокая плотность; pH '
            'ниже 6; высокий уробилиноген.',
        'en':
            'Bacteria that do not reduce nitrate (e.g. Enterococcus); urine '
            'held in the bladder for under 4 hours; a low-nitrate diet (no '
            'vegetables); vitamin C; high specific gravity; pH below 6; high '
            'urobilinogen.',
      }),
      [_a22LeNitrite, _a05Nitrite, _dStrip],
    ),
    next: UrFact(
      _T({
        'uz':
            'Manfiy nitrit infeksiyani istisno qilmaydi. Infeksiya '
            'simptomlari bo‘lsa siydik ekmasi tavsiya etiladi.',
        'ru':
            'Отрицательные нитриты не исключают инфекцию. При симптомах '
            'инфекции рекомендован посев мочи.',
        'en':
            'A negative nitrite does not rule out infection. Urine culture '
            'is recommended when infection symptoms are present.',
      }),
      [_a22Sort, _a22Bacteria],
    ),
  ),
  UrPad(
    id: 'leukocytes',
    name: _T({
      'uz': 'Leykotsitar esteraza',
      'ru': 'Лейкоцитарная эстераза',
      'en': 'Leukocyte esterase',
    }),
    detects: UrFact(
      _T({
        'uz':
            'Neytrofillar esterazasi; piuriyaga ishora. Chiziq turiga qarab '
            'rang o‘zgarishi uchun 30 soniyadan 2 daqiqagacha kutiladi.',
        'ru':
            'Эстераза нейтрофилов; указывает на пиурию. В зависимости от '
            'марки полоски для изменения цвета ждут от 30 секунд до 2 минут.',
        'en':
            'Esterase from neutrophils; signals pyuria. Allow 30 seconds to 2 '
            'minutes for the colour change, depending on the brand.',
      }),
      [_a05Le],
    ),
    mayPoint: UrFact(
      _T({
        'uz':
            'Siydik yo‘li infeksiyasi, yallig‘lanish, jinsiy yo‘l bilan '
            'yuqadigan infeksiya. Ekma manfiy piuriya (steril piuriya): '
            'Chlamydia, Ureaplasma, sil, toshlar, o‘sma, uretrit va b.',
        'ru':
            'Инфекция мочевых путей, воспаление, ИППП. Пиурия при '
            'отрицательном посеве (стерильная пиурия): Chlamydia, Ureaplasma, '
            'туберкулёз, камни, опухоль, уретрит и др.',
        'en':
            'Urinary tract infection, inflammation, sexually transmitted '
            'infection. Pyuria with negative cultures (sterile pyuria): '
            'Chlamydia, Ureaplasma, tuberculosis, stones, tumours, urethritis '
            'and others.',
      }),
      [_a22Table2, _a05Le],
    ),
    falsePos: UrFact(
      _T({
        'uz':
            'Ifloslanish (qin ajralmasi, shilliq), kuchli oksidlovchilar, '
            'formaldegid, natriy azid; bo‘yalgan siydik (bilirubin, lavlagi).',
        'ru':
            'Загрязнение (влагалищные выделения, слизь), сильные окислители, '
            'формальдегид, азид натрия; окрашенная моча (билирубин, свёкла).',
        'en':
            'Contamination (vaginal discharge, mucus), strong oxidising '
            'agents, formaldehyde, sodium azide; coloured urine (bilirubin, '
            'beets).',
      }),
      [_dStrip, _a05Table2],
    ),
    falseNeg: UrFact(
      _T({
        'uz':
            'Yuqori glyukoza, oqsil yoki nisbiy zichlik; C vitamini; ayrim '
            'antibiotiklar; bor kislotasi.',
        'ru':
            'Высокие глюкоза, белок или плотность; витамин C; некоторые '
            'антибиотики; борная кислота.',
        'en':
            'High glucose, protein or specific gravity; vitamin C; some '
            'antibiotics; boric acid.',
      }),
      [_dStrip, _a22Table2],
    ),
    next: UrFact(
      _T({
        'uz':
            'Esteraza va nitrit birga baholanadi: ikkalasi ham manfiy bo‘lsa '
            'infeksiya ehtimoli kamayadi (LR− ≈ 0,2), lekin istisno '
            'qilinmaydi. Leykotsitar silindrlar yallig‘lanish buyrakda '
            'ekanini ko‘rsatishi mumkin.',
        'ru':
            'Эстеразу оценивают вместе с нитритами: если оба отрицательны, '
            'вероятность инфекции снижается (LR− ≈ 0,2), но она не '
            'исключается. Лейкоцитарные цилиндры могут указывать на '
            'воспаление в почке.',
        'en':
            'Read esterase together with nitrite: both negative lowers the '
            'likelihood of infection (LR− ≈ 0.2) but does not exclude it. '
            'White-cell casts can localise inflammation to the kidney.',
      }),
      [_a22Table3, _a05Le],
    ),
  ),
  UrPad(
    id: 'sg',
    name: _T({
      'uz': 'Nisbiy zichlik',
      'ru': 'Относительная плотность',
      'en': 'Specific gravity',
    }),
    detects: UrFact(
      _T({
        'uz':
            'Siydikda erigan moddalar konsentratsiyasini (osmolyallikni) '
            'aks ettiradi; me’yori va ma’nosi — “Fizik xossalar” bo‘limida.',
        'ru':
            'Отражает концентрацию растворённых веществ (осмоляльность); '
            'норма и значение — в разделе «Физические свойства».',
        'en':
            'Reflects the concentration of dissolved substances '
            '(osmolality); normal values and meaning are under “Physical '
            'properties”.',
      }),
      [_a22Sg],
    ),
    mayPoint: UrFact(
      _T({
        'uz':
            '1,020 dan yuqori — suvsizlanish, glyukozuriya; 1,003 dan past — '
            'kuchli suyulish.',
        'ru': 'Выше 1,020 — обезвоживание, глюкозурия; ниже 1,003 — сильное разведение.',
        'en': 'Above 1.020 — dehydration, glycosuria; below 1.003 — marked dilution.',
      }),
      [_a22Sg],
    ),
    falsePos: UrFact(
      _T({
        'uz':
            'Soxta yuqori: proteinuriya (1 g/L dan ortiq), keto-kislotalar, '
            'dekstran eritmalari, tomir ichiga yuborilgan rentgenokontrast.',
        'ru':
            'Ложно высокая: протеинурия (более 1 г/л), кетокислоты, растворы '
            'декстрана, внутривенные рентгеноконтрастные вещества.',
        'en':
            'Falsely high: proteinuria (over 1 g/L), keto acids, dextran '
            'solutions, intravenous radiocontrast.',
      }),
      [_dStrip, _a05Table2],
    ),
    falseNeg: UrFact(
      _T({
        'uz': 'Soxta past: ishqoriy siydik.',
        'ru': 'Ложно низкая: щелочная моча.',
        'en': 'Falsely low: alkaline urine.',
      }),
      [_dStrip, _a05Table2],
    ),
  ),
];

// ───────────────────────── 4. Cho'kma mikroskopiyasi ─────────────────────────

const urSedimentIntro = <UrFact>[
  UrFact(
    _T({
      'uz':
          'Standartlashtirilgan tayyorlash: 12 ml siydik (5–12 ml '
          'qabul qilinadi), 400 g da 5 daqiqa sentrifuga (tormozsiz), usti '
          '1 ml qolguncha to‘kiladi (12:1) va cho‘kma ehtiyotkorlik bilan '
          'aralashtiriladi; standart oynacha va yozma SOP bilan baholanadi. '
          'Laboratoriyangiz SOP i ustun.',
      'ru':
          'Стандартизованная подготовка: 12 мл мочи (допустимо '
          '5–12 мл), центрифугирование 5 минут при 400 g (без тормоза), '
          'надосадок сливают до 1 мл (12:1), осадок осторожно ресуспендируют; '
          'оценивают на стандартизованных стёклах по письменной СОП. СОП '
          'вашей лаборатории имеет приоритет.',
      'en':
          'Standardised preparation: 12 ml of urine (5–12 ml '
          'acceptable), centrifuge 5 minutes at 400 g (brake off), decant to '
          '1 ml (12:1) and gently resuspend; read with standardised slides '
          'and a written SOP. Your laboratory’s SOP takes precedence.',
    }),
    [_dManual],
  ),
  UrFact(
    _T({
      'uz':
          'Cho‘kma — yarim miqdoriy usul: sentrifugada eritrotsit va '
          'leykotsitlarning 20–80 % i yo‘qolishi, takrorlanuvchanlik '
          'koeffitsienti 100 % gacha yetishi mumkin. Aniq sanoq uchun '
          'kamera usullari — Nechiporenko va Kakovskiy–Addis '
          'kalkulyatorlari.',
      'ru':
          'Осадок — полуколичественный метод: при центрифугировании теряется '
          '20–80 % эритроцитов и лейкоцитов, коэффициент вариации может '
          'достигать 100 %. Для подсчёта в камере — калькуляторы '
          'Нечипоренко и Каковского — Аддиса.',
      'en':
          'Sediment is semi-quantitative: centrifugation loses 20–80% of '
          'red and white cells, and the coefficient of variation can reach '
          '100%. For chamber counts see the Nechiporenko and Kakovsky–Addis '
          'calculators.',
    }),
    [_dManual],
  ),
  UrFact(
    _T({
      'uz':
          'Kondensor tushirilgan holda ×10 obyektiv bilan butun qoplagich '
          'ko‘zdan kechiriladi, so‘ng ×40 bilan har ko‘rish maydoni (k/m) '
          'bo‘yicha yoziladi. Silindrlar qoplagich chetiga yaqin, xira '
          'yorug‘lik va yuqori kontrastda yaxshi ko‘rinadi; fazali kontrast '
          'silindrlarni, qutblangan yorug‘lik kristallarni aniqlashga yordam '
          'beradi.',
      'ru':
          'При опущенном конденсоре объективом ×10 просматривают всё '
          'покровное стекло, затем объективом ×40 записывают результат на '
          'поле зрения (п/з). Цилиндры лучше видны у края покровного стекла '
          'при приглушённом свете и высоком контрасте; фазовый контраст '
          'помогает в распознавании цилиндров, поляризация — кристаллов.',
      'en':
          'With the condenser lowered, scan the whole coverslip with the ×10 '
          'objective, then report per high-power field (HPF) with ×40. Casts '
          'are best seen near the coverslip edge in dim light with high '
          'contrast; phase contrast helps with casts and polarised light '
          'with crystals.',
    }),
    [_wMicroscopy, _a22CrystCasts, _a22Setup],
  ),
];

const urSedimentCrystalsNote = UrFact(
  _T({
    'uz':
        'Kristallar sog‘lom odamlarda ham uchraydi; juda kam uchraydigan '
        'kasalliklardan tashqari tashxisiy ahamiyati yo‘q. Ba’zilari faqat '
        'kislotali (oksalatlar, siydik kislotasi), boshqalari ishqoriy '
        '(fosfatlar, karbonatlar) siydikda cho‘kadi. Sovigan siydikda ham '
        'hosil bo‘ladi — faqat yangi namuna ko‘riladi.',
    'ru':
        'Кристаллы встречаются и у здоровых; кроме очень редких болезней, '
        'диагностического значения не имеют. Одни выпадают только в кислой '
        '(оксалаты, мочевая кислота), другие — в щелочной (фосфаты, '
        'карбонаты) моче. Они образуются и в остывшей моче — исследуют '
        'только свежую пробу.',
    'en':
        'Crystals occur in healthy people; except in very rare diseases they '
        'have no diagnostic significance. Some deposit only in acid urine '
        '(oxalates, uric acid), others in alkaline urine (phosphates, '
        'carbonates). They also form in cooled urine, so only fresh samples '
        'are examined.',
  }),
  [_wPhCrystals, _wCrystals, _a05Crystals, _a22CrystCasts],
);

const _panelNote = _T({
  'uz': 'Jurnal rasmi, 4 panel; bu karta uchun — ',
  'ru': 'Журнальный рисунок из 4 панелей; к этой карточке — ',
  'en': 'Journal figure with 4 panels; for this card — ',
});

/// Ko'p panelli rasm uchun panel izohi.
LocalizedText urPanelNote(LocalizedText panel) => _T({
  for (final l in LocalizedText.requiredLanguages)
    l: '${_panelNote.of(l)}${panel.of(l)}',
});

const urElements = <UrElement>[
  // ── Hujayralar ──
  UrElement(
    id: 'rbc',
    group: UrGroup.cells,
    name: _T({
      'uz': 'Eritrotsitlar',
      'ru': 'Эритроциты',
      'en': 'Red blood cells',
    }),
    pics: [UrPic('u-rbc-1', 'urine-rbc'), UrPic('u-rbc-2', 'urine-rbc')],
    quiz: true,
    look: [
      UrFact(
        _T({
          'uz':
              'Butun: kichik sarg‘ish disklar, cheti qoramtir (taxminan 8 µm); '
              'burishgan: tikanakli cheti, kichikroq (5–6 µm); shishgan: '
              'yupqa halqa, kattaroq (9–10 µm). Saqlanganda shakli o‘zgaradi '
              'va bu tashxisiy ahamiyatga ega emas.',
          'ru':
              'Неизменённые: мелкие желтоватые диски с более тёмным краем '
              '(около 8 мкм); сморщенные: зубчатый край, меньше (5–6 мкм); '
              'набухшие: тонкие кольца, крупнее (9–10 мкм). При хранении '
              'форма меняется, и это диагностического значения не имеет.',
          'en':
              'Intact: small yellowish discs, darker at the edge (about 8 µm); '
              'crenated: spiky edge, smaller (5–6 µm); swollen: thin rings, '
              'larger (9–10 µm). Shape changes during storage and has no '
              'diagnostic importance.',
        }),
        [_wRbc],
      ),
      UrFact(
        _T({
          'uz':
              'Mikroskopda kichik, yumaloq, rangsiz (“soya” hujayralar); '
              'yadrosi yo‘q.',
          'ru':
              'Под микроскопом мелкие, круглые, бесцветные («тени»); ядра нет.',
          'en':
              'Small, round and colourless (“ghost cells”) under the '
              'microscope; no nucleus.',
        }),
        [_a22Rbc, _a22Epi],
      ),
    ],
    meaning: UrFact(
      _T({
        'uz':
            'Kattalarda sentrifugalangan siydikda k/m da 3 va undan ortiq '
            'eritrotsit — mikrogematuriya; bolalarda — 5 dan ortiq. Sabablar '
            'zararsizdan (jismoniy zo‘riqish, hayz qoni aralashishi) '
            'jiddiygacha; baholashni shifokor qiladi.',
        'ru':
            'У взрослых 3 и более эритроцитов в п/з центрифугированной мочи '
            '— микрогематурия; у детей — более 5. Причины — от безобидных '
            '(нагрузка, примесь менструальной крови) до серьёзных; оценивает '
            'врач.',
        'en':
            'In adults, 3 or more red cells per HPF of spun urine is '
            'microhaematuria; in children, more than 5. Causes range from '
            'benign (exercise, menstrual contamination) to serious; a '
            'clinician evaluates it.',
      }),
      [_a22Rbc, _wRbc, _a05Hematuria],
    ),
    confuse: UrFact(
      _T({
        'uz':
            'Achitqi zamburug‘lari bilan adashtirmang: ular kurtaklanadi va '
            'sirka kislotasida erimaydi.',
        'ru':
            'Не путать с дрожжевыми грибами: они почкуются и не растворяются '
            'в уксусной кислоте.',
        'en':
            'Do not confuse with yeasts: they bud and do not dissolve in '
            'acetic acid.',
      }),
      [_wFungi],
    ),
  ),
  UrElement(
    id: 'rbc_dysmorphic',
    group: UrGroup.cells,
    name: _T({
      'uz': 'Dismorf eritrotsitlar',
      'ru': 'Дисморфные эритроциты',
      'en': 'Dysmorphic red blood cells',
    }),
    look: [
      UrFact(
        _T({
          'uz':
              'Shakli yoki o‘lchami g‘ayrioddiy; bo‘rtmalar va o‘simtalar '
              'bo‘ladi. Akantotsitlar (G1 hujayralar) — bir yoki bir nechta '
              'bo‘rtmali halqasimon tana.',
          'ru':
              'Необычной формы или размера; с пузырьками и выростами. '
              'Акантоциты (клетки G1) — кольцевидное тело с одним или '
              'несколькими выпячиваниями.',
          'en':
              'Abnormal shape or size, with blebs or protrusions. Acanthocytes '
              '(G1 cells) are ring-shaped bodies with one or more protruding '
              'blebs.',
        }),
        [_dParticles, _a22Rbc],
      ),
      UrFact(
        _T({
          'uz':
              'Aniqlash uchun fazali kontrast va maxsus tayyorgarlik kerak; '
              'yagona mezonlar yo‘q. Ertalabki siydik afzal.',
          'ru':
              'Нужны фазовый контраст и специальная подготовка; единых '
              'критериев нет. Предпочтительна утренняя моча.',
          'en':
              'Requires phase-contrast microscopy and special training; there '
              'are no unequivocal criteria. Morning urine is preferred.',
        }),
        [_dParticles],
      ),
    ],
    meaning: UrFact(
      _T({
        'uz':
            'Glomerulyar (buyrak koptokchasi) kasalligiga ishora qilishi '
            'mumkin; shakli oddiy eritrotsitlar ko‘pincha pastki siydik '
            'yo‘llaridan.',
        'ru':
            'Могут указывать на клубочковое поражение; эритроциты обычной '
            'формы чаще происходят из нижних мочевых путей.',
        'en':
            'May point to glomerular disease; red cells of normal shape '
            'usually come from the lower urinary tract.',
      }),
      [_a22Rbc, _dParticles, _a05Cells],
    ),
  ),
  UrElement(
    id: 'wbc',
    group: UrGroup.cells,
    name: _T({
      'uz': 'Leykotsitlar',
      'ru': 'Лейкоциты',
      'en': 'White blood cells',
    }),
    pics: [UrPic('u-wbc-1', 'urine-wbc'), UrPic('u-wbc-2', 'urine-wbc')],
    quiz: true,
    look: [
      UrFact(
        _T({
          'uz':
              'Butun: tiniq donador disklar, 10–15 µm, yadrosi ko‘rinishi '
              'mumkin; degeneratsiyalangan: buzilgan, kichraygan, kam '
              'donador; yiring — ko‘p degeneratsiyalangan hujayralar to‘dasi.',
          'ru':
              'Неизменённые: светлые зернистые диски 10–15 мкм, ядро может '
              'быть видно; дегенерированные: деформированные, сморщенные, '
              'менее зернистые; гной — скопления многих дегенерированных '
              'клеток.',
          'en':
              'Intact: clear granular discs, 10–15 µm, nuclei may be visible; '
              'degenerated: distorted, shrunken, less granular; pus: clumps '
              'of many degenerated cells.',
        }),
        [_wWbc],
      ),
      UrFact(
        _T({
          'uz': 'Ko‘pincha neytrofillar: eritrotsitdan katta, yadroli.',
          'ru': 'Чаще нейтрофилы: крупнее эритроцитов, с ядром.',
          'en': 'Mostly neutrophils: larger than red cells, nucleated.',
        }),
        [_a22Wbc],
      ),
    ],
    meaning: UrFact(
      _T({
        'uz':
            'Me’yorda erkaklarda k/m da 2 tadan, ayollarda 5 tadan kam. '
            'Simptomli bemorda k/m da 5 dan ortiq — siydik yo‘li infeksiyasiga '
            'mos; jinsiy infeksiyalar va toshlarda ham. Ko‘p leykotsit, '
            'ayniqsa to‘da bo‘lsa, infeksiyaga ishora qiladi.',
        'ru':
            'В норме у мужчин меньше 2, у женщин меньше 5 в п/з. У пациента с '
            'симптомами более 5 в п/з согласуется с инфекцией мочевых путей; '
            'бывает при ИППП и камнях. Много лейкоцитов, особенно скоплениями, '
            '— признак инфекции.',
        'en':
            'Normally fewer than 2 per HPF in men and fewer than 5 in women. '
            'More than 5 per HPF in a symptomatic patient is consistent with '
            'urinary infection; also seen with STIs and stones. Many white '
            'cells, especially in clumps, indicate infection.',
      }),
      [_a05Cells, _a22Wbc, _wWbc],
    ),
  ),
  UrElement(
    id: 'squamous',
    group: UrGroup.cells,
    name: _T({
      'uz': 'Yassi epiteliy',
      'ru': 'Плоский эпителий',
      'en': 'Squamous epithelial cells',
    }),
    look: [
      UrFact(
        _T({
          'uz':
              'Yirik, notekis shaklli, yadrosi kichik, sitoplazmasi mayda '
              'donador; leykotsitdan ancha katta.',
          'ru':
              'Крупные, неправильной формы, с маленьким ядром и мелкозернистой '
              'цитоплазмой; намного крупнее лейкоцитов.',
          'en':
              'Large and irregular, with a small nucleus and finely granular '
              'cytoplasm; much larger than white cells.',
        }),
        [_a05Cells, _a22Epi],
      ),
    ],
    meaning: UrFact(
      _T({
        'uz':
            'Uretraning distal uchdan biri va vulvani qoplaydi. K/m da 5 dan '
            'ortiq yirik yassi hujayra — namuna ifloslanganiga ishora; '
            'ifloslangan namunada ham gematuriya yoki piuriya infeksiyani '
            'taxmin qildiradi.',
        'ru':
            'Выстилает дистальную треть уретры и вульву. Более 5 крупных '
            'плоских клеток в п/з указывают на загрязнение пробы; но и при '
            'загрязнении гематурия или пиурия позволяют предположить '
            'инфекцию.',
        'en':
            'Lines the distal third of the urethra and the vulva. More than 5 '
            'large squamous cells per HPF suggest contamination; even so, '
            'haematuria or pyuria still suggests infection.',
      }),
      [_a22Epi, _a05Cells],
    ),
  ),
  UrElement(
    id: 'transitional',
    group: UrGroup.cells,
    name: _T({
      'uz': 'O‘tuvchi epiteliy (urotelial)',
      'ru': 'Переходный эпителий (уротелий)',
      'en': 'Transitional (urothelial) cells',
    }),
    look: [
      UrFact(
        _T({
          'uz':
              'Yassi hujayralardan kichikroq va yumaloqroq, yadrosi kattaroq.',
          'ru': 'Мельче и округлее плоских клеток, ядро крупнее.',
          'en': 'Smaller and rounder than squamous cells, with larger nuclei.',
        }),
        [_a05Cells],
      ),
      UrFact(
        _T({
          'uz':
              'JSST siydik nayi va jom hujayralarini o‘rtacha kattalikdagi, '
              'aniq yadroli oval hujayralar deb ta’riflaydi.',
          'ru':
              'ВОЗ описывает клетки мочеточника и лоханки как овальные клетки '
              'среднего размера с отчётливым ядром.',
          'en':
              'WHO describes ureteral and renal pelvic cells as medium-sized '
              'oval cells with a distinct nucleus.',
        }),
        [_wPelvic],
      ),
    ],
    meaning: UrFact(
      _T({
        'uz': 'Oz miqdorda bo‘lishi me’yoriy holat.',
        'ru': 'Небольшое количество — нормальная находка.',
        'en': 'Their presence in small numbers is normal.',
      }),
      [_a05Cells],
    ),
  ),
  UrElement(
    id: 'rte',
    group: UrGroup.cells,
    name: _T({
      'uz': 'Buyrak kanalchalari epiteliysi',
      'ru': 'Почечный (канальцевый) эпителий',
      'en': 'Renal tubular epithelial cells',
    }),
    look: [
      UrFact(
        _T({
          'uz':
              'Jom hujayralaridan kichik (1–2 leykotsit kattaligida), juda '
              'donador; yadrosi yaltiroq va aniq ko‘rinadi.',
          'ru':
              'Мельче клеток лоханки (размером с 1–2 лейкоцита), очень '
              'зернистые; ядро блестящее, хорошо видно.',
          'en':
              'Smaller than renal pelvic cells (the size of 1–2 white cells), '
              'very granular; the nucleus is shiny and clearly visible.',
        }),
        [_wRenalCells],
      ),
    ],
    meaning: UrFact(
      _T({
        'uz':
            'Jiddiy buyrak patologiyasiga ishora qilishi mumkin; deyarli '
            'doim siydikdagi oqsil bilan birga uchraydi.',
        'ru':
            'Может указывать на значимую почечную патологию; почти всегда '
            'сочетается с белком в моче.',
        'en':
            'May indicate significant renal disease; almost always present '
            'with protein in the urine.',
      }),
      [_a05Cells, _wRenalCells],
    ),
  ),
  // ── Silindrlar ──
  UrElement(
    id: 'cast_hyaline',
    group: UrGroup.casts,
    name: _T({
      'uz': 'Gialin silindr',
      'ru': 'Гиалиновый цилиндр',
      'en': 'Hyaline cast',
    }),
    pics: [UrPic('u-cast-hyaline-1', 'cast-hyaline')],
    quiz: true,
    look: [
      UrFact(
        _T({
          'uz':
              'Silindrlar uzun, ×40 da deyarli butun maydonni kesib o‘tadi. '
              'Gialin silindr tiniq, biroz yaltiroq, uchlari yumaloq yoki '
              'ingichkalashgan.',
          'ru':
              'Цилиндры длинные, при ×40 пересекают почти всё поле. '
              'Гиалиновый цилиндр прозрачный, слегка блестящий, концы '
              'закруглены или сужены.',
          'en':
              'Casts are long, crossing almost the whole field at ×40. A '
              'hyaline cast is transparent and slightly shiny, with rounded or '
              'tapered ends.',
        }),
        [_wCasts],
      ),
      UrFact(
        _T({
          'uz':
              'Silindr — Tamm–Xorsfall mukoproteini va kanalcha ichidagi '
              'narsalardan iborat quyqa; distal kanalcha yoki yig‘uvchi '
              'naychada siydik quyuqlashganda, turib qolganda yoki pH juda '
              'past bo‘lganda hosil bo‘ladi.',
          'ru':
              'Цилиндр — сгусток мукопротеина Тамма — Хорсфалла с содержимым '
              'канальца; образуется в дистальном канальце или собирательной '
              'трубке при концентрации мочи, стазе или очень низком pH.',
          'en':
              'A cast is a coagulum of Tamm–Horsfall mucoprotein and tubular '
              'contents, formed in the distal tubule or collecting duct during '
              'urinary concentration or stasis, or at very low pH.',
        }),
        [_a05Casts],
      ),
    ],
    meaning: UrFact(
      _T({
        'uz':
            'Sog‘lom odamda og‘ir jismoniy zo‘riqishdan keyin ham bo‘ladi; '
            'buyrak kasalligida (pielonefrit, surunkali buyrak kasalligi) '
            'ham uchraydi.',
        'ru':
            'Бывает и у здоровых после тяжёлой физической нагрузки; '
            'встречается и при болезнях почек (пиелонефрит, хроническая '
            'болезнь почек).',
        'en':
            'Found in healthy people after strenuous exercise; also occurs '
            'in kidney disease (pyelonephritis, chronic renal disease).',
      }),
      [_wCasts, _a05Casts, _a22CrystCasts],
    ),
    confuse: UrFact(
      _T({
        'uz':
            'Soxta silindrlar bilan adashtirmang: fosfat kristallari to‘dasi '
            '(kalta, cheti aniq) va shilliq (uchlari ipga aylanadi).',
        'ru':
            'Не путать с ложными цилиндрами: скопления фосфатов (короткие, '
            'чёткие) и слизь (концы переходят в нити).',
        'en':
            'Do not confuse with false casts: clumps of phosphate crystals '
            '(short, clear-cut) and mucus (ends tapering into threads).',
      }),
      [_wFalseCasts],
    ),
  ),
  UrElement(
    id: 'cast_granular',
    group: UrGroup.casts,
    name: _T({
      'uz': 'Donador silindr',
      'ru': 'Зернистый цилиндр',
      'en': 'Granular cast',
    }),
    pics: [
      UrPic('u-cast-granular-1', 'cast-granular'),
      UrPic(
        'u-cast-panel-1',
        'cast-panel',
        panel: _T({
          'uz': '(b) “loyqa-jigarrang” donador silindrlar',
          'ru': '(b) «грязно-коричневые» зернистые цилиндры',
          'en': '(b) “muddy brown” granular casts',
        }),
      ),
    ],
    quiz: true,
    look: [
      UrFact(
        _T({
          'uz':
              'Kaltaroq, yirik donachalar bilan to‘lgan, och sariq, uchlari '
              'yumaloq; mayda donador silindrda donachalar mayda va silindrni '
              'to‘ldirmaydi.',
          'ru':
              'Короче, заполнены крупными гранулами, бледно-жёлтые, концы '
              'закруглены; в мелкозернистом цилиндре гранулы мелкие и не '
              'заполняют его целиком.',
          'en':
              'Rather short, filled with large pale-yellow granules, rounded '
              'ends; fine granular casts have smaller granules that do not '
              'fill the cast.',
        }),
        [_wCasts],
      ),
    ],
    meaning: UrFact(
      _T({
        'uz':
            'Manbalar farq qiladi: AAFP 2022 — kanalcha shikastlanishiga '
            '(masalan, o‘tkir kanalcha nekrozi) ishora qilishi mumkin; AAFP '
            '2005 — kuchaygan buyrak kasalligi; JSST 2003 qo‘llanmasi esa '
            'ularni tashxisiy ahamiyatsiz deb hisoblaydi.',
        'ru':
            'Источники расходятся: AAFP 2022 — могут указывать на повреждение '
            'канальцев (например, острый канальцевый некроз); AAFP 2005 — '
            'на далеко зашедшую болезнь почек; руководство ВОЗ 2003 считает '
            'их диагностически незначимыми.',
        'en':
            'Sources differ: AAFP 2022 — may indicate tubular injury such as '
            'acute tubular necrosis; AAFP 2005 — advanced renal disease; the '
            'WHO 2003 manual regards them as of no diagnostic significance.',
      }),
      [_a22CrystCasts, _a05Casts, _wCasts],
    ),
    confuse: UrFact(
      _T({
        'uz':
            'Mayda donador silindrni amorf fosfatlar qisman qoplagan gialin '
            'silindr bilan adashtirmang.',
        'ru':
            'Не путать мелкозернистый цилиндр с гиалиновым, частично '
            'покрытым аморфными фосфатами.',
        'en':
            'Do not confuse fine granular casts with hyaline casts partly '
            'covered by amorphous phosphates.',
      }),
      [_wCasts],
    ),
  ),
  UrElement(
    id: 'cast_rbc',
    group: UrGroup.casts,
    name: _T({
      'uz': 'Eritrotsitar silindr',
      'ru': 'Эритроцитарный цилиндр',
      'en': 'Red cell cast',
    }),
    pics: [
      UrPic(
        'u-cast-panel-1',
        'cast-panel',
        panel: _T({
          'uz': '(d) eritrotsitar silindr',
          'ru': '(d) эритроцитарный цилиндр',
          'en': '(d) red cell cast',
        }),
      ),
    ],
    look: [
      UrFact(
        _T({
          'uz':
              'Ozmi-ko‘pmi degeneratsiyalangan eritrotsitlar bilan to‘lgan, '
              'jigarrang tusli silindr.',
          'ru':
              'Цилиндр, заполненный более или менее разрушенными '
              'эритроцитами, коричневатого цвета.',
          'en':
              'Filled with more or less degenerated red cells, brownish in '
              'colour.',
        }),
        [_wCasts],
      ),
    ],
    meaning: UrFact(
      _T({
        'uz':
            'Glomerulonefritga, glomerulyar gematuriyaga ishora qilishi '
            'mumkin (ko‘pincha oqsil va dismorf eritrotsitlar bilan); '
            'o‘tkir buyrak kasalligida uchraydi. Kontakt sportda me’yoriy '
            'topilma bo‘lishi ham mumkin.',
        'ru':
            'Может указывать на гломерулонефрит, клубочковую гематурию '
            '(часто вместе с белком и дисморфными эритроцитами); встречается '
            'при острой болезни почек. У занимающихся контактными видами '
            'спорта может быть и нормальной находкой.',
        'en':
            'May point to glomerulonephritis and glomerular haematuria (often '
            'with protein and dysmorphic red cells); found in acute kidney '
            'disease. May be a normal finding in contact-sport players.',
      }),
      [_a05Casts, _a05GlomUro, _wCasts],
    ),
  ),
  UrElement(
    id: 'cast_wbc',
    group: UrGroup.casts,
    name: _T({
      'uz': 'Leykotsitar silindr',
      'ru': 'Лейкоцитарный цилиндр',
      'en': 'White cell cast',
    }),
    pics: [
      UrPic(
        'u-cast-panel-1',
        'cast-panel',
        panel: _T({
          'uz': '(c) leykotsitar silindr',
          'ru': '(c) лейкоцитарный цилиндр',
          'en': '(c) white cell cast',
        }),
      ),
    ],
    look: [
      UrFact(
        _T({
          'uz': 'Butunlay leykotsitlar bilan to‘lgan silindr.',
          'ru': 'Цилиндр, целиком заполненный лейкоцитами.',
          'en': 'A cast completely filled with white cells.',
        }),
        [_wCasts],
      ),
    ],
    meaning: UrFact(
      _T({
        'uz':
            'Yallig‘lanish buyrakda ekanini ko‘rsatishi mumkin: pielonefrit, '
            'interstitsial nefrit, glomerulonefrit.',
        'ru':
            'Может указывать, что воспаление в почке: пиелонефрит, '
            'интерстициальный нефрит, гломерулонефрит.',
        'en':
            'Can localise inflammation to the kidney: pyelonephritis, '
            'interstitial nephritis, glomerulonephritis.',
      }),
      [_a05Casts, _a05Le, _wCasts],
    ),
    confuse: UrFact(
      _T({
        'uz':
            'Ichida bir nechta leykotsit bor gialin silindr bilan '
            'adashtirmang.',
        'ru':
            'Не путать с гиалиновым цилиндром, содержащим отдельные лейкоциты.',
        'en':
            'Do not confuse with a hyaline cast containing a few white cells.',
      }),
      [_wCasts],
    ),
  ),
  UrElement(
    id: 'cast_epithelial',
    group: UrGroup.casts,
    name: _T({
      'uz': 'Epitelial silindr',
      'ru': 'Эпителиальный цилиндр',
      'en': 'Epithelial (renal tubular) cast',
    }),
    pics: [
      UrPic(
        'u-cast-panel-1',
        'cast-panel',
        panel: _T({
          'uz': '(a) buyrak kanalchalari epiteliysi silindri',
          'ru': '(a) цилиндр из почечного канальцевого эпителия',
          'en': '(a) renal tubular epithelial cell cast',
        }),
      ),
    ],
    look: [
      UrFact(
        _T({
          'uz':
              'Och sariq epiteliy hujayralari bilan to‘lgan; bir tomchi 10 % '
              'sirka kislotasi hujayralarni aniqroq ko‘rsatadi.',
          'ru':
              'Заполнен бледно-жёлтыми эпителиальными клетками; капля 10 % '
              'уксусной кислоты делает клетки чётче.',
          'en':
              'Filled with pale-yellow epithelial cells; a drop of 10% acetic '
              'acid makes the cells more distinct.',
        }),
        [_wCasts],
      ),
    ],
    meaning: UrFact(
      _T({
        'uz':
            'Manbalar farq qiladi: AAFP 2005 — o‘tkir kanalcha nekrozi, '
            'interstitsial nefrit, eklampsiya, transplantat rad etilishi, '
            'og‘ir metallar; JSST 2003 — tashxisiy ahamiyatsiz.',
        'ru':
            'Источники расходятся: AAFP 2005 — острый канальцевый некроз, '
            'интерстициальный нефрит, эклампсия, отторжение трансплантата, '
            'тяжёлые металлы; ВОЗ 2003 — диагностически незначимы.',
        'en':
            'Sources differ: AAFP 2005 — acute tubular necrosis, interstitial '
            'nephritis, eclampsia, allograft rejection, heavy metals; WHO '
            '2003 — no diagnostic significance.',
      }),
      [_a05Casts, _wCasts],
    ),
  ),
  UrElement(
    id: 'cast_waxy',
    group: UrGroup.casts,
    name: _T({
      'uz': 'Mumsimon va keng silindrlar',
      'ru': 'Восковидные и широкие цилиндры',
      'en': 'Waxy and broad casts',
    }),
    look: [
      UrFact(
        _T({
          'uz':
              'AAFP jadvalida tarkibi “turli hujayralar” deb berilgan; '
              'ko‘rinishining batafsil ta’rifi bu bo‘lim manbalarida yo‘q.',
          'ru':
              'В таблице AAFP состав указан как «различные клетки»; подробного '
              'описания внешнего вида в источниках раздела нет.',
          'en':
              'The AAFP table gives their composition as “various cell '
              'types”; the sources of this section do not describe their '
              'appearance in detail.',
        }),
        [_a05Casts],
      ),
    ],
    meaning: UrFact(
      _T({
        'uz':
            'Mumsimon — kuchaygan buyrak kasalligiga, keng silindrlar — '
            'oxirgi bosqich buyrak kasalligiga ishora qilishi mumkin.',
        'ru':
            'Восковидные могут указывать на далеко зашедшую болезнь почек, '
            'широкие — на терминальную стадию.',
        'en':
            'Waxy casts may point to advanced renal disease, broad casts to '
            'end-stage renal disease.',
      }),
      [_a05Casts],
    ),
  ),
  UrElement(
    id: 'cast_fatty',
    group: UrGroup.casts,
    name: _T({
      'uz': 'Yog‘li silindr',
      'ru': 'Жировой цилиндр',
      'en': 'Fatty cast',
    }),
    look: [
      UrFact(
        _T({
          'uz':
              'Juda yaltiroq, sarg‘ish; chetlari o‘yiq va aniq, uchlari '
              'yumaloq. Efirda eriydi, sirka kislotasida erimaydi.',
          'ru':
              'Очень блестящий, желтоватый; края зазубрены и чётки, концы '
              'закруглены. Растворяется в эфире, но не в уксусной кислоте.',
          'en':
              'Very shiny and yellowish; indented, distinct edges and rounded '
              'ends. Soluble in ether but not in acetic acid.',
        }),
        [_wCasts],
      ),
    ],
    meaning: UrFact(
      _T({
        'uz':
            'Lipidga to‘la kanalcha hujayralaridan; nefrotik sindrom va og‘ir '
            'buyrak kasalligiga ishora qilishi mumkin.',
        'ru':
            'Из нагруженных липидами клеток канальцев; может указывать на '
            'нефротический синдром и тяжёлую болезнь почек.',
        'en':
            'From lipid-laden tubular cells; may point to nephrotic syndrome '
            'and severe kidney disease.',
      }),
      [_a05Casts, _wCasts],
    ),
  ),
  UrElement(
    id: 'false_casts',
    group: UrGroup.casts,
    name: _T({
      'uz': 'Soxta silindrlar va begona narsalar',
      'ru': 'Ложные цилиндры и посторонние примеси',
      'en': 'False casts and contaminants',
    }),
    look: [
      UrFact(
        _T({
          'uz':
              'Soxta silindrlar: fosfat kristallari to‘dasi (kalta, chetlari '
              'aniq) va tiniq shilliq to‘dasi (uchlari ipga aylanadi).',
          'ru':
              'Ложные цилиндры: скопления фосфатов (короткие, чёткие) и '
              'прозрачная слизь (концы переходят в нити).',
          'en':
              'False casts: clumps of phosphate crystals (short, clear-cut) '
              'and translucent mucus (ends tapering into threads).',
        }),
        [_wFalseCasts],
      ),
      UrFact(
        _T({
          'uz':
              'Iflos idish yoki ochiq qolgan siydikda: yog‘ tomchilari, kraxmal '
              '(Lyugolda ko‘k-qora), gul changi, tuklar, paxta tolalari, havo '
              'pufakchalari.',
          'ru':
              'При грязной посуде или открытой моче: капли жира, крахмал '
              '(с Люголем — сине-чёрный), пыльца, волосы, хлопковые волокна, '
              'пузырьки воздуха.',
          'en':
              'With dirty containers or urine left open: oil droplets, starch '
              '(blue-black with Lugol), pollen, hairs, cotton fibres, air '
              'bubbles.',
        }),
        [_wFalseCasts],
      ),
    ],
    meaning: UrFact(
      _T({
        'uz': 'Haqiqiy silindr deb yozilmaydi.',
        'ru': 'Не записываются как истинные цилиндры.',
        'en': 'Not to be reported as true casts.',
      }),
      [_wFalseCasts],
    ),
  ),
  // ── Kristallar ──
  UrElement(
    id: 'cryst_caox',
    group: UrGroup.crystals,
    name: _T({
      'uz': 'Kalsiy oksalat',
      'ru': 'Оксалат кальция',
      'en': 'Calcium oxalate',
    }),
    pics: [UrPic('u-cryst-caox-1', 'crystal-caox')],
    look: [
      UrFact(
        _T({
          'uz':
              'Kislotali siydikda. Konvertsimon (10–20 µm) yoki yeryong‘oqsimon '
              '(taxminan 50 µm); rangsiz, juda yaltiroq; o‘lchami turlicha. '
              'Monogidrat qutblangan yorug‘likda nur sindiradi.',
          'ru':
              'В кислой моче. Конвертики (10–20 мкм) или в форме арахиса '
              '(около 50 мкм); бесцветные, сильно блестящие; размер различен. '
              'Моногидрат двоякопреломляет в поляризованном свете.',
          'en':
              'In acid urine. Envelope-shaped (10–20 µm) or peanut-shaped '
              '(about 50 µm); colourless and very shiny; size varies. The '
              'monohydrate is birefringent in polarised light.',
        }),
        [_wCrystals, _a05Crystals, _a22CrystCasts],
      ),
    ],
    meaning: UrFact(
      _T({
        'uz': 'Sog‘lom odamlarda ham uchraydi.',
        'ru': 'Встречаются и у здоровых людей.',
        'en': 'Can appear in healthy people.',
      }),
      [_a05Crystals, _wCrystals],
    ),
  ),
  UrElement(
    id: 'cryst_uric',
    group: UrGroup.crystals,
    name: _T({
      'uz': 'Siydik kislotasi',
      'ru': 'Мочевая кислота',
      'en': 'Uric acid',
    }),
    pics: [UrPic('u-cryst-uric-1', 'crystal-uric')],
    quiz: true,
    look: [
      UrFact(
        _T({
          'uz':
              'Kislotali siydikda. 30–150 µm; kvadrat, romb, kub yoki '
              'atirgulsimon; sariqdan qizg‘ish-jigarranggacha.',
          'ru':
              'В кислой моче. 30–150 мкм; квадраты, ромбы, кубы или розетки; '
              'от жёлтых до красновато-бурых.',
          'en':
              'In acid urine. 30–150 µm; square, diamond, cubical or '
              'rose-shaped; yellow to brownish-red.',
        }),
        [_wCrystals, _a05Crystals],
      ),
    ],
    meaning: UrFact(
      _T({
        'uz':
            'Sog‘lom odamlarda ham uchraydi; siydik kislotasi toshlari '
            'kislotali siydik bilan bog‘liq.',
        'ru': 'Встречаются и у здоровых; уратные камни связаны с кислой мочой.',
        'en':
            'Can appear in healthy people; uric acid stones are associated '
            'with acid urine.',
      }),
      [_a05Crystals, _a22Ph],
    ),
  ),
  UrElement(
    id: 'cryst_triple',
    group: UrGroup.crystals,
    name: _T({
      'uz': 'Uch fosfat (struvit)',
      'ru': 'Трипельфосфаты (струвит)',
      'en': 'Triple phosphate (struvite)',
    }),
    pics: [UrPic('u-cryst-triple-1', 'crystal-triple')],
    quiz: true,
    look: [
      UrFact(
        _T({
          'uz':
              'Neytral yoki ishqoriy siydikda. 30–150 µm; to‘g‘ri burchakli '
              '(“tobut qopqog‘i”) yoki paporotnik bargi, yulduzsimon; rangsiz, '
              'yaltiroq.',
          'ru':
              'В нейтральной или щелочной моче. 30–150 мкм; прямоугольные '
              '(«крышки гроба») или в виде листа папоротника, звёзд; '
              'бесцветные, блестящие.',
          'en':
              'In neutral or alkaline urine. 30–150 µm; rectangular '
              '(“coffin-lid”) or fern-leaf or star-shaped; colourless and '
              'shiny.',
        }),
        [_wCrystals, _a05Crystals],
      ),
    ],
    meaning: UrFact(
      _T({
        'uz':
            'Me’yorda ham bo‘lishi mumkin, lekin ko‘pincha ishqoriy siydik va '
            'siydik yo‘li infeksiyasi (odatda Proteus) bilan bog‘liq.',
        'ru':
            'Могут быть и в норме, но часто связаны со щелочной мочой и '
            'инфекцией мочевых путей (обычно Proteus).',
        'en':
            'May be normal but are often associated with alkaline urine and '
            'urinary infection (typically Proteus species).',
      }),
      [_a05Crystals],
    ),
  ),
  UrElement(
    id: 'cryst_cystine',
    group: UrGroup.crystals,
    name: _T({'uz': 'Sistin', 'ru': 'Цистин', 'en': 'Cystine'}),
    pics: [UrPic('u-cryst-cystine-1', 'crystal-cystine')],
    quiz: true,
    look: [
      UrFact(
        _T({
          'uz':
              'Kislotali siydikda. 30–60 µm, oltiburchak plastinkalar; rangsiz, '
              'juda yaltiroq. Ammiakda eriydi — faqat yangi siydikda ko‘rinadi.',
          'ru':
              'В кислой моче. 30–60 мкм, шестиугольные пластинки; бесцветные, '
              'сильно блестящие. Растворяются в аммиаке — видны только в '
              'свежей моче.',
          'en':
              'In acid urine. 30–60 µm hexagonal plates; colourless and very '
              'shiny. Soluble in ammonia, so seen only in fresh urine.',
        }),
        [_wRareCrystals],
      ),
    ],
    meaning: UrFact(
      _T({
        'uz':
            'Sistinuriyaga (juda kam uchraydigan irsiy kasallik) ishora '
            'qiladi — natijani shifokorga yetkazing.',
        'ru':
            'Указывают на цистинурию (очень редкое наследственное '
            'заболевание) — сообщите результат врачу.',
        'en':
            'Point to cystinuria, a very rare hereditary disease — report the '
            'finding to the clinician.',
      }),
      [_wRareCrystals, _a05Crystals],
    ),
  ),
  UrElement(
    id: 'cryst_amorphous',
    group: UrGroup.crystals,
    name: _T({
      'uz': 'Amorf uratlar va fosfatlar',
      'ru': 'Аморфные ураты и фосфаты',
      'en': 'Amorphous urates and phosphates',
    }),
    look: [
      UrFact(
        _T({
          'uz':
              'Amorf cho‘kma — aniq shaklsiz mayda donachalar to‘dasi. Amorf '
              'fosfatlar (ishqoriy siydik): mayda oqish donachalar, 10 % sirka '
              'kislotasida eriydi. Amorf uratlar (kislotali siydik): juda mayda '
              'sarg‘ish zich to‘dalar, sirka kislotasida erimaydi, ozgina '
              'isitilganda eriydi.',
          'ru':
              'Аморфный осадок — скопления мелких гранул без определённой '
              'формы. Аморфные фосфаты (щелочная моча): мелкие беловатые '
              'гранулы, растворяются в 10 % уксусной кислоте. Аморфные ураты '
              '(кислая моча): очень мелкие желтоватые плотные скопления, не '
              'растворяются в уксусной кислоте, растворяются при лёгком '
              'нагревании.',
          'en':
              'Amorphous debris is clumps of small granules with no definite '
              'shape. Amorphous phosphates (alkaline urine): small whitish '
              'granules, soluble in 10% acetic acid. Amorphous urates (acid '
              'urine): very small yellowish compact clusters, insoluble in '
              'acetic acid, dissolve on gentle heating.',
        }),
        [_wCrystals, _wAmorphous],
      ),
    ],
    meaning: UrFact(
      _T({
        'uz':
            'Muzlatkichda saqlangan siydikda ko‘pincha uratlar ko‘p '
            'cho‘kadi — saqlash artefakti bo‘lishi mumkin.',
        'ru':
            'В моче из холодильника часто выпадает обильный осадок уратов — '
            'возможен артефакт хранения.',
        'en':
            'Urine kept in a refrigerator often shows a heavy urate '
            'precipitate — possibly a storage artefact.',
      }),
      [_wAmorphous],
    ),
  ),
  UrElement(
    id: 'cryst_cholesterol',
    group: UrGroup.crystals,
    name: _T({'uz': 'Xolesterin', 'ru': 'Холестерин', 'en': 'Cholesterol'}),
    look: [
      UrFact(
        _T({
          'uz':
              'Kislotali siydikda. 50–100 µm, bir tomonida kertigi bor '
              'to‘rtburchak plastinkalar; rangsiz, yaltiroq.',
          'ru':
              'В кислой моче. 50–100 мкм, квадратные пластинки с выемкой на '
              'одной стороне; бесцветные, блестящие.',
          'en':
              'In acid urine. 50–100 µm squarish plates with notches on one '
              'side; colourless and shiny.',
        }),
        [_wRareCrystals],
      ),
    ],
    meaning: UrFact(
      _T({
        'uz': 'Nefrotik sindromda uchraydi.',
        'ru': 'Встречаются при нефротическом синдроме.',
        'en': 'Found in patients with nephrotic syndrome.',
      }),
      [_wRareCrystals],
    ),
  ),
  UrElement(
    id: 'cryst_drug',
    group: UrGroup.crystals,
    name: _T({
      'uz': 'Dori kristallari (atsetilsulfanilamidlar)',
      'ru': 'Лекарственные кристаллы (ацетилсульфаниламиды)',
      'en': 'Drug crystals (acetyl sulfonamides)',
    }),
    look: [
      UrFact(
        _T({
          'uz':
              'Neytral yoki kislotali siydikda; shakli turlicha, ko‘pincha '
              'ignalar bog‘lamiga o‘xshaydi.',
          'ru':
              'В нейтральной или кислой моче; форма разная, часто как снопы '
              'игл.',
          'en':
              'In neutral or acid urine; shape varies, often like sheaves of '
              'needles.',
        }),
        [_wDrugCrystals],
      ),
    ],
    meaning: UrFact(
      _T({
        'uz':
            'Sulfanilamidlar bilan davolashdan keyin; buyrakni shikastlashi '
            'mumkin — topilsa, albatta xabar beriladi.',
        'ru':
            'После лечения сульфаниламидами; могут повреждать почки — о '
            'находке обязательно сообщают.',
        'en':
            'After sulfonamide treatment; they can damage the kidney, so '
            'report them.',
      }),
      [_wDrugCrystals],
    ),
  ),
  // ── Mikroorganizmlar va boshqalar ──
  UrElement(
    id: 'bacteria',
    group: UrGroup.organisms,
    name: _T({'uz': 'Bakteriyalar', 'ru': 'Бактерии', 'en': 'Bacteria'}),
    look: [
      UrFact(
        _T({
          'uz':
              'Ko‘p bo‘lmasa mikroskopda ko‘rish qiyin; yuqori kattalashtirishda '
              'gramm-manfiy tayoqchalar, streptokokk va stafilokokklarni '
              'ko‘rinishidan ajratish mumkin.',
          'ru':
              'Трудно увидеть, если их немного; при большом увеличении '
              'грамотрицательные палочки, стрептококки и стафилококки '
              'различимы по виду.',
          'en':
              'Hard to see unless abundant; under high power Gram-negative '
              'rods, streptococci and staphylococci can be told apart by '
              'appearance.',
        }),
        [_a22Bacteria, _a05Bacteria],
      ),
    ],
    meaning: UrFact(
      _T({
        'uz':
            'Sog‘lom odam siydigida deyarli mikroorganizm yo‘q. Bakteriyalar '
            'infeksiyada ham, ifloslanishda ham bo‘ladi; k/m da 5 ta bakteriya '
            'ekmada taxminan 100 000 KHB/mL ga to‘g‘ri keladi. Turini va '
            'miqdorini faqat ekma aniqlaydi.',
        'ru':
            'В моче здорового человека микроорганизмов практически нет. '
            'Бактерии бывают и при инфекции, и при загрязнении; 5 бактерий в '
            'п/з соответствуют примерно 100 000 КОЕ/мл в посеве. Вид и '
            'количество точно определяет только посев.',
        'en':
            'Urine from healthy people contains practically no organisms. '
            'Bacteria occur with infection and with contamination; 5 bacteria '
            'per HPF suggest about 100,000 CFU/mL on culture. Only culture '
            'identifies the organism and its count.',
      }),
      [_wBacteria, _a22Bacteria],
    ),
  ),
  UrElement(
    id: 'yeast',
    group: UrGroup.organisms,
    name: _T({
      'uz': 'Achitqi zamburug‘lari',
      'ru': 'Дрожжевые грибы',
      'en': 'Yeasts (fungi)',
    }),
    look: [
      UrFact(
        _T({
          'uz':
              '5–12 µm, turli kattalikdagi yumaloq yoki oval tanachalar, '
              'birga yotadi; kurtaklanish ko‘rinishi mumkin; sirka kislotasida '
              'erimaydi.',
          'ru':
              '5–12 мкм, круглые или овальные тельца разной величины, лежат '
              'вместе; может быть видно почкование; не растворяются в уксусной '
              'кислоте.',
          'en':
              '5–12 µm round or oval bodies of various sizes lying together; '
              'budding may be seen; insoluble in acetic acid.',
        }),
        [_wFungi],
      ),
    ],
    meaning: UrFact(
      _T({
        'uz':
            'Ba’zan glyukozali siydikda uchraydi; namuna yangi ekanini '
            'tekshiring.',
        'ru':
            'Иногда встречаются в моче с глюкозой; проверьте, свежая ли '
            'проба.',
        'en':
            'Occasionally present in urine containing glucose; check that '
            'the specimen is fresh.',
      }),
      [_wFungi],
    ),
    confuse: UrFact(
      _T({
        'uz': 'Eritrotsitlar bilan adashtirmang.',
        'ru': 'Не путать с эритроцитами.',
        'en': 'Do not confuse with red cells.',
      }),
      [_wFungi],
    ),
  ),
  UrElement(
    id: 'schistosoma',
    group: UrGroup.organisms,
    name: _T({
      'uz': 'Schistosoma haematobium tuxumlari',
      'ru': 'Яйца Schistosoma haematobium',
      'en': 'Schistosoma haematobium eggs',
    }),
    look: [
      UrFact(
        _T({
          'uz':
              'Yirik, 120–150 µm, bir uchida terminal tikani bor; ichida embrion '
              '(miratsidiy) ko‘rinadi. Eritrotsitlar bilan birga topiladi.',
          'ru':
              'Крупные, 120–150 мкм, с терминальным шипом на одном конце; '
              'внутри виден зародыш (мирацидий). Находят вместе с '
              'эритроцитами.',
          'en':
              'Large, about 120–150 µm, with a terminal spine at one end; an '
              'embryo (miracidium) is visible inside. Found together with red '
              'cells.',
        }),
        [_wSchisto, _wEggs],
      ),
    ],
    meaning: UrFact(
      _T({
        'uz':
            'Siydik shistosomozi (endemik hududlarda). Bilvosita birinchi '
            'belgi — gematuriya va/yoki proteinuriya; ko‘zga ko‘rinadigan '
            'gematuriya kuchli invaziyani ko‘rsatadi.',
        'ru':
            'Мочеполовой шистосомоз (в эндемичных районах). Первый косвенный '
            'признак — гематурия и/или протеинурия; макрогематурия говорит о '
            'сильной инвазии.',
        'en':
            'Urinary schistosomiasis (in endemic areas). The first indirect '
            'evidence is haematuria and/or proteinuria; gross haematuria '
            'indicates heavy infection.',
      }),
      [_wSchisto],
    ),
  ),
];

UrElement? urElement(String id) =>
    urElements.where((e) => e.id == id).firstOrNull;

// ───────────────────────── 5. Natijani o'qish ─────────────────────────

/// O'qish yordamchisida tanlanadigan topilmalar (musbat yoki ko'paygan).
enum UrFinding {
  blood,
  protein,
  glucose,
  ketones,
  bilirubin,
  urobilinogen,
  nitrite,
  leukocyteEsterase,
  alkalinePh,
  rbc,
  dysmorphicRbc,
  rbcCast,
  wbc,
  wbcCast,
  hyalineCast,
  granularCast,
  waxyCast,
  rteCells,
  squamous,
  bacteria,
}

enum UrFindingKind { strip, sediment }

class UrFindingInfo {
  const UrFindingInfo(this.kind, this.label, this.note, {this.element});

  final UrFindingKind kind;
  final LocalizedText label;

  /// Nimaga ishora qilishi mumkin (tashxis emas).
  final UrFact note;

  /// Tegishli cho'kma kartasi ([urElements] id) yoki `null`.
  final String? element;
}

const urFindingInfo = <UrFinding, UrFindingInfo>{
  UrFinding.blood: UrFindingInfo(
    UrFindingKind.strip,
    _T({
      'uz': 'Qon (chiziqda)',
      'ru': 'Кровь (полоска)',
      'en': 'Blood (strip)',
    }),
    UrFact(
      _T({
        'uz':
            'Gematuriya, gemoglobinuriya yoki miyoglobinuriya; mikroskopiya '
            'bilan tasdiqlanadi.',
        'ru':
            'Гематурия, гемоглобинурия или миоглобинурия; подтверждают '
            'микроскопией.',
        'en':
            'Haematuria, haemoglobinuria or myoglobinuria; confirm by '
            'microscopy.',
      }),
      [_a05Hematuria, _a22Blood],
    ),
  ),
  UrFinding.protein: UrFindingInfo(
    UrFindingKind.strip,
    _T({'uz': 'Oqsil ≥ 1+', 'ru': 'Белок ≥ 1+', 'en': 'Protein ≥ 1+'}),
    UrFact(
      _T({
        'uz':
            'O‘tkinchi (isitma, zo‘riqish, suvsizlanish, ortostatik) yoki '
            'doimiy proteinuriya; 1+ va undan yuqori glomerulyar '
            'shikastlanishga ishora qilishi mumkin. Albumin/kreatinin '
            'nisbati bilan miqdoriy tekshiriladi.',
        'ru':
            'Транзиторная (лихорадка, нагрузка, обезвоживание, ортостаз) '
            'или стойкая протеинурия; 1+ и выше может указывать на '
            'клубочковое повреждение. Уточняют количественно — отношение '
            'альбумин/креатинин.',
        'en':
            'Transient (fever, exercise, dehydration, orthostatic) or '
            'persistent proteinuria; 1+ or more may suggest glomerular injury. '
            'Quantify with an albumin/creatinine ratio.',
      }),
      [_a22Protein, _a22Sort],
    ),
  ),
  UrFinding.glucose: UrFindingInfo(
    UrFindingKind.strip,
    _T({'uz': 'Glyukoza', 'ru': 'Глюкоза', 'en': 'Glucose'}),
    UrFact(
      _T({
        'uz':
            'Qandli diabet, SGLT-2 ingibitorlari, homiladorlik; qondagi '
            'glyukoza me’yorda bo‘lsa — Fankoni sindromi.',
        'ru':
            'Сахарный диабет, ингибиторы SGLT-2, беременность; при '
            'нормальной глюкозе крови — синдром Фанкони.',
        'en':
            'Diabetes, SGLT-2 inhibitors, pregnancy; with normal blood '
            'glucose — Fanconi syndrome.',
      }),
      [_a22Glucose, _a22Table2],
    ),
  ),
  UrFinding.ketones: UrFindingInfo(
    UrFindingKind.strip,
    _T({'uz': 'Ketonlar', 'ru': 'Кетоны', 'en': 'Ketones'}),
    UrFact(
      _T({
        'uz':
            'Diabetik ketoatsidoz, ketogen parhez, ochlik yoki yetarli '
            'ovqatlanmaslik, ba’zan homiladorlik.',
        'ru':
            'Диабетический кетоацидоз, кетогенная диета, голодание или '
            'недостаточное питание, иногда беременность.',
        'en':
            'Diabetic ketoacidosis, ketogenic diet, starvation or inadequate '
            'nutrition, sometimes pregnancy.',
      }),
      [_a22Ketones, _a22Table2],
    ),
  ),
  UrFinding.bilirubin: UrFindingInfo(
    UrFindingKind.strip,
    _T({'uz': 'Bilirubin', 'ru': 'Билирубин', 'en': 'Bilirubin'}),
    UrFact(
      _T({
        'uz': 'Jigar va o‘t yo‘llari kasalligini tekshirishga asos.',
        'ru': 'Повод обследовать печень и жёлчные пути.',
        'en': 'Prompts investigation for hepatobiliary disease.',
      }),
      [_a22Bili],
    ),
  ),
  UrFinding.urobilinogen: UrFindingInfo(
    UrFindingKind.strip,
    _T({
      'uz': 'Urobilinogen oshgan',
      'ru': 'Уробилиноген повышен',
      'en': 'Urobilinogen raised',
    }),
    UrFact(
      _T({
        'uz': 'Gemoliz yoki jigar kasalligi; ba’zan me’yoriy topilma.',
        'ru': 'Гемолиз или болезнь печени; иногда нормальная находка.',
        'en': 'Haemolysis or liver disease; sometimes a normal finding.',
      }),
      [_a22Bili, _a22Table2],
    ),
  ),
  UrFinding.nitrite: UrFindingInfo(
    UrFindingKind.strip,
    _T({'uz': 'Nitrit', 'ru': 'Нитриты', 'en': 'Nitrite'}),
    UrFact(
      _T({
        'uz':
            'Nitrat qaytaruvchi bakteriyalar ko‘p; simptomli bemorda siydik '
            'yo‘li infeksiyasini kuchli taxmin qildiradi.',
        'ru':
            'Много бактерий, восстанавливающих нитраты; у пациента с '
            'симптомами сильно указывает на инфекцию мочевых путей.',
        'en':
            'Nitrate-reducing bacteria in significant numbers; in a '
            'symptomatic patient strongly suggests urinary infection.',
      }),
      [_a05Nitrite, _a22Sort],
    ),
  ),
  UrFinding.leukocyteEsterase: UrFindingInfo(
    UrFindingKind.strip,
    _T({
      'uz': 'Leykotsitar esteraza',
      'ru': 'Лейкоцитарная эстераза',
      'en': 'Leukocyte esterase',
    }),
    UrFact(
      _T({
        'uz':
            'Piuriya: siydik yo‘li infeksiyasi, yallig‘lanish, jinsiy yo‘l '
            'bilan yuqadigan infeksiya.',
        'ru': 'Пиурия: инфекция мочевых путей, воспаление, ИППП.',
        'en':
            'Pyuria: urinary infection, inflammation, sexually transmitted '
            'infection.',
      }),
      [_a05Le, _a22Table2],
    ),
  ),
  UrFinding.alkalinePh: UrFindingInfo(
    UrFindingKind.strip,
    _T({
      'uz': 'pH ishqoriy (7,8–8,0)',
      'ru': 'pH щелочной (7,8–8,0)',
      'en': 'Alkaline pH (7.8–8.0)',
    }),
    UrFact(
      _T({
        'uz':
            'Siydik yo‘li infeksiyasi, vegetarian ovqat; turib qolgan namuna '
            'ham ishqoriylashadi.',
        'ru':
            'Инфекция мочевых путей, вегетарианская диета; постоявшая проба '
            'тоже защелачивается.',
        'en':
            'Urinary infection, vegetarian diet; a stale sample also turns '
            'alkaline.',
      }),
      [_wPh, _dStrip],
    ),
  ),
  UrFinding.rbc: UrFindingInfo(
    UrFindingKind.sediment,
    _T({
      'uz': 'Eritrotsitlar ≥ 3 k/m da',
      'ru': 'Эритроциты ≥ 3 в п/з',
      'en': 'Red cells ≥ 3/HPF',
    }),
    UrFact(
      _T({
        'uz':
            'Kattalarda mikrogematuriya mezoni; sabablari zararsizdan '
            '(zo‘riqish, hayz) jiddiygacha.',
        'ru':
            'Критерий микрогематурии у взрослых; причины — от безобидных '
            '(нагрузка, менструация) до серьёзных.',
        'en':
            'The adult microhaematuria criterion; causes range from benign '
            '(exercise, menses) to serious.',
      }),
      [_a22Rbc, _a05Hematuria],
    ),
    element: 'rbc',
  ),
  UrFinding.dysmorphicRbc: UrFindingInfo(
    UrFindingKind.sediment,
    _T({
      'uz': 'Dismorf eritrotsitlar',
      'ru': 'Дисморфные эритроциты',
      'en': 'Dysmorphic red cells',
    }),
    UrFact(
      _T({
        'uz': 'Glomerulyar kasallikka ishora qilishi mumkin.',
        'ru': 'Могут указывать на клубочковое поражение.',
        'en': 'May point to glomerular disease.',
      }),
      [_a22Rbc, _dParticles],
    ),
    element: 'rbc_dysmorphic',
  ),
  UrFinding.rbcCast: UrFindingInfo(
    UrFindingKind.sediment,
    _T({
      'uz': 'Eritrotsitar silindrlar',
      'ru': 'Эритроцитарные цилиндры',
      'en': 'Red cell casts',
    }),
    UrFact(
      _T({
        'uz': 'Glomerulonefritga ishora qilishi mumkin.',
        'ru': 'Могут указывать на гломерулонефрит.',
        'en': 'May point to glomerulonephritis.',
      }),
      [_a05Casts],
    ),
    element: 'cast_rbc',
  ),
  UrFinding.wbc: UrFindingInfo(
    UrFindingKind.sediment,
    _T({
      'uz': 'Leykotsitlar > 5 k/m da',
      'ru': 'Лейкоциты > 5 в п/з',
      'en': 'White cells > 5/HPF',
    }),
    UrFact(
      _T({
        'uz':
            'Simptomli bemorda siydik yo‘li infeksiyasiga mos; jinsiy '
            'infeksiyalar va toshlarda ham.',
        'ru':
            'У пациента с симптомами согласуется с инфекцией мочевых путей; '
            'бывает при ИППП и камнях.',
        'en':
            'Consistent with urinary infection in a symptomatic patient; '
            'also with STIs and stones.',
      }),
      [_a22Wbc],
    ),
    element: 'wbc',
  ),
  UrFinding.wbcCast: UrFindingInfo(
    UrFindingKind.sediment,
    _T({
      'uz': 'Leykotsitar silindrlar',
      'ru': 'Лейкоцитарные цилиндры',
      'en': 'White cell casts',
    }),
    UrFact(
      _T({
        'uz':
            'Yallig‘lanish buyrakda: pielonefrit, interstitsial nefrit, '
            'glomerulonefrit.',
        'ru':
            'Воспаление в почке: пиелонефрит, интерстициальный нефрит, '
            'гломерулонефрит.',
        'en':
            'Inflammation within the kidney: pyelonephritis, interstitial '
            'nephritis, glomerulonephritis.',
      }),
      [_a05Casts, _a05Le],
    ),
    element: 'cast_wbc',
  ),
  UrFinding.hyalineCast: UrFindingInfo(
    UrFindingKind.sediment,
    _T({
      'uz': 'Gialin silindrlar',
      'ru': 'Гиалиновые цилиндры',
      'en': 'Hyaline casts',
    }),
    UrFact(
      _T({
        'uz':
            'Me’yorda ham (og‘ir zo‘riqishdan keyin) yoki buyrak kasalligida.',
        'ru': 'Бывают в норме (после тяжёлой нагрузки) или при болезни почек.',
        'en': 'May be normal (after strenuous exercise) or occur in kidney disease.',
      }),
      [_wCasts, _a05Casts],
    ),
    element: 'cast_hyaline',
  ),
  UrFinding.granularCast: UrFindingInfo(
    UrFindingKind.sediment,
    _T({
      'uz': 'Donador silindrlar',
      'ru': 'Зернистые цилиндры',
      'en': 'Granular casts',
    }),
    UrFact(
      _T({
        'uz':
            'Kanalcha shikastlanishi (masalan, o‘tkir kanalcha nekrozi) '
            'yoki kuchaygan buyrak kasalligi; manbalar ahamiyatini turlicha '
            'baholaydi.',
        'ru':
            'Повреждение канальцев (например, острый канальцевый некроз) '
            'или далеко зашедшая болезнь почек; источники оценивают значение '
            'по-разному.',
        'en':
            'Tubular injury (e.g. acute tubular necrosis) or advanced renal '
            'disease; sources rate their significance differently.',
      }),
      [_a22CrystCasts, _a05Casts, _wCasts],
    ),
    element: 'cast_granular',
  ),
  UrFinding.waxyCast: UrFindingInfo(
    UrFindingKind.sediment,
    _T({
      'uz': 'Mumsimon yoki keng silindrlar',
      'ru': 'Восковидные или широкие цилиндры',
      'en': 'Waxy or broad casts',
    }),
    UrFact(
      _T({
        'uz': 'Kuchaygan yoki oxirgi bosqich buyrak kasalligi.',
        'ru': 'Далеко зашедшая или терминальная болезнь почек.',
        'en': 'Advanced or end-stage renal disease.',
      }),
      [_a05Casts],
    ),
    element: 'cast_waxy',
  ),
  UrFinding.rteCells: UrFindingInfo(
    UrFindingKind.sediment,
    _T({
      'uz': 'Buyrak kanalchalari epiteliysi',
      'ru': 'Почечный эпителий',
      'en': 'Renal tubular cells',
    }),
    UrFact(
      _T({
        'uz': 'Jiddiy buyrak patologiyasi; odatda oqsil bilan birga.',
        'ru': 'Значимая почечная патология; обычно вместе с белком.',
        'en': 'Significant renal disease; usually together with protein.',
      }),
      [_a05Cells, _wRenalCells],
    ),
    element: 'rte',
  ),
  UrFinding.squamous: UrFindingInfo(
    UrFindingKind.sediment,
    _T({
      'uz': 'Yassi epiteliy > 5 k/m da',
      'ru': 'Плоский эпителий > 5 в п/з',
      'en': 'Squamous cells > 5/HPF',
    }),
    UrFact(
      _T({
        'uz': 'Namuna ifloslanganiga ishora.',
        'ru': 'Указывает на загрязнение пробы.',
        'en': 'Suggests a contaminated sample.',
      }),
      [_a22Epi],
    ),
    element: 'squamous',
  ),
  UrFinding.bacteria: UrFindingInfo(
    UrFindingKind.sediment,
    _T({'uz': 'Bakteriyalar', 'ru': 'Бактерии', 'en': 'Bacteria'}),
    UrFact(
      _T({
        'uz': 'Infeksiya yoki ifloslanish; turini va sonini ekma aniqlaydi.',
        'ru': 'Инфекция или загрязнение; вид и число определяет посев.',
        'en':
            'Infection or contamination; culture identifies the organism and '
            'count.',
      }),
      [_a22Bacteria, _wBacteria],
    ),
    element: 'bacteria',
  ),
};

/// Topilmalar birikmasi bo'yicha qo'shimcha izohlar (manbada aytilgan
/// birikmalar).
enum UrCombo {
  bloodWithoutRbc,
  glomerularPattern,
  urologicPattern,
  nitriteAndLe,
  leWithoutNitrite,
  contamination,
  ureaseAlkaline,
}

const urComboInfo = <UrCombo, UrFact>{
  UrCombo.bloodWithoutRbc: UrFact(
    _T({
      'uz':
          'Chiziqda qon bor, cho‘kmada eritrotsit belgilanmagan: suyultirilgan '
          'siydikda eritrotsitlar lizlangan bo‘lishi mumkin; aniq qonli '
          'siydikda — tomir ichi gemolizi yoki rabdomioliz (gemoglobin, '
          'miyoglobin). Kechikish ham sabab bo‘lishi mumkin.',
      'ru':
          'Кровь на полоске, но эритроциты в осадке не отмечены: в '
          'разведённой моче эритроциты могли лизироваться; при явно '
          'кровянистой моче — внутрисосудистый гемолиз или рабдомиолиз '
          '(гемоглобин, миоглобин). Причиной может быть и задержка.',
      'en':
          'Blood on the strip but no red cells marked in the sediment: red '
          'cells may have lysed in dilute urine; with grossly bloody urine — '
          'intravascular haemolysis or rhabdomyolysis (haemoglobin, '
          'myoglobin). Delay can also be a cause.',
    }),
    [_dStrip, _a05Hematuria],
  ),
  UrCombo.glomerularPattern: UrFact(
    _T({
      'uz':
          'Dismorf eritrotsitlar va/yoki eritrotsitar silindrlar — '
          'glomerulyar gematuriya uchun ta’riflangan belgilar; ko‘pincha '
          'sezilarli proteinuriya bilan birga. Shifokor buyrak faoliyatini '
          'va oqsil miqdorini (24 soatlik siydik yoki oqsil/kreatinin '
          'nisbati) baholaydi.',
      'ru':
          'Дисморфные эритроциты и/или эритроцитарные цилиндры — признаки, '
          'описанные для клубочковой гематурии; часто вместе со значимой '
          'протеинурией. Врач оценивает функцию почек и количество белка '
          '(суточная моча или отношение белок/креатинин).',
      'en':
          'Dysmorphic red cells and/or red cell casts are the features '
          'described for glomerular haematuria, often with significant '
          'proteinuria. The clinician assesses renal function and protein '
          'excretion (24-hour urine or protein/creatinine ratio).',
    }),
    [_a05GlomUro, _a22Rbc],
  ),
  UrCombo.urologicPattern: UrFact(
    _T({
      'uz':
          'Eritrotsitlar bor, lekin oqsil, dismorf eritrotsit va '
          'eritrotsitar silindr belgilanmagan: bu urologik manba (tosh, '
          'infeksiya, o‘sma) uchun ta’riflangan ko‘rinish. Urologik '
          'baholash shifokor qaroriga ko‘ra.',
      'ru':
          'Эритроциты есть, но белок, дисморфные эритроциты и '
          'эритроцитарные цилиндры не отмечены: такая картина описана для '
          'урологического источника (камни, инфекция, опухоль). '
          'Урологическое обследование — по решению врача.',
      'en':
          'Red cells without protein, dysmorphic cells or red cell casts: '
          'this is the picture described for a urological source (stones, '
          'infection, tumour). Urological work-up is the clinician’s '
          'decision.',
    }),
    [_a05GlomUro, _a22Rbc],
  ),
  UrCombo.nitriteAndLe: UrFact(
    _T({
      'uz':
          'Nitrit va leykotsitar esteraza birga — siydik yo‘li infeksiyasi '
          'ehtimoli yuqori; simptomlar bo‘lsa ekma tavsiya etiladi.',
      'ru':
          'Нитриты вместе с лейкоцитарной эстеразой — инфекция мочевых путей '
          'вероятна; при симптомах рекомендован посев.',
      'en':
          'Nitrite together with leukocyte esterase — urinary infection is '
          'likely; urine culture is recommended when symptoms are present.',
    }),
    [_a05Table3, _a22Sort, _a22Bacteria],
  ),
  UrCombo.leWithoutNitrite: UrFact(
    _T({
      'uz':
          'Piuriya belgisi bor, nitrit esa belgilanmagan: manfiy nitrit '
          'infeksiyani istisno qilmaydi (masalan, Enterococcus, qovuqda '
          '4 soatdan kam turgan siydik). Ekma manfiy bo‘lsa — steril '
          'piuriya sabablari.',
      'ru':
          'Есть признаки пиурии, а нитриты не отмечены: отрицательные '
          'нитриты не исключают инфекцию (например, Enterococcus, моча '
          'меньше 4 часов в пузыре). При отрицательном посеве — причины '
          'стерильной пиурии.',
      'en':
          'Signs of pyuria without nitrite: a negative nitrite does not rule '
          'out infection (e.g. Enterococcus, urine held under 4 hours). If '
          'culture is negative, consider causes of sterile pyuria.',
    }),
    [_a22LeNitrite, _a22Sort, _a05Le],
  ),
  UrCombo.contamination: UrFact(
    _T({
      'uz':
          'Yassi epiteliy ko‘p — namuna ifloslangan bo‘lishi mumkin; '
          'shunda ham gematuriya yoki piuriya infeksiyani taxmin qildiradi. '
          'To‘g‘ri yig‘ilgan (o‘rta porsiya) namunani takrorlash haqida '
          'o‘ylang.',
      'ru':
          'Много плоского эпителия — проба может быть загрязнена; но и тогда '
          'гематурия или пиурия позволяют предположить инфекцию. Рассмотрите '
          'повтор правильно собранной (средней) порции.',
      'en':
          'Many squamous cells — the sample may be contaminated; even so, '
          'haematuria or pyuria still suggests infection. Consider repeating '
          'a correctly collected midstream sample.',
    }),
    [_a22Epi, _a22Collect],
  ),
  UrCombo.ureaseAlkaline: UrFact(
    _T({
      'uz':
          'Ishqoriy pH bilan bakteriyalar yoki nitrit — ureaza hosil '
          'qiluvchi bakteriyalar (masalan, Proteus) bilan infeksiyaga mos; '
          'struvit kristallari va toshlar bilan bog‘liq bo‘lishi mumkin.',
      'ru':
          'Щелочной pH вместе с бактериями или нитритами согласуется с '
          'инфекцией уреазообразующими бактериями (например, Proteus); '
          'может сочетаться с кристаллами и камнями струвита.',
      'en':
          'Alkaline pH with bacteria or nitrite fits infection with '
          'urease-producing bacteria (e.g. Proteus), which may be associated '
          'with struvite crystals and stones.',
    }),
    [_a22Ph, _a05Crystals],
  ),
};

// ───────────────────────── 6. Mashq ─────────────────────────

/// Bilim savoli: birinchi variant — to'g'ri javob (ekranda aralashtiriladi).
class UrQuizItem {
  const UrQuizItem(this.id, this.prompt, this.options, this.basis, this.refs);

  final String id;
  final LocalizedText prompt;
  final List<LocalizedText> options;
  final LocalizedText basis;
  final List<CalcRef> refs;
}

const urQuizItems = <UrQuizItem>[
  UrQuizItem(
    'ur-q-blood-myoglobin',
    _T({
      'uz':
          'Qaysi test-chiziq maydonchasi miyoglobin bilan ham musbat bo‘ladi?',
      'ru': 'Какая зона тест-полоски положительна и при миоглобине?',
      'en': 'Which strip pad also turns positive with myoglobin?',
    }),
    [
      _T({'uz': 'Qon', 'ru': 'Кровь', 'en': 'Blood'}),
      _T({'uz': 'Nitrit', 'ru': 'Нитриты', 'en': 'Nitrite'}),
      _T({'uz': 'Bilirubin', 'ru': 'Билирубин', 'en': 'Bilirubin'}),
      _T({'uz': 'Glyukoza', 'ru': 'Глюкоза', 'en': 'Glucose'}),
    ],
    _T({
      'uz':
          'Qon maydonchasi peroksidaza faolligini aniqlaydi: eritrotsitlar, '
          'gemoglobin va miyoglobin ham reaksiya beradi — mikroskopiya ajratadi.',
      'ru':
          'Зона «кровь» выявляет пероксидазную активность: реагируют '
          'эритроциты, гемоглобин и миоглобин — различает микроскопия.',
      'en':
          'The blood pad detects peroxidase activity: red cells, haemoglobin '
          'and myoglobin all react — microscopy tells them apart.',
    }),
    [_a05Hematuria],
  ),
  UrQuizItem(
    'ur-q-nitrite-negative',
    _T({
      'uz': 'Simptomli bemorda nitrit manfiy. Bu nimani anglatadi?',
      'ru': 'У пациента с симптомами нитриты отрицательные. Что это значит?',
      'en': 'Nitrite is negative in a symptomatic patient. What does it mean?',
    }),
    [
      _T({
        'uz': 'Infeksiya istisno qilinmaydi',
        'ru': 'Инфекция не исключена',
        'en': 'Infection is not ruled out',
      }),
      _T({
        'uz': 'Infeksiya istisno qilinadi',
        'ru': 'Инфекция исключена',
        'en': 'Infection is ruled out',
      }),
      _T({
        'uz': 'Namuna albatta ifloslangan',
        'ru': 'Проба обязательно загрязнена',
        'en': 'The sample must be contaminated',
      }),
      _T({
        'uz': 'Buyrak kanalchalari shikastlangan',
        'ru': 'Повреждены почечные канальцы',
        'en': 'The renal tubules are damaged',
      }),
    ],
    _T({
      'uz':
          'Nitrit spetsifik, lekin sezgir emas: Enterococcus kabi bakteriyalar '
          'nitrit hosil qilmaydi, siydik qovuqda 4 soatdan kam tursa ham '
          'manfiy chiqadi.',
      'ru':
          'Нитритный тест специфичен, но не чувствителен: бактерии вроде '
          'Enterococcus не образуют нитриты, а при пребывании мочи в пузыре '
          'меньше 4 часов тест тоже отрицателен.',
      'en':
          'The nitrite test is specific but not sensitive: bacteria such as '
          'Enterococcus do not produce nitrite, and urine held under 4 hours '
          'also gives a negative result.',
    }),
    [_a22Sort, _a22LeNitrite],
  ),
  UrQuizItem(
    'ur-q-vitamin-c',
    _T({
      'uz': 'Katta dozada C vitamini glyukoza maydonchasiga qanday ta’sir qiladi?',
      'ru': 'Как большие дозы витамина C влияют на зону глюкозы?',
      'en': 'How do large doses of vitamin C affect the glucose pad?',
    }),
    [
      _T({
        'uz': 'Soxta manfiy natija beradi',
        'ru': 'Дают ложноотрицательный результат',
        'en': 'They give a false-negative result',
      }),
      _T({
        'uz': 'Soxta musbat natija beradi',
        'ru': 'Дают ложноположительный результат',
        'en': 'They give a false-positive result',
      }),
      _T({
        'uz': 'Hech qanday ta’sir qilmaydi',
        'ru': 'Никак не влияют',
        'en': 'They have no effect',
      }),
      _T({
        'uz': 'Faqat pH ni oshiradi',
        'ru': 'Только повышают pH',
        'en': 'They only raise the pH',
      }),
    ],
    _T({
      'uz':
          'Askorbin kislota glyukozaoksidaza reaksiyasining sezgirligini '
          'pasaytiradi; test oxirgi qabuldan kamida 1 kun keyin takrorlanadi.',
      'ru':
          'Аскорбиновая кислота снижает чувствительность глюкозооксидазной '
          'реакции; тест повторяют не ранее чем через сутки после приёма.',
      'en':
          'Ascorbic acid lowers the sensitivity of the glucose oxidase '
          'reaction; repeat the test at least one day after the last intake.',
    }),
    [_dStrip, _a22Table2],
  ),
  UrQuizItem(
    'ur-q-protein-albumin',
    _T({
      'uz': 'Oqsil maydonchasi asosan qaysi oqsilga sezgir?',
      'ru': 'К какому белку наиболее чувствительна зона белка?',
      'en': 'The protein pad is most sensitive to which protein?',
    }),
    [
      _T({'uz': 'Albumin', 'ru': 'Альбумин', 'en': 'Albumin'}),
      _T({
        'uz': 'Yengil zanjirlar (Bens-Jons)',
        'ru': 'Лёгкие цепи (Бенс-Джонс)',
        'en': 'Light chains (Bence Jones)',
      }),
      _T({
        'uz': 'Gamma-globulinlar',
        'ru': 'Гамма-глобулины',
        'en': 'Gamma globulins',
      }),
      _T({'uz': 'Miyoglobin', 'ru': 'Миоглобин', 'en': 'Myoglobin'}),
    ],
    _T({
      'uz':
          'Chiziq albuminga eng sezgir; yengil zanjirlar va globulinlar '
          'ko‘rinmasligi mumkin.',
      'ru':
          'Полоска наиболее чувствительна к альбумину; лёгкие цепи и '
          'глобулины может не выявить.',
      'en':
          'The strip is most sensitive to albumin; light chains and '
          'globulins may be missed.',
    }),
    [_a22Protein, _a05Protein],
  ),
  UrQuizItem(
    'ur-q-particles-time',
    _T({
      'uz':
          'Yevropa qo‘llanmasiga ko‘ra cho‘kma xona haroratida qachongacha '
          'ko‘rilishi kerak?',
      'ru':
          'По европейскому руководству в какой срок исследуют осадок при '
          'комнатной температуре?',
      'en':
          'Per the European guidelines, within what time is sediment '
          'examined at room temperature?',
    }),
    [
      _T({
        'uz': '1 soat ichida',
        'ru': 'В течение 1 часа',
        'en': 'Within 1 hour',
      }),
      _T({
        'uz': '8 soat ichida',
        'ru': 'В течение 8 часов',
        'en': 'Within 8 hours',
      }),
      _T({
        'uz': '24 soat ichida',
        'ru': 'В течение 24 часов',
        'en': 'Within 24 hours',
      }),
      _T({
        'uz': '3 kun ichida',
        'ru': 'В течение 3 дней',
        'en': 'Within 3 days',
      }),
    ],
    _T({
      'uz':
          'Zarrachalar lizisining oldini olish uchun: xona haroratida 1 soat, '
          'sovutilganda 4 soatgacha.',
      'ru':
          'Чтобы избежать лизиса частиц: 1 час при комнатной температуре, до '
          '4 часов при охлаждении.',
      'en':
          'To avoid lysis: within 1 hour at room temperature, within 4 hours '
          'if refrigerated.',
    }),
    [_dParticles],
  ),
  UrQuizItem(
    'ur-q-hyaline-exercise',
    _T({
      'uz':
          'Sog‘lom odamda og‘ir jismoniy zo‘riqishdan keyin qaysi silindrlar '
          'bo‘lishi mumkin?',
      'ru':
          'Какие цилиндры могут быть у здорового человека после тяжёлой '
          'нагрузки?',
      'en':
          'Which casts may appear in a healthy person after strenuous '
          'exercise?',
    }),
    [
      _T({'uz': 'Gialin', 'ru': 'Гиалиновые', 'en': 'Hyaline'}),
      _T({'uz': 'Leykotsitar', 'ru': 'Лейкоцитарные', 'en': 'White cell'}),
      _T({'uz': 'Yog‘li', 'ru': 'Жировые', 'en': 'Fatty'}),
      _T({'uz': 'Keng', 'ru': 'Широкие', 'en': 'Broad'}),
    ],
    _T({
      'uz': 'Gialin silindrlar zo‘riqishdan keyin sog‘lom odamda ham topiladi.',
      'ru':
          'Гиалиновые цилиндры находят и у здоровых после физической нагрузки.',
      'en': 'Hyaline casts occur in healthy people after strenuous exercise.',
    }),
    [_wCasts, _a05Casts],
  ),
  UrQuizItem(
    'ur-q-cystine',
    _T({
      'uz': 'Qaysi kristallar irsiy kasallik — sistinuriyaga ishora qiladi?',
      'ru': 'Какие кристаллы указывают на наследственную цистинурию?',
      'en': 'Which crystals point to the hereditary disease cystinuria?',
    }),
    [
      _T({
        'uz': 'Oltiburchak rangsiz plastinkalar',
        'ru': 'Бесцветные шестиугольные пластинки',
        'en': 'Colourless hexagonal plates',
      }),
      _T({
        'uz': 'Konvertsimon kristallar',
        'ru': 'Кристаллы-«конверты»',
        'en': 'Envelope-shaped crystals',
      }),
      _T({
        'uz': '“Tobut qopqog‘i” prizmalar',
        'ru': 'Призмы «крышки гроба»',
        'en': '“Coffin-lid” prisms',
      }),
      _T({
        'uz': 'Sariq romblar va atirgullar',
        'ru': 'Жёлтые ромбы и розетки',
        'en': 'Yellow diamonds and rosettes',
      }),
    ],
    _T({
      'uz':
          'Sistin — kislotali siydikdagi oltiburchak rangsiz plastinkalar; '
          'konvert — kalsiy oksalat, “tobut qopqog‘i” — uch fosfat, sariq '
          'romb — siydik kislotasi.',
      'ru':
          'Цистин — бесцветные шестиугольные пластинки в кислой моче; '
          '«конверты» — оксалат кальция, «крышки гроба» — трипельфосфаты, '
          'жёлтые ромбы — мочевая кислота.',
      'en':
          'Cystine forms colourless hexagonal plates in acid urine; '
          'envelopes are calcium oxalate, coffin-lids triple phosphate, '
          'yellow diamonds uric acid.',
    }),
    [_wRareCrystals, _a05Crystals],
  ),
  UrQuizItem(
    'ur-q-triple-ph',
    _T({
      'uz': 'Uch fosfat kristallari qanday siydikda cho‘kadi?',
      'ru': 'В какой моче выпадают трипельфосфаты?',
      'en': 'In what urine do triple phosphate crystals form?',
    }),
    [
      _T({
        'uz': 'Neytral yoki ishqoriy',
        'ru': 'Нейтральной или щелочной',
        'en': 'Neutral or alkaline',
      }),
      _T({'uz': 'Faqat kislotali', 'ru': 'Только кислой', 'en': 'Acid only'}),
      _T({
        'uz': 'Faqat muzlatilgan',
        'ru': 'Только замороженной',
        'en': 'Frozen urine only',
      }),
      _T({
        'uz': 'pH ga bog‘liq emas',
        'ru': 'Не зависит от pH',
        'en': 'pH does not matter',
      }),
    ],
    _T({
      'uz':
          'Uch fosfatlar neytral yoki ishqoriy siydikda; ko‘pincha ishqoriy '
          'siydik va infeksiya bilan.',
      'ru':
          'Трипельфосфаты — в нейтральной или щелочной моче; часто при '
          'щелочной моче и инфекции.',
      'en':
          'Triple phosphates occur in neutral or alkaline urine, often with '
          'infection.',
    }),
    [_wCrystals, _a05Crystals],
  ),
  UrQuizItem(
    'ur-q-squamous',
    _T({
      'uz': 'K/m da 5 dan ortiq yirik yassi hujayra nimaga ishora qiladi?',
      'ru': 'На что указывают более 5 крупных плоских клеток в п/з?',
      'en': 'More than 5 large squamous cells per HPF suggest what?',
    }),
    [
      _T({
        'uz': 'Namuna ifloslangan',
        'ru': 'Загрязнение пробы',
        'en': 'Sample contamination',
      }),
      _T({
        'uz': 'Glomerulonefrit',
        'ru': 'Гломерулонефрит',
        'en': 'Glomerulonephritis',
      }),
      _T({
        'uz': 'O‘tkir kanalcha nekrozi',
        'ru': 'Острый канальцевый некроз',
        'en': 'Acute tubular necrosis',
      }),
      _T({'uz': 'Sistinuriya', 'ru': 'Цистинурия', 'en': 'Cystinuria'}),
    ],
    _T({
      'uz':
          'Yassi hujayralar uretraning distal qismi va vulvadan: ko‘pligi '
          'ifloslanishga ishora.',
      'ru':
          'Плоские клетки — из дистальной уретры и вульвы: их обилие '
          'указывает на загрязнение.',
      'en':
          'Squamous cells come from the distal urethra and vulva; many of '
          'them suggest contamination.',
    }),
    [_a22Epi],
  ),
  UrQuizItem(
    'ur-q-dysmorphic',
    _T({
      'uz': 'Dismorf eritrotsitlar (akantotsitlar) nimaga ishora qiladi?',
      'ru': 'На что указывают дисморфные эритроциты (акантоциты)?',
      'en': 'Dysmorphic red cells (acanthocytes) point to what?',
    }),
    [
      _T({
        'uz': 'Glomerulyar manba',
        'ru': 'Клубочковый источник',
        'en': 'A glomerular source',
      }),
      _T({
        'uz': 'Pastki siydik yo‘llari',
        'ru': 'Нижние мочевые пути',
        'en': 'The lower urinary tract',
      }),
      _T({
        'uz': 'Hayz qoni aralashishi',
        'ru': 'Примесь менструальной крови',
        'en': 'Menstrual contamination',
      }),
      _T({
        'uz': 'Faqat saqlash artefakti',
        'ru': 'Только артефакт хранения',
        'en': 'Only a storage artefact',
      }),
    ],
    _T({
      'uz':
          'Dismorf eritrotsitlar glomerulyar kasallikka ishora qiladi; shakli '
          'oddiy eritrotsitlar odatda pastki siydik yo‘llaridan.',
      'ru':
          'Дисморфные эритроциты указывают на клубочковое поражение; '
          'эритроциты обычной формы обычно из нижних мочевых путей.',
      'en':
          'Dysmorphic red cells suggest glomerular disease; normally shaped '
          'red cells usually come from the lower urinary tract.',
    }),
    [_a22Rbc, _dParticles],
  ),
  UrQuizItem(
    'ur-q-open-strips',
    _T({
      'uz':
          'Chiziqlar 2 hafta ochiq idishda turdi. Qaysi maydoncha ko‘pincha '
          'soxta musbat bo‘ladi?',
      'ru':
          'Полоски две недели стояли в открытой тубе. Какая зона часто '
          'становится ложноположительной?',
      'en':
          'Strips were kept in an open container for two weeks. Which pad '
          'often turns falsely positive?',
    }),
    [
      _T({'uz': 'Nitrit', 'ru': 'Нитриты', 'en': 'Nitrite'}),
      _T({'uz': 'Glyukoza', 'ru': 'Глюкоза', 'en': 'Glucose'}),
      _T({'uz': 'Ketonlar', 'ru': 'Кетоны', 'en': 'Ketones'}),
      _T({'uz': 'pH', 'ru': 'pH', 'en': 'pH'}),
    ],
    _T({
      'uz':
          'Nitrit maydonchasi havoga sezgir: 2 haftadan keyin chiziqlarning '
          'to‘rtdan uchi soxta musbat.',
      'ru':
          'Зона нитритов чувствительна к воздуху: через 2 недели три '
          'четверти полосок ложноположительны.',
      'en':
          'The nitrite pad is air-sensitive: after two weeks three quarters '
          'of strips give false positives.',
    }),
    [_a05Nitrite],
  ),
  UrQuizItem(
    'ur-q-fixed-sg',
    _T({
      'uz': 'Nisbiy zichlik 1,010 atrofida “qotib qolgan”. Bu nimaga mos?',
      'ru': 'Плотность «фиксирована» около 1,010. Чему это соответствует?',
      'en': 'Specific gravity is fixed near 1.010. What does this fit?',
    }),
    [
      _T({
        'uz': 'Buyrak to‘qimasi yetishmovchiligi',
        'ru': 'Собственно почечная недостаточность',
        'en': 'Intrinsic renal insufficiency',
      }),
      _T({'uz': 'Suvsizlanish', 'ru': 'Обезвоживание', 'en': 'Dehydration'}),
      _T({'uz': 'Glyukozuriya', 'ru': 'Глюкозурия', 'en': 'Glycosuria'}),
      _T({
        'uz': 'Ko‘p suv ichish',
        'ru': 'Избыточное питьё',
        'en': 'High water intake',
      }),
    ],
    _T({
      'uz':
          'Buyrak to‘qimasi yetishmovchiligida zichlik 1,010 da qotadi — '
          'glomerulyar filtrat zichligi.',
      'ru':
          'При собственно почечной недостаточности плотность фиксирована '
          'на 1,010 — плотности клубочкового фильтрата.',
      'en':
          'In intrinsic renal insufficiency specific gravity is fixed at '
          '1.010, that of the glomerular filtrate.',
    }),
    [_a05Sg],
  ),
  UrQuizItem(
    'ur-q-fridge',
    _T({
      'uz': 'Muzlatkichda saqlangan siydik mikroskopiyasida qanday muammo bo‘ladi?',
      'ru': 'Какая проблема при микроскопии мочи из холодильника?',
      'en': 'What is the problem with microscopy of refrigerated urine?',
    }),
    [
      _T({
        'uz': 'Tuzlar (fosfat, urat) ko‘p cho‘kadi',
        'ru': 'Выпадает много солей (фосфаты, ураты)',
        'en': 'Salts (phosphates, urates) precipitate',
      }),
      _T({
        'uz': 'Eritrotsitlar ko‘payadi',
        'ru': 'Эритроциты размножаются',
        'en': 'Red cells multiply',
      }),
      _T({
        'uz': 'Yangi silindrlar hosil bo‘ladi',
        'ru': 'Образуются новые цилиндры',
        'en': 'New casts form',
      }),
      _T({
        'uz': 'Hech qanday muammo yo‘q',
        'ru': 'Никакой проблемы нет',
        'en': 'There is no problem',
      }),
    ],
    _T({
      'uz':
          'Sovutilgan siydikda tuzlar cho‘kadi; kristallar kerak bo‘lsa, '
          'sovutilmagan ulush olinadi.',
      'ru':
          'В охлаждённой моче выпадают соли; если нужны кристаллы, берут '
          'неохлаждённую аликвоту.',
      'en':
          'Refrigerated urine precipitates salts; keep a non-refrigerated '
          'aliquot if crystals are needed.',
    }),
    [_wCollectMicro, _dParticles],
  ),
  UrQuizItem(
    'ur-q-sg-protein',
    _T({
      'uz': 'Test-chiziqdagi nisbiy zichlikni nima soxta oshiradi?',
      'ru': 'Что ложно повышает плотность на тест-полоске?',
      'en': 'What falsely raises strip specific gravity?',
    }),
    [
      _T({
        'uz': 'Proteinuriya (1 g/L dan ortiq)',
        'ru': 'Протеинурия (более 1 г/л)',
        'en': 'Proteinuria (over 1 g/L)',
      }),
      _T({
        'uz': 'Ishqoriy siydik',
        'ru': 'Щелочная моча',
        'en': 'Alkaline urine',
      }),
      _T({'uz': 'C vitamini', 'ru': 'Витамин C', 'en': 'Vitamin C'}),
      _T({'uz': 'Yorug‘lik', 'ru': 'Свет', 'en': 'Light exposure'}),
    ],
    _T({
      'uz':
          'Proteinuriya va keto-kislotalar zichlikni soxta oshiradi; '
          'ishqoriy siydik pasaytiradi.',
      'ru':
          'Протеинурия и кетокислоты ложно повышают плотность; щелочная '
          'моча — понижает.',
      'en':
          'Proteinuria and keto acids falsely raise it; alkaline urine '
          'lowers it.',
    }),
    [_dStrip],
  ),
  UrQuizItem(
    'ur-q-bilirubin-light',
    _T({
      'uz': 'Bilirubin maydonchasida soxta manfiy natijaning sababi?',
      'ru': 'Причина ложноотрицательного билирубина на полоске?',
      'en': 'A cause of a false-negative bilirubin pad?',
    }),
    [
      _T({
        'uz': 'Namunaning yorug‘likda turishi',
        'ru': 'Пребывание пробы на свету',
        'en': 'Light exposure of the sample',
      }),
      _T({
        'uz': 'Fenazopiridin',
        'ru': 'Феназопиридин',
        'en': 'Phenazopyridine',
      }),
      _T({'uz': 'Xlorpromazin', 'ru': 'Хлорпромазин', 'en': 'Chlorpromazine'}),
      _T({'uz': 'Indikan', 'ru': 'Индикан', 'en': 'Indican'}),
    ],
    _T({
      'uz':
          'Yorug‘lik, C vitamini va yuqori nitrit sezgirlikni pasaytiradi; '
          'fenazopiridin, xlorpromazin va indikan esa soxta musbat beradi.',
      'ru':
          'Свет, витамин C и высокие нитриты снижают чувствительность; '
          'феназопиридин, хлорпромазин и индикан дают ложноположительный '
          'результат.',
      'en':
          'Light, vitamin C and high nitrite lower sensitivity; '
          'phenazopyridine, chlorpromazine and indican give false positives.',
    }),
    [_dStrip, _a22Table2],
  ),
];

/// Rasmli savollar uchun chalg'ituvchilar (o'xshash elementlar). Test:
/// hammasi mavjud, takrorsiz, to'g'ri javobdan farqli.
const urPictureDistractors = <String, List<String>>{
  'rbc': ['wbc', 'yeast', 'rte'],
  'wbc': ['rbc', 'rte', 'squamous'],
  'cast_hyaline': ['cast_granular', 'cast_waxy', 'false_casts'],
  'cast_granular': ['cast_hyaline', 'cast_waxy', 'cast_wbc'],
  'cryst_uric': ['cryst_caox', 'cryst_triple', 'cryst_cystine'],
  'cryst_triple': ['cryst_caox', 'cryst_uric', 'cryst_cystine'],
  'cryst_cystine': ['cryst_uric', 'cryst_triple', 'cryst_caox'],
};

/// Bir mashqdagi savollar soni.
const urQuizSize = 12;

// ───────────────────────── Interfeys matnlari ─────────────────────────

abstract final class UrL {
  static const subtitle = _T({
    'uz': 'Yig‘ish, fizik xossalar, test-chiziq, cho‘kma, o‘qish, mashq',
    'ru': 'Сбор, физические свойства, полоска, осадок, чтение, тренировка',
    'en': 'Collection, physical, strip, sediment, reading, practice',
  });
  static const notDiagnosis = _T({
    'uz':
        'Bu o‘quv qo‘llanma: “ishora qilishi mumkin” — tashxis emas. Natijani '
        'klinik ma’lumotlar bilan shifokor baholaydi.',
    'ru':
        'Это учебное пособие: «может указывать» — не диагноз. Результат '
        'оценивает врач с учётом клинических данных.',
    'en':
        'A learning aid: “may point to” is not a diagnosis. A clinician '
        'interprets results together with clinical data.',
  });

  // Hub qatorlari.
  static const collectTitle = _T({
    'uz': 'Namuna yig‘ish va saqlash',
    'ru': 'Сбор и хранение пробы',
    'en': 'Collection and preservation',
  });
  static const collectSub = _T({
    'uz': 'Ertalabki, o‘rta porsiya, vaqt, sovutish',
    'ru': 'Утренняя, средняя порция, сроки, охлаждение',
    'en': 'Morning sample, midstream, timing, refrigeration',
  });
  static const physicalTitle = _T({
    'uz': 'Fizik xossalar',
    'ru': 'Физические свойства',
    'en': 'Physical properties',
  });
  static const physicalSub = _T({
    'uz': 'Rangi, tiniqligi, hidi, nisbiy zichligi',
    'ru': 'Цвет, прозрачность, запах, плотность',
    'en': 'Colour, clarity, odour, specific gravity',
  });
  static const stripTitle = _T({
    'uz': 'Test-chiziq (kimyoviy tekshiruv)',
    'ru': 'Тест-полоска (химическое исследование)',
    'en': 'Strip test (chemical examination)',
  });
  static const stripSub = _T({
    'uz': '10 maydoncha: ma’nosi, xalaqitlar, tasdiqlash',
    'ru': '10 зон: значение, помехи, подтверждение',
    'en': '10 pads: meaning, interferences, confirmation',
  });
  static const sedimentTitle = _T({
    'uz': 'Cho‘kma mikroskopiyasi',
    'ru': 'Микроскопия осадка',
    'en': 'Sediment microscopy',
  });
  static const sedimentSub = _T({
    'uz': 'Hujayralar, silindrlar, kristallar, mikroorganizmlar',
    'ru': 'Клетки, цилиндры, кристаллы, микроорганизмы',
    'en': 'Cells, casts, crystals, organisms',
  });
  static const readerTitle = _T({
    'uz': 'Natijani o‘qish',
    'ru': 'Чтение результата',
    'en': 'Result reader',
  });
  static const readerSub = _T({
    'uz': 'Topilmalarni belgilang — nimaga ishora qilishi mumkin',
    'ru': 'Отметьте находки — на что они могут указывать',
    'en': 'Mark findings — what they may point to',
  });
  static const quizTitle = _T({
    'uz': 'Mashq: bu nima?',
    'ru': 'Тренировка: что это?',
    'en': 'Practice: what is this?',
  });
  static const quizSub = _T({
    'uz': 'Rasm va bilim savollari',
    'ru': 'Вопросы по снимкам и знаниям',
    'en': 'Picture and knowledge questions',
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

  // Umumiy sarlavhalar.
  static const sectionGeneral = _T({
    'uz': 'Umumiy qoidalar',
    'ru': 'Общие правила',
    'en': 'General rules',
  });
  static const detects = _T({
    'uz': 'Nimani aniqlaydi',
    'ru': 'Что выявляет',
    'en': 'What it detects',
  });
  static const mayPoint = _T({
    'uz': 'Nimaga ishora qilishi mumkin',
    'ru': 'На что может указывать',
    'en': 'May point to',
  });
  static const falsePos = _T({
    'uz': 'Soxta musbat (soxta yuqori)',
    'ru': 'Ложноположительно (ложно высоко)',
    'en': 'False positive (falsely high)',
  });
  static const falseNeg = _T({
    'uz': 'Soxta manfiy (soxta past)',
    'ru': 'Ложноотрицательно (ложно низко)',
    'en': 'False negative (falsely low)',
  });
  static const next = _T({
    'uz': 'Tasdiqlash va keyingi qadam',
    'ru': 'Подтверждение и следующий шаг',
    'en': 'Confirmation and next step',
  });
  static const lookTitle = _T({
    'uz': 'Mikroskopda',
    'ru': 'Под микроскопом',
    'en': 'Under the microscope',
  });
  static const meaningTitle = _T({
    'uz': 'Nimaga ishora qilishi mumkin',
    'ru': 'На что может указывать',
    'en': 'May point to',
  });
  static const confuseTitle = _T({
    'uz': 'Adashtirmang',
    'ru': 'Не путать',
    'en': 'Do not confuse',
  });
  static const preparationTitle = _T({
    'uz': 'Tayyorlash va ko‘rish',
    'ru': 'Подготовка и просмотр',
    'en': 'Preparation and viewing',
  });
  static const groups = {
    UrGroup.cells: _T({'uz': 'Hujayralar', 'ru': 'Клетки', 'en': 'Cells'}),
    UrGroup.casts: _T({'uz': 'Silindrlar', 'ru': 'Цилиндры', 'en': 'Casts'}),
    UrGroup.crystals: _T({
      'uz': 'Kristallar',
      'ru': 'Кристаллы',
      'en': 'Crystals',
    }),
    UrGroup.organisms: _T({
      'uz': 'Mikroorganizmlar va parazitlar',
      'ru': 'Микроорганизмы и паразиты',
      'en': 'Organisms and parasites',
    }),
  };

  // Rasm.
  static const imageTitle = _T({
    'uz': 'Rasm (mikroskopiya atlasidan)',
    'ru': 'Снимок (из атласа микроскопии)',
    'en': 'Picture (from the microscopy atlas)',
  });
  static const noPhoto = _T({
    'uz':
        'Rasm hozircha yo‘q: atlasda bu element uchun erkin litsenziyali, '
        'nomi aniq tasdiqlangan foto topilmadi.',
    'ru':
        'Снимка пока нет: в атласе не найдено свободно лицензированного фото '
        'с надёжно подтверждённым названием этого элемента.',
    'en':
        'No picture yet: the atlas has no freely licensed photo whose label '
        'is confirmed for this element.',
  });
  static const openAtlas = _T({
    'uz': 'Atlasda ochish: to‘liq izoh, muallif, litsenziya',
    'ru': 'Открыть в атласе: полная подпись, автор, лицензия',
    'en': 'Open in the atlas: full caption, author, licence',
  });

  // O'qish yordamchisi.
  static const readerIntro = _T({
    'uz':
        'Test-chiziq va cho‘kmada topilgan narsalarni belgilang. Ilova har '
        'topilma va manbada ta’riflangan birikmalar nimaga ishora qilishi '
        'mumkinligini manbasi bilan ko‘rsatadi. Kristallar — “Cho‘kma” '
        'bo‘limida.',
    'ru':
        'Отметьте находки на полоске и в осадке. Приложение покажет, на что '
        'может указывать каждая находка и описанные в источниках сочетания, '
        'с указанием источника. Кристаллы — в разделе «Осадок».',
    'en':
        'Mark what was found on the strip and in the sediment. The app shows '
        'what each finding, and the combinations described in the sources, '
        'may point to, with sources. Crystals are in the “Sediment” section.',
  });
  static const readerStrip = _T({
    'uz': 'Test-chiziq (musbat)',
    'ru': 'Тест-полоска (положительно)',
    'en': 'Strip (positive)',
  });
  static const readerSediment = _T({
    'uz': 'Cho‘kma',
    'ru': 'Осадок',
    'en': 'Sediment',
  });
  static const readerEmpty = _T({
    'uz': 'Hech narsa belgilanmagan.',
    'ru': 'Ничего не отмечено.',
    'en': 'Nothing marked yet.',
  });
  static const readerReset = _T({
    'uz': 'Tozalash',
    'ru': 'Сбросить',
    'en': 'Clear',
  });
  static const readerSingleTitle = _T({
    'uz': 'Har bir topilma',
    'ru': 'Каждая находка',
    'en': 'Each finding',
  });
  static const readerComboTitle = _T({
    'uz': 'Birgalikda',
    'ru': 'В сочетании',
    'en': 'In combination',
  });
  static const readerReferral = _T({
    'uz':
        'Tashxis emas. Anormal natija va uning izohi davolovchi shifokorga '
        'yetkaziladi; xulosa klinik ma’lumotlar va zarur bo‘lsa takroriy yoki '
        'qo‘shimcha tekshiruvlar bilan chiqariladi.',
    'ru':
        'Это не диагноз. Анормальный результат с комментарием передают '
        'лечащему врачу; заключение делают с учётом клиники и, при '
        'необходимости, повторных или дополнительных исследований.',
    'en':
        'Not a diagnosis. Report abnormal results with this comment to the '
        'treating clinician; conclusions need clinical data and, where '
        'needed, repeat or further tests.',
  });
  static const readerOpenCard = _T({
    'uz': 'Kartasi',
    'ru': 'Карточка',
    'en': 'Card',
  });

  // Mashq.
  static const quizIntro = _T({
    'uz':
        'Rasmli savollar (atlasdagi fotolar) va test-chiziq, cho‘kma, '
        'yig‘ish bo‘yicha bilim savollari — faqat shu bo‘limdagi manbali '
        'matndan.',
    'ru':
        'Вопросы по снимкам (фото из атласа) и вопросы по полоске, осадку и '
        'сбору — только по материалу этого раздела с источниками.',
    'en':
        'Picture questions (atlas photos) plus knowledge questions on the '
        'strip, sediment and collection — built only from this section’s '
        'sourced text.',
  });
  static const quizStart = _T({
    'uz': 'Boshlash',
    'ru': 'Начать',
    'en': 'Start',
  });
  static const quizPicturePrompt = _T({
    'uz': 'Bu nima?',
    'ru': 'Что это?',
    'en': 'What is this?',
  });
  static const quizImageLabel = _T({
    'uz': 'Mikrofoto (nomi javobda)',
    'ru': 'Микрофото (название — в ответе)',
    'en': 'Micrograph (name in the answer)',
  });

  /// Barcha matnlar (test: uch tilda to‘liq).
  static const all = <LocalizedText>[
    subtitle,
    notDiagnosis,
    collectTitle,
    collectSub,
    physicalTitle,
    physicalSub,
    stripTitle,
    stripSub,
    sedimentTitle,
    sedimentSub,
    readerTitle,
    readerSub,
    quizTitle,
    quizSub,
    relatedTitle,
    relatedCardsTitle,
    sectionGeneral,
    detects,
    mayPoint,
    falsePos,
    falseNeg,
    next,
    lookTitle,
    meaningTitle,
    confuseTitle,
    preparationTitle,
    imageTitle,
    noPhoto,
    openAtlas,
    readerIntro,
    readerStrip,
    readerSediment,
    readerEmpty,
    readerReset,
    readerSingleTitle,
    readerComboTitle,
    readerReferral,
    readerOpenCard,
    quizIntro,
    quizStart,
    quizPicturePrompt,
    quizImageLabel,
  ];
}
