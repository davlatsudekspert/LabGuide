// LabGuide video studio — REAL app frames for the topic video
// "Spectrophotometry" (docs/video/photometry/).
//
// Every frame is the real app (widget-test render of LabGuideApp: real
// assets, no server, guest, role = lab, Classic light theme, 390x844 @2x):
// Learn → Lecture mode → Practical protocols → "Basics of biochemical
// photometry and working with a reagent kit" (assets/lectures/decks/
// fotometriya-asoslari-biokimyo.<lang>.json). Slides are picked by their
// CONTENT (the step numbers and the "10 %" absorbance slide), because the
// three language decks split the steps over different slide indices. Slides
// that name a photometer brand are never opened (brand check enforces it).
//
//   cd /home/user/wt-audit
//   flock /tmp/flutter_test.lock /root/sdk/flutter/bin/flutter test \
//     /home/user/wt-video/video_studio/flutter_walk/photometry_walk_test.dart --update-goldens
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/core/storage/kv_store.dart';
import 'package:labguide/features/classroom/lecture_catalog.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import 'file:///home/user/wt-audit/test/helpers/diff_device_fakes.dart';
import 'file:///home/user/wt-audit/test/helpers/harness.dart';
import 'walk_kit.dart';

const _video = 'photometry';
const _deck = 'fotometriya-asoslari-biokimyo';

/// Slide index whose bullets satisfy [test] (first match).
int _slide(List slides, bool Function(String b) test) {
  for (var i = 0; i < slides.length; i++) {
    final bullets = ((slides[i] as Map)['bullets'] as List? ?? const []).cast<String>();
    if (bullets.any(test)) return i;
  }
  throw StateError('slide not found');
}

/// On screen the step number is drawn separately: the bullet text without
/// its "N. " prefix.
Finder _step(List slides, int i, String n) {
  final bullets = ((slides[i] as Map)['bullets'] as List).cast<String>();
  final b = bullets.firstWhere((b) => b.startsWith('$n.'));
  return find.text(b.replaceFirst(RegExp(r'^\d+\.\s*'), ''));
}

Finder _startsWith(String prefix) => find.byWidgetPredicate(
      (w) => w is RichText && w.text.toPlainText().trimLeft().startsWith(prefix),
    );

Finder _contains(String s) => find.byWidgetPredicate(
      (w) => w is RichText && w.text.toPlainText().contains(s),
    );

void main() {
  setUpAll(loadAppFonts);
  for (final lang in AppLanguage.values) {
    testWidgets('photometry walk ${lang.name}', (tester) async {
      final code = lang.name;
      final l = lookupAppLocalizations(lang.locale);
      installDiffFakes();
      final deck = jsonDecode(
        File('assets/lectures/decks/$_deck.$code.json').readAsStringSync(),
      ) as Map<String, Object?>;
      final slides = deck['slides']! as List;
      final n = slides.length;
      final iBlank = _slide(slides, (b) => b.startsWith('2.'));
      final iCalc = _slide(slides, (b) => b.startsWith('5.'));
      final iLin = _slide(slides, (b) => b.startsWith('6.'));
      final iAbs = _slide(slides, (b) => b.contains('10%') && b.contains('90%'));
      final s = await makeServices(tester, language: lang, role: AppRole.lab);
      PaintingBinding.instance.imageCache
        ..maximumSize = 4000
        ..maximumSizeBytes = 1 << 30;
      await pumpApp(tester, s, ratio: 2);
      final w = Walk(tester, code, _video,
          source: 'video_studio/flutter_walk/photometry_walk_test.dart');

      // 1. Learn tab → Lecture mode row.
      await goTo(tester, '/learn');
      await w.bring(find.text(l.lectureListTitle), at: 420);
      await w.snap('learn', tapOn: find.text(l.lectureListTitle),
          marks: {'row': find.text(l.lectureListTitle)});

      // 2. Lecture list filtered to the practical protocols, photometry row.
      await goTo(tester, '/learn/lecture');
      await tester.tap(find.byKey(const ValueKey('lecture-filter-protocols')));
      await tester.pumpAndSettle();
      final row = find.byKey(const ValueKey('deck-$_deck'));
      await w.bring(row, at: 470);
      await w.snap('list', tapOn: row, marks: {
        'row': row,
        'filter': find.byKey(const ValueKey('lecture-filter-protocols')),
      });

      // 3. Slides (opened the way the app's own tests open them: the player
      //    reads the deck synchronously, so it is loaded first).
      await tester.runAsync(() async {
        final c = await DeckCatalog.load(rootBundle);
        final e = c.byId(_deck)!;
        await DeckCatalog.loadDeck(rootBundle, e, e.resolveLang(code));
      });
      Future<void> slide(String id, int i, Map<String, Finder> marks) async {
        await goTo(tester, '/learn/lecture');
        await goTo(tester, '/learn/lecture/deck/$_deck?s=$i');
        expect(find.text(l.lectureCounter(i + 1, n)), findsOneWidget);
        await w.snap(id, marks: marks, texts: true);
      }

      await slide('principle', 2, {'title': find.text((slides[2] as Map)['title'] as String)});
      await slide('blank', iBlank, {'step2': _step(slides, iBlank, '2')});
      await slide('calc', iCalc, {'step5': _step(slides, iCalc, '5')});
      await slide('lin', iLin, {'step6': _step(slides, iLin, '6')});
      await slide('abs', iAbs, {'ten': _contains('90%')});
      // 4. Full screen on a phone turns the slide landscape (the app's own
      //    LecturePresentation; orientation choice stored as "landscape" so
      //    no dialog). The same slides, 844x390.
      await s.store.setString(StoreKeys.lectureOrientation, 'landscape');
      Future<void> full(String id, int i, Map<String, Finder> marks) async {
        tester.view.physicalSize = const Size(390, 844) * 2;
        await tester.pumpAndSettle();
        await goTo(tester, '/learn/lecture');
        await goTo(tester, '/learn/lecture/deck/$_deck?s=$i');
        await tester.tap(find.text(l.lectureFullscreen).first);
        await tester.pumpAndSettle();
        // The app forces landscape: the phone is turned (844x390).
        tester.view.physicalSize = const Size(844, 390) * 2;
        tester.view.padding = FakeViewPadding.zero;
        await tester.pumpAndSettle();
        // The small on-screen buttons hide after 3 s (TV-clean slide).
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();
        await w.snap(id, marks: marks, texts: true);
      }

      await full('fs_principle', 2, {'title': find.text((slides[2] as Map)['title'] as String)});
      await full('fs_blank', iBlank, {'step2': _step(slides, iBlank, '2')});
      await full('fs_calc', iCalc, {'step5': _step(slides, iCalc, '5')});
      await full('fs_lin', iLin, {'step6': _step(slides, iLin, '6')});
      await full('fs_abs', iAbs, {'ten': find.text('10%')});
      w.record.addAll({
        'deck': _deck,
        'slides': {'principle': 2, 'blank': iBlank, 'calc': iCalc, 'lin': iLin, 'abs': iAbs, 'n': n},
        'deckTitle': deck['title'],
      });
      w.save();
      expect(tester.takeException(), isNull);
    });
  }
}
