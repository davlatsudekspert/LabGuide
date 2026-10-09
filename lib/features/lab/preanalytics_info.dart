/// Preanalitika: probirkalar tartibi va qon olishdagi asosiy qoidalar.
/// Manba: WHO guidelines on drawing blood: best practices in phlebotomy.
/// WHO, 2010 (ISBN 978 92 4 159922 1) — to'liq matn o'qib tekshirildi;
/// © WHO 2010, all rights reserved — jadval ko'chirilmagan, faktlar o'z
/// so'zlarimiz bilan, joyi ko'rsatilgan (docs/DECISIONS.md, D-23).
library;

import 'package:material_ui/material_ui.dart';

import '../content/content_model.dart';
import '../tools/calc_info.dart';

class DrawTube {
  const DrawTube({
    required this.name,
    required this.cap,
    required this.colors,
    this.note,
  });

  final LocalizedText name;

  /// Odatdagi qopqoq rangi (manbadagidek) — matn bilan ham beriladi.
  final LocalizedText cap;

  /// Rang belgisi uchun (bitta yoki ikkita — chiziqli/aralash qopqoq).
  /// Bo'sh — manbada rang ko'rsatilmagan.
  final List<Color> colors;
  final LocalizedText? note;
}

/// WHO 2010, 2.2.3 (8-qadam) va 2.3-jadval: plastik vakuum probirkalar
/// uchun tavsiya etilgan tartib (NCCLS 2003 konsensusi asosida).
const drawOrder = <DrawTube>[
  DrawTube(
    name: LocalizedText({
      'uz': 'Gemokultura (qon ekish) flakoni',
      'ru': 'Флакон для гемокультуры',
      'en': 'Blood culture bottle',
    }),
    cap: LocalizedText({
      'uz': 'sariq-qora chiziqli',
      'ru': 'жёлто-чёрный полосатый',
      'en': 'yellow-black striped',
    }),
    colors: [Color(0xFFE8C21A), Color(0xFF222222)],
    note: LocalizedText({
      'uz': 'Ozuqa muhiti (bulyon)',
      'ru': 'Питательная среда (бульон)',
      'en': 'Broth mixture',
    }),
  ),
  DrawTube(
    name: LocalizedText({
      'uz': 'Qo‘shimchasiz probirka',
      'ru': 'Пробирка без добавок',
      'en': 'Non-additive tube',
    }),
    cap: LocalizedText({
      'uz': 'rang ko‘rsatilmagan',
      'ru': 'цвет не указан',
      'en': 'color not specified',
    }),
    colors: [],
  ),
  DrawTube(
    name: LocalizedText({
      'uz': 'Koagulyatsiya probirkasi — natriy sitrat',
      'ru': 'Коагулологическая пробирка — цитрат натрия',
      'en': 'Coagulation tube — sodium citrate',
    }),
    cap: LocalizedText({'uz': 'och ko‘k', 'ru': 'голубая', 'en': 'light blue'}),
    colors: [Color(0xFF8EC9F0)],
    note: LocalizedText({
      'uz': 'To‘liq to‘ldirilishi shart',
      'ru': 'Требуется полное заполнение',
      'en': 'Requires a full draw',
    }),
  ),
  DrawTube(
    name: LocalizedText({
      'uz': 'Ivish faollashtiruvchisi bilan (zardob)',
      'ru': 'С активатором свёртывания (сыворотка)',
      'en': 'Clot activator (serum)',
    }),
    cap: LocalizedText({'uz': 'qizil', 'ru': 'красная', 'en': 'red'}),
    colors: [Color(0xFFD6403A)],
  ),
  DrawTube(
    name: LocalizedText({
      'uz': 'Zardob ajratuvchi probirka (gel bilan)',
      'ru': 'Пробирка с разделительным гелем (сыворотка)',
      'en': 'Serum separator tube (gel)',
    }),
    cap: LocalizedText({
      'uz': 'qizil-kulrang (“yo‘lbars”) yoki tilla rang',
      'ru': 'красно-серая («тигровая») или золотистая',
      'en': 'red-grey (“tiger”) or gold',
    }),
    colors: [Color(0xFFD6403A), Color(0xFFE3B23C)],
    note: LocalizedText({
      'uz': 'Tubida gel bor',
      'ru': 'Гель на дне',
      'en': 'Gel at the bottom',
    }),
  ),
  DrawTube(
    name: LocalizedText({
      'uz': 'Geparin (natriy yoki litiy geparin)',
      'ru': 'Гепарин (натрия или лития гепарин)',
      'en': 'Heparin (sodium or lithium heparin)',
    }),
    cap: LocalizedText({
      'uz': 'to‘q yashil',
      'ru': 'тёмно-зелёная',
      'en': 'dark green',
    }),
    colors: [Color(0xFF1E6B45)],
  ),
  DrawTube(
    name: LocalizedText({
      'uz': 'Plazma ajratuvchi (PST): litiy geparin + gel',
      'ru': 'Пробирка PST: лития гепарин + гель',
      'en': 'PST: lithium heparin + gel separator',
    }),
    cap: LocalizedText({
      'uz': 'och yashil',
      'ru': 'светло-зелёная',
      'en': 'light green',
    }),
    colors: [Color(0xFF8BC98A)],
  ),
  DrawTube(
    name: LocalizedText({'uz': 'EDTA', 'ru': 'ЭДТА', 'en': 'EDTA'}),
    cap: LocalizedText({'uz': 'binafsha', 'ru': 'фиолетовая', 'en': 'purple'}),
    colors: [Color(0xFF7B4BA3)],
    note: LocalizedText({
      'uz':
          'Gematologiya, qon banki (moslik sinovi); to‘liq to‘ldirilishi shart',
      'ru':
          'Гематология, банк крови (проба на совместимость); полное заполнение',
      'en': 'Haematology, blood bank (cross-match); requires a full draw',
    }),
  ),
  DrawTube(
    name: LocalizedText({
      'uz': 'ACD (kislotali sitrat-dekstroza)',
      'ru': 'ACD (кислый цитрат-декстроза)',
      'en': 'ACD (acid-citrate-dextrose)',
    }),
    cap: LocalizedText({
      'uz': 'och sariq',
      'ru': 'бледно-жёлтая',
      'en': 'pale yellow',
    }),
    colors: [Color(0xFFF3E58A)],
  ),
  DrawTube(
    name: LocalizedText({
      'uz': 'Natriy ftorid + kaliy oksalat',
      'ru': 'Фторид натрия + оксалат калия',
      'en': 'Sodium fluoride + potassium oxalate',
    }),
    cap: LocalizedText({
      'uz': 'och kulrang',
      'ru': 'светло-серая',
      'en': 'light grey',
    }),
    colors: [Color(0xFFC7CCD1)],
    note: LocalizedText({
      'uz': 'To‘liq to‘ldirilishi shart (kam to‘ldirilsa gemoliz bo‘lishi mumkin)',
      'ru': 'Полное заполнение (при недоборе возможен гемолиз)',
      'en': 'Requires a full draw (a short draw may cause hemolysis)',
    }),
  ),
];

