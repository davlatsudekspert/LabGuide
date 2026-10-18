import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Mashq (kontent paketi) va toifa izohlaridagi qo'sh birlik juftlari:
/// "SI (konvensional)" — masalan "7,0 mmol/L (126 mg/dL)". Har bir juft
/// analitga xos koeffitsientga mos kelishi, o'nlik belgisi tilga mosligi va
/// konvensional qiymat juftsiz qolmasligi tekshiriladi
/// (docs/QUIZ_UNITS_2026-10-10.md, tool/content/quiz_dual_units.py).

/// Konvensional → SI ko'paytuvchi (HbA1c alohida formula bilan).
const factors = <String, double>{
  'glucose': 1 / 18.016,
  'hemoglobin': 10,
  'mchc': 10,
  'protein': 10,
  // 2026-10-11: temir/TIBC (Fe 55,845 g/mol), B12 (1355,37 g/mol),
  // trombotsitlar (/µL → ×10⁹/L), gematokrit (% → L/L).
  'iron': 10 / 55.845,
  'b12': 0.7378,
  'plt': 1 / 1000,
  'hct': 1 / 100,
};

/// Juft uchraydigan savollar va ulardagi analit.
const itemAnalyte = <String, String>{
  'ogtt-q2': 'glucose',
  'hemoglobin-q1': 'hemoglobin',
  'hemoglobin-q2': 'hemoglobin',
  'books-mchc-artefact': 'mchc',
  'kdl-t-109': 'glucose',
  'kdl-t-264': 'protein',
  'kdl-t-451': 'hba1c',
  'platelets-q1': 'plt',
  'hematocrit-q1': 'hct',
  'transferrin-tibc-q1': 'iron',
  'vitamin-b12-q1': 'b12',
};

/// Juftsiz qiymat ruxsat etilgan savollar (sabab bilan).
const bareAllowed = <String, String>{
  // Koeffitsientning o'zi haqida ("glyukoza ≈ 18,0 mg/dL har 1 mmol/L ga") —
  // laboratoriya natijasi emas.
  'unit-factor': 'conversion factor statement',
  // Plevra suyuqligidagi oqsil chegarasi (30 g/L) — manba (Kurbonova, 2023)
  // va deck slaydidagi ko'rinishda; qon analiti natijasi emas.
  'drv-d032-04': 'effusion protein cut-off quoted as in the source',
  // Asos ortiqligi (BE ±2,5 mmol/L) — kislota-ishqor ko'rsatkichi, konvensional
  // birligi yo'q.
  'drv-d063-02': 'base excess has no conventional-unit equivalent',
  // JSST usuli: leykotsitlar soni noma'lum bo'lsa 8000/µL deb olinadi —
  // hisoblash konstantasi.
  'drv-d078-02': 'WHO parasitaemia formula constant (8000 leukocytes/µL)',
};

/// Raqam: o'nlik ("7,0", "7.0") yoki minglik guruhli butun son ("15 000",
/// "15,000").
const _num =
    r'(?<![A-Za-zА-Яа-я\d.,])\d{1,3}(?:[ ,]\d{3})+(?![.,]?\d)|\d+(?:[.,]\d+)?';
const _siUnits =
    r'mmol/L|ммоль/л|g/L|г/л|mmol/mol|ммоль/моль|µmol/L|мкмоль/л|'
    r'pmol/L|пмоль/л|×10⁹/L|×10⁹/л|L/L|л/л';
const _convUnits = r'mg/dL|мг/дл|g/dL|г/дл|µg/dL|мкг/дл|pg/mL|пг/мл|/µL|/мкл|%';
final pairRe = RegExp(
  '((?:$_num)(?:–(?:$_num))?) ($_siUnits) '
  '\\(((?:$_num)(?:–(?:$_num))?) ?($_convUnits)\\)',
);
final bareConvRe = RegExp(
  '(?:$_num)(?:–(?:$_num))? ?'
  '(?:mg/dL|мг/дл|g/dL|г/дл|µg/dL|мкг/дл|pg/mL|пг/мл|/µL|/мкл)',
);
final bareSiRe = RegExp(
  '(?:$_num)(?:–(?:$_num))? '
  '(?:mmol/L|ммоль/л|g/L|г/л|µmol/L|мкмоль/л|pmol/L|пмоль/л|×10⁹/L|×10⁹/л)'
  '(?! \\()',
);

final _grouped = RegExp(r'^\d{1,3}(?:[ ,]\d{3})+$');

double _parse(String s) => _grouped.hasMatch(s)
    ? double.parse(s.replaceAll(RegExp('[ ,]'), ''))
    : double.parse(s.replaceAll(',', '.'));

