/// Gistologiya: asosiy to'qimalar (epiteliy, biriktiruvchi, muskul, nerv) va
/// M2 modulidagi a'zolar (jigar, buyrak) — rasmli qo'llanma, bo'yash usullari
/// va "Bu qaysi to'qima?" mashqi (3 tilda).
///
/// Har da'vo — manba va joy bilan ([HistoFact], [CalcRef]); manbada yo'q narsa
/// yozilmaydi. Rasmlar — Wikimedia Commons'dagi erkin litsenziyali mikrofotolar:
/// litsenziya, muallif va asl izoh fayl sahifasidan tekshirilgan
/// ([histoCheckedAt]); faqat kichraytirilgan (tool/histology_images.py).
/// Bo'yoq faqat fayl sahifasida yozilgan bo'lsa ko'rsatiladi. Kontent
/// mutaxassis tekshiruvidan o'tmagan — ekranda "qoralama" belgisi (sitologiya,
/// spermogramma kabi). Manbalar jadvali: docs/HISTOLOGY_SOURCES.md.
library;

import '../content/content_model.dart';
import '../tools/calc_info.dart';

typedef _T = LocalizedText;

/// Rasm litsenziyasi va izohi tekshirilgan sana.
const histoCheckedAt = '2026-10-17';

abstract final class HistoSources {
  static const umich = CalcSource(
    id: 'histo-umich-lab-manual',
    citation:
        'Hortsch M, et al. University of Michigan Histology Laboratory '
        'Manual. University of Michigan Medical School, 2025 '
        '(CC BY-NC-SA 4.0)',
    url: 'https://histology.medicine.umich.edu/',
  );
  static const hpaLiver = CalcSource(
    id: 'histo-hpa-liver',
    citation: 'The Human Protein Atlas. Dictionary — Normal tissue: Liver',
    url: 'https://www.proteinatlas.org/learn/dictionary/normal/liver',
  );
  static const hpaKidney = CalcSource(
    id: 'histo-hpa-kidney',
    citation: 'The Human Protein Atlas. Dictionary — Normal tissue: Kidney',
    url: 'https://www.proteinatlas.org/learn/dictionary/normal/kidney',
  );
  static const hpaAdipose = CalcSource(
    id: 'histo-hpa-adipose',
    citation:
        'The Human Protein Atlas. Dictionary — Normal tissue: Adipose tissue',
    url: 'https://www.proteinatlas.org/learn/dictionary/normal/adipose+tissue',
  );
  static const hpaSkeletal = CalcSource(
    id: 'histo-hpa-skeletal-muscle',
    citation:
        'The Human Protein Atlas. Dictionary — Normal tissue: Skeletal muscle',
    url: 'https://www.proteinatlas.org/learn/dictionary/normal/skeletal+muscle',
  );
  static const hpaHeart = CalcSource(
    id: 'histo-hpa-heart-muscle',
    citation:
        'The Human Protein Atlas. Dictionary — Normal tissue: Heart muscle',
    url: 'https://www.proteinatlas.org/learn/dictionary/normal/heart+muscle',
  );
  static const hpaSmooth = CalcSource(
    id: 'histo-hpa-smooth-muscle',
    citation:
        'The Human Protein Atlas. Dictionary — Normal tissue: Smooth muscle',
    url: 'https://www.proteinatlas.org/learn/dictionary/normal/smooth+muscle',
  );
  static const boyd2020 = CalcSource(
    id: 'histo-boyd-2020-liver-biopsy',
    citation:
        'Boyd A, Cain O, Chauhan A, Webb GJ. Medical liver biopsy: '
        'background, indications, procedure and histopathology. Frontline '
        'Gastroenterol. 2020. doi:10.1136/flgastro-2018-101139',
    url: 'https://doi.org/10.1136/flgastro-2018-101139',
  );

  /// Rasm izohlari (preparat turi, bo'yoq, kattalashtirish) — fayl
  /// sahifalari; lokator — fayl nomi.
  static const commonsFiles = CalcSource(
    id: 'histo-commons-file-pages',
    citation:
        'Wikimedia Commons — file description pages of the pictures used '
        '(checked $histoCheckedAt)',
    url: 'https://commons.wikimedia.org/',
  );

  /// O'zbek tilidagi o'quv qo'llanma — o'zbekcha gistologik atamalar
  /// manbasi (tibbiy ko'rik 2026-10-18; PDF matni bet raqami bilan o'qildi).
  static const zokirova2025 = CalcSource(
    id: 'histo-zokirova-2025',
    citation:
        'Zokirova N.B. Gistologiya asoslari. O‘quv qo‘llanma. Toshkent: '
        'Tibbiyot nashriyoti matbaa uyi; 2025. ISBN 978-9910-02-646-1',
    url:
        'https://portfolio.afu.uz/storage/documents/'
        'c3SFUAvuBlXdjJHGkYTXuB4eVmkn3FguZZqvHpPk.pdf',
  );

  static const all = [
    umich,
    zokirova2025,
    hpaLiver,
    hpaKidney,
    hpaAdipose,
    hpaSkeletal,
    hpaHeart,
    hpaSmooth,
    boyd2020,
    commonsFiles,
  ];
}

const _hpaLiver = CalcRef(HistoSources.hpaLiver, 'Normal tissue — Liver');
const _hpaKidney = CalcRef(HistoSources.hpaKidney, 'Normal tissue — Kidney');
const _hpaAdipose = CalcRef(
  HistoSources.hpaAdipose,
  'Normal tissue — Adipose tissue',
);
const _hpaSkeletal = CalcRef(
  HistoSources.hpaSkeletal,
  'Normal tissue — Skeletal muscle',
);
const _hpaHeart = CalcRef(
  HistoSources.hpaHeart,
  'Normal tissue — Heart muscle',
);
const _hpaSmooth = CalcRef(
  HistoSources.hpaSmooth,
  'Normal tissue — Smooth muscle',
);
const _boydStain = CalcRef(HistoSources.boyd2020, 'Staining; Table 1');
const _boydZones = CalcRef(
  HistoSources.boyd2020,
  'Histological assessment; Figure 1; Table 2',
);

/// Bitta da'vo va uning manbalari.
class HistoFact {
  const HistoFact(this.text, this.refs);

  final LocalizedText text;
  final List<CalcRef> refs;
}

/// Wikimedia Commons rasmi: muallif, litsenziya, asl izoh.
class HistoImage {
  const HistoImage({
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
    this.labels,
  });

  /// `assets/histology/img/<file>.jpg`.
  final String file;

  /// Commons'dagi fayl nomi (`File:` siz).
  final String commonsTitle;
  final String author;
  final String license;
  final String licenseUrl;

  /// Fayl sahifasidagi izoh, so'zma-so'z (inglizcha).
  final String caption;

  /// Izohning LabGuide tarjimasi.
  final LocalizedText captionTr;

  /// Bo'yoq — faqat fayl sahifasida yozilgan bo'lsa; aks holda `null`
  /// ("manbada ko'rsatilmagan").
  final LocalizedText? stain;

  /// Rasm ichidagi yozuvlar tarjimasi (bo'lsa).
  final LocalizedText? labels;

  /// Ilovadagi nusxa o'lchami va asl fayl o'lchami (px).
  final int width;
  final int height;
  final int originalWidth;
  final int originalHeight;

  String get asset => 'assets/histology/img/$file.jpg';

  String get sourcePage =>
      'https://commons.wikimedia.org/wiki/'
      '${Uri.encodeComponent('File:${commonsTitle.replaceAll(' ', '_')}')}';
}

enum HistoGroup { epithelium, connective, muscle, nerve, organ }

class HistoItem {
  const HistoItem({
    required this.id,
    required this.group,
    required this.name,
    required this.image,
    required this.look,
    required this.key,
    required this.function,
    this.where,
    this.confuse,
    this.imageNote,
    this.quiz = true,
  });

  final String id;
  final HistoGroup group;
  final LocalizedText name;

  /// `null` — erkin litsenziyali, aniq belgilangan rasm topilmagan
  /// ("rasm hozircha yo'q").
  final HistoImage? image;

  /// "Nimani ko'rasiz" — mikroskopdagi belgilar.
  final List<HistoFact> look;

  /// Eng tez farqlovchi belgi.
  final HistoFact key;

  /// Vazifasi (bir qator).
  final HistoFact function;
  final HistoFact? where;

  /// Nima bilan adashtiriladi (manbada aytilgan bo'lsa).
  final HistoFact? confuse;

  /// Rasm haqida qo'shimcha (preparat turi va h.k.).
  final HistoFact? imageNote;

  /// "Bu qaysi to'qima?" mashqiga kiradimi (rasm belgilar uchun yetarlicha
  /// aniq bo'lsa).
  final bool quiz;

  /// Kartadagi barcha manbalar, takrorsiz (tartib bilan).
  List<CalcRef> get refs {
    final seen = <String>{};
    return [
      for (final f in facts)
        for (final r in f.refs)
          if (seen.add('${r.source.id}|${r.locator}')) r,
    ];
  }

  List<HistoFact> get facts => [
    ...look,
    key,
    function,
    ?where,
    ?confuse,
    ?imageNote,
  ];
}

// ───────────────────────── Rasmlar ─────────────────────────

const _berkshire = 'Berkshire Community College Bioscience Image Library';
const _cc0 = 'CC0 1.0';
const _cc0Url = 'https://creativecommons.org/publicdomain/zero/1.0/';

const _imgSimpleSquamous = HistoImage(
  file: 'simple_squamous',
  commonsTitle:
      'Epithelial Tissues Simple Squamous Epithelium (41722161021).jpg',
  author: _berkshire,
  license: _cc0,
  licenseUrl: _cc0Url,
  caption: 'whole mount: human epithelium; magnification: 200x',
  captionTr: _T({
    'uz':
        'Yaxlit preparat (whole mount): odam epiteliysi; kattalashtirish 200x',
    'ru':
        'Тотальный препарат (whole mount): эпителий человека; увеличение 200x',
    'en': 'Whole mount: human epithelium; magnification 200x',
  }),
  width: 900,
  height: 507,
  originalWidth: 3264,
  originalHeight: 1840,
);

const _imgSimpleCuboidal = HistoImage(
  file: 'simple_cuboidal',
  commonsTitle:
      'Epithelial Tissues Simple Cuboidal Epithelium (41681552432).jpg',
  author: _berkshire,
  license: _cc0,
  licenseUrl: _cc0Url,
  caption: 'cross section: kidney tubule; magnification: 200x',
  captionTr: _T({
    'uz': 'Ko‘ndalang kesma: buyrak kanalchasi; kattalashtirish 200x',
    'ru': 'Поперечный срез: почечный каналец; увеличение 200x',
    'en': 'Cross section: kidney tubule; magnification 200x',
  }),
  width: 900,
  height: 507,
  originalWidth: 3264,
  originalHeight: 1840,
);

const _imgSimpleColumnar = HistoImage(
  file: 'simple_columnar',
  commonsTitle:
      'Epithelial Tissues Simple Columnar Epithelium (27854453538).jpg',
  author: _berkshire,
  license: _cc0,
  licenseUrl: _cc0Url,
  caption: 'cross section: mammalian gut; magnification: 400x',
  captionTr: _T({
    'uz': 'Ko‘ndalang kesma: sutemizuvchi ichagi; kattalashtirish 400x',
    'ru': 'Поперечный срез: кишка млекопитающего; увеличение 400x',
    'en': 'Cross section: mammalian gut; magnification 400x',
  }),
  width: 900,
  height: 507,
  originalWidth: 3264,
  originalHeight: 1840,
);

const _imgPseudostratified = HistoImage(
  file: 'pseudostratified',
  commonsTitle:
      'Epithelial Tissues Pseudostratified Columnar Epithelium '
      '(26915091897).jpg',
  author: _berkshire,
  license: _cc0,
  licenseUrl: _cc0Url,
  caption: 'cross section: mammalian trachea; magnification: 200x',
  captionTr: _T({
    'uz': 'Ko‘ndalang kesma: sutemizuvchi traxeyasi; kattalashtirish 200x',
    'ru': 'Поперечный срез: трахея млекопитающего; увеличение 200x',
    'en': 'Cross section: mammalian trachea; magnification 200x',
  }),
  width: 900,
  height: 507,
  originalWidth: 3264,
  originalHeight: 1840,
);

const _imgStratifiedSquamous = HistoImage(
  file: 'stratified_squamous',
  commonsTitle:
      'Epithelial Tissues Stratified Squamous Epithelium (40230837610).jpg',
  author: _berkshire,
  license: _cc0,
  licenseUrl: _cc0Url,
  caption: 'cross section: stratified squamous epithelium; magnification: 100x',
  captionTr: _T({
    'uz': 'Ko‘ndalang kesma: ko‘p qavatli yassi epiteliy; kattalashtirish 100x',
    'ru': 'Поперечный срез: многослойный плоский эпителий; увеличение 100x',
    'en': 'Cross section: stratified squamous epithelium; magnification 100x',
  }),
  width: 900,
  height: 507,
  originalWidth: 3264,
  originalHeight: 1840,
);

const _imgTransitional = HistoImage(
  file: 'transitional',
  commonsTitle: 'Epithelial Tissues Transitional (27025225607).jpg',
  author: _berkshire,
  license: _cc0,
  licenseUrl: _cc0Url,
  caption: 'cross section: urinary bladder; magnification: 400x',
  captionTr: _T({
    'uz': 'Ko‘ndalang kesma: siydik pufagi (qovuq); kattalashtirish 400x',
    'ru': 'Поперечный срез: мочевой пузырь; увеличение 400x',
    'en': 'Cross section: urinary bladder; magnification 400x',
  }),
  width: 900,
  height: 507,
  originalWidth: 3264,
  originalHeight: 1840,
);

const _imgLooseCt = HistoImage(
  file: 'loose_ct',
  commonsTitle: 'Connective Tissue Loose Aerolar (41743648512).jpg',
  author: _berkshire,
  license: _cc0,
  licenseUrl: _cc0Url,
  caption: 'tissue spread; magnification: 100x',
  captionTr: _T({
    'uz': 'To‘qima yoyilmasi (kesma emas); kattalashtirish 100x',
    'ru': 'Плёночный препарат (не срез); увеличение 100x',
    'en': 'Tissue spread (not a section); magnification 100x',
  }),
  width: 900,
  height: 507,
  originalWidth: 3264,
  originalHeight: 1840,
);

const _imgDenseRegular = HistoImage(
  file: 'dense_regular',
  commonsTitle: 'Connective Tissue White Fibrous Connective (27986735128).jpg',
  author: _berkshire,
  license: _cc0,
  licenseUrl: _cc0Url,
  caption: 'long section: tendon; magnification: 100x',
  captionTr: _T({
    'uz': 'Bo‘ylama kesma: pay; kattalashtirish 100x',
    'ru': 'Продольный срез: сухожилие; увеличение 100x',
    'en': 'Longitudinal section: tendon; magnification 100x',
  }),
  width: 900,
  height: 507,
  originalWidth: 3264,
  originalHeight: 1840,
);

const _imgAdipose = HistoImage(
  file: 'adipose',
  commonsTitle: 'Connective Tissues Adipose (26915768737).jpg',
  author: _berkshire,
  license: _cc0,
  licenseUrl: _cc0Url,
  caption: 'cross section; magnification: 200x',
  captionTr: _T({
    'uz': 'Ko‘ndalang kesma; kattalashtirish 200x',
    'ru': 'Поперечный срез; увеличение 200x',
    'en': 'Cross section; magnification 200x',
  }),
  width: 900,
  height: 507,
  originalWidth: 3264,
  originalHeight: 1840,
);

const _imgHyaline = HistoImage(
  file: 'hyaline',
  commonsTitle: 'Connective Tissue Hyaline Cartilage (26989336187).jpg',
  author: _berkshire,
  license: _cc0,
  licenseUrl: _cc0Url,
  caption: 'cross section: hyaline cartilage; magnification: 200x',
  captionTr: _T({
    'uz': 'Ko‘ndalang kesma: gialin tog‘ay; kattalashtirish 200x',
    'ru': 'Поперечный срез: гиалиновый хрящ; увеличение 200x',
    'en': 'Cross section: hyaline cartilage; magnification 200x',
  }),
  width: 900,
  height: 507,
  originalWidth: 3264,
  originalHeight: 1840,
);

