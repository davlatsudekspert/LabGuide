/// Leykoformula: hujayralarni tanish, adashtiriladiganlar, talqin va
/// surtma texnikasi (3 tilda).
///
/// Manbalar — [DiffSources] (JSST 2003 qo'llanmasi, MedlinePlus, NCI,
/// ochiq maqolalar). Faktlar o'z so'zlarimiz bilan; manbada yo'q raqam
/// yozilmaydi. Kontent mutaxassis tekshiruvidan o'tmagan — ekranda
/// "draft" deb belgilanadi.
library;

import '../content/content_model.dart';
import '../tools/calc_info.dart';
import 'differential_sources.dart';

typedef _T = LocalizedText;

/// Sanashdagi hujayra turlari (tugmalar tartibi shu).
enum DiffCell {
  segmented,
  band,
  lymphocyte,
  monocyte,
  eosinophil,
  basophil,
  other,
}

/// Hujayra sxemasi (`assets/differential/<nom>.png`).
String cellImage(String id) => 'assets/differential/$id.png';

/// Sanash tugmasidagi kichik rasm.
const diffCellImage = <DiffCell, String>{
  DiffCell.segmented: 'neutrophil_segmented',
  DiffCell.band: 'neutrophil_band',
  DiffCell.lymphocyte: 'lymphocyte_small',
  DiffCell.monocyte: 'monocyte',
  DiffCell.eosinophil: 'eosinophil',
  DiffCell.basophil: 'basophil',
  DiffCell.other: 'blast',
};

const diffCellNames = <DiffCell, LocalizedText>{
  DiffCell.segmented: _T({
    'uz': 'Segment yadroli neytrofil',
    'ru': 'Сегментоядерный нейтрофил',
    'en': 'Segmented neutrophil',
  }),
  DiffCell.band: _T({
    'uz': 'Tayoqcha yadroli neytrofil',
    'ru': 'Палочкоядерный нейтрофил',
    'en': 'Band neutrophil',
  }),
  DiffCell.lymphocyte: _T({
    'uz': 'Limfotsit',
    'ru': 'Лимфоцит',
    'en': 'Lymphocyte',
  }),
  DiffCell.monocyte: _T({'uz': 'Monotsit', 'ru': 'Моноцит', 'en': 'Monocyte'}),
  DiffCell.eosinophil: _T({
    'uz': 'Eozinofil',
    'ru': 'Эозинофил',
    'en': 'Eosinophil',
  }),
  DiffCell.basophil: _T({'uz': 'Bazofil', 'ru': 'Базофил', 'en': 'Basophil'}),
  DiffCell.other: _T({
    'uz': 'Boshqa (atipik, blast…)',
    'ru': 'Другие (атипичные, бласты…)',
    'en': 'Other (atypical, blasts…)',
  }),
};

/// Sanash tugmasidagi nom (tor ustunga sig'adigan; to'liq nom —
/// ekran o'quvchida).
const diffCellButton = <DiffCell, LocalizedText>{
  DiffCell.segmented: _T({
    'uz': 'Segment yadroli',
    'ru': 'Сегм. нейтрофил',
    'en': 'Segmented',
  }),
  DiffCell.band: _T({
    'uz': 'Tayoqcha yadroli',
    'ru': 'Палочк. нейтрофил',
    'en': 'Band',
  }),
  DiffCell.lymphocyte: _T({
    'uz': 'Limfotsit',
    'ru': 'Лимфоцит',
    'en': 'Lymphocyte',
  }),
  DiffCell.monocyte: _T({'uz': 'Monotsit', 'ru': 'Моноцит', 'en': 'Monocyte'}),
  DiffCell.eosinophil: _T({
    'uz': 'Eozinofil',
    'ru': 'Эозинофил',
    'en': 'Eosinophil',
  }),
  DiffCell.basophil: _T({'uz': 'Bazofil', 'ru': 'Базофил', 'en': 'Basophil'}),
  DiffCell.other: _T({'uz': 'Boshqa', 'ru': 'Другие', 'en': 'Other'}),
};

/// Qisqa nom — nusxalanadigan matn va tor joylar uchun.
const diffCellShort = <DiffCell, LocalizedText>{
  DiffCell.segmented: _T({'uz': 'Segment', 'ru': 'Сегм.', 'en': 'Segs'}),
  DiffCell.band: _T({'uz': 'Tayoqcha', 'ru': 'Палочк.', 'en': 'Bands'}),
  DiffCell.lymphocyte: _T({'uz': 'Limf.', 'ru': 'Лимф.', 'en': 'Lymph'}),
  DiffCell.monocyte: _T({'uz': 'Mono', 'ru': 'Мон.', 'en': 'Mono'}),
  DiffCell.eosinophil: _T({'uz': 'Eoz.', 'ru': 'Эоз.', 'en': 'Eos'}),
  DiffCell.basophil: _T({'uz': 'Baz.', 'ru': 'Баз.', 'en': 'Baso'}),
  DiffCell.other: _T({'uz': 'Boshqa', 'ru': 'Другие', 'en': 'Other'}),
};

/// Atlasdagi bitta hujayra.
class CellGuide {
  const CellGuide({
    required this.id,
    required this.name,
    required this.size,
    required this.nucleus,
    required this.cytoplasm,
    required this.granules,
    required this.key,
    required this.refs,
    this.seenIn,
    this.refer = false,
    this.analyteId,
  });

  /// Rasm nomi ham shu.
  final String id;
  final LocalizedText name;
  final LocalizedText size;
  final LocalizedText nucleus;
  final LocalizedText cytoplasm;
  final LocalizedText granules;

  /// Eng tez farqlovchi belgi.
  final LocalizedText key;

  /// Qachon uchraydi (manbada bo'lsa).
  final LocalizedText? seenIn;

  /// "Shifokor/gematologga yuboring" ogohlantirishi.
  final bool refer;

  /// Kontent paketida shu nomli karta bo'lsa — havola (yo'q bo'lsa
  /// ko'rsatilmaydi).
  final String? analyteId;
  final List<CalcRef> refs;
}

const _noGranules = _T({'uz': 'Yo‘q', 'ru': 'Нет', 'en': 'None'});

