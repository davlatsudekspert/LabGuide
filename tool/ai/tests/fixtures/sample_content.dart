/// Sinov uchun Dart kontent namunasi (haqiqiy tibbiy mazmun emas).
library;

import '../content/content_model.dart';
import '../tools/calc_info.dart';

typedef _T = LocalizedText;

abstract final class SampleSources {
  static const who = CalcSource(
    id: 'sample-who-2021',
    citation:
        'World Health Organization. Sample manual, 6th ed. '
        'Geneva: WHO; 2021',
    url: 'https://example.org/who',
  );
  static const atlas = CalcSource(
    id: 'sample-atlas',
    citation: 'Sample Atlas',
    url: 'https://example.org/atlas',
  );
}

const refTable = CalcRef(SampleSources.who, 'Table 8.3, p. 213');
const refSection = CalcRef(SampleSources.who, '§2.4.6, p. 23–24');

abstract final class SampleL {
  static const subtitle = _T({
    'uz': 'Qisqa',
    'ru': 'Коротко',
    'en': 'Short',
  });
  static const draftNote = _T({
    'uz':
        'Qoralama: matn qo‘llanma bilan solishtirilgan, '
        'lekin mutaxassis tekshiruvidan hali o‘tmagan.',
    'ru':
        'Черновик: текст сверен с руководством, '
        'но ещё не прошёл экспертную проверку.',
    'en':
        'Draft: checked against the manual '
        'but not yet reviewed by an expert.',
  });
  static const templated = _T({
    'uz': 'Natija: $value mL — me’yordan past, takroriy tekshiruv kerak',
    'ru': 'Результат: $value мл — ниже нормы, нужна повторная проверка',
    'en': 'Result: $value mL - below the limit, a repeat test is needed',
  });
}

class SampleStep {
  const SampleStep(this.title, this.body, this.ref);
  final LocalizedText title;
  final LocalizedText body;
  final CalcRef ref;
}

// 'it\'s' va \n kabi escape'lar
const sampleSteps = <SampleStep>[
  SampleStep(
    _T({'uz': 'Ko‘rsatma', 'ru': 'Инструктаж', 'en': 'Instructions'}),
    _T({
      'uz':
          'Erkakka namuna olish bo‘yicha aniq yozma va og‘zaki ko‘rsatma '
          'beriladi; shifokor ham xuddi shu ma’lumotni beradi.',
      'ru':
          'Мужчине дают чёткие письменные и устные инструкции по сбору '
          'эякулята; врач даёт ту же информацию.',
      'en':
          'The man is given clear written and spoken instructions on '
          'collection; it\'s the same information the clinician gives.',
    }),
    refTable,
  ),
  SampleStep(
    _T({'uz': 'Tiyilish: 2–7 kun', 'ru': 'Воздержание: 2–7 дней', 'en': 'Abstinence: 2–7 days'}),
    _T({
      'uz': 'Eyakulyat kamida 2 kun va ko‘pi bilan 7 kunlik tiyilishdan keyin olinadi.',
      'ru': 'Эякулят собирают после не менее 2 и не более 7 дней воздержания.',
      'en': 'Collect after a minimum of 2 and a maximum of 7 days of abstinence.',
    }),
    CalcRef(SampleSources.atlas, 'Ch. 5'),
  ),
];

class SampleGrade {
  const SampleGrade(this.letter, this.definition);
  final String letter;
  final LocalizedText definition;
}

const sampleGrades = <String, SampleGrade>{
  'rapid': SampleGrade(
    'a',
    _T({
      'uz': '≥ 25 µm/s: faol harakat, to‘g‘ri chiziq yoki katta aylana bo‘ylab.',
      'ru': '≥ 25 мкм/с: активное движение по прямой или по большому кругу.',
      'en': '≥ 25 µm/s: moving actively, linearly or in a large circle.',
    }),
  ),
};

class SampleQuiz {
  const SampleQuiz(this.id, this.prompt, this.basis);
  final String id;
  final LocalizedText prompt;
  final LocalizedText basis;
}

// Matn ichida // bor (URL) — izoh emas.
final sampleQuiz = <SampleQuiz>[
  SampleQuiz(
    'sample-q-limit',
    const _T({
      'uz': 'Manba: https://example.org/limit — spermatozoidlar konsentratsiyasining pastki chegarasi qancha?',
      'ru': 'Источник: https://example.org/limit — каков нижний предел?',
      'en': 'Source: https://example.org/limit - what is the lower limit?',
    }),
    const _T({
      'uz': 'Table 8.3: 16 ×10⁶/mL, 95% IO 15–18 oralig‘ida.',
      'ru': 'Table 8.3: 16 ×10⁶/мл, 95% ДИ 15–18.',
      'en': 'Table 8.3: 16 ×10⁶/mL, 95% CI 15–18.',
    }),
  ),
];

/* blok izoh: _T({'uz': 'x'}) */
const sampleFactsRefs = [refSection];
