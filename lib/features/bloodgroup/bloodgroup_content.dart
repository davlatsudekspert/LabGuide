/// Qon guruhini aniqlash usullari bo'limi matnlari (3 tilda) va manbalari.
///
/// Har bir da'vo shu sessiyada ochiq manbadan tekshirilgan: BSH 2012
/// (Transfus Med 2013;23:3–35) PDF'i, JSST "Safe Blood and Blood Products,
/// Module 3: Blood Group Serology" PDF'i, UK Handbook of Transfusion
/// Medicine (5-nashr, 2013) PDF'i, RF SSV buyrug'i № 1134n (2020) matni va
/// ikki ochiq maqola. Manbada yo'q raqam yoki qadam yozilmaydi; lokatorda
/// bo'lim va sahifa. Ro'yxat va tekshirilmagan narsalar —
/// docs/BLOODGROUP_SOURCES.md. Kontent mutaxassis tekshiruvidan o'tmagan —
/// "qoralama"; ilova laboratoriya SOP'i o'rnini bosmaydi.
library;

import '../content/content_model.dart';
import '../tools/calc_info.dart';
import 'bloodgroup_logic.dart';

typedef _T = LocalizedText;

abstract final class BgSources {
  static const bsh2012 = CalcSource(
    id: 'bg-bsh-2012',
    citation:
        'Milkins C, Berryman J, Cantwell C, et al. Guidelines for '
        'pre-transfusion compatibility procedures in blood transfusion '
        'laboratories. British Committee for Standards in Haematology. '
        'Transfus Med. 2013;23(1):3–35. doi:10.1111/j.1365-3148.2012.01199.x',
    url: 'https://doi.org/10.1111/j.1365-3148.2012.01199.x',
  );
  static const who = CalcSource(
    id: 'bg-who-module3',
    citation:
        'World Health Organization. Safe Blood and Blood Products. '
        'Module 3: Blood Group Serology. Geneva: WHO; reprinted 2009',
    url: 'https://www.who.int/publications/m/item/guidelines-and-principles-for-safe-blood-transfusion-practice---module-3-blood-group-serology',
  );
  static const htm2013 = CalcSource(
    id: 'bg-htm-2013',
    citation:
        'Norfolk D, ed. Handbook of Transfusion Medicine. 5th ed. United '
        'Kingdom Blood Services. Norwich: TSO; 2013',
    url: 'https://www.infectedbloodinquiry.org.uk/sites/default/files/2023-06-28%20Oral%20Evidence%20Docs%20-%20Rows%20not%20downloaded%20copy/2023-06-28%20Oral%20Evidence%20Docs%20-%20Rows%20not%20downloaded%20copy/RLIT0000812%20-%20Handbook%20of%20Transfusion%20Medicine%20-%2001%20Jan%202013.pdf',
  );
  static const ru1134 = CalcSource(
    id: 'bg-ru-1134n',
    citation:
        'Приказ Минздрава России от 20.10.2020 № 1134н «Об утверждении '
        'порядка медицинского обследования реципиента, проведения проб на '
        'индивидуальную совместимость, включая биологическую пробу, при '
        'трансфузии донорской крови и (или) ее компонентов»',
    url: 'https://legalacts.ru/doc/prikaz-minzdrava-rossii-ot-20102020-n-1134n-ob-utverzhdenii/',
  );
  static const ru363 = CalcSource(
    id: 'bg-ru-363',
    citation:
        'Приказ Минздрава РФ от 25.11.2002 № 363 «Об утверждении Инструкции '
        'по применению компонентов крови» (атамалар uchun)',
    url: 'https://legalacts.ru/doc/prikaz-minzdrava-rf-ot-25112002-n-363/',
  );
  static const hagman2024 = CalcSource(
    id: 'bg-hagman-2024',
    citation:
        'Hagman JR, Rahfeld P, Withers SG, Kizhakkedathu JN, Olsson ML, '
        'Storry JR. Use of a recombinant deacetylase to convert A1 red blood '
        'cells to the acquired B phenotype for quality control purposes. '
        'Blood Transfus. 2024;22(2):106–110. doi:10.2450/bloodtransfus.584',
    url: 'https://doi.org/10.2450/bloodtransfus.584',
  );
  static const trummer2026 = CalcSource(
    id: 'bg-trummer-2026',
    citation:
        'Trummer P, Habicht CP, Scharberg EA, Schneeweiß C. Therapeutic '
        'biologics interference in serological and pre-transfusion testing. '
        'Front Immunol. 2026;17:1888597. doi:10.3389/fimmu.2026.1888597',
    url: 'https://doi.org/10.3389/fimmu.2026.1888597',
  );

  static const all = [
    bsh2012,
    who,
    htm2013,
    ru1134,
    ru363,
    hagman2024,
    trummer2026,
  ];
}

// ───────────────────────── Lokatorlar ─────────────────────────

const refBshKey = CalcRef(BgSources.bsh2012, 'Key recommendations, p. 3–4');
const refBshQms = CalcRef(BgSources.bsh2012, '§2.1.4, p. 5');
const refBshReagents = CalcRef(BgSources.bsh2012, '§2.3.1, §2.3.6, p. 5–6');
const refBshSamples = CalcRef(BgSources.bsh2012, '§3.1, p. 6');
const refBshRetain = CalcRef(BgSources.bsh2012, '§3.9.2, p. 8');
const refBshAboIntro = CalcRef(BgSources.bsh2012, '§4.1.1–4.1.3, p. 8–9');
const refBshReagentSel = CalcRef(BgSources.bsh2012, '§4.2.2–4.2.4, p. 9');
const refBshTests = CalcRef(BgSources.bsh2012, '§4.3.1, p. 9');
const refBshFig1 = CalcRef(BgSources.bsh2012, 'Fig. 1, p. 10');
const refBshFig2 = CalcRef(BgSources.bsh2012, 'Fig. 2, p. 10');
const refBshDtyping = CalcRef(BgSources.bsh2012, '§4.3.2, p. 10–11');
const refBshControls = CalcRef(BgSources.bsh2012, '§4.4, Table 2, p. 11');
const refBshInterp = CalcRef(BgSources.bsh2012, '§4.5.1–4.5.4, p. 11');
const refBshVerify = CalcRef(BgSources.bsh2012, '§4.6.1–4.6.3, p. 12');
const refBshAnomalies = CalcRef(BgSources.bsh2012, '§4.7.1, p. 12');
const refBshResolve = CalcRef(BgSources.bsh2012, '§4.8, p. 12–13');
const refBshScreenTech = CalcRef(BgSources.bsh2012, '§5.2.2, p. 13');
const refBshWbit = CalcRef(BgSources.bsh2012, '§7.2.1, p. 17');
const refBshIat = CalcRef(BgSources.bsh2012, '§7.3, p. 17–18');
const refBshIs = CalcRef(BgSources.bsh2012, '§7.4, p. 18');
const refBshEi = CalcRef(BgSources.bsh2012, '§7.5, p. 18–19');
const refBshAboSel = CalcRef(BgSources.bsh2012, '§7.7, p. 19');
const refBshDSel = CalcRef(BgSources.bsh2012, '§7.8, p. 19');
const refBshEmergency = CalcRef(BgSources.bsh2012, '§8.4.3–8.6.2, p. 23–24');
const refBshFigA1 = CalcRef(BgSources.bsh2012, 'Appendix 3, Fig. A1, p. 28');
const refBshApp7 = CalcRef(BgSources.bsh2012, 'Appendix 7, p. 29–30');

const refWhoAbo = CalcRef(BgSources.who, '§4.1, Table 2, p. 26');
const refWhoDemo = CalcRef(BgSources.who, '§4.3, p. 29');
const refWhoNewborn = CalcRef(BgSources.who, '§4.4, p. 30');
const refWhoSubgroups = CalcRef(BgSources.who, '§4.5–4.6, p. 30–31');
const refWhoHighTitre = CalcRef(BgSources.who, '§4.7, p. 32');
const refWhoRh = CalcRef(BgSources.who, '§5.2–5.3, p. 36–38');
const refWhoWeakD = CalcRef(BgSources.who, '§5.4, p. 38–39');
const refWhoCompat = CalcRef(BgSources.who, '§6.1, p. 42');
const refWhoRequest = CalcRef(BgSources.who, '§6.2, p. 42–43');
const refWhoSelect = CalcRef(BgSources.who, '§6.3, Fig. 14–15, p. 45');
const refWhoSlides = CalcRef(BgSources.who, '§7.6, p. 77–78');
const refWhoReading = CalcRef(BgSources.who, '§7.7, p. 79');
const refWhoGrading = CalcRef(BgSources.who, '§7.8, p. 79');
const refWhoSera = CalcRef(BgSources.who, '§7.9, p. 79–80');
const refWhoCells = CalcRef(BgSources.who, '§7.10, p. 80');
const refWhoStorage = CalcRef(BgSources.who, '§7.11–7.12, p. 81');
const refWhoGrouping = CalcRef(BgSources.who, '§7.13, p. 82');
const refWhoErrors = CalcRef(BgSources.who, '§7.14, p. 83–84');
const refWhoSaline = CalcRef(BgSources.who, '§7.4–7.5, p. 76–77');
const refWhoGel = CalcRef(BgSources.who, '§7.18, p. 87');
const refWhoCrossmatch = CalcRef(BgSources.who, '§7.21, p. 88–89');
const refWhoSlideTech = CalcRef(
  BgSources.who,
  'Appendix 1, Technique 2, p. 127–128',
);
const refWhoAnswers = CalcRef(
  BgSources.who,
  'Activity 6 and 8 answers, p. 101–102',
);
const refWhoAnswers10 = CalcRef(BgSources.who, 'Activity 10 answers, p. 103');

const refHtmTesting = CalcRef(BgSources.htm2013, '§2.3, p. 7–8');
const refHtmAbo = CalcRef(BgSources.htm2013, '§2.4, Table 2.1, p. 8');
const refHtmAboReact = CalcRef(BgSources.htm2013, '§2.4.1, p. 8');
const refHtmTable22 = CalcRef(BgSources.htm2013, 'Table 2.2, p. 9');
const refHtmRh = CalcRef(BgSources.htm2013, '§2.5, p. 9–10');
const refHtmGs = CalcRef(BgSources.htm2013, '§2.7.1–2.7.2, p. 10');
const refHtmEi = CalcRef(BgSources.htm2013, '§2.7.3, p. 11');

const refRu1134Lab = CalcRef(BgSources.ru1134, 'п. 11');
const refRu1134Sample = CalcRef(BgSources.ru1134, 'п. 7');
const refRu1134Bedside = CalcRef(BgSources.ru1134, 'п. 19, 23');
const refRu1134Retain = CalcRef(BgSources.ru1134, 'п. 28');
const refRu363Terms = CalcRef(BgSources.ru363, '§3.1, Таблица 1');
const refHagman = CalcRef(BgSources.hagman2024, 'Introduction');
const refTrummer = CalcRef(BgSources.trummer2026, '§2.2');

/// Interfeys matnlari.
abstract final class BgL {
  static const subtitle = _T({
    'uz': 'ABO va RhD: usullar, moslik, xatolar',
    'ru': 'AB0 и RhD: методы, совместимость, ошибки',
    'en': 'ABO and RhD: methods, compatibility, errors',
  });
  static const draftNote = _T({
    'uz':
        'Qoralama: matn BSH 2012, JSST va UK qo‘llanmalari bilan '
        'solishtirilgan, lekin mutaxassis tekshiruvidan hali o‘tmagan.',
    'ru':
        'Черновик: текст сверен с руководствами BSH 2012, ВОЗ и UK, но ещё '
        'не прошёл экспертную проверку.',
    'en':
        'Draft: checked against the BSH 2012, WHO and UK texts but not yet '
        'reviewed by an expert.',
  });
  static const sopNote = _T({
    'uz':
        'Bu ilova — o‘quv ma’lumotnomasi. U laboratoriyangiz SOP’i va '
        'me’yoriy talablar o‘rnini bosmaydi. Transfuziya bo‘yicha har qanday '
        'qaror mahalliy protokol asosida qabul qilinadi.',
    'ru':
        'Приложение — учебный справочник. Оно не заменяет СОП вашей '
        'лаборатории и нормативные требования. Любые решения о трансфузии '
        'принимаются по местному протоколу.',
    'en':
        'This app is a training reference. It does not replace your '
        'laboratory SOP or regulatory requirements. Any transfusion decision '
        'follows the local protocol.',
  });

  // Hub qatorlari.
  static const basicsTitle = _T({
    'uz': 'ABO va RhD asoslari',
    'ru': 'Основы AB0 и RhD',
    'en': 'ABO and RhD basics',
  });
  static const basicsSub = _T({
    'uz': 'Antigen va antitelalar, to‘g‘ri va teskari usul, naqshlar',
    'ru': 'Антигены и антитела, прямой и обратный метод, реакции',
    'en': 'Antigens and antibodies, forward and reverse typing, patterns',
  });
  static const methodsTitle = _T({
    'uz': 'Usullar',
    'ru': 'Методы',
    'en': 'Methods',
  });
  static const methodsSub = _T({
    'uz': 'Plastinka, probirka, mikroplanshet, gel-karta, qattiq faza',
    'ru': 'Плоскость, пробирка, микропланшет, гелевая карта, твёрдая фаза',
    'en': 'Slide, tube, microplate, gel card, solid phase',
  });
  static const compatTitle = _T({
    'uz': 'Moslik',
    'ru': 'Совместимость',
    'en': 'Compatibility',
  });
  static const compatSub = _T({
    'uz': 'Moslik sinamalari, eritrotsit va plazma tanlash',
    'ru': 'Пробы на совместимость, выбор эритроцитов и плазмы',
    'en': 'Crossmatching, red cell and plasma selection',
  });
  static const errorsTitle = _T({
    'uz': 'Nomuvofiqlik va xatolar',
    'ru': 'Расхождения и ошибки',
    'en': 'Discrepancies and errors',
  });
  static const errorsSub = _T({
    'uz': 'To‘g‘ri/teskari natija farqi, kuchsiz D, soxta natijalar',
    'ru': 'Расхождение прямой и обратной реакции, слабый D, ложные результаты',
    'en': 'Forward/reverse discrepancy, weak D, false results',
  });
  static const qualityTitle = _T({
    'uz': 'Sifat va preanalitika',
    'ru': 'Качество и преаналитика',
    'en': 'Quality and pre-analytics',
  });
  static const qualitySub = _T({
    'uz': 'Namuna identifikatsiyasi, ikkinchi namuna, reagent nazorati',
    'ru': 'Идентификация образца, второй образец, контроль реагентов',
    'en': 'Sample identification, second sample, reagent control',
  });
  static const readerTitle = _T({
    'uz': 'Reaksiya naqshini o‘qish',
    'ru': 'Чтение картины реакций',
    'en': 'Reaction pattern reader',
  });
  static const readerSub = _T({
    'uz': 'Natijalarni belgilang — o‘quv talqini',
    'ru': 'Отметьте реакции — учебная интерпретация',
    'en': 'Mark the reactions — a training interpretation',
  });
  static const quizTitle = _T({
    'uz': 'Mashq',
    'ru': 'Тренировка',
    'en': 'Practice',
  });
  static const quizSub = _T({
    'uz': 'Tekshirilgan ma’lumotlar bo‘yicha savollar',
    'ru': 'Вопросы по проверенному материалу',
    'en': 'Questions on the verified material',
  });
  static const quizIntro = _T({
    'uz':
        'Reaksiya naqshlari, usullar, moslik va xatolar bo‘yicha savollar. '
        'Har javobdan keyin manbali izoh ochiladi.',
    'ru':
        'Вопросы о картинах реакций, методах, совместимости и ошибках. После '
        'каждого ответа открывается пояснение с источником.',
    'en':
        'Questions on reaction patterns, methods, compatibility and errors. '
        'An explanation with its source opens after each answer.',
  });
  static const quizStart = _T({
    'uz': 'Boshlash',
    'ru': 'Начать',
    'en': 'Start',
  });