int _decimals(String s) {
  if (_grouped.hasMatch(s)) return 0;
  final i = s.indexOf(RegExp('[.,]'));
  return i < 0 ? 0 : s.length - i - 1;
}

/// Matn (id, til, satr) lari.
typedef QuizText = ({String id, String lang, String text});

List<QuizText> quizTexts() {
  final pack = jsonDecode(
    File('assets/content/core/pack.json').readAsStringSync(),
  ) as Map;
  final out = <QuizText>[];
  for (final q in (pack['quiz'] as List).cast<Map<String, Object?>>()) {
    for (final field in ['prompt', 'basis', 'options']) {
      void add(Object? loc) {
        if (loc is Map) {
          for (final lang in ['uz', 'ru', 'en']) {
            final t = loc[lang];
            if (t is String) {
              out.add((id: q['id']! as String, lang: lang, text: t));
            }
          }
        }
      }

      final v = q[field];
      if (field == 'options') {
        for (final o in (v as List).cast<Map<String, Object?>>()) {
          add(o['text']);
          add(o['explanation']);
        }
      } else {
        add(v);
      }
    }
  }
  return out;
}

List<QuizText> toifaNotes() {
  final bank =
      jsonDecode(File('assets/toifa/kdl_tests.json').readAsStringSync()) as Map;
  return [
    for (final q in (bank['questions'] as List).cast<Map<String, Object?>>())
      if (q['note'] is String)
        (id: q['id'] as String, lang: 'uz', text: q['note'] as String),
  ];
}

/// Bitta juftni tekshiradi; xato bo'lsa — tavsif.
String? checkPair(String analyte, RegExpMatch m, String lang) {
  final siParts = m[1]!.split('–');
  final convParts = m[3]!.split('–');
  final siUnit = m[2]!;
  final convUnit = m[4]!;
  if (siParts.length != convParts.length) return 'range shape differs';
  final sep = lang == 'en' ? ',' : '.';
  for (final part in [...siParts, ...convParts]) {
    if (_grouped.hasMatch(part)) {
      // Minglik ajratgich: en — vergul, uz/ru — bo'sh joy.
      if (part.contains(lang == 'en' ? ' ' : ',')) {
        return 'thousands separator for $lang';
      }
    } else if (part.contains(sep)) {
      return 'decimal separator for $lang';
    }
  }
  final hba1c = analyte == 'hba1c';
  final percent = hba1c || analyte == 'hct';
  if (percent != (convUnit == '%')) return 'unit $convUnit for $analyte';
  final molPerMol = siUnit == 'mmol/mol' || siUnit == 'ммоль/моль';
  if (hba1c != molPerMol) return 'unit $siUnit for $analyte';
  for (var i = 0; i < siParts.length; i++) {
    final si = _parse(siParts[i]);
    final conv = _parse(convParts[i]);
    final double expected;
    final double tol;
    if (hba1c) {
      expected = 10.929 * (conv - 2.15);
      tol = 0.5;
    } else {
      final f = factors[analyte]!;
      // Qaysi tomoni hisoblangani bilinmaydi: ikkala yo'nalishda ham
      // ko'rsatilgan xonalar bo'yicha yaxlitlashga sig'ishi kerak.
      final siTol = 0.5 * _pow10(-_decimals(siParts[i]));
      final convTol = 0.5 * _pow10(-_decimals(convParts[i]));
      final okSi = (si - conv * f).abs() <= siTol + 1e-9;
      final okConv = (conv - si / f).abs() <= convTol + 1e-9;
      if (!okSi && !okConv) {
        return '${siParts[i]} $siUnit vs ${convParts[i]} $convUnit '
            '(expected ${(conv * f).toStringAsFixed(3)})';
      }
      continue;
    }
    if ((si - expected).abs() > tol + 1e-9) {
      return '${siParts[i]} vs ${convParts[i]}% (expected '
          '${expected.toStringAsFixed(2)})';
    }
  }
  return null;
}

double _pow10(int e) {
  var r = 1.0;
  for (var i = 0; i < e.abs(); i++) {
    r *= 10;
  }
  return e < 0 ? 1 / r : r;
}

