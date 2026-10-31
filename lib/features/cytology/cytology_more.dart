/// Sitologiya qo'shimchalari (6b-blok): namuna sifati va artefaktlar,
/// reaktiv o'zgarishlar va atipiya farqi, yetilish indeksi, boshqa namunalar.
///
/// Har band — ochiq to'liq matnli manbadan (17-oktabr tekshirildi), joyi
/// [CalcRef] lokatorida va docs/CYTOLOGY_SOURCES.md da. Manbada yo'q raqam
/// yozilmaydi. Mutaxassis tekshiruvidan o'tmagan — ekranda "qoralama".
library;

import '../content/content_model.dart';
import '../tools/calc_info.dart';
import 'cytology_content.dart';

typedef _T = LocalizedText;

/// Sarlavha + matn + manbalar.
class CytoFact {
  const CytoFact(this.title, this.body, this.refs);
  final LocalizedText title;
  final LocalizedText body;
  final List<CalcRef> refs;
}

// ───────────────────────── Namuna sifati ─────────────────────────

const cytoAdequacy = <CytoFact>[
  CytoFact(
    _T({'uz': 'Ikki kategoriya', 'ru': 'Две категории', 'en': 'Two categories'}),
    _T({
      'uz':
          'Baholash uchun yaroqli — xulosada endotservikal/transformatsiya '
          'zonasi komponenti bor-yo‘qligi va boshqa sifat belgilari (masalan, '
          'qisman yopuvchi qon, yallig‘lanish) yoziladi.\n'
          'Baholash uchun yaroqsiz — sababi ko‘rsatiladi: namuna qabul '
          'qilinmagan/ishlanmagan yoki ishlangan va ko‘rilgan, lekin epiteliy '
          'anomaliyasini baholab bo‘lmaydi.',
      'ru':
          'Пригоден для оценки — в заключении указывают наличие или '
          'отсутствие эндоцервикального компонента/компонента зоны '
          'трансформации и другие показатели качества (например, частично '
          'закрывающая кровь, воспаление).\n'
          'Непригоден для оценки — с указанием причины: образец отклонён/не '
          'обработан либо обработан и просмотрен, но эпителиальную патологию '
          'оценить нельзя.',
      'en':
          'Satisfactory for evaluation — the report notes whether an '
          'endocervical/transformation zone component is present and other '
          'quality indicators (e.g. partially obscuring blood, inflammation).\n'
          'Unsatisfactory for evaluation — with the reason: specimen '
          'rejected/not processed, or processed and examined but '
          'unsatisfactory for evaluating epithelial abnormality.',
    }),
    [
      CalcRef(CytoSources.pangarkar2022, 'Specimen adequacy'),
      CalcRef(CytoSources.wang2023, 'Specimen adequacy'),
    ],
  ),
  CytoFact(
    _T({
      'uz': 'Yassi hujayralar soni (taxminiy minimum)',
      'ru': 'Количество плоских клеток (ориентировочный минимум)',
      'en': 'Squamous cellularity (estimated minimum)',
    }),
    _T({
      'uz':
          'An’anaviy surtma: 8 000–12 000 ta yaxshi ko‘rinadigan, yaxshi '
          'saqlangan yassi yoki yassi metaplastik hujayra.\n'
          'Suyuq asosli preparat: 5 000 ta.\n'
          'Son "mos yozuvli rasmlar" bilan solishtirib, taxminan baholanadi.',
      'ru':
          'Традиционный мазок: 8 000–12 000 хорошо видимых, хорошо сохранных '
          'плоских или плоскоклеточных метапластических клеток.\n'
          'Жидкостный препарат: 5 000.\n'
          'Количество оценивают ориентировочно, сравнивая с эталонными '
          'изображениями.',
      'en':
          'Conventional smear: 8,000–12,000 well-visualised, well-preserved '
          'squamous or squamous metaplastic cells.\n'
          'Liquid-based preparation: 5,000.\n'
          'The count is estimated by comparison with reference images.',
    }),
    [
      CalcRef(CytoSources.wang2023, 'Specimen adequacy'),
      CalcRef(CytoSources.capToday2026, 'p. 1'),
      CalcRef(CytoSources.pangarkar2022, 'Cellularity'),
    ],
  ),
  CytoFact(
    _T({
      'uz': 'Pastroq chegara (alohida holatlar)',
      'ru': 'Сниженный порог (особые случаи)',
      'en': 'Lower threshold (special cases)',
    }),
    _T({
      'uz':
          'Atrofiya, gisterektomiyadan keyin (qin gumbazi), nur yoki '
          'kimyoterapiyadan keyin 2 000 ta hujayra chegarasi qabul qilinishi '
          'mumkin. 2 000 tadan kam hujayrali namuna ko‘p hollarda yaroqsiz.',
      'ru':
          'При атрофии, после гистерэктомии (купол влагалища), после лучевой '
          'или химиотерапии можно принять порог 2 000 клеток. Образец менее '
          'чем с 2 000 клеток в большинстве случаев непригоден.',
      'en':
          'In atrophy, after hysterectomy (vaginal vault), radiation or '
          'chemotherapy a 2,000-cell threshold may be accepted. A specimen '
          'with fewer than 2,000 cells is unsatisfactory in most cases.',
    }),
    [
      CalcRef(CytoSources.pangarkar2022, 'Cellularity'),
      CalcRef(CytoSources.wang2023, 'Specimen adequacy'),
      CalcRef(CytoSources.capToday2026, 'p. 1'),
    ],
  ),
  CytoFact(
    _T({
      'uz': 'Transformatsiya zonasi komponenti',
      'ru': 'Компонент зоны трансформации',
      'en': 'Transformation zone component',
    }),
    _T({
      'uz':
          'Bor-yo‘qligi xulosada yoziladi. Yetarli deyilishi uchun kamida 10 '
          'ta yaxshi saqlangan endotservikal yoki yassi metaplastik hujayra '
          '(yakka yoki to‘da) kerak — an’anaviy va suyuq asosli preparatda '
          'bir xil.',
      'ru':
          'Его наличие или отсутствие указывают в заключении. Достаточным '
          'считается не менее 10 хорошо сохранных эндоцервикальных или '
          'плоскоклеточных метапластических клеток (по одной или группами) — '
          'одинаково для традиционного и жидкостного препарата.',
      'en':
          'Its presence or absence is reported. An adequate sample needs at '
          'least 10 well-preserved endocervical or squamous metaplastic cells, '
          'singly or in clusters — the same for conventional and liquid-based '
          'preparations.',
    }),
    [
      CalcRef(
        CytoSources.pangarkar2022,
        'Endocervical/transformation zone component',
      ),
      CalcRef(CytoSources.wang2023, 'Specimen adequacy'),
    ],
  ),
  CytoFact(
    _T({
      'uz': 'Yopuvchi omillar',
      'ru': 'Закрывающие факторы',
      'en': 'Obscuring factors',
    }),
    _T({
      'uz':
          'Yassi hujayralarning 75 % dan ko‘pi yaxshi ko‘rinmasa — namuna '
          'yaroqsiz. Xulosada qon, shilliq, lubrikant, yallig‘lanish yoki '
          'texnik artefakt sabab bo‘lganmi yoki shunchaki hujayra kammi — '
          'yoziladi. Suyuq asosli preparatda yopuvchi moddalar odatda kamroq '
          'muammo tug‘diradi.',
      'ru':
          'Если более 75 % плоских клеток плохо видны — образец непригоден. В '
          'заключении указывают, были ли причиной кровь, слизь, лубрикант, '
          'воспаление или технический артефакт, либо просто мало клеток. В '
          'жидкостных препаратах закрывающие вещества обычно меньше мешают.',
      'en':
          'If more than 75% of squamous cells are not well visualised, the '
          'specimen is unsatisfactory. The report states whether blood, mucus, '
          'lubricant, inflammation or technical artefact contributed, or simply '
          'low cellularity. Obscuring material is usually less of a problem in '
          'liquid-based preparations.',
    }),
    [
      CalcRef(CytoSources.wang2023, 'Specimen adequacy'),
      CalcRef(CytoSources.capToday2026, 'p. 1'),
      CalcRef(
        CytoSources.pangarkar2022,
        'Endocervical/transformation zone component',
      ),
    ],
  ),
  CytoFact(
    _T({
      'uz': 'Atipik hujayra topilsa',
      'ru': 'Если найдены атипичные клетки',
      'en': 'If abnormal cells are found',
    }),
    _T({
      'uz': 'Anomal hujayrali har qanday namuna ta’rifga ko‘ra yaroqli hisoblanadi.',
      'ru': 'Любой образец с аномальными клетками по определению считается пригодным.',
      'en': 'Any specimen with abnormal cells is by definition satisfactory.',
    }),
    [CalcRef(CytoSources.pangarkar2022, 'Specimen adequacy')],
  ),
  CytoFact(
    _T({
      'uz': 'Yaroqsiz natijadan keyin',
      'ru': 'После непригодного результата',
      'en': 'After an unsatisfactory result',
    }),
    _T({
      'uz':
          'Keyingi qadamni shifokor belgilaydi. ASCCP 2019: HPV testi yo‘q, '
          'noma’lum yoki manfiy bo‘lsa — 2–4 oydan keyin takroriy tekshiruv; '
          'HPV bilan triaj tavsiya etilmaydi.',
      'ru':
          'Тактику определяет врач. ASCCP 2019: если теста на ВПЧ нет, его '
          'результат неизвестен или отрицателен — повтор через 2–4 месяца; '
          'триаж по ВПЧ не рекомендуется.',
      'en':
          'The clinician decides. ASCCP 2019: with no, unknown or a negative '
          'HPV test — repeat testing in 2–4 months; HPV triage is not '
          'recommended.',
    }),
    [CalcRef(CytoSources.asccp2019, 'Section G.2')],
  ),
];