  // Asoslar sahifasi.
  static const basicsIntro = _T({
    'uz':
        'ABO guruhini aniqlash — transfuziyadan oldingi namunadagi eng muhim '
        'serologik test (BSH). ABO bo‘yicha nomos eritrotsit quyish ko‘pincha '
        'o‘lim bilan tugaydi (UK qo‘llanmasi).',
    'ru':
        'Определение группы AB0 — самое важное серологическое исследование '
        'претрансфузионного образца (BSH). Переливание AB0-несовместимых '
        'эритроцитов часто заканчивается смертью (руководство UK).',
    'en':
        'ABO grouping is the single most important serological test on a '
        'pre-transfusion sample (BSH). ABO-incompatible red cell transfusion '
        'is often fatal (UK Handbook).',
  });
  static const tableAntibodiesTitle = _T({
    'uz': 'Antigen va antitelalar',
    'ru': 'Антигены и антитела',
    'en': 'Antigens and antibodies',
  });
  static const colGroup = _T({'uz': 'Guruh', 'ru': 'Группа', 'en': 'Group'});
  static const colAntigens = _T({
    'uz': 'Antigenlar',
    'ru': 'Антигены',
    'en': 'Antigens',
  });
  static const colAntibodies = _T({
    'uz': 'Antitelalar',
    'ru': 'Антитела',
    'en': 'Antibodies',
  });
  static const antiA = _T({'uz': 'anti-A', 'ru': 'анти-A', 'en': 'anti-A'});
  static const antiB = _T({'uz': 'anti-B', 'ru': 'анти-B', 'en': 'anti-B'});
  static const antiD = _T({'uz': 'anti-D', 'ru': 'анти-D', 'en': 'anti-D'});
  static const none = _T({'uz': 'yo‘q', 'ru': 'нет', 'en': 'none'});
  static const andWord = _T({'uz': 'va', 'ru': 'и', 'en': 'and'});
  static const tablePatternTitle = _T({
    'uz': 'Kutilgan reaksiyalar',
    'ru': 'Ожидаемые реакции',
    'en': 'Expected reactions',
  });
  static const forwardHead = _T({
    'uz': 'To‘g‘ri usul',
    'ru': 'Прямой метод',
    'en': 'Forward',
  });
  static const reverseHead = _T({
    'uz': 'Teskari usul',
    'ru': 'Обратный метод',
    'en': 'Reverse',
  });
  static const a1Cells = _T({
    'uz': 'A1 hujayra',
    'ru': 'Эр. A1',
    'en': 'A1 cells',
  });
  static const bCells = _T({'uz': 'B hujayra', 'ru': 'Эр. B', 'en': 'B cells'});
  static const patternNote = _T({
    'uz':
        '+ — agglyutinatsiya bor, − — yo‘q. To‘g‘ri usul: bemor '
        'eritrotsitlari + reagent; teskari usul: bemor plazmasi (zardobi) + '
        'standart eritrotsitlar.',
    'ru':
        '+ — агглютинация есть, − — нет. Прямой метод: эритроциты пациента + '
        'реагент; обратный: плазма (сыворотка) пациента + стандартные '
        'эритроциты.',
    'en':
        '+ agglutination, − no agglutination. Forward: patient red cells + '
        'reagent; reverse: patient plasma (serum) + reagent red cells.',
  });

  // Usullar sahifasi.
  static const methodsIntro = _T({
    'uz':
        'Reagent va test tizimi ishlab chiqaruvchi yo‘riqnomasiga qat’iy '
        'muvofiq ishlatiladi; quyida tamoyillar, aniq hajm va vaqtlar — '
        'yo‘riqnoma va SOP’da.',
    'ru':
        'Реагенты и тест-системы используют строго по инструкции '
        'производителя; ниже — принципы, точные объёмы и время — в инструкции '
        'и СОП.',
    'en':
        'Reagents and test systems are used strictly per the manufacturer’s '
        'instructions; below are principles — exact volumes and times are in '
        'the insert and the SOP.',
  });
  static const gradingTitle = _T({
    'uz': 'Reaksiya kuchini baholash',
    'ru': 'Оценка силы реакции',
    'en': 'Grading reaction strength',
  });
  static const readingTitle = _T({
    'uz': 'Probirkada qanday o‘qiladi',
    'ru': 'Как читать реакцию в пробирке',
    'en': 'How to read a tube',
  });

  // Moslik sahifasi.
  static const compatIntro = _T({
    'uz':
        'O‘ta og‘ir o‘tkir gemolitik reaksiyalar deyarli doim ABO bo‘yicha '
        'nomos eritrotsitlardan kelib chiqadi; ular ko‘pincha namuna olish '
        'yoki qon quyishda bemorni noto‘g‘ri aniqlashdan yuzaga keladi (JSST).',
    'ru':
        'Тяжёлые острые гемолитические реакции почти всегда вызваны '
        'эритроцитами, несовместимыми по AB0; чаще всего — из-за ошибки '
        'идентификации пациента при взятии образца или переливании (ВОЗ).',
    'en':
        'Severe acute haemolytic reactions are nearly always caused by '
        'ABO-incompatible red cells, most often from patient identification '
        'errors at sampling or administration (WHO).',
  });
  static const tableSelectTitle = _T({
    'uz': 'ABO bo‘yicha mos komponentlar (JSST)',
    'ru': 'Совместимость компонентов по AB0 (ВОЗ)',
    'en': 'ABO-compatible components (WHO)',
  });
  static const colPatient = _T({
    'uz': 'Bemor',
    'ru': 'Пациент',
    'en': 'Patient',
  });
  static const colRbc = _T({
    'uz': 'Eritrotsitlar',
    'ru': 'Эритроциты',
    'en': 'Red cells',
  });
  static const colPlasma = _T({'uz': 'Plazma', 'ru': 'Плазма', 'en': 'Plasma'});
  static const selectNote = _T({
    'uz':
        'Imkon bo‘lsa — bir xil ABO guruhi (BSH §7.7.1). UK qo‘llanmasi '
        '(Table 2.2) tanlov tartibini beradi: ayrim zaxira variantlar faqat '
        'yuqori titrli anti-A/anti-B bo‘yicha tekshirilgan komponentlar '
        'uchun. Milliy me’yorlarning o‘z jadvali bor (masalan, RF № 1134n '
        'ilovasi) — mahalliy talab ustun.',
    'ru':
        'По возможности — одногруппные компоненты (BSH §7.7.1). Руководство '
        'UK (Table 2.2) задаёт порядок выбора: часть резервных вариантов — '
        'только для компонентов, проверенных на высокий титр анти-A/анти-B. '
        'В национальных нормах есть свои таблицы (например, приложение к '
        'приказу № 1134н) — приоритет у местных требований.',
    'en':
        'Use the same ABO group whenever possible (BSH §7.7.1). The UK '
        'Handbook (Table 2.2) gives an order of choice; some fall-back '
        'options apply only to components tested negative for high-titre '
        'anti-A/anti-B. National rules have their own tables (e.g. the annex '
        'to RF Order 1134n) — local requirements take precedence.',
  });

  // Xatolar sahifasi.
  static const errorsIntro = _T({
    'uz':
        'Nomuvofiqlik — to‘g‘ri usul natijasi teskari usul bilan mos '
        'kelmasligi. BSH bo‘yicha anomaliya eritrotsitlar berilishidan oldin '
        'hal qilinadi (bu bemor parvarishiga jiddiy zarar yetkazmasa).',
    'ru':
        'Расхождение — несовпадение результатов прямого и обратного методов. '
        'По BSH аномалию разрешают до выдачи эритроцитов (если это серьёзно '
        'не ухудшает помощь пациенту).',
    'en':
        'A discrepancy is when the forward result does not agree with the '
        'reverse. Per BSH, anomalies are resolved before red cells are '
        'provided (unless this seriously compromises patient care).',
  });
  static const noIssueNote = _T({
    'uz':
        'Nomuvofiqlik SOP bo‘yicha hal qilinmaguncha guruhga xos qon '
        'berilmaydi. Shoshilinch transfuziya kerak bo‘lsa, BSH O guruh '
        'eritrotsitlarini ko‘rsatadi — qaror mahalliy protokol bo‘yicha.',
    'ru':
        'Пока расхождение не разрешено по СОП, одногруппная кровь не '
        'выдаётся. Если трансфузия неотложна, BSH указывает эритроциты '
        'группы 0 — решение по местному протоколу.',
    'en':
        'Do not issue group-specific blood until the discrepancy is resolved '
        'per SOP. If transfusion is urgent, BSH indicates group O red cells — '
        'the decision follows the local protocol.',
  });
  static const causesTitle = _T({
    'uz': 'Ko‘rib chiqiladigan sabablar (BSH Fig. A1)',
    'ru': 'Причины для рассмотрения (BSH Fig. A1)',
    'en': 'Causes to consider (BSH Fig. A1)',
  });
  static const actionsTitle = _T({
    'uz': 'Nima qilinadi',
    'ru': 'Что делать',
    'en': 'What to do',
  });

  // Sifat sahifasi.
  static const qualityIntro = _T({
    'uz':
        'Bemorni aniqlash va namunani yorliqlashdagi xatolar ABO bo‘yicha '
        'nomos transfuziyaga olib kelishi mumkin (BSH §3.1).',
    'ru':
        'Ошибки идентификации пациента и маркировки образца могут привести к '
        'AB0-несовместимой трансфузии (BSH §3.1).',
    'en':
        'Errors in patient identification and sample labelling may lead to '
        'ABO-incompatible transfusion (BSH §3.1).',
  });
  static const controlsTitle = _T({
    'uz': 'ABO/D reagentlari nazorati (BSH Table 2)',
    'ru': 'Контроль реагентов AB0/D (BSH Table 2)',
    'en': 'ABO/D reagent controls (BSH Table 2)',
  });
  static const colReagent = _T({
    'uz': 'Reagent',
    'ru': 'Реагент',
    'en': 'Reagent',
  });
  static const colPosCtrl = _T({
    'uz': 'Musbat nazorat',
    'ru': 'Полож. контроль',
    'en': 'Positive control',
  });
  static const colNegCtrl = _T({
    'uz': 'Manfiy nazorat',
    'ru': 'Отриц. контроль',
    'en': 'Negative control',
  });
  static const dPos = _T({'uz': 'D musbat', 'ru': 'D+', 'en': 'D positive'});
  static const dNeg = _T({'uz': 'D manfiy', 'ru': 'D−', 'en': 'D negative'});

  // O'qish mashqi.
  static const readerIntro = _T({
    'uz':
        'Har bir test uchun reaksiyani belgilang. Ilova to‘g‘ri va teskari '
        'usulni solishtiradi va mos kelmasa nomuvofiqlik deb belgilaydi.',
    'ru':
        'Отметьте реакцию в каждом тесте. Приложение сравнит прямой и '
        'обратный методы и при несовпадении отметит расхождение.',
    'en':
        'Mark the reaction for each test. The app compares forward and '
        'reverse typing and flags a discrepancy when they disagree.',
  });
  static const readerTrainingOnly = _T({
    'uz':
        'Faqat o‘quv mashqi: bu talqin bemor uchun yakuniy xulosa emas va '
        'transfuziya qarori uchun ishlatilmaydi.',
    'ru':
        'Только учебное упражнение: интерпретация не является заключением '
        'для пациента и не используется для решения о трансфузии.',
    'en':
        'Training only: this interpretation is not a result for a patient '
        'and is not used for any transfusion decision.',
  });
  static const notTested = _T({
    'uz': 'Qo‘yilmagan',
    'ru': 'Не ставили',
    'en': 'Not tested',
  });
  static const reactionNeg = _T({'uz': '−', 'ru': '−', 'en': '−'});
  static const reactionPos = _T({'uz': '+', 'ru': '+', 'en': '+'});
  static const reactionWeak = _T({
    'uz': 'Kuchsiz',
    'ru': 'Слабая',
    'en': 'Weak',
  });
  static const reactionMixed = _T({
    'uz': 'Aralash maydon',
    'ru': 'Смешанное поле',
    'en': 'Mixed field',
  });
  static const controlLabel = _T({
    'uz': 'Nazorat (diluent / autonazorat)',
    'ru': 'Контроль (дилюент / аутоконтроль)',
    'en': 'Control (diluent / autocontrol)',
  });
  static const reset = _T({'uz': 'Tozalash', 'ru': 'Сбросить', 'en': 'Reset'});
  static const readerEmpty = _T({
    'uz': 'Reaksiyalarni belgilang — talqin shu yerda chiqadi.',
    'ru': 'Отметьте реакции — интерпретация появится здесь.',
    'en': 'Mark the reactions — the interpretation appears here.',
  });
  static const forwardSays = _T({
    'uz': 'To‘g‘ri usul bo‘yicha',
    'ru': 'По прямому методу',
    'en': 'Forward typing',
  });
  static const reverseSays = _T({
    'uz': 'Teskari usul bo‘yicha',
    'ru': 'По обратному методу',
    'en': 'Reverse typing',
  });
  static const concordant = _T({
    'uz': 'O‘quv talqini: ikki usul mos',
    'ru': 'Учебная интерпретация: методы совпадают',
    'en': 'Training interpretation: both methods agree',
  });
  static const discrepancyTitle = _T({
    'uz': 'Nomuvofiqlik — guruh aytilmaydi',
    'ru': 'Расхождение — группа не устанавливается',
    'en': 'Discrepancy — no group is assigned',
  });
  static const anomalyTitle = _T({
    'uz': 'Anomaliya — guruh aytilmaydi',
    'ru': 'Аномалия — группа не устанавливается',
    'en': 'Anomaly — no group is assigned',
  });
  static const invalidTitle = _T({
    'uz': 'Natija yaroqsiz',
    'ru': 'Результат недействителен',
    'en': 'Result invalid',
  });
  static const rhPositive = _T({
    'uz': 'RhD musbat',
    'ru': 'RhD положительный',
    'en': 'RhD positive',
  });
  static const rhNegative = _T({
    'uz': 'RhD manfiy',
    'ru': 'RhD отрицательный',
    'en': 'RhD negative',
  });
  static const rhWeak = _T({
    'uz': 'Anti-D bilan kuchsiz reaksiya',
    'ru': 'Слабая реакция с анти-D',
    'en': 'Weak reaction with anti-D',
  });
  static const rhMixed = _T({
    'uz': 'Anti-D bilan aralash maydon',
    'ru': 'Смешанное поле с анти-D',
    'en': 'Mixed field with anti-D',
  });
}

/// ABO guruhi nomi (RU/UZ — rim raqami bilan, RF № 363, Таблица 1).
const aboGroupNames = <AboGroup, LocalizedText>{
  AboGroup.o: _T({'uz': '0 (I)', 'ru': '0 (I)', 'en': 'O'}),
  AboGroup.a: _T({'uz': 'A (II)', 'ru': 'A (II)', 'en': 'A'}),
  AboGroup.b: _T({'uz': 'B (III)', 'ru': 'B (III)', 'en': 'B'}),
  AboGroup.ab: _T({'uz': 'AB (IV)', 'ru': 'AB (IV)', 'en': 'AB'}),
};

/// Bitta mavzu kartasi: sarlavha, matn va manbalar.
class BgItem {
  const BgItem(this.id, this.title, this.body, this.refs);
  final String id;
  final LocalizedText title;
  final LocalizedText body;
  final List<CalcRef> refs;
}

// ───────────────────────── 1. Asoslar ─────────────────────────