const _imgElastic = HistoImage(
  file: 'elastic_cartilage',
  commonsTitle: 'Connective Tissue Elastic Cartilage (41855666011).jpg',
  author: _berkshire,
  license: _cc0,
  licenseUrl: _cc0Url,
  caption: 'cross section: mammalian elastic cartilage; magnification: 100x',
  captionTr: _T({
    'uz':
        'Ko‘ndalang kesma: sutemizuvchi elastik tog‘ayi; kattalashtirish 100x',
    'ru': 'Поперечный срез: эластический хрящ млекопитающего; увеличение 100x',
    'en': 'Cross section: mammalian elastic cartilage; magnification 100x',
  }),
  width: 900,
  height: 507,
  originalWidth: 3264,
  originalHeight: 1840,
);

const _imgFibrocartilage = HistoImage(
  file: 'fibrocartilage',
  commonsTitle: 'Connective Tissue Fibrocartilage (27988652098).jpg',
  author: _berkshire,
  license: _cc0,
  licenseUrl: _cc0Url,
  caption: 'cross section: fibrocartilage; magnification: 400x',
  captionTr: _T({
    'uz': 'Ko‘ndalang kesma: tolali tog‘ay; kattalashtirish 400x',
    'ru': 'Поперечный срез: волокнистый хрящ; увеличение 400x',
    'en': 'Cross section: fibrocartilage; magnification 400x',
  }),
  width: 900,
  height: 507,
  originalWidth: 3264,
  originalHeight: 1840,
);

const _imgBone = HistoImage(
  file: 'bone',
  commonsTitle: 'Connective Tissue Compact Bone (41068142774).jpg',
  author: _berkshire,
  license: _cc0,
  licenseUrl: _cc0Url,
  caption: 'cross section: ground human bone; magnification: 200x',
  captionTr: _T({
    'uz':
        'Ko‘ndalang kesma: odam suyagining shliflangan (ground) preparati; '
        'kattalashtirish 200x',
    'ru': 'Поперечный срез: шлиф кости человека; увеличение 200x',
    'en': 'Cross section: ground human bone; magnification 200x',
  }),
  width: 900,
  height: 507,
  originalWidth: 3264,
  originalHeight: 1840,
);

const _imgSkeletal = HistoImage(
  file: 'skeletal',
  commonsTitle: 'Muscle Tissue Skeletal Muscle Fibers (40153601630).jpg',
  author: _berkshire,
  license: _cc0,
  licenseUrl: _cc0Url,
  caption: 'Cross section: teased skeletal muscle; magnification: 200x',
  captionTr: _T({
    'uz': 'Skelet muskuli tolalari (ajratilgan, teased); kattalashtirish 200x',
    'ru': 'Волокна скелетной мышцы (расщеплённые, teased); увеличение 200x',
    'en': 'Teased skeletal muscle fibres; magnification 200x',
  }),
  width: 900,
  height: 507,
  originalWidth: 3264,
  originalHeight: 1840,
);

const _imgCardiac = HistoImage(
  file: 'cardiac',
  commonsTitle: 'Cardiac muscle histology 400x.jpg',
  author: 'Alexander G. Cheroske',
  license: 'CC BY-SA 4.0',
  licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0/',
  caption:
      'Photo of cardiac muscle seen in the light microscope at 400x '
      'magnification',
  captionTr: _T({
    'uz': 'Yorug‘lik mikroskopida yurak muskuli, kattalashtirish 400x',
    'ru': 'Сердечная мышца в световом микроскопе, увеличение 400x',
    'en': 'Cardiac muscle in the light microscope, magnification 400x',
  }),
  width: 900,
  height: 1200,
  originalWidth: 3072,
  originalHeight: 4096,
);

const _imgSmooth = HistoImage(
  file: 'smooth',
  commonsTitle: 'Muscle Tissue Smooth (40087100000).jpg',
  author: _berkshire,
  license: _cc0,
  licenseUrl: _cc0Url,
  caption: 'cross section: smooth muscle; magnification: 400x',
  captionTr: _T({
    'uz': 'Kesma: silliq muskul; kattalashtirish 400x',
    'ru': 'Срез: гладкая мышечная ткань; увеличение 400x',
    'en': 'Section: smooth muscle; magnification 400x',
  }),
  width: 900,
  height: 507,
  originalWidth: 3264,
  originalHeight: 1840,
);

const _imgNeuron = HistoImage(
  file: 'neuron',
  commonsTitle: 'Nervous Tissue Spinal Cord Motor Neuron (41850850452).jpg',
  author: _berkshire,
  license: _cc0,
  licenseUrl: _cc0Url,
  caption: 'smear: spinal cord; magnification: 200x',
  captionTr: _T({
    'uz': 'Surtma: orqa miya (motor neyron); kattalashtirish 200x',
    'ru': 'Мазок: спинной мозг (мотонейрон); увеличение 200x',
    'en': 'Smear: spinal cord (motor neuron); magnification 200x',
  }),
  width: 900,
  height: 507,
  originalWidth: 3264,
  originalHeight: 1840,
);

const _imgNerve = HistoImage(
  file: 'nerve',
  commonsTitle: 'Nervous Tissue Nerve Bundle (40106758860).jpg',
  author: _berkshire,
  license: _cc0,
  licenseUrl: _cc0Url,
  caption: 'cross section: nerve; magnification: 100x',
  captionTr: _T({
    'uz': 'Ko‘ndalang kesma: nerv; kattalashtirish 100x',
    'ru': 'Поперечный срез: нерв; увеличение 100x',
    'en': 'Cross section: nerve; magnification 100x',
  }),
  width: 900,
  height: 507,
  originalWidth: 3264,
  originalHeight: 1840,
);

const _imgLiver = HistoImage(
  file: 'liver',
  commonsTitle: 'Histopathology of liver zones.jpg',
  author: 'Alexander Boyd, Owen Cain, Abhishek Chauhan, Gwilym James Webb',
  license: 'CC BY 4.0',
  licenseUrl: 'https://creativecommons.org/licenses/by/4.0/',
  caption:
      'Reticulin stain showing normal liver parenchyma with a portal tract in '
      'the top left of the image (P) and a central vein in the bottom right '
      '(V). Zones 1–3 are labelled.',
  captionTr: _T({
    'uz':
        'Retikulin bo‘yog‘i: normal jigar to‘qimasi; yuqori chapda portal '
        'yo‘l, pastki o‘ngda markaziy vena; 1–3-zonalar belgilangan.',
    'ru':
        'Окраска на ретикулин: нормальная паренхима печени; вверху слева — '
        'портальный тракт, внизу справа — центральная вена; отмечены зоны 1–3.',
    'en':
        'Reticulin stain: normal liver parenchyma; portal tract top left, '
        'central vein bottom right; zones 1–3 labelled.',
  }),
  stain: _T({
    'uz': 'Retikulin (kumush bilan)',
    'ru': 'Ретикулин (импрегнация серебром)',
    'en': 'Reticulin (silver)',
  }),
  labels: _T({
    'uz':
        'Rasmdagi yozuvlar: “Portal triad” — portal yo‘l (triada); '
        '“Zone 1, 2, 3” — 1, 2, 3-zonalar; “Central vein” — markaziy vena.',
    'ru':
        'Подписи на рисунке: «Portal triad» — портальный тракт (триада); '
        '«Zone 1, 2, 3» — зоны 1, 2, 3; «Central vein» — центральная вена.',
    'en':
        'Labels in the image: “Portal triad”, “Zone 1, 2, 3”, '
        '“Central vein”.',
  }),
  width: 900,
  height: 748,
  originalWidth: 1151,
  originalHeight: 957,
);

const _imgKidney = HistoImage(
  file: 'kidney',
  commonsTitle: 'Benign kidney -- intermed mag.jpg',
  author: 'Nephron (Wikimedia Commons)',
  license: 'CC BY-SA 3.0',
  licenseUrl: 'https://creativecommons.org/licenses/by-sa/3.0/',
  caption:
      'Micrograph showing benign kidney on a (missed) kidney biopsy. '
      'H&E stain.',
  captionTr: _T({
    'uz':
        'Buyrak biopsiyasidagi o‘zgarmagan (xavfsiz) buyrak to‘qimasi. '
        'Bo‘yoq: gematoksilin-eozin.',
    'ru':
        'Неизменённая (доброкачественная) ткань почки в биоптате. Окраска '
        'гематоксилином и эозином.',
    'en': 'Benign kidney tissue on a kidney biopsy. H&E stain.',
  }),
  stain: _T({
    'uz': 'Gematoksilin-eozin (H&E)',
    'ru': 'Гематоксилин-эозин (H&E)',
    'en': 'Haematoxylin and eosin (H&E)',
  }),
  width: 900,
  height: 600,
  originalWidth: 4272,
  originalHeight: 2848,
);

/// "Bo'yash usullari" sahifasidagi PAS namunasi (to'qima kartasi emas).
const histoPasImage = HistoImage(
  file: 'stain_pas',
  commonsTitle: 'Renal corpuscle.jpg',
  author: 'Ed Uthman',
  license: 'CC BY-SA 2.0',
  licenseUrl: 'https://creativecommons.org/licenses/by-sa/2.0/',
  caption:
      'Renal corpuscle (Glomerulus), Periodic Acid-Schiff Stain (PAS). The PAS '
      'stain lights up basement membranes, so it’s very nice for appreciating '
      'the skeleton of the glomerulus of the kidney.',
  captionTr: _T({
    'uz':
        'Buyrak tanachasi (koptokcha), PAS bo‘yog‘i. PAS bazal membranalarni '
        'yorqin ko‘rsatadi — koptokcha “skeleti” yaxshi ko‘rinadi.',
    'ru':
        'Почечное тельце (клубочек), ШИК-реакция (PAS). PAS выявляет базальные '
        'мембраны — хорошо виден «каркас» клубочка.',
    'en':
        'Renal corpuscle (glomerulus), PAS stain. PAS highlights basement '
        'membranes, showing the “skeleton” of the glomerulus.',
  }),
  stain: _T({
    'uz': 'PAS (Shiff yodli kislota reaksiyasi)',
    'ru': 'ШИК-реакция (PAS)',
    'en': 'Periodic acid–Schiff (PAS)',
  }),
  width: 900,
  height: 699,
  originalWidth: 1546,
  originalHeight: 1201,
);

// ───────────────────────── To'qima va a'zolar ─────────────────────────

