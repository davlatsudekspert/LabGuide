// LabGuide video studio — REAL app frames for the topic video "GC-MS"
// (docs/video/gcms/): Lab → Instruments and methods → Toxicology → the GC-MS
// card (`a3-tox-gc-ms`) with the app's original schematic, the numbered parts
// panel and the principle / QC / biosafety fields. Real app, no server,
// 390x844 @2x; brand check on every frame (labcard_kit.dart + walk_kit.dart).
//
//   cd /home/user/wt-audit
//   flock /tmp/flutter_test.lock /root/sdk/flutter/bin/flutter test \
//     /home/user/wt-video/video_studio/flutter_walk/gcms_walk_test.dart --update-goldens
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';

import 'file:///home/user/wt-audit/test/helpers/harness.dart';
import 'labcard_kit.dart';
import 'walk_kit.dart';

void main() {
  setUpAll(loadAppFonts);
  final catalog = jsonDecode(File('assets/instruments/catalog.json').readAsStringSync()) as Map;
  final card = (catalog['lab_cards'] as List).cast<Map>().firstWhere((c) => c['id'] == 'a3-tox-gc-ms');
  for (final lang in AppLanguage.values) {
    testWidgets('gcms walk ${lang.name}', (tester) async {
      final code = lang.name;
      final l = lookupAppLocalizations(lang.locale);
      final s = await makeServices(tester, language: lang, role: walkRole);
      await pumpApp(tester, s, ratio: 2);
      final w = Walk(tester, code, 'gcms', source: 'video_studio/flutter_walk/gcms_walk_test.dart');
      await labCardWalk(tester, w, l,
          cardId: 'a3-tox-gc-ms',
          cardName: (card['name'] as Map)[code] as String,
          direction: 'toxicology',
          schematicKey: 'mass_spec_gc',
          prefix: 'g',
          fields: {
            'g_principle': l.labDirPrinciple,
            'g_qc': l.labDirQc,
            'g_bio': l.labDirBiosafety,
          });
      w.record['card'] = 'a3-tox-gc-ms';
      w.save();
      expect(tester.takeException(), isNull);
    });
  }
}