/// Ko'p uchraydigan artefaktlar va sifat muammolari.
const cytoArtefacts = <CytoFact>[
  CytoFact(
    _T({
      'uz': 'Havoda qurib qolish (kech fiksatsiya)',
      'ru': 'Высыхание на воздухе (поздняя фиксация)',
      'en': 'Air-drying (delayed fixation)',
    }),
    _T({
      'uz':
          'Polixromaziya va yadroning to‘q bo‘yalishiga olib keladi; bunday '
          'surtma noto‘g‘ri ASC-US deb baholanishi mumkin. IARC atlasida '
          'qurigan surtmalar yaroqsiz namuna misollari orasida.',
      'ru':
          'Вызывает полихромазию и тёмное окрашивание ядер; такой мазок может '
          'быть ошибочно расценён как ASC-US. В атласе IARC высохшие мазки '
          'приведены среди примеров непригодных образцов.',
      'en':
          'Causes polychromasia and dark nuclear staining; such smears may be '
          'falsely labelled ASC-US. The IARC atlas shows air-dried smears among '
          'its unsatisfactory examples.',
    }),
    [
      CalcRef(
        CytoSources.kattoor2022,
        'ASC-US due to compromised specimen, Fig. 12',
      ),
      CalcRef(CytoSources.iarcUnsat, 'cyt15383, cyto0000'),
    ],
  ),
  CytoFact(
    _T({'uz': 'Qon', 'ru': 'Кровь', 'en': 'Blood'}),
    _T({
      'uz':
          'Epiteliyni qisman yopadi; ayniqsa hujayra kam bo‘lsa (masalan, '
          'hayz paytida) namuna yaroqsiz bo‘lishi mumkin.',
      'ru':
          'Частично закрывает эпителий; особенно при малом количестве клеток '
          '(например, во время менструации) образец может быть непригоден.',
      'en':
          'Partly masks the epithelium; especially with scant cellularity '
          '(e.g. during menses) the specimen may be unsatisfactory.',
    }),
    [CalcRef(CytoSources.iarcUnsat, 'cyto8608, cyto8510, cyto8504')],
  ),
  CytoFact(
    _T({
      'uz': 'Kuchli yallig‘lanish',
      'ru': 'Выраженное воспаление',
      'en': 'Heavy inflammation',
    }),
    _T({
      'uz':
          'Hujayra to‘dalarini tahlil qilishni qiyinlashtiradi. IARC atlasi '
          'izohida — mahalliy davolashdan keyin takrorlash.',
      'ru':
          'Затрудняет анализ клеточных групп. В подписи атласа IARC — повтор '
          'после местного лечения.',
      'en':
          'Makes cell groups hard to analyse. The IARC atlas caption advises '
          'repeating after local treatment.',
    }),
    [CalcRef(CytoSources.iarcUnsat, 'cyto8502, cyto8503')],
  ),
  CytoFact(
    _T({
      'uz': 'Lubrikant va shilliq',
      'ru': 'Лубрикант и слизь',
      'en': 'Lubricant and mucus',
    }),
    _T({
      'uz': 'Yopuvchi omillar qatorida; xulosada sabab sifatida ko‘rsatiladi.',
      'ru': 'Относятся к закрывающим факторам; указываются в заключении как причина.',
      'en':
          'Listed among obscuring factors; named as the reason in the report.',
    }),
    [
      CalcRef(CytoSources.wang2023, 'Specimen adequacy'),
      CalcRef(
        CytoSources.pangarkar2022,
        'Endocervical/transformation zone component',
      ),
    ],
  ),
  CytoFact(
    _T({
      'uz': 'Qalin hujayra bo‘laklari',
      'ru': 'Толстые клеточные фрагменты',
      'en': 'Thick cell fragments',
    }),
    _T({
      'uz':
          'Asbob bilan qattiq qirish qalin bo‘laklar beradi — ulardagi '
          'hujayralar reaktivmi yoki o‘smami, aniqlash qiyin. Bu oldini olsa '
          'bo‘ladigan sabab.',
      'ru':
          'Грубое соскабливание инструментом даёт толстые фрагменты — в них '
          'трудно определить, реактивные клетки или опухолевые. Это '
          'устранимая причина.',
      'en':
          'Vigorous scraping produces thick fragments in which reactive and '
          'neoplastic cells are hard to tell apart — an avoidable cause.',
    }),
    [CalcRef(CytoSources.kattoor2022, 'ASC-H, hyperchromatic crowded groups')],
  ),
  CytoFact(
    _T({
      'uz': 'Yomon saqlanish (degeneratsiya)',
      'ru': 'Плохая сохранность (дегенерация)',
      'en': 'Poor preservation (degeneration)',
    }),
    _T({
      'uz':
          'Sitoplazmaning vakuolali degeneratsiyasi koylotsitga o‘xshab '
          'qolishi mumkin; yadrolar "surkalgan" yoki vakuolali bo‘ladi. '
          'Xulosada takroriy surtma tavsiyasi ta’kidlanadi.',
      'ru':
          'Вакуольная дегенерация цитоплазмы может имитировать койлоциты; '
          'ядра «смазанные» или вакуолизированные. В заключении подчёркивают '
          'необходимость повторного мазка.',
      'en':
          'Vacuolar cytoplasmic degeneration may mimic koilocytes; nuclei look '
          'smudged or vacuolated. The report emphasises a repeat smear.',
    }),
    [CalcRef(CytoSources.kattoor2022, 'ASC-US due to compromised specimen')],
  ),
];

