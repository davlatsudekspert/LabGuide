// Xalqaro foydalanuvchi (ru/en, mintaqa UZ emas) uchun yurish: 5 ta tab va
// chuqur sahifalar, har birida ekran rasmi va o'zbekcha qolib ketgan matnni
// qidirish (o‘/g‘ belgilari, o'zbekcha xizmat so'zlari). Rasmlar:
// tool/screenshots/out/walk/intl_<til>/NN_<qadam>.png
//
//   flutter test tool/screenshots/walk_intl_test.dart --update-goldens
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';

import '../../test/helpers/harness.dart';
import 'walk_helper.dart';

const _routes = <(String, String)>[
  ('home', '/home'),
  ('tests', '/tests'),
  ('lab', '/lab'),
  ('library', '/library'),
  ('learn', '/learn'),
  ('profile', '/profile'),
  ('ldl_card', '/tests/analyte/ldl-c'),
  ('glucose_card', '/tests/analyte/glucose-plasma-fasting'),
  ('calc_list', '/lab/calculators'),
  ('calc_ldl', '/lab/calculators/ldl'),
  ('calc_egfr', '/lab/calculators/egfr'),
  ('calc_calcium', '/lab/calculators/calcium'),
  ('units', '/lab/calculators/units'),
  ('qc', '/lab/qc'),
  ('preanalytics', '/lab/preanalytics'),
  ('instruments', '/lab/instruments'),
  ('microscopy', '/lab/microscopy'),
  ('differential', '/lab/differential'),
  ('reference', '/learn/reference'),
  ('daily', '/learn/daily'),
  ('books', '/library/books'),
];

final _uzbek = RegExp(
  r'[oOgG][‘’ʻ]|\b(uchun|bilan|emas|yoki|qiymat\w*|tahlil\w*|natija\w*|sahifa\w*|bo‘lim\w*|kalkulyator\w*)\b',
);

Set<String> _texts(WidgetTester tester) {
  final out = <String>{};
  for (final w in tester.widgetList<Text>(find.byType(Text))) {
    final s = w.data ?? w.textSpan?.toPlainText();
    if (s != null) out.add(s);
  }
  for (final w in tester.widgetList<RichText>(find.byType(RichText))) {
    out.add(w.text.toPlainText());
  }
  return out;
}

void main() {
  setUpAll(loadAppFonts);

  for (final lang in [AppLanguage.ru, AppLanguage.en]) {
    testWidgets('intl walk (${lang.name})', (tester) async {
      await start(tester, lang: lang);
      final w = Walk(tester, 'intl_${lang.name}');
      final hits = <String>[];
      for (final (name, path) in _routes) {
        await goTo(tester, path);
        await w.snap(name);
        for (final t in _texts(tester)) {
          if (_uzbek.hasMatch(t)) {
            hits.add('[$name] ${t.replaceAll('\n', ' ')}');
          }
        }
      }
      // ignore: avoid_print
      print('UZBEK-LEFTOVERS (${lang.name}): ${hits.length}');
      for (final h in hits) {
        // ignore: avoid_print
        print('  $h');
      }
      expect(tester.takeException(), isNull);
    });
  }
}