const bgBasics = <BgItem>[
  BgItem(
    'antigens',
    _T({
      'uz': 'Antigenlar va guruhlar',
      'ru': 'Антигены и группы',
      'en': 'Antigens and groups',
    }),
    _T({
      'uz':
          'Eritrotsit yuzasida A antigeni, B antigeni, ikkalasi yoki hech '
          'biri bo‘lishi mumkin: faqat A — A guruh, faqat B — B guruh, '
          'ikkalasi — AB guruh, hech biri — O guruh.',
      'ru':
          'На эритроцитах может быть антиген A, антиген B, оба или ни одного: '
          'только A — группа A, только B — группа B, оба — AB, ни одного — 0.',
      'en':
          'Red cells may carry the A antigen, the B antigen, both or neither: '
          'A only — group A; B only — group B; both — group AB; neither — '
          'group O.',
    }),
    [refWhoAbo],
  ),
  BgItem(
    'landsteiner',
    _T({
      'uz': 'Antitelalar: Landshteyner qoidasi',
      'ru': 'Антитела: правило Ландштейнера',
      'en': 'Antibodies: Landsteiner’s rule',
    }),
    _T({
      'uz':
          'Sog‘lom odam plazmasida o‘z eritrotsitlarida yo‘q A yoki B '
          'antigeniga qarshi antitela bo‘ladi: A guruhda anti-B, B guruhda '
          'anti-A, O guruhda anti-A va anti-B, AB guruhda ikkalasi ham yo‘q.',
      'ru':
          'В плазме здорового человека есть антитела к тем антигенам A или B, '
          'которых нет на его эритроцитах: при группе A — анти-B, при B — '
          'анти-A, при 0 — анти-A и анти-B, при AB — ни тех, ни других.',
      'en':
          'Normal individuals have antibodies to the A or B antigens absent '
          'from their own red cells: group A has anti-B, group B anti-A, '
          'group O anti-A and anti-B, group AB neither.',
    }),
    [refWhoAbo, refHtmAbo, refHagman],
  ),
  BgItem(
    'igm',
    _T({
      'uz': 'Tabiiy antitelalar va chaqaloqlar',
      'ru': 'Естественные антитела и новорождённые',
      'en': 'Naturally occurring antibodies and newborns',
    }),
    _T({
      'uz':
          'Anti-A va anti-B asosan IgM — eritrotsitlarni ko‘zga ko‘rinadigan '
          'darajada agglyutinatsiya qiladi; ular tabiiy holda hosil bo‘ladi va '
          'hayotning dastlabki 3 oyidan keyin hammada bo‘ladi. Tug‘ilganda A '
          'va B antigenlari kattalarnikidan kuchsizroq, anti-A va anti-B esa '
          'taxminan 3 oylikkacha aniqlanmasligi mumkin. Shuning uchun kindik '
          'qoni va chaqaloq namunalarida faqat eritrotsit guruhi aniqlanadi '
          '(teskari usul foydasiz — antitelalar onadan o‘tgan bo‘lishi '
          'mumkin).',
      'ru':
          'Анти-A и анти-B — преимущественно IgM: вызывают видимую '
          'агглютинацию; они естественные и есть у всех после первых 3 '
          'месяцев жизни. При рождении антигены A и B слабее, чем у взрослых, '
          'а анти-A и анти-B могут не выявляться примерно до 3 месяцев. '
          'Поэтому у новорождённых и в пуповинной крови определяют только '
          'антигены эритроцитов (обратный метод неинформативен — антитела '
          'могут быть материнскими).',
      'en':
          'Anti-A and anti-B are mainly IgM and cause visible agglutination; '
          'they are naturally occurring and present in everyone after the '
          'first 3 months of life. At birth A and B antigens are weaker than '
          'in adults, and anti-A/anti-B may not be demonstrable until about '
          '3 months. Cord and newborn samples are therefore cell-grouped only '
          '(a reverse group is unhelpful — antibodies may be maternal).',
    }),
    [refHtmTesting, refWhoNewborn, refBshTests],
  ),
  BgItem(
    'forward-reverse',
    _T({
      'uz': 'To‘g‘ri va teskari usul',
      'ru': 'Прямой и обратный метод',
      'en': 'Forward and reverse typing',
    }),
    _T({
      'uz':
          'To‘liq ABO guruhi ikki qismdan iborat: to‘g‘ri usul — bemor '
          'eritrotsitlari monoklonal anti-A va anti-B reagentlari bilan; '
          'teskari usul — bemor plazmasi (zardobi) A1 va B standart '
          'eritrotsitlari bilan. Ikki natija bir-birini tasdiqlaydi; mos '
          'kelmasa — xato haqida signal, test takrorlanadi. Teskari usul — '
          'to‘g‘ri usulning ichki nazorati: transfuziya, ildiz hujayra '
          'transplantatsiyasi va sovuq agglyutininlar kabi anomaliyalarni '
          'ko‘rsatadi.',
      'ru':
          'Полное определение группы AB0 состоит из двух частей: прямой метод '
          '— эритроциты пациента с моноклональными реагентами анти-A и '
          'анти-B; обратный — плазма (сыворотка) пациента со стандартными '
          'эритроцитами A1 и B. Результаты взаимно подтверждают друг друга; '
          'расхождение — сигнал ошибки, исследование повторяют. Обратный '
          'метод — встроенный контроль прямого: выявляет аномалии после '
          'трансфузии, трансплантации стволовых клеток, при холодовых '
          'агглютининах.',
      'en':
          'A full ABO group has two parts: forward — patient red cells with '
          'monoclonal anti-A and anti-B; reverse — patient plasma (serum) with '
          'A1 and B reagent red cells. Each confirms the other; disagreement '
          'signals an error and the test is repeated. The reverse group is an '
          'in-built check of the forward group, highlighting anomalies after '
          'transfusion, stem cell transplantation or with cold agglutinins.',
    }),
    [refBshTests, refWhoDemo, refBshAboIntro],
  ),
  BgItem(
    'cross-method',
    _T({
      'uz': 'Kesishgan (kross) usul — MDH amaliyoti',
      'ru': 'Перекрёстный метод — практика СНГ',
      'en': 'Cross method — CIS practice',
    }),
    _T({
      'uz':
          'RF SSV buyrug‘i № 1134n (2020) laboratoriyada ABO guruhini '
          'tasdiqlovchi aniqlashni kesishgan usulda — anti-A, anti-B '
          'antitelali reagentlar va standart eritrotsitlar bilan — '
          'o‘tkazishni talab qiladi (ya’ni to‘g‘ri va teskari usul birga); '
          'chaqaloqlarda — faqat to‘g‘ri usulda, periferik qondan. RhD '
          'tasdig‘i — anti-D IgM reagenti bilan. O‘zbekiston me’yorlari bu '
          'bo‘limda tekshirilmagan — o‘z SOP’ingizga qarang.',
      'ru':
          'Приказ Минздрава России № 1134н (2020): подтверждающее определение '
          'группы крови по системе AB0 в лаборатории проводится перекрёстным '
          'методом — реагентами, содержащими анти-A, анти-B антитела, и '
          'стандартными эритроцитами (то есть прямой и обратный метод '
          'вместе); новорождённым — прямым методом, из периферической крови. '
          'Подтверждение резус-принадлежности — реагентами с анти-D IgM. '
          'Нормы Узбекистана в разделе не проверялись — см. свой СОП.',
      'en':
          'RF Ministry of Health Order 1134n (2020) requires laboratory '
          'confirmatory ABO grouping by the cross method — reagents containing '
          'anti-A and anti-B plus reagent red cells (i.e. forward and reverse '
          'together); newborns — forward only, from peripheral blood. RhD is '
          'confirmed with an anti-D IgM reagent. Uzbek national rules were '
          'not verified for this section — see your SOP.',
    }),
    [refRu1134Lab],
  ),
  BgItem(
    'subgroups',
    _T({
      'uz': 'A kichik guruhlari: A1 va A2',
      'ru': 'Подгруппы A: A1 и A2',
      'en': 'A subgroups: A1 and A2',
    }),
    _T({
      'uz':
          'A guruhining taxminan 80% i — A1, 20% i — A2 (AB da ham shunday: '
          'A1B va A2B). A2 kishilarning taxminan 2% ida, A2B larning 25% ida '
          'anti-A1 bo‘lishi mumkin; odatda u kuchsiz. Anti-A1 reagenti '
          '(jumladan Dolichos biflorus lektini) faqat A1 va A1B '
          'eritrotsitlarini agglyutinatsiya qiladi. RF № 1134n: to‘g‘ri va '
          'teskari natija farq qilsa (anti-A1 ekstraagglyutinini), A2 yoki '
          'A2B ni tasdiqlash uchun anti-A1 reagenti ishlatiladi.',
      'ru':
          'Около 80% лиц группы A — A1, 20% — A2 (так же в группе AB: A1B и '
          'A2B). Анти-A1 бывает примерно у 2% лиц A2 и у 25% лиц A2B; обычно '
          'он слабый. Реагент анти-A1 (в том числе лектин Dolichos biflorus) '
          'агглютинирует только эритроциты A1 и A1B. Приказ № 1134н: при '
          'расхождении прямого и обратного определения (экстраагглютинин '
          'анти-A1) для подтверждения подгруппы A2 или A2B используют реактив '
          'анти-A1.',
      'en':
          'About 80% of group A people are A1 and 20% A2 (likewise A1B and '
          'A2B in group AB). Anti-A1 may occur in about 2% of A2 and 25% of '
          'A2B people and is usually weak. Anti-A1 reagent (including Dolichos '
          'biflorus lectin) agglutinates only A1 and A1B cells. RF Order '
          '1134n: when forward and reverse disagree (extra anti-A1), anti-A1 '
          'reagent is used to confirm A2 or A2B.',
    }),
    [refWhoSubgroups, refRu1134Lab],
  ),
  BgItem(
    'anti-ab',
    _T({
      'uz': 'Anti-A,B reagenti',
      'ru': 'Реагент анти-A,B',
      'en': 'Anti-A,B reagent',
    }),
    _T({
      'uz':
          'Anti-A,B (anti-AB) kuchsiz A va B antigenlariga kuchliroq '
          'bog‘lanadi; JSST uni donorlarni guruhlashda tavsiya etadi, bemor '
          'eritrotsitlarini tekshirishda shart emas.',
      'ru':
          'Анти-A,B (анти-AB) сильнее реагирует со слабыми антигенами A и B; '
          'ВОЗ рекомендует его при типировании доноров, для эритроцитов '
          'пациентов он не обязателен.',
      'en':
          'Anti-A,B (anti-AB) reacts more strongly with weak A and B '
          'antigens; WHO recommends it for donor grouping, but it is not '
          'required for patients’ red cells.',
    }),
    [refWhoSubgroups],
  ),
  BgItem(
    'rhd',
    _T({'uz': 'RhD', 'ru': 'RhD', 'en': 'RhD'}),
    _T({
      'uz':
          'Eritrotsitlar anti-D bilan agglyutinatsiyalansa — RhD musbat, '
          'agglyutinatsiya bo‘lmasa — RhD manfiy (ishlaydigan D geni yo‘q). '
          'Anti-D faqat RhD musbat qon quyilgan yoki RhD musbat homilaga '
          'homilador bo‘lgan RhD manfiy kishida bo‘ladi; u IgG, transfuziya '
          'reaksiyalari va homila/chaqaloq gemolitik kasalligiga sabab bo‘lishi '
          'mumkin. ABO dan farqli o‘laroq, D antigeni homila davrining '
          'boshidayoq to‘liq rivojlangan.',
      'ru':
          'Агглютинация с анти-D — RhD положительный, её отсутствие — RhD '
          'отрицательный (нет функционирующего гена D). Анти-D бывает только '
          'у RhD-отрицательных людей после переливания RhD-положительной '
          'крови или беременности RhD-положительным плодом; это IgG, '
          'вызывающий трансфузионные реакции и гемолитическую болезнь плода и '
          'новорождённого. В отличие от AB0, антиген D полностью развит уже в '
          'раннем внутриутробном периоде.',
      'en':
          'Agglutination with anti-D — RhD positive; none — RhD negative '
          '(no functioning D gene). Anti-D is present only in RhD negative '
          'people transfused with RhD positive cells or pregnant with an RhD '
          'positive baby; it is IgG and can cause transfusion reactions and '
          'haemolytic disease of the fetus and newborn. Unlike ABO, D is '
          'fully developed in early fetal life.',
    }),
    [refWhoRh, refHtmRh],
  ),
  BgItem(
    'weak-partial-d',
    _T({
      'uz': 'Kuchsiz D va qisman D',
      'ru': 'Слабый D и частичный D',
      'en': 'Weak D and partial D',
    }),
    _T({
      'uz':
          'Kuchsiz D (Du) — D antigeni kamroq ifodalangan irsiy belgi; turli '
          'anti-D reagentlari bilan turlicha kuchda reaksiya beradi. Qisman D '
          '— D antigenining bir qismi yo‘q: bunday kishi D musbat aniqlansa '
          'ham, yo‘q qismga qarshi anti-D hosil qilishi mumkin. BSH 2012: '
          'ular orasidagi chegara endi aniq emas, shuning uchun bemorga '
          'asoslangan algoritm (Fig. 1) tavsiya etiladi.',
      'ru':
          'Слабый D (Du) — наследуемое ослабленное выражение антигена D; с '
          'разными реагентами анти-D даёт реакции разной силы. Частичный D — '
          'часть антигена D отсутствует: человек типируется как D+, но может '
          'образовать анти-D к недостающей части. BSH 2012: граница между ними '
          'уже не однозначна, поэтому рекомендован алгоритм, основанный на '
          'характеристиках пациента (Fig. 1).',
      'en':
          'Weak D (Du) is an inherited weakened expression of D; it reacts '
          'with different strength with different anti-D reagents. In '
          'partial D part of the antigen is missing: the person types D '
          'positive but can make anti-D to the missing part. BSH 2012: the '
          'distinction is no longer straightforward, so a patient-based '
          'algorithm (Fig. 1) is recommended.',
    }),
    [refWhoWeakD, refBshAnomalies, refBshFig1],
  ),
];

/// Kutilgan naqsh jadvali uchun manbalar.
const bgPatternRefs = [refWhoAnswers, refBshTests, refHtmAbo];

// ───────────────────────── 2. Usullar ─────────────────────────

