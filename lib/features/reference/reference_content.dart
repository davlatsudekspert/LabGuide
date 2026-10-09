/// "Jadvallar va algoritmlar": anemiya algoritmi, analizator soxta
/// natijalari, sariqlik turlari, jigar laborator sindromlari, najasda
/// parazit topish usullari va eskirgan usullar (3 tilda).
///
/// Faktlar o'z so'zimiz bilan; har blok ostida manba ([RefSources]).
/// Kitobdagi bilim rasmiy/ochiq manba bilan solishtirilgan; tasdiqlanmagan
/// raqam yozilmagan. Kontent mutaxassis tekshiruvidan o'tmagan (draft).
library;

import 'package:material_ui/material_ui.dart';

import '../content/content_model.dart';
import '../tools/calc_info.dart';
import 'reference_sources.dart';

typedef _T = LocalizedText;

/// Blokdagi "nom — qiymat" qatori.
class RefFact {
  const RefFact(this.label, this.value);
  final LocalizedText label;
  final LocalizedText value;
}

/// Bitta karta: sarlavha, ixtiyoriy belgi, qatorlar, bandlar va manbalar.
class RefBlock {
  const RefBlock({
    required this.title,
    required this.refs,
    this.tag,
    this.warning = false,
    this.facts = const [],
    this.bullets = const [],
  });

  final LocalizedText title;
  final LocalizedText? tag;

  /// Belgi ogohlantiruvchi rangda (masalan, "ishlatilmaydi").
  final bool warning;
  final List<RefFact> facts;
  final List<LocalizedText> bullets;
  final List<CalcRef> refs;
}

class RefTopic {
  const RefTopic({
    required this.id,
    required this.title,
    required this.summary,
    required this.icon,
    required this.blocks,
    this.analytes = const [],
  });

  final String id;
  final LocalizedText title;
  final LocalizedText summary;
  final IconData icon;
  final List<RefBlock> blocks;

  /// Shu jadvalga havola beriladigan tahlil kartalari.
  final List<String> analytes;
}

RefTopic? refTopic(String id) => refTopics.where((t) => t.id == id).firstOrNull;

/// Analit kartasidan tegishli jadvallarga o'tish.
List<RefTopic> refTopicsForAnalyte(String analyteId) => [
  for (final t in refTopics)
    if (t.analytes.contains(analyteId)) t,
];

// Qisqa yordamchilar.
const _dolAn = CalcRef(
  RefSources.dolgov2009,
  'Гематологические анализаторы: показатели эритропоэза, с. 25–35',
);
const _dolClass = CalcRef(
  RefSources.dolgov2009,
  'Определение и классификация анемий, с. 36–38',
);
const _dolIron = CalcRef(
  RefSources.dolgov2009,
  'Обмен железа; диагностика ЖДА, с. 43–68',
);
const _dolHem = CalcRef(
  RefSources.dolgov2009,
  'Внутриклеточный и внутрисосудистый гемолиз, с. 100–104',
);
const _takT3 = CalcRef(RefSources.takami2026, 'Table 3 (MCV and RDW)');
const _takT4 = CalcRef(RefSources.takami2026, 'Table 4 (spurious results)');
const _takS2 = CalcRef(RefSources.takami2026, 'Step 2: RBC lineage');
const _sobJ = CalcRef(
  RefSources.sobirova2006,
  'XVII bob: jigar biokimyosi, sariqliklar',
);
const _sobS = CalcRef(
  RefSources.sobirova2006,
  'XVII bob: jigar kasalliklarida biokimyoviy sindromlar',
);
const _acg = CalcRef(RefSources.kwo2017, 'Abstract');
const _lyu24 = CalcRef(
  RefSources.lyubina1984,
  '§24 Методы обнаружения яиц гельминтов',
);
const _who45 = CalcRef(
  RefSources.who2003,
  '4.5 Techniques for concentrating parasites, p. 152–156',
);

const _labelFinds = _T({
  'uz': 'Nimani topadi',
  'ru': 'Что выявляет',
  'en': 'What it finds',
});
const _labelMisses = _T({
  'uz': 'Cheklovi',
  'ru': 'Ограничения',
  'en': 'Limitations',
});
const _labelWhat = _T({'uz': 'Nima edi', 'ru': 'Что это', 'en': 'What it was'});
const _labelWhy = _T({
  'uz': 'Nega ishlatilmaydi',
  'ru': 'Почему не применяют',
  'en': 'Why it is not used',
});
const _labelInstead = _T({
  'uz': 'O‘rniga',
  'ru': 'Вместо него',
  'en': 'Use instead',
});
const _tagObsolete = _T({
  'uz': 'Ishlatilmaydi',
  'ru': 'Не применяется',
  'en': 'Not used',
});
const _tagHazard = _T({
  'uz': 'Xavfli — ishlatilmaydi',
  'ru': 'Опасно — не применяется',
  'en': 'Hazardous — not used',
});
const _blood = _T({
  'uz': 'Qonda bilirubin',
  'ru': 'Билирубин крови',
  'en': 'Blood bilirubin',
});
const _urineBili = _T({
  'uz': 'Siydikda bilirubin',
  'ru': 'Билирубин в моче',
  'en': 'Urine bilirubin',
});
const _urobil = _T({
  'uz': 'Siydikda urobilinogen',
  'ru': 'Уробилиноген в моче',
  'en': 'Urine urobilinogen',
});
const _stool = _T({'uz': 'Najas', 'ru': 'Кал', 'en': 'Stool'});
const _causes = _T({'uz': 'Sabablar', 'ru': 'Причины', 'en': 'Causes'});
const _enzymes = _T({
  'uz': 'Ko‘rsatkichlar',
  'ru': 'Показатели',
  'en': 'Markers',
});
const _meaning = _T({'uz': 'Ma’nosi', 'ru': 'Значение', 'en': 'Meaning'});

