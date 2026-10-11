// 6–7-videolar: ilova bilan tanishuv va shifokor uchun tahlillar.
//   flutter test tool/video/frames_overview_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/community/community_screens.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'common.dart';
import 'rec.dart';

void main() {
  setUpAll(loadAppFonts);
  final l = lookupAppLocalizations(const Locale('uz'));

  testWidgets('v6 tanishuv', (tester) async {
    final (_, _, _) = await startCommunity(
      tester,
      onboarded: false,
      languageChosen: false,
    );
    final r = Rec(tester, 'v6');
    await r.shot('til', target: vis('O‘zbekcha'));
    await r.tapText('O‘zbekcha');
    await r.shot('welcome', target: vis(l.welcomeGuest));
    await r.tapText(l.welcomeGuest);
    await r.shot('role');
    await r.shot('role_pick', target: vis(l.roleDoctor));
    await r.tapText(l.roleDoctor);
    await r.shot('role_picked', target: await reveal(tester, find.text(l.actionContinue)));
    await tapR(tester, find.text(l.actionContinue));
    await r.shot('home', target: vis(l.navTests));
    await r.scroll(500);
    await r.shot('home_low');
    await tester.drag(vertical(), const Offset(0, 3000));
    await tester.pumpAndSettle();
    await r.tapText(l.navTests);
    await r.shot('tests', target: find.byType(TextField).first, kind: 'type');
    await tester.enterText(find.byType(TextField).first, 'HbA1c');
    await tester.pumpAndSettle();
    await r.shot('tests_search', target: vis(l.navLab));
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();
    await r.tapText(l.navLab);
    await r.shot('lab', target: vis(l.navLibrary));
    await r.tapText(l.navLibrary);
    await r.shot('library', target: vis(l.navLearn));
    await r.tapText(l.navLearn);
    await r.shot('learn');
    await goTo(tester, '/profile');
    final conv = await reveal(tester, find.textContaining('anaviy'));
    await centerOn(tester, conv, alignment: 0.55, force: true);
    await r.shot('profile', target: conv, scrollTo: false);
    await tester.tap(conv);
    await tester.pumpAndSettle();
    await r.shot('units', target: vis(l.themeDark), scrollTo: false);
    final si = await reveal(tester, find.textContaining('SI ('), center: false);
    await tester.tap(si);
    await tester.pumpAndSettle();
    await goTo(tester, '/home');
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('community-home-card')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await r.shot('community');
    await goTo(tester, CommunityRoutes.list());
    await r.shot(
      'community_list',
      target: find.byKey(const ValueKey('cm-rules-toggle')),
    );
    await tester.tap(find.byKey(const ValueKey('cm-rules-toggle')));
    await tester.pumpAndSettle();
    await r.shot('rules');
    r.save();
  });

  testWidgets('v7 shifokor', (tester) async {
    final (s, _, _) = await startCommunity(tester);
    final r = Rec(tester, 'v7');
    final gname =
        s.content.pack!.analyte('hba1c')!.names.of('uz');
    await r.shot('home', target: find.text(l.condGuideSearch));
    await tester.tap(find.text(l.condGuideSearch));
    await tester.pumpAndSettle();
    await r.shot('conditions', target: find.byType(TextField).first, kind: 'type');
    await tester.enterText(find.byType(TextField).first, 'diabet');
    await tester.pumpAndSettle();
    final cond = find.textContaining('qandli diabet').first;
    await r.shot('conditions_search', target: cond);
    await tester.tap(cond);
    await tester.pumpAndSettle();
    await r.shot('condition');
    await r.scroll(500);
    await r.shot('condition_low');
    await goTo(tester, '/home');
    await r.tapText(l.navTests);
    await r.shot('tests', target: find.byType(TextField).first, kind: 'type');
    await tester.enterText(find.byType(TextField).first, 'HbA1c');
    await tester.pumpAndSettle();
    await r.shot('search', target: find.text(gname).first);
    await tester.tap(find.text(gname).first);
    await tester.pumpAndSettle();
    await r.shot('card_top');
    Future<void> sec(String id, String text, {double a = 0.2}) async {
      try {
        await tester.scrollUntilVisible(
          find.text(text).hitTestable(),
          200,
          scrollable: vertical(),
          maxScrolls: 40,
        );
      } on Object {
        // ignore: avoid_print
        print('NOSEC $id');
        await tester.drag(vertical(), const Offset(0, 6000));
        await tester.pumpAndSettle();
        return;
      }
      await centerOn(tester, find.text(text).hitTestable().last,
          alignment: a, force: true);
      await r.shot(id);
    }

    await sec('card_ref', l.analyteRefIntervals);
    await sec('card_high', l.sectionHighResult);
    await sec('card_low', l.sectionLowResult);
    await sec('card_conv', l.analyteConvertUnits);
    await sec('card_sources', l.analyteSources);
    final link = find.byKey(
      const ValueKey('community-topic-analyte:hba1c'),
    );
    await tester.scrollUntilVisible(link, 200, scrollable: vertical());
    await centerOn(tester, link, alignment: 0.4, force: true);
    await r.shot('card_community', target: link);
    // Kreatinin → eGFR kalkulyatori.
    await goTo(tester, '/tests/analyte/creatinine');
    final egfr = find.text(l.calcEgfr);
    await tester.scrollUntilVisible(egfr, 200, scrollable: vertical());
    await centerOn(tester, egfr, alignment: 0.4, force: true);
    await r.shot('creat_link', target: egfr);
    await tester.tap(egfr);
    await tester.pumpAndSettle();
    await r.shot('egfr', target: find.byType(TextField).at(0), kind: 'type');
    await tester.enterText(find.byType(TextField).at(0), '97');
    await tester.enterText(find.byType(TextField).at(1), '54');
    await tester.pumpAndSettle();
    await r.shot('egfr_filled', target: find.text(l.sexFemale));
    await tester.tap(find.text(l.sexFemale));
    await tester.pumpAndSettle();
    await r.shot('egfr_sex', target: find.text(l.dilCalculate));
    await tester.tap(find.text(l.dilCalculate));
    await tester.pumpAndSettle();
    final res = find.textContaining('mL/min/1.73 m²').first;
    await centerOn(tester, res, alignment: 0.4, force: true);
    await r.shot('egfr_result');
    r.save();
  });
}