const histoItems = <HistoItem>[
  // ── Epiteliy ──
  HistoItem(
    id: 'simple_squamous',
    group: HistoGroup.epithelium,
    name: _T({
      'uz': 'Bir qavatli yassi epiteliy',
      'ru': 'Однослойный плоский эпителий',
      'en': 'Simple squamous epithelium',
    }),
    image: _imgSimpleSquamous,
    look: [
      HistoFact(
        _T({
          'uz': 'Bir qavat yassi hujayralar: eni bo‘yidan ancha katta.',
          'ru': 'Один слой плоских клеток: ширина намного больше высоты.',
          'en': 'One layer of flattened cells, wider than they are tall.',
        }),
        [CalcRef(HistoSources.umich, 'p. 17')],
      ),
      HistoFact(
        _T({
          'uz':
              'Kesmada sitoplazma deyarli ko‘rinmaydi: epiteliy yuza bo‘ylab '
              'yotgan yassi, cho‘zinchoq yadrolardan taniladi.',
          'ru':
              'На срезе цитоплазма почти не видна: эпителий узнают по '
              'уплощённым вытянутым ядрам, лежащим вдоль поверхности.',
          'en':
              'In section the cytoplasm is too thin to see; it is recognised '
              'by flat, elongated nuclei lining the surface.',
        }),
        [CalcRef(HistoSources.umich, 'p. 17')],
      ),
    ],
    key: HistoFact(
      _T({
        'uz': 'Juda yupqa qavat: yuzadagi yassi, cho‘zinchoq yadrolar qatori.',
        'ru': 'Очень тонкий слой: ряд плоских вытянутых ядер у поверхности.',
        'en': 'A very thin layer: a row of flat, elongated surface nuclei.',
      }),
      [CalcRef(HistoSources.umich, 'p. 17')],
    ),
    function: HistoFact(
      _T({
        'uz':
            'Qon va limfa tomirlari, yurak bo‘shliqlari (endoteliy) hamda '
            'tana bo‘shliqlari va a’zolar yuzasini (mezoteliy) qoplaydi.',
        'ru':
            'Выстилает кровеносные и лимфатические сосуды, полости сердца '
            '(эндотелий), а также полости тела и поверхность органов '
            '(мезотелий).',
        'en':
            'Lines blood and lymph vessels and heart chambers (endothelium) '
            'and body cavities and organ surfaces (mesothelium).',
      }),
      [CalcRef(HistoSources.umich, 'p. 17–18')],
    ),
    imageNote: HistoFact(
      _T({
        'uz':
            'Rasm — yaxlit (whole mount) preparat: epiteliy kesmada emas, '
            'yuzadan ko‘rinadi.',
        'ru':
            'На рисунке тотальный препарат (whole mount): эпителий виден не '
            'на срезе, а с поверхности.',
        'en':
            'The image is a whole mount: the epithelium is seen from the '
            'surface, not in section.',
      }),
      [
        CalcRef(
          HistoSources.commonsFiles,
          'File:Epithelial Tissues Simple Squamous Epithelium (41722161021).jpg',
        ),
      ],
    ),
  ),
  HistoItem(
    id: 'simple_cuboidal',
    group: HistoGroup.epithelium,
    name: _T({
      'uz': 'Bir qavatli kubsimon epiteliy',
      'ru': 'Однослойный кубический эпителий',
      'en': 'Simple cuboidal epithelium',
    }),
    image: _imgSimpleCuboidal,
    look: [
      HistoFact(
        _T({
          'uz':
              'Ko‘ndalang kesmada naycha bo‘shlig‘i atrofida bir qator hujayra '
              'halqasi.',
          'ru':
              'На поперечном срезе — кольцо из одного ряда клеток вокруг '
              'просвета канальца.',
          'en':
              'In cross section, a single ring of cells around a tubule '
              'lumen.',
        }),
        [CalcRef(HistoSources.umich, 'p. 17')],
      ),
      HistoFact(
        _T({
          'uz':
              'Buyrakda naychalar orasida boshqa to‘qima kam — qo‘shni '
              'naychalarning epiteliysi ko‘pincha yonma-yon turadi.',
          'ru':
              'В почке между канальцами мало другой ткани — эпителий соседних '
              'канальцев часто лежит вплотную.',
          'en':
              'In the kidney there is little tissue between tubules, so '
              'epithelia of neighbouring tubules often lie back to back.',
        }),
        [CalcRef(HistoSources.umich, 'p. 17')],
      ),
      HistoFact(
        _T({
          'uz': 'Yig‘uvchi naychalarda: kubsimon hujayralar, yadrosi markazda.',
          'ru':
              'В собирательных трубочках: кубические клетки с центрально '
              'расположенным ядром.',
          'en': 'In collecting ducts: cuboidal cells with central nuclei.',
        }),
        [_hpaKidney],
      ),
    ],
    key: HistoFact(
      _T({
        'uz': 'Naycha bo‘shlig‘i atrofida bir qator kubsimon hujayra.',
        'ru': 'Один ряд кубических клеток вокруг просвета канальца.',
        'en': 'One row of cuboidal cells around a tubule lumen.',
      }),
      [CalcRef(HistoSources.umich, 'p. 17')],
    ),
    function: HistoFact(
      _T({
        'uz':
            'Buyrak kanalchalarini qoplaydi; kanalchalar filtratni o‘zgartirib '
            'siydik hosil qiladi.',
        'ru':
            'Выстилает почечные канальцы; канальцы изменяют фильтрат, '
            'образуя мочу.',
        'en':
            'Lines kidney tubules, which modify the filtrate to produce '
            'urine.',
      }),
      [CalcRef(HistoSources.umich, 'p. 17, 205')],
    ),
    where: HistoFact(
      _T({
        'uz': 'Buyrak kanalchalari.',
        'ru': 'Почечные канальцы.',
        'en': 'Kidney tubules.',
      }),
      [CalcRef(HistoSources.umich, 'p. 17')],
    ),
    confuse: HistoFact(
      _T({
        'uz':
            'Bir qavatli prizmatik epiteliy — unda hujayralar baland (bo‘yi '
            'enidan katta), yadrolar asosga yaqin.',
        'ru':
            'Однослойный призматический эпителий — клетки высокие (высота '
            'больше ширины), ядра ближе к основанию.',
        'en':
            'Simple columnar epithelium — its cells are taller than wide, '
            'with nuclei near the base.',
      }),
      [CalcRef(HistoSources.umich, 'p. 16')],
    ),
  ),
  HistoItem(
    id: 'simple_columnar',
    group: HistoGroup.epithelium,
    name: _T({
      'uz': 'Bir qavatli prizmatik epiteliy',
      'ru': 'Однослойный призматический эпителий',
      'en': 'Simple columnar epithelium',
    }),
    image: _imgSimpleColumnar,
    look: [
      HistoFact(
        _T({
          'uz': 'Bir qator baland hujayra: bo‘yi enidan katta.',
          'ru': 'Один ряд высоких клеток: высота больше ширины.',
          'en': 'One row of tall cells, taller than they are wide.',
        }),
        [CalcRef(HistoSources.umich, 'p. 16')],
      ),
      HistoFact(
        _T({
          'uz': 'Yadrolar hujayra asosiga yaqin, bir qatorda.',
          'ru': 'Ядра в один ряд, ближе к основанию клеток.',
          'en': 'A single row of nuclei towards the cell bases.',
        }),
        [CalcRef(HistoSources.umich, 'p. 16')],
      ),
      HistoFact(
        _T({
          'uz':
              'Qadahsimon hujayralar — epiteliyda osilgan “pufak” kabi: '
              'uchidagi och joy — shilliq (H&E bilan bo‘yalmaydi).',
          'ru':
              'Бокаловидные клетки — как «пузырьки» в эпителии: светлая '
              'верхушка — слизь (не окрашивается H&E).',
          'en':
              'Goblet cells look like balloons in the epithelium; the clear '
              'apex is stored mucus, which does not stain with H&E.',
        }),
        [CalcRef(HistoSources.umich, 'p. 16')],
      ),
      HistoFact(
        _T({
          'uz':
              'Uchki yuzada to‘qroq chiziq — mikrovorsinkalardan iborat '
              'jiyak (“cho‘tkasimon” yoki “chiziqli” hoshiya). Manba '
              '(«jiyak»): Zokirova N.B., 2025, «Gistologiya asoslari», 12, '
              '29-b.',
          'ru':
              'На апикальной поверхности — более тёмная полоска: каёмка из '
              'микроворсинок (щёточная, или исчерченная, каёмка; узбекский '
              'термин «jiyak» — источник: Zokirova N.B., 2025, «Gistologiya '
              'asoslari», с. 12, 29).',
          'en':
              'A darker line at the apex: the microvillous (striated or '
              'brush) border (Uzbek term “jiyak” — source: Zokirova N.B., '
              '2025, “Gistologiya asoslari”, pp. 12, 29).',
        }),
        [
          CalcRef(HistoSources.umich, 'p. 16–17, 20'),
          CalcRef(HistoSources.zokirova2025, 'p. 12, 29'),
        ],
      ),
    ],
    key: HistoFact(
      _T({
        'uz':
            'Bir qator baland hujayra, asosda bir qator yadro, orada '
            'qadahsimon hujayralar.',
        'ru':
            'Один ряд высоких клеток, ядра в ряд у основания, между ними '
            'бокаловидные клетки.',
        'en':
            'One row of tall cells, one row of basal nuclei, goblet cells in '
            'between.',
      }),
      [CalcRef(HistoSources.umich, 'p. 16')],
    ),
    function: HistoFact(
      _T({
        'uz':
            'Qadahsimon hujayralar shilliq ajratadi; mikrovorsinkalar '
            'so‘rilishga yordam beradi.',
        'ru':
            'Бокаловидные клетки выделяют слизь; микроворсинки облегчают '
            'всасывание.',
        'en': 'Goblet cells secrete mucus; microvilli aid absorption.',
      }),
      [CalcRef(HistoSources.umich, 'p. 16, 24')],
    ),
    where: HistoFact(
      _T({
        'uz': 'Ingichka va yo‘g‘on ichakning ichki (shilliq) yuzasi.',
        'ru': 'Внутренняя (слизистая) поверхность тонкой и толстой кишки.',
        'en': 'The luminal (mucosal) surface of the small and large intestine.',
      }),
      [CalcRef(HistoSources.umich, 'p. 16')],
    ),
    confuse: HistoFact(
      _T({
        'uz':
            'Ko‘p qatorli epiteliy — unda yadrolar turli balandlikda yotadi. '
            'Qiya kesilgan bir qavatli epiteliyda ham yadrolar ko‘p qator '
            'ko‘rinishi mumkin.',
        'ru':
            'Многорядный эпителий — в нём ядра лежат на разных уровнях. При '
            'косом срезе и однослойный эпителий может казаться многорядным.',
        'en':
            'Pseudostratified epithelium, whose nuclei lie at various levels. '
            'A tangential cut can also make a simple epithelium look '
            'multi-rowed.',
      }),
      [CalcRef(HistoSources.umich, 'p. 16, 19')],
    ),
  ),
  HistoItem(
    id: 'pseudostratified',
    group: HistoGroup.epithelium,
    name: _T({
      'uz': 'Ko‘p qatorli kiprikli epiteliy',
      'ru': 'Многорядный реснитчатый эпителий',
      'en': 'Pseudostratified ciliated columnar epithelium',
    }),
    image: _imgPseudostratified,
    look: [
      HistoFact(
        _T({
          'uz':
              'Yadrolar turli balandlikda — epiteliy ko‘p qavatli bo‘lib '
              'ko‘rinadi.',
          'ru': 'Ядра на разных уровнях — эпителий кажется многослойным.',
          'en': 'Nuclei at various levels make the epithelium look stratified.',
        }),
        [CalcRef(HistoSources.umich, 'p. 19')],
      ),
      HistoFact(
        _T({
          'uz':
              'Aslida barcha hujayralar bazal membranaga tegib turadi; '
              'yuzaga faqat bir qismi chiqadi.',
          'ru':
              'На самом деле все клетки лежат на базальной мембране, но до '
              'поверхности доходят лишь некоторые.',
          'en':
              'In fact every cell rests on the basement membrane; only some '
              'reach the free surface.',
        }),
        [CalcRef(HistoSources.umich, 'p. 19')],
      ),
      HistoFact(
        _T({
          'uz':
              'Yuzada kipriklar (sochsimon o‘simtalar) va qadahsimon '
              'hujayralar.',
          'ru':
              'На поверхности — реснички (волосковидные выросты) и '
              'бокаловидные клетки.',
          'en':
              'Cilia (hair-like projections) and goblet cells at the surface.',
        }),
        [CalcRef(HistoSources.umich, 'p. 19')],
      ),
      HistoFact(
        _T({
          'uz': 'Epiteliy ostida bazal membrana — pushti chiziq.',
          'ru': 'Под эпителием — базальная мембрана в виде розовой линии.',
          'en': 'The basement membrane shows as a pink line at the base.',
        }),
        [CalcRef(HistoSources.umich, 'p. 19')],
      ),
    ],
    key: HistoFact(
      _T({
        'uz': 'Yadrolar turli darajada + yuzada kipriklar.',
        'ru': 'Ядра на разных уровнях + реснички на поверхности.',
        'en': 'Nuclei at different levels + surface cilia.',
      }),
      [CalcRef(HistoSources.umich, 'p. 19')],
    ),
    function: HistoFact(
      _T({
        'uz':
            'Nafas yo‘llarini qoplaydi (“nafas yo‘li epiteliysi”); qadahsimon '
            'hujayralari shilliq ajratadi.',
        'ru':
            'Выстилает дыхательные пути («респираторный эпителий»); '
            'бокаловидные клетки выделяют слизь.',
        'en':
            'Lines the respiratory tract (“respiratory epithelium”); its '
            'goblet cells secrete mucus.',
      }),
      [CalcRef(HistoSources.umich, 'p. 16, 19')],
    ),
    where: HistoFact(
      _T({
        'uz': 'Traxeya va nafas yo‘llari.',
        'ru': 'Трахея и дыхательные пути.',
        'en': 'Trachea and respiratory tract.',
      }),
      [CalcRef(HistoSources.umich, 'p. 18–19')],
    ),
    confuse: HistoFact(
      _T({
        'uz':
            'Haqiqiy ko‘p qavatli epiteliy — unda faqat eng pastki qavat '
            'bazal membranada yotadi.',
        'ru':
            'Истинный многослойный эпителий — в нём на базальной мембране '
            'лежит только нижний слой.',
        'en':
            'A truly stratified epithelium, in which only the basal layer '
            'touches the basement membrane.',
      }),
      [CalcRef(HistoSources.umich, 'p. 18–19')],
    ),
  ),
  HistoItem(
    id: 'stratified_squamous',
    group: HistoGroup.epithelium,
    name: _T({
      'uz': 'Ko‘p qavatli yassi epiteliy',
      'ru': 'Многослойный плоский эпителий',
      'en': 'Stratified squamous epithelium',
    }),
    image: _imgStratifiedSquamous,
    look: [
      HistoFact(
        _T({
          'uz':
              'Ko‘p qavat hujayra: eng ustki qavat yassi, asosdagilar '
              'kubsimon yoki past prizmatik.',
          'ru':
              'Много слоёв клеток: поверхностный слой плоский, базальные '
              'клетки кубические или низкопризматические.',
          'en':
              'Many cell layers: the outermost are flat, the basal cells '
              'cuboidal or low columnar.',
        }),
        [CalcRef(HistoSources.umich, 'p. 18')],
      ),
      HistoFact(
        _T({
          'uz':
              'Asosdagi qavat bo‘linib, epiteliyni doim yangilaydi; hujayralar '
              'yuzaga ko‘tarilib ko‘chib tushadi.',
          'ru':
              'Базальный слой делится и постоянно обновляет эпителий; клетки '
              'поднимаются к поверхности и слущиваются.',
          'en':
              'The basal layer divides to renew the epithelium; cells move up '
              'and are shed.',
        }),
        [CalcRef(HistoSources.umich, 'p. 18')],
      ),
      HistoFact(
        _T({
          'uz':
              'Muguzlanmaydigan turida yuza hujayralarda yadro bor; '
              'muguzlanuvchi turida (teri) eng ustki qavat — yadrosiz keratin.',
          'ru':
              'В неороговевающем эпителии в поверхностных клетках есть ядра; в '
              'ороговевающем (кожа) верхний слой — безъядерный кератин.',
          'en':
              'Non-keratinized: surface cells keep nuclei. Keratinized (skin): '
              'the top layer is anucleate keratin.',
        }),
        [CalcRef(HistoSources.umich, 'p. 18, 20')],
      ),
    ],
    key: HistoFact(
      _T({
        'uz': 'Ko‘p qavat; ustki hujayralar yassi.',
        'ru': 'Много слоёв; поверхностные клетки плоские.',
        'en': 'Many layers; flat cells at the surface.',
      }),
      [CalcRef(HistoSources.umich, 'p. 18')],
    ),
    function: HistoFact(
      _T({
        'uz': 'Ishqalanishga uchraydigan yuzalarni himoya qiladi.',
        'ru': 'Защищает поверхности, подверженные трению.',
        'en': 'Covers surfaces subjected to abrasion.',
      }),
      [CalcRef(HistoSources.umich, 'p. 18')],
    ),
    where: HistoFact(
      _T({
        'uz':
            'Muguzlanmaydigan — qizilo‘ngach, qin, halqum; muguzlanuvchi — '
            'teri (epidermis).',
        'ru':
            'Неороговевающий — пищевод, влагалище, глотка; ороговевающий — '
            'кожа (эпидермис).',
        'en':
            'Non-keratinized: oesophagus, vagina, pharynx. Keratinized: skin '
            '(epidermis).',
      }),
      [CalcRef(HistoSources.umich, 'p. 18, 32')],
    ),
    confuse: HistoFact(
      _T({
        'uz':
            'O‘zgaruvchan epiteliy — uning yuzasida katta gumbazsimon '
            'hujayralar bo‘ladi va u faqat siydik yo‘llarida uchraydi.',
        'ru':
            'Переходный эпителий — на поверхности крупные куполообразные '
            'клетки; встречается только в мочевых путях.',
        'en':
            'Transitional epithelium — large dome-shaped surface cells, and '
            'only in the urinary tract.',
      }),
      [CalcRef(HistoSources.umich, 'p. 19, 22')],
    ),
  ),
  HistoItem(
    id: 'transitional',
    group: HistoGroup.epithelium,
    name: _T({
      'uz': 'O‘zgaruvchan epiteliy',
      'ru': 'Переходный эпителий',
      'en': 'Transitional epithelium',
    }),
    image: _imgTransitional,
    look: [
      HistoFact(
        _T({
          'uz':
              'Nomi: o‘zbek darsligida — «o‘zgaruvchan epiteliy» (ruscha '
              '«переходный»); bazal, oraliq va yuza qavatlari bor, a’zo '
              'tarang tortilganda yupqalashadi. Manba: Zokirova N.B., 2025, '
              '«Gistologiya asoslari», Epiteliy to‘qimasi, 28–30-b.',
          'ru':
              'Название в узбекском учебнике — «o‘zgaruvchan epiteliy» '
              '(переходный эпителий); есть базальный, промежуточный и '
              'поверхностный слои, при растяжении органа эпителий '
              'истончается. Источник: Zokirova N.B., 2025, «Gistologiya '
              'asoslari», Эпителиальная ткань, с. 28–30.',
          'en':
              'Uzbek textbook name: “o‘zgaruvchan epiteliy” (transitional '
              'epithelium); it has basal, intermediate and surface layers and '
              'thins when the organ is stretched. Source: Zokirova N.B., 2025, '
              '“Gistologiya asoslari”, Epithelial tissue, pp. 28–30.',
        }),
        [CalcRef(HistoSources.zokirova2025, 'p. 28–30')],
      ),
      HistoFact(
        _T({
          'uz':
              'Ko‘p qavat; yuza hujayralari katta, ko‘pincha gumbazsimon, '
              'bo‘shliqqa bo‘rtib turadi (cho‘zilmagan holatda).',
          'ru':
              'Многослойный; поверхностные клетки крупные, часто '
              'куполообразные, выбухают в просвет (в нерастянутом состоянии).',
          'en':
              'Several layers; large, often dome-shaped surface cells bulge '
              'into the lumen (when not distended).',
        }),
        [CalcRef(HistoSources.umich, 'p. 19')],
      ),
      HistoFact(
        _T({
          'uz':
              'Cho‘zilganda yuza hujayralar yupqalashadi, qavatlar kamroq '
              'ko‘rinadi.',
          'ru':
              'При растяжении поверхностные клетки истончаются, слоёв кажется '
              'меньше.',
          'en':
              'When stretched the surface cells thin out and fewer layers are '
              'seen.',
        }),
        [CalcRef(HistoSources.umich, 'p. 19')],
      ),
    ],
    key: HistoFact(
      _T({
        'uz': 'Yuzada katta gumbazsimon hujayralar.',
        'ru': 'Крупные куполообразные клетки на поверхности.',
        'en': 'Large dome-shaped surface cells.',
      }),
      [CalcRef(HistoSources.umich, 'p. 19, 22')],
    ),
    function: HistoFact(
      _T({
        'uz':
            'Cho‘ziladi va suv hamda tuzlarni deyarli o‘tkazmaydi — qovuq '
            'to‘lganda ham to‘siq saqlanadi.',
        'ru':
            'Растягивается и практически непроницаем для воды и солей — '
            'барьер сохраняется при наполнении пузыря.',
        'en':
            'Stretches yet stays essentially impermeable to water and salts '
            'as the bladder fills.',
      }),
      [CalcRef(HistoSources.umich, 'p. 19, 208, 210')],
    ),
    where: HistoFact(
      _T({
        'uz':
            'Faqat siydik yo‘llari: buyrak kosachalari, siydik yo‘li '
            '(ureter), qovuq.',
        'ru':
            'Только мочевые пути: почечные чашечки, мочеточник, мочевой '
            'пузырь.',
        'en': 'Only the urinary tract: renal calyces, ureter, bladder.',
      }),
      [CalcRef(HistoSources.umich, 'p. 19, 208, 210')],
    ),
    confuse: HistoFact(
      _T({
        'uz':
            'Ko‘p qavatli yassi epiteliy — uning yuzasida yassi hujayralar; '
            'teri muguzlanuvchi epiteliy bilan qoplangan.',
        'ru':
            'Многослойный плоский эпителий — на поверхности плоские клетки; '
            'кожа покрыта ороговевающим эпителием.',
        'en':
            'Stratified squamous epithelium — flat surface cells; skin has '
            'the keratinizing type.',
      }),
      [CalcRef(HistoSources.umich, 'p. 18, 22')],
    ),
  ),

  // ── Biriktiruvchi to'qima ──
  HistoItem(
    id: 'loose_ct',
    group: HistoGroup.connective,
    name: _T({
      'uz': 'Siyrak tolali biriktiruvchi to‘qima',
      'ru': 'Рыхлая волокнистая соединительная ткань',
      'en': 'Loose connective tissue',
    }),
    image: _imgLooseCt,
    look: [
      HistoFact(
        _T({
          'uz':
              'Tolalar siyrak, to‘lqinsimon, yakka yoki kichik tutam bo‘lib, '
              'turli yo‘nalishda yotadi.',
          'ru':
              'Волокна редкие, извитые, лежат поодиночке или небольшими '
              'пучками в разных направлениях.',
          'en':
              'Sparse, wavy fibres, single or in small groups, running in '
              'different directions.',
        }),
        [
          CalcRef(HistoSources.umich, 'p. 26'),
          CalcRef(HistoSources.zokirova2025, 'p. 39'),
        ],
      ),
      HistoFact(
        _T({
          'uz': 'Tolalar orasi “bo‘sh” ko‘rinadi — bu asosiy (amorf) modda.',
          'ru':
              'Пространство между волокнами выглядит «пустым» — это основное '
              '(аморфное) вещество.',
          'en': 'The “empty” background between fibres is ground substance.',
        }),
        [CalcRef(HistoSources.umich, 'p. 26, 33')],
      ),
      HistoFact(
        _T({
          'uz':
              'Fibroblastlar: yakka cho‘zinchoq yadro, bir yoki ikki uchidan '
              'ingichka sitoplazma chiqadi.',
          'ru':
              'Фибробласты: одиночное вытянутое ядро, от одного или обоих '
              'полюсов отходит тонкая цитоплазма.',
          'en':
              'Fibroblasts: a solitary elongated nucleus with tapered '
              'cytoplasm at one or both poles.',
        }),
        [CalcRef(HistoSources.umich, 'p. 26')],
      ),
      HistoFact(
        _T({
          'uz':
              'Leykotsitlar, plazmatik hujayralar va makrofaglar ham '
              'uchraydi.',
          'ru':
              'Встречаются также лейкоциты, плазматические клетки и '
              'макрофаги.',
          'en':
              'White blood cells, plasma cells and macrophages are also '
              'present.',
        }),
        [CalcRef(HistoSources.umich, 'p. 26–28')],
      ),
    ],
    key: HistoFact(
      _T({
        'uz':
            'Siyrak to‘lqinsimon tolalar, ko‘p “bo‘sh” joy, orada fibroblast '
            'yadrolari.',
        'ru':
            'Редкие извитые волокна, много «пустого» места, ядра '
            'фибробластов.',
        'en':
            'Sparse wavy fibres, plenty of “empty” space, scattered '
            'fibroblast nuclei.',
      }),
      [CalcRef(HistoSources.umich, 'p. 26')],
    ),
    function: HistoFact(
      _T({
        'uz':
            'Epiteliy ostidagi tayanch qatlam; antigen kirishi mumkin bo‘lgan '
            'joylarda (ichak, nafas yo‘llari) bu yerda plazmatik hujayralar '
            'ko‘p.',
        'ru':
            'Опорный слой под эпителием; там, где возможно проникновение '
            'антигенов (кишечник, дыхательные пути), в нём много '
            'плазматических клеток.',
        'en':
            'The supporting layer beneath epithelia; where antigens may enter '
            '(gut, airways) it is rich in plasma cells.',
      }),
      [CalcRef(HistoSources.umich, 'p. 26–27')],
    ),
    where: HistoFact(
      _T({
        'uz':
            'Ichak devorining shilliq osti qavati va shilliq qavatning '
            'xususiy plastinkasi.',
        'ru':
            'Подслизистая основа кишки и собственная пластинка слизистой '
            'оболочки.',
        'en': 'The submucosa and lamina propria of the intestine.',
      }),
      [CalcRef(HistoSources.umich, 'p. 26–27')],
    ),
    confuse: HistoFact(
      _T({
        'uz':
            'Zich biriktiruvchi to‘qima — unda tolalar ustun, hujayralar kam.',
        'ru':
            'Плотная соединительная ткань — в ней преобладают волокна, '
            'клеток мало.',
        'en': 'Dense connective tissue — fibres predominate, few cells.',
      }),
      [CalcRef(HistoSources.umich, 'p. 30')],
    ),
    imageNote: HistoFact(
      _T({
        'uz': 'Rasm — to‘qima yoyilmasi (tissue spread), kesma emas.',
        'ru': 'На рисунке плёночный препарат (tissue spread), а не срез.',
        'en': 'The image is a tissue spread, not a section.',
      }),
      [
        CalcRef(
          HistoSources.commonsFiles,
          'File:Connective Tissue Loose Aerolar (41743648512).jpg',
        ),
      ],
    ),
  ),
  HistoItem(
    id: 'dense_regular',
    group: HistoGroup.connective,
    name: _T({
      'uz': 'Zich shakllangan biriktiruvchi to‘qima (pay)',
      'ru': 'Плотная оформленная соединительная ткань (сухожилие)',
      'en': 'Dense regular connective tissue (tendon)',
    }),
    image: _imgDenseRegular,
    look: [
      HistoFact(
        _T({
          'uz':
              'Kollagen tolalar zich va bir yo‘nalishda parallel yotadi '
              '(biroz to‘lqinsimon).',
          'ru':
              'Коллагеновые волокна лежат плотно и параллельно в одном '
              'направлении (слегка волнисто).',
          'en':
              'Collagen fibres packed densely and in parallel (slightly '
              'wavy).',
        }),
        [CalcRef(HistoSources.umich, 'p. 30')],
      ),
      HistoFact(
        _T({
          'uz': 'Hujayralar kam; ular asosan fibroblastlar.',
          'ru': 'Клеток мало; в основном это фибробласты.',
          'en': 'Few cells, mostly fibroblasts.',
        }),
        [CalcRef(HistoSources.umich, 'p. 30, 33')],
      ),
      HistoFact(
        _T({
          'uz':
              'Tolalar orasidagi mayda yoriqlar — tayyorlashdagi qisqarish '
              'artefakti.',
          'ru': 'Мелкие щели между волокнами — артефакт сжатия при обработке.',
          'en': 'Small cracks between fibres are shrinkage artefacts.',
        }),
        [CalcRef(HistoSources.umich, 'p. 30')],
      ),
    ],
    key: HistoFact(
      _T({
        'uz': 'Bir yo‘nalishdagi zich parallel tolalar, hujayra kam.',
        'ru': 'Плотные параллельные волокна одного направления, мало клеток.',
        'en': 'Dense parallel fibres in one direction, few cells.',
      }),
      [CalcRef(HistoSources.umich, 'p. 30')],
    ),
    function: HistoFact(
      _T({
        'uz': 'I tip kollagen cho‘zilishga mustahkamlik beradi.',
        'ru': 'Коллаген I типа обеспечивает прочность на растяжение.',
        'en': 'Type I collagen gives tensile strength.',
      }),
      [CalcRef(HistoSources.umich, 'p. 26')],
    ),
    where: HistoFact(
      _T({'uz': 'Paylar (tendonlar).', 'ru': 'Сухожилия.', 'en': 'Tendons.'}),
      [CalcRef(HistoSources.umich, 'p. 30')],
    ),
    confuse: HistoFact(
      _T({
        'uz':
            'Silliq muskul va nerv: bir xil cho‘zinchoq yadrolar to‘dasi '
            'ko‘pincha silliq muskul yoki nervdagi Shvann hujayralariniki. '
            'H&E da silliq muskul pushti va yadrosi ko‘proq, kollagen esa '
            'qizg‘ish-to‘q sariqroq.',
        'ru':
            'Гладкая мышечная ткань и нерв: скопления одинаковых вытянутых '
            'ядер обычно принадлежат гладким миоцитам или шванновским клеткам '
            'нерва. При H&E гладкая мышца розовая и богаче ядрами, коллаген '
            'красно-оранжевый.',
        'en':
            'Smooth muscle and nerve: clusters of similar elongated nuclei '
            'usually belong to smooth muscle or Schwann cells. In H&E smooth '
            'muscle is pink with more nuclei; collagen is more orange-red.',
      }),
      [CalcRef(HistoSources.umich, 'p. 26, 50')],
    ),
  ),
  HistoItem(
    id: 'adipose',
    group: HistoGroup.connective,
    name: _T({
      'uz': 'Yog‘ to‘qimasi (oq)',
      'ru': 'Жировая ткань (белая)',
      'en': 'Adipose tissue (white)',
    }),
    image: _imgAdipose,
    look: [
      HistoFact(
        _T({
          'uz':
              'Katta, “bo‘sh” ko‘rinadigan hujayralar (adipotsitlar): har '
              'birini bitta yirik lipid tomchisi to‘ldiradi.',
          'ru':
              'Крупные «пустые» на вид клетки (адипоциты): каждую заполняет '
              'одна большая липидная капля.',
          'en':
              'Large, empty-looking cells (adipocytes), each filled by a '
              'single large lipid droplet.',
        }),
        [_hpaAdipose, CalcRef(HistoSources.umich, 'p. 28')],
      ),
      HistoFact(
        _T({
          'uz': 'Sitoplazma chetga surilgan — faqat ingichka halqa ko‘rinadi.',
          'ru': 'Цитоплазма оттеснена к периферии — виден лишь тонкий ободок.',
          'en': 'Cytoplasm pushed to the edge — only a thin rim is seen.',
        }),
        [_hpaAdipose],
      ),
      HistoFact(
        _T({
          'uz':
              'Yadrosi kichik, yupqa, oval, chetda; ko‘p hujayrada kesimga '
              'tushmagani uchun ko‘rinmaydi.',
          'ru':
              'Ядро маленькое, тонкое, овальное, на периферии; во многих '
              'клетках не попадает в плоскость среза.',
          'en':
              'Small, thin, oval nucleus at the edge; in many cells it is out '
              'of the plane of section.',
        }),
        [_hpaAdipose, CalcRef(HistoSources.umich, 'p. 33')],
      ),
      HistoFact(
        _T({
          'uz':
              'Bo‘lakchalar ingichka kollagen tasmalar va mayda qon tomirlar '
              'bilan ajralgan.',
          'ru':
              'Дольки разделены тонкими коллагеновыми прослойками и мелкими '
              'сосудами.',
          'en': 'Lobules separated by thin collagen bands and small vessels.',
        }),
        [_hpaAdipose],
      ),
    ],
    key: HistoFact(
      _T({
        'uz': '“Bo‘sh” katta hujayralar to‘ri; ingichka sitoplazma halqasi.',
        'ru': 'Сеть крупных «пустых» клеток с тонким ободком цитоплазмы.',
        'en': 'A network of large empty cells with thin cytoplasmic rims.',
      }),
      [_hpaAdipose],
    ),
    function: HistoFact(
      _T({
        'uz':
            'Energiyani yog‘ sifatida saqlaydi, issiqlikni saqlaydi; '
            'gormonlar (masalan, leptin) ishlab chiqaradi.',
        'ru':
            'Запасает энергию в виде жира, обеспечивает теплоизоляцию; '
            'вырабатывает гормоны (например, лептин).',
        'en':
            'Stores energy as fat and insulates; produces hormones such as '
            'leptin.',
      }),
      [_hpaAdipose],
    ),
    where: HistoFact(
      _T({
        'uz':
            'Butun tanada, ko‘p a’zolar atrofida; masalan, ichak tutqichida '
            '(mezenteriy).',
        'ru':
            'По всему телу, вокруг большинства органов; например, в '
            'брыжейке.',
        'en': 'Throughout the body, around most organs, e.g. the mesentery.',
      }),
      [_hpaAdipose, CalcRef(HistoSources.umich, 'p. 29')],
    ),
    confuse: HistoFact(
      _T({
        'uz':
            'Qo‘ng‘ir (ko‘p tomchili) yog‘ — hujayrasida bir nechta mayda '
            'yog‘ tomchisi bo‘ladi.',
        'ru':
            'Бурая (многокапельная) жировая ткань — в клетке несколько '
            'мелких капель жира.',
        'en':
            'Brown (multilocular) fat — its cells contain several small '
            'droplets.',
      }),
      [CalcRef(HistoSources.umich, 'p. 28, 32')],
    ),
  ),
  HistoItem(
    id: 'hyaline',
    group: HistoGroup.connective,
    name: _T({
      'uz': 'Gialin tog‘ay',
      'ru': 'Гиалиновый хрящ',
      'en': 'Hyaline cartilage',
    }),
    image: _imgHyaline,
    look: [
      HistoFact(
        _T({
          'uz':
              'Ko‘p miqdorda bir xil, “shishasimon” matriks: II tip kollagen '
              'tolalari mikroskopda ko‘rinmaydi.',
          'ru':
              'Обильный однородный «стекловидный» матрикс: фибриллы '
              'коллагена II типа в световой микроскоп не видны.',
          'en':
              'Abundant, glassy (“hyaline”) matrix; its type II collagen '
              'fibrils are too small to resolve.',
        }),
        [CalcRef(HistoSources.umich, 'p. 111')],
      ),
      HistoFact(
        _T({
          'uz':
              'Xondrotsitlar bo‘shliqlarda — lakunalarda yotadi; hujayralar '
              'to‘dalari — izogen guruhlar.',
          'ru':
              'Хондроциты лежат в полостях — лакунах; группы клеток — '
              'изогенные группы.',
          'en':
              'Chondrocytes sit in spaces (lacunae); clusters of cells are '
              'isogenous groups.',
        }),
        [CalcRef(HistoSources.umich, 'p. 111')],
      ),
      HistoFact(
        _T({
          'uz':
              'Lakuna atrofidagi (hududiy) matriks bazofilroq; chetida tolali '
              'qobiq — perixondriy.',
          'ru':
              'Территориальный матрикс вокруг лакун более базофилен; снаружи — '
              'волокнистая надхрящница.',
          'en':
              'The territorial matrix around lacunae is more basophilic; a '
              'fibrous perichondrium surrounds it.',
        }),
        [CalcRef(HistoSources.umich, 'p. 111')],
      ),
    ],
    key: HistoFact(
      _T({
        'uz': 'Bir jinsli shishasimon matriks + lakunalardagi xondrotsitlar.',
        'ru': 'Однородный стекловидный матрикс + хондроциты в лакунах.',
        'en': 'Uniform glassy matrix + chondrocytes in lacunae.',
      }),
      [CalcRef(HistoSources.umich, 'p. 111')],
    ),
    function: HistoFact(
      _T({
        'uz': 'Siqilishga juda chidamli; tomirsiz to‘qima.',
        'ru': 'Очень устойчив к сжатию; бессосудистая ткань.',
        'en': 'Highly resistant to compression; avascular.',
      }),
      [CalcRef(HistoSources.umich, 'p. 113–114')],
    ),
    where: HistoFact(
      _T({
        'uz': 'Traxeya, burun to‘sig‘i.',
        'ru': 'Трахея, носовая перегородка.',
        'en': 'Trachea, nasal septum.',
      }),
      [CalcRef(HistoSources.umich, 'p. 111')],
    ),
    confuse: HistoFact(
      _T({
        'uz':
            'Elastik tog‘ay — matriksda elastik tolalar, hujayralar ko‘proq; '
            'tolali tog‘ay — matriks tolali, perixondriy yo‘q.',
        'ru':
            'Эластический хрящ — в матриксе эластические волокна, клеток '
            'больше; волокнистый хрящ — матрикс волокнистый, надхрящницы нет.',
        'en':
            'Elastic cartilage — elastic fibres, more cells; fibrocartilage — '
            'fibrous matrix, no perichondrium.',
      }),
      [CalcRef(HistoSources.umich, 'p. 112')],
    ),
  ),
  HistoItem(
    id: 'elastic_cartilage',
    group: HistoGroup.connective,
    name: _T({
      'uz': 'Elastik tog‘ay',
      'ru': 'Эластический хрящ',
      'en': 'Elastic cartilage',
    }),
    image: _imgElastic,
    look: [
      HistoFact(
        _T({
          'uz': 'Xondrotsitlar lakunalarda — gialin tog‘aydagi kabi.',
          'ru': 'Хондроциты в лакунах — как в гиалиновом хряще.',
          'en': 'Chondrocytes in lacunae, as in hyaline cartilage.',
        }),
        [CalcRef(HistoSources.umich, 'p. 112')],
      ),
      HistoFact(
        _T({
          'uz':
              'Matriksda elastik tolalar tarmog‘i; elastinga maxsus bo‘yoq '
              'bilan to‘q binafsha yoki qora ko‘rinadi.',
          'ru':
              'В матриксе сеть эластических волокон; при окраске на эластин '
              'они тёмно-фиолетовые или чёрные.',
          'en':
              'A network of elastic fibres in the matrix, dark purple or black '
              'with elastin stains.',
        }),
        [CalcRef(HistoSources.umich, 'p. 112')],
      ),
      HistoFact(
        _T({
          'uz': 'Gialin tog‘aydan ko‘ra hujayralar ko‘proq.',
          'ru': 'Клеток больше, чем в гиалиновом хряще.',
          'en': 'More cellular than hyaline cartilage.',
        }),
        [CalcRef(HistoSources.umich, 'p. 112')],
      ),
    ],
    key: HistoFact(
      _T({
        'uz': 'Lakunalar + matriksdagi elastik tolalar to‘ri.',
        'ru': 'Лакуны + сеть эластических волокон в матриксе.',
        'en': 'Lacunae + a network of elastic fibres in the matrix.',
      }),
      [CalcRef(HistoSources.umich, 'p. 112')],
    ),
    function: HistoFact(
      _T({
        'uz':
            'Quloq suprasi va hiqildoq usti tog‘ayi (epiglottis) asosini '
            'hosil qiladi; tarkibi — II tip kollagen va elastik tolalar.',
        'ru':
            'Образует основу ушной раковины и надгортанника; состав — коллаген '
            'II типа и эластические волокна.',
        'en':
            'Forms the cartilage of the ear pinna and epiglottis; contains '
            'type II collagen and elastic fibres.',
      }),
      [CalcRef(HistoSources.umich, 'p. 112–114')],
    ),
    confuse: HistoFact(
      _T({
        'uz':
            'Gialin tog‘ay. Elastik tog‘ayni ishonchli ajratish uchun '
            'elastinga maxsus bo‘yoq kerak.',
        'ru':
            'Гиалиновый хрящ. Для уверенного распознавания эластического '
            'хряща нужна окраска на эластин.',
        'en':
            'Hyaline cartilage. Elastic cartilage is only convincingly '
            'identified with an elastin stain.',
      }),
      [CalcRef(HistoSources.umich, 'p. 112')],
    ),
  ),
  HistoItem(
    id: 'fibrocartilage',
    group: HistoGroup.connective,
    name: _T({
      'uz': 'Tolali tog‘ay',
      'ru': 'Волокнистый хрящ',
      'en': 'Fibrocartilage',
    }),
    image: _imgFibrocartilage,
    // Rasm nomga mos, lekin lakunalar unchalik aniq emas — mashqqa olinmaydi.
    quiz: false,
    look: [
      HistoFact(
        _T({
          'uz':
              'Matriks tolali ko‘rinadi — II tip kollagenga qo‘shimcha I tip '
              'kollagen tolalari bor.',
          'ru':
              'Матрикс выглядит волокнистым — кроме коллагена II типа есть '
              'волокна коллагена I типа.',
          'en':
              'Fibrous-looking matrix: type I collagen fibres in addition to '
              'type II.',
        }),
        [CalcRef(HistoSources.umich, 'p. 112–113')],
      ),
      HistoFact(
        _T({
          'uz': 'Xondrotsit lakunalari aniq; perixondriy yo‘q.',
          'ru': 'Лакуны хондроцитов различимы; надхрящницы нет.',
          'en': 'Distinct chondrocyte lacunae; no perichondrium.',
        }),
        [CalcRef(HistoSources.umich, 'p. 112')],
      ),
    ],
    key: HistoFact(
      _T({
        'uz': 'Tolali matriks + lakunalardagi xondrotsitlar.',
        'ru': 'Волокнистый матрикс + хондроциты в лакунах.',
        'en': 'Fibrous matrix + chondrocytes in lacunae.',
      }),
      [CalcRef(HistoSources.umich, 'p. 112')],
    ),
    function: HistoFact(
      _T({
        'uz': 'Cho‘zilishga mustahkam; odatda suyakka birikadi.',
        'ru': 'Высокая прочность на растяжение; обычно прикрепляется к кости.',
        'en': 'High tensile strength; usually inserts into bone.',
      }),
      [CalcRef(HistoSources.umich, 'p. 114')],
    ),
    where: HistoFact(
      _T({
        'uz': 'Umurtqalararo disk.',
        'ru': 'Межпозвонковый диск.',
        'en': 'Intervertebral disc.',
      }),
      [CalcRef(HistoSources.umich, 'p. 112, 114')],
    ),
    confuse: HistoFact(
      _T({
        'uz':
            'Zich biriktiruvchi to‘qima fibroblasti — xondrotsitni atrofidagi '
            'amorf matriks ajratib turadi.',
        'ru':
            'Фибробласт плотной соединительной ткани — хондроцит отличает '
            'окружающий его аморфный матрикс.',
        'en':
            'A fibroblast in dense connective tissue — the amorphous matrix '
            'around the chondrocyte tells them apart.',
      }),
      [CalcRef(HistoSources.umich, 'p. 113')],
    ),
  ),
  HistoItem(
    id: 'bone',
    group: HistoGroup.connective,
    name: _T({
      'uz': 'Kompakt suyak to‘qimasi (osteon)',
      'ru': 'Компактная костная ткань (остеон)',
      'en': 'Compact bone (osteon)',
    }),
    image: _imgBone,
    look: [
      HistoFact(
        _T({
          'uz':
              'Osteonlar (Gavers tizimlari): markazda Gavers (markaziy) '
              'kanali, atrofida halqa-halqa plastinkalar.',
          'ru':
              'Остеоны (гаверсовы системы): в центре гаверсов (центральный) '
              'канал, вокруг — кольца костных пластинок.',
          'en':
              'Osteons (Haversian systems): a central (Haversian) canal '
              'surrounded by rings of lamellae.',
        }),
        [CalcRef(HistoSources.umich, 'p. 117–119')],
      ),
      HistoFact(
        _T({
          'uz':
              'Lakunalar va ularni bog‘lovchi ingichka kanalchalar '
              '(kanalikulalar); kanalchalarda osteotsit o‘simtalari yotadi.',
          'ru':
              'Лакуны и соединяющие их тонкие канальцы; в канальцах лежат '
              'отростки остеоцитов.',
          'en':
              'Lacunae linked by fine canaliculi, which hold osteocyte '
              'processes.',
        }),
        [CalcRef(HistoSources.umich, 'p. 119')],
      ),
      HistoFact(
        _T({
          'uz':
              'Osteonlar orasida oraliq (interstitsial) plastinkalar; Volkmann '
              'kanallari osteonlarni teshib o‘tadi.',
          'ru':
              'Между остеонами — вставочные пластинки; фолькмановы каналы '
              'пронизывают остеоны.',
          'en':
              'Interstitial lamellae lie between osteons; Volkmann canals '
              'pierce them.',
        }),
        [CalcRef(HistoSources.umich, 'p. 119')],
      ),
    ],
    key: HistoFact(
      _T({
        'uz': 'Kanal atrofidagi halqasimon plastinkalar + lakunalar.',
        'ru': 'Кольцевые пластинки вокруг канала + лакуны.',
        'en': 'Rings of lamellae around a canal + lacunae.',
      }),
      [CalcRef(HistoSources.umich, 'p. 117–119')],
    ),
    function: HistoFact(
      _T({
        'uz':
            'Tayanch to‘qima: matriksidagi I tip kollagen cho‘zilishga '
            'mustahkamlik beradi, matriks mineral bilan qotgan.',
        'ru':
            'Опорная ткань: коллаген I типа в матриксе даёт прочность на '
            'растяжение, матрикс минерализован.',
        'en':
            'Supporting tissue: type I collagen gives tensile strength; the '
            'matrix is mineralized.',
      }),
      [CalcRef(HistoSources.umich, 'p. 26, 116')],
    ),
    confuse: HistoFact(
      _T({
        'uz':
            'Gialin tog‘ay — unda ham lakunalar bor, lekin matriks bir jinsli, '
            'osteon va kanalchalar yo‘q.',
        'ru':
            'Гиалиновый хрящ — в нём тоже есть лакуны, но матрикс однородный, '
            'нет остеонов и канальцев.',
        'en':
            'Hyaline cartilage — also has lacunae, but a uniform matrix '
            'without osteons or canaliculi.',
      }),
      [CalcRef(HistoSources.umich, 'p. 111, 119')],
    ),
    imageNote: HistoFact(
      _T({
        'uz':
            'Rasm — shliflangan (ground) quruq preparat: bo‘yalmagan; to‘q '
            'joylar — havo to‘lgan bo‘shliqlar (kanal, lakuna, kanalcha).',
        'ru':
            'На рисунке шлиф: не окрашен; тёмные участки — полости, '
            'заполненные воздухом (каналы, лакуны, канальцы).',
        'en':
            'The image is an unstained ground section; dark areas are '
            'air-filled spaces (canals, lacunae, canaliculi).',
      }),
      [
        CalcRef(
          HistoSources.commonsFiles,
          'File:Connective Tissue Compact Bone (41068142774).jpg',
        ),
        CalcRef(HistoSources.umich, 'p. 119'),
      ],
    ),
  ),

  // ── Muskul to'qimasi ──
  HistoItem(
    id: 'skeletal',
    group: HistoGroup.muscle,
    name: _T({
      'uz': 'Skelet ko‘ndalang-targ‘il muskul to‘qimasi',
      'ru': 'Поперечнополосатая скелетная мышечная ткань',
      'en': 'Skeletal muscle',
    }),
    image: _imgSkeletal,
    look: [
      HistoFact(
        _T({
          'uz':
              'Uzun, shoxlanmaydigan silindrsimon tolalar (hujayralar); '
              'uchlari ko‘rinmaydi.',
          'ru':
              'Длинные неветвящиеся цилиндрические волокна (клетки); концы '
              'не видны.',
          'en':
              'Long, unbranched cylindrical fibres (cells) whose ends are '
              'not seen.',
        }),
        [CalcRef(HistoSources.umich, 'p. 46')],
      ),
      HistoFact(
        _T({
          'uz':
              'Ko‘ndalang chiziqlar (sarkomerlar): to‘q A-disk, och I-disk, '
              'I-diskni bo‘luvchi Z-chiziq.',
          'ru':
              'Поперечная исчерченность (саркомеры): тёмный диск A, светлый '
              'диск I, линия Z посередине диска I.',
          'en':
              'Cross-striations (sarcomeres): dark A band, light I band, Z '
              'line bisecting the I band.',
        }),
        [CalcRef(HistoSources.umich, 'p. 47')],
      ),
      HistoFact(
        _T({
          'uz':
              'Har tolada ko‘p yadro; ular cho‘zinchoq va chetda — sarkolemma '
              'ostida.',
          'ru':
              'В каждом волокне много ядер; они вытянутые и лежат на '
              'периферии — под сарколеммой.',
          'en':
              'Many elongated nuclei per fibre, at the periphery under the '
              'sarcolemma.',
        }),
        [CalcRef(HistoSources.umich, 'p. 47'), _hpaSkeletal],
      ),
      HistoFact(
        _T({
          'uz':
              'Qiya kesilgan tolada chetdagi yadro markazda turgandek '
              'ko‘rinishi mumkin.',
          'ru':
              'В косо срезанном волокне периферическое ядро может казаться '
              'центральным.',
          'en':
              'In an obliquely cut fibre a peripheral nucleus can look '
              'central.',
        }),
        [CalcRef(HistoSources.umich, 'p. 46')],
      ),
    ],
    key: HistoFact(
      _T({
        'uz': 'Ko‘ndalang chiziqlar + chetdagi ko‘p yadro.',
        'ru': 'Поперечная исчерченность + много ядер на периферии.',
        'en': 'Cross-striations + many peripheral nuclei.',
      }),
      [CalcRef(HistoSources.umich, 'p. 47')],
    ),
    function: HistoFact(
      _T({
        'uz':
            'Suyakka birikadi va ixtiyoriy (ongli nerv nazoratida) qisqaradi.',
        'ru':
            'Прикрепляется к костям и сокращается произвольно (под '
            'сознательным нервным контролем).',
        'en':
            'Attached to bone; contracts voluntarily under conscious neural '
            'control.',
      }),
      [CalcRef(HistoSources.umich, 'p. 46'), _hpaSkeletal],
    ),
    confuse: HistoFact(
      _T({
        'uz':
            'Yurak muskuli — tolalari shoxlangan, yadrosi markazda, '
            'oraliq (interkalyar) disklar bor.',
        'ru':
            'Сердечная мышечная ткань — волокна ветвятся, ядро в центре, '
            'есть вставочные диски.',
        'en':
            'Cardiac muscle — branched fibres, central nuclei, intercalated '
            'discs.',
      }),
      [CalcRef(HistoSources.umich, 'p. 48–49')],
    ),
  ),
  HistoItem(
    id: 'cardiac',
    group: HistoGroup.muscle,
    name: _T({
      'uz': 'Yurak muskul to‘qimasi',
      'ru': 'Поперечнополосатая сердечная мышечная ткань',
      'en': 'Cardiac muscle',
    }),
    image: _imgCardiac,
    look: [
      HistoFact(
        _T({
          'uz':
              'Tolalar shoxlanib, uch o‘lchamli to‘r hosil qiladi; skelet '
              'muskuliga qaraganda kamroq parallel.',
          'ru':
              'Волокна ветвятся и образуют трёхмерную сеть; менее '
              'параллельны, чем в скелетной мышце.',
          'en':
              'Fibres branch into a 3-D network and are less parallel than '
              'in skeletal muscle.',
        }),
        [CalcRef(HistoSources.umich, 'p. 48'), _hpaHeart],
      ),
      HistoFact(
        _T({
          'uz':
              'Interkalyar (qo‘shuvchi) disklar — tolani ko‘ndalang kesib '
              'o‘tuvchi to‘q chiziqlar.',
          'ru': 'Вставочные диски — тёмные линии поперёк волокна.',
          'en': 'Intercalated discs — dark lines crossing the fibre.',
        }),
        [CalcRef(HistoSources.umich, 'p. 48')],
      ),
      HistoFact(
        _T({
          'uz': 'Yadro tolaning markazida; ko‘ndalang chiziqlar bor.',
          'ru': 'Ядро в центре волокна; есть поперечная исчерченность.',
          'en': 'Central nucleus; cross-striations are present.',
        }),
        [CalcRef(HistoSources.umich, 'p. 46, 48')],
      ),
      HistoFact(
        _T({
          'uz': 'Tolalar orasida kapillyarlar tarmog‘i zich.',
          'ru': 'Между волокнами густая сеть капилляров.',
          'en': 'A dense capillary network between fibres.',
        }),
        [CalcRef(HistoSources.umich, 'p. 49')],
      ),
    ],
    key: HistoFact(
      _T({
        'uz':
            'Shoxlangan tolalar + markaziy yadro + oraliq (interkalyar) '
            'disklar.',
        'ru': 'Ветвящиеся волокна + центральное ядро + вставочные диски.',
        'en': 'Branched fibres + central nucleus + intercalated discs.',
      }),
      [
        CalcRef(HistoSources.umich, 'p. 48'),
        CalcRef(HistoSources.zokirova2025, 'p. 78'),
      ],
    ),
    function: HistoFact(
      _T({
        'uz': 'Ixtiyorsiz va tinmay qisqarib, qonni haydaydi.',
        'ru': 'Сокращается непроизвольно и непрерывно, перекачивая кровь.',
        'en': 'Contracts involuntarily and continuously, pumping blood.',
      }),
      [CalcRef(HistoSources.umich, 'p. 46, 49'), _hpaHeart],
    ),
    where: HistoFact(
      _T({
        'uz': 'Yurak devori — miokard (qorinchalar devori).',
        'ru': 'Стенка сердца — миокард (стенка желудочков).',
        'en': 'The heart wall — myocardium (ventricular wall).',
      }),
      [CalcRef(HistoSources.umich, 'p. 48'), _hpaHeart],
    ),
    confuse: HistoFact(
      _T({
        'uz':
            'Tayyorlashdagi ko‘ndalang yoriqlar — ular oraliq (interkalyar) '
            'disk emas. Skelet muskulida esa yadrolar chetda.',
        'ru':
            'Поперечные разрывы волокон при обработке — это не вставочные '
            'диски. В скелетной мышце ядра лежат по периферии.',
        'en':
            'Artefactual transverse breaks are not intercalated discs. '
            'Skeletal muscle has peripheral nuclei.',
      }),
      [CalcRef(HistoSources.umich, 'p. 47–48')],
    ),
  ),
  HistoItem(
    id: 'smooth',
    group: HistoGroup.muscle,
    name: _T({
      'uz': 'Silliq muskul to‘qimasi',
      'ru': 'Гладкая мышечная ткань',
      'en': 'Smooth muscle',
    }),
    image: _imgSmooth,
    look: [
      HistoFact(
        _T({
          'uz':
              'Hujayralar kichik, duksimon (urchuqsimon); hujayra chegarasi '
              'noaniq.',
          'ru': 'Клетки мелкие, веретеновидные; границы клеток нечёткие.',
          'en': 'Small spindle-shaped cells with indistinct borders.',
        }),
        [CalcRef(HistoSources.umich, 'p. 50'), _hpaSmooth],
      ),
      HistoFact(
        _T({
          'uz': 'Miofibrillalar va ko‘ndalang chiziqlar ko‘rinmaydi.',
          'ru': 'Миофибриллы и поперечная исчерченность не видны.',
          'en': 'No visible myofibrils or cross-striations.',
        }),
        [CalcRef(HistoSources.umich, 'p. 50')],
      ),
      HistoFact(
        _T({
          'uz':
              'Yadro markazda, ingichka va cho‘zinchoq, ba’zan bukilgan yoki '
              'buralgan.',
          'ru':
              'Ядро в центре, узкое и вытянутое, иногда изогнутое или '
              'спиральное.',
          'en':
              'Central, narrow, elongated nucleus, sometimes kinked or '
              'spiralling.',
        }),
        [CalcRef(HistoSources.umich, 'p. 50'), _hpaSmooth],
      ),
      HistoFact(
        _T({
          'uz':
              'Ko‘ndalang kesmada diametrlar har xil, yadro har kesimda '
              'ko‘rinmaydi.',
          'ru':
              'На поперечном срезе диаметры разные, ядро видно не в каждом '
              'профиле.',
          'en':
              'In cross section diameters vary and not every profile shows '
              'a nucleus.',
        }),
        [CalcRef(HistoSources.umich, 'p. 50')],
      ),
    ],
    key: HistoFact(
      _T({
        'uz': 'Chiziqsiz duksimon hujayralar + markazdagi cho‘zinchoq yadro.',
        'ru': 'Веретеновидные клетки без исчерченности + центральное ядро.',
        'en': 'Unstriated spindle cells + central elongated nucleus.',
      }),
      [CalcRef(HistoSources.umich, 'p. 50')],
    ),
    function: HistoFact(
      _T({
        'uz':
            'Ixtiyorsiz qisqaradi; qisqarish to‘lqinlari masalan, ovqatni '
            'ichak bo‘ylab suradi.',
        'ru':
            'Сокращается непроизвольно; волны сокращения, например, '
            'продвигают пищу по кишечнику.',
        'en':
            'Contracts involuntarily; waves of contraction move food along '
            'the gut, for example.',
      }),
      [CalcRef(HistoSources.umich, 'p. 46'), _hpaSmooth],
    ),
    where: HistoFact(
      _T({
        'uz':
            'Ichki a’zolar devori; ichakda — ichki aylana va tashqi bo‘ylama '
            'qavatlar.',
        'ru':
            'Стенки внутренних органов; в кишке — внутренний циркулярный и '
            'наружный продольный слои.',
        'en':
            'Walls of internal organs; in the gut, inner circular and outer '
            'longitudinal layers.',
      }),
      [CalcRef(HistoSources.umich, 'p. 49'), _hpaSmooth],
    ),
    confuse: HistoFact(
      _T({
        'uz':
            'Kollagen tolalar: H&E da kollagen qizg‘ish-to‘q sariqroq va '
            'hujayrasi kam; Masson trixromida kollagen ko‘k, muskul pushti.',
        'ru':
            'Коллагеновые волокна: при H&E коллаген более красно-оранжевый и '
            'беден клетками; при трихроме Массона коллаген синий, мышца '
            'розоватая.',
        'en':
            'Collagen: in H&E it is more orange-red and has fewer nuclei; with '
            'Masson trichrome collagen is blue and muscle pinkish.',
      }),
      [CalcRef(HistoSources.umich, 'p. 50')],
    ),
  ),

  // ── Nerv to'qimasi ──
  HistoItem(
    id: 'neuron',
    group: HistoGroup.nerve,
    name: _T({
      'uz': 'Neyron (orqa miya motor neyroni)',
      'ru': 'Нейрон (мотонейрон спинного мозга)',
      'en': 'Neuron (spinal cord motor neuron)',
    }),
    image: _imgNeuron,
    look: [
      HistoFact(
        _T({
          'uz': 'Yirik hujayra tanasi (perikarion).',
          'ru': 'Крупное тело клетки (перикарион).',
          'en': 'A large cell body (perikaryon).',
        }),
        [CalcRef(HistoSources.umich, 'p. 57')],
      ),
      HistoFact(
        _T({
          'uz': 'Katta, och (euxromatinli) yadro va aniq yadrocha.',
          'ru': 'Крупное светлое (эухроматиновое) ядро с заметным ядрышком.',
          'en':
              'A large, pale (euchromatic) nucleus with a prominent '
              'nucleolus.',
        }),
        [CalcRef(HistoSources.umich, 'p. 57')],
      ),
      HistoFact(
        _T({
          'uz':
              'Sitoplazmada Nissl moddasi (darslikda — «bazofil modda») — '
              'ribosoma va donador endoplazmatik to‘r to‘dalari (bazofil).',
          'ru':
              'В цитоплазме вещество Ниссля (тигроид) — скопления рибосом и '
              'гранулярной ЭПС (базофильные).',
          'en':
              'Nissl substance in the cytoplasm — basophilic clusters of '
              'ribosomes and rough ER.',
        }),
        [
          CalcRef(HistoSources.umich, 'p. 10, 57'),
          CalcRef(HistoSources.zokirova2025, 'p. 14'),
        ],
      ),
      HistoFact(
        _T({
          'uz': 'Tanadan o‘simtalar chiqadi: dendritlar va bitta akson.',
          'ru': 'От тела отходят отростки: дендриты и один аксон.',
          'en': 'Processes leave the body: dendrites and a single axon.',
        }),
        [CalcRef(HistoSources.umich, 'p. 57')],
      ),
    ],
    key: HistoFact(
      _T({
        'uz': 'Yirik tana + och yadro + aniq yadrocha + o‘simtalar.',
        'ru': 'Крупное тело + светлое ядро + ядрышко + отростки.',
        'en': 'Large body + pale nucleus + nucleolus + processes.',
      }),
      [CalcRef(HistoSources.umich, 'p. 57')],
    ),
    function: HistoFact(
      _T({
        'uz':
            'Dendritlar signalni hujayra tanasiga olib keladi; akson uni '
            'boshqa neyron yoki muskulga uzatadi.',
        'ru':
            'Дендриты проводят сигнал к телу клетки; аксон передаёт его '
            'другому нейрону или мышце.',
        'en':
            'Dendrites carry signals towards the cell body; the axon passes '
            'them to other neurons or to muscle.',
      }),
      [CalcRef(HistoSources.umich, 'p. 57')],
    ),
    where: HistoFact(
      _T({
        'uz':
            'Orqa miya kulrang moddasining oldingi shoxlari: yirik motor '
            'neyronlar skelet muskullarini innervatsiya qiladi.',
        'ru':
            'Передние рога серого вещества спинного мозга: крупные '
            'мотонейроны иннервируют скелетные мышцы.',
        'en':
            'Ventral horn of the spinal cord grey matter: large motor neurons '
            'supply skeletal muscles.',
      }),
      [CalcRef(HistoSources.umich, 'p. 56–57')],
    ),
    confuse: HistoFact(
      _T({
        'uz':
            'Glial hujayralar — tanasi neyrondan ancha kichik, yadrosida '
            'euxromatin kam.',
        'ru':
            'Глиальные клетки — тело намного меньше, чем у нейрона, в ядре '
            'мало эухроматина.',
        'en':
            'Glial cells — much smaller bodies, nuclei with less '
            'euchromatin.',
      }),
      [CalcRef(HistoSources.umich, 'p. 58')],
    ),
    imageNote: HistoFact(
      _T({
        'uz': 'Rasm — orqa miya surtmasi (smear), kesma emas.',
        'ru': 'На рисунке мазок спинного мозга, а не срез.',
        'en': 'The image is a spinal cord smear, not a section.',
      }),
      [
        CalcRef(
          HistoSources.commonsFiles,
          'File:Nervous Tissue Spinal Cord Motor Neuron (41850850452).jpg',
        ),
      ],
    ),
  ),
  HistoItem(
    id: 'nerve',
    group: HistoGroup.nerve,
    name: _T({
      'uz': 'Periferik nerv',
      'ru': 'Периферический нерв',
      'en': 'Peripheral nerve',
    }),
    image: _imgNerve,
    look: [
      HistoFact(
        _T({
          'uz': 'Nerv bir nechta tutamdan (fassikuladan) iborat.',
          'ru': 'Нерв состоит из нескольких пучков.',
          'en': 'A nerve is made up of several fascicles.',
        }),
        [CalcRef(HistoSources.umich, 'p. 59')],
      ),
      HistoFact(
        _T({
          'uz':
              'Ko‘ndalang kesmada akson — och bo‘shliq (tayyorlashda erigan '
              'miyelin) o‘rtasidagi nuqta; aksonlar diametri har xil.',
          'ru':
              'На поперечном срезе аксон — точка в центре светлого '
              'пространства (миелин растворён при обработке); диаметр '
              'аксонов разный.',
          'en':
              'In cross section each axon is a dot inside a clear space '
              '(myelin extracted in processing); diameters vary.',
        }),
        [CalcRef(HistoSources.umich, 'p. 59')],
      ),
      HistoFact(
        _T({
          'uz':
              'Tutam atrofida perinevriy (yassi hujayralar qatlami), butun '
              'nerv atrofida epinevriy (zich biriktiruvchi to‘qima), har '
              'akson atrofida endonevriy.',
          'ru':
              'Вокруг пучка — периневрий (слой уплощённых клеток), вокруг '
              'всего нерва — эпиневрий (плотная соединительная ткань), вокруг '
              'каждого аксона — эндоневрий.',
          'en':
              'Perineurium (flattened cells) around each fascicle, epineurium '
              '(dense connective tissue) around the nerve, endoneurium around '
              'each axon.',
        }),
        [CalcRef(HistoSources.umich, 'p. 59')],
      ),
      HistoFact(
        _T({
          'uz':
              'Bo‘ylama kesmada aksonlar to‘lqinsimon; yadrolar asosan Shvann '
              'hujayralari va fibroblastlarniki.',
          'ru':
              'На продольном срезе аксоны извитые; ядра принадлежат в '
              'основном шванновским клеткам и фибробластам.',
          'en':
              'In longitudinal section axons are wavy; nuclei are mostly '
              'Schwann cells and fibroblasts.',
        }),
        [CalcRef(HistoSources.umich, 'p. 59')],
      ),
    ],
    key: HistoFact(
      _T({
        'uz':
            'Tutam ichida och halqalar, markazida nuqta-aksonlar; atrofida '
            'perinevriy.',
        'ru':
            'В пучке — светлые кольца с точками-аксонами в центре; вокруг '
            'периневрий.',
        'en':
            'Clear rings with dot-like axons inside a fascicle wrapped by '
            'perineurium.',
      }),
      [CalcRef(HistoSources.umich, 'p. 59')],
    ),
    function: HistoFact(
      _T({
        'uz': 'Sezuvchi (afferent) va harakat (efferent) tolalarini o‘tkazadi.',
        'ru':
            'Проводит чувствительные (афферентные) и двигательные '
            '(эфферентные) волокна.',
        'en': 'Carries both sensory (afferent) and motor (efferent) fibres.',
      }),
      [CalcRef(HistoSources.umich, 'p. 56, 59')],
    ),
    confuse: HistoFact(
      _T({
        'uz':
            'Zich biriktiruvchi to‘qima va silliq muskul — ular ham '
            'tutamlarga o‘xshash; nervda to‘lqinsimon aksonlar va Shvann '
            'hujayralari yadrolari bor.',
        'ru':
            'Плотная соединительная ткань и гладкая мышца — тоже похожи на '
            'пучки; в нерве есть извитые аксоны и ядра шванновских клеток.',
        'en':
            'Dense connective tissue and smooth muscle also form bundles; a '
            'nerve shows wavy axons and Schwann cell nuclei.',
      }),
      [CalcRef(HistoSources.umich, 'p. 26, 47, 59')],
    ),
  ),

  // ── A'zolar (M2 moduli) ──
  HistoItem(
    id: 'liver',
    group: HistoGroup.organ,
    name: _T({
      'uz': 'Jigar (jigar bo‘lakchasi)',
      'ru': 'Печень (печёночная долька)',
      'en': 'Liver (lobule)',
    }),
    image: _imgLiver,
    look: [
      HistoFact(
        _T({
          'uz':
              'Gepatotsitlar plastinkalari (odatda bir hujayra qalinlikda), '
              'orasida sinusoidlar.',
          'ru':
              'Пластинки (балки) гепатоцитов, обычно толщиной в одну клетку, '
              'между ними синусоиды.',
          'en':
              'Plates of hepatocytes (usually one cell thick) with sinusoids '
              'between them.',
        }),
        [_hpaLiver, CalcRef(HistoSources.umich, 'p. 197')],
      ),
      HistoFact(
        _T({
          'uz':
              'Klassik bo‘lakcha markazida markaziy vena, chetida portal '
              'yo‘llar (o‘rtacha oltita).',
          'ru':
              'В центре классической дольки — центральная вена, по периферии '
              '— портальные тракты (в среднем около шести).',
          'en':
              'A classic lobule has a central vein in the middle and portal '
              'tracts (on average six) at its periphery.',
        }),
        [CalcRef(HistoSources.umich, 'p. 197'), _hpaLiver],
      ),
      HistoFact(
        _T({
          'uz':
              'Portal yo‘lda: darvoza vena tarmog‘i, jigar arteriyasi '
              'tarmog‘i va o‘t yo‘li (triada).',
          'ru':
              'В портальном тракте: ветвь воротной вены, ветвь печёночной '
              'артерии и жёлчный проток (триада).',
          'en':
              'A portal tract holds a portal vein branch, a hepatic artery '
              'branch and a bile duct (triad).',
        }),
        [CalcRef(HistoSources.umich, 'p. 197'), _boydZones],
      ),
      HistoFact(
        _T({
          'uz':
              'Gepatotsit ko‘pburchak, yadrosi odatda bitta, markazda; ba’zan '
              'ikki yadroli.',
          'ru':
              'Гепатоцит многоугольный, ядро обычно одно, в центре; иногда '
              'двуядерный.',
          'en':
              'Hepatocytes are polygonal with usually one central nucleus; '
              'some are binucleate.',
        }),
        [_hpaLiver, CalcRef(HistoSources.umich, 'p. 197')],
      ),
      HistoFact(
        _T({
          'uz':
              'Sinusoid devorida Kupfer (Kupffer) hujayralari — yulduzsimon '
              'makrofaglar. Manba («Kupfer hujayralari»): Zokirova N.B., '
              '2025, «Gistologiya asoslari», Jigar va o‘t qopini tuzilishi, '
              '102-b.',
          'ru':
              'В стенке синусоидов — клетки Купфера (звёздчатые макрофаги; '
              'узбекское написание «Kupfer hujayralari» — источник: Zokirova '
              'N.B., 2025, «Gistologiya asoslari», с. 102).',
          'en':
              'Kupffer cells (stellate macrophages) line the sinusoids (Uzbek '
              'spelling “Kupfer hujayralari” — source: Zokirova N.B., 2025, '
              '“Gistologiya asoslari”, p. 102).',
        }),
        [
          CalcRef(HistoSources.umich, 'p. 197'),
          _hpaLiver,
          CalcRef(HistoSources.zokirova2025, 'p. 102'),
        ],
      ),
      HistoFact(
        _T({
          'uz':
              'Zonalar: 1-zona portal yo‘lga yaqin, 3-zona markaziy venaga eng '
              'yaqin, 2-zona — oralig‘ida.',
          'ru':
              'Зоны: зона 1 прилежит к портальному тракту, зона 3 ближе всего '
              'к центральной вене, зона 2 — между ними.',
          'en':
              'Zones: zone 1 next to the portal tract, zone 3 closest to the '
              'central (hepatic) venule, zone 2 in between.',
        }),
        [_boydZones],
      ),
    ],
    key: HistoFact(
      _T({
        'uz':
            'Markaziy vena atrofida gepatotsit plastinkalari va sinusoidlar; '
            'chetda portal triadalar.',
        'ru':
            'Балки гепатоцитов и синусоиды вокруг центральной вены; по '
            'периферии портальные триады.',
        'en':
            'Hepatocyte plates and sinusoids around a central vein; portal '
            'triads at the periphery.',
      }),
      [CalcRef(HistoSources.umich, 'p. 197'), _hpaLiver],
    ),
    function: HistoFact(
      _T({
        'uz':
            'Gepatotsitlar o‘t (safro) ishlab chiqaradi; qon portal '
            'yo‘llardan sinusoidlar orqali markaziy venaga oqadi — portal va '
            'arterial qon sinusoidda aralashadi.',
        'ru':
            'Гепатоциты образуют жёлчь; кровь течёт от портальных трактов по '
            'синусоидам к центральной вене — портальная и артериальная кровь '
            'смешиваются в синусоидах.',
        'en':
            'Hepatocytes produce bile; blood flows from portal tracts through '
            'sinusoids to the central vein, where portal and arterial blood '
            'mix in the sinusoids.',
      }),
      [_hpaLiver, CalcRef(HistoSources.umich, 'p. 197'), _boydZones],
    ),
    confuse: HistoFact(
      _T({
        'uz':
            'Markaziy vena va portal vena: markaziy vena yonida arteriya va o‘t '
            'yo‘li bo‘lmaydi; portal vena doim triadada, bo‘lakcha chetida.',
        'ru':
            'Центральная вена и воротная вена: рядом с центральной веной нет '
            'артерии и жёлчного протока; ветвь воротной вены всегда в триаде '
            'на периферии дольки.',
        'en':
            'Central vein vs portal vein: a central vein has no accompanying '
            'artery or bile duct; portal vein branches sit in triads at the '
            'lobule edge.',
      }),
      [CalcRef(HistoSources.umich, 'p. 197')],
    ),
    imageNote: HistoFact(
      _T({
        'uz':
            'Rasm retikulin bo‘yog‘ida: III tip kollagen (retikulyar) tolalar '
            'qora — jigar tuzilishini (arxitekturasini) baholash uchun '
            'qulay.',
        'ru':
            'Рисунок — окраска на ретикулин: волокна коллагена III типа '
            '(ретикулярные) чёрные — удобно для оценки архитектоники печени.',
        'en':
            'The image uses a reticulin stain: type III collagen (reticular) '
            'fibres are black, useful for assessing liver architecture.',
      }),
      [
        CalcRef(
          HistoSources.commonsFiles,
          'File:Histopathology of liver zones.jpg',
        ),
        _boydStain,
        CalcRef(HistoSources.umich, 'p. 8'),
      ],
    ),
  ),
  HistoItem(
    id: 'kidney',
    group: HistoGroup.organ,
    name: _T({
      'uz': 'Buyrak (po‘stloq: tanacha va kanalchalar)',
      'ru': 'Почка (корковое вещество: тельце и канальцы)',
      'en': 'Kidney (cortex: corpuscle and tubules)',
    }),
    image: _imgKidney,
    look: [
      HistoFact(
        _T({
          'uz':
              'Buyrak tanachasi: kapillyarlar to‘pi — koptokcha (glomerula) va '
              'uni o‘rab turgan Bouman–Shumlyanskiy kapsulasi; orasida '
              'Bouman bo‘shlig‘i.',
          'ru':
              'Почечное тельце: клубочек капилляров и окружающая его капсула '
              'Боумена — Шумлянского; между ними — полость капсулы.',
          'en':
              'Renal corpuscle: a capillary tuft (glomerulus) inside '
              'Bowman’s capsule, with Bowman’s space between them.',
        }),
        [_hpaKidney, CalcRef(HistoSources.umich, 'p. 205, 207')],
      ),
      HistoFact(
        _T({
          'uz':
              'Kapsulaning tashqi (parietal) varag‘i — bir qavatli yassi '
              'epiteliy; koptokchadagi yassi yadrolar endoteliy va '
              'podotsitlarniki.',
          'ru':
              'Наружный (париетальный) листок капсулы — однослойный плоский '
              'эпителий; плоские ядра в клубочке принадлежат эндотелию и '
              'подоцитам.',
          'en':
              'The parietal layer of Bowman’s capsule is simple squamous; flat '
              'nuclei in the glomerulus are endothelial cells and podocytes.',
        }),
        [CalcRef(HistoSources.umich, 'p. 207')],
      ),
      HistoFact(
        _T({
          'uz':
              'Proksimal kanalchalar — eng ko‘p, yirik, to‘qroq pushti '
              '(atsidofil); bo‘shlig‘i tomonida jiyak (cho‘tkasimon '
              'hoshiya). Manba («jiyak»): Zokirova N.B., 2025, «Gistologiya '
              'asoslari», Nefron gistofiziologiyasi, 118-b.',
          'ru':
              'Проксимальные канальцы — самые многочисленные, крупные, более '
              'розовые (ацидофильные); со стороны просвета щёточная каёмка '
              '(узбекский термин «jiyak» — источник: Zokirova N.B., 2025, '
              '«Gistologiya asoslari», с. 118).',
          'en':
              'Proximal tubules are the most numerous, large and deeper pink '
              '(acidophilic), with a luminal brush border (Uzbek term “jiyak” '
              '— source: Zokirova N.B., 2025, “Gistologiya asoslari”, p. 118).',
        }),
        [
          CalcRef(HistoSources.umich, 'p. 206'),
          _hpaKidney,
          CalcRef(HistoSources.zokirova2025, 'p. 118'),
        ],
      ),
      HistoFact(
        _T({
          'uz':
              'Distal kanalchalar — ochroq, diametri kichikroq, past kubsimon '
              'epiteliy bilan qoplangan.',
          'ru':
              'Дистальные канальцы — бледнее, меньшего диаметра, выстланы '
              'низким кубическим эпителием.',
          'en':
              'Distal tubules are paler and narrower, with a low cuboidal '
              'epithelium.',
        }),
        [CalcRef(HistoSources.umich, 'p. 206'), _hpaKidney],
      ),
    ],
    key: HistoFact(
      _T({
        'uz':
            'Yumaloq koptokcha (kapillyar to‘pi) kapsula ichida + atrofida '
            'turli kesimdagi kanalchalar.',
        'ru':
            'Округлый клубочек капилляров в капсуле + вокруг канальцы в '
            'разных срезах.',
        'en':
            'A round capillary tuft in its capsule + tubules cut in all '
            'directions around it.',
      }),
      [_hpaKidney, CalcRef(HistoSources.umich, 'p. 206–207')],
    ),
    function: HistoFact(
      _T({
        'uz':
            'Koptokchalar qonni filtrlaydi — siydik hosil bo‘lishi shu yerdan '
            'boshlanadi; kanalchalar filtratni o‘zgartiradi.',
        'ru':
            'Клубочки фильтруют кровь — с этого начинается образование мочи; '
            'канальцы изменяют фильтрат.',
        'en':
            'Glomeruli filter the blood, which starts urine formation; '
            'tubules modify the filtrate.',
      }),
      [_hpaKidney, CalcRef(HistoSources.umich, 'p. 205')],
    ),
    where: HistoFact(
      _T({
        'uz':
            'Buyrak tanachalari va burama kanalchalar po‘stloq qavatda '
            '(kortikal labirint) joylashadi.',
        'ru':
            'Почечные тельца и извитые канальцы находятся в корковом '
            'веществе (корковый лабиринт).',
        'en':
            'Renal corpuscles and convoluted tubules lie in the cortex '
            '(cortical labyrinth).',
      }),
      [CalcRef(HistoSources.umich, 'p. 206')],
    ),
    confuse: HistoFact(
      _T({
        'uz':
            'Proksimal va distal kanalcha: distal kanalcha torroq, ochroq, '
            'unda to‘q pushti (atsidofil) donador sitoplazma yo‘q.',
        'ru':
            'Проксимальный и дистальный каналец: дистальный уже, бледнее, в '
            'нём нет ярко-ацидофильной зернистой цитоплазмы.',
        'en':
            'Proximal vs distal tubule: the distal tubule is narrower and '
            'paler, without the deeply acidophilic granular cytoplasm.',
      }),
      [CalcRef(HistoSources.umich, 'p. 206'), _hpaKidney],
    ),
  ),
];

