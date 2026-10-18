/// Sitologiya (ginekologik surtma): hujayralarni tanish, qin surtmasining
/// tozalik darajasi, Bethesda tasnifi, surtma olish va bo'yash (3 tilda).
///
/// Faktlar ochiq manbalardan o'z so'zlarimiz bilan ([CytoSources]); manbada
/// yo'q raqam yozilmaydi. Rasmlar — LabGuide chizgan sxema (mikrofoto emas).
/// Kontent mutaxassis tekshiruvidan o'tmagan — ekranda "draft".
library;

import '../content/content_model.dart';
import '../differential/differential_sources.dart';
import '../tools/calc_info.dart';

typedef _T = LocalizedText;

abstract final class CytoSources {
  static const bethesda = CalcSource(
    id: 'cyto-bethesda-2015',
    citation:
        'Nayar R, Wilbur DC, eds. The Bethesda System for Reporting Cervical '
        'Cytology: Definitions, Criteria, and Explanatory Notes. 3rd ed. '
        'Springer; 2015. doi:10.1007/978-3-319-11074-5',
    url: 'https://doi.org/10.1007/978-3-319-11074-5',
  );
  static const nciAbnormal = CalcSource(
    id: 'cyto-nci-abnormal-hpv-pap',
    citation:
        'National Cancer Institute. HPV and Pap Test Results: Next Steps '
        'after an Abnormal Cervical Cancer Screening Test',
    url: 'https://www.cancer.gov/types/cervical/screening/abnormal-hpv-pap-test-results',
  );
  static const nciPdq = CalcSource(
    id: 'cyto-nci-pdq-screening',
    citation:
        'National Cancer Institute. Cervical Cancer Screening (PDQ®) — '
        'Health Professional Version',
    url: 'https://www.cancer.gov/types/cervical/hp/cervical-screening-pdq',
  );
  static const medlinePap = CalcSource(
    id: 'cyto-medline-pap',
    citation: 'MedlinePlus [Internet]. Pap Smear. National Library of Medicine',
    url: 'https://medlineplus.gov/lab-tests/pap-smear/',
  );
  static const cdcBv = CalcSource(
    id: 'cyto-cdc-bv',
    citation: 'CDC. STI Treatment Guidelines, 2021 — Bacterial Vaginosis',
    url: 'https://www.cdc.gov/std/treatment-guidelines/bv.htm',
  );
  static const cdcTrich = CalcSource(
    id: 'cyto-cdc-trichomoniasis',
    citation: 'CDC. STI Treatment Guidelines, 2021 — Trichomoniasis',
    url: 'https://www.cdc.gov/std/treatment-guidelines/trichomoniasis.htm',
  );
  static const cdcCandida = CalcSource(
    id: 'cyto-cdc-candidiasis',
    citation: 'CDC. STI Treatment Guidelines, 2021 — Vulvovaginal Candidiasis',
    url: 'https://www.cdc.gov/std/treatment-guidelines/candidiasis.htm',
  );
  static const cdcGono = CalcSource(
    id: 'cyto-cdc-gonorrhea',
    citation:
        'CDC. STI Treatment Guidelines, 2021 — Gonococcal Infections Among '
        'Adolescents and Adults',
    url: 'https://www.cdc.gov/std/treatment-guidelines/gonorrhea-adults.htm',
  );
  static const amsel = CalcSource(
    id: 'cyto-amsel-1983',
    citation:
        'Amsel R, Totten PA, Spiegel CA, et al. Nonspecific vaginitis. '
        'Diagnostic criteria and microbial and epidemiologic associations. '
        'Am J Med. 1983. doi:10.1016/0002-9343(83)91112-9',
    url: 'https://doi.org/10.1016/0002-9343(83)91112-9',
  );
  static const nugent = CalcSource(
    id: 'cyto-nugent-1991',
    citation:
        'Nugent RP, Krohn MA, Hillier SL. Reliability of diagnosing bacterial '
        'vaginosis is improved by a standardized method of Gram stain '
        'interpretation. J Clin Microbiol. 1991. '
        'doi:10.1128/jcm.29.2.297-301.1991',
    url: 'https://doi.org/10.1128/jcm.29.2.297-301.1991',
  );

  static const iarcNormal = CalcSource(
    id: 'cyto-iarc-atlas-normal',
    citation:
        'IARC. Atlas of Colposcopy and Cytology: cytology — normal squamous '
        'cells (D1). International Agency for Research on Cancer',
    url: 'https://screening.iarc.fr/atlascyto_list.php?cat=D1&lang=1',
  );
  static const iarcAtlas = CalcSource(
    id: 'cyto-iarc-atlas',
    citation:
        'IARC. Atlas of Colposcopy and Cytology — cytology atlas. '
        'International Agency for Research on Cancer',
    url: 'https://screening.iarc.fr/atlascyto.php',
  );
  static const iarcMetaplastic = CalcSource(
    id: 'cyto-iarc-atlas-metaplastic',
    citation:
        'IARC. Atlas of Colposcopy and Cytology: squamous metaplastic cells '
        '(D5a). International Agency for Research on Cancer',
    url: 'https://screening.iarc.fr/atlascyto_list.php?cat=D5a&lang=1',
  );
  static const iarcKoilocyte = CalcSource(
    id: 'cyto-iarc-koilocyte',
    citation:
        'IARC. Atlas of Colposcopy and Cytology — glossary: Koilocyte. '
        'International Agency for Research on Cancer',
    url: 'https://screening.iarc.fr/atlasglossdef.php?img=cyt14560&key=Koilocyte&lang=1',
  );
  static const iarcHsil = CalcSource(
    id: 'cyto-iarc-atlas-hsil',
    citation:
        'IARC. Atlas of Colposcopy and Cytology: high-grade squamous '
        'intraepithelial lesion (F1c2). International Agency for Research on '
        'Cancer',
    url: 'https://screening.iarc.fr/atlascyto_list.php?cat=F1c2&lang=1',
  );
  static const dpdxTrich = CalcSource(
    id: 'cyto-cdc-dpdx-trichomoniasis',
    citation:
        'CDC DPDx — Laboratory Identification of Parasites: Trichomoniasis',
    url: 'https://www.cdc.gov/dpdx/trichomoniasis/',
  );

  // ── Qo'shimcha sahifalar manbalari (ochiq to'liq matn, 17-oktabr tekshirildi;
  // har da'vo joyi docs/CYTOLOGY_SOURCES.md da).
  static const pangarkar2022 = CalcSource(
    id: 'cyto-pangarkar-2022',
    citation:
        'Pangarkar MA. The Bethesda System for reporting cervical cytology. '
        'CytoJournal. 2022. doi:10.25259/CMAS_03_07_2021',
    url: 'https://doi.org/10.25259/CMAS_03_07_2021',
  );
  static const wang2023 = CalcSource(
    id: 'cyto-wang-2023-jctp',
    citation:
        'Wang T, Zhang H, Liu Y, Zhao C. Updates in Cervical Cancer Screening '
        'Guidelines, The Bethesda System for Reporting Cervical Cytology, and '
        'Clinical Management Recommendations. J Clin Transl Pathol. 2023. '
        'doi:10.14218/jctp.2023.00004',
    url: 'https://doi.org/10.14218/jctp.2023.00004',
  );
  static const asccp2019 = CalcSource(
    id: 'cyto-asccp-2019',
    citation:
        'Perkins RB, Guido RS, Castle PE, et al. 2019 ASCCP Risk-Based '
        'Management Consensus Guidelines for Abnormal Cervical Cancer '
        'Screening Tests and Cancer Precursors. J Low Genit Tract Dis. 2020. '
        'doi:10.1097/LGT.0000000000000525',
    url: 'https://doi.org/10.1097/LGT.0000000000000525',
  );
  static const capToday2026 = CalcSource(
    id: 'cyto-captoday-unsat-2026',
    citation:
        'O’Conor C, Hegde P, Reynolds J. Cytopathology in focus: '
        'Unsatisfactory Paps — recommendations, remedies. CAP Today. 2026',
    url: 'https://www.captodayonline.com/?p=103445',
  );
  static const iarcUnsat = CalcSource(
    id: 'cyto-iarc-atlas-unsatisfactory',
    citation:
        'IARC. Atlas of Colposcopy and Cytology: unsatisfactory specimen (A1). '
        'International Agency for Research on Cancer',
    url: 'https://screening.iarc.fr/atlascyto_list.php?cat=A1&lang=1',
  );
  static const iarcRepair = CalcSource(
    id: 'cyto-iarc-atlas-repair',
    citation:
        'IARC. Atlas of Colposcopy and Cytology: inflammation and repair '
        '(E1a). International Agency for Research on Cancer',
    url: 'https://screening.iarc.fr/atlascyto_list.php?cat=E1a&lang=1',
  );
  static const kattoor2022 = CalcSource(
    id: 'cyto-kattoor-kamal-2022',
    citation:
        'Kattoor J, Kamal MM. The gray zone squamous lesions: ASC-US / ASC-H. '
        'CytoJournal. 2022. doi:10.25259/CMAS_03_10_2021',
    url: 'https://doi.org/10.25259/CMAS_03_10_2021',
  );
  static const kamal2022 = CalcSource(
    id: 'cyto-kamal-2022-inflammation',
    citation:
        'Kamal MM. The Pap smear in inflammation and repair. CytoJournal. '
        '2022. doi:10.25259/CMAS_03_08_2021',
    url: 'https://doi.org/10.25259/CMAS_03_08_2021',
  );
  static const poflee2022 = CalcSource(
    id: 'cyto-poflee-bhatia-2022',
    citation:
        'Poflee SV, Bhatia JK. Cervical cytology: Radiation and other therapy '
        'effects. CytoJournal. 2022. doi:10.25259/CMAS_03_12_2021',
    url: 'https://doi.org/10.25259/CMAS_03_12_2021',
  );
  static const kamalTopiwala2022 = CalcSource(
    id: 'cyto-kamal-topiwala-2022',
    citation:
        'Kamal M, Topiwala F. Nonneoplastic cervical cytology. CytoJournal. '
        '2022. doi:10.25259/CMAS_03_06_2021',
    url: 'https://doi.org/10.25259/CMAS_03_06_2021',
  );
  static const slhAbnormal = CalcSource(
    id: 'cyto-wslh-abnormal',
    citation:
        'Wisconsin State Laboratory of Hygiene. Gynecologic Cytology 101: '
        'Abnormal (precancerous) lesions of the female reproductive system',
    url: 'https://www.slh.wisc.edu/clinical/cytology/resources-for-health-care-professionals/gynecologic-cytology-101/abnormal-precancerous-lesions-of-the-female-reproductive-system',
  );
  static const euroReactive = CalcSource(
    id: 'cyto-eurocytology-reactive',
    citation:
        'Eurocytology. Cervical cytology, 9b: Reactive cytological changes',
    url: 'https://www.eurocytology.eu/course/cervical-cytology-2/9b-normal-cytology-and-benign-reactive-changes/reactive-cytological-changes/',
  );
  static const wang2023Serous = CalcSource(
    id: 'cyto-wang-chandra-cai-2023-serous',
    citation:
        'Wang M, Chandra A, Cai G. The International System for Reporting '
        'Serous Fluid Cytopathology — An Updated Review. J Clin Transl '
        'Pathol. 2023. doi:10.14218/jctp.2023.00025',
    url: 'https://doi.org/10.14218/jctp.2023.00025',
  );
  static const wojcik2026 = CalcSource(
    id: 'cyto-wojcik-2026-paris',
    citation:
        'Wojcik EM. The Paris system for reporting urinary cytology: what '
        'worked and what still needs to be improved. Histopathology. 2026. '
        'doi:10.1111/his.70038',
    url: 'https://doi.org/10.1111/his.70038',
  );
  static const dolezal2024 = CalcSource(
    id: 'cyto-dolezal-2024-who-lung',
    citation:
        'Dolezal D, Kholová I, Cai G. The World Health Organization Reporting '
        'System for Lung Cytopathology — A Review of the First Edition. '
        'J Clin Transl Pathol. 2024. doi:10.14218/jctp.2023.00068',
    url: 'https://doi.org/10.14218/jctp.2023.00068',
  );
  static const grigoruk2024 = CalcSource(
    id: 'cyto-grigoruk-2024',
    citation:
        'Григорук ОГ, Москвина ТА, Базулина ЛМ, Вихлянов ИВ. '
        'Цитологическая диагностика железистых поражений цервикального '
        'канала. Опухоли женской репродуктивной системы. 2024. '
        'doi:10.17650/1994-4098-2024-20-4-101-110',
    url: 'https://doi.org/10.17650/1994-4098-2024-20-4-101-110',
  );