const cytoAdequacyRefs = [
  CalcRef(CytoSources.pangarkar2022, ''),
  CalcRef(CytoSources.wang2023, ''),
  CalcRef(CytoSources.capToday2026, ''),
  CalcRef(CytoSources.iarcUnsat, ''),
  CalcRef(CytoSources.kattoor2022, ''),
  CalcRef(CytoSources.asccp2019, ''),
];

// ───────────────────────── Reaktiv o'zgarishlar va atipiya ─────────────────

/// Taqqoslash jadvali ustunlari sarlavhalari.
const cytoCompareHeads = <LocalizedText>[
  _T({
    'uz': 'Reaktiv (NILM)',
    'ru': 'Реактивные (NILM)',
    'en': 'Reactive (NILM)',
  }),
  _T({'uz': 'ASC-US', 'ru': 'ASC-US', 'en': 'ASC-US'}),
  _T({'uz': 'LSIL', 'ru': 'LSIL', 'en': 'LSIL'}),
];

/// Jadval qatori: belgi va uch ustun. `null` — manbalarda shu ustun uchun
/// alohida mezon topilmadi (yozilmaydi).
class CytoCompareRow {
  const CytoCompareRow(this.feature, this.cells, this.refs);
  final LocalizedText feature;

  /// [cytoCompareHeads] tartibida.
  final List<LocalizedText?> cells;
  final List<CalcRef> refs;
}

