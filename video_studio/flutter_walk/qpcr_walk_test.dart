// LabGuide video studio — REAL app frames for the topic video "Real-time
// PCR" (docs/video/qpcr/): Lab → Instruments and methods → Molecular
// diagnostics → "Real-time PCR (qPCR/RT-qPCR) method" card
// (`a1-realtime-pcr-method`, sources: one NCBI Bookshelf page) with the app's
// original schematic, numbered parts, principle, limitations and the
// contamination-prevention note. (The platform card, which states the Cq
// readout, is not filmed: one of its sources names a manufacturer.)
//
//   cd /home/user/wt-audit
//   flock /tmp/flutter_test.lock /root/sdk/flutter/bin/flutter test \
//     /home/user/wt-video/video_studio/flutter_walk/qpcr_walk_test.dart --update-goldens
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
  final cards = (catalog['lab_cards'] as List).cast<Map>();
  final method = cards.firstWhere((c) => c['id'] == 'a1-realtime-pcr-method');
  for (final lang in AppLanguage.values) {
    testWidgets('qpcr walk ${lang.name}', (tester) async {
      final code = lang.name;
      final l = lookupAppLocalizations(lang.locale);
      final s = await makeServices(tester, language: lang, role: walkRole);
      await pumpApp(tester, s, ratio: 2);
      final w = Walk(tester, code, 'qpcr', source: 'video_studio/flutter_walk/qpcr_walk_test.dart');
      await labCardWalk(tester, w, l,
          cardId: 'a1-realtime-pcr-method',
          cardName: (method['name'] as Map)[code] as String,
          direction: 'molecular',
          schematicKey: 'real_time_pcr',
          prefix: 'q',
          fields: {
            'q_principle': l.labDirPrinciple,
            'q_limits': l.labDirLimitations,
            'q_qc': l.labDirQc,
          });
      w.record['cards'] = ['a1-realtime-pcr-method'];
      w.save();
      expect(tester.takeException(), isNull);
    });
  }
}