  /// RF klinik tavsiyasi (Minzdrav, 2024, ID 597) — Bethesda atamalarining
  /// ruscha nomlari "Список сокращений" da.
  static const krCin2024 = CalcSource(
    id: 'cyto-kr-597-2024',
    citation:
        'Российское общество акушеров-гинекологов; Российское общество '
        'специалистов по профилактике и лечению опухолей репродуктивной '
        'системы. Клинические рекомендации «Цервикальная интраэпителиальная '
        'неоплазия, эрозия и эктропион шейки матки» (одобрены Научно-'
        'практическим советом Минздрава России), 2024, ID 597',
    url: 'https://base.garant.ru/410436907/',
  );

  /// ROAG 2019 — Heurlein (1910) darajalari "faqat tarixiy ahamiyatga ega".
  static const roag2019 = CalcSource(
    id: 'cyto-roag-2019-discharge',
    citation:
        'Российское общество акушеров-гинекологов (Прилепская В.Н., Кира Е.Ф. '
        'и др.). Клинические рекомендации по диагностике и лечению '
        'заболеваний, сопровождающихся патологическими выделениями из половых '
        'путей женщин. 2-е изд. Москва; 2019. ISBN 978-5-89084-052-3',
    url: 'https://library.mededtech.ru/rest/documents/Rek/',
  );

  /// Hay–Ison shkalasi (0–IV) — asl maqola.
  static const isonHay2002 = CalcSource(
    id: 'cyto-ison-hay-2002',
    citation:
        'Ison CA, Hay PE. Validation of a simplified grading of Gram stained '
        'vaginal smears for use in genitourinary medicine clinics. Sex '
        'Transm Infect. 2002;78(6):413–415. doi:10.1136/sti.78.6.413',
    url: 'https://doi.org/10.1136/sti.78.6.413',
  );

  /// O'zbek darsligi (bosma; havolasiz).
  static const kurbonova2023 = CalcSource(
    id: 'book-kurbonova-2023',
    citation:
        'Kurbonova Z.Ch. Klinik laboratoriya tashxisi. Darslik. Toshkent: '
        'Toshkent tibbiyot akademiyasi; 2023',
    url: null,
  );

  static const all = [
    bethesda,
    nciAbnormal,
    nciPdq,
    medlinePap,
    cdcBv,
    cdcTrich,
    cdcCandida,
    cdcGono,
    amsel,
    nugent,
    iarcAtlas,
    dpdxTrich,
    DiffSources.who2003,
    pangarkar2022,
    wang2023,
    asccp2019,
  ];
}

/// Rasm: `assets/cytology/<id>.png`.
String cytoImage(String id) => 'assets/cytology/$id.png';

class CytoCell {
  const CytoCell({
    required this.id,
    required this.name,
    required this.look,
    required this.key,
    required this.meaning,
    required this.refs,
    this.confuse,
    this.refer = false,
  });

  final String id;
  final LocalizedText name;

  /// Qanday ko'rinadi (o'lcham, yadro, sitoplazma).
  final LocalizedText look;

  /// Eng tez farqlovchi belgi.
  final LocalizedText key;

  /// Nimani anglatadi.
  final LocalizedText meaning;

  /// Nima bilan adashtiriladi.
  final LocalizedText? confuse;

  /// Shifokorga/sitologga ko'rsatish kerak.
  final bool refer;

  final List<CalcRef> refs;
}