const bgMethods = <BgItem>[
  BgItem(
    'reagents',
    _T({
      'uz': 'Monoklonal reagentlar (tsoliklonlar)',
      'ru': 'Моноклональные реагенты (цоликлоны)',
      'en': 'Monoclonal reagents',
    }),
    _T({
      'uz':
          'Ilgari guruh zardoblari odam yoki hayvon qonidagi poliklonal '
          'antitelalardan tayyorlangan; hozir ABO va RhD reagentlarining '
          'ko‘pchiligi gibridomalardan olinadigan monoklonal antitelalar. '
          'Ular juda o‘ziga xos va kuchli, keraksiz antitelalardan holi. '
          'Faqat ishlab chiqaruvchi yo‘riqnomasidagi usulda ishlatiladi '
          '(odatda 2–6 °C da saqlanadi); ba’zilari aralash (IgM + IgG). BSH: '
          'ABO va D reagentlari CE belgili, yo‘riqnomaga muvofiq saqlanadi va '
          'ishlatiladi.',
      'ru':
          'Раньше применяли гемагглютинирующие сыворотки — поликлональные '
          'антитела крови человека или животных; сейчас большинство '
          'реагентов AB0 и RhD — моноклональные антитела гибридом (в '
          'отечественной практике — цоликлоны). Они высокоспецифичны и '
          'активны, без посторонних антител. Используют только по методике '
          'инструкции (хранение обычно 2–6 °C); часть реагентов смешанные '
          '(IgM + IgG). BSH: реагенты AB0 и D маркированы CE, хранятся и '
          'применяются по инструкции.',
      'en':
          'Grouping sera used to be polyclonal antibodies from human or '
          'animal blood; most ABO and RhD reagents are now monoclonal '
          'antibodies from hybridomas. They are highly specific and potent, '
          'free from unwanted antibodies, and are used only by the method in '
          'the insert (usually stored at 2–6 °C); some are blended (IgM + '
          'IgG). BSH: ABO and D reagents are CE marked and stored and used '
          'per the manufacturer.',
    }),
    [refWhoSera, refBshReagents, refRu363Terms],
  ),
  BgItem(
    'slide',
    _T({
      'uz': 'Plastinka (oyna/kafel) usuli',
      'ru': 'Метод на плоскости (стекло, планшет)',
      'en': 'Slide (tile) method',
    }),
    _T({
      'uz':
          'Tez, lekin sezgirligi past va xatoga olib keladi: kuchsiz '
          'antitelalar agglyutinatsiya bermaydi. JSST uni faqat dastlabki tez '
          'eritrotsit guruhi uchun tavsiya etadi; natija probirka yoki '
          'mikroplanshetdagi to‘liq guruhlash bilan tasdiqlanadi. Reaksiya 2 '
          'daqiqa ichida o‘qiladi — keyin aralashma quriydi va soxta musbat '
          'ko‘rinadi.',
      'ru':
          'Быстро, но малочувствительно и ведёт к ошибкам: слабые антитела '
          'не дают агглютинации. ВОЗ допускает его только для '
          'предварительного быстрого определения антигенов эритроцитов; '
          'результат подтверждают полным типированием в пробирке или '
          'микропланшете. Читать в течение 2 минут — затем подсыхание даёт '
          'ложноположительную картину.',
      'en':
          'Quick but insensitive and error-prone: weak antibodies will not '
          'agglutinate. WHO accepts it only for a preliminary rapid cell '
          'group, confirmed by full tube or microplate grouping. Read within '
          '2 minutes — drying then gives false positives.',
    }),
    [refWhoSlides, refWhoReading, refWhoSlideTech],
  ),
  BgItem(
    'tube',
    _T({
      'uz': 'Probirka usuli',
      'ru': 'Пробирочный метод',
      'en': 'Tube method',
    }),
    _T({
      'uz':
          'Probirkada uzoq inkubatsiyada bug‘lanish bo‘lmaydi. ABO uchun '
          'to‘g‘ri va teskari usulda odatda xona haroratidagi fiziologik '
          'eritma usuli qo‘llanadi. RhD reagentlari har xil: ba’zilari ABO '
          'kabi ishlaydi, boshqalari 37 °C da inkubatsiyani talab qiladi — '
          'yo‘riqnomaga qarang. Eritrotsit suspenziyasi aniq bo‘lishi shart '
          '(odatda 2–3%).',
      'ru':
          'В пробирке длительная инкубация идёт без испарения. Для AB0 в '
          'прямом и обратном методе обычно используют солевую методику при '
          'комнатной температуре. Реагенты анти-D различаются: одни работают '
          'как реагенты AB0, другим нужна инкубация при 37 °C — см. '
          'инструкцию. Взвесь эритроцитов должна быть точной (обычно 2–3%).',
      'en':
          'Tubes allow long incubation without evaporation. For ABO, a '
          'room-temperature saline technique is generally used for both '
          'forward and reverse groups. Anti-D reagents vary: some work like '
          'ABO reagents, others need 37 °C incubation — see the insert. Cell '
          'suspensions must be accurate (usually 2–3%).',
    }),
    [refWhoSlides, refWhoGrouping, refWhoCells],
  ),
  BgItem(
    'microplate',
    _T({'uz': 'Mikroplanshet', 'ru': 'Микропланшет', 'en': 'Microplate'}),
    _T({
      'uz':
          '96 chuqurchali planshet bir vaqtda 96 probirka ishini bajaradi va '
          'reagentni kam sarflaydi; o‘qish uchun U-shakl chuqurcha qulay.',
      'ru':
          'Планшет на 96 лунок заменяет 96 пробирок и экономит реагенты; для '
          'чтения удобны U-образные лунки.',
      'en':
          'A 96-well plate does the work of 96 tubes and uses far less '
          'reagent; U-shaped wells are easier to read.',
    }),
    [refWhoSlides],
  ),
  BgItem(
    'gel',
    _T({
      'uz': 'Gel-karta (kolonkali agglyutinatsiya)',
      'ru': 'Гелевые карты (колоночная агглютинация)',
      'en': 'Gel card (column agglutination)',
    }),
    _T({
      'uz':
          'Plastik kartada odatda 6 ta mikronaycha, ichida gel yoki shisha '
          'sharchalar matritsasi. Sentrifugada eritrotsitlar matritsaga '
          'kiradi: agglyutinatlar unda ushlanib qoladi (musbat), '
          'agglyutinatsiyalanmagan hujayralar naycha tubida tugmacha hosil '
          'qiladi (manfiy). Antiglobulin yoki guruhlash (anti-A, anti-B) '
          'reagentli kartalar bor. BSH: ba’zi kartalar teskari tomondan '
          'o‘qilsa noto‘g‘ri guruh chiqadi — masalan, O D manfiy namuna AB D '
          'manfiy bo‘lib ko‘rinadi.',
      'ru':
          'Пластиковая карта обычно с 6 микроколонками, заполненными гелем '
          'или стеклянными микросферами. При центрифугировании эритроциты '
          'проходят в матрицу: агглютинаты задерживаются в ней '
          '(положительно), неагглютинированные клетки оседают на дно, '
          'образуя «пуговку» (отрицательно). Есть карты с антиглобулином и с '
          'реагентами анти-A, анти-B. BSH: некоторые карты при чтении с '
          'обратной стороны дают неверную группу — например, 0 D− выглядит '
          'как AB D−.',
      'en':
          'A plastic card usually holds 6 microtubes with a gel or glass-bead '
          'matrix. On centrifugation red cells enter the matrix: agglutinates '
          'are trapped (positive), unagglutinated cells pass to the bottom as '
          'a button (negative). Cards exist with antiglobulin or with grouping '
          'reagents (anti-A, anti-B). BSH: some cards read from the wrong side '
          'give the wrong group — e.g. an O D negative sample appears AB D '
          'negative.',
    }),
    [refWhoGel, refBshReagentSel, refBshFig2],
  ),
  BgItem(
    'solid-phase',
    _T({
      'uz': 'Qattiq faza usuli',
      'ru': 'Твердофазный метод',
      'en': 'Solid phase',
    }),
    _T({
      'uz':
          'Antitelalarni aniqlashning IAT turi: eritrotsitlar (membranalari) '
          'yuzaga qotiriladi; ularga bog‘langan qon guruhi antitelalari anti-'
          'IgG bilan qoplangan indikator eritrotsitlar yordamida aniqlanadi. '
          'BSH: kolonkali agglyutinatsiya va qattiq faza texnologiyalarining '
          'kuchli va zaif tomonlari bor — joriy etishdan oldin mahalliy '
          'validatsiya qilinadi.',
      'ru':
          'Вариант НАТ для выявления антител: эритроциты (их мембраны) '
          'иммобилизованы на поверхности; связавшиеся антитела выявляют '
          'индикаторными эритроцитами, покрытыми анти-IgG. BSH: у колоночной '
          'агглютинации и твёрдой фазы свои сильные и слабые стороны — перед '
          'внедрением нужна местная валидация.',
      'en':
          'An IAT variant for antibody detection: red cells (ghosts) are '
          'immobilised on a surface, and bound blood group antibodies are '
          'detected by indicator red cells coated with anti-human IgG. BSH: '
          'column agglutination and solid-phase systems have different '
          'strengths and weaknesses and are validated locally before use.',
    }),
    [refTrummer, refBshScreenTech],
  ),
];

/// Reaksiya kuchi shkalasi (JSST §7.8).
const bgGrades = <(String, LocalizedText)>[
  (
    '4+',
    _T({
      'uz': 'Barcha hujayralar to‘liq agglyutinatsiyalangan',
      'ru': 'Полная агглютинация всех клеток',
      'en': 'Complete agglutination of all cells',
    }),
  ),
  (
    '3+',
    _T({
      'uz': 'Hujayralarning ko‘pi agglyutinatsiyalangan, ba’zilari erkin',
      'ru': 'Агглютинировано большинство клеток, есть свободные',
      'en': 'Majority of cells agglutinated, with some free cells',
    }),
  ),
  (
    '2+',
    _T({
      'uz': 'Oddiy ko‘z bilan aniq agglyutinatsiya',
      'ru': 'Чёткая агглютинация невооружённым глазом',
      'en': 'Definite agglutination with naked-eye reading',
    }),
  ),
  (
    '1+',
    _T({
      'uz': 'Oddiy ko‘zda kuchsiz musbat; lupa yoki botiq oynada aniq musbat',
      'ru':
          'Слабо положительно невооружённым глазом; чётко — с лупой или '
          'вогнутым зеркалом',
      'en':
          'Weakly positive to the naked eye; clearly positive with a hand '
          'lens or concave mirror',
    }),
  ),
  (
    '−',
    _T({
      'uz': 'Agglyutinatsiya yo‘q',
      'ru': 'Агглютинации нет',
      'en': 'No agglutination',
    }),
  ),
  (
    'L',
    _T({
      'uz': 'Eritrotsitlar lizisi (gemoliz)',
      'ru': 'Лизис эритроцитов (гемолиз)',
      'en': 'Lysis of red cells',
    }),
  ),
];

/// Probirkada o'qish qadamlari (JSST §7.7).
const bgTubeReading = <LocalizedText>[
  _T({
    'uz':
        'Hujayralar cho‘kishini kuting (kamida 45 daqiqa) yoki yengil '
        'sentrifugalang.',
    'ru':
        'Дождитесь оседания клеток (не менее 45 минут) или слегка '
        'отцентрифугируйте.',
    'en': 'Let the cells settle (at least 45 minutes) or centrifuge lightly.',
  }),
  _T({
    'uz':
        'Probirkalarni bittadan, yaxshi yoritilgan oq fon, diffuz yorug‘lik '
        'qutisi yoki botiq oyna ustida ko‘ring.',
    'ru':
        'Берите по одной пробирке и смотрите над хорошо освещённым белым '
        'фоном, рассеянным светом или вогнутым зеркалом.',
    'en':
        'Take one tube at a time over a well-lit white background, a diffuse '
        'light box or a concave mirror.',
  }),
  _T({
    'uz': 'Avval gemolizni qidiring; bo‘lsa — qayd eting.',
    'ru': 'Сначала ищите гемолиз; если есть — запишите.',
    'en': 'Look for haemolysis first; record it if present.',
  }),
  _T({
    'uz':
        'Probirkani qiya ushlab, hujayralarni tubdan ko‘chirish uchun ohista '
        'silkiting va agglyutinatsiyani qidiring (lupa ×2–×5 yordam beradi).',
    'ru':
        'Держа пробирку под углом, осторожно встряхните, чтобы поднять '
        'осадок, и ищите агглютинацию (помогает лупа ×2–×5).',
    'en':
        'Hold the tube at an angle, shake gently to dislodge the cells and '
        'look for agglutination (a ×2–×5 hand lens helps).',
  }),
  _T({
    'uz': 'Natijani darhol yozing, keyin keyingi probirkaga o‘ting.',
    'ru': 'Сразу запишите результат и только потом берите следующую.',
    'en': 'Record the result immediately before reading the next tube.',
  }),
];

// ───────────────────────── 3. Moslik ─────────────────────────

