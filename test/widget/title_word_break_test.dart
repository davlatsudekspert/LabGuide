// Audit 2026-10-18 (tablar, docs/AUDIT_2026-10-18_TABS.md): kichik
// telefonda katta shrift bilan (360×640, ×1.3) sahifa sarlavhasidagi uzun
// so'z o'rtasidan bo'linardi: ru "Конфиденциальност / ь и данные".
// [FitLongWordText] so'zni sig'dirish uchun shriftni kichraytiradi, lekin
// pastki chegara (minFontSize) masshtabdan OLDIN qo'llanib, ×1.3 da so'z
// baribir sig'masdi. Endi chegara ko'rsatiladigan o'lchamga qo'llanadi.
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/widgets/lg_page.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

/// Lab tabidan tashqari sahifalar (audit doirasi).
const _routes = [
  '/home/search',
  '/tests',
  '/tests/conditions',
  '/tests/analyte/anti-ccp',
  '/tests/analyte/hba1c',
  '/library',
  '/library/books',
  '/library/packs',
  '/library/sources',
  '/library/research',
  '/library/intake',
  '/learn/reference',
  '/learn/quiz',
  '/learn/exam',
  '/learn/daily',
  '/learn/classes',
  '/learn/classes/join',
  '/learn/lecture',
  '/profile',
  '/profile/role',
  '/profile/theme',
  '/profile/privacy',
  '/profile/help',
  '/profile/contact',
  '/profile/support',
  '/terms',
];

/// Har bir sarlavhaning har bir so'zi bitta qatorga sig'adi.
void _expectNoWordBreak(WidgetTester tester, String where) {
  for (final e in find.byType(FitLongWordText).evaluate()) {
    final para =
        find
                .descendant(
                  of: find.byWidget(e.widget),
                  matching: find.byType(RichText),
                )
                .evaluate()
                .first
                .renderObject!
            as RenderParagraph;
    final width = para.size.width;
    final title = (e.widget as FitLongWordText).text;
    for (final word in title.split(RegExp(r'\s+'))) {
      if (word.isEmpty) continue;
      final painter = TextPainter(
        text: TextSpan(text: word, style: para.text.style),
        textDirection: TextDirection.ltr,
        textScaler: para.textScaler,
        maxLines: 1,
      )..layout();
      expect(
        painter.width,
        lessThanOrEqualTo(width + 0.5),
        reason: '$where: "$word" in "$title" is split mid-word',
      );
      painter.dispose();
    }
  }
}

void main() {
  setUpAll(loadAppFonts);

  for (final lang in AppLanguage.values) {
    for (final (w, scale) in [(360.0, 1.3), (320.0, 1.3), (390.0, 1.0)]) {
      testWidgets('${lang.name} ${w.toInt()} ×$scale: no title word split', (
        tester,
      ) async {
        final s = await makeServices(tester, language: lang);
        await pumpApp(tester, s, size: Size(w, 640), textScale: scale);
        for (final r in _routes) {
          await goTo(tester, r);
          expect(tester.takeException(), isNull, reason: r);
          _expectNoWordBreak(tester, '${lang.name} $r');
        }
      });
    }
  }
}