const cytoCompare = <CytoCompareRow>[
  CytoCompareRow(
    _T({'uz': 'Yadro o‘lchami', 'ru': 'Размер ядра', 'en': 'Nuclear size'}),
    [
      _T({
        'uz': 'Biroz kattalashgan: oraliq hujayra yadrosidan < 2 marta.',
        'ru': 'Слегка увеличено: менее чем в 2 раза больше ядра промежуточной клетки.',
        'en': 'Slightly enlarged: < 2× an intermediate cell nucleus.',
      }),
      _T({
        'uz':
            'Normal oraliq hujayra yadrosi maydonidan taxminan 2,5–3 marta '
            '(metaplastik hujayra yadrosidan ~2 marta) katta.',
        'ru':
            'Примерно в 2,5–3 раза больше площади ядра нормальной '
            'промежуточной клетки (~в 2 раза больше ядра метапластической).',
        'en':
            'About 2.5–3× the area of a normal intermediate nucleus (~2× a '
            'metaplastic cell nucleus).',
      }),
      _T({
        'uz': 'Eng yaqqol belgi — g‘ayritabiiy katta, to‘q yadro.',
        'ru': 'Самый яркий признак — аномально крупное тёмное ядро.',
        'en': 'The most striking feature — an abnormally large, dark nucleus.',
      }),
    ],
    [
      CalcRef(CytoSources.kamal2022, 'Inflammatory changes in squamous cells'),
      CalcRef(CytoSources.kattoor2022, 'ASC-US with mature cytoplasm'),
      CalcRef(CytoSources.slhAbnormal, 'ASC-US; LSIL'),
    ],
  ),
  CytoCompareRow(
    _T({
      'uz': 'Yadro qobig‘i va xromatin',
      'ru': 'Ядерная мембрана и хроматин',
      'en': 'Nuclear membrane and chromatin',
    }),
    [
      _T({
        'uz': 'Kontur silliq, dumaloq; xromatin mayda, och.',
        'ru': 'Контур гладкий, округлый; хроматин мелкий, бледный.',
        'en': 'Smooth, round outline; fine, pale chromatin.',
      }),
      _T({
        'uz':
            'Kontur silliq yoki biroz notekis; xromatin mayda donador, bir tekis; '
            'giperxromaziya minimal.',
        'ru':
            'Контур гладкий или слегка неровный; хроматин мелкозернистый, '
            'равномерный; гиперхромазия минимальна.',
        'en':
            'Smooth or slightly irregular outline; finely granular, evenly '
            'distributed chromatin; minimal hyperchromasia.',
      }),
      null,
    ],
    [
      CalcRef(CytoSources.kamal2022, 'Inflammatory changes in squamous cells'),
      CalcRef(
        CytoSources.kattoor2022,
        'Summary: morphologic criteria of ASC-US',
      ),
      CalcRef(CytoSources.slhAbnormal, 'ASC-US'),
    ],
  ),
  CytoCompareRow(
    _T({'uz': 'Yadrocha', 'ru': 'Ядрышки', 'en': 'Nucleoli'}),
    [
      _T({
        'uz': 'Ko‘zga tashlanishi mumkin — reaktiv jarayon foydasiga.',
        'ru': 'Могут быть заметны — в пользу реактивного процесса.',
        'en': 'May be conspicuous — favours a reactive process.',
      }),
      _T({
        'uz': 'Odatda ko‘rinmaydi yoki yo‘q.',
        'ru': 'Обычно незаметны или отсутствуют.',
        'en': 'Usually inconspicuous or absent.',
      }),
      null,
    ],
    [
      CalcRef(CytoSources.kamal2022, 'Inflammatory changes in squamous cells'),
      CalcRef(CytoSources.kattoor2022, 'ASC-US; Summary'),
    ],
  ),
  CytoCompareRow(
    _T({
      'uz': 'Perinuklear oqarish (halo)',
      'ru': 'Перинуклеарное просветление (гало)',
      'en': 'Perinuclear halo',
    }),
    [
      _T({
        'uz':
            'Kichik "yallig‘lanish" halosi — koylotsit halosidan farqli. '
            'Psevdokoylotsitoz: trixomonada, kandida, glikogen, degeneratsiya, '
            'artefakt.',
        'ru':
            'Небольшое «воспалительное» гало — отличается от койлоцитарного. '
            'Псевдокойлоцитоз: трихомонады, кандида, гликоген, дегенерация, '
            'артефакт.',
        'en':
            'Small "inflammatory" halos, unlike koilocyte halos. '
            'Pseudokoilocytosis: Trichomonas, Candida, glycogen, degeneration, '
            'artefact.',
      }),
      _T({
        'uz':
            'Koylotsitga o‘xshash halo, lekin yadro o‘zgarishi minimal '
            '(to‘liq bo‘lmagan koylotsitoz).',
        'ru':
            'Гало, похожее на койлоцитарное, но с минимальными изменениями '
            'ядра (неполный койлоцитоз).',
        'en':
            'Koilocyte-like halos with minimal nuclear change (incomplete '
            'koilocytosis).',
      }),
      _T({
        'uz': 'Klassik koylotsit: aniq halo + o‘zgargan yadro.',
        'ru': 'Классический койлоцит: чёткое гало + изменённое ядро.',
        'en': 'Classic koilocyte: distinct halo + abnormal nucleus.',
      }),
    ],
    [
      CalcRef(CytoSources.kamal2022, 'Inflammatory changes in squamous cells'),
      CalcRef(CytoSources.iarcRepair, 'cyto8010'),
      CalcRef(
        CytoSources.kattoor2022,
        'ASC-US; Differential diagnosis of ASC-US',
      ),
      CalcRef(CytoSources.iarcKoilocyte, ''),
    ],
  ),
  CytoCompareRow(
    _T({'uz': 'Ikki yadrolilik', 'ru': 'Двуядерность', 'en': 'Binucleation'}),
    [
      _T({
        'uz': 'Uchrashi mumkin.',
        'ru': 'Может встречаться.',
        'en': 'May occur.',
      }),
      _T({
        'uz': 'HPV ta’sirini taxmin qildiradi, lekin LSIL uchun yetarli emas.',
        'ru': 'Наводит на мысль о ВПЧ, но недостаточно для LSIL.',
        'en': 'May suggest HPV change but falls short of LSIL.',
      }),
      _T({
        'uz': 'Ba’zan ikki yoki ko‘p yadroli.',
        'ru': 'Иногда дву- или многоядерные.',
        'en': 'Sometimes bi- or multinucleated.',
      }),
    ],
    [
      CalcRef(
        CytoSources.kattoor2022,
        'Summary: morphologic criteria of ASC-US',
      ),
      CalcRef(CytoSources.slhAbnormal, 'LSIL'),
    ],
  ),
  CytoCompareRow(
    _T({
      'uz': 'Sitoplazma va fon',
      'ru': 'Цитоплазма и фон',
      'en': 'Cytoplasm and background',
    }),
    [
      _T({
        'uz':
            'Sitoplazma chetlari titilgan, vakuolali, polixromaziya; fon '
            '"iflos" (donador va fibrinli qoldiq).',
        'ru':
            'Края цитоплазмы разволокнены, вакуолизация, полихромазия; фон '
            '«грязный» (зернистый и фибринозный детрит).',
        'en':
            'Frayed, vacuolated cytoplasm, polychromasia; "dirty" background '
            '(granular and fibrinous debris).',
      }),
      _T({
        'uz': 'Yadro/sitoplazma nisbati biroz oshgan.',
        'ru': 'Ядерно-цитоплазматическое отношение слегка повышено.',
        'en': 'Slightly increased nuclear-to-cytoplasmic ratio.',
      }),
      null,
    ],
    [
      CalcRef(CytoSources.kamal2022, 'Inflammatory changes in squamous cells'),
      CalcRef(
        CytoSources.kattoor2022,
        'Summary: morphologic criteria of ASC-US',
      ),
    ],
  ),
];