const bgCompat = <BgItem>[
  BgItem(
    'steps',
    _T({
      'uz': 'Moslik tekshiruvi nimadan iborat',
      'ru': 'Из чего состоит проверка совместимости',
      'en': 'What compatibility testing includes',
    }),
    _T({
      'uz':
          '1) Bemorning oldingi guruhi, antitelalari, oldingi transfuziyalari '
          'va transfuziya sababini tekshirish; 2) ABO va RhD guruhini '
          'aniqlash va oldingi natija bilan solishtirish; 3) imkon bo‘lsa — '
          'antitela skriningi; 4) yakuniy moslik sinamasi.',
      'ru':
          '1) Проверка прежней группы пациента, антител, предыдущих '
          'трансфузий и показания; 2) определение AB0 и RhD и сверка с '
          'прежним результатом; 3) по возможности — скрининг антител; '
          '4) итоговая проба на совместимость.',
      'en':
          '1) Check previous group, antibodies, past transfusions and the '
          'reason for transfusion; 2) ABO and RhD group, compared with '
          'previous results; 3) antibody screen if possible; 4) the final '
          'crossmatch.',
    }),
    [refWhoCompat],
  ),
  BgItem(
    'major-minor',
    _T({
      'uz': 'Katta va kichik moslik sinamasi',
      'ru': '«Большая» и «малая» проба',
      'en': 'Major and minor crossmatch',
    }),
    _T({
      'uz':
          'Katta (asosiy) sinama — bemor zardobi + donor eritrotsitlari: '
          'bemorda donor hujayralariga qarshi antitela bormi. Kichik sinama — '
          'bemor eritrotsitlari + donor zardobi. JSST: kichik sinama '
          'ko‘pincha endi kerak emas, chunki donor zardobi guruhlashda '
          'antitelaga tekshiriladi.',
      'ru':
          '«Большая» (основная) проба — сыворотка реципиента + эритроциты '
          'донора: нет ли у реципиента антител к клеткам донора. «Малая» — '
          'эритроциты реципиента + сыворотка донора. ВОЗ: малая проба в '
          'большинстве случаев больше не нужна — сыворотку донора проверяют '
          'на антитела при типировании.',
      'en':
          'Major crossmatch — patient serum + donor red cells: does the '
          'patient have antibodies to the donor cells? Minor — patient red '
          'cells + donor serum. WHO: the minor crossmatch is mostly no longer '
          'needed because donor serum is checked for antibodies at grouping.',
    }),
    [refWhoCompat],
  ),
  BgItem(
    'iat',
    _T({
      'uz': 'Antiglobulin (IAT) sinamasi',
      'ru': 'Проба с непрямым антиглобулиновым тестом',
      'en': 'Antiglobulin (IAT) crossmatch',
    }),
    _T({
      'uz':
          'Har bir donor birligi bemor plazmasiga qarshi tekshiriladi va ABO '
          'hamda ABO bo‘lmagan nomoslik aniqlanadi. BSH: tasdiqlangan IT yoki '
          'elektron berish bo‘lmasa — standart usul; bemorda klinik ahamiyatli '
          'alloantitela bo‘lsa yoki bo‘lgan bo‘lsa, skrining musbat bo‘lsa — '
          'majburiy. JSST: sinama xona haroratida (ABO nomosligi) va 37 °C da '
          'IAT bilan (IgG antitelalar) o‘tkaziladi; agglyutinatsiya yoki '
          'gemoliz — nomos, bu birlik bemorga berilmaydi.',
      'ru':
          'Каждую единицу донора тестируют с плазмой реципиента, выявляя '
          'несовместимость по AB0 и другим системам. BSH: метод по умолчанию '
          'при отсутствии валидированной ИТ или электронной выдачи; '
          'обязателен, если у пациента есть или были клинически значимые '
          'аллоантитела или скрининг положителен. ВОЗ: проба при комнатной '
          'температуре (несовместимость AB0) и при 37 °C в НАТ (IgG-антитела); '
          'агглютинация или гемолиз — несовместимо, единицу не переливают.',
      'en':
          'Each donor unit is tested against the patient’s plasma to detect '
          'ABO and non-ABO incompatibility. BSH: the default technique without '
          'validated IT/electronic issue; mandatory if the patient has, or has '
          'had, clinically significant alloantibodies or a positive screen. '
          'WHO: test at room temperature (ABO incompatibility) and at 37 °C by '
          'IAT (IgG antibodies); agglutination or haemolysis means '
          'incompatible — the unit is not used.',
    }),
    [refBshIat, refWhoCrossmatch],
  ),
  BgItem(
    'immediate-spin',
    _T({
      'uz': 'Darhol sentrifugalash (immediate spin)',
      'ru': 'Солевая проба с немедленным центрифугированием',
      'en': 'Immediate-spin (saline spin) crossmatch',
    }),
    _T({
      'uz':
          'Asosan ABO nomosligini tez aniqlash uchun. Kuchsiz anti-A yoki '
          'anti-B bo‘lgan bemorlarda unga tayanib bo‘lmaydi; IgG antitelalarni '
          'aniqlamaydi, shuning uchun IAT o‘rnini bosmaydi. Kelishilgan '
          'standart nazoratlari yo‘q (BSH).',
      'ru':
          'В основном — быстрое выявление несовместимости по AB0. У пациентов '
          'со слабыми анти-A или анти-B на неё нельзя полагаться; IgG-антитела '
          'не выявляет, поэтому НАТ не заменяет. Согласованных стандартных '
          'контролей нет (BSH).',
      'en':
          'Used mainly as a rapid check for ABO incompatibility. It cannot be '
          'relied on in patients with weak anti-A or anti-B and does not '
          'detect IgG antibodies, so it does not replace the IAT. There are no '
          'agreed standard controls (BSH).',
    }),
    [refBshIs],
  ),
  BgItem(
    'electronic',
    _T({
      'uz': 'Elektron berish (kompyuter moslik tanlovi)',
      'ru': 'Электронная выдача (компьютерный подбор)',
      'en': 'Electronic issue (computer crossmatch)',
    }),
    _T({
      'uz':
          'Moslikni donor hujayralarini serologik tekshirmasdan laboratoriya '
          'axborot tizimi aniqlaydi. BSH shartlari: guruh va skrining to‘liq '
          'avtomatlashtirilgan, natijalar elektron uzatiladi; joriy guruh '
          'tarixiy yozuv bilan bir xil; qo‘lda tuzatish yo‘q; joriy skrining '
          'manfiy; ma’lum klinik ahamiyatli antitela yo‘q; namuna muddat '
          'talablariga mos. Qo‘llanmaydi: antitela bo‘lsa yoki bo‘lgan bo‘lsa, '
          'skrining musbat, ABO nomos ildiz hujayra transplantatsiyasi, '
          'so‘nggi 3 oyda ABO nomos qattiq a’zo transplantatsiyasi, onada IgG '
          'antitela bo‘lgan chaqaloq yoki homila.',
      'ru':
          'Совместимость определяет лабораторная информационная система без '
          'серологической пробы с эритроцитами донора. Условия BSH: группа и '
          'скрининг полностью автоматизированы, результаты передаются '
          'электронно; текущая группа совпадает с архивной; нет ручных '
          'правок; текущий скрининг отрицателен; нет известных клинически '
          'значимых антител; образец соответствует срокам. Не применяется: '
          'есть или были антитела, положительный скрининг, AB0-несовместимая '
          'трансплантация стволовых клеток, AB0-несовместимая трансплантация '
          'органа за последние 3 месяца, плод или новорождённый при IgG-'
          'антителах у матери.',
      'en':
          'The LIMS determines compatibility without serological testing of '
          'donor cells. BSH criteria: fully automated group and screen with '
          'electronic result transfer; current group identical to the '
          'historical record; no manual amendments; current screen negative; '
          'no known clinically significant antibody; sample within timing '
          'rules. Not used with current or past antibodies, a positive screen, '
          'ABO-incompatible stem cell transplant, ABO-incompatible solid organ '
          'transplant in the last 3 months, or a neonate/fetus whose mother has '
          'an IgG red cell antibody.',
    }),
    [refBshEi, refHtmEi],
  ),
  BgItem(
    'bedside-ru',
    _T({
      'uz': 'RF me’yori: shifokor sinamalari',
      'ru': 'Нормы РФ: пробы, выполняемые врачом',
      'en': 'RF rules: bedside tests by the physician',
    }),
    _T({
      'uz':
          'RF № 1134n: eritrotsit komponenti quyishdan oldin transfuziya '
          'qiluvchi shifokor bemor va donorning ABO va rezus-mansubligini '
          'nazorat tekshiruvidan o‘tkazadi hamda plastinkada individual '
          'moslik sinamasini bajaradi; biologik sinama — har bir yangi '
          'birlikda birinchi 15 daqiqa 2 mL/daq tezlikda quyib, bemorni '
          'kuzatish (krioprecipitatdan tashqari). Boshqa mamlakatlar '
          'qoidalari farq qiladi.',
      'ru':
          'Приказ № 1134н: перед переливанием эритроцитсодержащих компонентов '
          'врач выполняет контрольную проверку AB0 и резус-принадлежности '
          'реципиента и донора и пробу на индивидуальную совместимость '
          'методом на плоскости; биологическая проба — первые 15 минут каждой '
          'новой единицы со скоростью 2 мл/мин с наблюдением (кроме '
          'криопреципитата). Правила других стран отличаются.',
      'en':
          'RF Order 1134n: before red cell transfusion the physician performs '
          'a control check of recipient and donor ABO and Rh and an individual '
          'compatibility test on a plane (slide); a biological test — the '
          'first 15 minutes of each new unit at 2 mL/min with observation '
          '(except cryoprecipitate). Other countries’ rules differ.',
    }),
    [refRu1134Bedside],
  ),
  BgItem(
    'group-o',
    _T({
      'uz': 'O guruh eritrotsitlari: “universal donor” va chegaralari',
      'ru': 'Эритроциты 0: «универсальный донор» и его пределы',
      'en': 'Group O red cells: the “universal donor” and its limits',
    }),
    _T({
      'uz':
          'O guruh eritrotsitlarida A va B antigenlari yo‘q, shuning uchun '
          'ularni ba’zan universal donor deyishadi. Lekin O plazmasida anti-A '
          'va anti-B bor: yuqori titrda ular O bo‘lmagan bemor eritrotsitlarini '
          'gemolizlashi mumkin. SAG-M qo‘shimcha eritmadagi eritrotsitlarda '
          'qoldiq plazma 20 mL dan kam — xavf juda past. BSH: imkon bo‘lsa — '
          'bir xil ABO guruhi; A yoki B bemorga bir xil guruh bo‘lmasa — O; AB '
          'bemorga O dan oldin A yoki B. O plazmaga boy komponentlar (plazma, '
          'trombotsitlar) mos komponent bo‘lsa, A, B, AB bemorlarga '
          'berilmaydi.',
      'ru':
          'На эритроцитах группы 0 нет антигенов A и B, поэтому их иногда '
          'называют универсальными. Но в плазме 0 есть анти-A и анти-B: в '
          'высоком титре они могут гемолизировать эритроциты реципиента не 0 '
          'группы. В эритроцитах в добавочном растворе SAG-M остаточной плазмы '
          'менее 20 мл — риск очень низкий. BSH: по возможности одногруппные; '
          'для A или B при отсутствии одногруппных — 0; для AB — A или B '
          'раньше, чем 0. Богатые плазмой компоненты группы 0 (плазма, '
          'тромбоциты) не дают пациентам A, B, AB, если есть совместимые.',
      'en':
          'Group O red cells lack A and B antigens and are sometimes called '
          'universal donors. But group O plasma contains anti-A and anti-B, '
          'which in high titre can haemolyse a non-O recipient’s red cells. '
          'Red cells in SAG-M additive solution have under 20 mL residual '
          'plasma, so the risk is very low. BSH: same ABO group when possible; '
          'group O for A or B patients if identical is unavailable; A or B '
          'rather than O for AB patients. Plasma-rich group O components '
          '(plasma, platelets) are not given to A, B or AB patients if '
          'compatible ones are available.',
    }),
    [refHtmAbo, refHtmAboReact, refBshAboSel, refWhoHighTitre],
  ),
  BgItem(
    'rhd-select',
    _T({
      'uz': 'RhD bo‘yicha tanlash',
      'ru': 'Выбор по RhD',
      'en': 'RhD selection',
    }),
    _T({
      'uz':
          'JSST: RhD manfiy bemor RhD manfiy qon oladi — anti-D hosil '
          'bo‘lishining oldini olish uchun. BSH: D zaxirasini saqlash uchun '
          'ayrim holatlarda istisno bor (masalan, 50 yoshdan katta ayollar, '
          'katta yoshli erkaklar), lekin tug‘ish yoshidagi (<51) ayollar, '
          '18 yoshgacha bo‘lganlar, immun anti-D hosil qilganlar va '
          'transfuziyaga qaram kattalar doim D manfiy oladi. Bu siyosat '
          'mahalliy hujjatda belgilanadi.',
      'ru':
          'ВОЗ: RhD-отрицательный пациент получает RhD-отрицательную кровь — '
          'чтобы не образовался анти-D. BSH: ради сохранения запасов D− '
          'возможны исключения (например, женщины старше 50 лет, взрослые '
          'мужчины), но женщины детородного возраста (<51 года), пациенты '
          'моложе 18 лет, лица с иммунным анти-D и взрослые, зависимые от '
          'трансфузий, всегда получают D−. Политика закрепляется локально.',
      'en':
          'WHO: RhD negative patients receive RhD negative blood to prevent '
          'anti-D formation. BSH: to preserve D negative stock, exceptions '
          'exist (e.g. women over 50, adult men), but women of childbearing '
          'potential (<51), patients under 18, those with immune anti-D and '
          'transfusion-dependent adults always receive D negative. The policy '
          'is set locally.',
    }),
    [refWhoSelect, refBshDSel],
  ),
];

/// JSST Fig. 14–15: ABO bo'yicha mos eritrotsit va plazma guruhlari.
const bgSelectTable = <AboGroup, (List<AboGroup>, List<AboGroup>)>{
  AboGroup.o: ([AboGroup.o], [AboGroup.o, AboGroup.a, AboGroup.b, AboGroup.ab]),
  AboGroup.a: ([AboGroup.a, AboGroup.o], [AboGroup.a, AboGroup.ab]),
  AboGroup.b: ([AboGroup.b, AboGroup.o], [AboGroup.b, AboGroup.ab]),
  AboGroup.ab: (
    [AboGroup.ab, AboGroup.a, AboGroup.b, AboGroup.o],
    [AboGroup.ab],
  ),
};

// ───────────────────────── 4. Nomuvofiqlik va xatolar ─────────────────────

const bgCauses = <BgItem>[
  BgItem(
    'causes-forward',
    _T({
      'uz': 'To‘g‘ri usul tomonidan',
      'ru': 'Со стороны прямого метода',
      'en': 'Forward group',
    }),
    _T({
      'uz':
          'Aralash maydon reaksiyalari; kuchsiz A yoki B kichik guruhi; '
          'usul yoki reagent bilan bog‘liq texnik muammolar; kasallik tufayli '
          'antigenning kuchsizlanishi yoki yo‘qolishi; musbat DAT; '
          'poliagglyutinatsiya.',
      'ru':
          'Реакции «смешанного поля»; слабая подгруппа A или B; технические '
          'проблемы методики или реагентов; ослабление или утрата антигена при '
          'заболевании; положительная прямая проба Кумбса; '
          'полиагглютинабельность.',
      'en':
          'Mixed-field reactions; weak A or B subgroup; technical problems '
          'with procedure or reagents; weakening or loss of antigen due to '
          'disease; positive DAT; polyagglutination.',
    }),
    [refBshFigA1],
  ),
  BgItem(
    'causes-reverse',
    _T({
      'uz': 'Teskari usul tomonidan',
      'ru': 'Со стороны обратного метода',
      'en': 'Reverse group',
    }),
    _T({
      'uz':
          'Kutilgan agglyutinin yo‘q; sovuqda faol allo- yoki autoantitelalar; '
          'texnik muammolar; gemoliz yoki lipemiya.',
      'ru':
          'Отсутствие ожидаемого агглютинина; холодовые алло- или '
          'аутоантитела; технические проблемы; гемолиз или липемия.',
      'en':
          'Missing agglutinin; cold-reacting allo- or autoantibodies; '
          'technical problems; haemolysis or lipaemia.',
    }),
    [refBshFigA1],
  ),
];