const cytoCells = <CytoCell>[
  CytoCell(
    id: 'superficial',
    name: _T({
      'uz': 'Yuzaki yassi epiteliy hujayrasi',
      'ru': 'Поверхностная клетка плоского эпителия',
      'en': 'Superficial squamous cell',
    }),
    look: _T({
      'uz':
          'Katta, ko‘pburchakli, yupqa hujayra. Sitoplazmasi pushti-to‘q sariq '
          '(eozinofil). Yadrosi juda kichik, to‘q, zich — piknotik.',
      'ru':
          'Крупная полигональная тонкая клетка. Цитоплазма розово-оранжевая '
          '(эозинофильная). Ядро очень маленькое, тёмное, плотное — пикнотичное.',
      'en':
          'Large, thin, polygonal cell. Pink-orange (eosinophilic) cytoplasm. '
          'Very small, dark, dense — pyknotic — nucleus.',
    }),
    key: _T({
      'uz': 'Kichik nuqtadek to‘q yadro + pushti sitoplazma.',
      'ru': 'Маленькое точечное тёмное ядро + розовая цитоплазма.',
      'en': 'Tiny dot-like dark nucleus + pink cytoplasm.',
    }),
    meaning: _T({
      'uz':
          'Epiteliyning eng yetilgan qavati. Normal surtmada bo‘ladi; ko‘pligi '
          'estrogen ta’sirini ko‘rsatadi.',
      'ru':
          'Самый зрелый слой эпителия. Есть в нормальном мазке; '
          'преобладание отражает эстрогенное влияние.',
      'en':
          'The most mature epithelial layer. Present in a normal smear; '
          'predominance reflects oestrogen effect.',
    }),
    confuse: _T({
      'uz': 'Oraliq hujayra — uning yadrosi kattaroq, pufaksimon, sitoplazmasi ko‘kish.',
      'ru': 'Промежуточная клетка — ядро крупнее, пузырьковидное, цитоплазма голубоватая.',
      'en': 'Intermediate cell — larger vesicular nucleus, bluish cytoplasm.',
    }),
    refs: [CalcRef(CytoSources.bethesda, 'Ch. 1')],
  ),
  CytoCell(
    id: 'intermediate',
    name: _T({
      'uz': 'Oraliq yassi epiteliy hujayrasi',
      'ru': 'Промежуточная клетка плоского эпителия',
      'en': 'Intermediate squamous cell',
    }),
    look: _T({
      'uz':
          'Katta, ko‘pburchakli, chetlari ko‘pincha bukilgan. Sitoplazmasi '
          'ko‘k-yashil (sianofil). Yadrosi o‘rtacha, pufaksimon, mayda xromatinli.',
      'ru':
          'Крупная полигональная, края часто загнуты. Цитоплазма '
          'сине-зелёная (цианофильная). Ядро среднее, пузырьковидное, с '
          'мелким хроматином.',
      'en':
          'Large polygonal cell, edges often folded. Blue-green (cyanophilic) '
          'cytoplasm. Medium vesicular nucleus with fine chromatin.',
    }),
    key: _T({
      'uz':
          'Uning yadrosi — "o‘lchov chizg‘ichi": boshqa yadrolar shu bilan '
          'solishtiriladi.',
      'ru': 'Его ядро — «линейка»: с ним сравнивают другие ядра.',
      'en': 'Its nucleus is the "ruler" other nuclei are compared with.',
    }),
    meaning: _T({
      'uz': 'Normal surtmaning asosiy hujayrasi.',
      'ru': 'Основная клетка нормального мазка.',
      'en': 'The main cell of a normal smear.',
    }),
    refs: [CalcRef(CytoSources.bethesda, 'Ch. 1')],
  ),
  CytoCell(
    id: 'parabasal',
    name: _T({
      'uz': 'Parabazal hujayra',
      'ru': 'Парабазальная клетка',
      'en': 'Parabasal cell',
    }),
    look: _T({
      'uz':
          'Kichikroq, dumaloq yoki oval. Sitoplazmasi zich, ko‘k-yashil. '
          'Yadro hujayraga nisbatan katta.',
      'ru':
          'Меньше, круглая или овальная. Цитоплазма плотная, сине-зелёная. '
          'Ядро относительно крупное.',
      'en':
          'Smaller, round or oval. Dense blue-green cytoplasm. Relatively '
          'large nucleus.',
    }),
    key: _T({
      'uz': 'Dumaloq shakl va qalin sitoplazma.',
      'ru': 'Округлая форма и плотная цитоплазма.',
      'en': 'Round shape and dense cytoplasm.',
    }),
    meaning: _T({
      'uz':
          'Epiteliyning chuqur qavati. Ko‘p bo‘lsa — estrogen kamligi '
          '(menopauza, tug‘ruqdan keyin) — atrofik surtma.',
      'ru':
          'Глубокий слой эпителия. Много — недостаток эстрогенов (менопауза, '
          'послеродовый период) — атрофический мазок.',
      'en':
          'Deep epithelial layer. Many of them suggest low oestrogen '
          '(menopause, postpartum) — an atrophic smear.',
    }),
    confuse: _T({
      'uz': 'Metaplastik hujayra, HSIL hujayrasi — yadro belgilariga qarang.',
      'ru': 'Метапластическая клетка, клетка HSIL — смотрите на ядро.',
      'en': 'Metaplastic cell, HSIL cell — look at the nucleus.',
    }),
    refs: [CalcRef(CytoSources.bethesda, 'Ch. 1')],
  ),
  CytoCell(
    id: 'endocervical',
    name: _T({
      'uz': 'Endotservikal (silindrsimon) hujayralar',
      'ru': 'Эндоцервикальные (цилиндрические) клетки',
      'en': 'Endocervical (columnar) cells',
    }),
    look: _T({
      'uz':
          'Tepadan qaraganda — "asalari uyasi" kabi to‘da. Yondan — baland '
          'hujayralar, yadrolari bir qatorda, pastda ("panjara").',
      'ru':
          'Сверху — пласт «пчелиные соты». Сбоку — высокие клетки, ядра в '
          'ряд у основания («частокол»).',
      'en':
          'En face — a "honeycomb" sheet. Side view — tall cells with basal '
          'nuclei in a row ("picket fence").',
    }),
    key: _T({
      'uz': 'Asalari uyasi yoki panjara tuzilishi.',
      'ru': 'Соты или частокол.',
      'en': 'Honeycomb or picket fence.',
    }),
    meaning: _T({
      'uz':
          'Bo‘yin kanalidan. Bo‘lishi transformatsiya zonasidan material '
          'olinganini ko‘rsatadi (namuna sifati).',
      'ru':
          'Из цервикального канала. Их наличие показывает, что материал взят '
          'из зоны трансформации (качество образца).',
      'en':
          'From the endocervical canal. Their presence shows the '
          'transformation zone was sampled (specimen adequacy).',
    }),
    refs: [CalcRef(CytoSources.bethesda, 'Ch. 1')],
  ),
  CytoCell(
    id: 'metaplastic',
    name: _T({
      'uz': 'Metaplastik yassi hujayra',
      'ru': 'Метапластическая плоская клетка',
      'en': 'Squamous metaplastic cell',
    }),
    look: _T({
      'uz':
          'O‘rtacha kattalikda, sitoplazmasi zich, ko‘k-yashil, ko‘pincha '
          'o‘simtalari bor ("o‘rgimchak"). Yadrosi oval, tekis.',
      'ru':
          'Средних размеров, цитоплазма плотная, сине-зелёная, часто с '
          'отростками («паучок»). Ядро овальное, ровное.',
      'en':
          'Medium size, dense blue-green cytoplasm, often with processes '
          '("spider" cell). Oval, smooth nucleus.',
    }),
    key: _T({
      'uz': 'Sitoplazma o‘simtalari.',
      'ru': 'Отростки цитоплазмы.',
      'en': 'Cytoplasmic processes.',
    }),
    meaning: _T({
      'uz': 'Transformatsiya zonasidan; normal holat.',
      'ru': 'Из зоны трансформации; норма.',
      'en': 'From the transformation zone; a normal finding.',
    }),
    refs: [CalcRef(CytoSources.bethesda, 'Ch. 1')],
  ),
  CytoCell(
    id: 'koilocyte',
    name: _T({'uz': 'Koylotsit', 'ru': 'Койлоцит', 'en': 'Koilocyte'}),
    look: _T({
      'uz':
          'Yadro atrofida aniq chegarali katta oq bo‘shliq (halo); chetida '
          'qalin sitoplazma halqasi. Yadro kattalashgan, to‘q, notekis '
          '("mayiz"), ko‘pincha ikkita.',
      'ru':
          'Вокруг ядра большая светлая зона с чёткой границей (гало); по краю '
          '— плотный ободок цитоплазмы. Ядро увеличено, тёмное, неровное '
          '(«изюм»), часто два ядра.',
      'en':
          'A large clear perinuclear cavity with a sharp edge (halo) and a '
          'dense cytoplasmic rim. Enlarged, dark, irregular ("raisinoid") '
          'nucleus, often binucleate.',
    }),
    key: _T({
      'uz': 'Halo + o‘zgargan yadro. Yadrosi oddiy bo‘lsa — koylotsit emas.',
      'ru': 'Гало + изменённое ядро. Если ядро обычное — это не койлоцит.',
      'en': 'Halo + abnormal nucleus. A plain nucleus means it is not one.',
    }),
    meaning: _T({
      'uz': 'HPV ta’siri belgisi; Bethesda bo‘yicha LSIL toifasiga kiradi.',
      'ru': 'Признак действия ВПЧ; по Bethesda относится к LSIL.',
      'en': 'A sign of HPV effect; reported as LSIL in Bethesda.',
    }),
    confuse: _T({
      'uz':
          'Glikogenli yoki yallig‘lanishdagi kichik perinuklear oqarish — '
          'unda chegara noaniq va yadro o‘zgarmagan.',
      'ru':
          'Небольшое просветление вокруг ядра (гликоген, воспаление) — '
          'граница нечёткая, ядро не изменено.',
      'en':
          'Small perinuclear clearing (glycogen, inflammation) — vague edge '
          'and a normal nucleus.',
    }),
    refer: true,
    refs: [
      CalcRef(CytoSources.bethesda, 'Ch. 5'),
      CalcRef(CytoSources.nciAbnormal, ''),
    ],
  ),
  CytoCell(
    id: 'clue_cell',
    name: _T({
      'uz': '"Kalit" hujayra (clue cell)',
      'ru': '«Ключевая» клетка (clue cell)',
      'en': 'Clue cell',
    }),
    look: _T({
      'uz':
          'Yassi epiteliy hujayrasi butunlay mayda kokkobatsillalar bilan '
          'qoplangan; chetlari "tukli", noaniq. Fonda laktobatsillalar kam.',
      'ru':
          'Клетка плоского эпителия сплошь покрыта мелкими коккобациллами; '
          'края «лохматые», нечёткие. Лактобацилл в фоне мало.',
      'en':
          'A squamous cell covered with small coccobacilli; shaggy, '
          'indistinct borders. Few lactobacilli in the background.',
    }),
    key: _T({
      'uz': 'Hujayra chegarasi bakteriyalar ostida ko‘rinmaydi.',
      'ru': 'Граница клетки скрыта под бактериями.',
      'en': 'The cell border is obscured by bacteria.',
    }),
    meaning: _T({
      'uz':
          'Bakterial vaginoz belgisi (Amsel mezonlaridan biri). Tashxisni '
          'shifokor mezonlar majmuasi bo‘yicha qo‘yadi.',
      'ru':
          'Признак бактериального вагиноза (один из критериев Амсела). '
          'Диагноз ставит врач по совокупности критериев.',
      'en':
          'A sign of bacterial vaginosis (one of Amsel’s criteria). The '
          'clinician diagnoses on the full set of criteria.',
    }),
    confuse: _T({
      'uz':
          'Ustida bir nechta bakteriya bo‘lgan oddiy hujayra — chetlari aniq '
          'qolgan bo‘lsa, "kalit" hujayra hisoblanmaydi.',
      'ru':
          'Обычная клетка с несколькими бактериями — если края чёткие, это не '
          '«ключевая» клетка.',
      'en':
          'An ordinary cell with a few bacteria — if the edges are still '
          'sharp, it is not a clue cell.',
    }),
    refs: [
      CalcRef(CytoSources.cdcBv, ''),
      CalcRef(CytoSources.amsel, ''),
      CalcRef(CytoSources.nugent, ''),
    ],
  ),
  CytoCell(
    id: 'lactobacilli',
    name: _T({
      'uz': 'Laktobatsillalar (Dederleyn tayoqchalari)',
      'ru': 'Лактобациллы (палочки Дёдерлейна)',
      'en': 'Lactobacilli (Döderlein bacilli)',
    }),
    look: _T({
      'uz': 'Uzun ingichka tayoqchalar, fonda va hujayralar ustida ko‘p.',
      'ru': 'Длинные тонкие палочки, много в фоне и на клетках.',
      'en': 'Long thin rods, abundant in the background and on cells.',
    }),
    key: _T({
      'uz': 'Uzun tayoqchalar ko‘p, kokklar kam.',
      'ru': 'Много длинных палочек, мало кокков.',
      'en': 'Many long rods, few cocci.',
    }),
    meaning: _T({
      'uz':
          'Normal qin mikroflorasi; muhitni kislotali saqlaydi. Ko‘p bo‘lsa '
          'oraliq hujayralar sitolizi (yemirilishi) kuzatilishi mumkin.',
      'ru':
          'Нормальная микрофлора влагалища; поддерживает кислую среду. При '
          'обилии возможен цитолиз промежуточных клеток.',
      'en':
          'Normal vaginal flora; keeps the environment acidic. When abundant, '
          'intermediate cells may be lysed (cytolysis).',
    }),
    refs: [CalcRef(CytoSources.nugent, ''), CalcRef(CytoSources.cdcBv, '')],
  ),
  CytoCell(
    id: 'trichomonas',
    name: _T({
      'uz': 'Trixomonada (Trichomonas vaginalis)',
      'ru': 'Трихомонада (Trichomonas vaginalis)',
      'en': 'Trichomonas vaginalis',
    }),
    look: _T({
      'uz':
          'Nok shaklidagi kulrang-yashil tana, yadrosi och, cho‘ziq, bir '
          'chetda; sitoplazmada qizil donachalar. Xivchinlar bo‘yalgan '
          'surtmada ko‘pincha ko‘rinmaydi.',
      'ru':
          'Грушевидное серо-зелёное тело, ядро бледное, вытянутое, '
          'эксцентричное; в цитоплазме красные гранулы. Жгутики в окрашенном '
          'мазке часто не видны.',
      'en':
          'Pear-shaped grey-green body with a pale, elongated, eccentric '
          'nucleus and red cytoplasmic granules. Flagella are often not seen '
          'in stained smears.',
    }),
    key: _T({
      'uz':
          'Nok shakli + ekssentrik och yadro. Nativ (ho‘l) preparatda — '
          'harakatlanadi.',
      'ru': 'Грушевидная форма + бледное эксцентричное ядро. В нативном препарате — движется.',
      'en': 'Pear shape + pale eccentric nucleus. Motile in a wet mount.',
    }),
    meaning: _T({
      'uz':
          'Trixomoniaz. Odatda ko‘p neytrofillar bilan birga. Tasdiq uchun '
          'sezgir test (NAAT) tavsiya etiladi.',
      'ru':
          'Трихомониаз. Обычно с большим количеством нейтрофилов. Для '
          'подтверждения рекомендуется чувствительный тест (МАНК).',
      'en':
          'Trichomoniasis, usually with many neutrophils. A sensitive test '
          '(NAAT) is recommended to confirm.',
    }),
    confuse: _T({
      'uz': 'Yemirilgan epiteliy bo‘laklari, degeneratsiyalangan leykotsitlar.',
      'ru': 'Обрывки эпителия, дегенерированные лейкоциты.',
      'en': 'Cell fragments, degenerated leukocytes.',
    }),
    refs: [
      CalcRef(CytoSources.cdcTrich, ''),
      CalcRef(CytoSources.bethesda, 'Ch. 2'),
    ],
  ),
  CytoCell(
    id: 'candida',
    name: _T({
      'uz': 'Kandida (zamburug‘)',
      'ru': 'Кандида (грибы)',
      'en': 'Candida (yeast)',
    }),
    look: _T({
      'uz':
          'Kurtaklanayotgan oval achitqi hujayralari va bo‘g‘imli '
          'psevdogifalar; gifalar hujayralarni "shishga tizilgandek" kesib o‘tadi.',
      'ru':
          'Почкующиеся овальные дрожжевые клетки и членистые псевдогифы; '
          'гифы «нанизывают» клетки.',
      'en':
          'Budding oval yeasts and segmented pseudohyphae; hyphae "skewer" '
          'epithelial cells.',
    }),
    key: _T({
      'uz': 'Bo‘g‘imli iplar + kurtaklanayotgan sporalar.',
      'ru': 'Членистые нити + почкующиеся споры.',
      'en': 'Segmented threads + budding yeasts.',
    }),
    meaning: _T({
      'uz':
          'Vulvovaginal kandidoz bilan mos keladi; shikoyatlarsiz kolonizatsiya '
          'ham bo‘lishi mumkin — klinikaga qarab baholanadi.',
      'ru':
          'Соответствует вульвовагинальному кандидозу; возможна бессимптомная '
          'колонизация — оценивают с клиникой.',
      'en':
          'Consistent with vulvovaginal candidiasis; asymptomatic '
          'colonisation is possible — judge with the clinical picture.',
    }),
    refs: [
      CalcRef(CytoSources.cdcCandida, ''),
      CalcRef(CytoSources.bethesda, 'Ch. 2'),
    ],
  ),
  CytoCell(
    id: 'inflammation',
    name: _T({
      'uz': 'Yallig‘lanish (ko‘p neytrofil)',
      'ru': 'Воспаление (много нейтрофилов)',
      'en': 'Inflammation (many neutrophils)',
    }),
    look: _T({
      'uz':
          'Epiteliy hujayralari orasida va ustida ko‘p segment yadroli '
          'neytrofillar.',
      'ru':
          'Много сегментоядерных нейтрофилов между клетками эпителия и на них.',
      'en': 'Many segmented neutrophils among and over epithelial cells.',
    }),
    key: _T({
      'uz': 'Leykotsitlar epiteliy hujayralaridan ko‘p.',
      'ru': 'Лейкоцитов больше, чем клеток эпителия.',
      'en': 'More leukocytes than epithelial cells.',
    }),
    meaning: _T({
      'uz':
          'Yallig‘lanish belgisi (masalan, trixomoniaz, servitsit). Juda ko‘p '
          'bo‘lsa, epiteliyni yopib qo‘yib, surtmani baholashni qiyinlashtiradi.',
      'ru':
          'Признак воспаления (например, трихомониаз, цервицит). При обилии '
          'закрывает эпителий и затрудняет оценку мазка.',
      'en':
          'A sign of inflammation (e.g. trichomoniasis, cervicitis). Heavy '
          'inflammation can obscure epithelium and limit assessment.',
    }),
    refs: [
      CalcRef(CytoSources.bethesda, 'Ch. 1–2'),
      CalcRef(CytoSources.cdcTrich, ''),
    ],
  ),
  CytoCell(
    id: 'gonococcus',
    name: _T({
      'uz': 'Gonokokklar (Gram bo‘yog‘i)',
      'ru': 'Гонококки (окраска по Граму)',
      'en': 'Gonococci (Gram stain)',
    }),
    look: _T({
      'uz':
          'Juft, loviyasimon, botiq tomonlari bir-biriga qaragan qizil-pushti '
          '(gramm-manfiy) diplokokklar — neytrofillar ichida.',
      'ru':
          'Парные бобовидные красно-розовые (грамотрицательные) диплококки, '
          'вогнутыми сторонами друг к другу — внутри нейтрофилов.',
      'en':
          'Paired, bean-shaped, red-pink (Gram-negative) diplococci with '
          'facing concave sides — inside neutrophils.',
    }),
    key: _T({
      'uz': 'Hujayra ichidagi gramm-manfiy diplokokklar.',
      'ru': 'Внутриклеточные грамотрицательные диплококки.',
      'en': 'Intracellular Gram-negative diplococci.',
    }),
    meaning: _T({
      'uz':
          'Simptomli erkaklarda uretra surtmasida — gonoreya uchun '
          'diagnostik; simptomsiz erkaklarda manfiy surtma infeksiyani '
          'istisno qilmaydi. Endotservikal surtmada Gram sezgirligi past — '
          'NAAT tavsiya etiladi.',
      'ru':
          'У мужчин с симптомами в мазке из уретры — диагностически для '
          'гонореи; у мужчин без симптомов отрицательный мазок инфекцию не '
          'исключает. В мазке из цервикального канала чувствительность '
          'окраски по Граму низкая — рекомендуется МАНК.',
      'en':
          'Diagnostic for gonorrhoea in urethral smears from symptomatic '
          'men; in asymptomatic men a negative smear does not rule it out. '
          'Gram stain is insensitive on endocervical smears — NAAT is '
          'recommended.',
    }),
    refer: true,
    refs: [CalcRef(CytoSources.cdcGono, ''), CalcRef(DiffSources.who2003, '')],
  ),
  CytoCell(
    id: 'hsil',
    name: _T({
      'uz':
          'HSIL: yuqori darajali yassi epiteliy intraepitelial shikastlanishi',
      'ru':
          'HSIL: плоскоклеточное интраэпителиальное поражение высокой степени',
      'en': 'HSIL: high-grade squamous intraepithelial lesion',
    }),
    look: _T({
      'uz':
          'Kichik, yetilmagan hujayralar, ko‘pincha to‘da bo‘lib. Yadro '
          'hujayraning katta qismini egallaydi, to‘q, notekis, xromatini dag‘al.',
      'ru':
          'Мелкие незрелые клетки, часто группами. Ядро занимает большую часть '
          'клетки, тёмное, неровное, хроматин грубый.',
      'en':
          'Small immature cells, often in groups. The nucleus fills most of '
          'the cell; dark, irregular, coarse chromatin.',
    }),
    key: _T({
      'uz':
          'Yadro/sitoplazma nisbati yuqori. Oraliq hujayra yadrosi bilan '
          'solishtiring.',
      'ru': 'Высокое ядерно-цитоплазматическое отношение. Сравните с ядром промежуточной клетки.',
      'en': 'High nuclear-to-cytoplasmic ratio. Compare with an intermediate nucleus.',
    }),
    meaning: _T({
      'uz':
          'Saraton oldi o‘zgarish ehtimoli yuqori. Keyingi qadamni shifokor '
          'ASCCP 2019 bo‘yicha belgilaydi — kolposkopiya yoki tezlashtirilgan '
          'davolash. Xulosani sitolog beradi.',
      'ru':
          'Высокая вероятность предракового поражения. Тактику определяет '
          'врач по ASCCP 2019 — кольпоскопия или ускоренное лечение. '
          'Заключение даёт цитолог.',
      'en':
          'High likelihood of a precancerous lesion. The clinician decides '
          'next steps per ASCCP 2019 — colposcopy or expedited treatment. '
          'The cytologist reports.',
    }),
    confuse: _T({
      'uz': 'Parabazal va metaplastik hujayralar — ularning yadrosi tekis, xromatini mayda.',
      'ru': 'Парабазальные и метапластические клетки — ядро ровное, хроматин мелкий.',
      'en': 'Parabasal and metaplastic cells — smooth nuclei, fine chromatin.',
    }),
    refer: true,
    refs: [
      CalcRef(CytoSources.bethesda, 'Ch. 5'),
      CalcRef(CytoSources.nciAbnormal, ''),
      CalcRef(CytoSources.asccp2019, 'Major changes, item 3; Section E.3'),
    ],
  ),
];

