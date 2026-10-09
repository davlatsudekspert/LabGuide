/// "Jadvallar va algoritmlar" bo'limi manbalari.
///
/// Kitoblar (Dolgov 2009, Lyubina 1984, Sobirova 2006, Aripova 2007,
/// Najmitdinov 1998, Dadayev 2004) mualliflik huquqi bilan himoyalangan:
/// faqat manba sifatida keltiriladi, matn/jadval/rasm ko'chirilmagan, onlayn
/// manzil berilmaydi. Har bir kitob bilimi rasmiy yoki ochiq manba bilan
/// solishtirilgan; tasdiqlanmagan raqam yozilmagan.
library;

import '../tools/calc_info.dart';

abstract final class RefSources {
  // ── Kitoblar (faqat iqtibos) ──
  static const dolgov2009 = CalcSource(
    id: 'book-dolgov-2009',
    citation:
        'Долгов В.В., Луговская С.А., Морозова В.Т., Почтарь М.Е. '
        'Лабораторная диагностика анемий. 2-е изд. Москва–Тверь: Триада; 2009',
    url: null,
  );
  static const lyubina1984 = CalcSource(
    id: 'book-lyubina-1984',
    citation:
        'Любина А.Я., Ильичева Л.П., Катасонова Т.В., Петросова С.А. '
        'Клинические лабораторные исследования. Москва: Медицина; 1984',
    url: null,
  );
  static const sobirova2006 = CalcSource(
    id: 'book-sobirova-2006',
    citation:
        'Sobirova R.A., Abrorov O.A., Inoyatova F.X., Aripov A.N. '
        'Biologik kimyo. Toshkent: Yangi asr avlodi; 2006',
    url: null,
  );
  static const aripova2007 = CalcSource(
    id: 'book-aripova-2007',
    citation:
        'Aripova G.S., Po‘latova F.G., Nazarova N.S., Toirova Z.S. Klinik va '
        'biokimyoviy tekshiruv usullari. Toshkent: G‘afur G‘ulom NMIU; 2007',
    url: null,
  );
  static const najmitdinov1998 = CalcSource(
    id: 'book-najmitdinov-1998',
    citation:
        'Наджимитдинов С.Т. Клиник гематология асослари. Тошкент: Абу Али '
        'ибн Сино номидаги тиббиёт нашриёти; 1998',
    url: null,
  );
  static const dadayev2004 = CalcSource(
    id: 'book-dadayev-2004',
    citation: 'Дадаев С. Паразитология. Тошкент: ТДПУ; 2004',
    url: null,
  );