const bgErrors = <BgItem>[
  BgItem(
    'weak-subgroups',
    _T({
      'uz': 'Kuchsiz A/B variantlari (A2, Ax va boshqalar)',
      'ru': 'Слабые варианты A/B (A2, Ax и др.)',
      'en': 'Weak A/B variants (A2, Ax and others)',
    }),
    _T({
      'uz':
          'A va B variantlari monoklonal reagentlar bilan kuchsiz yoki manfiy '
          'reaksiya berishi mumkin; guruhni tasdiqlash uchun ma’lumotnoma '
          'laboratoriyasiga yuborish kerak bo‘lishi mumkin. A2 va A2B '
          'kishilarda anti-A1 teskari usulda A1 hujayralar bilan qo‘shimcha '
          'reaksiya beradi (JSST mashq javoblari).',
      'ru':
          'Варианты A и B могут давать слабые или отрицательные реакции с '
          'моноклональными реагентами; для подтверждения группы может '
          'понадобиться референтная лаборатория. У лиц A2 и A2B анти-A1 даёт '
          'дополнительную реакцию с эритроцитами A1 в обратном методе '
          '(ответы к упражнениям ВОЗ).',
      'en':
          'A and B variants may react weakly or not at all with monoclonal '
          'reagents; referral to a reference centre may be needed to confirm '
          'the group. In A2 and A2B people, anti-A1 gives an extra reaction '
          'with A1 cells in the reverse group (WHO activity answers).',
    }),
    [refBshAnomalies, refWhoSubgroups, refWhoAnswers10],
  ),
  BgItem(
    'mixed-field',
    _T({
      'uz': 'Aralash maydon, transfuziya va transplantatsiya',
      'ru': 'Смешанное поле, трансфузия и трансплантация',
      'en': 'Mixed field, transfusion and transplantation',
    }),
    _T({
      'uz':
          'Aralash maydon reaksiyalari ABO/D bo‘yicha mos bo‘lmagan yoki '
          'nomos transfuziya, mos bo‘lmagan ildiz hujayra transplantatsiyasi, '
          'A3/B3, katta homila-ona qon ketishi yoki (kamdan-kam) egizaklar '
          'orasidagi qon almashinuvidan keyingi ximerizm belgisi bo‘lishi '
          'mumkin — guruh tasdiqlanishi yoki qon berilishidan oldin takrorlanadi '
          'va tekshiriladi. Bachadon ichi transfuziyasi olgan chaqaloqlar bir '
          'necha oy quyilgan eritrotsitlar guruhida ko‘rinishi mumkin.',
      'ru':
          'Реакции «смешанного поля» могут означать несовпадающую по AB0/D или '
          'несовместимую трансфузию, несовпадающую трансплантацию стволовых '
          'клеток, A3/B3, массивное фетоматеринское кровотечение или (редко) '
          'химеризм после фето-фетальной трансфузии у близнецов — до '
          'утверждения группы или выдачи крови их повторяют и исследуют. '
          'Младенцы после внутриутробных трансфузий несколько месяцев могут '
          'типироваться как группа перелитых эритроцитов.',
      'en':
          'Mixed-field reactions may mean an ABO/D mismatched or incompatible '
          'transfusion, mismatched stem cell transplant, A3/B3, a large FMH or '
          '(rarely) a chimera after twin-to-twin transfusion — repeat and '
          'investigate before authorising the group or issuing red cells. '
          'Infants given intrauterine transfusions may type as the transfused '
          'group for several months.',
    }),
    [refBshAnomalies],
  ),
  BgItem(
    'cold',
    _T({
      'uz': 'Sovuq antitelalar va autoagglyutinatsiya',
      'ru': 'Холодовые антитела и аутоагглютинация',
      'en': 'Cold antibodies and autoagglutination',
    }),
    _T({
      'uz':
          'Plazmada anti-A va anti-B dan boshqa sovuq alloantitela bo‘lsa, '
          'teskari usulda kutilmagan reaksiya chiqadi: iloji bo‘lsa yuqoriroq '
          'haroratda yoki shu antigeni yo‘q hujayralar bilan takrorlanadi. '
          'Kuchli sovuq autoantitela yoki autoagglyutinatsiya bo‘lsa — diluent '
          'nazorati majburiy; hujayralarni iliq fiziologik eritmada yuvish '
          'foydali. JSST: teskari usulni 37 °C da inkubatsiya qilib o‘qish; '
          '37 °C da gemoliz bo‘lsa — DAT va natija shifokorga.',
      'ru':
          'Если в плазме есть холодовое аллоантитело помимо анти-A и анти-B, '
          'в обратном методе будет неожиданная реакция: по возможности '
          'повторяют при более высокой температуре или с эритроцитами без '
          'соответствующего антигена. При сильном холодовом аутоантителе или '
          'аутоагглютинации контроль с дилюентом обязателен; полезна отмывка '
          'клеток тёплым физраствором. ВОЗ: инкубировать обратный метод при '
          '37 °C; при гемолизе при 37 °C — прямая проба Кумбса и сообщение '
          'врачу.',
      'en':
          'A cold-active alloantibody other than anti-A/anti-B gives an '
          'unexpected reverse reaction: repeat at a higher temperature or '
          'with cells lacking the antigen. With a strong cold autoantibody or '
          'autoagglutination a diluent control is mandatory; washing cells in '
          'warm saline may help. WHO: incubate the reverse group at 37 °C; if '
          'there is haemolysis at 37 °C, do a DAT and inform the doctor.',
    }),
    [refBshAnomalies, refBshControls, refWhoErrors],
  ),
  BgItem(
    'rouleaux',
    _T({
      'uz': 'Rulo (soxta agglyutinatsiya)',
      'ru': 'Монетные столбики (псевдоагглютинация)',
      'en': 'Rouleaux (pseudo-agglutination)',
    }),
    _T({
      'uz':
          'Rulo agglyutinatsiyaga o‘xshaydi; odatda albumin/globulin nisbati '
          'buzilgan bemor zardobida uchraydi. JSST: 1 tomchi gipertonik '
          'fiziologik eritma (1,5%) qo‘shilsa rulo odatda tarqaladi, haqiqiy '
          'agglyutinatsiya tarqalmaydi; shubha bo‘lsa — katta mutaxassisga. '
          'Kindik qoni namunasidagi Varton dirildog‘i kuchli rulo beradi — '
          'hujayralar 37 °C gacha isitilgan eritmada bir necha marta '
          'yuviladi.',
      'ru':
          'Монетные столбики похожи на агглютинацию; обычно встречаются в '
          'сыворотке пациентов с нарушенным альбумин-глобулиновым '
          'соотношением. ВОЗ: после 1 капли гипертонического раствора (1,5%) '
          'столбики обычно расходятся, истинная агглютинация — нет; при '
          'сомнении — к старшему специалисту. Вартонов студень в пуповинной '
          'крови даёт выраженные столбики — клетки несколько раз отмывают '
          'раствором, нагретым до 37 °C.',
      'en':
          'Rouleaux look like agglutination and are usually seen in serum '
          'with an abnormal albumin/globulin ratio. WHO: adding 1 drop of '
          'hypertonic saline (1.5%) usually disperses rouleaux but not true '
          'agglutination; if in doubt, ask a senior. Wharton’s jelly in cord '
          'samples gives strong rouleaux — wash the cells several times in '
          'saline warmed to 37 °C.',
    }),
    [refWhoErrors],
  ),
  BgItem(
    'acquired-b',
    _T({'uz': 'Orttirilgan B', 'ru': 'Приобретённый B', 'en': 'Acquired B'}),
    _T({
      'uz':
          'Bakterial fermentlar A antigenining immunodominant qandini '
          '(N-atsetilgalaktozamin) B ga juda o‘xshash tuzilmaga aylantiradi. '
          'Hodisa dastlab A1 guruhli bemorlarda tasvirlangan; keyingi holatlar '
          'keksa yosh va yo‘g‘on yoki to‘g‘ri ichak saratoni bilan bog‘liq '
          'bo‘lgan. Infeksiya bartaraf etilgach o‘zgarish to‘xtaydi. Noto‘g‘ri AB deb aniqlanib, o‘lim bilan tugagan holat '
          'qayd etilgan. BSH: anti-B reagenti orttirilgan B antigeni bilan '
          'reaksiya bermasligi kerak.',
      'ru':
          'Бактериальные ферменты превращают иммунодоминантный сахар антигена '
          'A (N-ацетилгалактозамин) в структуру, очень похожую на B. Феномен '
          'впервые описан у пациентов группы A1; последующие случаи были '
          'связаны с пожилым возрастом и раком толстой или прямой кишки. '
          'После устранения инфекции изменение прекращается. Описан случай '
          'со смертельным исходом после ошибочного типирования как AB. BSH: '
          'реагент анти-B не должен реагировать с приобретённым антигеном B.',
      'en':
          'Bacterial enzymes convert the immunodominant A sugar '
          '(N-acetylgalactosamine) into a structure closely resembling B. It '
          'was first described in group A1 patients; later cases were linked '
          'to old age and colorectal carcinoma. The change ceases once the '
          'infection clears. A fatal case '
          'after mistyping as AB has been reported. BSH: the anti-B reagent '
          'should not react with acquired-B antigen.',
    }),
    [refHagman, refBshReagentSel],
  ),
  BgItem(
    'weak-antibodies',
    _T({
      'uz': 'Kuchsiz yoki yo‘q antitelalar',
      'ru': 'Слабые или отсутствующие антитела',
      'en': 'Weak or missing antibodies',
    }),
    _T({
      'uz':
          'Teskari usulda kutilgan agglyutinin yo‘qligi bemor tarixini — '
          'chaqaloqlik, keksalik yoki immunodefitsitni — ko‘rib chiqishni '
          'talab qiladi. Reaksiyani kuchaytirish: test haroratini pasaytirish, '
          'fermentlangan hujayralar, plazma/hujayra nisbatini oshirish. '
          'Teskari usulda reaksiya olinmasa, BSH guruhni ikki to‘g‘ri usul '
          'natijasi asosida berishni ko‘rsatadi.',
      'ru':
          'Отсутствие ожидаемого агглютинина требует учесть анамнез — '
          'новорождённый, пожилой возраст, иммунодефицит. Усиление реакции: '
          'снижение температуры, эритроциты, обработанные ферментом, '
          'увеличение соотношения плазма/клетки. Если реакций в обратном '
          'методе получить нельзя, BSH допускает заключение по двум '
          'определениям прямым методом.',
      'en':
          'A missing reverse agglutinin calls for patient history — neonate, '
          'old age or immunodeficiency. Enhance reactions by lowering the test '
          'temperature, using enzyme-treated cells or increasing the '
          'plasma/cell ratio. If no reverse reactions can be obtained, BSH '
          'reports the group based on two forward groups.',
    }),
    [refBshFigA1],
  ),
  BgItem(
    'dat-potentiators',
    _T({
      'uz': 'Musbat DAT va potentsiatorlar',
      'ru': 'Положительная прямая проба Кумбса и потенциаторы',
      'en': 'Positive DAT and potentiators',
    }),
    _T({
      'uz':
          'Potentsiatorli (masalan, PEG) reagentlar eritrotsitlari organizmda '
          'immunoglobulin bilan qoplangan bemorda soxta musbat beradi — '
          'diluent nazorati qo‘yiladi; u musbat bo‘lsa (kuchsiz bo‘lsa ham), '
          'natija yaroqsiz. To‘g‘ri usulda yoki nazoratda ortiqcha reaksiya '
          'bo‘lsa: DAT, potentsiatorsiz reagentlar bilan probirkada takrorlash, '
          'iliq yuvish va takrorlash. Teskari hujayralardagi potentsiatorlar '
          'anti-c kabi IgG antitelalarni ham ko‘rsatishi mumkin.',
      'ru':
          'Реагенты с потенциаторами (например, ПЭГ) дают ложноположительные '
          'реакции, если эритроциты пациента покрыты иммуноглобулином in vivo '
          '— ставят контроль с дилюентом; если он положителен (даже слабо), '
          'результат недействителен. При лишних реакциях в прямом методе или '
          'контроле: прямая проба Кумбса, повтор в пробирке реагентами без '
          'потенциатора, тёплая отмывка и повтор. Потенциаторы в стандартных '
          'эритроцитах могут выявить в обратном методе IgG-антитела, например '
          'анти-c.',
      'en':
          'Reagents with potentiators (e.g. PEG) give false positives when '
          'the patient’s cells are coated with immunoglobulin in vivo — use a '
          'diluent control; if it is positive (even weakly) the result is '
          'invalid. With extra forward or control reactions: DAT, repeat with '
          'unpotentiated reagents in a tube, warm wash and repeat. '
          'Potentiators in reverse cells may also detect IgG antibodies such '
          'as anti-c.',
    }),
    [refBshReagentSel, refBshControls, refBshFigA1, refBshAnomalies],
  ),
  BgItem(
    'technical',
    _T({
      'uz': 'Texnik xatolar (soxta musbat / manfiy)',
      'ru': 'Технические ошибки (ложноположительные / ложноотрицательные)',
      'en': 'Technical errors (false positive / negative)',
    }),
    _T({
      'uz':
          'Noto‘g‘ri saqlangan yoki yomon standartlangan reagentlar — soxta '
          'manfiy; ifloslangan reagentlar — soxta musbat. Ifloslangan namuna '
          '(hid, gemoliz) — yangi namuna so‘raladi. Fiziologik eritma pH '
          '6,5–7,5 dan tashqarida bo‘lsa — soxta manfiy. Eng ko‘p xato: '
          'noto‘g‘ri namuna, reagent yoki hujayrani noto‘g‘ri probirkaga '
          'solish, harorat va vaqtga rioya qilmaslik, natijani noto‘g‘ri '
          'ko‘chirish. Suspenziya aniq bo‘lishi kerak; pipetkadagi zardob '
          'qoldig‘i soxta natija beradi.',
      'ru':
          'Неправильно хранившиеся или плохо стандартизованные реагенты — '
          'ложноотрицательные результаты; контаминированные реагенты — '
          'ложноположительные. Контаминированный образец (запах, гемолиз) — '
          'запросить новый. pH физраствора вне 6,5–7,5 — ложноотрицательные '
          'реакции. Чаще всего ошибки: не тот образец, реагент или клетки не '
          'в той пробирке, несоблюдение температуры и времени, ошибки '
          'переписывания. Взвесь должна быть точной; остатки сыворотки в '
          'пипетке дают ложные результаты.',
      'en':
          'Poorly standardised or wrongly stored reagents — false negatives; '
          'infected reagents — false positives. A contaminated sample (odour, '
          'haemolysis) — request a fresh one. Saline outside pH 6.5–7.5 — '
          'false negatives. Most errors: wrong sample, reagent or cells in the '
          'wrong tube, ignoring temperature and time, transcription errors. '
          'Suspensions must be accurate; serum traces in a pipette give false '
          'results.',
    }),
    [refWhoErrors, refWhoSaline, refWhoCells],
  ),
];

const bgActions = <BgItem>[
  BgItem(
    'resolve',
    _T({
      'uz': 'Anomaliyani hal qilish',
      'ru': 'Разрешение аномалии',
      'en': 'Resolving an anomaly',
    }),
    _T({
      'uz':
          'Nomuvofiqlik turiga qarab: bemor tarixi, testni takrorlash, yangi '
          'namuna, ma’lumotnoma laboratoriyasiga yuborish va qo‘shimcha '
          'testlar. Hal bo‘lsa — guruh beriladi; hal bo‘lmasa — ma’lumotnoma '
          'laboratoriyasiga. Qo‘lda bajarilganda natijalar ikki marta, '
          'mustaqil yoziladi. Tarixiy natija bilan farq bo‘lsa — darhol yangi '
          'namuna olinadi va tekshiriladi.',
      'ru':
          'В зависимости от вида расхождения: анамнез, повтор исследования, '
          'новый образец, направление в референтную лабораторию, дополнительные '
          'тесты. Если разрешено — группа выдаётся; если нет — в '
          'референтную лабораторию. При ручной работе результаты записывают '
          'дважды и независимо. При расхождении с архивным результатом сразу '
          'берут и исследуют новый образец.',
      'en':
          'Depending on the discrepancy: patient history, repeat test, repeat '
          'sample, referral and additional tests. If resolved, report the '
          'group; if not, refer to a reference laboratory. With manual work, '
          'results are recorded twice, independently. If the result differs '
          'from the historical record, a further sample is obtained and tested '
          'immediately.',
    }),
    [refBshFigA1, refBshVerify],
  ),
  BgItem(
    'weak-d-action',
    _T({
      'uz': 'Kuchsiz D reaksiyasi (BSH Fig. 1)',
      'ru': 'Слабая реакция D (BSH Fig. 1)',
      'en': 'Weak D reaction (BSH Fig. 1)',
    }),
    _T({
      'uz':
          'Bir yoki bir nechta anti-D bilan reaksiya musbat, lekin belgilangan '
          'darajadan kuchsiz bo‘lsa (mahalliy siyosat; odatda <3+ yoki <2+): '
          '50 yosh va undan kichik ayol yoki doimiy transfuziyaga muhtoj '
          'bemor — D manfiy deb qaraladi va D turi tasdiqlash uchun '
          'yuboriladi; boshqalar — D musbat. Qisman D ma’lum bo‘lgan bemor D '
          'manfiy deb qaraladi.',
      'ru':
          'Если реакция с одним или несколькими анти-D положительна, но слабее '
          'установленной степени (по местной политике; обычно <3+ или <2+): '
          'женщина ≤50 лет или пациент, которому вероятны постоянные '
          'трансфузии, — считать D-отрицательным и направить на подтверждение '
          'D; остальные — D-положительные. Пациента с известным частичным D '
          'считают D-отрицательным.',
      'en':
          'If one or more anti-D reactions are positive but below the '
          'predefined grade (local policy; likely <3+ or <2+): a female ≤50 '
          'years or a patient likely to need chronic transfusion is treated as '
          'D negative and referred for D type confirmation; others are treated '
          'as D positive. A patient with known partial D is regarded as D '
          'negative.',
    }),
    [refBshFig1, refBshResolve],
  ),
  BgItem(
    'emergency',
    _T({
      'uz': 'Shoshilinch guruh',
      'ru': 'Экстренное определение группы',
      'en': 'Emergency grouping',
    }),
    _T({
      'uz':
          'Shoshilinch guruh anti-A, anti-B va anti-D bilan, tegishli '
          'nazoratlar yoki teskari usul bilan bo‘ladi; AB D musbat naqshida '
          'ehtiyot bo‘ling — nazoratsiz sovuq agglyutininlar o‘tkazib '
          'yuborilishi mumkin. Tez guruhdan keyin guruhga xos eritrotsit '
          'berishdan oldin kamida bitta ikkinchi test (yangi alikvotda teskari '
          'yoki takroriy to‘g‘ri usul yoki saline spin sinamasi). Guruh '
          'aniqlanmagan bo‘lsa — O guruh eritrotsitlari.',
      'ru':
          'Экстренная группа — с анти-A, анти-B и анти-D, с соответствующими '
          'контролями или обратным методом; осторожно с картиной AB D+ — без '
          'контролей можно пропустить холодовые агглютинины. После быстрого '
          'определения до выдачи одногруппных эритроцитов — хотя бы один '
          'второй тест (обратный метод или повтор прямого из новой аликвоты, '
          'либо солевая проба). Пока группа не установлена — эритроциты 0.',
      'en':
          'An emergency group uses anti-A, anti-B and anti-D with appropriate '
          'controls or a reverse group; take care with an AB D positive '
          'pattern — cold agglutinins may be missed without controls. After a '
          'rapid group, at least one second test (reverse or repeat forward on '
          'a new aliquot, or a saline spin crossmatch) precedes issue of '
          'group-specific red cells. Group O red cells while the group is '
          'unknown.',
    }),
    [refBshEmergency],
  ),
];

// ───────────────────────── 5. Sifat va preanalitika ─────────────────────

