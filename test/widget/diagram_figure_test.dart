import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/widgets/diagram_figure.dart';
import 'package:labguide/design/theme.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

/// Egasi taqdim etgan 18 ta sxema (6 mavzu × uz/ru/en): fayllar, o'lcham,
/// hajm, huquq jadvali (sha256), uch tilli muqobil matn, 320 px / ×1.3
/// maketi va ekranlarda ko'rinishi.
const _langs = ['uz', 'ru', 'en'];

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  required String lang,
  double width = 320,
  double scale = 1.3,
  Brightness brightness = Brightness.light,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 2400);
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildLgTheme(brightness),
      locale: Locale(lang),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ListView(padding: const EdgeInsets.all(16), children: [child]),
      ),
    ),
  );
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 200)),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  group('diagram assets', () {
    test('18 PNG, 960x640, <=150 KB, registered, listed in provenance', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('- assets/diagrams/'));
      final doc = File('docs/DIAGRAMS_PROVENANCE.md').readAsStringSync();
      for (final t in DiagramTopic.values) {
        for (final lang in _langs) {
          final path = t.asset(lang);
          final f = File(path);
          expect(f.existsSync(), isTrue, reason: path);
          final bytes = f.readAsBytesSync();
          expect(bytes.length, lessThanOrEqualTo(150 * 1024), reason: path);
          final bd = ByteData.sublistView(Uint8List.fromList(bytes));
          expect(bd.getUint32(0), 0x89504E47, reason: '$path PNG magic');
          expect(bd.getUint32(16), 960, reason: '$path width');
          expect(bd.getUint32(20), 640, reason: '$path height');
          final digest = sha256.convert(bytes).toString();
          expect(doc, contains(digest), reason: '$path sha256 missing in doc');
          expect(doc, contains(path.split('/').last), reason: path);
        }
      }
    });

    test('unknown language falls back to English asset', () {
      expect(
        DiagramTopic.qcDecision.asset('de'),
        'assets/diagrams/qc_decision.en.png',
      );
    });

    test('alt texts: present in 3 languages, uz uses U+2018 apostrophes', () {
      final inWord = RegExp(r"(?<=[A-Za-z])'(?=[A-Za-z])");
      for (final lang in _langs) {
        final l = lookupAppLocalizations(Locale(lang));
        for (final t in DiagramTopic.values) {
          final alt = t.alt(l);
          expect(alt.length, greaterThan(80), reason: '$lang ${t.name}');
          expect(inWord.hasMatch(alt), isFalse, reason: '$lang ${t.name}');
        }
        expect(l.imgDiagramCaption, isNotEmpty);
        expect(l.imgDiagramTapToZoom, isNotEmpty);
      }
      final uz = lookupAppLocalizations(const Locale('uz'));
      expect(uz.imgDiagramQcDecisionAlt, contains('o‘lchash'));
    });

    test('ARB keys identical in uz/ru/en', () {
      Set<String> keys(String l) =>
          (jsonDecode(File('lib/l10n/app_$l.arb').readAsStringSync())
                  as Map<String, dynamic>)
              .keys
              .where((k) => k.startsWith('imgDiagram'))
              .toSet();
      expect(keys('uz'), keys('en'));
      expect(keys('ru'), keys('en'));
      expect(keys('en').length, 8);
    });
  });

  for (final lang in _langs) {
    for (final (width, scale) in [(320.0, 1.3), (320.0, 2.0), (390.0, 1.0)]) {
      testWidgets('all six figures lay out: $lang ${width.toInt()}px ×$scale', (
        tester,
      ) async {
        final l = lookupAppLocalizations(Locale(lang));
        await _pump(
          tester,
          Column(
            children: [
              for (final t in DiagramTopic.values) DiagramFigure(topic: t),
            ],
          ),
          lang: lang,
          width: width,
          scale: scale,
        );
        expect(tester.takeException(), isNull);
        for (final t in DiagramTopic.values) {
          final img = tester.widget<Image>(
            find.descendant(
              of: find.byKey(ValueKey('diagram-${t.file}')),
              matching: find.byType(Image),
            ),
          );
          expect(img.image, AssetImage(t.asset(lang)));
        }
        expect(find.text(l.imgDiagramCaption), findsNWidgets(6));
      });
    }
  }

  testWidgets('semantic label is the localized alt text; tap opens zoom', (
    tester,
  ) async {
    final l = lookupAppLocalizations(const Locale('ru'));
    await _pump(
      tester,
      const DiagramFigure(topic: DiagramTopic.photometry),
      lang: 'ru',
    );
    final handle = tester.ensureSemantics();
    await tester.pump();
    final node = tester.getSemantics(
      find.byKey(const ValueKey('diagram-photometry')),
    );
    expect(node.label, contains(DiagramTopic.photometry.alt(l)));
    expect(node.hint, l.imgDiagramTapToZoom);
    handle.dispose();
    await tester.tap(find.byKey(const ValueKey('diagram-photometry')));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOneWidget);
    await tester.tap(find.byTooltip(l.micClose));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsNothing);
  });

  group('screens show the matching diagram in the UI language', () {
    for (final lang in AppLanguage.values) {
      testWidgets('routes: ${lang.name}', (tester) async {
        final s = await makeServices(tester, language: lang);
        await pumpApp(tester, s, size: const Size(320, 2600), textScale: 1.3);
        const routes = {
          '/lab/calibration': 'calibration_overview',
          '/lab/differential': 'differential_count',
          '/lab/qc': 'qc_decision',
          '/lab/preanalytics': 'preanalytics',
          '/lab/instruments/m/human-humalyzer-4000': 'photometry',
        };
        for (final e in routes.entries) {
          await goTo(tester, e.key);
          expect(tester.takeException(), isNull, reason: e.key);
          final f = find.byKey(ValueKey('diagram-${e.value}'));
          expect(f, findsOneWidget, reason: e.key);
          final img = tester.widget<Image>(
            find.descendant(of: f, matching: find.byType(Image)),
          );
          expect(
            img.image,
            AssetImage('assets/diagrams/${e.value}.${lang.name}.png'),
            reason: e.key,
          );
        }
        // Fotometrik bo'lmagan model (gematologiya): fotometriya sxemasi yo'q.
        await goTo(tester, '/lab/instruments/m/mindray-bc-5390');
        expect(find.byKey(const ValueKey('diagram-photometry')), findsNothing);
      });
    }
  });
}