/// 2.3-jadval izohlari va kapillyar tartib (7.1.3). Aralashtirish qoidasi
/// alohida — [mixingRules].
const drawOrderNotes = <LocalizedText>[
  LocalizedText({
    'uz':
        'Qopqoq ranglari va qo‘shimchalar ishlab chiqaruvchiga qarab farq '
        'qiladi — tartibni laboratoriyangiz bilan tekshiring.',
    'ru':
        'Цвета крышек и добавки различаются у производителей — сверяйте '
        'порядок с вашей лабораторией.',
    'en':
        'Cap colors and additives vary by manufacturer — confirm the order '
        'with your laboratory.',
  }),
  LocalizedText({
    'uz':
        'Faqat oddiy koagulyatsiya tahlili buyurilgan bo‘lsa, bitta och ko‘k '
        'probirka olinishi mumkin; to‘qima suyuqligi bilan ifloslanish '
        'xavotiri bo‘lsa, undan oldin qo‘shimchasiz probirka olinadi.',
    'ru':
        'Если назначена только рутинная коагулограмма, можно взять одну '
        'голубую пробирку; при опасении загрязнения тканевой жидкостью перед '
        'ней берут пробирку без добавок.',
    'en':
        'If a routine coagulation assay is the only test, a single light-blue '
        'tube may be drawn; if tissue-fluid contamination is a concern, draw a '
        'non-additive tube before it.',
  }),
  LocalizedText({
    'uz':
        'Kapillyar (barmoq/tovon) qon olishda tartib teskari: avval '
        'gematologiya, so‘ng biokimyo va qon banki namunalari.',
    'ru':
        'При капиллярном взятии порядок обратный: сначала гематология, затем '
        'биохимия и банк крови.',
    'en':
        'For capillary (skin-puncture) sampling the order is reversed: '
        'hematology first, then chemistry and blood bank.',
  }),
];

/// 1.1.1: gemolizga olib keluvchi omillar.
const haemolysisCauses = <LocalizedText>[
  LocalizedText({
    'uz': 'Juda ingichka (23G va undan ingichka) yoki tomirga nisbatan juda yo‘g‘on igna',
    'ru': 'Слишком тонкая (23G и тоньше) или слишком толстая для вены игла',
    'en': 'A needle too fine (23 gauge or smaller) or too large for the vessel',
  }),
  LocalizedText({
    'uz': 'Shprits porshenini bosib, qonni probirkaga majburan haydash',
    'ru': 'Выдавливание крови из шприца в пробирку нажатием на поршень',
    'en': 'Forcing blood from a syringe into the tube with the plunger',
  }),
  LocalizedText({
    'uz': 'Vena ichidagi yoki markaziy kateterdan qon olish',
    'ru': 'Взятие крови из внутривенного или центрального катетера',
    'en': 'Drawing from an intravenous or central line',
  }),
  LocalizedText({
    'uz':
        'Probirkani kam to‘ldirish (antikoagulyant:qon nisbati 1:9 dan katta)',
    'ru':
        'Недозаполнение пробирки (соотношение антикоагулянт:кровь больше 1:9)',
    'en': 'Underfilling a tube (anticoagulant-to-blood ratio above 1:9)',
  }),
  LocalizedText({
    'uz': 'Qo‘lda qayta to‘ldirilgan probirkalarni qayta ishlatish',
    'ru': 'Повторное использование пробирок, заполненных вручную',
    'en': 'Reusing tubes that were refilled by hand',
  }),
  LocalizedText({
    'uz': 'Probirkani juda qattiq chayqatish',
    'ru': 'Слишком интенсивное перемешивание пробирки',
    'en': 'Mixing a tube too vigorously',
  }),
  LocalizedText({
    'uz': 'Spirt yoki dezinfektant qurimasidan punksiya qilish',
    'ru': 'Пункция до высыхания спирта или антисептика',
    'en': 'Not letting alcohol or disinfectant dry',
  }),
  LocalizedText({
    'uz': 'Juda kuchli vakuum',
    'ru': 'Слишком сильный вакуум',
    'en': 'Too great a vacuum',
  }),
];