CytoCell? cytoCell(String id) {
  for (final c in cytoCells) {
    if (c.id == id) return c;
  }
  return null;
}

// ───────────────────────── Tozalik darajasi ─────────────────────────

enum CytoLacto { many, few, none }

enum CytoLeuko { single, moderate, many }

enum CytoFlora { none, mixed, pathogenic }

class CytoDegree {
  const CytoDegree(this.n, this.picture, this.meaning);
  final int n;
  final LocalizedText picture;
  final LocalizedText meaning;
}

/// An'anaviy (MDH amaliyotidagi) 4 darajali tasnif — A. Heurlein (1910).
/// Tibbiy ko'rik 2026-10-18: har darajaga alohida pH oralig'i ko'rib
/// chiqilgan manbalarda (ROAG 2019, Kurbonova 2023, Ison–Hay 2002) yo'q —
/// avvalgi "4,0–4,5 / 4,5–5,0 / 5,0–7,0 / 7,0–7,5" olib tashlandi.
/// Manbalar ekranda [cytoDegreeCites] bilan ko'rsatiladi.
const cytoDegrees = <CytoDegree>[
  CytoDegree(
    1,
    _T({
      'uz': 'Laktobatsillalar ko‘p, yassi epiteliy, leykotsitlar yakka yoki yo‘q.',
      'ru': 'Много лактобацилл, плоский эпителий, лейкоциты единичные или отсутствуют.',
      'en': 'Abundant lactobacilli, squamous cells, rare or no leukocytes.',
    }),
    _T({'uz': 'Norma', 'ru': 'Норма', 'en': 'Normal'}),
  ),
  CytoDegree(
    2,
    _T({
      'uz': 'Laktobatsillalar kamroq, oz miqdorda boshqa flora, leykotsitlar yakka.',
      'ru': 'Лактобацилл меньше, немного другой флоры, лейкоциты единичные.',
      'en': 'Fewer lactobacilli, a little other flora, rare leukocytes.',
    }),
    _T({
      'uz': 'Norma chegarasida',
      'ru': 'Вариант нормы',
      'en': 'Within normal',
    }),
  ),
  CytoDegree(
    3,
    _T({
      'uz': 'Laktobatsillalar oz, aralash (kokkli) flora ustun, leykotsitlar ko‘p.',
      'ru': 'Лактобацилл мало, преобладает смешанная (кокковая) флора, много лейкоцитов.',
      'en': 'Few lactobacilli, mixed (coccal) flora predominates, many leukocytes.',
    }),
    _T({
      'uz': 'Yallig‘lanish belgisi',
      'ru': 'Признак воспаления',
      'en': 'Suggests inflammation',
    }),
  ),
  CytoDegree(
    4,
    _T({
      'uz':
          'Laktobatsillalar yo‘q, patogen flora ko‘p (masalan, trixomonada), '
          'leykotsitlar juda ko‘p.',
      'ru':
          'Лактобацилл нет, много патогенной флоры (например, трихомонады), '
          'лейкоцитов очень много.',
      'en':
          'No lactobacilli, abundant pathogenic flora (e.g. trichomonads), '
          'very many leukocytes.',
    }),
    _T({
      'uz': 'Yaqqol yallig‘lanish',
      'ru': 'Выраженное воспаление',
      'en': 'Marked inflammation',
    }),
  ),
];