/// Reaktiv o'zgarish turlari (Bethesda: NILM ichida).
const cytoReactiveTypes = <CytoFact>[
  CytoFact(
    _T({
      'uz': 'Yallig‘lanish va regeneratsiya (repair)',
      'ru': 'Воспаление и репарация',
      'en': 'Inflammation and repair',
    }),
    _T({
      'uz':
          'Repair: yassi yoki silindrsimon/yetilmagan metaplastik hujayralarning '
          'tekis qatlami; yadrolar kattalashgan, lekin "sokin", xromatin mayda '
          'donador, bitta kichik yadrocha; qatlam ichida yallig‘lanish '
          'hujayralari bor. Kuchli repair o‘smaga o‘xshab qolishi mumkin; '
          '"atipik repair" ASC-US deb baholanishi mumkin.',
      'ru':
          'Репарация: плоский пласт метапластических (незрелых) или '
          'цилиндрических клеток; ядра увеличены, но «спокойные», хроматин '
          'мелкозернистый, одно небольшое ядрышко; внутри пласта — клетки '
          'воспаления. Выраженная репарация может имитировать опухоль; '
          '«атипичная репарация» может расцениваться как ASC-US.',
      'en':
          'Repair: flat sheets of immature metaplastic or columnar cells with '
          'bland nuclear enlargement, finely granular chromatin and a small '
          'single nucleolus; inflammatory cells within the sheet. Marked '
          'repair can mimic neoplasia; "atypical repair" may be reported as '
          'ASC-US.',
    }),
    [
      CalcRef(CytoSources.kamal2022, 'Fig. 27'),
      CalcRef(CytoSources.euroReactive, 'Regenerative (repair) changes'),
      CalcRef(CytoSources.kattoor2022, 'ASC-US in metaplastic squamous cells'),
    ],
  ),
  CytoFact(
    _T({
      'uz': 'Nur (radiatsiya) ta’siri',
      'ru': 'Лучевые изменения',
      'en': 'Radiation effect',
    }),
    _T({
      'uz':
          'Erta (dastlabki 6 oy): hujayra va yadro kattalashadi, lekin '
          'yadro/sitoplazma nisbati saqlanadi; sitoplazma vakuolali; ko‘p '
          'yadroli va g‘alati shaklli hujayralar. Kech: atrofik manzara, '
          'g‘alati shakllar va polixromaziya. Ayrim o‘zgarishlar uzoq '
          'saqlanadi; tirik o‘sma hujayralaridan farqlash muhim.',
      'ru':
          'Ранние (первые 6 месяцев): увеличение клетки и ядра при сохранённом '
          'ядерно-цитоплазматическом отношении; вакуолизация цитоплазмы; '
          'многоядерные и причудливые клетки. Поздние: атрофическая картина, '
          'причудливые формы и полихромазия. Часть изменений сохраняется '
          'долго; важно отличать от жизнеспособных опухолевых клеток.',
      'en':
          'Acute (first 6 months): cell and nuclear enlargement with a '
          'preserved N:C ratio, cytoplasmic vacuolation, multinucleated and '
          'bizarre cells. Chronic: atrophic pattern, bizarre shapes and '
          'polychromasia. Some changes persist; distinguishing them from '
          'viable tumour cells matters.',
    }),
    [
      CalcRef(CytoSources.poflee2022, 'Acute and chronic radiation changes'),
      CalcRef(CytoSources.pangarkar2022, 'Radiation-induced changes'),
    ],
  ),
  CytoFact(
    _T({
      'uz': 'Bachadon ichi vositasi (BIV)',
      'ru': 'Внутриматочная спираль (ВМС)',
      'en': 'Intrauterine device (IUD)',
    }),
    _T({
      'uz':
          'Endometriy hujayralari siklning istalgan kunida tushadi; yakka, '
          'yadro/sitoplazma nisbati yuqori "BIV hujayralari" HSILga o‘xshashi '
          'mumkin; vakuolali bezli hujayralar adenokarsinomaga o‘xshashi '
          'mumkin; ba’zan Actinomyces.',
      'ru':
          'Клетки эндометрия слущиваются в любой день цикла; одиночные '
          '«клетки ВМС» с высоким ядерно-цитоплазматическим отношением могут '
          'напоминать HSIL; вакуолизированные железистые клетки могут '
          'напоминать аденокарциному; иногда Actinomyces.',
      'en':
          'Endometrial cells shed at any phase of the cycle; single "IUD cells" '
          'with a high N:C ratio may resemble HSIL; vacuolated glandular cells '
          'may resemble adenocarcinoma; Actinomyces may be present.',
    }),
    [
      CalcRef(CytoSources.kamal2022, 'IUCD-associated cellular changes'),
      CalcRef(CytoSources.pangarkar2022, 'RCC associated with IUD'),
    ],
  ),
  CytoFact(
    _T({'uz': 'Shubha bo‘lsa', 'ru': 'При сомнении', 'en': 'When in doubt'}),
    _T({
      'uz':
          'Reaktivmi yoki ASC-USmi — bemor yoshi, oldingi surtmalar va HPV '
          'testi natijalari ko‘rib chiqiladi. Yallig‘lanish va displaziya '
          'farqi ko‘pincha daraja farqidir; yakuniy xulosani sitolog beradi.',
      'ru':
          'Реактивные изменения или ASC-US — учитывают возраст, предыдущие '
          'мазки и результаты теста на ВПЧ. Различие воспаления и дисплазии '
          'часто лишь в степени; окончательное заключение даёт цитолог.',
      'en':
          'Reactive or ASC-US — review age, previous smears and HPV results. '
          'Inflammation and dysplasia often differ only in degree; the '
          'cytologist makes the final call.',
    }),
    [
      CalcRef(CytoSources.kattoor2022, 'ASC-US'),
      CalcRef(CytoSources.kamal2022, 'Inflammatory changes in squamous cells'),
    ],
  ),
];

