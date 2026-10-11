// 11-video: ustoz uchun "Ma'ruza rejimi" — O'rganish bo'limidan 1-mavzu
// taqdimotini ochish.
//   flutter test tool/video/frames_lecture_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../../test/helpers/harness.dart';
import 'common.dart';
import 'rec.dart';

const _topic = 'd001-P';

void main() {
  setUpAll(loadAppFonts);
  final l = lookupAppLocalizations(const Locale('uz'));

  testWidgets('v11 maruza rejimi', (tester) async {
    final (s, _, _) = await startCommunity(tester, role: AppRole.teacher);
    final topic = s.curriculum.curriculum!.topics
        .firstWhere((t) => t.id == _topic)
        .title
        .of('uz');
    final r = Rec(tester, 'v11');
    await r.shot('home', target: vis(l.navLearn));
    await r.tapText(l.navLearn);
    await r.shot(
      'learn',
      target: await reveal(tester, find.text(l.lectureListTitle)),
    );
    await tapR(tester, find.text(l.lectureListTitle));
    await r.shot('list', target: await reveal(tester, find.text(topic)));
    await tapR(tester, find.text(topic));
    final total = List.generate(30, (k) => k + 1).firstWhere(
      (k) => find.text(l.lectureCounter(1, k)).evaluate().isNotEmpty,
    );
    for (var n = 1; n <= total; n++) {
      final last = n == total;
      await r.shot(
        'slide$n',
        target: last ? find.byTooltip(l.lectureClose) : vis(l.lectureNext),
      );
      if (!last) {
        await tester.tap(vis(l.lectureNext));
        await tester.pumpAndSettle();
      }
    }
    final n = total;
    // ignore: avoid_print
    print('SLIDES $n');
    r.save();
  });
}