/// "Manba: …" qatorlari — tozalik darajasi ekranida jadval yonida ko'rinadi
/// (tibbiy ko'rik 2026-10-18; har qator shu sessiyada ochilgan matn bilan
/// solishtirilgan). Manbalar bir-biridan farq qiladi — ikkalasi ham
/// ko'rsatiladi.
const cytoDegreeCites = <LocalizedText>[
  _T({
    'uz':
        'Manba: Rossiya akusher-ginekologlar jamiyati (ROAG), 2019, «Ayollar '
        'jinsiy yo‘llaridan patologik ajralma bilan kechadigan kasalliklar '
        'diagnostikasi va davolash bo‘yicha klinik tavsiyalar» (2-nashr), '
        '«Bakterial vaginoz — Tasnif» bo‘limi: qin tozaligining 4 darajasi — '
        'A. Heurlein (1910) tasnifi; uning o‘rniga 1995-yilgi vaginal biotop '
        'tasnifi kelgan, Heurlein va O. Jirovec (1948) tasniflari «hozir kam '
        'ma’lumot beradi va faqat tarixiy ahamiyatga ega». Bakterial vaginoz '
        'mezonlari — Amsel (biri: pH > 4,5) va Nugent (7–10 ball).',
    'ru':
        'Источник: Российское общество акушеров-гинекологов (РОАГ), 2019, '
        '«Клинические рекомендации по диагностике и лечению заболеваний, '
        'сопровождающихся патологическими выделениями из половых путей '
        'женщин» (2-е изд.), раздел «Бактериальный вагиноз — Классификация»: '
        '4 степени чистоты влагалища — классификация A. Heurlein (1910); её '
        'заменила классификация вагинального биотопа 1995 г., классификации '
        'Heurlein и O. Jirovec (1948) «в настоящее время малоинформативны и '
        'имеют лишь историческое значение». Критерии бактериального '
        'вагиноза — Амсел (один из них: pH > 4,5) и Ньюджент (7–10 баллов).',
    'en':
        'Source: Russian Society of Obstetricians and Gynecologists (ROAG), '
        '2019, “Clinical guidelines on diseases with pathological genital '
        'discharge in women” (2nd ed.), section “Bacterial vaginosis — '
        'Classification”: the 4 vaginal cleanliness grades are A. Heurlein’s '
        '(1910) classification; it was replaced by the 1995 vaginal biotope '
        'classification, and the Heurlein and O. Jirovec (1948) schemes “are '
        'now of little informative value and of historical interest only”. '
        'Bacterial vaginosis criteria — Amsel (one of them: pH > 4.5) and '
        'Nugent (score 7–10).',
  }),
  _T({
    'uz':
        'Manba: Kurbonova Z.Ch., 2023, «Klinik laboratoriya tashxisi», 6.5 '
        '(Gardnerellyoz), 70-b.: o‘zbek darsligi «qin tozalik darajasi»ni '
        'Hay–Ison shkalasi bo‘yicha beradi — 0 (epiteliy bor, bakteriya '
        'yo‘q), I (laktobatsillalar ustun), II (aralash flora), III '
        '(bakterial vaginoz), IV (gramm-musbat kokklar). Bu Heurlein '
        'darajalaridan boshqa tizim.',
    'ru':
        'Источник: Kurbonova Z.Ch., 2023, «Klinik laboratoriya tashxisi», '
        '6.5 (гарднереллёз), с. 70: узбекский учебник даёт «степень чистоты '
        'влагалища» по шкале Hay–Ison — 0 (эпителий без бактерий), I '
        '(преобладают лактобациллы), II (смешанная флора), III '
        '(бактериальный вагиноз), IV (грамположительные кокки). Это другая '
        'система, не степени Heurlein.',
    'en':
        'Source: Kurbonova Z.Ch., 2023, “Klinik laboratoriya tashxisi”, 6.5 '
        '(gardnerellosis), p. 70: the Uzbek textbook gives the “vaginal '
        'cleanliness grade” on the Hay–Ison scale — 0 (epithelial cells, no '
        'bacteria), I (lactobacilli predominate), II (mixed flora), III '
        '(bacterial vaginosis), IV (Gram-positive cocci). This is a different '
        'system from Heurlein’s grades.',
  }),
  _T({
    'uz':
        'Manba: Ison C.A., Hay P.E., 2002, «Validation of a simplified '
        'grading of Gram stained vaginal smears…», Sex Transm Infect '
        '78(6), 413–415-b.: Hay–Ison asl ta’rifi — I normal, II oraliq, III '
        'bakterial vaginoz; 0 — faqat epiteliy, bakteriyasiz; IV — faqat '
        'gramm-musbat kokklar.',
    'ru':
        'Источник: Ison C.A., Hay P.E., 2002, «Validation of a simplified '
        'grading of Gram stained vaginal smears…», Sex Transm Infect 78(6), '
        'с. 413–415: исходное определение Hay–Ison — I норма, II '
        'промежуточная, III бактериальный вагиноз; 0 — только эпителий, без '
        'бактерий; IV — только грамположительные кокки.',
    'en':
        'Source: Ison C.A., Hay P.E., 2002, “Validation of a simplified '
        'grading of Gram stained vaginal smears…”, Sex Transm Infect 78(6), '
        'pp. 413–415: the original Hay–Ison definitions — I normal, II '
        'intermediate, III bacterial vaginosis; 0 epithelial cells only, no '
        'bacteria; IV Gram-positive cocci only.',
  }),
  _T({
    'uz':
        'Har bir darajaga alohida pH oralig‘i ko‘rib chiqilgan manbalarda '
        '(ROAG 2019, Kurbonova 2023, Ison–Hay 2002) berilmagan, shuning '
        'uchun jadvalda pH yo‘q. Darajalar tavsifi — an’anaviy sxema; '
        'Heurlein 1910 asl matni ochiq manbada topilmadi.',
    'ru':
        'Отдельные диапазоны pH для каждой степени в проверенных источниках '
        '(РОАГ 2019, Kurbonova 2023, Ison–Hay 2002) не приводятся, поэтому в '
        'таблице pH нет. Описание степеней — традиционная схема; исходный '
        'текст Heurlein 1910 в открытом доступе не найден.',
    'en':
        'None of the sources checked (ROAG 2019, Kurbonova 2023, Ison–Hay '
        '2002) gives a pH range per grade, so the table shows no pH. The '
        'grade descriptions are the traditional scheme; Heurlein’s 1910 '
        'original text was not found in open access.',
  }),
];

/// Tozalik darajasi ekrani pastidagi manbalar ro'yxati.
const cytoDegreeRefs = <CalcRef>[
  CalcRef(
    CytoSources.roag2019,
    'Бактериальный вагиноз — Классификация (Таблица 4)',
  ),
  CalcRef(CytoSources.kurbonova2023, '6.5 Gardnerellyoz, p. 70'),
  CalcRef(CytoSources.isonHay2002, 'Abstract, p. 413'),
  CalcRef(CytoSources.amsel, ''),
  CalcRef(CytoSources.nugent, ''),
  CalcRef(CytoSources.cdcBv, ''),
];

/// Belgilar bo'yicha daraja: eng og'ir belgi hal qiladi.
int cytoDegreeOf(CytoLacto lacto, CytoLeuko leuko, CytoFlora flora) {
  final a = switch (lacto) {
    CytoLacto.many => 1,
    CytoLacto.few => 3,
    CytoLacto.none => 4,
  };
  final b = switch (leuko) {
    CytoLeuko.single => 1,
    CytoLeuko.moderate => 3,
    CytoLeuko.many => 4,
  };
  final c = switch (flora) {
    CytoFlora.none => 1,
    CytoFlora.mixed => 3,
    CytoFlora.pathogenic => 4,
  };
  var d = [a, b, c].reduce((x, y) => x > y ? x : y);
  // II daraja — [cytoDegrees] dagi o'z matni bo'yicha: "laktobatsillalar
  // kamroq, oz miqdorda boshqa flora, leykotsitlar yakka". Leykotsitlar yakka
  // bo'lib, laktobatsillalar kamaygan (yoki aralash flora qo'shilgan), lekin
  // laktobatsillalar yo'q emas va patogen flora yo'q — II. Leykotsitlar ko'p
  // bo'lsa (yallig'lanish belgisi) kamida III daraja.
  if (d == 3 &&
      leuko == CytoLeuko.single &&
      lacto != CytoLacto.none &&
      flora != CytoFlora.pathogenic) {
    d = 2;
  }
  return d;
}

// ───────────────────────── Bethesda ─────────────────────────

class BethesdaItem {
  const BethesdaItem(
    this.code,
    this.name,
    this.meaning, {
    this.tone = 0,
    this.refs = const [],
    this.cites = const [],
  });
  final String code;
  final LocalizedText name;
  final LocalizedText meaning;

  /// 0 — norma, 1 — kuzatish/qo'shimcha test, 2 — shifokorga tez.
  final int tone;

  final List<CalcRef> refs;

  /// Karta ichida ko'rinadigan "Manba: muallif, yil, «nom», bo'lim, bet"
  /// qatorlari (atama yoki da'vo shu manbadan ekanini ko'rsatadi).
  final List<LocalizedText> cites;
}

/// Bethesda 2014 terminologiyasi ro'yxati (Pangarkar 2022 jadvali).
const _tbsList = CalcRef(
  CytoSources.pangarkar2022,
  'The 2014 Bethesda System: Interpretation/result',
);