const bgQuality = <BgItem>[
  BgItem(
    'labelling',
    _T({
      'uz': 'Namuna va so‘rovnoma',
      'ru': 'Образец и направление',
      'en': 'Sample and request form',
    }),
    _T({
      'uz':
          'JSST: namunaga bemorning to‘liq ismi, shifoxona raqami va bo‘limi '
          'yoziladi; namunadagi barcha ma’lumot so‘rovnoma bilan mos kelmasa, '
          'so‘rov qabul qilinmaydi — yangi namuna va so‘rovnoma so‘raladi. '
          'BSH: natijani tasdiqlashdan oldin (yaxshisi testdan oldin) '
          'namunadagi ma’lumotlar kompyuter yozuvi bilan solishtiriladi. RF '
          '№ 1134n: namuna transfuziyadan ko‘pi bilan 24 soat oldin olinadi, '
          'sana, familiya va initsiallar, bo‘lim, ABO va rezus-mansublik '
          'bilan belgilanadi.',
      'ru':
          'ВОЗ: на образце — полное имя пациента, номер истории и отделение; '
          'если данные образца не совпадают с направлением полностью, запрос '
          'не принимают — запрашивают новые образец и направление. BSH: до '
          'утверждения результата (лучше до исследования) данные образца '
          'сверяют с компьютерной записью. Приказ № 1134н: пробы берут не '
          'ранее чем за 24 часа до трансфузии и маркируют датой, фамилией и '
          'инициалами, отделением, AB0 и резус-принадлежностью.',
      'en':
          'WHO: the sample carries the patient’s full name, hospital number '
          'and ward; if any detail on the sample does not match the request '
          'form, the request is not accepted — a new sample and form are '
          'requested. BSH: check sample demographics against the computer '
          'record before validating results (preferably before testing). RF '
          'Order 1134n: samples are taken no more than 24 h before transfusion '
          'and labelled with date, surname and initials, department, ABO and '
          'Rh.',
    }),
    [refWhoRequest, refBshVerify, refRu1134Sample],
  ),
  BgItem(
    'second-sample',
    _T({
      'uz': 'Ikkinchi namuna (WBIT)',
      'ru': 'Второй образец (WBIT)',
      'en': 'Second sample (WBIT)',
    }),
    _T({
      'uz':
          'Taxminan 2000 namunadan 1 tasi boshqa bemordan olingan bo‘ladi '
          '(“probirkada noto‘g‘ri qon”, WBIT). Xavfsiz elektron identifikatsiya '
          'tizimi bo‘lmasa, birinchi marta tekshirilayotgan bemorning ABO '
          'guruhini tasdiqlash uchun transfuziyadan oldin ikkinchi namuna '
          'so‘raladi (shoshilinch qon berishni kechiktirmasa). Ikki namuna '
          'bir-biridan mustaqil olinishi kerak — birini bir vaqtda olib, '
          'keyinroq yuborish mumkin emas.',
      'ru':
          'Примерно 1 из 2000 образцов взят не у того пациента («не та кровь '
          'в пробирке», WBIT). Без надёжной электронной идентификации для '
          'подтверждения группы AB0 у пациента, обследуемого впервые, до '
          'трансфузии запрашивают второй образец (если это не задерживает '
          'экстренную выдачу). Образцы должны быть взяты независимо — нельзя '
          'взять оба сразу и отправить второй позже.',
      'en':
          'About 1 in 2000 samples is from the wrong patient (“wrong blood in '
          'tube”, WBIT). Without secure electronic patient identification, a '
          'second sample is requested to confirm the ABO group of a first-time '
          'patient before transfusion (if it does not delay urgent supply). '
          'The two samples must be taken independently — not both at once with '
          'one sent later.',
    }),
    [refBshWbit, refBshApp7, refHtmGs],
  ),
  BgItem(
    'independent',
    _T({
      'uz': 'Mustaqil o‘qish va qayd etish',
      'ru': 'Независимое чтение и запись',
      'en': 'Independent reading and recording',
    }),
    _T({
      'uz':
          'Qo‘lda ishlaganda xavfni kamaytirish: reaksiya naqshini yozish va '
          'yakuniy talqinni, to‘g‘ri va teskari usul talqinini ajratish, '
          'imkon bo‘lsa — turli xodimlar. Xavfsiz avtomatika bo‘lmasa, D '
          'turi ikki marta aniqlanadi (bir xil yoki ikki xil IgM anti-D '
          'bilan). Iloji bo‘lsa to‘liq avtomatlashtirilgan tizimlar '
          'ishlatiladi: ABO xatolarining ko‘pchiligi qo‘lda ishlashda.',
      'ru':
          'При ручной работе риск снижают разделением задач: запись картины '
          'реакций отдельно от итоговой интерпретации, прямой и обратный '
          'метод — отдельно, по возможности разными сотрудниками. Без '
          'надёжной автоматизации D определяют в дубле (одним или двумя '
          'разными IgM анти-D). По возможности используют полностью '
          'автоматизированные системы: большинство ошибок AB0 — при ручной '
          'работе.',
      'en':
          'For manual work, reduce risk by separating tasks: record reaction '
          'patterns separately from the final interpretation, and forward '
          'from reverse, ideally by different staff. Without secure '
          'automation, D typing is done in duplicate (same or two different '
          'IgM anti-D). Fully automated systems are used where possible: most '
          'ABO errors occur in manual systems.',
    }),
    [refBshInterp, refBshDtyping, refBshAboIntro],
  ),
  BgItem(
    'reagent-qc',
    _T({
      'uz': 'Reagentlar sifat nazorati',
      'ru': 'Контроль качества реагентов',
      'en': 'Reagent quality control',
    }),
    _T({
      'uz':
          'JSST: guruh reagentlari ishga tushirishdan oldin va keyin har bir '
          'seriyada yoki kamida kuniga bir marta nazorat hujayralari bilan '
          'tekshiriladi: mos antigenli hujayralar bilan aniq musbat, '
          'antigensiz hujayralar bilan aniq manfiy, lizis va rulo yo‘q. '
          'Gemoliz, cho‘kma/zarrachalar yoki gel hosil bo‘lgan reagent '
          'ishlatilmaydi. BSH: probirka yoki mikroplanshetda qo‘lda ishlaganda '
          '— har seriyada; seriya raqami almashganda va analizator ishga '
          'tushganda; avtomatda kamida har 12 soatda. Nazorat kutilganini '
          'bermasa — oxirgi to‘g‘ri nazoratdan keyingi barcha natijalar '
          'tekshiriladi.',
      'ru':
          'ВОЗ: реагенты проверяют контрольными эритроцитами до начала '
          'использования, затем в каждой серии или минимум раз в день: чёткая '
          'положительная реакция с клетками, несущими антиген, чёткая '
          'отрицательная — без него, без лизиса и монетных столбиков. Реагент '
          'с гемолизом, осадком/частицами или гелеобразованием не используют. '
          'BSH: при ручной работе в пробирках или планшетах — в каждой серии; '
          'при смене лота и запуске анализатора; на анализаторе — не реже '
          'раза в 12 ч. Если контроль не дал ожидаемого, проверяют все '
          'результаты после последнего валидного контроля.',
      'en':
          'WHO: grouping reagents are tested against control cells before '
          'routine use, then with each batch or at least daily: clear positive '
          'with antigen-positive cells, clear negative without, no lysis or '
          'rouleaux. Do not use a reagent showing haemolysis, precipitate/'
          'particles or gel formation. BSH: in manual tube or microplate work '
          '— every batch; at lot change and analyser start-up; on analysers at '
          'least every 12 h. If controls fail, check the validity of all '
          'results since the last valid controls.',
    }),
    [refWhoStorage, refBshControls],
  ),
  BgItem(
    'records',
    _T({
      'uz': 'Qaydlar va audit izi',
      'ru': 'Записи и прослеживаемость',
      'en': 'Records and audit trail',
    }),
    _T({
      'uz':
          'Har bir reagent uchun: qachon kelgani, qayerdan, qanday saqlangani, '
          'qachon ishga tushirilgani, seriya raqami, yaroqlilik muddati va '
          'muammolar (JSST). BSH: barcha reagentlarning seriya va muddati qayd '
          'etiladi; tizim to‘liq audit izini — dastlabki natijalar, '
          'nazoratlar, talqin, o‘zgartirishlar va mas’ul xodimlarni — saqlaydi. '
          'Transfuziyadan oldingi namuna transfuziyadan keyin kamida 3 kun '
          'saqlanadi (BSH); RF № '
          '1134n: bemor probirkasi va donor birligi qoldig‘i (≥5 mL) 48 soat '
          '2–6 °C da.',
      'ru':
          'Для каждого реагента: когда поступил, откуда, условия хранения, '
          'дата начала использования, номер серии, срок годности и замечания '
          '(ВОЗ). BSH: регистрируют серии и сроки всех реагентов; система '
          'хранит полный аудиторский след — исходные результаты, контроли, '
          'интерпретации, исправления и ответственных. Претрансфузионный '
          'образец хранят не менее 3 дней после трансфузии (BSH); приказ '
          '№ 1134н: пробирку '
          'реципиента и остаток компонента (не менее 5 мл) — 48 ч при 2–6 °C.',
      'en':
          'For each reagent: arrival date, source, storage, date into use, '
          'batch number, expiry and problems (WHO). BSH: record batch numbers '
          'and expiry of all reagents; the system keeps a full audit trail of '
          'original results, controls, interpretations, amendments and staff. '
          'Keep the pre-transfusion sample at least 3 days post-transfusion '
          '(BSH); RF Order '
          '1134n: the recipient tube and the unit residue (≥5 mL) 48 h at '
          '2–6 °C.',
    }),
    [refWhoStorage, refBshReagents, refBshQms, refBshRetain, refRu1134Retain],
  ),
];

/// BSH Table 2: musbat va manfiy nazorat hujayralari.
const bgControlTable = <(LocalizedText, LocalizedText, LocalizedText)>[
  (
    BgL.antiA,
    _T({'uz': 'A', 'ru': 'A', 'en': 'A'}),
    _T({'uz': 'B', 'ru': 'B', 'en': 'B'}),
  ),
  (
    BgL.antiB,
    _T({'uz': 'B', 'ru': 'B', 'en': 'B'}),
    _T({'uz': 'A', 'ru': 'A', 'en': 'A'}),
  ),
  (BgL.antiD, BgL.dPos, BgL.dNeg),
];

// ───────────────────────── 6. O'qish mashqi izohlari ─────────────────────

/// Belgi izohi va manbasi.
class BgFlagInfo {
  const BgFlagInfo(this.text, this.refs);
  final LocalizedText text;
  final List<CalcRef> refs;
}

const bgFlagInfo = <BgFlag, BgFlagInfo>{
  BgFlag.discrepancy: BgFlagInfo(
    _T({
      'uz':
          'To‘g‘ri va teskari natija mos emas. Test takrorlanadi va sabab '
          'SOP bo‘yicha aniqlanadi; hal bo‘lmaguncha guruhga xos qon '
          'berilmaydi.',
      'ru':
          'Прямой и обратный результаты не совпадают. Исследование повторяют '
          'и выясняют причину по СОП; до разрешения одногруппная кровь не '
          'выдаётся.',
      'en':
          'Forward and reverse results disagree. Repeat and investigate per '
          'SOP; no group-specific blood is issued until resolved.',
    }),
    [refWhoDemo, refBshResolve],
  ),
  BgFlag.aBothPositive: BgFlagInfo(
    _T({
      'uz':
          'A antigeni ham, A1 hujayralar bilan reaksiya ham bor. Ko‘rib '
          'chiqiladi: A2/A2B dagi anti-A1, sovuq allo/autoantitelalar, rulo; '
          'to‘g‘ri usulda — musbat DAT, poliagglyutinatsiya.',
      'ru':
          'Есть и антиген A, и реакция с эритроцитами A1. Рассмотреть: анти-A1 '
          'при A2/A2B, холодовые алло-/аутоантитела, монетные столбики; в '
          'прямом методе — положительная прямая проба Кумбса, '
          'полиагглютинабельность.',
      'en':
          'Both A antigen and a reaction with A1 cells. Consider anti-A1 in '
          'A2/A2B, cold allo/autoantibodies, rouleaux; in the forward group — '
          'positive DAT, polyagglutination.',
    }),
    [refBshFigA1, refWhoSubgroups, refWhoErrors],
  ),
  BgFlag.aBothNegative: BgFlagInfo(
    _T({
      'uz':
          'A antigeni ham, anti-A ham aniqlanmadi. Ko‘rib chiqiladi: kuchsiz '
          'A varianti yoki antigen yo‘qolishi; teskari usulda kuchsiz yoki '
          'yo‘q antitela (chaqaloq, keksa, immunodefitsit).',
      'ru':
          'Не выявлены ни антиген A, ни анти-A. Рассмотреть: слабый вариант A '
          'или утрату антигена; слабые или отсутствующие антитела '
          '(новорождённый, пожилой, иммунодефицит).',
      'en':
          'Neither A antigen nor anti-A detected. Consider a weak A variant or '
          'antigen loss; weak or missing antibodies (neonate, old age, '
          'immunodeficiency).',
    }),
    [refBshFigA1, refBshAnomalies],
  ),
  BgFlag.bBothPositive: BgFlagInfo(
    _T({
      'uz':
          'B antigeni ham, B hujayralar bilan reaksiya ham bor. Ko‘rib '
          'chiqiladi: sovuq allo/autoantitelalar, rulo; to‘g‘ri usulda — '
          'musbat DAT, poliagglyutinatsiya, orttirilgan B.',
      'ru':
          'Есть и антиген B, и реакция с эритроцитами B. Рассмотреть: '
          'холодовые алло-/аутоантитела, монетные столбики; в прямом методе — '
          'положительная прямая проба Кумбса, полиагглютинабельность, '
          'приобретённый B.',
      'en':
          'Both B antigen and a reaction with B cells. Consider cold '
          'allo/autoantibodies, rouleaux; in the forward group — positive '
          'DAT, polyagglutination, acquired B.',
    }),
    [refBshFigA1, refWhoErrors, refHagman],
  ),
  BgFlag.bBothNegative: BgFlagInfo(
    _T({
      'uz':
          'B antigeni ham, anti-B ham aniqlanmadi. Ko‘rib chiqiladi: kuchsiz '
          'B varianti yoki antigen yo‘qolishi; kuchsiz yoki yo‘q antitela.',
      'ru':
          'Не выявлены ни антиген B, ни анти-B. Рассмотреть: слабый вариант B '
          'или утрату антигена; слабые или отсутствующие антитела.',
      'en':
          'Neither B antigen nor anti-B detected. Consider a weak B variant or '
          'antigen loss; weak or missing antibodies.',
    }),
    [refBshFigA1, refBshAnomalies],
  ),
  BgFlag.reverseMissing: BgFlagInfo(
    _T({
      'uz':
          'Faqat to‘g‘ri usul — bu guruhning yarmi. To‘liq ABO guruhi uchun '
          'teskari usul ham kerak (chaqaloqlardan tashqari).',
      'ru':
          'Только прямой метод — это половина группы. Для полного AB0 нужен и '
          'обратный метод (кроме новорождённых).',
      'en':
          'Forward only is half the group. A full ABO group also needs the '
          'reverse group (except in neonates).',
    }),
    [refWhoDemo, refBshTests],
  ),
  BgFlag.forwardMissing: BgFlagInfo(
    _T({
      'uz': 'Faqat teskari usul — to‘g‘ri usul ham kerak.',
      'ru': 'Только обратный метод — нужен и прямой.',
      'en': 'Reverse only — the forward group is also needed.',
    }),
    [refBshTests],
  ),
  BgFlag.controlPositive: BgFlagInfo(
    _T({
      'uz':
          'Nazorat musbat — natija yaroqsiz. Sovuq autoantitela yoki '
          'autoagglyutinatsiyada hujayralarni iliq fiziologik eritmada yuvish '
          'foydali bo‘lishi mumkin; SOP bo‘yicha qayta tekshiring.',
      'ru':
          'Контроль положительный — результат недействителен. При холодовых '
          'аутоантителах или аутоагглютинации может помочь отмывка тёплым '
          'физраствором; повторите по СОП.',
      'en':
          'Control positive — the result is invalid. With cold autoantibodies '
          'or autoagglutination, washing in warm saline may help; retest per '
          'SOP.',
    }),
    [refBshControls],
  ),
  BgFlag.allPositiveNoControl: BgFlagInfo(
    _T({
      'uz':
          'Hamma reagent bilan musbat (AB D musbat) va nazorat yo‘q: sovuq '
          'agglyutininlar o‘tkazib yuborilishi mumkin — nazorat qo‘ying.',
      'ru':
          'Все реакции положительны (AB D+), контроля нет: можно пропустить '
          'холодовые агглютинины — поставьте контроль.',
      'en':
          'All reagents positive (AB D positive) with no control: cold '
          'agglutinins may be missed — include a control.',
    }),
    [refBshEmergency],
  ),
  BgFlag.weakForward: BgFlagInfo(
    _T({
      'uz':
          'Anti-A yoki anti-B bilan kuchsiz reaksiya — anomaliya, guruh '
          'aytilmaydi. A/B variantlari monoklonal reagentlar bilan kuchsiz '
          'yoki manfiy reaksiya berishi mumkin; test takrorlanadi va sabab SOP '
          'bo‘yicha aniqlanadi, guruhni tasdiqlash uchun ma’lumotnoma '
          'laboratoriyasi kerak bo‘lishi mumkin.',
      'ru':
          'Слабая реакция с анти-A или анти-B — аномалия, группа не '
          'устанавливается. Варианты A/B могут давать слабые или отрицательные '
          'реакции с моноклональными реагентами; исследование повторяют и '
          'выясняют причину по СОП, для подтверждения группы может '
          'понадобиться референтная лаборатория.',
      'en':
          'Weak reaction with anti-A or anti-B — an anomaly, no group is '
          'assigned. A/B variants may give weak or negative reactions with '
          'monoclonal reagents; repeat and investigate per SOP — referral to a '
          'reference centre may be needed to confirm the group.',
    }),
    [refBshAnomalies, refBshResolve, refBshFigA1],
  ),
  BgFlag.mixedField: BgFlagInfo(
    _T({
      'uz':
          'Aralash maydon — anomaliya: guruh tasdiqlanishidan yoki '
          'eritrotsitlar berilishidan oldin test takrorlanadi va/yoki '
          'tekshiriladi. Sabablari: ABO/D bo‘yicha mos bo‘lmagan (hatto '
          'nomuvofiq) transfuziya, mos bo‘lmagan gemopoetik ildiz hujayra '
          'transplantatsiyasi, A3 yoki B3, katta homila-ona qon o‘tishi, '
          'kamdan-kam — ximera.',
      'ru':
          'Смешанное поле — аномалия: до утверждения группы или выдачи '
          'эритроцитов исследование повторяют и/или выясняют причину. Причины: '
          'ABO/D-несовпадающая (даже несовместимая) трансфузия, несовпадающая '
          'трансплантация гемопоэтических стволовых клеток, A3 или B3, '
          'массивное фетоматеринское кровотечение, редко — химеризм.',
      'en':
          'Mixed field — an anomaly: repeat and/or investigate before the '
          'group is authorised or red cells are issued. Causes: an ABO/D '
          'mismatched or even incompatible transfusion, a mismatched '
          'haemopoietic stem cell transplant, A3 or B3, a large fetomaternal '
          'haemorrhage or, rarely, a chimera.',
    }),
    [refBshAnomalies, refBshResolve],
  ),
  BgFlag.weakD: BgFlagInfo(
    _T({
      'uz':
          'Anti-D bilan kuchsiz reaksiya: BSH Fig. 1 — 50 yosh va undan kichik '
          'ayol yoki doimiy transfuziyaga muhtoj bemor D manfiy deb qaraladi '
          'va tasdiqlashga yuboriladi; boshqalar — D musbat. Mahalliy '
          'siyosatga qarang.',
      'ru':
          'Слабая реакция с анти-D: BSH Fig. 1 — женщину ≤50 лет или пациента '
          'с вероятными постоянными трансфузиями считают D-отрицательным и '
          'направляют на подтверждение; остальных — D-положительными. См. '
          'местную политику.',
      'en':
          'Weak anti-D reaction: BSH Fig. 1 — a female ≤50 or a patient likely '
          'to need chronic transfusion is treated as D negative and referred; '
          'others as D positive. Follow local policy.',
    }),
    [refBshFig1],
  ),
};