/// 2.2.3 (3, 6-qadamlar): jgut.
const tourniquetRules = <LocalizedText>[
  LocalizedText({
    'uz': 'Jgut punksiya joyidan taxminan 4–5 barmoq eni yuqoriga qo‘yiladi.',
    'ru': 'Жгут накладывают примерно на 4–5 пальцев выше места пункции.',
    'en': 'Apply the tourniquet about 4–5 finger widths above the site.',
  }),
  LocalizedText({
    'uz':
        'Jgut ignani chiqarishdan OLDIN bo‘shatiladi; ba’zi qo‘llanmalar uni '
        'qon oqimi boshlanishi bilan va har holda 2 daqiqa bo‘lmasidan oldin '
        'olishni tavsiya qiladi.',
    'ru':
        'Жгут снимают ДО извлечения иглы; некоторые руководства советуют '
        'снимать его, как только пошла кровь, и всегда раньше 2 минут.',
    'en':
        'Release the tourniquet BEFORE withdrawing the needle; some guidelines '
        'suggest removing it as soon as blood flows, and always before 2 '
        'minutes.',
  }),
];

/// 2.2.3 (2, 9-qadamlar): bemorni aniqlash va yorliq.
const identificationRules = <LocalizedText>[
  LocalizedText({
    'uz':
        'Bemordan to‘liq ismini aytishni so‘rang va yo‘llanma uning shaxsiga '
        'mosligini tekshiring.',
    'ru':
        'Попросите пациента назвать полное имя и проверьте, что направление '
        'соответствует его личности.',
    'en':
        'Ask the patient to state their full name and check that the request '
        'form matches their identity.',
  }),
  LocalizedText({
    'uz':
        'Yorliqda odatda: ism va familiya, tibbiy karta raqami, tug‘ilgan sana, '
        'qon olingan sana va vaqt.',
    'ru':
        'На этикетке обычно: имя и фамилия, номер карты, дата рождения, дата и '
        'время взятия крови.',
    'en':
        'Labels typically carry first and last names, file number, date of '
        'birth, and the date and time of collection.',
  }),
  LocalizedText({
    'uz': 'Jo‘natishdan oldin probirka yorliqlari va yo‘llanmalarni qayta tekshiring.',
    'ru': 'Перед отправкой ещё раз сверьте этикетки пробирок и направления.',
    'en': 'Recheck tube labels and forms before dispatch.',
  }),
];

// ---------------------------------------------------------------------------
// Kitoblardan kelgan bloklar (Selivanov 2005, Aripova 2007, Lyubina 1984) —
// har raqam rasmiy manbadan (JSST 2010, WHO/DIL/LAB/99.1, MedlinePlus)
// tekshirilgan; kitob faqat qo'shimcha manba. Tasdiqlanmagan raqam yo'q.
// ---------------------------------------------------------------------------

/// Manbali band: matn + manbalar (ekranda [n] bilan).
class PreItem {
  const PreItem(this.text, this.refs);
  final LocalizedText text;
  final List<CalcRef> refs;
}

const _who10Mix = CalcRef(
  CalcSources.whoPhlebotomy2010,
  '2.2.3 Step 7; Table 2.3 note c (p. 15)',
);
const _dilMix = CalcRef(CalcSources.whoDilLab99, '1.3.1 (Page 7)');
const _who10Table = CalcRef(CalcSources.whoPhlebotomy2010, 'Table 2.3 (p. 15)');

/// Probirkani aralashtirish. JSST aniq ag'darishlar sonini bermaydi —
/// shuning uchun ilova ham son yozmaydi.
const mixingRules = <PreItem>[
  PreItem(
    LocalizedText({
      'uz':
          'Qo‘shimchali probirkani to‘ldirilgandan keyin darhol yumshoq '
          'ag‘darib aralashtiring: qon qo‘shimcha bilan yaxshi aralashmasa, '
          'natija noto‘g‘ri chiqishi mumkin. Chayqatmang va ko‘pik hosil '
          'qilmang.',
      'ru':
          'Пробирку с добавкой сразу после заполнения аккуратно '
          'переворачивайте: при плохом смешивании крови с добавкой результат '
          'может быть ошибочным. Не встряхивайте и не допускайте '
          'вспенивания.',
      'en':
          'Gently invert a tube with an additive straight after filling: '
          'blood that is not mixed well with the additive can give wrong '
          'results. Do not shake it or let it foam.',
    }),
    [_who10Mix, _dilMix],
  ),
  PreItem(
    LocalizedText({
      'uz':
          'Ag‘darishlar soni JSST qo‘llanmalarida berilmagan — u '
          'laboratoriyangiz va probirka ishlab chiqaruvchisi ko‘rsatmasiga '
          'ko‘ra belgilanadi.',
      'ru':
          'Число переворотов в руководствах ВОЗ не указано — его задают '
          'ваша лаборатория и производитель пробирок.',
      'en':
          'WHO guidance does not give a number of inversions — it is set by '
          'your laboratory and the tube manufacturer.',
    }),
    [_who10Mix],
  ),
  PreItem(
    LocalizedText({
      'uz':
          'Ayrim MDH qo‘llanmalarida EDTA probirkani “3–5 daqiqa yaxshilab '
          'aralashtirish” deyilgan. JSST esa yumshoq ag‘darishni tavsiya '
          'qiladi va juda qattiq aralashtirishni gemoliz sababi deb sanaydi.',
      'ru':
          'В некоторых руководствах СНГ сказано «тщательно перемешать '
          'пробирку с ЭДТА 3–5 минут». ВОЗ рекомендует аккуратное '
          'переворачивание и относит слишком интенсивное перемешивание к '
          'причинам гемолиза.',
      'en':
          'Some CIS manuals say to “mix the EDTA tube thoroughly for 3–5 '
          'minutes”. WHO recommends gentle inversion and lists mixing too '
          'vigorously as a cause of haemolysis.',
    }),
    [
      CalcRef(CalcSources.selivanov2005, 'Приложение: общий анализ крови'),
      CalcRef(CalcSources.whoPhlebotomy2010, '1.1.1'),
    ],
  ),
];