const cellGuides = <CellGuide>[
  CellGuide(
    id: 'neutrophil_segmented',
    analyteId: 'neutrophils',
    name: _T({
      'uz': 'Segment yadroli neytrofil',
      'ru': 'Сегментоядерный нейтрофил',
      'en': 'Segmented neutrophil',
    }),
    size: _T({'uz': '12–15 mkm', 'ru': '12–15 мкм', 'en': '12–15 µm'}),
    nucleus: _T({
      'uz': '2–5 bo‘lak, bir-biriga ingichka xromatin ip bilan ulangan; to‘q binafsha',
      'ru': '2–5 сегментов, соединённых тонкими нитями хроматина; тёмно-фиолетовое',
      'en': '2–5 lobes joined by thin chromatin strands; deep purple',
    }),
    cytoplasm: _T({
      'uz': 'Keng, och pushti',
      'ru': 'Обильная, бледно-розовая',
      'en': 'Abundant, pale pink',
    }),
    granules: _T({
      'uz': 'Juda mayda, ko‘p, och binafsha (mauve)',
      'ru': 'Очень мелкие, многочисленные, сиреневые',
      'en': 'Very small, numerous, mauve',
    }),
    key: _T({
      'uz': 'Bo‘laklar orasida ingichka “ip” bor — bu segment.',
      'ru': 'Между сегментами — тонкая «нить»: это сегментоядерный.',
      'en': 'Thin “thread” between lobes — that makes it segmented.',
    }),
    refs: [whoCells],
  ),
  CellGuide(
    id: 'neutrophil_band',
    name: _T({
      'uz': 'Tayoqcha yadroli neytrofil',
      'ru': 'Палочкоядерный нейтрофил',
      'en': 'Band neutrophil',
    }),
    size: _T({
      'uz': 'Manbada alohida berilmagan (yetilmagan granulotsitlar: 12–18 mkm)',
      'ru': 'В источнике отдельно не указан (незрелые гранулоциты: 12–18 мкм)',
      'en': 'Not given separately (immature granulocytes: 12–18 µm)',
    }),
    nucleus: _T({
      'uz':
          'Bo‘laklarga ajralmagan, cho‘ziq, egilgan (C yoki S shaklida) tasma',
      'ru': 'Не разделено на сегменты: вытянутая изогнутая лента (C или S)',
      'en': 'Not divided into lobes: an elongated, curved band (C or S shape)',
    }),
    cytoplasm: _T({
      'uz': 'Segment neytrofildagidek och pushti',
      'ru': 'Бледно-розовая, как у сегментоядерного',
      'en': 'Pale pink, as in a segmented neutrophil',
    }),
    granules: _T({
      'uz': 'Mayda, och binafsha',
      'ru': 'Мелкие, сиреневые',
      'en': 'Fine, mauve',
    }),
    key: _T({
      'uz': 'Yadroda ingichka ip bilan ajralgan bo‘lak yo‘q.',
      'ru': 'В ядре нет сегментов, разделённых тонкой нитью.',
      'en': 'No lobes separated by a thin strand.',
    }),
    seenIn: _T({
      'uz': 'Ko‘payishi infeksiyalarda, mielodisplaziyada uchraydi; Pelger–Xyuet anomaliyasida yadro shakli tug‘ma o‘zgargan bo‘ladi.',
      'ru': 'Увеличение — при инфекциях, миелодисплазии; при аномалии Пельгера–Хюэ форма ядра изменена врождённо.',
      'en': 'Increased in infections and myelodysplasia; in Pelger–Huët anomaly nuclear shape is altered congenitally.',
    }),
    refs: [
      CalcRef(DiffSources.who2003, '9.10.4: Immature granulocytes'),
      CalcRef(DiffSources.oskarsson2022, 'Introduction'),
    ],
  ),
  CellGuide(
    id: 'lymphocyte_small',
    analyteId: 'lymphocytes',
    name: _T({
      'uz': 'Kichik limfotsit',
      'ru': 'Малый лимфоцит',
      'en': 'Small lymphocyte',
    }),
    size: _T({'uz': '7–10 mkm', 'ru': '7–10 мкм', 'en': '7–10 µm'}),
    nucleus: _T({
      'uz': 'Yumaloq, hujayraning deyarli hammasini egallaydi; xromatin zich, to‘q',
      'ru': 'Круглое, занимает почти всю клетку; хроматин плотный, тёмный',
      'en': 'Round, fills most of the cell; dense, dark chromatin',
    }),
    cytoplasm: _T({
      'uz': 'Juda kam — yadro atrofida ingichka ko‘k hoshiya',
      'ru': 'Очень мало — узкий голубой ободок',
      'en': 'Scant — a thin blue rim',
    }),
    granules: _noGranules,
    key: _T({
      'uz': 'Eritrotsitdan biroz katta, deyarli butunlay yadro.',
      'ru': 'Чуть больше эритроцита, почти целиком ядро.',
      'en': 'A little larger than a red cell, almost all nucleus.',
    }),
    refs: [whoCells],
  ),
  CellGuide(
    id: 'lymphocyte_large',
    analyteId: 'lymphocytes',
    name: _T({
      'uz': 'Katta limfotsit',
      'ru': 'Большой лимфоцит',
      'en': 'Large lymphocyte',
    }),
    size: _T({'uz': '10–15 mkm', 'ru': '10–15 мкм', 'en': '10–15 µm'}),
    nucleus: _T({
      'uz': 'Yumaloq yoki oval, bir chetga surilgan bo‘lishi mumkin',
      'ru': 'Круглое или овальное, может быть смещено к краю',
      'en': 'Round or oval, may lie to one side',
    }),
    cytoplasm: _T({
      'uz': 'Ko‘proq, och ko‘k (tiniq)',
      'ru': 'Обильнее, светло-голубая',
      'en': 'More abundant, clear pale blue',
    }),
    granules: _T({
      'uz': 'Bo‘lishi mumkin: bir nechta yirik to‘q qizil (azurofil)',
      'ru': 'Возможны: несколько крупных тёмно-красных (азурофильных)',
      'en': 'May have a few large dark-red (azurophilic) granules',
    }),
    key: _T({
      'uz': 'Sitoplazma tiniq ko‘k, vakuolalar va “chang” donachalar yo‘q.',
      'ru':
          'Цитоплазма чисто-голубая, без вакуолей и «пылевидной» зернистости.',
      'en': 'Clear blue cytoplasm, no vacuoles or dust-like granules.',
    }),
    refs: [whoCells],
  ),
  CellGuide(
    id: 'monocyte',
    analyteId: 'monocytes',
    name: _T({'uz': 'Monotsit', 'ru': 'Моноцит', 'en': 'Monocyte'}),
    size: _T({
      'uz': '15–25 mkm — eng yirik leykotsit',
      'ru': '15–25 мкм — самый крупный лейкоцит',
      'en': '15–25 µm — the largest leukocyte',
    }),
    nucleus: _T({
      'uz': 'Shakli turlicha, ko‘pincha loviyasimon; xromatin och, ipsimon (to‘rsimon)',
      'ru': 'Разной формы, часто бобовидное; хроматин светлый, тяжистый',
      'en': 'Variable, often kidney-shaped; pale chromatin in strands',
    }),
    cytoplasm: _T({
      'uz': 'Kulrang-ko‘k; odatda vakuolalar bor',
      'ru': 'Серо-голубая; обычно есть вакуоли',
      'en': 'Grey-blue; vacuoles usually present',
    }),
    granules: _T({
      'uz': 'Juda mayda, changsimon, qizg‘ish',
      'ru': 'Мелкие, пылевидные, красноватые',
      'en': 'Fine, dust-like, reddish',
    }),
    key: _T({
      'uz': 'Katta + loviyasimon och yadro + kulrang “xira” sitoplazma.',
      'ru': 'Крупный + бобовидное светлое ядро + серая «матовая» цитоплазма.',
      'en': 'Large + pale folded nucleus + grey “ground-glass” cytoplasm.',
    }),
    seenIn: _T({
      'uz': 'Bezgakda sitoplazmada qo‘ng‘ir-qora pigment bo‘lishi mumkin.',
      'ru': 'При малярии в цитоплазме может быть буро-чёрный пигмент.',
      'en': 'In malaria, brown-black pigment may be seen in the cytoplasm.',
    }),
    refs: [whoCells],
  ),
  CellGuide(
    id: 'eosinophil',
    analyteId: 'eosinophils',
    name: _T({'uz': 'Eozinofil', 'ru': 'Эозинофил', 'en': 'Eosinophil'}),
    size: _T({'uz': '12–15 mkm', 'ru': '12–15 мкм', 'en': '12–15 µm'}),
    nucleus: _T({
      'uz': 'Odatda 2 bo‘lak (“ko‘zoynak”)',
      'ru': 'Обычно 2 сегмента («очки»)',
      'en': 'Usually 2 lobes (“spectacles”)',
    }),
    cytoplasm: _T({
      'uz': 'Donachalar tufayli deyarli ko‘rinmaydi',
      'ru': 'Почти не видна из-за гранул',
      'en': 'Barely visible because of the granules',
    }),
    granules: _T({
      'uz': 'Yirik, yumaloq, zich joylashgan, to‘q sariq-qizil',
      'ru': 'Крупные, круглые, плотно лежащие, оранжево-красные',
      'en': 'Large, round, densely packed, orange-red',
    }),
    key: _T({
      'uz': 'To‘q sariq-qizil yirik donachalar — boshqa hujayrada bunday rang yo‘q.',
      'ru': 'Крупные оранжево-красные гранулы — такого цвета больше нет.',
      'en': 'Large orange-red granules — no other cell has this colour.',
    }),
    seenIn: _T({
      'uz': 'Hujayra ba’zan yorilgan, donachalari sochilgan holda ko‘rinadi.',
      'ru': 'Иногда клетка разрушена, гранулы рассыпаны.',
      'en': 'Sometimes the cell is damaged with scattered granules.',
    }),
    refs: [whoCells],
  ),
  CellGuide(
    id: 'basophil',
    analyteId: 'basophils',
    name: _T({'uz': 'Bazofil', 'ru': 'Базофил', 'en': 'Basophil'}),
    size: _T({'uz': '11–13 mkm', 'ru': '11–13 мкм', 'en': '11–13 µm'}),
    nucleus: _T({
      'uz': 'Donachalar ostida qolib, yaxshi ko‘rinmaydi',
      'ru': 'Плохо видно — прикрыто гранулами',
      'en': 'Hard to see — covered by granules',
    }),
    cytoplasm: _T({
      'uz': 'Kam ko‘rinadi; ba’zan mayda rangsiz vakuolalar',
      'ru': 'Почти не видна; иногда мелкие бесцветные вакуоли',
      'en': 'Barely visible; sometimes small colourless vacuoles',
    }),
    granules: _T({
      'uz': 'Juda yirik, to‘q binafsha-qora; eozinofilnikidan siyrakroq',
      'ru': 'Очень крупные, тёмно-фиолетовые; реже, чем у эозинофила',
      'en': 'Very large, deep purple; less densely packed than in eosinophils',
    }),
    key: _T({
      'uz': 'Eng kam uchraydigan granulotsit; donachalar yadroni ham yopadi.',
      'ru': 'Самый редкий гранулоцит; гранулы закрывают и ядро.',
      'en': 'The rarest granulocyte; granules cover the nucleus too.',
    }),
    refs: [whoCells],
  ),
  CellGuide(
    id: 'lymphocyte_reactive',
    name: _T({
      'uz': 'Reaktiv (atipik) limfotsit',
      'ru': 'Реактивный (атипичный) лимфоцит',
      'en': 'Reactive (atypical) lymphocyte',
    }),
    size: _T({
      'uz': 'Juda turlicha, 12–18 mkm',
      'ru': 'Очень вариабелен, 12–18 мкм',
      'en': 'Very variable, 12–18 µm',
    }),
    nucleus: _T({
      'uz': 'Yumaloq yoki noto‘g‘ri, ko‘pincha bir chetda; yadrochalar ko‘rinishi mumkin',
      'ru': 'Круглое или неправильное, часто у края; могут быть видны ядрышки',
      'en': 'Round or irregular, often to one side; nucleoli may be seen',
    }),
    cytoplasm: _T({
      'uz': 'Katta limfotsitnikidan to‘qroq ko‘k; chetida to‘q hoshiya',
      'ru': 'Синее, чем у большого лимфоцита; тёмный край',
      'en': 'Darker blue than a large lymphocyte; dark edge',
    }),
    granules: _noGranules,
    key: _T({
      'uz': 'Chetga qarab to‘qlashadigan ko‘k sitoplazma, donachasiz.',
      'ru': 'Синяя цитоплазма, темнеющая к краю, без зернистости.',
      'en': 'Blue cytoplasm darkening towards the edge, no granules.',
    }),
    seenIn: _T({
      'uz': 'Virusli infeksiyalar (ayniqsa infeksion mononukleoz), ko‘kyo‘tal, qizamiq; sil, og‘ir bezgak, OITS.',
      'ru': 'Вирусные инфекции (особенно инфекционный мононуклеоз), коклюш, корь; туберкулёз, тяжёлая малярия, СПИД.',
      'en': 'Viral infections (especially infectious mononucleosis), whooping cough, measles; tuberculosis, severe malaria, AIDS.',
    }),
    refs: [CalcRef(DiffSources.who2003, '9.10.4: Atypical lymphocytes')],
  ),
  CellGuide(
    id: 'neutrophil_toxic',
    name: _T({
      'uz': 'Toksik donadorlikli neytrofil',
      'ru': 'Нейтрофил с токсической зернистостью',
      'en': 'Neutrophil with toxic granulation',
    }),
    size: _T({
      'uz': 'Neytrofil o‘lchamida',
      'ru': 'Размер нейтрофила',
      'en': 'Neutrophil-sized',
    }),
    nucleus: _T({
      'uz': 'Neytrofilniki: bo‘laklar yoki tayoqcha ko‘rinadi',
      'ru': 'Как у нейтрофила: сегменты или палочка видны',
      'en': 'Neutrophil nucleus: lobes or band visible',
    }),
    cytoplasm: _T({
      'uz': 'Och pushti yoki och ko‘k',
      'ru': 'Бледно-розовая или голубоватая',
      'en': 'Pale pink or pale blue',
    }),
    granules: _T({
      'uz': 'Juda yirik va to‘q bo‘yalgan',
      'ru': 'Очень крупные, тёмно окрашенные',
      'en': 'Very large and darkly stained',
    }),
    key: _T({
      'uz': 'Bu neytrofil — neytrofil deb sanang; toksik donadorlikni alohida qayd eting.',
      'ru': 'Это нейтрофил — считайте как нейтрофил; токсическую зернистость отметьте отдельно.',
      'en': 'It is a neutrophil — count it as one; note the toxic granulation separately.',
    }),
    seenIn: _T({
      'uz': 'Og‘ir bakterial infeksiyada yetilmagan granulotsitlar bilan birga uchraydi. Analizatorlar toksik donadorlikni aniqlay olmaydi — faqat surtmada ko‘rinadi.',
      'ru': 'Встречается при тяжёлых бактериальных инфекциях вместе с незрелыми гранулоцитами. Анализаторы её не выявляют — видна только в мазке.',
      'en': 'Seen with immature granulocytes in severe bacterial infections. Analysers cannot report it — only the smear shows it.',
    }),
    refs: [
      CalcRef(DiffSources.who2003, '9.10.4: Immature granulocytes'),
      CalcRef(DiffSources.gulati2013, 'Blood smear examination'),
    ],
  ),
  CellGuide(
    id: 'neutrophil_hypersegmented',
    name: _T({
      'uz': 'Gipersegmentlangan neytrofil',
      'ru': 'Гиперсегментированный нейтрофил',
      'en': 'Hypersegmented neutrophil',
    }),
    size: _T({
      'uz': 'Ko‘pincha oddiy neytrofildan kattaroq',
      'ru': 'Часто крупнее обычного нейтрофила',
      'en': 'Often larger than a normal neutrophil',
    }),
    nucleus: _T({
      'uz': '5–10 bo‘lak',
      'ru': '5–10 сегментов',
      'en': '5–10 lobes',
    }),
    cytoplasm: _T({
      'uz': 'Oddiy neytrofildagidek',
      'ru': 'Как у обычного нейтрофила',
      'en': 'As in a normal neutrophil',
    }),
    granules: _T({
      'uz': 'Mayda, och binafsha',
      'ru': 'Мелкие, сиреневые',
      'en': 'Fine, mauve',
    }),
    key: _T({
      'uz': 'Bo‘laklarni sanang: 5 va undan ko‘p.',
      'ru': 'Посчитайте сегменты: 5 и больше.',
      'en': 'Count the lobes: 5 or more.',
    }),
    seenIn: _T({
      'uz':
          'Foliy kislotasi yoki B12 yetishmovchiligidan makrotsitar anemiyada.',
      'ru': 'Макроцитарная анемия при дефиците фолиевой кислоты или B12.',
      'en': 'Macrocytic anaemia from folate or vitamin B12 deficiency.',
    }),
    refs: [CalcRef(DiffSources.who2003, '9.10.4: Hypersegmented neutrophils')],
  ),
  CellGuide(
    id: 'smudge_cell',
    name: _T({
      'uz': 'Ezilgan hujayra (smudge, Gumprext soyasi)',
      'ru': 'Тень Боткина–Гумпрехта (smudge cell)',
      'en': 'Smudge (basket) cell',
    }),
    size: _T({
      'uz': 'Aniq chegarasi yo‘q',
      'ru': 'Нет чётких границ',
      'en': 'No clear outline',
    }),
    nucleus: _T({
      'uz': 'Yoyilib ketgan, “surtilgan” yadro qoldig‘i',
      'ru': 'Размазанный остаток ядра',
      'en': 'A smeared remnant of the nucleus',
    }),
    cytoplasm: _T({'uz': 'Yo‘q', 'ru': 'Нет', 'en': 'Absent'}),
    granules: _noGranules,
    key: _T({
      'uz': 'Bu buzilgan leykotsit qoldig‘i, alohida hujayra turi emas.',
      'ru': 'Это остаток разрушенного лейкоцита, а не отдельный тип клеток.',
      'en': 'A remnant of a broken leukocyte, not a separate cell type.',
    }),
    seenIn: _T({
      'uz': 'Reaktiv va o‘smali limfotsitozda ham uchraydi; o‘zi surunkali limfoleykoz tashxisi emas. Qanday hisobga olish — laboratoriyangiz tartibiga ko‘ra.',
      'ru': 'Бывают и при реактивном, и при опухолевом лимфоцитозе; сами по себе не диагноз ХЛЛ. Как учитывать — по правилам вашей лаборатории.',
      'en': 'Seen in both reactive and malignant lymphocytosis; not diagnostic of CLL on their own. How to record them follows your laboratory’s procedure.',
    }),
    refs: [CalcRef(DiffSources.susman2021, 'Discussion')],
  ),
  CellGuide(
    id: 'blast',
    refer: true,
    name: _T({'uz': 'Blast', 'ru': 'Бласт', 'en': 'Blast'}),
    size: _T({
      'uz': 'Yirik, 15–25 mkm (limfoblast)',
      'ru': 'Крупный, 15–25 мкм (лимфобласт)',
      'en': 'Large, 15–25 µm (lymphoblast)',
    }),
    nucleus: _T({
      'uz': 'Katta, yumaloq, och binafsha, xromatin nozik; 1–5 yadrocha',
      'ru': 'Крупное, круглое, светлое, нежный хроматин; 1–5 ядрышек',
      'en': 'Large, round, pale, fine chromatin; 1–5 nucleoli',
    }),
    cytoplasm: _T({
      'uz': 'To‘q ko‘k ingichka hoshiya, yadro atrofida och zona',
      'ru': 'Тёмно-синий узкий ободок, светлая зона вокруг ядра',
      'en': 'Narrow dark-blue rim, clear zone around the nucleus',
    }),
    granules: _noGranules,
    key: _T({
      'uz': 'Yadrochalar + nozik xromatin + juda kam sitoplazma.',
      'ru': 'Ядрышки + нежный хроматин + очень мало цитоплазмы.',
      'en': 'Nucleoli + fine chromatin + very little cytoplasm.',
    }),
    seenIn: _T({
      'uz': 'Blast — yetilmagan qon hujayrasi; leykozda surtmada uchraydi.',
      'ru': 'Бласт — незрелая клетка крови; встречается в мазке при лейкозе.',
      'en': 'A blast is an immature blood cell; seen in blood films in leukaemia.',
    }),
    refs: [
      CalcRef(DiffSources.who2003, '9.10.4: Lymphoblasts'),
      CalcRef(DiffSources.nciDictionary, 'blast'),
      CalcRef(DiffSources.gulati2013, 'Blood smear scan; Blood smear review'),
    ],
  ),
];

