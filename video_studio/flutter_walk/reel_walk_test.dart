// LabGuide reel (docs/video/reel_labs): REAL app frames for the Sitologiya
// (cytology) section, which earlier topic videos never captured.
// Same method as overview_walk_test.dart: widget-test render of LabGuideApp
// (real content pack, no server, guest, role = lab, Classic light, 390x844 @2x).
//
//   cd /home/user/wt-audit
//   FRAMES_OUT=/home/user/wt-reel/video_studio/public/frames \
//   flock /tmp/flutter_test.lock /root/sdk/flutter/bin/flutter test \
//     /home/user/wt-reel/video_studio/flutter_walk/reel_walk_test.dart --update-goldens
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/cytology/cytology_content.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';

import 'file:///home/user/wt-audit/test/helpers/diff_device_fakes.dart';
import 'file:///home/user/wt-audit/test/helpers/harness.dart';
import 'walk_kit.dart';

const _src = 'video_studio/flutter_walk/reel_walk_test.dart';

void main() {
  setUpAll(loadAppFonts);

  for (final lang in AppLanguage.values) {
    testWidgets('reel cytology walk ${lang.name}', (tester) async {
      final code = lang.name;
      final l = lookupAppLocalizations(lang.locale);
      installDiffFakes();
      final s = await makeServices(tester, language: lang, role: AppRole.lab);
      await pumpApp(tester, s, ratio: 2);
      final w = Walk(tester, code, 'reel', source: _src);

      await goTo(tester, '/lab/cytology');
      await w.toTop();
      await w.snap('cy_home', marks: {'cells': find.text(l.cytoCellsTitle)});

      await goTo(tester, '/lab/cytology/cells');
      await w.toTop();
      await w.snap('cy_cells');

      await goTo(tester, '/lab/cytology/cells/${cytoCells.first.id}');
      await w.toTop();
      await w.snap('cy_cell');

      w.save();
      expect(tester.takeException(), isNull);
    });
  }
}