/// Qaysi tahlilga qaysi probirka. [tube] — [drawOrder] dagi indeks (rang
/// va tartib shu yerdan); `null` — JSST jadvalida alohida probirka yo'q.
class TubeForTest {
  const TubeForTest({
    required this.tests,
    required this.tube,
    required this.note,
    required this.refs,
  });

  final LocalizedText tests;
  final int? tube;
  final LocalizedText note;
  final List<CalcRef> refs;
}

const tubeForTest = <TubeForTest>[
  TubeForTest(
    tests: LocalizedText({
      'uz': 'Umumiy qon tahlili, leykoformula, retikulotsitlar',
      'ru': 'Общий анализ крови, лейкоформула, ретикулоциты',
      'en': 'Complete blood count, differential, reticulocytes',
    }),
    tube: 7,
    note: LocalizedText({
      'uz':
          'Surtma 3 soat ichida tayyorlanadi; EDTA qon sovitgichda '
          'saqlanmaydi.',
      'ru':
          'Мазок готовят в течение 3 часов; кровь с ЭДТА не хранят в '
          'холодильнике.',
      'en': 'Make the smear within 3 hours; do not refrigerate EDTA blood.',
    }),
    refs: [
      _who10Table,
      CalcRef(
        CalcSources.whoDilLab99,
        '5.1 Differential leucocyte count (Page 29)',
      ),
      CalcRef(CalcSources.selivanov2005, '1.2.1'),
    ],
  ),
  TubeForTest(
    tests: LocalizedText({
      'uz': 'Glikirlangan gemoglobin (HbA1c)',
      'ru': 'Гликированный гемоглобин (HbA1c)',
      'en': 'Glycated haemoglobin (HbA1c)',
    }),
    tube: 7,
    note: LocalizedText({
      'uz': 'Butun qon (EDTA).',
      'ru': 'Цельная кровь (ЭДТА).',
      'en': 'Whole blood (EDTA).',
    }),
    refs: [
      CalcRef(CalcSources.whoDilLab99, '5.1 Haemoglobin A1c (Page 32)'),
      CalcRef(CalcSources.selivanov2005, '1.2.1'),
    ],
  ),
  TubeForTest(
    tests: LocalizedText({
      'uz': 'Koagulogramma: PT/INR, APTV, fibrinogen',
      'ru': 'Коагулограмма: ПВ/МНО, АЧТВ, фибриноген',
      'en': 'Coagulation: PT/INR, aPTT, fibrinogen',
    }),
    tube: 2,
    note: LocalizedText({
      'uz': 'Sitrat : qon = 1 : 9; probirka to‘liq to‘ldiriladi.',
      'ru': 'Цитрат : кровь = 1 : 9; пробирку заполняют полностью.',
      'en': 'Citrate : blood = 1 : 9; fill the tube completely.',
    }),
    refs: [
      _who10Table,
      CalcRef(CalcSources.whoDilLab99, '1.1.4.2 (Page 5)'),
      CalcRef(CalcSources.selivanov2005, '1.2.2'),
    ],
  ),
  TubeForTest(
    tests: LocalizedText({
      'uz': 'EChT (Vestergren usuli)',
      'ru': 'СОЭ (метод Вестергрена)',
      'en': 'ESR (Westergren method)',
    }),
    tube: null,
    note: LocalizedText({
      'uz':
          'Sitrat : qon = 1 : 4 (koagulogrammadan farqli nisbat). Qopqoq '
          'rangi JSST jadvalida berilmagan.',
      'ru':
          'Цитрат : кровь = 1 : 4 (иное соотношение, чем для коагулограммы). '
          'Цвет крышки в таблице ВОЗ не указан.',
      'en':
          'Citrate : blood = 1 : 4 (a different ratio from coagulation). The '
          'WHO table gives no cap colour.',
    }),
    refs: [CalcRef(CalcSources.whoDilLab99, '1.1.4.2 (Page 5)')],
  ),
  TubeForTest(
    tests: LocalizedText({'uz': 'Glyukoza', 'ru': 'Глюкоза', 'en': 'Glucose'}),
    tube: 9,
    note: LocalizedText({
      'uz':
          'Natriy ftorid glikolizni to‘xtatadi; probirka to‘liq to‘ldiriladi.',
      'ru':
          'Фторид натрия останавливает гликолиз; пробирку заполняют '
          'полностью.',
      'en': 'Sodium fluoride stops glycolysis; fill the tube completely.',
    }),
    refs: [_who10Table, CalcRef(CalcSources.selivanov2005, '1.2.3')],
  ),
  TubeForTest(
    tests: LocalizedText({
      'uz': 'Biokimyo, gormonlar, immunologiya va serologiya',
      'ru': 'Биохимия, гормоны, иммунология и серология',
      'en': 'Chemistry, hormones, immunology and serology',
    }),
    tube: 3,
    note: LocalizedText({
      'uz':
          'Zardob: ivish faollashtiruvchili yoki gelli probirka; biokimyo '
          'uchun litiy geparinli plazma (PST) ham ishlatiladi.',
      'ru':
          'Сыворотка: пробирка с активатором свёртывания или с гелем; для '
          'биохимии используют и плазму с гепарином лития (PST).',
      'en':
          'Serum: clot-activator or gel tube; lithium-heparin plasma (PST) '
          'is also used for chemistry.',
    }),
    refs: [_who10Table, CalcRef(CalcSources.selivanov2005, 'Приложение')],
  ),
  TubeForTest(
    tests: LocalizedText({'uz': 'Ammiak', 'ru': 'Аммиак', 'en': 'Ammonia'}),
    tube: 7,
    note: LocalizedText({
      'uz':
          'EDTA plazma (JSST 2010: natriy yoki litiy geparin ham bo‘ladi); '
          'ammoniy geparin ishlatilmaydi; EDTA da 15 daqiqa barqaror.',
      'ru':
          'Плазма с ЭДТА (ВОЗ 2010: допустим и гепарин натрия или лития); '
          'гепарин аммония не используют; в ЭДТА стабилен 15 минут.',
      'en':
          'EDTA plasma (WHO 2010: sodium or lithium heparin also acceptable); '
          'never ammonium heparin; stable 15 minutes in EDTA.',
    }),
    refs: [
      CalcRef(CalcSources.whoDilLab99, '5.1 Ammonia (Page 21)'),
      _who10Table,
    ],
  ),
  TubeForTest(
    tests: LocalizedText({
      'uz': 'Litiy (dori darajasi)',
      'ru': 'Литий (уровень препарата)',
      'en': 'Lithium (drug level)',
    }),
    tube: 5,
    note: LocalizedText({
      'uz': 'Natriy geparin — litiy geparin emas.',
      'ru': 'Гепарин натрия — не гепарин лития.',
      'en': 'Sodium heparin — not lithium heparin.',
    }),
    refs: [_who10Table],
  ),
  TubeForTest(
    tests: LocalizedText({
      'uz': 'PZR (DNK/RNK qonda)',
      'ru': 'ПЦР (ДНК/РНК в крови)',
      'en': 'PCR (DNA/RNA in blood)',
    }),
    tube: 7,
    note: LocalizedText({
      'uz':
          'EDTA butun qon; geparin ishlatilmaydi — u PZR fermentini (Taq '
          'polimeraza) to‘xtatadi.',
      'ru':
          'Цельная кровь с ЭДТА; гепарин не используют — он подавляет '
          'фермент ПЦР (Taq-полимеразу).',
      'en':
          'EDTA whole blood; no heparin — it inhibits the PCR enzyme (Taq '
          'polymerase).',
    }),
    refs: [
      CalcRef(CalcSources.whoDilLab99, '1.2.2 d (Page 7); 5.1 PCR (Page 29)'),
      CalcRef(CalcSources.selivanov2005, '1.2.4; 7.12'),
    ],
  ),
  TubeForTest(
    tests: LocalizedText({
      'uz': 'HLA-tiplash, otalikni aniqlash, DNK tadqiqotlari',
      'ru': 'HLA-типирование, установление отцовства, ДНК-исследования',
      'en': 'HLA typing, paternity testing, DNA studies',
    }),
    tube: 8,
    note: LocalizedText({
      'uz': 'ACD probirkasi.',
      'ru': 'Пробирка ACD.',
      'en': 'ACD tube.',
    }),
    refs: [_who10Table],
  ),
  TubeForTest(
    tests: LocalizedText({
      'uz': 'Qon ekish (gemokultura)',
      'ru': 'Посев крови (гемокультура)',
      'en': 'Blood culture',
    }),
    tube: 0,
    note: LocalizedText({
      'uz': 'Har doim birinchi olinadi.',
      'ru': 'Всегда берут первым.',
      'en': 'Always drawn first.',
    }),
    refs: [_who10Table],
  ),
];