CellGuide? cellGuide(String id) {
  for (final c in cellGuides) {
    if (c.id == id) return c;
  }
  return null;
}

/// Ko'p adashtiriladigan juftlik.
class Confusion {
  const Confusion({
    required this.a,
    required this.b,
    required this.rows,
    required this.tip,
    required this.refs,
    this.refer = false,
  });

  final String a;
  final String b;

  /// (belgi, A da, B da).
  final List<(LocalizedText, LocalizedText, LocalizedText)> rows;
  final LocalizedText tip;
  final List<CalcRef> refs;
  final bool refer;
}

const _size = _T({'uz': 'O‘lcham', 'ru': 'Размер', 'en': 'Size'});
const _nucleus = _T({'uz': 'Yadro', 'ru': 'Ядро', 'en': 'Nucleus'});
const _cytoplasm = _T({
  'uz': 'Sitoplazma',
  'ru': 'Цитоплазма',
  'en': 'Cytoplasm',
});
const _granules = _T({'uz': 'Donachalar', 'ru': 'Гранулы', 'en': 'Granules'});

const confusions = <Confusion>[
  Confusion(
    a: 'lymphocyte_reactive',
    b: 'monocyte',
    rows: [
      (
        _size,
        _T({'uz': '12–18 mkm', 'ru': '12–18 мкм', 'en': '12–18 µm'}),
        _T({'uz': '15–25 mkm', 'ru': '15–25 мкм', 'en': '15–25 µm'}),
      ),
      (
        _nucleus,
        _T({
          'uz': 'Yumaloq/noto‘g‘ri, xromatin zichroq; yadrocha bo‘lishi mumkin',
          'ru': 'Круглое/неправильное, хроматин плотнее; возможны ядрышки',
          'en': 'Round/irregular, denser chromatin; nucleoli possible',
        }),
        _T({
          'uz': 'Loviyasimon/burmali, xromatin och va ipsimon',
          'ru': 'Бобовидное/складчатое, хроматин светлый, тяжистый',
          'en': 'Kidney-shaped/folded, pale chromatin in strands',
        }),
      ),
      (
        _cytoplasm,
        _T({
          'uz': 'Ko‘k, chetiga qarab to‘qlashadi',
          'ru': 'Синяя, темнеет к краю',
          'en': 'Blue, darker at the edge',
        }),
        _T({
          'uz': 'Kulrang-ko‘k, vakuolali',
          'ru': 'Серо-голубая, с вакуолями',
          'en': 'Grey-blue, with vacuoles',
        }),
      ),
      (
        _granules,
        _noGranules,
        _T({
          'uz': 'Changsimon mayda qizg‘ish',
          'ru': 'Пылевидные красноватые',
          'en': 'Fine dust-like, reddish',
        }),
      ),
    ],
    tip: _T({
      'uz': 'Avval sitoplazma rangiga qarang: chetida to‘q ko‘k hoshiya — limfotsit; kulrang, vakuolali — monotsit.',
      'ru': 'Сначала цвет цитоплазмы: тёмно-синий край — лимфоцит; серая, с вакуолями — моноцит.',
      'en': 'Look at the cytoplasm first: dark-blue edge — lymphocyte; grey with vacuoles — monocyte.',
    }),
    refs: [whoCells],
  ),
  Confusion(
    a: 'neutrophil_band',
    b: 'neutrophil_segmented',
    rows: [
      (
        _nucleus,
        _T({
          'uz': 'Bitta egilgan tasma, bo‘laklarga ajralmagan',
          'ru': 'Одна изогнутая лента без сегментов',
          'en': 'One curved band, not divided into lobes',
        }),
        _T({
          'uz': '2–5 bo‘lak, ingichka ip bilan ulangan',
          'ru': '2–5 сегментов, соединённых тонкой нитью',
          'en': '2–5 lobes joined by thin strands',
        }),
      ),
      (
        _cytoplasm,
        _T({'uz': 'Och pushti', 'ru': 'Бледно-розовая', 'en': 'Pale pink'}),
        _T({'uz': 'Och pushti', 'ru': 'Бледно-розовая', 'en': 'Pale pink'}),
      ),
    ],
    tip: _T({
      'uz': 'Faqat yadroga qarang: ingichka ip bormi? Chegaraviy holatlar uchun laboratoriyangizda yozma qoida bo‘lishi kerak — hamma bir xil sanasin.',
      'ru': 'Смотрите только на ядро: есть ли тонкая нить? Для пограничных случаев в лаборатории должно быть письменное правило — чтобы все считали одинаково.',
      'en': 'Look only at the nucleus: is there a thin strand? Borderline cases need a written laboratory rule so everyone counts the same way.',
    }),
    refs: [whoCells, CalcRef(DiffSources.oskarsson2022, 'Introduction')],
  ),
  Confusion(
    a: 'basophil',
    b: 'neutrophil_toxic',
    rows: [
      (
        _nucleus,
        _T({
          'uz': 'Donachalar ostida, deyarli ko‘rinmaydi',
          'ru': 'Под гранулами, почти не видно',
          'en': 'Hidden under granules',
        }),
        _T({
          'uz': 'Neytrofil bo‘laklari aniq ko‘rinadi',
          'ru': 'Сегменты нейтрофила хорошо видны',
          'en': 'Neutrophil lobes clearly visible',
        }),
      ),
      (
        _granules,
        _T({
          'uz': 'Juda yirik, to‘q binafsha, yadro ustida ham',
          'ru': 'Очень крупные, тёмно-фиолетовые, и над ядром',
          'en': 'Very large, deep purple, also over the nucleus',
        }),
        _T({
          'uz': 'Yirik va to‘q, lekin pushti sitoplazmada',
          'ru': 'Крупные и тёмные, но в розовой цитоплазме',
          'en': 'Large and dark, but in pink cytoplasm',
        }),
      ),
      (
        _size,
        _T({'uz': '11–13 mkm', 'ru': '11–13 мкм', 'en': '11–13 µm'}),
        _T({
          'uz': 'Neytrofil o‘lchamida',
          'ru': 'Размер нейтрофила',
          'en': 'Neutrophil-sized',
        }),
      ),
    ],
    tip: _T({
      'uz': 'Bunday hujayralar ko‘p bo‘lsa va yadro ko‘rinsa — bu toksik donadorlikli neytrofillar: neytrofil deb sanang, toksik donadorlikni alohida yozing.',
      'ru': 'Если таких клеток много и ядро видно — это нейтрофилы с токсической зернистостью: считайте как нейтрофилы, зернистость отметьте отдельно.',
      'en': 'If there are many such cells and the nucleus is visible, they are neutrophils with toxic granulation: count as neutrophils and note the granulation.',
    }),
    refs: [
      whoCells,
      CalcRef(DiffSources.who2003, '9.10.4: Immature granulocytes'),
    ],
  ),
  Confusion(
    a: 'smudge_cell',
    b: 'lymphocyte_small',
    rows: [
      (
        _cytoplasm,
        _T({'uz': 'Yo‘q', 'ru': 'Нет', 'en': 'Absent'}),
        _T({
          'uz': 'Ingichka ko‘k hoshiya',
          'ru': 'Узкий голубой ободок',
          'en': 'Thin blue rim',
        }),
      ),
      (
        _nucleus,
        _T({
          'uz': 'Yoyilgan, chegarasi noaniq',
          'ru': 'Размазано, границы нечёткие',
          'en': 'Spread out, blurred outline',
        }),
        _T({
          'uz': 'Yumaloq, chegarasi aniq',
          'ru': 'Круглое, чёткие границы',
          'en': 'Round, sharp outline',
        }),
      ),
    ],
    tip: _T({
      'uz': 'Ezilgan hujayrani biror tur deb taxmin qilib sanamang. Ular ko‘p bo‘lsa — hisobotda qayd eting.',
      'ru': 'Не относите размазанную клетку к какому-либо типу наугад. Если их много — отметьте в отчёте.',
      'en': 'Do not guess a type for a smudge cell. If there are many, note it in the report.',
    }),
    refs: [CalcRef(DiffSources.susman2021, 'Discussion')],
  ),
  Confusion(
    a: 'blast',
    b: 'lymphocyte_large',
    refer: true,
    rows: [
      (
        _nucleus,
        _T({
          'uz': 'Nozik och xromatin, 1–5 yadrocha',
          'ru': 'Нежный светлый хроматин, 1–5 ядрышек',
          'en': 'Fine pale chromatin, 1–5 nucleoli',
        }),
        _T({
          'uz': 'Zichroq xromatin, odatda yadrochasiz',
          'ru': 'Хроматин плотнее, обычно без ядрышек',
          'en': 'Denser chromatin, usually no nucleoli',
        }),
      ),
      (
        _cytoplasm,
        _T({
          'uz': 'Juda kam, to‘q ko‘k, yadro atrofida och zona',
          'ru': 'Очень мало, тёмно-синяя, светлая зона у ядра',
          'en': 'Very little, dark blue, clear zone near nucleus',
        }),
        _T({
          'uz': 'Ko‘proq, och ko‘k',
          'ru': 'Больше, светло-голубая',
          'en': 'More, pale blue',
        }),
      ),
      (
        _size,
        _T({'uz': '15–25 mkm', 'ru': '15–25 мкм', 'en': '15–25 µm'}),
        _T({'uz': '10–15 mkm', 'ru': '10–15 мкм', 'en': '10–15 µm'}),
      ),
    ],
    tip: _T({
      'uz': 'Shubha bo‘lsa — o‘zingiz hal qilmang.',
      'ru': 'Если сомневаетесь — не решайте сами.',
      'en': 'If in doubt, do not decide alone.',
    }),
    refs: [
      CalcRef(DiffSources.who2003, '9.10.4: Lymphoblasts'),
      CalcRef(DiffSources.gulati2013, 'Blood smear review'),
    ],
  ),
];