HistoItem? histoItem(String id) {
  for (final i in histoItems) {
    if (i.id == id) return i;
  }
  return null;
}

// ───────────────────────── Bo'yash usullari ─────────────────────────

class HistoStain {
  const HistoStain({
    required this.id,
    required this.name,
    required this.facts,
    this.example,
  });

  final String id;
  final LocalizedText name;
  final List<HistoFact> facts;

  /// Shu bo'yoqdagi namuna (bo'yoq fayl sahifasida yozilgan rasm).
  final HistoImage? example;
}

const histoStains = <HistoStain>[
  HistoStain(
    id: 'he',
    name: _T({
      'uz': 'Gematoksilin va eozin (H&E)',
      'ru': 'Гематоксилин и эозин (H&E)',
      'en': 'Haematoxylin and eosin (H&E)',
    }),
    example: _imgKidney,
    facts: [
      HistoFact(
        _T({
          'uz':
              'Gematoksilin — asosli bo‘yoq: nuklein kislotalar (yadrodagi '
              'DNK va RNK, sitoplazmadagi RNK) bilan bog‘lanadi. Uni oladigan '
              'tuzilmalar — bazofil (ko‘k-binafsha).',
          'ru':
              'Гематоксилин — основный краситель: связывается с нуклеиновыми '
              'кислотами (ДНК и РНК ядра, РНК цитоплазмы). Такие структуры — '
              'базофильные (сине-фиолетовые).',
          'en':
              'Haematoxylin is a basic dye that binds nucleic acids (DNA and '
              'RNA in the nucleus, RNA in the cytoplasm); such structures are '
              'basophilic (blue-purple).',
        }),
        [CalcRef(HistoSources.umich, 'p. 6')],
      ),
      HistoFact(
        _T({
          'uz':
              'Eozin — kislotali bo‘yoq: membranalar va ko‘pchilik oqsillarni '
              'bo‘yaydi; bunday tuzilmalar — eozinofil (atsidofil), pushti.',
          'ru':
              'Эозин — кислый краситель: окрашивает мембраны и большинство '
              'белков; такие структуры — эозинофильные (ацидофильные), '
              'розовые.',
          'en':
              'Eosin is an acidic dye that stains membranes and most proteins; '
              'these are eosinophilic (acidophilic), pink.',
        }),
        [CalcRef(HistoSources.umich, 'p. 6')],
      ),
      HistoFact(
        _T({
          'uz':
              'Natija: yadrolar ko‘k, sitoplazma va tolali to‘qima pushti. '
              'Kollagen qizg‘ish-to‘q sariq, silliq muskul (aktin) pushtiroq, '
              'ko‘p elastin — shishasimon qizil.',
          'ru':
              'Итог: ядра синие, цитоплазма и волокнистая ткань розовые. '
              'Коллаген красно-оранжевый, гладкая мышца (актин) розовее, '
              'обильный эластин — стекловидно-красный.',
          'en':
              'Result: nuclei blue, cytoplasm and fibrous tissue pink. '
              'Collagen red-orange, smooth muscle (actin) pinker, abundant '
              'elastin glassy red.',
        }),
        [_boydStain, CalcRef(HistoSources.umich, 'p. 6')],
      ),
      HistoFact(
        _T({
          'uz':
              'Shilliq (mutsin) H&E bilan bo‘yalmaydi — qadahsimon hujayralar '
              'och ko‘rinadi.',
          'ru':
              'Слизь (муцин) не окрашивается H&E — бокаловидные клетки '
              'выглядят светлыми.',
          'en': 'Mucus does not stain with H&E, so goblet cells look pale.',
        }),
        [CalcRef(HistoSources.umich, 'p. 16')],
      ),
      HistoFact(
        _T({
          'uz':
              'Gematoksilin — gistologiya va patologiyada eng ko‘p '
              'ishlatiladigan yadro bo‘yog‘i; H&E — jigar biopsiyasining '
              'standart birinchi bo‘yog‘i.',
          'ru':
              'Гематоксилин — самый распространённый ядерный краситель в '
              'гистологии и патологии; H&E — стандартная первая окраска '
              'биоптата печени.',
          'en':
              'Haematoxylin is the most common nuclear stain in histology and '
              'pathology; H&E is the standard first stain for a liver biopsy.',
        }),
        [CalcRef(HistoSources.umich, 'p. 6'), _boydStain],
      ),
    ],
  ),
  HistoStain(
    id: 'masson',
    name: _T({
      'uz': 'Masson trixromi',
      'ru': 'Трихром по Массону',
      'en': 'Masson trichrome',
    }),
    facts: [
      HistoFact(
        _T({
          'uz':
              'Kollagen va retikulyar tolalar hamda shilliq ko‘k (anilin ko‘k) '
              'yoki yashil; muskul qizil; yadrolar qizil (temirli gematoksilin '
              'bilan — qora).',
          'ru':
              'Коллагеновые и ретикулярные волокна и слизь — синие (анилиновый '
              'синий) или зелёные; мышцы красные; ядра красные (с железным '
              'гематоксилином — чёрные).',
          'en':
              'Collagen, reticular fibres and mucus blue (aniline blue) or '
              'green; muscle red; nuclei red (black after iron haematoxylin).',
        }),
        [CalcRef(HistoSources.umich, 'p. 7')],
      ),
      HistoFact(
        _T({
          'uz':
              'Biriktiruvchi to‘qimani ko‘rsatish uchun keng qo‘llanadi — '
              'silliq muskul va kollagenni ajratish oson.',
          'ru':
              'Широко применяется для выявления соединительной ткани — легко '
              'отличить гладкую мышцу от коллагена.',
          'en':
              'A common connective tissue stain; smooth muscle and collagen '
              'are easy to tell apart.',
        }),
        [CalcRef(HistoSources.umich, 'p. 7, 50')],
      ),
    ],
  ),
  HistoStain(
    id: 'elastic',
    name: _T({
      'uz': 'Elastik tolalar bo‘yoqlari',
      'ru': 'Окраски на эластические волокна',
      'en': 'Elastic fibre stains',
    }),
    facts: [
      HistoFact(
        _T({
          'uz':
              'Aldegid-fuksin (Gomori), Veygert va Verxoff (Van Gizon bilan) '
              'usullari elastik tolalarni to‘q binafsha yoki qora qiladi.',
          'ru':
              'Альдегид-фуксин (Гомори), окраска по Вейгерту и по Верхоффу '
              '(с ван Гизоном) окрашивают эластические волокна в '
              'тёмно-фиолетовый или чёрный цвет.',
          'en':
              'Aldehyde fuchsin (Gomori), Weigert and Verhoeff (with Van '
              'Gieson) stain elastic fibres deep purple or black.',
        }),
        [CalcRef(HistoSources.umich, 'p. 7–8')],
      ),
      HistoFact(
        _T({
          'uz': 'Van Gizon eritmasi kollagenni qizil-to‘q sariq bo‘yaydi.',
          'ru': 'Раствор ван Гизона окрашивает коллаген в красно-оранжевый.',
          'en': 'Van Gieson solution stains collagen red-orange.',
        }),
        [CalcRef(HistoSources.umich, 'p. 8')],
      ),
    ],
  ),
  HistoStain(
    id: 'silver',
    name: _T({
      'uz': 'Kumush bilan bo‘yash (retikulin)',
      'ru': 'Импрегнация серебром (ретикулин)',
      'en': 'Silver stain (reticulin)',
    }),
    example: _imgLiver,
    facts: [
      HistoFact(
        _T({
          'uz':
              'Kumush nitrat metall (qora) kumushgacha qaytariladi: '
              'retikulyar (III tip kollagen) tolalar nozik qora to‘r bo‘lib '
              'ko‘rinadi.',
          'ru':
              'Нитрат серебра восстанавливается до металлического (чёрного) '
              'серебра: ретикулярные волокна (коллаген III типа) видны как '
              'тонкая чёрная сеть.',
          'en':
              'Silver nitrate is reduced to black metallic silver, showing '
              'reticular (type III collagen) fibres as a fine black network.',
        }),
        [CalcRef(HistoSources.umich, 'p. 8, 29')],
      ),
      HistoFact(
        _T({
          'uz': 'Jigar biopsiyasida umumiy tuzilishni baholash uchun foydali.',
          'ru': 'В биоптате печени полезна для оценки общей архитектоники.',
          'en': 'In a liver biopsy it helps assess the overall architecture.',
        }),
        [_boydStain],
      ),
    ],
  ),
  HistoStain(
    id: 'pas',
    name: _T({
      'uz': 'PAS (Shiff yodli kislota reaksiyasi)',
      'ru': 'ШИК-реакция (PAS)',
      'en': 'Periodic acid–Schiff (PAS)',
    }),
    example: histoPasImage,
    facts: [
      HistoFact(
        _T({
          'uz':
              'Shakar guruhlari ko‘p bo‘lgan moddalarni ko‘rsatadi: '
              'glikoproteinlar, shilliq (mutsin), ayrim proteoglikanlar.',
          'ru':
              'Выявляет вещества, богатые углеводными группами: гликопротеины, '
              'слизь (муцины), некоторые протеогликаны.',
          'en':
              'Shows sugar-rich material: glycoproteins, mucins and some '
              'proteoglycans.',
        }),
        [CalcRef(HistoSources.umich, 'p. 9')],
      ),
      HistoFact(
        _T({
          'uz':
              'Bazal membranalarni (masalan, buyrak kanalchalari va '
              'koptokchalarida) pushti chiziq qilib ko‘rsatadi; '
              'mikrovorsinkalar glikokaliksini ham.',
          'ru':
              'Выявляет базальные мембраны (например, канальцев и клубочков '
              'почки) розовыми линиями, а также гликокаликс микроворсинок.',
          'en':
              'Outlines basement membranes (e.g. kidney tubules and glomeruli) '
              'as pink lines, and the glycocalyx of microvilli.',
        }),
        [CalcRef(HistoSources.umich, 'p. 9')],
      ),
      HistoFact(
        _T({
          'uz':
              'Jigarda gepatotsitlardagi glikogenni bo‘yaydi; diastaza bilan '
              '(PAS-D) glikogen olib tashlanadi.',
          'ru':
              'В печени окрашивает гликоген гепатоцитов; с диастазой (ШИК-Д) '
              'гликоген удаляется.',
          'en':
              'In the liver it stains hepatocyte glycogen; diastase (PAS-D) '
              'removes the glycogen.',
        }),
        [_boydStain],
      ),
    ],
  ),
  HistoStain(
    id: 'luxol',
    name: _T({
      'uz': 'Lyuksol tez ko‘k (LFB)',
      'ru': 'Люксоловый прочный синий (LFB)',
      'en': 'Luxol fast blue (LFB)',
    }),
    facts: [
      HistoFact(
        _T({
          'uz':
              'Nerv to‘qimasida asosan miyelinni bo‘yaydi (klassik '
              'Klyuver–Barrera usulida hujayralar va Nissl moddasi uchun '
              'qo‘shimcha bo‘yoq bilan birga); demiyelinizatsiyani aniqlashda '
              'ishlatiladi.',
          'ru':
              'В нервной ткани окрашивает в основном миелин (в классическом '
              'методе Клювера — Барреры — вместе с дополнительным красителем '
              'для клеток и вещества Ниссля); используется для выявления '
              'демиелинизации.',
          'en':
              'Stains mainly myelin in nervous tissue (the classic '
              'Klüver–Barrera method adds a counterstain for cells and Nissl '
              'substance); used to detect demyelination.',
        }),
        [CalcRef(HistoSources.umich, 'p. 9')],
      ),
    ],
  ),
];