/// Ajratilgan zardob/plazmaning barqarorligi: −20 °C, 4–8 °C, 20–25 °C.
/// Qiymat kodlari: `7d`, `6w`, `3m`, `1y`, `1h`, oraliq `3m–2y`.
class StabilityRow {
  const StabilityRow(
    this.analyte,
    this.frozen,
    this.fridge,
    this.room,
    this.page, {
    this.note,
  });

  final LocalizedText analyte;
  final String frozen;
  final String fridge;
  final String room;

  /// WHO/DIL/LAB/99.1 dagi sahifa (“Page N”).
  final int page;
  final LocalizedText? note;
}

const stabilityRows = <StabilityRow>[
  StabilityRow(
    LocalizedText({'uz': 'ALT', 'ru': 'АЛТ', 'en': 'ALT'}),
    '7d',
    '7d',
    '3d',
    21,
  ),
  StabilityRow(
    LocalizedText({'uz': 'AST', 'ru': 'АСТ', 'en': 'AST'}),
    '3m',
    '7d',
    '4d',
    23,
  ),
  StabilityRow(
    LocalizedText({
      'uz': 'Bilirubin (umumiy)',
      'ru': 'Билирубин (общий)',
      'en': 'Bilirubin (total)',
    }),
    '6m',
    '7d',
    '1d',
    24,
    note: LocalizedText({
      'uz': '8 soatdan uzoq saqlansa — qorong‘ida.',
      'ru': 'При хранении дольше 8 часов — в темноте.',
      'en': 'Keep in the dark if stored over 8 hours.',
    }),
  ),
  StabilityRow(
    LocalizedText({'uz': 'Kaliy', 'ru': 'Калий', 'en': 'Potassium'}),
    '1y',
    '6w',
    '6w',
    39,
    note: LocalizedText({
      'uz':
          'Ajratilmagan qonda xona haroratida 1 soatda ko‘tariladi; '
          'gemoliz ham oshiradi.',
      'ru':
          'В неразделённой крови при комнатной температуре повышается за '
          '1 час; гемолиз также повышает.',
      'en':
          'Rises within 1 hour in unseparated blood at room temperature; '
          'haemolysis also raises it.',
    }),
  ),
  StabilityRow(
    LocalizedText({
      'uz': 'Kalsiy (umumiy)',
      'ru': 'Кальций (общий)',
      'en': 'Calcium (total)',
    }),
    '8m',
    '3w',
    '7d',
    25,
  ),
  StabilityRow(
    LocalizedText({'uz': 'Kreatinin', 'ru': 'Креатинин', 'en': 'Creatinine'}),
    '3m',
    '7d',
    '7d',
    28,
  ),
  StabilityRow(
    LocalizedText({'uz': 'Mochevina', 'ru': 'Мочевина', 'en': 'Urea'}),
    '1y',
    '7d',
    '7d',
    44,
  ),
  StabilityRow(
    LocalizedText({
      'uz': 'Xolesterin (umumiy)',
      'ru': 'Холестерин (общий)',
      'en': 'Cholesterol (total)',
    }),
    '3m',
    '7d',
    '7d',
    26,
  ),
  StabilityRow(
    LocalizedText({'uz': 'TTG', 'ru': 'ТТГ', 'en': 'TSH'}),
    '3m',
    '3d',
    '1d',
    42,
  ),
  StabilityRow(
    LocalizedText({'uz': 'Erkin T4', 'ru': 'Свободный Т4', 'en': 'Free T4'}),
    '3m',
    '8d',
    '2d',
    43,
  ),
  StabilityRow(
    LocalizedText({'uz': 'Prolaktin', 'ru': 'Пролактин', 'en': 'Prolactin'}),
    '1y',
    '6d',
    '5d',
    40,
  ),
  StabilityRow(
    LocalizedText({'uz': 'Estradiol', 'ru': 'Эстрадиол', 'en': 'Estradiol'}),
    '1y',
    '3d',
    '1d',
    30,
  ),
  StabilityRow(
    LocalizedText({'uz': 'Kortizol', 'ru': 'Кортизол', 'en': 'Cortisol'}),
    '3m',
    '7d',
    '7d',
    27,
  ),
  StabilityRow(
    LocalizedText({
      'uz': 'PSA (umumiy)',
      'ru': 'ПСА (общий)',
      'en': 'PSA (total)',
    }),
    '3m–2y',
    '30d',
    '7d',
    40,
  ),
  StabilityRow(
    LocalizedText({'uz': 'KEA (CEA)', 'ru': 'РЭА', 'en': 'CEA'}),
    '6m',
    '7d',
    '1d',
    25,
  ),
];