  // ── Rasmiy va ochiq manbalar ──
  static const who2003 = CalcSource(
    id: 'who-basic-lab-techniques-2003',
    citation:
        'World Health Organization. Manual of basic techniques for a health '
        'laboratory, 2nd ed. Geneva: WHO; 2003',
    url: 'https://www.who.int/publications/i/item/9241545305',
  );
  static const whoFerritin2020 = CalcSource(
    id: 'who-ferritin-2020',
    citation:
        'World Health Organization. WHO guideline on use of ferritin '
        'concentrations to assess iron status in individuals and populations. '
        'Geneva: WHO; 2020',
    url: 'https://www.who.int/publications/i/item/9789240000124',
  );
  static const whoHb2024 = CalcSource(
    id: 'who-hb-cutoffs-2024',
    citation:
        'World Health Organization. Guideline on haemoglobin cutoffs to '
        'define anaemia in individuals and populations. Geneva: WHO; 2024',
    url: 'https://www.who.int/publications/i/item/9789240088542',
  );
  static const whoMercury = CalcSource(
    id: 'who-mercury-health',
    citation: 'World Health Organization. Mercury and health. Fact sheet; 2024',
    url: 'https://www.who.int/news-room/fact-sheets/detail/mercury-and-health',
  );
  static const nhlbiAnemiaDx = CalcSource(
    id: 'nhlbi-anemia-dx',
    citation: 'NHLBI. Anemia — Diagnosis. National Institutes of Health',
    url: 'https://www.nhlbi.nih.gov/health/anemia/diagnosis',
  );
  static const medlineMcv = CalcSource(
    id: 'medline-mcv',
    citation: 'MedlinePlus. MCV (Mean Corpuscular Volume). NLM',
    url: 'https://medlineplus.gov/lab-tests/mcv-mean-corpuscular-volume/',
  );
  static const medlineRetic = CalcSource(
    id: 'medline-reticulocyte',
    citation: 'MedlinePlus. Reticulocyte Count. NLM',
    url: 'https://medlineplus.gov/lab-tests/reticulocyte-count/',
  );
  static const medlineHapto = CalcSource(
    id: 'medline-haptoglobin',
    citation: 'MedlinePlus. Haptoglobin (HP) Test. NLM',
    url: 'https://medlineplus.gov/lab-tests/haptoglobin-hp-test/',
  );
  static const medlineLft = CalcSource(
    id: 'medline-liver-function',
    citation: 'MedlinePlus. Liver Function Tests. NLM',
    url: 'https://medlineplus.gov/lab-tests/liver-function-tests/',
  );
  static const medlineGgt = CalcSource(
    id: 'medline-ggt',
    citation: 'MedlinePlus. Gamma-glutamyl Transferase (GGT) Test. NLM',
    url: 'https://medlineplus.gov/lab-tests/gamma-glutamyl-transferase-ggt-test/',
  );
  static const medlineUrineBili = CalcSource(
    id: 'medline-bilirubin-urine',
    citation: 'MedlinePlus. Bilirubin in Urine. NLM',
    url: 'https://medlineplus.gov/lab-tests/bilirubin-in-urine/',
  );
  static const medlineUrobil = CalcSource(
    id: 'medline-urobilinogen-urine',
    citation: 'MedlinePlus. Urobilinogen in Urine. NLM',
    url: 'https://medlineplus.gov/lab-tests/urobilinogen-in-urine/',
  );
  static const medlinePaleStools = CalcSource(
    id: 'medline-ency-pale-stools',
    citation: 'MedlinePlus Medical Encyclopedia. Stools — pale or clay-colored',
    url: 'https://medlineplus.gov/ency/article/003129.htm',
  );
  static const medlineJaundice = CalcSource(
    id: 'medline-ency-jaundice-causes',
    citation: 'MedlinePlus Medical Encyclopedia. Jaundice causes',
    url: 'https://medlineplus.gov/ency/article/007491.htm',
  );
  static const medlineFobt = CalcSource(
    id: 'medline-fobt',
    citation: 'MedlinePlus. Fecal Occult Blood Test (FOBT). NLM',
    url: 'https://medlineplus.gov/lab-tests/fecal-occult-blood-test-fobt/',
  );
  static const cdcStoolProc = CalcSource(
    id: 'cdc-dpdx-stool-processing',
    citation: 'CDC DPDx. Stool Specimens — Specimen Processing',
    url:
        'https://www.cdc.gov/dpdx/diagnosticprocedures/stool/specimenproc.html',
  );
  static const cdcStoolCollect = CalcSource(
    id: 'cdc-dpdx-stool-collection',
    citation: 'CDC DPDx. Stool Specimens — Specimen Collection',
    url:
        'https://www.cdc.gov/dpdx/diagnosticprocedures/stool/specimencoll.html',
  );
  static const cdcPinworm = CalcSource(
    id: 'cdc-pinworm-diagnosing',
    citation: 'CDC. Diagnosing Pinworm',
    url: 'https://www.cdc.gov/pinworm/diagnosing/index.html',
  );
  static const takami2026 = CalcSource(
    id: 'takami-2026-cbc',
    citation:
        'Takami A. How to Interpret the Complete Blood Count in Daily '
        'Practice. JMA J. 2026. doi:10.31662/jmaj.2026-0173',
    url: 'https://doi.org/10.31662/jmaj.2026-0173',
  );
  static const barcellini2015 = CalcSource(
    id: 'barcellini-2015-hemolysis',
    citation:
        'Barcellini W, Fattizzo B. Clinical applications of hemolytic markers '
        'in the differential diagnosis and management of hemolytic anemia. '
        'Dis Markers. 2015. doi:10.1155/2015/635670',
    url: 'https://doi.org/10.1155/2015/635670',
  );
  static const kwo2017 = CalcSource(
    id: 'kwo-2017-acg-liver',
    citation:
        'Kwo PY, Cohen SM, Lim JK. ACG Clinical Guideline: Evaluation of '
        'Abnormal Liver Chemistries. Am J Gastroenterol. 2017. '
        'doi:10.1038/ajg.2016.517',
    url: 'https://doi.org/10.1038/ajg.2016.517',
  );
  static const fargo2017 = CalcSource(
    id: 'fargo-2017-jaundice',
    citation:
        'Fargo MV, Grogan SP, Saguil A. Evaluation of Jaundice in Adults. '
        'Am Fam Physician. 2017 (PubMed 28145671)',
    url: 'https://pubmed.ncbi.nlm.nih.gov/28145671/',
  );
  static const williams1988 = CalcSource(
    id: 'williams-1988-ast-alt',
    citation:
        'Williams AL, Hoofnagle JH. Ratio of serum aspartate to alanine '
        'aminotransferase in chronic hepatitis. Gastroenterology. 1988. '
        'doi:10.1016/s0016-5085(88)80022-2',
    url: 'https://doi.org/10.1016/s0016-5085(88)80022-2',
  );
  static const kratz2017 = CalcSource(
    id: 'kratz-2017-icsh-esr',
    citation:
        'Kratz A, et al. ICSH recommendations for modified and alternate '
        'methods measuring the erythrocyte sedimentation rate. Int J Lab '
        'Hematol. 2017. doi:10.1111/ijlh.12693',
    url: 'https://doi.org/10.1111/ijlh.12693',
  );
  static const ifcc2002 = CalcSource(
    id: 'ifcc-2002-enzymes',
    citation:
        'IFCC primary reference procedures for the measurement of catalytic '
        'activity concentrations of enzymes at 37 °C (Parts 4–7). Clin Chem '
        'Lab Med. 2002. doi:10.1515/CCLM.2002.127',
    url: 'https://doi.org/10.1515/CCLM.2002.127',
  );
}