// ───────────────────────── Matnlar ─────────────────────────

abstract final class HisL {
  static const subtitle = _T({
    'uz': 'To‘qimalar va a’zolar: rasmlar, belgilar, mashq',
    'ru': 'Ткани и органы: снимки, признаки, тренировка',
    'en': 'Tissues and organs: pictures, features, practice',
  });
  static const draftNote = _T({
    'uz':
        'Qoralama: matn Michigan universiteti gistologiya qo‘llanmasi, '
        'Human Protein Atlas va ochiq maqola bilan solishtirilgan, lekin '
        'mutaxassis tekshiruvidan hali o‘tmagan.',
    'ru':
        'Черновик: текст сверен с руководством по гистологии Мичиганского '
        'университета, Human Protein Atlas и открытой статьёй, но ещё не '
        'прошёл экспертную проверку.',
    'en':
        'Draft: checked against the University of Michigan histology manual, '
        'the Human Protein Atlas and an open-access paper, but not yet '
        'reviewed by an expert.',
  });
  static const photoNote = _T({
    'uz':
        'Rasmlar — haqiqiy mikrofotolar (Wikimedia Commons, erkin '
        'litsenziya). Faqat kichraytirilgan: kesilmagan, yozuv qo‘shilmagan.',
    'ru':
        'Снимки — настоящие микрофотографии (Wikimedia Commons, свободные '
        'лицензии). Только уменьшены: не обрезаны, подписи не добавлены.',
    'en':
        'Pictures are real micrographs (Wikimedia Commons, free licences). '
        'Only downscaled: not cropped, no labels added.',
  });