/// `7d` → “7 kun” / “7 сут” / “7 d”; `3m–2y` — oraliq.
String formatStability(String code, String lang) {
  const units = {
    'uz': {'h': 'soat', 'd': 'kun', 'w': 'hafta', 'm': 'oy', 'y': 'yil'},
    'ru': {'h': 'ч', 'd': 'сут', 'w': 'нед', 'm': 'мес', 'y': 'г'},
    'en': {'h': 'h', 'd': 'd', 'w': 'wk', 'm': 'mo', 'y': 'y'},
  };
  final u = units[lang] ?? units['en']!;
  String one(String part) {
    final n = part.substring(0, part.length - 1);
    final unit = u[part[part.length - 1]];
    if (unit == null || int.tryParse(n) == null) {
      throw FormatException('stability code: $code');
    }
    return '$n $unit';
  }

  return code.split('–').map(one).join(' – ');
}

/// Umumiy saqlash qoidalari (WHO/DIL/LAB/99.1, 1.3 va 3.2.4).
const storageRules = <PreItem>[
  PreItem(
    LocalizedText({
      'uz':
          'Zardob olish uchun qon xona haroratida kamida 30 daqiqa ivishi '
          'kerak; ajratishda harorat 15 °C dan past va 24 °C dan yuqori '
          'bo‘lmasin.',
      'ru':
          'Для получения сыворотки кровь должна свернуться при комнатной '
          'температуре не менее 30 минут; при разделении температура не ниже '
          '15 °C и не выше 24 °C.',
      'en':
          'For serum, let blood clot at room temperature for at least 30 '
          'minutes; keep separation between 15 °C and 24 °C.',
    }),
    [CalcRef(CalcSources.whoDilLab99, '1.3.1–1.3.2 (Pages 7–8)')],
  ),
  PreItem(
    LocalizedText({
      'uz':
          'Sovitish yoki muzlatishdan oldin hujayralar zardob/plazmadan '
          'ajratiladi. Butun qon muzlatilmaydi — sentrifugadan oldin ham, '
          'keyin ham.',
      'ru':
          'Перед охлаждением или заморозкой клетки отделяют от сыворотки или '
          'плазмы. Цельную кровь не замораживают — ни до, ни после '
          'центрифугирования.',
      'en':
          'Separate cells from serum or plasma before refrigerating or '
          'freezing. Never freeze whole blood, before or after '
          'centrifugation.',
    }),
    [CalcRef(CalcSources.whoDilLab99, '1.3.3 (Page 8)')],
  ),
  PreItem(
    LocalizedText({
      'uz':
          'Ruxsat etilgan vaqt o‘tib ketsa, laboratoriya natijaga izoh '
          'yozadi yoki tahlilni rad etadi — noto‘g‘ri natija bemorga zarar '
          'keltirishi mumkin.',
      'ru':
          'Если допустимое время превышено, лаборатория делает пометку к '
          'результату или отказывается от анализа — ошибочный результат может '
          'навредить пациенту.',
      'en':
          'If the permitted time is exceeded, the laboratory adds a comment '
          'to the result or rejects the test — a wrong result can harm the '
          'patient.',
    }),
    [CalcRef(CalcSources.whoDilLab99, '3.2.4 (Pages 10–11)')],
  ),
];