const refTopics = <RefTopic>[
  // ───────────────────────── Anemiya ─────────────────────────
  RefTopic(
    id: 'anemia',
    icon: Icons.water_drop_outlined,
    title: _T({
      'uz': 'Anemiya: bosqichma-bosqich',
      'ru': 'Анемия: шаг за шагом',
      'en': 'Anaemia: step by step',
    }),
    summary: _T({
      'uz':
          'Gemoglobin → MCV → retikulotsitlar → temir, B12/folat yoki gemoliz',
      'ru': 'Гемоглобин → MCV → ретикулоциты → железо, B12/фолат или гемолиз',
      'en':
          'Haemoglobin → MCV → reticulocytes → iron, B12/folate or haemolysis',
    }),
    analytes: [
      'hemoglobin',
      'mcv',
      'rdw',
      'reticulocytes',
      'ferritin',
      'iron',
      'transferrin-tibc',
      'vitamin-b12',
      'folate',
    ],
    blocks: [
      RefBlock(
        title: _T({
          'uz': '1. Anemiya bormi?',
          'ru': '1. Есть ли анемия?',
          'en': '1. Is there anaemia?',
        }),
        bullets: [
          _T({
            'uz': 'Gemoglobin bo‘yicha aniqlanadi. JSST (2024): 15–65 yoshli homilador bo‘lmagan ayollarda <120 g/L, erkaklarda <130 g/L; chegaralar yosh, homiladorlik, balandlik va chekishga qarab tuzatiladi.',
            'ru': 'Определяется по гемоглобину. ВОЗ (2024): у небеременных женщин 15–65 лет <120 г/л, у мужчин <130 г/л; пороги корректируют по возрасту, беременности, высоте и курению.',
            'en': 'Defined by haemoglobin. WHO (2024): <120 g/L in non-pregnant women aged 15–65, <130 g/L in men; cut-offs are adjusted for age, pregnancy, altitude and smoking.',
          }),
          _T({
            'uz': 'Avval natija haqiqiyligini tekshiring — “Analizator soxta natijalari” jadvaliga qarang.',
            'ru': 'Сначала убедитесь, что результат достоверен, — см. таблицу «Ложные результаты анализатора».',
            'en': 'First check that the result is genuine — see “Analyser spurious results”.',
          }),
        ],
        refs: [
          CalcRef(RefSources.whoHb2024, 'Table 2, p. 9'),
          CalcRef(RefSources.nhlbiAnemiaDx, 'Blood tests'),
        ],
      ),
      RefBlock(
        title: _T({
          'uz': '2. MCV bo‘yicha turi',
          'ru': '2. Тип по MCV',
          'en': '2. Type by MCV',
        }),
        facts: [
          RefFact(
            _T({
              'uz': 'MCV past (≈ <80 fL)',
              'ru': 'MCV низкий (≈ <80 фл)',
              'en': 'Low MCV (≈ <80 fL)',
            }),
            _T({
              'uz': 'Mikrotsitar: ko‘pincha temir tanqisligi; talassemiya → ferritin, temir ko‘rsatkichlari',
              'ru': 'Микроцитарная: чаще дефицит железа; талассемия → ферритин, показатели железа',
              'en': 'Microcytic: mostly iron deficiency; thalassaemia → ferritin, iron studies',
            }),
          ),
          RefFact(
            _T({'uz': 'MCV me’yorda', 'ru': 'MCV в норме', 'en': 'Normal MCV'}),
            _T({
              'uz': 'Normotsitar: o‘tkir qon yo‘qotish, buyrak kasalligi, surunkali kasallik, aplastik anemiya → retikulotsitlar hal qiladi',
              'ru': 'Нормоцитарная: острая кровопотеря, болезнь почек, хронические заболевания, апластическая анемия → решают ретикулоциты',
              'en': 'Normocytic: acute blood loss, kidney disease, chronic disease, aplastic anaemia → reticulocytes decide',
            }),
          ),
          RefFact(
            _T({
              'uz': 'MCV yuqori (≈ >100 fL)',
              'ru': 'MCV высокий (≈ >100 фл)',
              'en': 'High MCV (≈ >100 fL)',
            }),
            _T({
              'uz': 'Makrotsitar: B12 yoki folat tanqisligi, jigar kasalligi, alkogol, gipotireoz → B12, folat',
              'ru': 'Макроцитарная: дефицит B12 или фолата, болезнь печени, алкоголь, гипотиреоз → B12, фолат',
              'en': 'Macrocytic: B12 or folate deficiency, liver disease, alcohol, hypothyroidism → B12, folate',
            }),
          ),
        ],
        refs: [
          CalcRef(RefSources.medlineMcv, 'What do the results mean?'),
          _takT3,
          _dolClass,
        ],
      ),
      RefBlock(
        title: _T({
          'uz': '3. Suyak ko‘migi javobi — retikulotsitlar',
          'ru': '3. Ответ костного мозга — ретикулоциты',
          'en': '3. Marrow response — reticulocytes',
        }),
        facts: [
          RefFact(
            _T({
              'uz': 'Yuqori (≈ >80×10⁹/L)',
              'ru': 'Высокие (≈ >80×10⁹/л)',
              'en': 'High (≈ >80×10⁹/L)',
            }),
            _T({
              'uz': 'Qon ketishi, gemoliz yoki davodan keyin tiklanish → gemoliz belgilari',
              'ru': 'Кровотечение, гемолиз или восстановление после лечения → признаки гемолиза',
              'en': 'Bleeding, haemolysis or recovery after treatment → haemolysis markers',
            }),
          ),
          RefFact(
            _T({
              'uz': 'Past (og‘ir anemiyada ≈ <20×10⁹/L)',
              'ru': 'Низкие (при тяжёлой анемии ≈ <20×10⁹/л)',
              'en': 'Low (≈ <20×10⁹/L with severe anaemia)',
            }),
            _T({
              'uz': 'Ishlab chiqarish yetishmovchiligi: tanqislik, buyrak, suyak ko‘migi kasalligi',
              'ru': 'Недостаточная продукция: дефициты, почки, болезнь костного мозга',
              'en': 'Poor production: deficiencies, kidney, marrow disease',
            }),
          ),
        ],
        bullets: [
          _T({
            'uz': 'Chegaralar taxminiy; ulush (%) o‘rniga absolyut son yoki tuzatilgan indeks (CRC, RPI) ishlatiladi.',
            'ru': 'Пороги ориентировочные; вместо доли (%) используют абсолютное число или скорректированный индекс (CRC, RPI).',
            'en': 'Cut-offs are approximate; use the absolute count or a corrected index (CRC, RPI) rather than the percentage.',
          }),
        ],
        refs: [
          CalcRef(RefSources.medlineRetic, 'What do the results mean?'),
          _takS2,
          _dolAn,
        ],
      ),
      RefBlock(
        title: _T({
          'uz': 'MCV + RDW birga',
          'ru': 'MCV + RDW вместе',
          'en': 'MCV with RDW',
        }),
        facts: [
          RefFact(
            _T({
              'uz': 'MCV ↓, RDW me’yorda',
              'ru': 'MCV ↓, RDW норма',
              'en': 'MCV ↓, RDW normal',
            }),
            _T({
              'uz': 'Talassemiya tashuvchanligi, ayrim surunkali kasallik anemiyasi',
              'ru': 'Носительство талассемии, часть анемий хронических заболеваний',
              'en': 'Thalassaemia trait, some anaemia of chronic disease',
            }),
          ),
          RefFact(
            _T({
              'uz': 'MCV ↓, RDW ↑',
              'ru': 'MCV ↓, RDW ↑',
              'en': 'MCV ↓, RDW ↑',
            }),
            _T({
              'uz': 'Temir tanqisligi (ferritin, transferrin to‘yinishi)',
              'ru': 'Дефицит железа (ферритин, насыщение трансферрина)',
              'en': 'Iron deficiency (ferritin, transferrin saturation)',
            }),
          ),
          RefFact(
            _T({
              'uz': 'MCV me’yorda, RDW ↑',
              'ru': 'MCV норма, RDW ↑',
              'en': 'MCV normal, RDW ↑',
            }),
            _T({
              'uz': 'Erta temir tanqisligi, aralash tanqislik, transfuziyadan keyin',
              'ru':
                  'Ранний дефицит железа, смешанный дефицит, после трансфузии',
              'en':
                  'Early iron deficiency, mixed deficiency, after transfusion',
            }),
          ),
          RefFact(
            _T({
              'uz': 'MCV ↑, RDW ↑',
              'ru': 'MCV ↑, RDW ↑',
              'en': 'MCV ↑, RDW ↑',
            }),
            _T({
              'uz': 'B12 yoki folat tanqisligi, miyelodisplaziya',
              'ru': 'Дефицит B12 или фолата, миелодисплазия',
              'en': 'B12 or folate deficiency, myelodysplasia',
            }),
          ),
        ],
        refs: [_takT3],
      ),
      RefBlock(
        title: _T({
          'uz': 'Temir: tanqislik yoki yallig‘lanish?',
          'ru': 'Железо: дефицит или воспаление?',
          'en': 'Iron: deficiency or inflammation?',
        }),
        facts: [
          RefFact(
            _T({
              'uz': 'Temir tanqisligi',
              'ru': 'Дефицит железа',
              'en': 'Iron deficiency',
            }),
            _T({
              'uz': 'Ferritin ↓, temir ↓, transferrin to‘yinishi ↓, TIBC odatda ↑',
              'ru': 'Ферритин ↓, железо ↓, насыщение трансферрина ↓, ОЖСС обычно ↑',
              'en': 'Ferritin ↓, iron ↓, transferrin saturation ↓, TIBC usually ↑',
            }),
          ),
          RefFact(
            _T({
              'uz': 'Yallig‘lanish anemiyasi',
              'ru': 'Анемия воспаления',
              'en': 'Anaemia of inflammation',
            }),
            _T({
              'uz': 'Temir ↓, TIBC ↓, ferritin me’yorda yoki ↑',
              'ru': 'Железо ↓, ОЖСС ↓, ферритин норма или ↑',
              'en': 'Iron ↓, TIBC ↓, ferritin normal or ↑',
            }),
          ),
          RefFact(
            _T({
              'uz': 'Ferritin chegarasi (JSST 2020)',
              'ru': 'Порог ферритина (ВОЗ 2020)',
              'en': 'Ferritin cut-off (WHO 2020)',
            }),
            _T({
              'uz': 'Sog‘lom kattalar <15 µg/L; yallig‘lanishda <70 µg/L (CRP, AGP bilan birga)',
              'ru': 'Здоровые взрослые <15 мкг/л; при воспалении <70 мкг/л (вместе с CRP, AGP)',
              'en': 'Healthy adults <15 µg/L; with inflammation <70 µg/L (with CRP, AGP)',
            }),
          ),
        ],
        refs: [
          CalcRef(RefSources.whoFerritin2020, 'Executive summary: Table 1'),
          _dolIron,
        ],
      ),
      RefBlock(
        title: _T({
          'uz': 'Gemoliz belgilari',
          'ru': 'Признаки гемолиза',
          'en': 'Haemolysis markers',
        }),
        bullets: [
          _T({
            'uz': 'Retikulotsitlar ↑, LDG ↑, bevosita bo‘lmagan bilirubin ↑, gaptoglobin ↓.',
            'ru': 'Ретикулоциты ↑, ЛДГ ↑, непрямой билирубин ↑, гаптоглобин ↓.',
            'en':
                'Reticulocytes ↑, LDH ↑, indirect bilirubin ↑, haptoglobin ↓.',
          }),
          _T({
            'uz': 'Kumbs (antiglobulin) testi immun gemolizni ajratadi; surtmada sferotsit — membrana nuqsoni, shizotsit — trombotik mikroangiopatiya.',
            'ru': 'Проба Кумбса (антиглобулиновая) выделяет иммунный гемолиз; в мазке сфероциты — дефект мембраны, шизоциты — тромботическая микроангиопатия.',
            'en': 'The Coombs (antiglobulin) test identifies immune haemolysis; spherocytes suggest a membrane defect, schistocytes thrombotic microangiopathy.',
          }),
          _T({
            'uz': 'LDG keskin ↑ va gemosiderinuriya — tomir ichi gemolizi.',
            'ru':
                'Резкий рост ЛДГ и гемосидеринурия — внутрисосудистый гемолиз.',
            'en': 'A marked LDH rise with haemosiderinuria — intravascular haemolysis.',
          }),
        ],
        refs: [
          CalcRef(RefSources.barcellini2015, 'Abstract'),
          CalcRef(RefSources.medlineHapto, 'What is it used for?'),
          _dolHem,
        ],
      ),
    ],
  ),

  // ─────────────────── Analizator soxta natijalari ───────────────────
  RefTopic(
    id: 'spurious-cbc',
    icon: Icons.warning_amber_rounded,
    title: _T({
      'uz': 'Analizator soxta natijalari',
      'ru': 'Ложные результаты анализатора',
      'en': 'Analyser spurious results',
    }),
    summary: _T({
      'uz': 'Sovuq agglyutininlar, lipemiya, MCHC xato belgisi, saqlash',
      'ru': 'Холодовые агглютинины, липемия, MCHC как признак ошибки, хранение',
      'en': 'Cold agglutinins, lipaemia, MCHC as an error flag, storage',
    }),
    analytes: [
      'rbc-count',
      'hemoglobin',
      'hematocrit',
      'mcv',
      'mchc',
      'reticulocytes',
    ],
    blocks: [
      RefBlock(
        title: _T({
          'uz': 'Qaysi ko‘rsatkich, nima sababdan',
          'ru': 'Какой показатель и почему',
          'en': 'Which parameter, which cause',
        }),
        facts: [
          RefFact(
            _T({'uz': 'RBC', 'ru': 'RBC', 'en': 'RBC'}),
            _T({
              'uz': '↑ katta leykotsitoz, giperlipidemiya; ↓ sovuq agglyutininlar, gemoliz',
              'ru': '↑ выраженный лейкоцитоз, гиперлипидемия; ↓ холодовые агглютинины, гемолиз',
              'en': '↑ marked leukocytosis, hyperlipidaemia; ↓ cold agglutinins, haemolysis',
            }),
          ),
          RefFact(
            _T({'uz': 'Gemoglobin', 'ru': 'Гемоглобин', 'en': 'Haemoglobin'}),
            _T({
              'uz': '↑ lipemiya, katta leykotsitoz, paraproteinemiya',
              'ru': '↑ липемия, выраженный лейкоцитоз, парапротеинемия',
              'en': '↑ lipaemia, marked leukocytosis, paraproteinaemia',
            }),
          ),
          RefFact(
            _T({'uz': 'MCV', 'ru': 'MCV', 'en': 'MCV'}),
            _T({
              'uz': '↑ sovuq agglyutininlar, giperglikemiya, uzoq saqlash; ↓ og‘ir giponatriyemiya',
              'ru': '↑ холодовые агглютинины, гипергликемия, долгое хранение; ↓ тяжёлая гипонатриемия',
              'en': '↑ cold agglutinins, hyperglycaemia, prolonged storage; ↓ severe hyponatraemia',
            }),
          ),
          RefFact(
            _T({'uz': 'MCHC', 'ru': 'MCHC', 'en': 'MCHC'}),
            _T({
              'uz': '↑ Hb soxta ↑ yoki RBC soxta ↓; ↓ giperglikemiya, uzoq saqlash',
              'ru': '↑ ложно высокий Hb или ложно низкий RBC; ↓ гипергликемия, долгое хранение',
              'en': '↑ falsely high Hb or falsely low RBC; ↓ hyperglycaemia, prolonged storage',
            }),
          ),
          RefFact(
            _T({'uz': 'Gematokrit', 'ru': 'Гематокрит', 'en': 'Haematocrit'}),
            _T({
              'uz': 'RBC × MCV dan hisoblanadi — ularning xatosi o‘tadi',
              'ru': 'Рассчитывается из RBC × MCV — их ошибки переходят',
              'en': 'Calculated from RBC × MCV — their errors carry over',
            }),
          ),
          RefFact(
            _T({
              'uz': 'Retikulotsitlar',
              'ru': 'Ретикулоциты',
              'en': 'Reticulocytes',
            }),
            _T({
              'uz': '↑ yadroli eritrotsitlar, kiritmalar, fluoressent xalaqit',
              'ru': '↑ ядросодержащие эритроциты, включения, флуоресцентные помехи',
              'en':
                  '↑ nucleated red cells, inclusions, fluorescent interference',
            }),
          ),
        ],
        refs: [_takT4, _dolAn],
      ),
      RefBlock(
        title: _T({
          'uz': 'MCHC — xato indikatori',
          'ru': 'MCHC — индикатор ошибки',
          'en': 'MCHC as an error flag',
        }),
        bullets: [
          _T({
            'uz': 'MCHC fiziologik jihatdan kam o‘zgaradi. 36 g/dL (360 g/L) dan yuqori — artefakt ehtimoli (Takami 2026); Dolgov va hammualliflari 37–38 g/dL chegarani keltiradi.',
            'ru': 'MCHC физиологически меняется мало. Выше 36 г/дл (360 г/л) — вероятен артефакт (Takami 2026); Долгов и соавт. приводят порог 37–38 г/дл.',
            'en': 'MCHC varies little physiologically. Above 36 g/dL (360 g/L) suggests artefact (Takami 2026); Dolgov et al. give 37–38 g/dL.',
          }),
          _T({
            'uz': 'Haqiqiy yuqori MCHC sferotsitozda bo‘ladi — surtma bilan tekshiriladi.',
            'ru': 'Истинно высокий MCHC бывает при сфероцитозе — проверяют мазком.',
            'en':
                'A truly high MCHC occurs in spherocytosis — check the smear.',
          }),
        ],
        refs: [CalcRef(RefSources.takami2026, 'Table 2; Table 4'), _dolAn],
      ),
      RefBlock(
        title: _T({
          'uz': 'Nima qilish kerak',
          'ru': 'Что делать',
          'en': 'What to do',
        }),
        bullets: [
          _T({
            'uz': 'Analizator belgilarini (flag) ko‘ring, namunani tekshiring (laxta, gemoliz, lipemiya), surtma ko‘ring, kerak bo‘lsa qayta tahlil qiling.',
            'ru': 'Посмотрите флаги анализатора, проверьте пробу (сгусток, гемолиз, липемия), посмотрите мазок, при необходимости повторите.',
            'en': 'Review analyser flags, inspect the sample (clot, haemolysis, lipaemia), look at the smear and repeat if needed.',
          }),
          _T({
            'uz': 'Sovuq agglyutinatsiya shubhasida: namunani 37 °C da isitib qayta o‘lchash (Dolgov va hammualliflari).',
            'ru': 'При подозрении на холодовую агглютинацию: согреть пробу до 37 °C и измерить повторно (Долгов и соавт.).',
            'en': 'If cold agglutination is suspected: warm the sample to 37 °C and re-measure (Dolgov et al.).',
          }),
          _T({
            'uz': 'Namunani uzoq saqlamang: Dolgov va hammualliflari 8 soatdan ortiq saqlashda MCV oshishini qayd etadi.',
            'ru': 'Не храните пробу долго: Долгов и соавт. отмечают рост MCV при хранении более 8 часов.',
            'en': 'Do not store samples long: Dolgov et al. note MCV rising after more than 8 hours.',
          }),
        ],
        refs: [
          CalcRef(
            RefSources.takami2026,
            'Step 5: Always consider spurious results',
          ),
          _dolAn,
        ],
      ),
    ],
  ),

  // ───────────────────────── Sariqlik ─────────────────────────
  RefTopic(
    id: 'jaundice',
    icon: Icons.contrast_rounded,
    title: _T({
      'uz': 'Sariqlik turlarini farqlash',
      'ru': 'Дифференциация желтух',
      'en': 'Telling jaundice types apart',
    }),
    summary: _T({
      'uz': 'Jigar usti, jigar va jigar osti: qon, siydik, najas',
      'ru': 'Надпечёночная, печёночная, подпечёночная: кровь, моча, кал',
      'en': 'Prehepatic, hepatic, posthepatic: blood, urine, stool',
    }),
    analytes: ['bilirubin-total', 'bilirubin-direct'],
    blocks: [
      RefBlock(
        title: _T({
          'uz': 'Jigar usti (gemolitik)',
          'ru': 'Надпечёночная (гемолитическая)',
          'en': 'Prehepatic (haemolytic)',
        }),
        facts: [
          RefFact(
            _blood,
            _T({
              'uz': 'Bevosita bo‘lmagan (konyugatsiyalanmagan) ↑',
              'ru': 'Непрямой (неконъюгированный) ↑',
              'en': 'Indirect (unconjugated) ↑',
            }),
          ),
          RefFact(
            _urineBili,
            _T({
              'uz': 'Yo‘q — bu fraksiya siydikka o‘tmaydi',
              'ru': 'Нет — эта фракция в мочу не проходит',
              'en': 'Absent — this fraction does not enter urine',
            }),
          ),
          RefFact(_urobil, _T({'uz': '↑', 'ru': '↑', 'en': '↑'})),
          RefFact(
            _stool,
            _T({'uz': 'To‘q rangli', 'ru': 'Тёмный', 'en': 'Dark'}),
          ),
          RefFact(
            _causes,
            _T({
              'uz': 'Gemoliz; konyugatsiya buzilishi (Jilber sindromi)',
              'ru': 'Гемолиз; нарушение конъюгации (синдром Жильбера)',
              'en': 'Haemolysis; impaired conjugation (Gilbert syndrome)',
            }),
          ),
        ],
        refs: [
          CalcRef(RefSources.fargo2017, 'Abstract'),
          CalcRef(RefSources.medlineUrobil, 'What do the results mean?'),
          _sobJ,
        ],
      ),
      RefBlock(
        title: _T({
          'uz': 'Jigar (parenximatoz)',
          'ru': 'Печёночная (паренхиматозная)',
          'en': 'Hepatic',
        }),
        facts: [
          RefFact(
            _blood,
            _T({
              'uz': 'Ikkala fraksiya ↑, bevosita (konyugatsiyalangan) ham',
              'ru': 'Обе фракции ↑, включая прямой (конъюгированный)',
              'en': 'Both fractions ↑, including direct (conjugated)',
            }),
          ),
          RefFact(_urineBili, _T({'uz': 'Bor', 'ru': 'Есть', 'en': 'Present'})),
          RefFact(
            _urobil,
            _T({'uz': 'Ko‘pincha ↑', 'ru': 'Часто ↑', 'en': 'Often ↑'}),
          ),
          RefFact(
            _enzymes,
            _T({
              'uz': 'ALT/AST ustun (sitoliz)',
              'ru': 'Преобладают АЛТ/АСТ (цитолиз)',
              'en': 'ALT/AST predominate (cytolysis)',
            }),
          ),
          RefFact(
            _causes,
            _T({
              'uz': 'Virusli yoki alkogolli gepatit, sirroz, dorilar',
              'ru': 'Вирусный или алкогольный гепатит, цирроз, лекарства',
              'en': 'Viral or alcoholic hepatitis, cirrhosis, medicines',
            }),
          ),
        ],
        refs: [
          _acg,
          CalcRef(RefSources.medlineUrineBili, 'What do the results mean?'),
          CalcRef(RefSources.medlineUrobil, 'What do the results mean?'),
          _sobJ,
        ],
      ),
      RefBlock(
        title: _T({
          'uz': 'Jigar osti (mexanik)',
          'ru': 'Подпечёночная (механическая)',
          'en': 'Posthepatic (obstructive)',
        }),
        facts: [
          RefFact(
            _blood,
            _T({
              'uz': 'Bevosita (konyugatsiyalangan) ↑',
              'ru': 'Прямой (конъюгированный) ↑',
              'en': 'Direct (conjugated) ↑',
            }),
          ),
          RefFact(
            _urineBili,
            _T({
              'uz': 'Bor (siydik to‘q)',
              'ru': 'Есть (моча тёмная)',
              'en': 'Present (dark urine)',
            }),
          ),
          RefFact(
            _urobil,
            _T({
              'uz': '↓ yoki yo‘q',
              'ru': '↓ или отсутствует',
              'en': '↓ or absent',
            }),
          ),
          RefFact(
            _stool,
            _T({
              'uz': 'Oqargan, loysimon',
              'ru': 'Светлый, глинистый',
              'en': 'Pale, clay-coloured',
            }),
          ),
          RefFact(
            _enzymes,
            _T({
              'uz': 'ALP va GGT ustun (xolestaz)',
              'ru': 'Преобладают ЩФ и ГГТ (холестаз)',
              'en': 'ALP and GGT predominate (cholestasis)',
            }),
          ),
          RefFact(
            _causes,
            _T({
              'uz': 'O‘t yo‘lida tosh, o‘sma, torayish',
              'ru': 'Камень, опухоль, стриктура желчных путей',
              'en': 'Bile-duct stone, tumour, stricture',
            }),
          ),
        ],
        refs: [
          _acg,
          CalcRef(RefSources.medlineUrobil, 'What do the results mean?'),
          CalcRef(
            RefSources.medlinePaleStools,
            'Stools — pale or clay-colored',
          ),
          _sobJ,
        ],
      ),
      RefBlock(
        title: _T({'uz': 'Eslatma', 'ru': 'Примечание', 'en': 'Note'}),
        bullets: [
          _T({
            'uz': 'Sariqlik uch yo‘l bilan yuzaga keladi: eritrotsitlar ko‘p parchalanadi, jigar shikastlangan yoki bilirubin ichakka o‘tmaydi. Bu umumiy sxema; tashxis klinika, tasvirlash va boshqa tahlillar bilan qo‘yiladi.',
            'ru': 'Желтуха возникает тремя путями: усиленный распад эритроцитов, поражение печени или непрохождение билирубина в кишечник. Это общая схема; диагноз ставят с учётом клиники, визуализации и других анализов.',
            'en': 'Jaundice arises in three ways: excess red-cell breakdown, liver damage, or bilirubin failing to reach the gut. This is a general scheme; diagnosis uses the clinical picture, imaging and other tests.',
          }),
        ],
        refs: [CalcRef(RefSources.medlineJaundice, 'Jaundice causes')],
      ),
    ],
  ),

  // ───────────────────── Jigar sindromlari ─────────────────────
  RefTopic(
    id: 'liver-syndromes',
    icon: Icons.science_outlined,
    title: _T({
      'uz': 'Jigar laborator sindromlari',
      'ru': 'Лабораторные синдромы печени',
      'en': 'Liver laboratory patterns',
    }),
    summary: _T({
      'uz': 'Sitoliz, xolestaz, gepatotsitar yetishmovchilik, de Ritis',
      'ru': 'Цитолиз, холестаз, печёночно-клеточная недостаточность, де Ритис',
      'en': 'Cytolysis, cholestasis, hepatocellular failure, De Ritis',
    }),
    analytes: ['alt', 'ast', 'alp', 'ggt', 'bilirubin-total', 'albumin'],
    blocks: [
      RefBlock(
        title: _T({
          'uz': 'Sitoliz (gepatotsellyulyar shikastlanish)',
          'ru': 'Цитолиз (гепатоцеллюлярное повреждение)',
          'en': 'Cytolysis (hepatocellular injury)',
        }),
        facts: [
          RefFact(
            _enzymes,
            _T({
              'uz': 'ALT va AST ALP ga nisbatan nomutanosib ↑',
              'ru': 'АЛТ и АСТ ↑ непропорционально ЩФ',
              'en': 'ALT and AST ↑ out of proportion to ALP',
            }),
          ),
          RefFact(
            _meaning,
            _T({
              'uz': 'Jigar hujayralari zararlangan: gepatitlar, yog‘li jigar, alkogol, dorilar',
              'ru': 'Повреждение гепатоцитов: гепатиты, жировая болезнь печени, алкоголь, лекарства',
              'en': 'Liver-cell injury: hepatitis, fatty liver, alcohol, medicines',
            }),
          ),
        ],
        refs: [_acg, _sobS],
      ),
      RefBlock(
        title: _T({'uz': 'Xolestaz', 'ru': 'Холестаз', 'en': 'Cholestasis'}),
        facts: [
          RefFact(
            _enzymes,
            _T({
              'uz': 'ALP ALT/AST ga nisbatan nomutanosib ↑; GGT ↑ (jigar manbasi); ko‘pincha bevosita bilirubin ↑',
              'ru': 'ЩФ ↑ непропорционально АЛТ/АСТ; ГГТ ↑ (печёночный источник); часто ↑ прямой билирубин',
              'en': 'ALP ↑ out of proportion to ALT/AST; GGT ↑ (liver source); direct bilirubin often ↑',
            }),
          ),
          RefFact(
            _meaning,
            _T({
              'uz': 'O‘t oqimi buzilgan; ALP ↑ va GGT me’yorda bo‘lsa — suyak sababini o‘ylang',
              'ru': 'Нарушен отток желчи; при ЩФ ↑ и нормальной ГГТ — думать о костях',
              'en': 'Impaired bile flow; ALP ↑ with normal GGT — think of bone',
            }),
          ),
        ],
        refs: [
          _acg,
          CalcRef(RefSources.medlineGgt, 'What do the results mean?'),
          _sobS,
        ],
      ),
      RefBlock(
        title: _T({
          'uz': 'Gepatotsitar yetishmovchilik (sintetik funksiya)',
          'ru': 'Печёночно-клеточная недостаточность (синтетическая функция)',
          'en': 'Hepatocellular failure (synthetic function)',
        }),
        facts: [
          RefFact(
            _enzymes,
            _T({
              'uz': 'Albumin ↓, protrombin vaqti (PT/INR) uzaygan, bilirubin ↑',
              'ru': 'Альбумин ↓, протромбиновое время (ПВ/МНО) удлинено, билирубин ↑',
              'en':
                  'Albumin ↓, prolonged prothrombin time (PT/INR), bilirubin ↑',
            }),
          ),
          RefFact(
            _meaning,
            _T({
              'uz': 'Jigar oqsil va ivish omillarini yetarli ishlab chiqarmaydi; yuqori ALT o‘zi buni bildirmaydi',
              'ru': 'Печень недостаточно синтезирует белки и факторы свёртывания; высокая АЛТ сама этого не означает',
              'en': 'The liver makes too little protein and clotting factors; a high ALT alone does not mean this',
            }),
          ),
        ],
        refs: [
          CalcRef(RefSources.medlineLft, 'What are liver function tests?'),
          _sobS,
        ],
      ),
      RefBlock(
        title: _T({
          'uz': 'De Ritis koeffitsiyenti (AST/ALT)',
          'ru': 'Коэффициент де Ритиса (АСТ/АЛТ)',
          'en': 'De Ritis ratio (AST/ALT)',
        }),
        facts: [
          RefFact(
            _T({'uz': '> 2', 'ru': '> 2', 'en': '> 2'}),
            _T({
              'uz': 'Odatda alkogolli jigar kasalligi',
              'ru': 'Обычно алкогольная болезнь печени',
              'en': 'Usually alcoholic liver disease',
            }),
          ),
          RefFact(
            _T({'uz': '< 1', 'ru': '< 1', 'en': '< 1'}),
            _T({
              'uz': 'Surunkali virusli gepatit, surunkali xolestaz',
              'ru': 'Хронический вирусный гепатит, хронический холестаз',
              'en': 'Chronic viral hepatitis, chronic cholestasis',
            }),
          ),
          RefFact(
            _T({
              'uz': '> 1 (alkogolsiz kasallik)',
              'ru': '> 1 (неалкогольная болезнь)',
              'en': '> 1 (non-alcoholic disease)',
            }),
            _T({
              'uz': 'Sirrozga ishora qilishi mumkin',
              'ru': 'Может указывать на цирроз',
              'en': 'May suggest cirrhosis',
            }),
          ),
        ],
        bullets: [
          _T({
            'uz': 'AST yurak va mushakda ham bor — nisbat faqat jigar holatida ma’noli.',
            'ru': 'АСТ есть и в сердце, и в мышцах — отношение имеет смысл только при поражении печени.',
            'en': 'AST is also in heart and muscle — the ratio only makes sense for liver conditions.',
          }),
        ],
        refs: [CalcRef(RefSources.williams1988, 'Abstract'), _sobS],
      ),
    ],
  ),

  // ─────────────────── Najasda parazitlar ───────────────────
  RefTopic(
    id: 'stool-parasites',
    icon: Icons.bug_report_outlined,
    title: _T({
      'uz': 'Najasda parazitlarni topish usullari',
      'ru': 'Методы выявления паразитов в кале',
      'en': 'Finding parasites in stool',
    }),
    summary: _T({
      'uz': 'Nativ, Lugol, Kato, flotatsiya, cho‘ktirish, konservantlar, lenta',
      'ru': 'Нативный, Люголь, Като, флотация, осаждение, консерванты, лента',
      'en': 'Wet mount, iodine, Kato, flotation, sedimentation, preservatives, tape',
    }),
    analytes: ['stool-ova-parasites', 'pinworm-test', 'stool-analysis'],
    blocks: [
      RefBlock(
        title: _T({
          'uz': 'Nativ preparat (fiziologik eritma)',
          'ru': 'Нативный препарат (физраствор)',
          'en': 'Saline wet mount',
        }),
        facts: [
          RefFact(
            _labelFinds,
            _T({
              'uz': 'Harakatlanuvchi trofozoitlar, o‘rtacha miqdordagi tuxum va sistalar, eritrotsit, yog‘',
              'ru': 'Подвижные трофозоиты, яйца и цисты в умеренном количестве, эритроциты, жир',
              'en': 'Motile trophozoites, moderate numbers of eggs and cysts, red cells, fat',
            }),
          ),
          RefFact(
            _labelMisses,
            _T({
              'uz': 'Parazit kam bo‘lsa topilmasligi mumkin; trofozoit uchun suyuq najas va 37 °C gacha iliq eritma',
              'ru': 'При малом числе паразитов может не выявить; для трофозоитов — жидкий кал и раствор до 37 °C',
              'en': 'May miss scanty parasites; use liquid stool and saline warmed to 37 °C for trophozoites',
            }),
          ),
        ],
        refs: [
          CalcRef(
            RefSources.who2003,
            '4.2.3 Microscopic examination, p. 107–109',
          ),
          _lyu24,
        ],
      ),
      RefBlock(
        title: _T({
          'uz': 'Lugol (yod) preparati',
          'ru': 'Препарат с Люголем (йод)',
          'en': 'Iodine (Lugol) mount',
        }),
        facts: [
          RefFact(
            _labelFinds,
            _T({
              'uz': 'Sistalar yadrolari va glikogen vakuolasi; lyambliya va amyoba sistalarini farqlash',
              'ru': 'Ядра цист и гликогеновая вакуоль; различение цист лямблий и амёб',
              'en': 'Cyst nuclei and glycogen vacuoles; telling Giardia and amoeba cysts apart',
            }),
          ),
          RefFact(
            _labelMisses,
            _T({
              'uz': 'Trofozoitlar harakatsiz bo‘lib qoladi — harakatni fiziologik eritmada ko‘ring',
              'ru': 'Трофозоиты обездвиживаются — подвижность смотрят в физрастворе',
              'en': 'Trophozoites stop moving — check motility in saline',
            }),
          ),
        ],
        refs: [
          CalcRef(
            RefSources.who2003,
            '4.2.3 Microscopic examination, p. 107–109',
          ),
          CalcRef(
            RefSources.dadayev2004,
            'Bir hujayrali parazitlar: lyambliya, amyoba',
          ),
        ],
      ),
      RefBlock(
        title: _T({
          'uz': 'Kato (Kato–Kats) qalin surtmasi',
          'ru': 'Толстый мазок по Като (Като–Катцу)',
          'en': 'Kato (Kato–Katz) thick smear',
        }),
        facts: [
          RefFact(
            _labelFinds,
            _T({
              'uz': 'Gijja tuxumlari, ayniqsa shistosoma; tuxumlarni sanash; surtmani saqlab yuborish mumkin',
              'ru': 'Яйца гельминтов, особенно шистосом; подсчёт яиц; мазки можно хранить и пересылать',
              'en': 'Helminth eggs, especially Schistosoma; egg counts; slides can be stored and shipped',
            }),
          ),
          RefFact(
            _labelMisses,
            _T({
              'uz': 'Strongiloidoz, enterobioz va sodda jonivorlar uchun yaramaydi',
              'ru': 'Не подходит для стронгилоидоза, энтеробиоза и простейших',
              'en': 'Not for strongyloidiasis, enterobiasis or protozoa',
            }),
          ),
        ],
        refs: [
          CalcRef(RefSources.who2003, '4.4.1 Kato–Katz technique, p. 141–143'),
          _lyu24,
        ],
      ),
      RefBlock(
        title: _T({
          'uz': 'Flotatsiya (suzib chiqish)',
          'ru': 'Флотация',
          'en': 'Flotation',
        }),
        facts: [
          RefFact(
            _labelFinds,
            _T({
              'uz': 'Og‘ir eritmada (to‘yingan NaCl — Uillis; rux sulfat) yengil tuxumlar yuzaga chiqadi: ankilostoma, askarida, gimenolepis, tenia, qilbosh',
              'ru': 'В тяжёлом растворе (насыщенный NaCl — Уиллис; сульфат цинка) всплывают лёгкие яйца: анкилостомы, аскариды, карликовый цепень, тенииды, власоглав',
              'en': 'Light eggs rise in a dense solution (saturated NaCl — Willis; zinc sulfate): hookworm, Ascaris, Hymenolepis, Taenia, Trichuris',
            }),
          ),
          RefFact(
            _labelMisses,
            _T({
              'uz': 'So‘rg‘ichlilar va shistosoma tuxumlari, strongiloid lichinkalari, sodda jonivorlar; sista va tuxum devori bujmayishi mumkin',
              'ru': 'Яйца сосальщиков и шистосом, личинки стронгилоид, простейшие; стенки цист и яиц могут спадаться',
              'en': 'Fluke and schistosome eggs, Strongyloides larvae, protozoa; cyst and egg walls may collapse',
            }),
          ),
        ],
        refs: [
          _who45,
          CalcRef(RefSources.cdcStoolProc, 'Concentration Procedures'),
          _lyu24,
        ],
      ),
      RefBlock(
        title: _T({
          'uz': 'Cho‘ktirish (sedimentatsiya)',
          'ru': 'Осаждение (седиментация)',
          'en': 'Sedimentation',
        }),
        facts: [
          RefFact(
            _labelFinds,
            _T({
              'uz': 'Formalin–efir yoki formalin–etilatsetat: tuxum, lichinka va sistalarning ko‘p turi; CDC umumiy laboratoriyalarga tavsiya qiladi',
              'ru': 'Формалин–эфир или формалин–этилацетат: большинство яиц, личинок и цист; CDC рекомендует общим лабораториям',
              'en': 'Formalin–ether or formalin–ethyl acetate: most eggs, larvae and cysts; CDC recommends it for general laboratories',
            }),
          ),
          RefFact(
            _labelMisses,
            _T({
              'uz': 'Harakatlanuvchi shakllar ko‘rinmaydi — avval nativ preparat; efir yonuvchan, etilatsetat xavfsizroq',
              'ru': 'Подвижные формы не видны — сначала нативный препарат; эфир огнеопасен, этилацетат безопаснее',
              'en': 'Motile forms are not seen — do a wet mount first; ether is flammable, ethyl acetate is safer',
            }),
          ),
        ],
        refs: [
          _who45,
          CalcRef(RefSources.cdcStoolProc, 'Concentration Procedures'),
        ],
      ),
      RefBlock(
        title: _T({
          'uz': 'Konservantlar (uzoq laboratoriyaga yuborish)',
          'ru': 'Консерванты (пересылка)',
          'en': 'Preservatives (shipping)',
        }),
        bullets: [
          _T({
            'uz': '10% formalin — nam preparat va cho‘ktirish uchun; tuxum va sistalarni yaxshi saqlaydi, trofozoitni yomonroq.',
            'ru': '10% формалин — для нативных препаратов и осаждения; хорошо сохраняет яйца и цисты, хуже трофозоиты.',
            'en': '10% formalin — for wet mounts and sedimentation; preserves eggs and cysts well, trophozoites less so.',
          }),
          _T({
            'uz': 'PVA — doimiy (trixrom) bo‘yash uchun; MIF, SAF yoki TIF — nam preparat uchun aralashmalar.',
            'ru': 'ПВС (PVA) — для постоянной окраски (трихром); MIF, SAF или TIF — смеси для нативных препаратов.',
            'en': 'PVA — for permanent (trichrome) stains; MIF, SAF or TIF — mixtures for wet mounts.',
          }),
          _T({
            'uz': 'Konservantsiz yangi najas 1–4 soat ichida ko‘riladi; suyuq va qon-shilliqli najas birinchi.',
            'ru': 'Свежий кал без консерванта исследуют в течение 1–4 часов; жидкий и со слизью и кровью — в первую очередь.',
            'en': 'Fresh stool without preservative is examined within 1–4 hours; liquid and blood- or mucus-stained stool first.',
          }),
        ],
        refs: [
          CalcRef(RefSources.who2003, '4.2.1; 4.2.4, p. 107–109'),
          CalcRef(RefSources.cdcStoolCollect, 'Specimen Collection'),
        ],
      ),
      RefBlock(
        title: _T({
          'uz': 'Enterobioz: yopishqoq lenta',
          'ru': 'Энтеробиоз: липкая лента',
          'en': 'Pinworm: adhesive tape',
        }),
        bullets: [
          _T({
            'uz': 'Ostritsa tuxumlari najasda kam — anus atrofidagi teridan lenta bilan olinadi.',
            'ru':
                'Яиц остриц в кале мало — их берут лентой с кожи вокруг ануса.',
            'en': 'Pinworm eggs are scarce in stool — collect them with tape from the perianal skin.',
          }),
          _T({
            'uz': 'Ertalab, yuvinish va hojatxonadan oldin; ketma-ket uch kun takrorlanadi.',
            'ru': 'Утром до умывания и туалета; повторяют три дня подряд.',
            'en': 'In the morning before washing or using the toilet; repeat on three consecutive days.',
          }),
        ],
        refs: [
          CalcRef(
            RefSources.who2003,
            '4.4.1 Enterobius vermicularis, p. 135–136',
          ),
          CalcRef(RefSources.cdcPinworm, 'Overview'),
          _lyu24,
        ],
      ),
    ],
  ),

  // ───────────────────── Eskirgan usullar ─────────────────────
  RefTopic(
    id: 'obsolete-methods',
    icon: Icons.history_rounded,
    title: _T({
      'uz': 'Eskirgan usullar va ularning o‘rniga',
      'ru': 'Устаревшие методы и чем их заменить',
      'en': 'Obsolete methods and replacements',
    }),
    summary: _T({
      'uz': 'Sali, Panchenkov, benzidin, sulema, timol, Reitman–Frenkel, Kvik–Pitel',
      'ru': 'Сали, Панченков, бензидин, сулема, тимол, Райтман–Френкель, Квик–Пытель',
      'en': 'Sahli, Panchenkov, benzidine, mercuric chloride, thymol, Reitman–Frankel, Quick',
    }),
    analytes: [
      'hemoglobin',
      'esr',
      'fecal-occult-blood',
      'alt',
      'ast',
      'albumin',
      'mch',
    ],
    blocks: [
      RefBlock(
        title: _T({
          'uz': 'Gemoglobin: Sali usuli',
          'ru': 'Гемоглобин: метод Сали',
          'en': 'Haemoglobin: Sahli method',
        }),
        tag: _tagObsolete,
        facts: [
          RefFact(
            _labelWhat,
            _T({
              'uz': 'Xlorid kislota bilan gematin hosil qilib, rangni ko‘z bilan shkala bilan solishtirish',
              'ru': 'Образование гематина соляной кислотой и визуальное сравнение со шкалой',
              'en': 'Acid haematin formed with HCl and compared by eye with a colour scale',
            }),
          ),
          RefFact(
            _labelWhy,
            _T({
              'uz': 'Ko‘z bilan baholanadi, standartlanmagan, aniqligi past',
              'ru': 'Визуальная оценка, не стандартизован, низкая точность',
              'en': 'Visual reading, not standardised, poor accuracy',
            }),
          ),
          RefFact(
            _labelInstead,
            _T({
              'uz': 'Gemiglobinsianid fotometrik usuli (JSST: eng aniq) yoki analizator (masalan, SLS-Hb)',
              'ru': 'Гемиглобинцианидный фотометрический метод (ВОЗ: наиболее точный) или анализатор (например, SLS-Hb)',
              'en': 'Haemiglobincyanide photometry (WHO: most accurate) or an analyser (e.g., SLS-Hb)',
            }),
          ),
        ],
        refs: [
          CalcRef(
            RefSources.who2003,
            '9.3.1 Haemiglobincyanide method, p. 271',
          ),
          CalcRef(RefSources.aripova2007, '12.1.4 Gemoglobinni aniqlash'),
          CalcRef(RefSources.lyubina1984, '§54 Определение гемоглобина'),
        ],
      ),
      RefBlock(
        title: _T({
          'uz': 'EChT: Panchenkov usuli',
          'ru': 'СОЭ: метод Панченкова',
          'en': 'ESR: Panchenkov method',
        }),
        tag: _T({
          'uz': 'Almashtirilmoqda',
          'ru': 'Заменяется',
          'en': 'Being replaced',
        }),
        facts: [
          RefFact(
            _labelWhat,
            _T({
              'uz': 'Sitratli kapillyar qon Panchenkov apparatida; MDH laboratoriyalarida hanuz qo‘llanadi',
              'ru': 'Цитратная капиллярная кровь в аппарате Панченкова; в лабораториях СНГ ещё применяется',
              'en': 'Citrated capillary blood in the Panchenkov apparatus; still used in former-USSR laboratories',
            }),
          ),
          RefFact(
            _labelWhy,
            _T({
              'uz': 'Xalqaro oltin standart — Westergren; usullar natijasi bir-biriga mos kelmasligi mumkin',
              'ru': 'Международный золотой стандарт — Вестергрен; результаты методов могут не совпадать',
              'en': 'The international gold standard is Westergren; methods may disagree',
            }),
          ),
          RefFact(
            _labelInstead,
            _T({
              'uz': 'Westergren (200 mm, ichki diametri 2,5 mm) yoki validatsiya qilingan muqobil avtomatik usul (ICSH 2017); usulni blankaga yozing',
              'ru': 'Вестергрен (200 мм, внутренний диаметр 2,5 мм) или валидированный альтернативный автоматический метод (ICSH 2017); метод указывают в бланке',
              'en': 'Westergren (200 mm, 2.5 mm bore) or a validated alternative automated method (ICSH 2017); state the method on the report',
            }),
          ),
        ],
        refs: [
          CalcRef(RefSources.kratz2017, 'Abstract'),
          CalcRef(RefSources.who2003, '9.7 Erythrocyte sedimentation rate'),
          CalcRef(RefSources.lyubina1984, '§59 СОЭ по Панченкову'),
        ],
      ),
      RefBlock(
        title: _T({
          'uz': 'Yashirin qon: benzidin sinamasi',
          'ru': 'Скрытая кровь: бензидиновая проба',
          'en': 'Occult blood: benzidine test',
        }),
        tag: _tagHazard,
        warning: true,
        facts: [
          RefFact(
            _labelWhat,
            _T({
              'uz': 'Najasdagi gemoglobin peroksidaza faolligini benzidin bilan aniqlash (Gregersen)',
              'ru': 'Выявление пероксидазной активности гемоглобина в кале бензидином (Грегерсен)',
              'en': 'Detecting haemoglobin peroxidase activity in stool with benzidine (Gregersen)',
            }),
          ),
          RefFact(
            _labelWhy,
            _T({
              'uz': 'Benzidin kanserogen — JSST tavsiya etmaydi',
              'ru': 'Бензидин канцерогенен — ВОЗ не рекомендует',
              'en': 'Benzidine is carcinogenic — WHO does not recommend it',
            }),
          ),
          RefFact(
            _labelInstead,
            _T({
              'uz': 'Immunokimyoviy test (FIT) — parhezsiz; yoki gvayak/amidopirin testi parhez bilan',
              'ru': 'Иммунохимический тест (FIT) — без диеты; или гваяковый/амидопириновый тест с диетой',
              'en': 'Immunochemical test (FIT) — no diet; or guaiac/aminopyrine test with diet',
            }),
          ),
        ],
        refs: [
          CalcRef(RefSources.who2003, '4.6 Occult blood in stools, p. 157'),
          CalcRef(
            RefSources.medlineFobt,
            'What happens during a fecal occult blood test?',
          ),
          CalcRef(RefSources.aripova2007, 'XI bob: yashirin qon'),
        ],
      ),
      RefBlock(
        title: _T({
          'uz': 'Sulema (simob xlorid) bilan sinamalar',
          'ru': 'Пробы с сулемой (хлорид ртути)',
          'en': 'Mercuric chloride tests',
        }),
        tag: _tagHazard,
        warning: true,
        facts: [
          RefFact(
            _labelWhat,
            _T({
              'uz': 'Najasda sterkobilinni aniqlash (Shmidt sinamasi) va jigarning sulema cho‘kma sinamasi',
              'ru': 'Выявление стеркобилина в кале (проба Шмидта) и сулемовая осадочная проба печени',
              'en': 'Stercobilin in stool (Schmidt test) and the mercuric chloride liver flocculation test',
            }),
          ),
          RefFact(
            _labelWhy,
            _T({
              'uz': 'Simob birikmalari zaharli: asab, buyrak, teri va ko‘zga ta’sir qiladi; noorganik tuzlar o‘yuvchi',
              'ru': 'Соединения ртути токсичны: нервная система, почки, кожа и глаза; неорганические соли едкие',
              'en': 'Mercury compounds are toxic to nerves, kidneys, skin and eyes; inorganic salts are corrosive',
            }),
          ),
          RefFact(
            _labelInstead,
            _T({
              'uz': 'Najas rangi va siydikda urobilinogen; jigar uchun — albumin, PT/INR, bilirubin fraksiyalari, fermentlar',
              'ru': 'Цвет кала и уробилиноген в моче; для печени — альбумин, ПВ/МНО, фракции билирубина, ферменты',
              'en': 'Stool colour and urine urobilinogen; for the liver — albumin, PT/INR, bilirubin fractions, enzymes',
            }),
          ),
        ],
        refs: [
          CalcRef(RefSources.whoMercury, 'Key facts; Exposure'),
          CalcRef(RefSources.lyubina1984, '§22 Химическое исследование кала'),
          _sobS,
          CalcRef(RefSources.medlineLft, 'What are liver function tests?'),
        ],
      ),
      RefBlock(
        title: _T({
          'uz': 'Timol va boshqa cho‘kma sinamalari',
          'ru': 'Тимоловая и другие осадочные пробы',
          'en': 'Thymol and other flocculation tests',
        }),
        tag: _tagObsolete,
        facts: [
          RefFact(
            _labelWhat,
            _T({
              'uz': 'Zardob oqsillari nisbati buzilishini loyqalanish bilan bilvosita baholash (timol, Veltman)',
              'ru': 'Косвенная оценка диспротеинемии по помутнению (тимоловая, Вельтмана)',
              'en': 'Indirect turbidity estimates of dysproteinaemia (thymol, Weltmann)',
            }),
          ),
          RefFact(
            _labelWhy,
            _T({
              'uz': 'Nospetsifik va bilvosita; Sobirova va hammualliflari ularni eskirgan deb belgilaydi',
              'ru': 'Неспецифичны и косвенны; Собирова и соавт. относят их к устаревшим',
              'en': 'Non-specific and indirect; Sobirova et al. list them as obsolete',
            }),
          ),
          RefFact(
            _labelInstead,
            _T({
              'uz': 'Albumin, umumiy oqsil, PT/INR, ALT/AST/ALP/GGT, bilirubin fraksiyalari',
              'ru': 'Альбумин, общий белок, ПВ/МНО, АЛТ/АСТ/ЩФ/ГГТ, фракции билирубина',
              'en': 'Albumin, total protein, PT/INR, ALT/AST/ALP/GGT, bilirubin fractions',
            }),
          ),
        ],
        refs: [
          _sobS,
          CalcRef(RefSources.medlineLft, 'What are liver function tests?'),
          _acg,
        ],
      ),
      RefBlock(
        title: _T({
          'uz': 'ALT/AST: Reitman–Frenkel usuli',
          'ru': 'АЛТ/АСТ: метод Райтмана–Френкеля',
          'en': 'ALT/AST: Reitman–Frankel method',
        }),
        tag: _tagObsolete,
        facts: [
          RefFact(
            _labelWhat,
            _T({
              'uz': 'Reaksiya mahsulotini dinitrofenilgidrazin bilan rangli qilish; natija mmol/(soat·L) da',
              'ru': 'Окрашивание продукта реакции динитрофенилгидразином; результат в ммоль/(ч·л)',
              'en': 'Colouring the reaction product with dinitrophenylhydrazine; results in mmol/(h·L)',
            }),
          ),
          RefFact(
            _labelWhy,
            _T({
              'uz': 'Xalqaro reference usul — 37 °C dagi kinetik IFCC usuli; eski birliklarni U/L ga to‘g‘ridan-to‘g‘ri o‘tkazib bo‘lmaydi',
              'ru': 'Международный референсный метод — кинетический метод IFCC при 37 °C; старые единицы нельзя напрямую перевести в Ед/л',
              'en': 'The international reference is the IFCC kinetic method at 37 °C; old units cannot be converted directly to U/L',
            }),
          ),
          RefFact(
            _labelInstead,
            _T({
              'uz': 'Kinetik usul (U/L), IFCC ga kuzatiladigan kalibrlash',
              'ru': 'Кинетический метод (Ед/л) с калибровкой, прослеживаемой к IFCC',
              'en': 'Kinetic method (U/L) with calibration traceable to IFCC',
            }),
          ),
        ],
        refs: [
          CalcRef(
            RefSources.ifcc2002,
            'Abstract (series: Part 4 ALT, Part 5 AST)',
          ),
          CalcRef(
            RefSources.aripova2007,
            'V bob: ALT/AST Reitman–Frenkel usuli',
          ),
        ],
      ),
      RefBlock(
        title: _T({
          'uz': 'Kvik–Pitel (gippur kislota) sinamasi',
          'ru': 'Проба Квика–Пытеля (гиппуровая кислота)',
          'en': 'Quick (hippuric acid) test',
        }),
        tag: _tagObsolete,
        facts: [
          RefFact(
            _labelWhat,
            _T({
              'uz': 'Natriy benzoatdan keyin siydikda gippur kislota chiqishi bilan jigarning zararsizlantirish funksiyasini baholash',
              'ru': 'Оценка обезвреживающей функции печени по выделению гиппуровой кислоты с мочой после бензоата натрия',
              'en': 'Judging liver detoxification by urinary hippuric acid after sodium benzoate',
            }),
          ),
          RefFact(
            _labelWhy,
            _T({
              'uz': 'Bilvosita yuklama sinamasi, zamonaviy jigar panelida yo‘q; Sobirova va hammualliflari eskirgan deb belgilaydi',
              'ru': 'Косвенная нагрузочная проба, в современную печёночную панель не входит; Собирова и соавт. относят к устаревшим',
              'en': 'An indirect load test, not part of today’s liver panel; Sobirova et al. list it as obsolete',
            }),
          ),
          RefFact(
            _labelInstead,
            _T({
              'uz': 'Jigar sintetik funksiyasi: albumin, PT/INR; tozalash: bilirubin',
              'ru': 'Синтетическая функция печени: альбумин, ПВ/МНО; очищение: билирубин',
              'en': 'Liver synthetic function: albumin, PT/INR; clearance: bilirubin',
            }),
          ),
        ],
        refs: [
          _sobS,
          CalcRef(RefSources.medlineLft, 'What are liver function tests?'),
        ],
      ),
      RefBlock(
        title: _T({
          'uz': 'Rang ko‘rsatkichi',
          'ru': 'Цветовой показатель',
          'en': 'Colour index',
        }),
        tag: _tagObsolete,
        facts: [
          RefFact(
            _labelWhat,
            _T({
              'uz': 'Gemoglobin va eritrotsitlar sonidan qo‘lda hisoblanadigan nisbat',
              'ru': 'Отношение, вычисляемое вручную по гемоглобину и числу эритроцитов',
              'en':
                  'A ratio hand-calculated from haemoglobin and red cell count',
            }),
          ),
          RefFact(
            _labelWhy,
            _T({
              'uz': 'Analizator eritrotsit indekslarini bevosita beradi; Dolgov va hammualliflari eskirgan deb hisoblaydi',
              'ru': 'Анализатор выдаёт эритроцитарные индексы напрямую; Долгов и соавт. считают его устаревшим',
              'en': 'Analysers report red cell indices directly; Dolgov et al. consider it obsolete',
            }),
          ),
          RefFact(
            _labelInstead,
            _T({
              'uz': 'MCH (pg), MCHC, MCV',
              'ru': 'MCH (пг), MCHC, MCV',
              'en': 'MCH (pg), MCHC, MCV',
            }),
          ),
        ],
        refs: [
          CalcRef(RefSources.takami2026, 'Understanding CBC parameters'),
          _dolAn,
          CalcRef(RefSources.najmitdinov1998, 'Кириш: ранг кўрсаткичи'),
        ],
      ),
    ],
  ),
];