  // Hub qatorlari.
  static const atlasTitle = _T({
    'uz': 'To‘qimalar va a’zolar',
    'ru': 'Ткани и органы',
    'en': 'Tissues and organs',
  });
  static const atlasSub = _T({
    'uz': 'Epiteliy, biriktiruvchi, muskul, nerv; jigar, buyrak',
    'ru': 'Эпителий, соединительная, мышечная, нервная; печень, почка',
    'en': 'Epithelium, connective, muscle, nerve; liver, kidney',
  });
  static const stainsTitle = _T({
    'uz': 'Bo‘yash usullari',
    'ru': 'Методы окраски',
    'en': 'Staining methods',
  });
  static const stainsSub = _T({
    'uz': 'H&E, Masson, elastik, kumush, PAS, LFB',
    'ru': 'H&E, Массон, эластика, серебро, ШИК, LFB',
    'en': 'H&E, Masson, elastic, silver, PAS, LFB',
  });
  static const quizTitle = _T({
    'uz': 'Bu qaysi to‘qima?',
    'ru': 'Какая это ткань?',
    'en': 'Which tissue is this?',
  });
  static const quizSub = _T({
    'uz': 'Rasm bo‘yicha mashq',
    'ru': 'Тренировка по снимкам',
    'en': 'Picture practice',
  });
  static const creditsTitle = _T({
    'uz': 'Rasmlar mualliflari',
    'ru': 'Авторы снимков',
    'en': 'Picture credits',
  });
  static const creditsSub = _T({
    'uz': 'Muallif, litsenziya, manba sahifasi',
    'ru': 'Автор, лицензия, страница источника',
    'en': 'Author, licence, source page',
  });
  static const creditsIntro = _T({
    'uz':
        'Har rasmning litsenziyasi, muallifi va asl izohi Wikimedia Commons '
        'fayl sahifasidan tekshirilgan ($histoCheckedAt). Faqat CC0, CC BY va '
        'CC BY-SA rasmlari olinadi.',
    'ru':
        'Лицензия, автор и исходная подпись каждого снимка проверены на '
        'странице файла Wikimedia Commons ($histoCheckedAt). Используются '
        'только CC0, CC BY и CC BY-SA.',
    'en':
        'Each picture’s licence, author and original caption were checked on '
        'its Wikimedia Commons file page ($histoCheckedAt). Only CC0, CC BY '
        'and CC BY-SA images are used.',
  });