/// Saqlab bo'lmaydigan yoki darhol tekshiriladigan namunalar.
const urgentSamples = <PreItem>[
  PreItem(
    LocalizedText({
      'uz': 'Ammiak — EDTA qonda atigi 15 daqiqa barqaror.',
      'ru': 'Аммиак — в крови с ЭДТА стабилен лишь 15 минут.',
      'en': 'Ammonia — stable for only 15 minutes in EDTA blood.',
    }),
    [CalcRef(CalcSources.whoDilLab99, 'Ammonia (Page 21)')],
  ),
  PreItem(
    LocalizedText({
      'uz': 'Qon gazlari — xona haroratida 15 daqiqadan kam.',
      'ru': 'Газы крови — менее 15 минут при комнатной температуре.',
      'en': 'Blood gases — under 15 minutes at room temperature.',
    }),
    [CalcRef(CalcSources.whoDilLab99, 'Blood gases (Page 24)')],
  ),
  PreItem(
    LocalizedText({
      'uz':
          'AKTG — butun qonda beqaror; plastik probirka; ajratilgan '
          'plazmada xona haroratida 1 soat, 4–8 °C da 3 soat.',
      'ru':
          'АКТГ — нестабилен в цельной крови; пластиковая пробирка; в '
          'отделённой плазме 1 час при комнатной температуре, 3 часа при '
          '4–8 °C.',
      'en':
          'ACTH — unstable in whole blood; use plastic tubes; separated '
          'plasma lasts 1 hour at room temperature and 3 hours at 4–8 °C.',
    }),
    [
      CalcRef(CalcSources.whoDilLab99, 'Corticotropin (Page 27)'),
      CalcRef(CalcSources.selivanov2005, '1.4'),
    ],
  ),
  PreItem(
    LocalizedText({
      'uz': 'EChT — 2 soat ichida qo‘yiladi, namuna saqlanmaydi.',
      'ru': 'СОЭ — ставят в течение 2 часов, образец не хранят.',
      'en': 'ESR — set up within 2 hours; the sample is not stored.',
    }),
    [
      CalcRef(
        CalcSources.whoDilLab99,
        'Erythrocyte sedimentation rate (Page 30)',
      ),
    ],
  ),
  PreItem(
    LocalizedText({
      'uz':
          'Glyukoza stabilizatorsiz qonda 10 daqiqadan boshlab kamayadi — '
          'ftoridli probirka kerak.',
      'ru':
          'Глюкоза в крови без стабилизатора начинает снижаться уже через '
          '10 минут — нужна пробирка с фторидом.',
      'en':
          'Glucose in blood without a stabiliser starts falling within 10 '
          'minutes — use a fluoride tube.',
    }),
    [CalcRef(CalcSources.whoDilLab99, 'Glucose (Page 32)'), _who10Table],
  ),
  PreItem(
    LocalizedText({
      'uz':
          'Koagulogramma — saqlanmaydi: APTV plazmada 2–8 soat, PT muddati '
          'reagentga bog‘liq (4 soatdan 1 sutkagacha).',
      'ru':
          'Коагулограмма — не хранят: АЧТВ в плазме 2–8 часов, срок для ПВ '
          'зависит от реагента (от 4 часов до 1 суток).',
      'en':
          'Coagulation — not stored: aPTT lasts 2–8 hours in plasma; PT '
          'depends on the reagent (4 hours to 1 day).',
    }),
    [
      CalcRef(
        CalcSources.whoDilLab99,
        'aPTT (Page 39); Prothrombin time (Page 40)',
      ),
      CalcRef(CalcSources.selivanov2005, '1.4'),
    ],
  ),
];