void main() {
  final texts = [...quizTexts(), ...toifaNotes()];

  test('pair extraction recognises the agreed style', () {
    final m = pairRe.firstMatch('≥ 7,0 mmol/L (126 mg/dL) va')!;
    expect(m[1], '7,0');
    expect(m[3], '126');
    expect(checkPair('glucose', m, 'uz'), isNull);
    final range = pairRe.firstMatch('7.8–11.0 mmol/L (140–199 mg/dL)')!;
    expect(checkPair('glucose', range, 'en'), isNull);
    // Noto'g'ri koeffitsient (xolesterinniki) — xato.
    final wrong = pairRe.firstMatch('3,3 mmol/L (126 mg/dL)')!;
    expect(checkPair('glucose', wrong, 'uz'), isNotNull);
    // en da vergul — xato.
    expect(checkPair('glucose', m, 'en'), isNotNull);
    final ok = pairRe.firstMatch('39 mmol/mol (5,7%)')!;
    expect(checkPair('hba1c', ok, 'uz'), isNull);
    final bad = pairRe.firstMatch('42 mmol/mol (5,7%)')!;
    expect(checkPair('hba1c', bad, 'uz'), isNotNull);
    final plt = pairRe.firstMatch('100–150 ×10⁹/L (100 000–150 000/µL)')!;
    expect(plt[3], '100 000–150 000');
    expect(checkPair('plt', plt, 'uz'), isNull);
    expect(checkPair('plt', plt, 'en'), isNotNull); // en: "100,000"
    final pltEn = pairRe.firstMatch('15 ×10⁹/L (15,000/µL)')!;
    expect(checkPair('plt', pltEn, 'en'), isNull);
    final hct = pairRe.firstMatch('0,42 L/L (42%)')!;
    expect(checkPair('hct', hct, 'uz'), isNull);
    final iron = pairRe.firstMatch('9,0 µmol/L (50 µg/dL)')!;
    expect(checkPair('iron', iron, 'uz'), isNull);
    final b12 = pairRe.firstMatch('184 pmol/L (250 pg/mL)')!;
    expect(checkPair('b12', b12, 'en'), isNull);
    final b12bad = pairRe.firstMatch('250 pmol/L (250 pg/mL)')!;
    expect(checkPair('b12', b12bad, 'en'), isNotNull);
  });

  test('every SI (conventional) pair matches its analyte factor', () {
    final problems = <String>[];
    final seen = <String>{};
    for (final t in texts) {
      for (final m in pairRe.allMatches(t.text)) {
        final analyte = itemAnalyte[t.id];
        if (analyte == null) {
          problems.add('${t.id}/${t.lang}: unregistered pair "${m[0]}"');
          continue;
        }
        seen.add(t.id);
        final err = checkPair(analyte, m, t.lang);
        if (err != null) problems.add('${t.id}/${t.lang}: "${m[0]}" — $err');
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
    expect(
      seen,
      itemAnalyte.keys.toSet(),
      reason: 'registered items lost pairs',
    );
  });

  test('no conventional or SI value is left without its pair', () {
    final problems = <String>[];
    for (final t in texts) {
      if (bareAllowed.containsKey(t.id)) continue;
      final stripped = t.text.replaceAll(pairRe, '');
      for (final re in [bareConvRe, bareSiRe]) {
        for (final m in re.allMatches(stripped)) {
          problems.add('${t.id}/${t.lang}: "${m[0]}"');
        }
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('factors agree with the app conversion data (molar masses)', () {
    final pack = jsonDecode(
      File('assets/content/core/pack.json').readAsStringSync(),
    ) as Map;
    final conv = {
      for (final a in (pack['analytes'] as List).cast<Map<String, Object?>>())
        if (a['conversion'] is Map)
          a['id'] as String: (a['conversion']! as Map).cast<String, Object?>(),
    };
    // Rasmiy koeffitsientlar (konvensional → SI, mg/dL asosida).
    const official = <String, double>{
      'glucose-plasma-fasting': 1 / 18.016,
      'cholesterol-total': 1 / 38.67,
      'ldl-c': 1 / 38.67,
      'hdl-c': 1 / 38.67,
      'non-hdl-c': 1 / 38.67,
      'triglycerides': 1 / 88.57,
      'creatinine': 88.42,
      'uric-acid': 59.48,
      'bilirubin-total': 17.1,
      'calcium': 0.2495,
      'magnesium': 0.4114,
      'phosphate': 0.3229,
    };
    for (final e in official.entries) {
      final c = conv[e.key];
      expect(c, isNotNull, reason: e.key);
      final mm = (c!['molar_mass_g_per_mol'] as num).toDouble();
      final si = c['si_unit'] as String? ?? 'mmol/L';
      final app = (si == 'µmol/L' ? 10000 : 10) / mm;
      expect(
        (app - e.value).abs() / e.value,
        lessThan(1e-3),
        reason: '${e.key}: app $app vs official ${e.value}',
      );
    }
    expect(factors['glucose'], official['glucose-plasma-fasting']);
  });
}
