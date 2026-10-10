// Yakuniy vizual tekshiruv regressiyalari (tool/screenshots/walk_final_check):
// birlik satr oxirida bo'linmasligi va tor ekran + katta shriftda Lab
// tabidagi leykoformula kartasi sarlavhasining so'z o'rtasidan uzilmasligi.
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/learn/exam_question.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';

import '../helpers/harness.dart';

void main() {
  setUpAll(loadAppFonts);

  test('keepUnitsTogether: birlik va son bo‘linmaydi, matn o‘zgarmaydi', () {
    const uz = '7,8–11,0 mmol/L (140–199 mg/dL) va 11,1 mmol/L';
    final glued = keepUnitsTogether(uz);
    expect(glued.contains('mmol/⁠L'), isTrue);
    expect(glued.contains('mg/⁠dL'), isTrue);
    expect(glued.contains('11,0 mmol'), isTrue);
    // Ko'rinmas belgilarsiz asl matn.
    expect(glued.replaceAll('⁠', '').replaceAll(' ', ' '), uz);
    const ru = '5,6 ммоль/л (100 мг/дл)';
    expect(keepUnitsTogether(ru).contains('ммоль/⁠л'), isTrue);
    // Birlik bo'lmagan "/" va so'zlar tegilmaydi.
    expect(keepUnitsTogether('A/B va L/min'), 'A/B va L/min');
  });

  testWidgets('leykoformula kartasi 320 px va 1.35 shriftda bir qator', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('ru'));
    final s = await makeServices(tester, language: AppLanguage.ru);
    await pumpApp(tester, s, size: const Size(320, 640), textScale: 1.35);
    await goTo(tester, '/lab');
    final title = find.text(l.diffTitle).first;
    expect(title, findsOneWidget);
    final para = tester.renderObject<RenderParagraph>(title);
    final lines = para.getBoxesForSelection(
      TextSelection(baseOffset: 0, extentOffset: l.diffTitle.length),
    );
    expect(lines.length, 1, reason: 'sarlavha so‘z o‘rtasidan uzilmasin');
    expect(tester.takeException(), isNull);
  });
}