/// Talqin: bitta topilma.
class DiffFinding {
  const DiffFinding({
    required this.id,
    required this.title,
    required this.what,
    required this.causes,
    required this.refs,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText what;
  final List<LocalizedText> causes;
  final List<CalcRef> refs;
}

const diffFindings = <DiffFinding>[
  DiffFinding(
    id: 'left-shift',
    title: _T({
      'uz': 'Chapga siljish',
      'ru': 'Сдвиг влево',
      'en': 'Left shift',
    }),
    what: _T({
      'uz': 'Tayoqcha yadroli va undan ham yosh granulotsitlar ulushining ortishi. Analizatorda “left shift” — sifat bayrog‘i: surtmani ko‘rish va kerak bo‘lsa qo‘lda sanash uchun signal.',
      'ru': 'Увеличение доли палочкоядерных и более молодых гранулоцитов. «Left shift» у анализатора — качественный флаг: сигнал посмотреть мазок и при необходимости посчитать вручную.',
      'en': 'A higher share of band and younger granulocytes. On an analyser, “left shift” is a qualitative flag: a signal to scan the smear and do a manual differential if needed.',
    }),
    causes: [
      _T({
        'uz': 'Og‘ir bakterial infeksiyalar (yetilmagan granulotsitlar qonga chiqadi)',
        'ru': 'Тяжёлые бактериальные инфекции (незрелые гранулоциты выходят в кровь)',
        'en': 'Severe bacterial infections (immature granulocytes enter the blood)',
      }),
      _T({
        'uz': 'Infeksiyalar; mielodisplaziya (yadro shakli o‘zgarishi)',
        'ru': 'Инфекции; миелодисплазия (изменение формы ядра)',
        'en': 'Infections; myelodysplasia (altered nuclear shape)',
      }),
      _T({
        'uz': 'Leykopeniyada tayoqchalarning nisbiy ortishi ham sepsisni tekshirishda e’tiborga olinadi',
        'ru': 'При лейкопении даже относительный рост палочкоядерных учитывают при обследовании на сепсис',
        'en': 'In leukopenia, even a relative rise in bands is given weight in a sepsis work-up',
      }),
    ],
    refs: [
      CalcRef(DiffSources.who2003, '9.10.4: Immature granulocytes'),
      CalcRef(DiffSources.oskarsson2022, 'Introduction'),
      CalcRef(DiffSources.gulati2013, 'Blood smear scan; examination'),
    ],
  ),
  DiffFinding(
    id: 'neutrophilia',
    title: _T({
      'uz': 'Neytrofiliya',
      'ru': 'Нейтрофилия',
      'en': 'Neutrophilia',
    }),
    what: _T({
      'uz': 'Neytrofillar ulushi yoki soni ortgan.',
      'ru': 'Доля или число нейтрофилов увеличены.',
      'en': 'Increased proportion or number of neutrophils.',
    }),
    causes: [
      _T({
        'uz': 'O‘tkir infeksiya (eng ko‘p uchraydigani), yallig‘lanish',
        'ru': 'Острая инфекция (самое частое), воспаление',
        'en': 'Acute infection (most common), inflammation',
      }),
      _T({
        'uz': 'O‘tkir stress, jarohat',
        'ru': 'Острый стресс, травма',
        'en': 'Acute stress, trauma',
      }),
      _T({
        'uz':
            'Revmatoid artrit, revmatik isitma, tireoidit, podagra, eklampsiya',
        'ru': 'Ревматоидный артрит, ревматическая лихорадка, тиреоидит, подагра, эклампсия',
        'en': 'Rheumatoid arthritis, rheumatic fever, thyroiditis, gout, eclampsia',
      }),
      _T({
        'uz': 'O‘tkir yoki surunkali leykoz, mieloproliferativ kasalliklar',
        'ru': 'Острый или хронический лейкоз, миелопролиферативные заболевания',
        'en': 'Acute or chronic leukaemia, myeloproliferative diseases',
      }),
      _T({'uz': 'Chekish', 'ru': 'Курение', 'en': 'Cigarette smoking'}),
    ],
    refs: [
      CalcRef(DiffSources.who2003, '9.13: Abnormal findings'),
      CalcRef(DiffSources.medlineEncyDiff, 'What abnormal results mean'),
    ],
  ),
  DiffFinding(
    id: 'neutropenia',
    title: _T({'uz': 'Neytropeniya', 'ru': 'Нейтропения', 'en': 'Neutropenia'}),
    what: _T({
      'uz': 'Qonda neytrofillar soni me’yordan kam.',
      'ru': 'Число нейтрофилов в крови ниже нормы.',
      'en': 'A lower-than-normal number of neutrophils in the blood.',
    }),
    causes: [
      _T({
        'uz': 'Og‘ir tarqalgan bakterial infeksiya (sepsis)',
        'ru': 'Тяжёлая генерализованная бактериальная инфекция (сепсис)',
        'en': 'Severe widespread bacterial infection (sepsis)',
      }),
      _T({
        'uz': 'Gripp va boshqa virusli infeksiyalar',
        'ru': 'Грипп и другие вирусные инфекции',
        'en': 'Influenza and other viral infections',
      }),
      _T({
        'uz': 'Kimyoterapiya, nurlanish',
        'ru': 'Химиотерапия, облучение',
        'en': 'Chemotherapy, radiation exposure',
      }),
      _T({
        'uz': 'Aplastik anemiya',
        'ru': 'Апластическая анемия',
        'en': 'Aplastic anaemia',
      }),
    ],
    refs: [
      CalcRef(DiffSources.nciDictionary, 'neutropenia'),
      CalcRef(DiffSources.who2003, '9.13: Abnormal findings'),
      CalcRef(DiffSources.medlineEncyDiff, 'What abnormal results mean'),
    ],
  ),
  DiffFinding(
    id: 'lymphocytosis',
    title: _T({'uz': 'Limfotsitoz', 'ru': 'Лимфоцитоз', 'en': 'Lymphocytosis'}),
    what: _T({
      'uz': 'Limfotsitlar ulushi yoki soni ortgan. Bolalarda limfotsitlar ko‘pligi yoshga bog‘liq bo‘lishi mumkin — yosh referensiga qarang.',
      'ru': 'Доля или число лимфоцитов увеличены. У детей преобладание лимфоцитов может быть возрастным — смотрите возрастной референс.',
      'en': 'Increased proportion or number of lymphocytes. In children a lymphocyte majority can be age-related — use age-specific references.',
    }),
    causes: [
      _T({
        'uz': 'Virusli infeksiyalar (qizamiq, parotit), infeksion mononukleoz, infeksion gepatit',
        'ru': 'Вирусные инфекции (корь, паротит), инфекционный мононуклеоз, инфекционный гепатит',
        'en': 'Viral infections (measles, mumps), infectious mononucleosis, infectious hepatitis',
      }),
      _T({
        'uz': 'Surunkali infeksiyalar: sil, bezgak, surunkali bakterial infeksiya',
        'ru': 'Хронические инфекции: туберкулёз, малярия, хроническая бактериальная инфекция',
        'en': 'Chronic infections: tuberculosis, malaria, chronic bacterial infection',
      }),
      _T({
        'uz': 'Limfotsitar leykoz, mielom kasalligi',
        'ru': 'Лимфолейкоз, миеломная болезнь',
        'en': 'Lymphocytic leukaemia, multiple myeloma',
      }),
    ],
    refs: [
      CalcRef(DiffSources.who2003, '9.13: Abnormal findings'),
      CalcRef(DiffSources.medlineEncyDiff, 'What abnormal results mean'),
    ],
  ),
  DiffFinding(
    id: 'lymphopenia',
    title: _T({'uz': 'Limfopeniya', 'ru': 'Лимфопения', 'en': 'Lymphopenia'}),
    what: _T({
      'uz': 'Qonda limfotsitlar soni me’yordan kam.',
      'ru': 'Число лимфоцитов в крови ниже нормы.',
      'en': 'A lower-than-normal number of lymphocytes in the blood.',
    }),
    causes: [
      _T({'uz': 'OIV/OITS', 'ru': 'ВИЧ/СПИД', 'en': 'HIV/AIDS'}),
      _T({
        'uz': 'Kimyoterapiya, nurlanish, steroidlar',
        'ru': 'Химиотерапия, облучение, стероиды',
        'en': 'Chemotherapy, radiation, steroid use',
      }),
      _T({
        'uz': 'Sepsis, leykoz; keksalik',
        'ru': 'Сепсис, лейкоз; пожилой возраст',
        'en': 'Sepsis, leukaemia; ageing',
      }),
    ],
    refs: [
      CalcRef(DiffSources.nciDictionary, 'lymphopenia'),
      CalcRef(DiffSources.who2003, '9.13: Abnormal findings'),
      CalcRef(DiffSources.medlineEncyDiff, 'What abnormal results mean'),
    ],
  ),
  DiffFinding(
    id: 'eosinophilia',
    title: _T({
      'uz': 'Eozinofiliya',
      'ru': 'Эозинофилия',
      'en': 'Eosinophilia',
    }),
    what: _T({
      'uz': 'Eozinofillar soni ortgan; ko‘pincha infeksiya yoki allergenlarga javob.',
      'ru':
          'Число эозинофилов увеличено; часто ответ на инфекцию или аллергены.',
      'en':
          'Increased eosinophils; often a response to infection or allergens.',
    }),
    causes: [
      _T({
        'uz': 'To‘qimadagi parazitlar (shistosomoz, filyarioz, ankilostomoz, askaridoz)',
        'ru':
            'Тканевые паразиты (шистосомоз, филяриоз, анкилостомоз, аскаридоз)',
        'en': 'Tissue parasites (schistosomiasis, filariasis, hookworm, ascariasis)',
      }),
      _T({
        'uz': 'Allergik reaksiyalar',
        'ru': 'Аллергические реакции',
        'en': 'Allergic reactions',
      }),
      _T({
        'uz': 'Addison kasalligi, biriktiruvchi to‘qima (kollagen-tomir) kasalliklari',
        'ru': 'Болезнь Аддисона, коллагенозы',
        'en': 'Addison disease, collagen vascular disease',
      }),
      _T({
        'uz': 'Surunkali mieloleykoz, gipereozinofil sindromlar, o‘smalar',
        'ru': 'Хронический миелолейкоз, гиперэозинофильные синдромы, опухоли',
        'en': 'Chronic myelogenous leukaemia, hypereosinophilic syndromes, cancer',
      }),
    ],
    refs: [
      CalcRef(DiffSources.nciDictionary, 'eosinophilia'),
      CalcRef(DiffSources.who2003, '9.13: Abnormal findings'),
      CalcRef(DiffSources.medlineEncyDiff, 'What abnormal results mean'),
    ],
  ),
  DiffFinding(
    id: 'monocytosis',
    title: _T({'uz': 'Monotsitoz', 'ru': 'Моноцитоз', 'en': 'Monocytosis'}),
    what: _T({
      'uz': 'Monotsitlar ulushi yoki soni ortgan.',
      'ru': 'Доля или число моноцитов увеличены.',
      'en': 'Increased proportion or number of monocytes.',
    }),
    causes: [
      _T({
        'uz': 'Sil, ich terlama (qorin tifi)',
        'ru': 'Туберкулёз, брюшной тиф',
        'en': 'Tuberculosis, typhoid fever',
      }),
      _T({
        'uz': 'Parazitar: bezgak, visseral leyshmanioz (kala-azar)',
        'ru': 'Паразитарные: малярия, висцеральный лейшманиоз (кала-азар)',
        'en': 'Parasitic: malaria, visceral leishmaniasis (kala-azar)',
      }),
      _T({
        'uz': 'Virusli: mononukleoz, parotit, qizamiq',
        'ru': 'Вирусные: мононуклеоз, паротит, корь',
        'en': 'Viral: mononucleosis, mumps, measles',
      }),
      _T({
        'uz': 'Surunkali yallig‘lanish kasalliklari, leykoz',
        'ru': 'Хронические воспалительные заболевания, лейкоз',
        'en': 'Chronic inflammatory disease, leukaemia',
      }),
    ],
    refs: [
      CalcRef(DiffSources.who2003, '9.13: Abnormal findings'),
      CalcRef(DiffSources.medlineEncyDiff, 'What abnormal results mean'),
    ],
  ),
  DiffFinding(
    id: 'basophilia',
    title: _T({'uz': 'Bazofiliya', 'ru': 'Базофилия', 'en': 'Basophilia'}),
    what: _T({
      'uz': 'Bazofillar soni ortgan. Bazofil — eng kam uchraydigan granulotsit; foiz emas, mutlaq songa qarang.',
      'ru': 'Число базофилов увеличено. Базофил — самый редкий гранулоцит; оценивайте абсолютное число, а не процент.',
      'en': 'Increased basophils. Basophils are the rarest granulocyte; judge by the absolute count rather than the percentage.',
    }),
    causes: [
      _T({
        'uz': 'Surunkali mieloleykoz, mieloproliferativ kasalliklar',
        'ru': 'Хронический миелолейкоз, миелопролиферативные заболевания',
        'en': 'Chronic myelogenous leukaemia, myeloproliferative diseases',
      }),
      _T({
        'uz': 'Allergik reaksiyalar',
        'ru': 'Аллергические реакции',
        'en': 'Allergic reactions',
      }),
      _T({
        'uz': 'Splenektomiyadan keyin; suvchechak; kollagen-tomir kasalliklari',
        'ru': 'После спленэктомии; ветряная оспа; коллагенозы',
        'en': 'After splenectomy; chickenpox; collagen vascular disease',
      }),
    ],
    refs: [
      whoCells,
      CalcRef(DiffSources.medlineEncyDiff, 'What abnormal results mean'),
      CalcRef(DiffSources.gulati2013, 'Blood smear examination'),
    ],
  ),
];

/// Manbalardagi kattalar uchun misol oraliqlari — "referens blankada"
/// qoidasini ko'rsatish uchun: manbalar bir-biridan farq qiladi.
class ExampleRange {
  const ExampleRange(this.cell, this.who, this.medline, this.classic);
  final LocalizedText cell;

  /// WHO 2003, Table 9.12 (kattalar), ulush × 100.
  final String who;

  /// MedlinePlus ency 003657, "Normal results".
  final String medline;

  /// MDH darsligi (Lyubina 1984, §50, jadval 6) — O'zbekiston
  /// laboratoriyalari blankalarida hanuz uchraydigan klassik oraliq.
  final LocalizedText classic;
}

const exampleRanges = <ExampleRange>[
  ExampleRange(
    _T({'uz': 'Neytrofillar', 'ru': 'Нейтрофилы', 'en': 'Neutrophils'}),
    '55–65',
    '40–60',
    _T({
      'uz': '45–70 (segment yadroli)',
      'ru': '45–70 (сегментоядерные)',
      'en': '45–70 (segmented)',
    }),
  ),
  ExampleRange(
    _T({'uz': 'Tayoqchalar', 'ru': 'Палочкоядерные', 'en': 'Bands'}),
    '—',
    '0–3',
    _T({'uz': '1–6', 'ru': '1–6', 'en': '1–6'}),
  ),
  ExampleRange(
    _T({'uz': 'Limfotsitlar', 'ru': 'Лимфоциты', 'en': 'Lymphocytes'}),
    '25–35',
    '20–40',
    _T({'uz': '18–40', 'ru': '18–40', 'en': '18–40'}),
  ),
  ExampleRange(
    _T({'uz': 'Monotsitlar', 'ru': 'Моноциты', 'en': 'Monocytes'}),
    '3–6',
    '2–8',
    _T({'uz': '2–9', 'ru': '2–9', 'en': '2–9'}),
  ),
  ExampleRange(
    _T({'uz': 'Eozinofillar', 'ru': 'Эозинофилы', 'en': 'Eosinophils'}),
    '2–4',
    '1–4',
    _T({'uz': '0–5', 'ru': '0–5', 'en': '0–5'}),
  ),
  ExampleRange(
    _T({'uz': 'Bazofillar', 'ru': 'Базофилы', 'en': 'Basophils'}),
    '0–1',
    '0,5–1',
    _T({'uz': '0–1', 'ru': '0–1', 'en': '0–1'}),
  ),
];

/// Surtma texnikasi bo'limi: sarlavha + bandlar + manba.
class TechniqueSection {
  const TechniqueSection({
    required this.title,
    required this.items,
    required this.refs,
    this.numbered = false,
  });

  final LocalizedText title;
  final List<LocalizedText> items;
  final List<CalcRef> refs;
  final bool numbered;
}

const techniqueSections = <TechniqueSection>[
  TechniqueSection(
    title: _T({
      'uz': 'Qon olish',
      'ru': 'Взятие крови',
      'en': 'Collecting the blood',
    }),
    items: [
      _T({
        'uz': 'Uchinchi yoki to‘rtinchi barmoqning yon tomonidan; qon erkin oqsin.',
        'ru': 'С боковой поверхности третьего или четвёртого пальца; кровь должна течь свободно.',
        'en': 'From the side of the third or fourth finger; let the blood flow freely.',
      }),
      _T({
        'uz': 'Ko‘rsatkich barmoq, bosh barmoq, yallig‘langan barmoq va quloqdan olinmaydi (quloq qonida monotsitlar ko‘p bo‘ladi).',
        'ru': 'Не брать из указательного и большого пальцев, воспалённого пальца и мочки уха (в крови уха слишком много моноцитов).',
        'en': 'Not from the index finger, thumb, an infected finger or the ear (ear blood has too many monocytes).',
      }),
      _T({
        'uz': 'Surtma 1–2 soat ichida tayyorlanmasa — EDTA (K₂) ishlating. Geparin leykotsit va trombotsitlar ko‘rinishini o‘zgartiradi — ishlatilmaydi.',
        'ru': 'Если мазок не готовится в течение 1–2 часов — используйте EDTA (K₂). Гепарин меняет вид лейкоцитов и тромбоцитов — не использовать.',
        'en': 'If the film cannot be made within 1–2 hours, use EDTA (K₂). Heparin alters leukocytes and platelets — do not use it.',
      }),
    ],
    refs: [whoFilm],
  ),
  TechniqueSection(
    numbered: true,
    title: _T({
      'uz': 'Surtma tayyorlash',
      'ru': 'Приготовление мазка',
      'en': 'Making the film',
    }),
    items: [
      _T({
        'uz': 'Toza, yog‘sizlantirilgan buyum oynasiga diametri taxminan 4 mm tomchi oling.',
        'ru': 'На чистое обезжиренное стекло нанесите каплю диаметром около 4 мм.',
        'en':
            'Put a drop of about 4 mm diameter on a clean, grease-free slide.',
      }),
      _T({
        'uz': 'Silliq qirrali surtgich oynani tomchi oldiga qo‘ying va orqaga tortib tomchiga tekkizing.',
        'ru': 'Поставьте шлифованное стекло перед каплей и подведите его назад до касания капли.',
        'en': 'Place the smooth-edged spreader in front of the drop and draw it back to touch the drop.',
      }),
      _T({
        'uz': 'Qon surtgich qirrasi bo‘ylab yoyilsin.',
        'ru': 'Дайте крови растечься вдоль края.',
        'en': 'Let the blood run along the spreader edge.',
      }),
      _T({
        'uz': 'Bir tekis harakat bilan oxirigacha suring — qon oyna oxiriga yetmasdan tugashi kerak. Anemiyada tezroq suring.',
        'ru': 'Одним плавным движением продвиньте до конца — кровь должна закончиться раньше края стекла. При анемии — быстрее.',
        'en': 'Push to the end in one smooth movement — the blood should be used up before the end. Spread faster for anaemic blood.',
      }),
      _T({
        'uz': 'Havoda quriting; bemor ma’lumotini qalam bilan qalin qismiga yozing.',
        'ru': 'Высушите на воздухе; данные пациента — карандашом на толстой части.',
        'en': 'Air-dry; label with a pencil on the thick part.',
      }),
    ],
    refs: [whoFilm],
  ),
  TechniqueSection(
    title: _T({
      'uz': 'Yaxshi surtma belgilari',
      'ru': 'Признаки хорошего мазка',
      'en': 'A good film',
    }),
    items: [
      _T({
        'uz': 'Ko‘ndalang yoki bo‘ylama chiziqlar yo‘q.',
        'ru': 'Нет поперечных и продольных полос.',
        'en': 'No lines across or along the film.',
      }),
      _T({
        'uz': 'Oxiri silliq, yirtiq-chiziqli emas.',
        'ru': 'Конец ровный, не рваный.',
        'en': 'A smooth end, not ragged.',
      }),
      _T({
        'uz': 'Juda uzun ham, juda qalin ham emas.',
        'ru': 'Не слишком длинный и не слишком толстый.',
        'en': 'Neither too long nor too thick.',
      }),
      _T({
        'uz': 'Teshiklar yo‘q (yog‘li oyna belgisi).',
        'ru': 'Нет «дыр» (признак жирного стекла).',
        'en': 'No holes (a sign of a greasy slide).',
      }),
      _T({
        'uz': 'Yomon surtma leykoformulani noto‘g‘ri chiqaradi.',
        'ru': 'Плохой мазок даёт неверную формулу.',
        'en': 'A badly spread film gives a wrong differential.',
      }),
    ],
    refs: [whoFilm],
  ),
  TechniqueSection(
    numbered: true,
    title: _T({
      'uz': 'Fiksatsiya va bo‘yash (May–Grünvald + Gimza)',
      'ru': 'Фиксация и окраска (Май-Грюнвальд + Гимза)',
      'en': 'Fixing and staining (May–Grünwald + Giemsa)',
    }),
    items: [
      _T({
        'uz': 'Metanolda 2–3 daqiqa fiksatsiya qiling.',
        'ru': 'Фиксируйте метанолом 2–3 минуты.',
        'en': 'Fix with methanol for 2–3 minutes.',
      }),
      _T({
        'uz': 'May–Grünvald 1:2 (bufer suv bilan) — 5 daqiqa.',
        'ru': 'Май-Грюнвальд 1:2 (буферной водой) — 5 минут.',
        'en': 'May–Grünwald 1 in 2 (buffered water) — 5 minutes.',
      }),
      _T({
        'uz': 'To‘kib, Gimza 1:10 — 10 daqiqa. Gimzani sekin aralashtiring: chayqatish cho‘kma beradi.',
        'ru': 'Слейте и залейте Гимзу 1:10 — 10 минут. Смешивайте медленно: встряхивание даёт осадок.',
        'en': 'Tip off and cover with Giemsa 1 in 10 — 10 minutes. Mix gently: shaking makes it precipitate.',
      }),
      _T({
        'uz': 'Bo‘yoqni oqib turgan bufer suv bilan yuving — to‘kib tashlamang (cho‘kma qoladi).',
        'ru': 'Смывайте краску струёй буферной воды — не сливайте (останется осадок).',
        'en': 'Wash the stain off with a stream of buffered water — do not tip it off (leaves deposit).',
      }),
      _T({
        'uz': 'Toza suvni 2–3 daqiqa qoldiring (differensiatsiya), pH 6,8–7,0; so‘ng quriting.',
        'ru': 'Оставьте чистую воду на 2–3 минуты (дифференцировка), pH 6,8–7,0; затем высушите.',
        'en': 'Leave clean water for 2–3 minutes to differentiate, pH 6.8–7.0; then dry.',
      }),
      _T({
        'uz': 'Suyultirilgan bo‘yoqlar faqat bir kunga tayyorlanadi; yangi partiyada vaqtni moslash kerak bo‘lishi mumkin.',
        'ru': 'Разведённые краски готовят на один день; для новой партии время может потребовать подбора.',
        'en': 'Prepare diluted stains for one day only; a new batch may need adjusted times.',
      }),
    ],
    refs: [whoFilm],
  ),
  TechniqueSection(
    title: _T({
      'uz': 'Qayerda va qanday sanash',
      'ru': 'Где и как считать',
      'en': 'Where and how to count',
    }),
    items: [
      _T({
        'uz': '×100 immersion obyektiv bilan avval leykotsitlar bir tekis tarqalganini tekshiring: yomon surtmada neytrofillar oxirida to‘planib qoladi.',
        'ru': 'С иммерсией ×100 сначала проверьте равномерность распределения лейкоцитов: в плохом мазке нейтрофилы скапливаются в конце.',
        'en': 'With the ×100 oil objective, first check leukocytes are evenly spread: in a bad film neutrophils collect at the end.',
      }),
      _T({
        'uz': 'Ingichka uchidan oldingi “o‘qiladigan” bir qavatli zonada sanang: eritrotsitlar bir-biriga tegib turadi, lekin ustma-ust emas. Qalin boshi va eng ingichka uchi yaramaydi.',
        'ru': 'Считайте в «читаемой» монослойной зоне перед тонким концом: эритроциты касаются, но не накладываются. Толстая часть и самый край не подходят.',
        'en': 'Count in the readable monolayer just before the thin end: red cells touch but do not overlap. Avoid the thick part and the very edge.',
      }),
      _T({
        'uz': 'Maydonlarni tizimli, bir yo‘nalishda almashtiring va orqaga qaytmang — bitta hujayra ikki marta sanalmasin. Raqamli morfologik analizatorlar ham surtmani “battlement” (qal’a devori tishi) yo‘li bilan ko‘radi.',
        'ru': 'Меняйте поля систематично, в одном направлении, не возвращаясь — чтобы не посчитать клетку дважды. Цифровые морфоанализаторы тоже сканируют мазок по траектории «battlement» (зубцы крепостной стены).',
        'en': 'Move field to field systematically in one direction without going back, so no cell is counted twice. Digital morphology analysers also scan in a “battlement” track.',
      }),
      _T({
        'uz': 'Odatda 100 leykotsit sanaladi. Leykotsitlar juda kam yoki ko‘p bo‘lsa, ba’zi laboratoriyalar 25 tadan 200–300 tagacha sanaydi — o‘z SOP’ingizga amal qiling.',
        'ru': 'Обычно считают 100 лейкоцитов. При очень низком или высоком числе лейкоцитов некоторые лаборатории считают от 25 до 200–300 — следуйте своей СОП.',
        'en': 'Usually 100 leukocytes are counted. With very low or high counts some laboratories count from 25 up to 200–300 — follow your SOP.',
      }),
      _T({
        'uz': 'Mutlaq son = ulush × umumiy leykotsitlar soni. Mutlaq son haqiqiy ortish yoki kamayishni ko‘rsatadi.',
        'ru': 'Абсолютное число = доля × общее число лейкоцитов. Именно оно показывает истинное увеличение или уменьшение.',
        'en': 'Absolute count = fraction × total WBC. It reflects the true increase or decrease.',
      }),
    ],
    refs: [
      whoCount,
      CalcRef(DiffSources.who2003, '9.10.4: Erythrocytes (where to look)'),
      CalcRef(DiffSources.gulati2013, 'Blood smear examination'),
      CalcRef(DiffSources.zhao2024, 'Methods'),
    ],
  ),
  // MDH darsligi (Lyubina 1984, §61) + JSST 2003 (9.13.3) — o'z so'zimiz
  // bilan; kitob matni ko'chirilmagan.
  TechniqueSection(
    title: _T({
      'uz': 'Surtma bo‘ylab yurish: chet va o‘rta',
      'ru': 'Движение по мазку: края и середина',
      'en': 'Moving along the film: edges and middle',
    }),
    items: [
      _T({
        'uz': 'Leykotsitlar surtmada bir tekis tarqalmaydi: yirikroq hujayralar (granulotsitlar, monotsitlar) chetlar va uchga, limfotsitlar o‘rtaga ko‘proq to‘planadi. Faqat o‘rtadan yoki faqat chetdan sanash formulani buzadi.',
        'ru': 'Лейкоциты распределяются по мазку неравномерно: более крупные клетки (гранулоциты, моноциты) скапливаются у краёв и конца, лимфоциты — ближе к середине. Подсчёт только в середине или только по краю искажает формулу.',
        'en': 'Leukocytes are not spread evenly: larger cells (granulocytes, monocytes) gather at the edges and tail, lymphocytes nearer the middle. Counting only the middle or only the edge distorts the differential.',
      }),
      _T({
        'uz': 'MDH darsliklaridagi usul: chet va o‘rta qismlarni qamrab oluvchi zigzag (meandr) yo‘l bilan yoki surtmaning bir necha joyida chetdan o‘rtaga ko‘ndalang yuriladi; maydonlar takrorlanmaydi.',
        'ru': 'Метод учебников СНГ: двигаться зигзагом (меандром), захватывая края и середину, или поперечными дорожками от края к середине в нескольких участках мазка; поля не повторять.',
        'en': 'The former-USSR textbook method: move in a zigzag (meander) covering edges and middle, or in cross-wise tracks from edge to middle at several places; never repeat a field.',
      }),
      _T({
        'uz': 'MDH darsliklarida odatda 200 leykotsit sanalib, har tur soni 2 ga bo‘linadi va foiz olinadi; JSST qo‘llanmasi 100 hujayra sanaydi. Qaysi biri — laboratoriyangiz SOP’i belgilaydi.',
        'ru': 'В учебниках СНГ обычно считают 200 лейкоцитов и делят число каждого типа на 2, получая процент; руководство ВОЗ считает 100 клеток. Что именно — определяет СОП вашей лаборатории.',
        'en': 'Former-USSR textbooks usually count 200 leukocytes and halve each number to get a percentage; the WHO manual counts 100 cells. Your laboratory SOP decides which.',
      }),
    ],
    refs: [lyubinaCount, whoTally],
  ),
  TechniqueSection(
    numbered: true,
    title: _T({
      'uz': 'Hisoblagich bo‘lmasa: qog‘oz jadval',
      'ru': 'Без счётчика: бумажная таблица',
      'en': 'No counter: a paper tally table',
    }),
    items: [
      _T({
        'uz': 'Qog‘ozga ustunlar chizing: N, E, B, L, M (tayoqcha va segment alohida yozilsa — ularga alohida ustun) va 10 qator.',
        'ru': 'Начертите на бумаге столбцы N, E, B, L, M (если палочко- и сегментоядерные пишутся отдельно — отдельные столбцы) и 10 строк.',
        'en': 'Draw columns N, E, B, L, M on paper (separate columns for bands and segmented cells if your report lists them) and 10 rows.',
      }),
      _T({
        'uz': 'Har bir hujayra uchun tegishli ustunga bitta chiziqcha qo‘ying; qatorda 10 ta chiziqcha bo‘lgach, keyingi qatorga o‘ting.',
        'ru': 'За каждую клетку ставьте чёрточку в нужный столбец; когда в строке 10 чёрточек — переходите на следующую.',
        'en': 'Put one stroke in the right column for each cell; after 10 strokes in a row move to the next row.',
      }),
      _T({
        'uz': '10 qator to‘lsa — 100 hujayra sanaldi: har ustun yig‘indisi foizga teng (200 sanalsa — 20 qator va yig‘indini 2 ga bo‘ling).',
        'ru': 'Заполнены 10 строк — подсчитано 100 клеток: сумма каждого столбца равна проценту (при 200 — 20 строк и сумму делят на 2).',
        'en': 'Ten rows filled means 100 cells: each column total equals the percentage (for 200 cells use 20 rows and halve the totals).',
      }),
      _T({
        'uz': 'SI tizimida ulush o‘nli kasr bilan yoziladi: 59 → 0,59; mutlaq son = ulush × leykotsitlar soni.',
        'ru': 'В системе СИ долю пишут десятичной дробью: 59 → 0,59; абсолютное число = доля × число лейкоцитов.',
        'en': 'In SI units write the fraction as a decimal: 59 → 0.59; absolute count = fraction × WBC.',
      }),
    ],
    refs: [whoTally, lyubinaCount],
  ),
  TechniqueSection(
    title: _T({
      'uz': 'Bo‘yash xatolari va tuzatish',
      'ru': 'Ошибки окраски и их исправление',
      'en': 'Staining faults and fixes',
    }),
    items: [
      _T({
        'uz': 'Juda ko‘k surtma — suv ishqoriy. Juda qizil — suv kislotali. Neytral suvni yangi tayyorlang: havoda turib kislotalashadi.',
        'ru': 'Слишком синий мазок — вода щелочная. Слишком красный — кислая. Нейтральную воду готовьте свежей: на воздухе она закисляется.',
        'en': 'Too blue — the water is alkaline. Too red — it is acidic. Make neutral water fresh: it turns acidic in air.',
      }),
      _T({
        'uz': 'Juda ko‘k bo‘lsa: 95% etanoldagi 1% bor kislotasi bilan ikki marta chayib, darhol neytral suvda yuving. Keyingi safar pH’ni biroz kislotaliroq qiling.',
        'ru': 'Если слишком синий: дважды ополосните 1% борной кислотой в 95% этаноле и сразу промойте нейтральной водой. В следующий раз — чуть более кислый pH.',
        'en': 'If too blue: rinse twice in 1% boric acid in 95% ethanol, then wash at once in neutral water. Next time use a slightly more acidic buffer.',
      }),
      _T({
        'uz': 'Qora mayda nuqtalar — bo‘yoq cho‘kmasi. Idishlarni har kuni toza yuving (kislotasiz), bo‘yoqni filtrlang.',
        'ru': 'Мелкие чёрные точки — осадок краски. Ежедневно мойте посуду (без кислоты), фильтруйте краску.',
        'en': 'Little black dots are stain deposit. Wash glassware daily (no acid) and filter the stain.',
      }),
      _T({
        'uz': 'May–Grünvald cho‘kmasi: metanolda ikki marta chayib, quriting va yangi/filtrlangan bo‘yoq bilan qayta bo‘yang.',
        'ru': 'Осадок Май-Грюнвальда: дважды ополосните метанолом, высушите и перекрасьте свежей/фильтрованной краской.',
        'en': 'May–Grünwald deposit: rinse twice in methanol, dry and re-stain with fresh or filtered stain.',
      }),
      _T({
        'uz': 'Gimza cho‘kmasi: metanol bilan chayib, darhol neytral suvda yuving va bo‘yashni boshidan takrorlang.',
        'ru': 'Осадок Гимзы: ополосните метанолом, сразу промойте нейтральной водой и повторите окраску с начала.',
        'en': 'Giemsa deposit: rinse with methanol, wash at once in neutral water and repeat the staining.',
      }),
      _T({
        'uz': 'Bo‘yoqdagi aralashmalar ham sifatni buzadi — standartlashtirilgan bo‘yoq tavsiya etiladi.',
        'ru': 'Примеси в красителях тоже портят окраску — рекомендуется стандартизованная краска.',
        'en': 'Dye impurities also spoil staining — a standardized stain is recommended.',
      }),
    ],
    refs: [
      CalcRef(
        DiffSources.who2003,
        '9.10.3: Precautions; How to remedy poor results',
      ),
    ],
  ),
  TechniqueSection(
    title: _T({
      'uz': 'Surtmadagi boshqa artefaktlar',
      'ru': 'Другие артефакты мазка',
      'en': 'Other smear artefacts',
    }),
    items: [
      _T({
        'uz': 'Leykotsit to‘dalari: ko‘pincha infeksiya (neytrofillar) yoki limfoproliferativ holat (limfotsitlar) bilan bog‘liq; analizatorda WBC ni soxta kamaytiradi va formulani qiyinlashtiradi.',
        'ru': 'Скопления лейкоцитов: чаще при инфекции (нейтрофилы) или лимфопролиферации (лимфоциты); ложно снижают WBC на анализаторе и затрудняют формулу.',
        'en': 'Leukocyte clumps: usually with infection (neutrophils) or lymphoproliferative disorders (lymphocytes); falsely lower the analyser WBC and hamper the differential.',
      }),
      _T({
        'uz': 'Qobig‘i buzilgan granulotsitlar va “xira” eritrotsitlar giperlipidemiyaga ishora qilishi mumkin.',
        'ru': 'Повреждённые гранулоциты без оболочки и «размытые» эритроциты могут указывать на гиперлипидемию.',
        'en': 'Damaged granulocytes and fuzzy-looking red cells may suggest hyperlipidaemia.',
      }),
      _T({
        'uz': 'Ezilgan hujayralar (smudge) — buzilgan leykotsit qoldiqlari; “Hujayralar” bo‘limiga qarang.',
        'ru': 'Размазанные клетки (smudge) — остатки разрушенных лейкоцитов; см. раздел «Клетки».',
        'en': 'Smudge cells are remnants of broken leukocytes; see “Cells”.',
      }),
    ],
    refs: [
      CalcRef(DiffSources.gulati2013, 'Blood smear examination'),
      CalcRef(DiffSources.susman2021, 'Discussion'),
    ],
  ),
];