// ───────────────────────── Mashq ─────────────────────────

/// Mashq savoli: to'g'ri javob birinchi ([options][0]); ekranda aralashtiriladi.
class BgQuizItem {
  const BgQuizItem(this.id, this.prompt, this.options, this.basis);
  final String id;
  final LocalizedText prompt;
  final List<LocalizedText> options;
  final LocalizedText basis;
}

LocalizedText _pattern(String aA, String aB, String a1, String b) => _T({
  'uz': 'Anti-A $aA, anti-B $aB; A1 hujayra $a1, B hujayra $b. Talqin?',
  'ru': 'Анти-A $aA, анти-B $aB; эр. A1 $a1, эр. B $b. Интерпретация?',
  'en': 'Anti-A $aA, anti-B $aB; A1 cells $a1, B cells $b. Interpretation?',
});

const _discrepancyOption = _T({
  'uz': 'Nomuvofiqlik — guruh berilmaydi, tekshiriladi',
  'ru': 'Расхождение — группу не выдают, исследуют',
  'en': 'Discrepancy — no group assigned; investigate',
});

final bgQuiz = <BgQuizItem>[
  BgQuizItem(
    'bg-q-pattern-a',
    _pattern('+', '−', '−', '+'),
    [
      aboGroupNames[AboGroup.a]!,
      aboGroupNames[AboGroup.b]!,
      aboGroupNames[AboGroup.o]!,
      _discrepancyOption,
    ],
    const _T({
      'uz': 'A antigeni bor, plazmada anti-B — A guruh (JSST, mashq 8).',
      'ru': 'Есть антиген A, в плазме анти-B — группа A (ВОЗ, упражнение 8).',
      'en': 'A antigen with anti-B in plasma — group A (WHO, activity 8).',
    }),
  ),
  BgQuizItem(
    'bg-q-pattern-o',
    _pattern('−', '−', '+', '+'),
    [
      aboGroupNames[AboGroup.o]!,
      aboGroupNames[AboGroup.ab]!,
      aboGroupNames[AboGroup.a]!,
      _discrepancyOption,
    ],
    const _T({
      'uz': 'Antigen yo‘q, anti-A va anti-B bor — O guruh.',
      'ru': 'Антигенов нет, есть анти-A и анти-B — группа 0.',
      'en': 'No antigens, anti-A and anti-B present — group O.',
    }),
  ),
  BgQuizItem(
    'bg-q-pattern-ab',
    _pattern('+', '+', '−', '−'),
    [
      aboGroupNames[AboGroup.ab]!,
      aboGroupNames[AboGroup.o]!,
      aboGroupNames[AboGroup.b]!,
      _discrepancyOption,
    ],
    const _T({
      'uz': 'A va B antigenlari bor, antitela yo‘q — AB guruh.',
      'ru': 'Есть антигены A и B, антител нет — группа AB.',
      'en': 'A and B antigens, no antibodies — group AB.',
    }),
  ),
  BgQuizItem(
    'bg-q-pattern-discrepancy',
    _pattern('−', '+', '−', '−'),
    [
      _discrepancyOption,
      aboGroupNames[AboGroup.b]!,
      aboGroupNames[AboGroup.ab]!,
      aboGroupNames[AboGroup.o]!,
    ],
    const _T({
      'uz':
          'To‘g‘ri usul — B, teskari — kutilgan anti-A yo‘q. Mos kelmasa — '
          'xato signali, takrorlanadi; anomaliya qon berilishidan oldin hal '
          'qilinadi (JSST §4.3; BSH §4.8.1).',
      'ru':
          'Прямой метод — B, в обратном нет ожидаемого анти-A. Несовпадение — '
          'сигнал ошибки, повтор; аномалию разрешают до выдачи крови (ВОЗ '
          '§4.3; BSH §4.8.1).',
      'en':
          'Forward says B, but the expected anti-A is missing. Disagreement '
          'signals an error and is repeated; anomalies are resolved before '
          'issue (WHO §4.3; BSH §4.8.1).',
    }),
  ),
  BgQuizItem(
    'bg-q-grade-1',
    const _T({
      'uz': 'JSST shkalasida “1+” nimani bildiradi?',
      'ru': 'Что означает «1+» по шкале ВОЗ?',
      'en': 'What does “1+” mean on the WHO scale?',
    }),
    const [
      _T({
        'uz': 'Ko‘zga kuchsiz musbat, lupada aniq musbat',
        'ru': 'Слабо положительно глазом, чётко — с лупой',
        'en': 'Weakly positive to the eye, clearly positive with a lens',
      }),
      _T({
        'uz': 'Barcha hujayralar to‘liq agglyutinatsiyalangan',
        'ru': 'Полная агглютинация всех клеток',
        'en': 'Complete agglutination of all cells',
      }),
      _T({
        'uz': 'Eritrotsitlar lizisi',
        'ru': 'Лизис эритроцитов',
        'en': 'Lysis of red cells',
      }),
      _T({
        'uz': 'Ko‘pi agglyutinatsiyalangan, ba’zilari erkin',
        'ru': 'Большинство агглютинировано, есть свободные',
        'en': 'Most cells agglutinated, some free',
      }),
    ],
    const _T({
      'uz': 'JSST §7.8: 4+ — to‘liq, 3+ — ko‘pi, 1+ — lupada aniq, L — lizis.',
      'ru': 'ВОЗ §7.8: 4+ — полная, 3+ — большинство, 1+ — с лупой, L — лизис.',
      'en': 'WHO §7.8: 4+ complete, 3+ most, 1+ clear with a lens, L lysis.',
    }),
  ),
  BgQuizItem(
    'bg-q-slide',
    const _T({
      'uz': 'Plastinka (kafel) usulida reaksiya qachon o‘qiladi?',
      'ru': 'Когда читать реакцию на плоскости (по ВОЗ)?',
      'en': 'When is a slide (tile) test read?',
    }),
    const [
      _T({
        'uz': '2 daqiqa ichida — keyin quriydi va soxta musbat',
        'ru': 'В течение 2 минут — потом подсыхание даёт ложный «+»',
        'en': 'Within 2 minutes — drying then gives false positives',
      }),
      _T({
        'uz': '15 daqiqadan keyin',
        'ru': 'Через 15 минут',
        'en': 'After 15 minutes',
      }),
      _T({
        'uz': '37 °C da 30 daqiqadan keyin',
        'ru': 'После 30 минут при 37 °C',
        'en': 'After 30 minutes at 37 °C',
      }),
      _T({
        'uz': 'Vaqt ahamiyatsiz',
        'ru': 'Время не важно',
        'en': 'Timing does not matter',
      }),
    ],
    const _T({
      'uz': 'JSST §7.7: 2 daqiqa ichida; usul faqat dastlabki tez guruh uchun.',
      'ru': 'ВОЗ §7.7: в течение 2 минут; метод — лишь для предварительной группы.',
      'en': 'WHO §7.7: within 2 minutes; only for a preliminary rapid group.',
    }),
  ),
  BgQuizItem(
    'bg-q-newborn',
    const _T({
      'uz': 'Chaqaloq namunasida teskari usul haqida to‘g‘ri gap?',
      'ru': 'Что верно об обратном методе у новорождённого?',
      'en': 'What is true of the reverse group in a newborn?',
    }),
    const [
      _T({
        'uz': 'Foydasiz: antitelalar yo‘q yoki onadan o‘tgan',
        'ru': 'Неинформативен: антител нет или они материнские',
        'en': 'Unhelpful: antibodies absent or maternal',
      }),
      _T({
        'uz': 'Faqat teskari usul yetarli',
        'ru': 'Достаточно только обратного метода',
        'en': 'The reverse group alone is enough',
      }),
      _T({
        'uz': 'Anti-A va anti-B kattalarnikidan kuchli',
        'ru': 'Анти-A и анти-B сильнее, чем у взрослых',
        'en': 'Anti-A and anti-B are stronger than in adults',
      }),
      _T({
        'uz': 'Ikki marta takrorlansa ishonchli',
        'ru': 'Надёжен, если повторить дважды',
        'en': 'Reliable if repeated twice',
      }),
    ],
    const _T({
      'uz':
          'BSH §4.3.1: antitelalar onaniki bo‘lishi mumkin; JSST §4.4: anti-A '
          'va anti-B ~3 oylikkacha aniqlanmasligi mumkin.',
      'ru':
          'BSH §4.3.1: антитела могут быть материнскими; ВОЗ §4.4: анти-A и '
          'анти-B могут не выявляться примерно до 3 месяцев.',
      'en':
          'BSH §4.3.1: antibodies are likely maternal; WHO §4.4: anti-A and '
          'anti-B may not be demonstrable until about 3 months.',
    }),
  ),
  BgQuizItem(
    'bg-q-immediate-spin',
    const _T({
      'uz': 'Darhol sentrifugalash sinamasining asosiy cheklovi?',
      'ru':
          'Главное ограничение солевой пробы с немедленным '
          'центрифугированием?',
      'en': 'The main limitation of the immediate-spin crossmatch?',
    }),
    const [
      _T({
        'uz': 'IgG antitelalarni aniqlamaydi',
        'ru': 'Не выявляет IgG-антитела',
        'en': 'It does not detect IgG antibodies',
      }),
      _T({
        'uz': 'ABO nomosligini aniqlamaydi',
        'ru': 'Не выявляет несовместимость по AB0',
        'en': 'It cannot detect ABO incompatibility',
      }),
      _T({
        'uz': '37 °C da 60 daqiqa davom etadi',
        'ru': 'Длится 60 минут при 37 °C',
        'en': 'It takes 60 minutes at 37 °C',
      }),
      _T({
        'uz': 'Faqat gel-kartada bajariladi',
        'ru': 'Выполняется только в гелевых картах',
        'en': 'It runs only on gel cards',
      }),
    ],
    const _T({
      'uz': 'BSH §7.4: IgG ni aniqlamaydi — IAT o‘rnini bosmaydi.',
      'ru': 'BSH §7.4: не выявляет IgG — НАТ не заменяет.',
      'en': 'BSH §7.4: misses IgG — it does not replace the IAT.',
    }),
  ),
  BgQuizItem(
    'bg-q-second-sample',
    const _T({
      'uz': 'BSH bo‘yicha ikkinchi namuna nima uchun so‘raladi?',
      'ru': 'Зачем по BSH запрашивают второй образец?',
      'en': 'Why does BSH ask for a second sample?',
    }),
    const [
      _T({
        'uz':
            'Birinchi marta tekshirilgan bemor ABO guruhini tasdiqlash (WBIT)',
        'ru': 'Подтвердить AB0 у впервые обследуемого пациента (WBIT)',
        'en': 'To confirm a first-time patient’s ABO group (WBIT)',
      }),
      _T({
        'uz': 'Gemoglobinni o‘lchash uchun',
        'ru': 'Для измерения гемоглобина',
        'en': 'To measure haemoglobin',
      }),
      _T({
        'uz': 'Reagent sifatini tekshirish uchun',
        'ru': 'Для контроля качества реагентов',
        'en': 'To quality-control the reagents',
      }),
      _T({
        'uz': 'Faqat chaqaloqlarda',
        'ru': 'Только у новорождённых',
        'en': 'Only for newborns',
      }),
    ],
    const _T({
      'uz': 'BSH §7.2.1: taxminan 2000 namunadan 1 tasi boshqa bemordan.',
      'ru': 'BSH §7.2.1: около 1 из 2000 образцов — не от того пациента.',
      'en': 'BSH §7.2.1: about 1 in 2000 samples is from the wrong patient.',
    }),
  ),
  BgQuizItem(
    'bg-q-rouleaux',
    const _T({
      'uz': 'Rulo haqiqiy agglyutinatsiyadan qanday farqlanadi (JSST)?',
      'ru': 'Как отличить монетные столбики от агглютинации (ВОЗ)?',
      'en': 'How are rouleaux told apart from agglutination (WHO)?',
    }),
    const [
      _T({
        'uz': 'Gipertonik eritma (1,5%) tomchisidan keyin tarqaladi',
        'ru': 'Расходятся после капли гипертонического раствора (1,5%)',
        'en': 'They disperse after a drop of hypertonic saline (1.5%)',
      }),
      _T({
        'uz': 'Faqat 37 °C da paydo bo‘ladi',
        'ru': 'Появляются только при 37 °C',
        'en': 'They appear only at 37 °C',
      }),
      _T({
        'uz': 'Har doim 4+ beradi',
        'ru': 'Всегда дают 4+',
        'en': 'They always grade 4+',
      }),
      _T({
        'uz': 'Faqat anti-D bilan uchraydi',
        'ru': 'Бывают только с анти-D',
        'en': 'They occur only with anti-D',
      }),
    ],
    const _T({
      'uz': 'JSST §7.14: rulo tarqaladi, haqiqiy agglyutinatsiya — yo‘q.',
      'ru': 'ВОЗ §7.14: столбики расходятся, истинная агглютинация — нет.',
      'en': 'WHO §7.14: rouleaux disperse; true agglutination does not.',
    }),
  ),
];

/// Mashq uchun manbalar.
const bgQuizRefs = [
  refWhoAnswers,
  refWhoDemo,
  refWhoGrading,
  refWhoReading,
  refWhoNewborn,
  refWhoErrors,
  refBshTests,
  refBshResolve,
  refBshIs,
  refBshWbit,
];