const cytoReactiveRefs = [
  CalcRef(CytoSources.kamal2022, ''),
  CalcRef(CytoSources.kattoor2022, ''),
  CalcRef(CytoSources.slhAbnormal, ''),
  CalcRef(CytoSources.poflee2022, ''),
  CalcRef(CytoSources.pangarkar2022, ''),
  CalcRef(CytoSources.euroReactive, ''),
  CalcRef(CytoSources.iarcRepair, ''),
];

// ───────────────────────── Yetilish indeksi ─────────────────────────

const cytoMaturation = <CytoFact>[
  CytoFact(
    _T({'uz': 'Nima u', 'ru': 'Что это', 'en': 'What it is'}),
    _T({
      'uz':
          'Parabazal : oraliq : yuzaki yassi hujayralarning foiz nisbati. Faqat '
          'yakka hujayralar sanaladi, to‘dadagilar sanalmaydi.',
      'ru':
          'Процентное соотношение парабазальных : промежуточных : '
          'поверхностных плоских клеток. Считают только одиночные клетки, '
          'клетки в группах не считают.',
      'en':
          'The percentage ratio of parabasal : intermediate : superficial '
          'squamous cells. Only single cells are counted, not cells in '
          'clusters.',
    }),
    [CalcRef(CytoSources.kamalTopiwala2022, 'Hormonal cytology: MI')],
  ),
  CytoFact(
    _T({
      'uz': 'Siljishlar nimani ko‘rsatadi',
      'ru': 'Что означают сдвиги',
      'en': 'What the shifts mean',
    }),
    _T({
      'uz':
          'Yuzaki hujayralar ustun — estrogen ta’siri (ovulyatsiya atrofida).\n'
          'Oraliq hujayralar ustun — progesteron ta’siri (lyutein faza, '
          'homiladorlik); erta menopauzada ham.\n'
          'Parabazal hujayralar ustun ("chapga siljish") — yupqa, atrofik '
          'epiteliy: atrofiya, tug‘ruqdan keyingi davr; faqat progestinli '
          'kontratseptivlarda ham chapga siljish bo‘ladi.',
      'ru':
          'Преобладают поверхностные клетки — эстрогенное влияние (около '
          'овуляции).\n'
          'Преобладают промежуточные — влияние прогестерона (лютеиновая фаза, '
          'беременность); также в ранней менопаузе.\n'
          'Преобладают парабазальные («сдвиг влево») — тонкий атрофичный '
          'эпителий: атрофия, послеродовый период; сдвиг влево бывает и при '
          'чисто прогестиновой контрацепции.',
      'en':
          'Superficial cells predominate — oestrogen effect (around '
          'ovulation).\n'
          'Intermediate cells predominate — progesterone effect (luteal phase, '
          'pregnancy); also in early menopause.\n'
          'Parabasal cells predominate ("shift to the left") — thin, atrophic '
          'epithelium: atrophy, postpartum; progestin-only contraceptives also '
          'shift it to the left.',
    }),
    [CalcRef(CytoSources.kamalTopiwala2022, 'Hormonal cytology; Menopause')],
  ),
  CytoFact(
    _T({'uz': 'Shartlar', 'ru': 'Условия', 'en': 'Prerequisites'}),
    _T({
      'uz':
          'Yallig‘lanish va sitoliz bo‘lmasligi; yaqinda mahalliy yoki umumiy '
          'dori qabul qilinmagan; nur terapiyasi yoki yaqinda qin/bo‘yinchada '
          'operatsiya bo‘lmagan. Gormonal holatni qinning yon devoridan olingan '
          'surtma aniqroq aks ettiradi; bo‘yincha surtmasi kamroq aniq.',
      'ru':
          'Нет воспаления и цитолиза; нет недавнего местного или системного '
          'лечения; не было лучевой терапии или недавней операции на '
          'влагалище/шейке. Гормональный статус точнее отражает мазок с '
          'боковой стенки влагалища; шеечный мазок менее точен.',
      'en':
          'No inflammation or cytolysis; no recent topical or systemic '
          'medication; no radiotherapy or recent vaginal/cervical surgery. A '
          'smear from the lateral vaginal wall reflects hormonal status best; '
          'cervical smears are less accurate.',
    }),
    [
      CalcRef(
        CytoSources.kamalTopiwala2022,
        'Hormonal cytology: prerequisites',
      ),
    ],
  ),
];