  // Ro'yxat.
  static const classification = _T({
    'uz':
        'To‘qimalar Michigan qo‘llanmasi boblari tartibida: epiteliy, '
        'biriktiruvchi to‘qima (tog‘ay va suyak bilan), muskul (skelet, yurak, '
        'silliq), nerv; keyin M2 modulidagi a’zolar — jigar va buyrak.',
    'ru':
        'Ткани — в порядке глав руководства Мичиганского университета: '
        'эпителий, соединительная ткань (с хрящом и костью), мышечная '
        '(скелетная, сердечная, гладкая), нервная; затем органы модуля М2 — '
        'печень и почка.',
    'en':
        'Tissues follow the chapter order of the Michigan manual: epithelium, '
        'connective tissue (with cartilage and bone), muscle (skeletal, '
        'cardiac, smooth), nerve; then the M2 organs — liver and kidney.',
  });
  static const groups = {
    HistoGroup.epithelium: _T({
      'uz': 'Epiteliy to‘qimasi',
      'ru': 'Эпителиальная ткань',
      'en': 'Epithelial tissue',
    }),
    HistoGroup.connective: _T({
      'uz': 'Biriktiruvchi to‘qima',
      'ru': 'Соединительная ткань',
      'en': 'Connective tissue',
    }),
    HistoGroup.muscle: _T({
      'uz': 'Muskul to‘qimasi',
      'ru': 'Мышечная ткань',
      'en': 'Muscle tissue',
    }),
    HistoGroup.nerve: _T({
      'uz': 'Nerv to‘qimasi',
      'ru': 'Нервная ткань',
      'en': 'Nervous tissue',
    }),
    HistoGroup.organ: _T({
      'uz': 'A’zolar (M2 moduli)',
      'ru': 'Органы (модуль М2)',
      'en': 'Organs (module M2)',
    }),
  };

