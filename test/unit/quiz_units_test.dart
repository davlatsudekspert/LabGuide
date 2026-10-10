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
};

/// Juftsiz qiymat ruxsat etilgan savollar (sabab bilan).
const bareAllowed = <String, String>{
  // Koeffitsientning o'zi haqida ("glyukoza ≈ 18,0 mg/dL har 1 mmol/L ga") —
  // laboratoriya natijasi emas.
  'unit-factor': 'conversion factor statement',
};

const _num = r'\d+(?:[.,]\d+)?';
const _siUnits = r'mmol/L|ммоль/л|g/L|г/л|mmol/mol|ммоль/моль';
const _convUnits = r'mg/dL|мг/дл|g/dL|г/дл|%';
final pairRe = RegExp(
  '($_num(?:–$_num)?) ($_siUnits) \\(($_num(?:–$_num)?) ?($_convUnits)\\)',
);
final bareConvRe = RegExp('$_num(?:–$_num)? ?(?:mg/dL|мг/дл|g/dL|г/дл)');
final bareSiRe = RegExp('$_num(?:–$_num)? (?:mmol/L|ммоль/л|g/L|г/л)(?! \\()');

double _parse(String s) => double.parse(s.replaceAll(',', '.'));

int _decimals(String s) {
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
  if (m[0]!.contains(RegExp('\\d\\$sep\\d'))) {
    return 'decimal separator for $lang';
  }
  final hba1c = analyte == 'hba1c';
  if (hba1c != (convUnit == '%')) return 'unit $convUnit for $analyte';
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