const cytoMaturationRefs = [CalcRef(CytoSources.kamalTopiwala2022, '')];

/// Yetilish indeksi: parabazal, oraliq, yuzaki hujayralar foizi (sof
/// arifmetika). Sonlar manfiy yoki jami 0 bo'lsa — `null`.
({double parabasal, double intermediate, double superficial})?
cytoMaturationIndex(int parabasal, int intermediate, int superficial) {
  if (parabasal < 0 || intermediate < 0 || superficial < 0) return null;
  final total = parabasal + intermediate + superficial;
  if (total == 0) return null;
  return (
    parabasal: parabasal * 100 / total,
    intermediate: intermediate * 100 / total,
    superficial: superficial * 100 / total,
  );
}

// ───────────────────────── Boshqa namunalar ─────────────────────────

/// Xalqaro hisobot tizimi: nomi, qisqa izoh, kategoriyalar.
class CytoSystem {
  const CytoSystem({
    required this.title,
    required this.system,
    required this.categories,
    required this.refs,
    this.note,
  });
  final LocalizedText title;

  /// Tizim nomi va qisqa izoh.
  final LocalizedText system;

  /// Toifalar, tartib bilan (asl inglizcha nom qavsda).
  final List<LocalizedText> categories;
  final LocalizedText? note;
  final List<CalcRef> refs;
}