/// Bemor tayyorgarligi.
const patientPrep = <PreItem>[
  PreItem(
    LocalizedText({
      'uz':
          'Och qoringa: tahlildan oldin bir necha soat yoki tun bo‘yi suvdan '
          'boshqa hech narsa yeyilmaydi va ichilmaydi; muddatini shifokor '
          'aytadi. Ko‘p uchraydiganlari: glyukoza, xolesterin, '
          'triglitseridlar.',
      'ru':
          'Натощак: за несколько часов или за ночь до анализа ничего не едят '
          'и не пьют, кроме воды; срок называет врач. Чаще всего — глюкоза, '
          'холестерин, триглицериды.',
      'en':
          'Fasting: nothing but water for several hours or overnight before '
          'the test; the provider says how long. Common examples: glucose, '
          'cholesterol, triglycerides.',
    }),
    [
      CalcRef(CalcSources.medlinePlusLabPrep, 'Other steps to prepare'),
      CalcRef(CalcSources.selivanov2005, '1.1.1'),
    ],
  ),
  PreItem(
    LocalizedText({
      'uz':
          'Barcha dori, vitamin va qo‘shimchalarni aytish kerak: ayrimlari '
          'natijani o‘zgartiradi (masalan, glyukozani). Dorini shifokor '
          'aytmasa to‘xtatmang; darslik qonni dori qabulidan oldin olishni '
          'tavsiya qiladi.',
      'ru':
          'Нужно сообщить обо всех лекарствах, витаминах и добавках: '
          'некоторые меняют результат (например, глюкозу). Не отменяйте '
          'лекарства без указания врача; учебник рекомендует брать кровь до '
          'приёма препаратов.',
      'en':
          'Report all medicines, vitamins and supplements: some change '
          'results (for example glucose). Do not stop a medicine unless the '
          'provider says so; the textbook advises drawing blood before the '
          'dose.',
    }),
    [
      CalcRef(CalcSources.medlinePlusLabPrep, 'How do I prepare?'),
      CalcRef(CalcSources.selivanov2005, '1.1.1–1.1.2'),
    ],
  ),
  PreItem(
    LocalizedText({
      'uz':
          'Oldingi kun ko‘p ovqat yemaslik, spirtli ichimlik, chekish va '
          'og‘ir jismoniy zo‘riqishdan saqlanish so‘ralishi mumkin.',
      'ru':
          'Накануне могут попросить не переедать, избегать алкоголя, курения '
          'и тяжёлой физической нагрузки.',
      'en':
          'You may be asked not to overeat the day before and to avoid '
          'alcohol, smoking and strenuous exercise.',
    }),
    [CalcRef(CalcSources.medlinePlusLabPrep, 'Other steps to prepare')],
  ),
  PreItem(
    LocalizedText({
      'uz':
          'Hayz sikliga bog‘liq gormonlar (FSG, LG) siklning belgilangan '
          'kunida olinadi — kunini shifokor belgilaydi.',
      'ru':
          'Гормоны, зависящие от цикла (ФСГ, ЛГ), берут в определённый день '
          'цикла — день назначает врач.',
      'en':
          'Cycle-dependent hormones (FSH, LH) are drawn on a set day of the '
          'menstrual cycle — the provider chooses the day.',
    }),
    [
      CalcRef(CalcSources.medlinePlusFsh, 'Preparation'),
      CalcRef(CalcSources.selivanov2005, '1.1.3'),
    ],
  ),
  PreItem(
    LocalizedText({
      'uz':
          'Statsionarda qon vena ichiga tomchi qo‘yilgan joydan olinmaydi: '
          'eritma va dori natijani o‘zgartiradi.',
      'ru':
          'В стационаре кровь не берут из места установленного венозного '
          'доступа: раствор и лекарства искажают результат.',
      'en':
          'In hospital, do not draw from an existing IV access site: fluids '
          'and medicines alter the result.',
    }),
    [CalcRef(CalcSources.whoPhlebotomy2010, '2.2.3 Step 3 (p. 14)')],
  ),
  PreItem(
    LocalizedText({
      'uz':
          'Teri 70% spirt bilan artiladi va qurishi kutiladi (30 soniya). '
          'Povidon-yod bilan ifloslangan qonda kaliy, fosfor va siydik '
          'kislotasi soxta yuqori chiqishi mumkin.',
      'ru':
          'Кожу обрабатывают 70% спиртом и ждут высыхания (30 секунд). В '
          'крови, загрязнённой повидон-йодом, калий, фосфор и мочевая кислота '
          'могут быть ложно повышены.',
      'en':
          'Clean the skin with 70% alcohol and let it dry (30 seconds). '
          'Blood contaminated with povidone-iodine may show falsely high '
          'potassium, phosphorus or uric acid.',
    }),
    [
      CalcRef(CalcSources.whoPhlebotomy2010, '2.2.3 Step 5 (p. 14)'),
      CalcRef(CalcSources.selivanov2005, '1.3'),
    ],
  ),
];

/// Ekrandagi barcha manbalar tartibi ([n] raqamlari uchun): avval JSST
/// 2010 (probirkalar tartibi), keyin bloklar tartibida.
List<CalcSource> preanalyticsSources() {
  final out = <CalcSource>[CalcSources.whoPhlebotomy2010];
  void add(Iterable<CalcRef> refs) {
    for (final r in refs) {
      if (!out.any((s) => s.id == r.source.id)) out.add(r.source);
    }
  }

  for (final x in patientPrep) {
    add(x.refs);
  }
  for (final x in tubeForTest) {
    add(x.refs);
  }
  for (final x in mixingRules) {
    add(x.refs);
  }
  for (final x in [...storageRules, ...urgentSamples]) {
    add(x.refs);
  }
  return out;
}