const bethesdaItems = <BethesdaItem>[
  BethesdaItem(
    'NILM',
    _T({
      'uz': 'Intraepitelial shikastlanish yoki xavfli o‘sma yo‘q',
      'ru': 'Нет интраэпителиального поражения или злокачественности',
      'en': 'Negative for intraepithelial lesion or malignancy',
    }),
    _T({
      'uz': 'Norma. Infeksiya yoki reaktiv o‘zgarishlar alohida yoziladi.',
      'ru': 'Норма. Инфекции и реактивные изменения указываются отдельно.',
      'en': 'Normal. Organisms and reactive changes are reported separately.',
    }),
    refs: [_tbsList],
  ),
  BethesdaItem(
    'ASC-US',
    _T({
      'uz': 'Noaniq ahamiyatli atipik yassi hujayralar',
      'ru': 'Атипичные клетки плоского эпителия неясного значения',
      'en': 'Atypical squamous cells of undetermined significance',
    }),
    _T({
      'uz': 'Eng ko‘p uchraydigan noaniq xulosa; odatda HPV testi bilan aniqlashtiriladi.',
      'ru': 'Самое частое неопределённое заключение; обычно уточняют тестом на ВПЧ.',
      'en': 'The commonest equivocal result; usually triaged with an HPV test.',
    }),
    tone: 1,
    refs: [_tbsList, CalcRef(CytoSources.wang2023, 'ASC-US')],
  ),
  BethesdaItem(
    'LSIL',
    _T({
      'uz': 'Past darajali yassi epiteliy intraepitelial shikastlanishi',
      'ru': 'Плоскоклеточное интраэпителиальное поражение низкой степени',
      'en': 'Low-grade squamous intraepithelial lesion',
    }),
    _T({
      'uz': 'Odatda HPV ta’siri (koylotsitlar); ko‘pincha o‘z-o‘zidan o‘tadi. Keyingi qadamni shifokor belgilaydi.',
      'ru': 'Обычно эффект ВПЧ (койлоциты); часто регрессирует. Дальнейшую тактику определяет врач.',
      'en': 'Usually HPV effect (koilocytes); often regresses. The clinician decides next steps.',
    }),
    tone: 1,
    refs: [_tbsList, CalcRef(CytoSources.pangarkar2022, 'Introduction')],
  ),
  BethesdaItem(
    'ASC-H',
    _T({
      'uz': 'Atipik yassi hujayralar, HSIL istisno qilinmaydi',
      'ru': 'Атипичные клетки плоского эпителия, нельзя исключить HSIL',
      'en': 'Atypical squamous cells, cannot exclude HSIL',
    }),
    _T({
      'uz': 'Yuqori darajali o‘zgarish ehtimoli bor — odatda kolposkopiya.',
      'ru': 'Возможно поражение высокой степени — обычно кольпоскопия.',
      'en': 'A high-grade lesion is possible — colposcopy is usual.',
    }),
    tone: 2,
    refs: [_tbsList, CalcRef(CytoSources.kattoor2022, 'Management guidelines')],
  ),
  BethesdaItem(
    'HSIL',
    _T({
      'uz': 'Yuqori darajali yassi epiteliy intraepitelial shikastlanishi',
      'ru': 'Плоскоклеточное интраэпителиальное поражение высокой степени',
      'en': 'High-grade squamous intraepithelial lesion',
    }),
    // Yo'naltiruvchi emas: qaror — shifokorda (audit, 17-oktabr).
    _T({
      'uz':
          'Saraton oldi o‘zgarish ehtimoli yuqori. Keyingi qadamni shifokor '
          'ASCCP 2019 bo‘yicha belgilaydi — kolposkopiya yoki tezlashtirilgan '
          'davolash (biopsiyasiz).',
      'ru':
          'Высокая вероятность предрака. Тактику определяет врач по ASCCP '
          '2019 — кольпоскопия или ускоренное лечение (без предварительной '
          'биопсии).',
      'en':
          'High likelihood of precancer. The clinician decides next steps per '
          'ASCCP 2019 — colposcopy or expedited treatment (without prior '
          'biopsy).',
    }),
    tone: 2,
    refs: [
      _tbsList,
      CalcRef(CytoSources.asccp2019, 'Major changes, item 3; Section E.3'),
    ],
  ),
  BethesdaItem(
    'SCC',
    _T({
      'uz': 'Yassi hujayrali karsinoma',
      'ru': 'Плоскоклеточный рак',
      'en': 'Squamous cell carcinoma',
    }),
    _T({
      'uz': 'Zudlik bilan mutaxassisga.',
      'ru': 'Срочно к специалисту.',
      'en': 'Urgent specialist referral.',
    }),
    tone: 2,
    refs: [_tbsList],
  ),
  BethesdaItem(
    'AGC',
    _T({
      'uz':
          'Atipik bezli hujayralar (endotservikal, endometrial yoki '
          'aniqlanmagan — NOS)',
      'ru':
          'Атипичные железистые клетки (эндоцервикальные, эндометриальные или '
          'без уточнения — NOS)',
      'en':
          'Atypical glandular cells (endocervical, endometrial or not '
          'otherwise specified — NOS)',
    }),
    _T({
      'uz':
          'Bez epiteliysi o‘zgarishi; chuqurroq tekshiruvni shifokor belgilaydi '
          '(ASCCP 2019, homilador bo‘lmaganlarda: kolposkopiya va endotservikal '
          'namuna; 35 yosh va undan kattalarda, shuningdek 35 yoshgacha '
          'endometriy o‘smasi xavfi oshganlarda — masalan, anormal bachadon '
          'qon ketishi, surunkali anovulyatsiya belgilari yoki semizlik — '
          'qo‘shimcha endometrial namuna; atipik endometrial hujayralarda '
          'avval endometrial va endotservikal namuna).',
      'ru':
          'Изменения железистого эпителия; объём обследования определяет врач '
          '(ASCCP 2019, у небеременных: кольпоскопия и эндоцервикальный забор; '
          'в 35 лет и старше, а также до 35 лет при повышенном риске неоплазии '
          'эндометрия — например, аномальном маточном кровотечении, признаках '
          'хронической ановуляции или ожирении — дополнительно забор из '
          'эндометрия; при атипичных клетках эндометрия — сначала '
          'эндометриальный и эндоцервикальный забор).',
      'en':
          'Glandular abnormality; the clinician decides the work-up (ASCCP '
          '2019, non-pregnant patients: colposcopy with endocervical sampling; '
          'at age 35 or older, and under 35 at increased risk of endometrial '
          'neoplasia — e.g. abnormal uterine bleeding, signs of chronic '
          'anovulation or obesity — endometrial sampling as well; for '
          'atypical endometrial cells, endometrial and endocervical sampling '
          'first).',
    }),
    tone: 2,
    refs: [_tbsList, CalcRef(CytoSources.asccp2019, 'Section G.1')],
  ),
  BethesdaItem(
    'AGC, favor neoplastic',
    _T({
      'uz':
          'Atipik bezli hujayralar, o‘sma (neoplaziya) foydasiga '
          '(endotservikal yoki aniqlanmagan)',
      'ru':
          'Атипичные железистые клетки, похожие на неопластичные '
          '(AGC-FN, favor neoplastic; эндоцервикальные или без уточнения)',
      'en':
          'Atypical glandular cells, favor neoplastic (endocervical or not '
          'otherwise specified)',
    }),
    _T({
      'uz':
          'O‘zgarish AIS yoki adenokarsinomaga yetmaydi, lekin o‘sma ehtimoli '
          'bor. Tekshiruvni shifokor ASCCP 2019 bo‘yicha belgilaydi.',
      'ru':
          'Изменения не достигают AIS или аденокарциномы, но опухоль '
          'вероятна. Обследование определяет врач по ASCCP 2019.',
      'en':
          'Falls short of AIS or adenocarcinoma, but neoplasia is likely. The '
          'clinician decides the work-up per ASCCP 2019.',
    }),
    tone: 2,
    refs: [
      _tbsList,
      CalcRef(CytoSources.wang2023, 'Atypical glandular cells'),
      CalcRef(CytoSources.asccp2019, 'Section G.1'),
      CalcRef(CytoSources.krCin2024, 'Список сокращений: AGC-FN'),
      CalcRef(CytoSources.grigoruk2024, 'p. 103'),
    ],
    cites: [
      _T({
        'uz':
            'Ruscha atama — manba: RF Sog‘liqni saqlash vazirligi klinik '
            'tavsiyasi «Цервикальная интраэпителиальная неоплазия, эрозия и '
            'эктропион шейки матки», 2024 (ID 597), «Список сокращений»: '
            '«атипичные железистые клетки, похожие на неопластичные».',
        'ru':
            'Русский термин — источник: клинические рекомендации Минздрава '
            'России «Цервикальная интраэпителиальная неоплазия, эрозия и '
            'эктропион шейки матки», 2024 (ID 597), «Список сокращений»: '
            '«атипичные железистые клетки, похожие на неопластичные».',
        'en':
            'Russian term — source: RF Ministry of Health clinical guideline '
            '“Cervical intraepithelial neoplasia, erosion and ectropion of the '
            'cervix”, 2024 (ID 597), list of abbreviations: «атипичные '
            'железистые клетки, похожие на неопластичные».',
      }),
      _T({
        'uz':
            'Boshqa ruscha variant — manba: Grigoruk O.G. va hamm., 2024, '
            '«Цитологическая диагностика железистых поражений цервикального '
            'канала», Опухоли женской репродуктивной системы 20(4), 103-b.: '
            '«атипичные железистые клетки, подозрительные на '
            'аденокарциному».',
        'ru':
            'Другой вариант — источник: Григорук О.Г. и соавт., 2024, '
            '«Цитологическая диагностика железистых поражений цервикального '
            'канала», Опухоли женской репродуктивной системы 20(4), с. 103: '
            '«атипичные железистые клетки, подозрительные на '
            'аденокарциному».',
        'en':
            'Another Russian variant — source: Grigoruk O.G. et al., 2024, '
            '“Cytological diagnosis of glandular lesions of the cervical '
            'canal”, Tumors of Female Reproductive System 20(4), p. 103: '
            '«атипичные железистые клетки, подозрительные на '
            'аденокарциному».',
      }),
    ],
  ),
  BethesdaItem(
    'AIS',
    _T({
      'uz': 'Endotservikal adenokarsinoma in situ',
      'ru': 'Эндоцервикальная аденокарцинома in situ',
      'en': 'Endocervical adenocarcinoma in situ',
    }),
    _T({
      'uz': 'Bez epiteliysining saraton oldi o‘zgarishi — mutaxassisga.',
      'ru': 'Предраковое поражение железистого эпителия — к специалисту.',
      'en': 'Glandular precancer — specialist referral.',
    }),
    tone: 2,
    refs: [_tbsList],
  ),
  BethesdaItem(
    'Adenocarcinoma',
    _T({
      'uz':
          'Adenokarsinoma (endotservikal, endometrial, bachadondan tashqari '
          'yoki aniqlanmagan — NOS)',
      'ru':
          'Аденокарцинома (эндоцервикальная, эндометриальная, внематочная или '
          'без уточнения — NOS)',
      'en':
          'Adenocarcinoma (endocervical, endometrial, extrauterine or not '
          'otherwise specified — NOS)',
    }),
    _T({
      'uz': 'Bezli xavfli o‘sma hujayralari — zudlik bilan mutaxassisga.',
      'ru': 'Клетки железистой злокачественной опухоли — срочно к специалисту.',
      'en': 'Malignant glandular cells — urgent specialist referral.',
    }),
    tone: 2,
    refs: [_tbsList, CalcRef(CytoSources.asccp2019, 'Section G.1')],
  ),
];