const cytoOtherSystems = <CytoSystem>[
  CytoSystem(
    title: _T({
      'uz': 'Siydik sitologiyasi',
      'ru': 'Цитология мочи',
      'en': 'Urine cytology',
    }),
    system: _T({
      'uz':
          'Parij tizimi (The Paris System, 2-nashr). Asosiy maqsad — yuqori '
          'darajali urotelial karsinomani (HGUC) aniqlash.',
      'ru':
          'Парижская система (The Paris System, 2-е издание). Главная цель — '
          'выявление уротелиальной карциномы высокой степени (HGUC).',
      'en':
          'The Paris System (2nd edition). Its main aim is detecting '
          'high-grade urothelial carcinoma (HGUC).',
    }),
    categories: [
      _T({
        'uz': 'Yaroqsiz (Unsatisfactory)',
        'ru': 'Непригодный (Unsatisfactory)',
        'en': 'Unsatisfactory',
      }),
      _T({
        'uz': 'HGUC uchun manfiy (NHGUC)',
        'ru': 'Отрицательный в отношении HGUC (NHGUC)',
        'en': 'Negative for high-grade urothelial carcinoma (NHGUC)',
      }),
      _T({
        'uz': 'Atipik urotelial hujayralar (AUC)',
        'ru': 'Атипичные уротелиальные клетки (AUC)',
        'en': 'Atypical urothelial cells (AUC)',
      }),
      _T({
        'uz': 'HGUC ga shubhali (SHGUC)',
        'ru': 'Подозрение на HGUC (SHGUC)',
        'en': 'Suspicious for high-grade urothelial carcinoma (SHGUC)',
      }),
      _T({
        'uz': 'HGUC uchun musbat (HGUC)',
        'ru': 'Положительный в отношении HGUC (HGUC)',
        'en': 'Positive for high-grade urothelial carcinoma (HGUC)',
      }),
      _T({
        'uz':
            'Urotelial bo‘lmagan xavfli o‘smalar (Non-urothelial; ilgari '
            '"boshqa xavfli o‘smalar")',
        'ru':
            'Неуротелиальные злокачественные опухоли (Non-urothelial; ранее '
            '«другие злокачественные опухоли»)',
        'en': 'Non-urothelial malignancies (previously "other malignancies")',
      }),
    ],
    note: _T({
      'uz':
          '2-nashrda past darajali urotelial neoplaziya (LGUN) alohida kategoriya '
          'emas — NHGUC ichiga kiritilgan.',
      'ru':
          'Во 2-м издании уротелиальная неоплазия низкой степени (LGUN) не '
          'отдельная категория — включена в NHGUC.',
      'en':
          'In the 2nd edition low-grade urothelial neoplasm (LGUN) is no '
          'longer a separate category — it is included in NHGUC.',
    }),
    refs: [CalcRef(CytoSources.wojcik2026, 'Tables 2–3; text on TPS 2.0')],
  ),
  CytoSystem(
    title: _T({
      'uz': 'Seroz suyuqliklar (plevra, qorin, perikard)',
      'ru': 'Серозные жидкости (плевра, брюшина, перикард)',
      'en': 'Serous fluids (pleural, peritoneal, pericardial)',
    }),
    system: _T({
      'uz':
          'Seroz suyuqlik sitopatologiyasi bo‘yicha xalqaro tizim (IAC va ASC, '
          '2020): 5 kategoriya.',
      'ru':
          'Международная система для серозных жидкостей (IAC и ASC, 2020): '
          '5 категорий.',
      'en':
          'The International System for Reporting Serous Fluid Cytopathology '
          '(IAC and ASC, 2020): 5 categories.',
    }),
    categories: [
      _T({
        'uz': 'Diagnostik emas (ND)',
        'ru': 'Недиагностический (ND)',
        'en': 'Nondiagnostic (ND)',
      }),
      _T({
        'uz': 'Xavfli o‘sma uchun manfiy (NFM)',
        'ru': 'Отрицательный в отношении злокачественности (NFM)',
        'en': 'Negative for malignancy (NFM)',
      }),
      _T({
        'uz': 'Noaniq ahamiyatli atipiya (AUS)',
        'ru': 'Атипия неясного значения (AUS)',
        'en': 'Atypia of undetermined significance (AUS)',
      }),
      _T({
        'uz': 'Xavfli o‘smaga shubhali (SFM)',
        'ru': 'Подозрение на злокачественность (SFM)',
        'en': 'Suspicious for malignancy (SFM)',
      }),
      _T({
        'uz': 'Xavfli o‘sma (MAL)',
        'ru': 'Злокачественный (MAL)',
        'en': 'Malignant (MAL)',
      }),
    ],
    refs: [CalcRef(CytoSources.wang2023Serous, 'Abstract; Table 1')],
  ),
  CytoSystem(
    title: _T({
      'uz': 'Balg‘am va o‘pka sitologiyasi',
      'ru': 'Мокрота и цитология лёгкого',
      'en': 'Sputum and lung cytology',
    }),
    system: _T({
      'uz':
          'JSST o‘pka sitopatologiyasi hisobot tizimi (IAC va IARC): 5 kategoriya, '
          'barcha o‘pka namunalari uchun.',
      'ru':
          'Система ВОЗ для цитопатологии лёгкого (IAC и IARC): 5 категорий для '
          'всех видов лёгочных образцов.',
      'en':
          'The WHO Reporting System for Lung Cytopathology (IAC and IARC): 5 '
          'categories for all lung specimen types.',
    }),
    categories: [
      _T({
        'uz': 'Yetarli emas / diagnostik emas (Insufficient/Inadequate/Non-diagnostic)',
        'ru': 'Недостаточный / недиагностический (Insufficient/Inadequate/Non-diagnostic)',
        'en': 'Insufficient/Inadequate/Non-diagnostic',
      }),
      _T({
        'uz': 'Xavfsiz (Benign)',
        'ru': 'Доброкачественный (Benign)',
        'en': 'Benign',
      }),
      _T({
        'uz': 'Atipik (Atypical)',
        'ru': 'Атипичный (Atypical)',
        'en': 'Atypical',
      }),
      _T({
        'uz': 'Xavfli o‘smaga shubhali (Suspicious for malignancy)',
        'ru': 'Подозрение на злокачественность (Suspicious for malignancy)',
        'en': 'Suspicious for malignancy',
      }),
      _T({
        'uz': 'Xavfli o‘sma (Malignant)',
        'ru': 'Злокачественный (Malignant)',
        'en': 'Malignant',
      }),
    ],
    note: _T({
      'uz':
          'Balg‘am yetarli bo‘lishi uchun: kamida bir nechta alveolyar makrofag '
          'va kiprikli silindrsimon bronx hujayralari, kamida 2 ta surtmaga '
          'yetadigan hajm.',
      'ru':
          'Адекватная мокрота: хотя бы несколько альвеолярных макрофагов и '
          'реснитчатых цилиндрических клеток бронхов, объём не менее чем на 2 '
          'мазка.',
      'en':
          'Adequate sputum: at least a few alveolar macrophages and ciliated '
          'columnar bronchial cells, and enough volume for at least two smears.',
    }),
    refs: [
      CalcRef(CytoSources.dolezal2024, 'Introduction; Insufficient category'),
    ],
  ),
];
