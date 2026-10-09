/// Leykoformula bo'limi manbalari. Har bir da'vo shu ro'yxatdagi ochiq
/// manbadan o'z so'zlarimiz bilan olingan (matn ko'chirilmagan); manbada
/// yo'q raqam yozilmaydi. Domla materiallaridagi raqamlar ishlatilmagan
/// (xatolar bor — kdl/summary_A.md).
library;

import '../tools/calc_info.dart';

abstract final class DiffSources {
  /// JSST qo'llanmasi: 9.10 (surtma tayyorlash, bo'yash, hujayralar
  /// ko'rinishi) va 9.13 (leykoformula). PDF to'liq o'qildi.
  /// Eslatma: 9.13 dagi misolda mutlaq son 10⁸/l deb yozilgan — bu
  /// bosmadagi xato (0,42 × 5×10⁹ = 2,1×10⁹/l); biz ko'chirmadik.
  static const who2003 = CalcSource(
    id: 'diff-who-basic-lab-2003',
    citation:
        'World Health Organization. Manual of basic techniques for a health '
        'laboratory, 2nd ed. Geneva: WHO; 2003. ISBN 92 4 154530 5',
    url: 'https://www.who.int/publications/i/item/9241545305',
  );

  /// MedlinePlus (NLM) — Blood Differential, oxirgi yangilanish 2024-10-09.
  static const medlineDiff = CalcSource(
    id: 'diff-medline-blood-differential',
    citation:
        'MedlinePlus [Internet]. Blood Differential. National Library of '
        'Medicine (US); updated 2024',
    url: 'https://medlineplus.gov/lab-tests/blood-differential/',
  );

  /// MedlinePlus Medical Encyclopedia (A.D.A.M.) — Blood differential test,
  /// review 2025-02-03. Faqat sabablar ro'yxati (faktlar) qisqa bayon
  /// qilingan.
  static const medlineEncyDiff = CalcSource(
    id: 'diff-medline-ency-003657',
    citation:
        'MedlinePlus Medical Encyclopedia. Blood differential test '
        '(article 003657). A.D.A.M.; reviewed 2025',
    url: 'https://medlineplus.gov/ency/article/003657.htm',
  );

  /// NCI Dictionary of Cancer Terms: blast, neutropenia, eosinophilia,
  /// lymphopenia, leukemia.
  static const nciDictionary = CalcSource(
    id: 'diff-nci-dictionary',
    citation:
        'National Cancer Institute. NCI Dictionary of Cancer Terms: blast; '
        'neutropenia; eosinophilia; lymphopenia; leukemia',
    url: 'https://www.cancer.gov/publications/dictionaries/cancer-terms/def/blast',
  );

  static const gulati2013 = CalcSource(
    id: 'diff-gulati-2013',
    citation:
        'Gulati G, Song J, Florea AD, Gong J. Purpose and criteria for blood '
        'smear scan, blood smear examination, and blood smear review. Ann Lab '
        'Med. 2013. doi:10.3343/alm.2013.33.1.1',
    url: 'https://doi.org/10.3343/alm.2013.33.1.1',
  );

  static const susman2021 = CalcSource(
    id: 'diff-susman-2021',
    citation:
        'Susman D, Price R, Kotchetkov R. Lymphocytosis with smudge cells is '
        'not equivalent to chronic lymphocytic leukemia. Case Rep Oncol. '
        '2021. doi:10.1159/000516748',
    url: 'https://doi.org/10.1159/000516748',
  );

  static const oskarsson2022 = CalcSource(
    id: 'diff-oskarsson-2022',
    citation:
        'Oskarsson GR, et al. Genetic architecture of band neutrophil '
        'fraction in Iceland. Commun Biol. 2022. '
        'doi:10.1038/s42003-022-03462-1',
    url: 'https://doi.org/10.1038/s42003-022-03462-1',
  );

  static const zhao2024 = CalcSource(
    id: 'diff-zhao-2024',
    citation:
        'Zhao Y, et al. Performance evaluation of the digital morphology '
        'analyser Sysmex DI-60 for white blood cell differentials in abnormal '
        'samples. Sci Rep. 2024. doi:10.1038/s41598-024-65427-0',
    url: 'https://doi.org/10.1038/s41598-024-65427-0',
  );

  static const all = [
    who2003,
    medlineDiff,
    medlineEncyDiff,
    nciDictionary,
    gulati2013,
    susman2021,
    oskarsson2022,
    zhao2024,
  ];
}

/// WHO 2003 qo'llanmasidagi asosiy joylar.
const whoCells = CalcRef(DiffSources.who2003, '9.10.4, Table 9.10');
const whoFilm = CalcRef(DiffSources.who2003, '9.10.3');
const whoCount = CalcRef(DiffSources.who2003, '9.13, Table 9.12');