// ───────────────────────── Surtma olish va bo'yash ─────────────────────────

class CytoStep {
  const CytoStep(this.title, this.body);
  final LocalizedText title;
  final LocalizedText body;
}

const cytoTechnique = <CytoStep>[
  CytoStep(
    _T({
      'uz': 'Bemor tayyorgarligi',
      'ru': 'Подготовка пациентки',
      'en': 'Patient preparation',
    }),
    _T({
      'uz':
          'Hayz kunlaridan tashqari. 2 kun oldin jinsiy aloqa, chayish, qin '
          'dorilari va spermitsidlardan saqlanish tavsiya etiladi.',
      'ru':
          'Вне менструации. За 2 дня избегать половых контактов, спринцеваний, '
          'вагинальных средств и спермицидов.',
      'en':
          'Outside menstruation. Avoid intercourse, douching, vaginal '
          'medicines and spermicides for 2 days before.',
    }),
  ),
  CytoStep(
    _T({'uz': 'Material olish', 'ru': 'Взятие материала', 'en': 'Sampling'}),
    _T({
      'uz':
          'Spatula bilan bo‘yinchaning qin qismidan, cho‘tka bilan bo‘yin '
          'kanalidan — transformatsiya zonasini qamrab.',
      'ru':
          'Шпателем — с влагалищной части шейки, щёточкой — из '
          'цервикального канала, захватывая зону трансформации.',
      'en':
          'Spatula from the ectocervix and brush from the endocervical canal, '
          'covering the transformation zone.',
    }),
  ),
  CytoStep(
    _T({
      'uz': 'Surtma va fiksatsiya',
      'ru': 'Мазок и фиксация',
      'en': 'Smear and fixation',
    }),
    _T({
      'uz':
          'Yupqa, tekis qatlam. Papanikolau uchun — darhol ho‘l fiksatsiya '
          '(95% spirt yoki sprey); qurib qolsa, yadrolar buziladi. Suyuq asosli '
          'sitologiyada material idishga chayiladi.',
      'ru':
          'Тонкий ровный слой. Для Папаниколау — сразу влажная фиксация (95% '
          'спирт или спрей); при высыхании ядра искажаются. При жидкостной '
          'цитологии материал смывают во флакон.',
      'en':
          'Thin, even layer. For Pap — immediate wet fixation (95% alcohol or '
          'spray); air-drying distorts nuclei. For liquid-based cytology rinse '
          'the device into the vial.',
    }),
  ),
  CytoStep(
    _T({'uz': 'Bo‘yash', 'ru': 'Окраска', 'en': 'Staining'}),
    _T({
      'uz':
          'Papanikolau: yadro — gematoksilin (ko‘k), sitoplazma — OG-6 va EA '
          '(pushti yoki ko‘k-yashil). Romanovskiy — havoda quritilgan surtma. '
          'Gram — bakterial vaginoz (Nugent) va gonokokklar uchun.',
      'ru':
          'Папаниколау: ядро — гематоксилин (синий), цитоплазма — OG-6 и EA '
          '(розовая или сине-зелёная). Романовский — высушенный мазок. Грам — '
          'для бактериального вагиноза (Ньюджент) и гонококков.',
      'en':
          'Pap: nuclei — haematoxylin (blue); cytoplasm — OG-6 and EA (pink or '
          'blue-green). Romanowsky — air-dried smear. Gram — for bacterial '
          'vaginosis (Nugent) and gonococci.',
    }),
  ),
  CytoStep(
    _T({'uz': 'Ko‘p xatolar', 'ru': 'Частые ошибки', 'en': 'Common errors'}),
    _T({
      'uz':
          'Qalin surtma; kech fiksatsiya (qurish artefakti); qon yoki ko‘p '
          'leykotsit epiteliyni yopadi; hujayra kam; bo‘yin kanali hujayralari '
          'yo‘q (transformatsiya zonasi olinmagan).',
      'ru':
          'Толстый мазок; поздняя фиксация (артефакт высыхания); кровь или '
          'много лейкоцитов закрывают эпителий; мало клеток; нет клеток '
          'цервикального канала (не взята зона трансформации).',
      'en':
          'Thick smear; delayed fixation (drying artefact); blood or heavy '
          'inflammation obscuring cells; scant cellularity; no endocervical '
          'cells (transformation zone not sampled).',
    }),
  ),
];

const cytoTechniqueRefs = [
  CalcRef(CytoSources.medlinePap, ''),
  CalcRef(CytoSources.nciPdq, ''),
  CalcRef(CytoSources.bethesda, 'Ch. 1'),
  CalcRef(CytoSources.nugent, ''),
];

/// "Bu nima?" mashqidagi savollar soni.
const cytoQuizSize = 10;

// ───────────────────────── Izohli sxema: 1–2 belgilar ─────────────────────────

/// Kartadagi izohli sxema (`assets/cytology/<id>.png`, raqamli belgilar):
/// bo'yoq/preparat turi, 1 va 2 belgilar izohi va cheklov. Manba:
/// egasi bergan paket (tool/illustrations/cyto/annotated/metadata.json),
/// manbalarga solishtirildi; mutaxassis tasdig'i alohida (hali yo'q).
class CytoMarks {
  const CytoMarks({
    required this.method,
    required this.marks,
    required this.caveat,
    required this.refs,
  });

  /// Bo'yoq yoki preparat turi.
  final LocalizedText method;

  /// Rasmdagi 1 va 2 raqamlari izohi (tartib bilan).
  final List<LocalizedText> marks;
  final LocalizedText caveat;
  final List<CalcRef> refs;
}

const _pap = _T({
  'uz': 'Papanikolau (Pap)',
  'ru': 'Папаниколау (Pap)',
  'en': 'Papanicolaou (Pap)',
});