  // Karta.
  static const lookTitle = _T({
    'uz': 'Nimani ko‘rasiz',
    'ru': 'Что вы видите',
    'en': 'What you see',
  });
  static const keyTitle = _T({
    'uz': 'Asosiy belgi',
    'ru': 'Главный признак',
    'en': 'Key feature',
  });
  static const functionTitle = _T({
    'uz': 'Vazifasi',
    'ru': 'Функция',
    'en': 'Function',
  });
  static const whereTitle = _T({
    'uz': 'Qayerda uchraydi',
    'ru': 'Где встречается',
    'en': 'Where it is found',
  });
  static const confuseTitle = _T({
    'uz': 'Nima bilan adashtiriladi',
    'ru': 'С чем путают',
    'en': 'Confused with',
  });
  static const imageTitle = _T({
    'uz': 'Rasm haqida',
    'ru': 'О снимке',
    'en': 'About the picture',
  });
  static const stain = _T({'uz': 'Bo‘yoq', 'ru': 'Окраска', 'en': 'Stain'});
  static const stainNotStated = _T({
    'uz': 'manbada ko‘rsatilmagan',
    'ru': 'в источнике не указана',
    'en': 'not stated by the source',
  });
  static const captionTitle = _T({
    'uz': 'Manba izohi (asl matn)',
    'ru': 'Подпись источника (оригинал)',
    'en': 'Source caption (original)',
  });
  static const checked = _T({
    'uz': 'Litsenziya tekshirilgan',
    'ru': 'Лицензия проверена',
    'en': 'Licence checked',
  });
  static const fileTitle = _T({
    'uz': 'Commons fayli',
    'ru': 'Файл на Commons',
    'en': 'Commons file',
  });
  static const noPhoto = _T({
    'uz': 'Rasm hozircha yo‘q',
    'ru': 'Снимка пока нет',
    'en': 'No picture yet',
  });
  static const resized = _T({
    'uz': 'Ilovadagi nusxa faqat kichraytirilgan',
    'ru': 'В приложении снимок только уменьшен',
    'en': 'The in-app copy is only downscaled',
  });

  // Bo'yash.
  static const stainsIntro = _T({
    'uz':
        'Bo‘yoq rasmning ranglarini belgilaydi: bir to‘qima turli bo‘yoqda '
        'butunlay boshqacha ko‘rinadi. Karta rasmlarida bo‘yoq faqat manba '
        'yozgan bo‘lsa ko‘rsatiladi.',
    'ru':
        'Окраска определяет цвета снимка: одна и та же ткань при разных '
        'окрасках выглядит по-разному. На карточках окраска указана, только '
        'если её назвал источник.',
    'en':
        'The stain sets the colours: one tissue looks completely different in '
        'different stains. Cards name the stain only when the source states '
        'it.',
  });
  static const stainExample = _T({
    'uz': 'Namuna',
    'ru': 'Пример',
    'en': 'Example',
  });

  // Mashq.
  static const quizPrompt = _T({
    'uz': 'Bu qaysi to‘qima?',
    'ru': 'Какая это ткань?',
    'en': 'Which tissue is this?',
  });
  static const quizIntro = _T({
    'uz':
        'Haqiqiy mikrofoto ko‘rsatiladi — to‘rtta javobdan to‘g‘risini '
        'tanlang. Javobdan keyin asosiy belgi ko‘rsatiladi.',
    'ru':
        'Показывается настоящая микрофотография — выберите верный ответ из '
        'четырёх. После ответа показывается главный признак.',
    'en':
        'A real micrograph is shown — pick the right answer of four. The key '
        'feature is shown after you answer.',
  });
  static const quizStart = _T({
    'uz': 'Boshlash',
    'ru': 'Начать',
    'en': 'Start',
  });
  static const quizImageLabel = _T({
    'uz': 'Mikrofoto (nomi javobda)',
    'ru': 'Микрофотография (название — в ответе)',
    'en': 'Micrograph (name in the answer)',
  });
}

// ───────────────────────── Mashq ─────────────────────────

/// "Bu qaysi to'qima?" mashqidagi savollar soni.
const histoQuizSize = 10;

/// Har rasm uchun 3 ta chalg'ituvchi (o'xshash to'qimalar). Test: hammasi
/// mavjud, takrorsiz va to'g'ri javobdan farqli.
const histoDistractors = <String, List<String>>{
  'simple_squamous': ['simple_cuboidal', 'stratified_squamous', 'transitional'],
  'simple_cuboidal': ['simple_columnar', 'simple_squamous', 'transitional'],
  'simple_columnar': ['pseudostratified', 'simple_cuboidal', 'transitional'],
  'pseudostratified': [
    'simple_columnar',
    'stratified_squamous',
    'transitional',
  ],
  'stratified_squamous': [
    'transitional',
    'pseudostratified',
    'simple_squamous',
  ],
  'transitional': [
    'stratified_squamous',
    'pseudostratified',
    'simple_cuboidal',
  ],
  'loose_ct': ['dense_regular', 'adipose', 'smooth'],
  'dense_regular': ['smooth', 'nerve', 'loose_ct'],
  'adipose': ['loose_ct', 'hyaline', 'dense_regular'],
  'hyaline': ['elastic_cartilage', 'fibrocartilage', 'bone'],
  'elastic_cartilage': ['hyaline', 'fibrocartilage', 'bone'],
  'bone': ['hyaline', 'fibrocartilage', 'elastic_cartilage'],
  'skeletal': ['cardiac', 'smooth', 'dense_regular'],
  'cardiac': ['skeletal', 'smooth', 'dense_regular'],
  'smooth': ['skeletal', 'cardiac', 'dense_regular'],
  'neuron': ['nerve', 'smooth', 'loose_ct'],
  'nerve': ['dense_regular', 'smooth', 'neuron'],
  'liver': ['kidney', 'adipose', 'simple_cuboidal'],
  'kidney': ['liver', 'simple_cuboidal', 'transitional'],
};