const cytoMarks = <String, CytoMarks>{
  'candida': CytoMarks(
    method: _T({
      'uz': 'KOH / Gram / Pap',
      'ru': 'КОН / Грам / Pap',
      'en': 'KOH / Gram / Pap',
    }),
    marks: [
      _T({
        'uz': 'Kurtaklanayotgan oval achitqi hujayralari.',
        'ru': 'Почкующиеся овальные дрожжевые клетки.',
        'en': 'Budding oval yeast cells.',
      }),
      _T({
        'uz': 'Psevdogifa: tutashgan cho‘ziq hujayralar, tutash joylarda torayish bor.',
        'ru': 'Псевдогифа: соединённые вытянутые клетки с перетяжками в местах соединения.',
        'en': 'Pseudohypha: joined elongated cells with constrictions at the junctions.',
      }),
    ],
    caveat: _T({
      'uz': 'Psevdogifa hamma Candida turida ko‘rinmaydi; natija simptomlar va testlar bilan birga baholanadi.',
      'ru': 'Псевдогифы видны не у всех видов Candida; результат оценивают вместе с симптомами и тестами.',
      'en': 'Not every Candida species forms pseudohyphae; interpret with symptoms and tests.',
    }),
    refs: [CalcRef(CytoSources.cdcCandida, '')],
  ),
  'clue_cell': CytoMarks(
    method: _T({
      'uz': 'Nativ / Gram / Pap',
      'ru': 'Нативный / Грам / Pap',
      'en': 'Wet mount / Gram / Pap',
    }),
    marks: [
      _T({
        'uz': 'Epiteliy yuzasiga zich yopishgan mayda bakteriyalar.',
        'ru': 'Мелкие бактерии, плотно прилипшие к поверхности эпителия.',
        'en': 'Small bacteria densely adhering to the cell surface.',
      }),
      _T({
        'uz': 'Bakteriyalar hujayra chetini ham xira qilib qo‘yadi.',
        'ru': 'Бактерии делают нечётким и край клетки.',
        'en': 'Bacteria blur the cell border as well.',
      }),
    ],
    caveat: _T({
      'uz': 'Bakterial vaginoz belgilaridan biri; faqat shu rasmga qarab tashxis qo‘yilmaydi.',
      'ru': 'Один из признаков бактериального вагиноза; только по этой картине диагноз не ставят.',
      'en': 'One sign of bacterial vaginosis; never a diagnosis on its own.',
    }),
    refs: [CalcRef(CytoSources.cdcBv, '')],
  ),
  'endocervical': CytoMarks(
    method: _pap,
    marks: [
      _T({
        'uz': 'Tepadan: tartibli, asalari uyasiga o‘xshash qatlam.',
        'ru': 'Сверху: упорядоченный пласт, похожий на соты.',
        'en': 'En face: an orderly honeycomb sheet.',
      }),
      _T({
        'uz': 'Yondan: silindrsimon hujayralar, yadrolar bazal joylashgan.',
        'ru': 'Сбоку: цилиндрические клетки с базально расположенными ядрами.',
        'en': 'Side view: columnar cells with basal nuclei.',
      }),
    ],
    caveat: _T({
      'uz': 'Bu ikki xil ko‘rish yo‘nalishi; kiprikchalar hamma hujayrada bo‘lmaydi.',
      'ru': 'Это два ракурса одного эпителия; реснички есть не у всех клеток.',
      'en': 'Two views of the same epithelium; not all cells are ciliated.',
    }),
    refs: [CalcRef(CytoSources.iarcAtlas, '')],
  ),
  'gonococcus': CytoMarks(
    method: _T({'uz': 'Gram', 'ru': 'Грам', 'en': 'Gram'}),
    marks: [
      _T({
        'uz': 'Ko‘p bo‘lakli yadroli neytrofil.',
        'ru': 'Нейтрофил с многодольчатым ядром.',
        'en': 'Neutrophil with a multilobed nucleus.',
      }),
      _T({
        'uz': 'Sitoplazmada pushti-qizil, juft, loviyasimon kokklar (kattalashtirib chizilgan).',
        'ru': 'В цитоплазме розово-красные парные бобовидные кокки (нарисованы увеличенными).',
        'en': 'Pink-red, paired, bean-shaped cocci in the cytoplasm (drawn enlarged).',
      }),
    ],
    caveat: _T({
      'uz': 'Endotservikal surtmada Gram bo‘yicha manfiy natija gonoreyani istisno qilmaydi — NAAT kerak bo‘lishi mumkin.',
      'ru': 'Отрицательный мазок по Граму из цервикального канала не исключает гонорею — может понадобиться МАНК.',
      'en': 'A negative endocervical Gram smear does not exclude gonorrhoea — NAAT may be needed.',
    }),
    refs: [CalcRef(CytoSources.cdcGono, '')],
  ),
  'hsil': CytoMarks(
    method: _pap,
    marks: [
      _T({
        'uz': 'Yadro/sitoplazma nisbati yuqori, sitoplazma kam.',
        'ru': 'Высокое ядерно-цитоплазматическое отношение, мало цитоплазмы.',
        'en': 'High nuclear-to-cytoplasmic ratio, scant cytoplasm.',
      }),
      _T({
        'uz': 'Yadro konturi notekis, xromatini qo‘pol va to‘q.',
        'ru': 'Неровный контур ядра, грубый тёмный хроматин.',
        'en': 'Irregular nuclear outline, coarse dark chromatin.',
      }),
    ],
    caveat: _T({
      'uz': 'Sxema HSIL belgilarini tushuntiradi; yakuniy talqinni sitolog beradi.',
      'ru': 'Схема объясняет признаки HSIL; окончательную оценку даёт цитолог.',
      'en': 'The drawing explains HSIL features; a cytologist makes the final call.',
    }),
    refs: [CalcRef(CytoSources.iarcHsil, '')],
  ),
  'inflammation': CytoMarks(
    method: _T({
      'uz': 'Pap yoki boshqa bo‘yalgan surtma',
      'ru': 'Pap или другой окрашенный мазок',
      'en': 'Pap or another stained smear',
    }),
    marks: [
      _T({
        'uz': 'Ko‘p bo‘lakli yadroli neytrofillar.',
        'ru': 'Нейтрофилы с многодольчатыми ядрами.',
        'en': 'Neutrophils with multilobed nuclei.',
      }),
      _T({
        'uz': 'Taqqoslash uchun katta epiteliy hujayrasi.',
        'ru': 'Крупная эпителиальная клетка для сравнения.',
        'en': 'A large epithelial cell for comparison.',
      }),
    ],
    caveat: _T({
      'uz': 'Neytrofillar ko‘pligi yallig‘lanish belgisi, lekin uning sababini o‘zi ko‘rsatmaydi.',
      'ru': 'Обилие нейтрофилов — признак воспаления, но не указывает его причину.',
      'en': 'Many neutrophils signal inflammation but not its cause.',
    }),
    refs: [CalcRef(CytoSources.iarcAtlas, '')],
  ),
  'intermediate': CytoMarks(
    method: _pap,
    marks: [
      _T({
        'uz': 'Keng, odatda ko‘kimtir-yashil sitoplazma.',
        'ru': 'Широкая, обычно голубовато-зелёная цитоплазма.',
        'en': 'Broad, usually blue-green cytoplasm.',
      }),
      _T({
        'uz': 'Yuzaki hujayradagidan kattaroq, pufaksimon yadro.',
        'ru': 'Пузырьковидное ядро, крупнее, чем у поверхностной клетки.',
        'en': 'Vesicular nucleus, larger than in a superficial cell.',
      }),
    ],
    caveat: _T({
      'uz': 'Yadrosi solishtirish uchun qulay; o‘lcham preparat va holatga qarab o‘zgaradi.',
      'ru': 'Ядро удобно для сравнения; размеры зависят от препарата и состояния.',
      'en': 'A handy nuclear reference; size varies with preparation and condition.',
    }),
    refs: [CalcRef(CytoSources.iarcNormal, '')],
  ),
  'koilocyte': CytoMarks(
    method: _pap,
    marks: [
      _T({
        'uz': 'Yadro atrofida aniq chegarali, notekis bo‘shliq (halo).',
        'ru': 'Вокруг ядра — полость с чёткой неровной границей (гало).',
        'en': 'A sharply bordered, irregular perinuclear cavity (halo).',
      }),
      _T({
        'uz': 'Kattalashgan, konturi notekis, to‘q yadro; chetda zich sitoplazma.',
        'ru': 'Увеличенное тёмное ядро с неровным контуром; по краю плотная цитоплазма.',
        'en': 'Enlarged dark nucleus with an irregular outline; dense cytoplasm at the rim.',
      }),
    ],
    caveat: _T({
      'uz': 'Faqat halo yetarli emas: yadro atipiyasi ham bo‘lishi kerak.',
      'ru': 'Одного гало недостаточно: нужна и атипия ядра.',
      'en': 'A halo alone is not enough: nuclear atypia must be present.',
    }),
    refs: [CalcRef(CytoSources.iarcKoilocyte, '')],
  ),
  'lactobacilli': CytoMarks(
    method: _T({
      'uz': 'Gram; Papda ham ko‘rinishi mumkin',
      'ru': 'Грам; видны и в Pap',
      'en': 'Gram; also visible on Pap',
    }),
    marks: [
      _T({
        'uz': 'Gramda binafsha bo‘yaladigan uzun tayoqchalar.',
        'ru': 'Длинные палочки, окрашивающиеся по Граму в фиолетовый цвет.',
        'en': 'Long rods staining purple on Gram.',
      }),
      _T({
        'uz': 'Taqqoslash uchun epiteliy hujayrasi.',
        'ru': 'Эпителиальная клетка для сравнения.',
        'en': 'An epithelial cell for comparison.',
      }),
    ],
    caveat: _T({
      'uz':
          'Tayoqcha shakli turini aniqlab bermaydi; yagona "normal son" yo‘q.',
      'ru': 'Форма палочки не определяет вид; единой «нормы» количества нет.',
      'en': 'Rod shape does not identify the species; there is no single "normal count".',
    }),
    refs: [CalcRef(CytoSources.cdcBv, ''), CalcRef(CytoSources.iarcAtlas, '')],
  ),
  'metaplastic': CytoMarks(
    method: _pap,
    marks: [
      _T({
        'uz': 'Zich sitoplazma, dumaloq yoki oval, odatda muntazam yadro.',
        'ru':
            'Плотная цитоплазма, ядро круглое или овальное, обычно правильное.',
        'en': 'Dense cytoplasm; round or oval, usually regular nucleus.',
      }),
      _T({
        'uz': 'Ayrim hujayralarda burchakli kontur yoki sitoplazma o‘simtasi.',
        'ru': 'У части клеток угловатый контур или отростки цитоплазмы.',
        'en': 'Some cells show an angular outline or cytoplasmic process.',
      }),
    ],
    caveat: _T({
      'uz': 'Faqat o‘simtaga qarab tanilmaydi; yetilishiga qarab ko‘rinishi o‘zgaradi.',
      'ru': 'Узнают не только по отросткам; вид меняется по мере созревания.',
      'en': 'Not identified by processes alone; appearance changes with maturation.',
    }),
    refs: [CalcRef(CytoSources.iarcMetaplastic, '')],
  ),
  'parabasal': CytoMarks(
    method: _pap,
    marks: [
      _T({
        'uz': 'Kichikroq, dumaloq yoki oval hujayralar, zich sitoplazma.',
        'ru': 'Более мелкие круглые или овальные клетки, плотная цитоплазма.',
        'en': 'Smaller round or oval cells with dense cytoplasm.',
      }),
      _T({
        'uz': 'Oraliq va yuzaki hujayralarga nisbatan yadro ulushi kattaroq.',
        'ru': 'Доля ядра больше, чем у промежуточных и поверхностных клеток.',
        'en': 'Larger nuclear share than intermediate and superficial cells.',
      }),
    ],
    caveat: _T({
      'uz': 'Yadrosi muntazam parabazal hujayra HSIL degani emas.',
      'ru': 'Парабазальная клетка с правильным ядром — это не HSIL.',
      'en': 'A parabasal cell with a regular nucleus is not HSIL.',
    }),
    refs: [
      CalcRef(CytoSources.iarcNormal, ''),
      CalcRef(CytoSources.iarcHsil, ''),
    ],
  ),
  'superficial': CytoMarks(
    method: _pap,
    marks: [
      _T({
        'uz': 'Keng, yassi, ko‘pburchakli sitoplazma.',
        'ru': 'Широкая плоская полигональная цитоплазма.',
        'en': 'Broad, flat, polygonal cytoplasm.',
      }),
      _T({
        'uz': 'Kichik, zich (piknotik) yadro.',
        'ru': 'Маленькое плотное (пикнотичное) ядро.',
        'en': 'Small, dense (pyknotic) nucleus.',
      }),
    ],
    caveat: _T({
      'uz':
          'Ko‘pincha pushti bo‘yaladi, lekin rang har doim bir xil bo‘lmaydi.',
      'ru': 'Чаще окрашивается в розовый, но цвет бывает разным.',
      'en': 'Often pink, but staining colour varies.',
    }),
    refs: [CalcRef(CytoSources.iarcNormal, '')],
  ),
  'trichomonas': CytoMarks(
    method: _T({
      'uz': 'Nativ yoki bo‘yalgan preparat',
      'ru': 'Нативный или окрашенный препарат',
      'en': 'Wet mount or stained smear',
    }),
    marks: [
      _T({
        'uz': 'Noksimon tana, yadro oldingi keng qismda.',
        'ru': 'Грушевидное тело, ядро в переднем широком отделе.',
        'en': 'Pear-shaped body; nucleus in the broad anterior part.',
      }),
      _T({
        'uz': 'To‘rtta oldingi xivchin; qaytuvchi xivchin, to‘lqinsimon membrana va aksostil.',
        'ru': 'Четыре передних жгутика; возвратный жгутик, ундулирующая мембрана и аксостиль.',
        'en': 'Four anterior flagella; recurrent flagellum, undulating membrane and axostyle.',
      }),
    ],
    caveat: _T({
      'uz': 'Bu tuzilish sxemasi. Nativda faol harakat baholanadi; Papda xivchinlar ko‘rinmasligi mumkin. Manfiy nativ natija istisno qilmaydi.',
      'ru': 'Это схема строения. В нативном препарате оценивают активное движение; в Pap жгутики могут быть не видны. Отрицательный нативный препарат не исключает.',
      'en': 'A structural diagram. Wet mounts show motility; flagella may not be visible on Pap. A negative wet mount does not exclude infection.',
    }),
    refs: [
      CalcRef(CytoSources.dpdxTrich, ''),
      CalcRef(CytoSources.cdcTrich, ''),
    ],
  ),
};
