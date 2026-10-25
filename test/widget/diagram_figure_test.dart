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

/// Repoda yaratilgan 18 ta original sxema (6 mavzu × uz/ru/en): fayllar,
/// o'lcham, hajm, kelib chiqish jadvali (PNG va SVG sha256, holat
/// ORIGINAL_CREATED_IN_REPO), eski (muallifi noma'lum) rasmlar qaytmagani,
/// uch tilli muqobil matn, 320 px / ×1.3 maketi va ekranlarda ko'rinishi.
const _langs = ['uz', 'ru', 'en'];

/// Iste'moldan chiqarilgan eski 18 ta rasm (muallifi noma'lum, 2026-10-24
/// paketi) — sha256; docs/DIAGRAMS_PROVENANCE.md dagi RETIRED jadval.
const _retired = <String>{
  '65ebf953a8d7ac4a0e605a779dfa4f05eb834c23e97c58927bea0b4d8fabafbd',
  'd18a55fcbd66fbb6e1dce193e31da88f32722f76f0ce776ee7d7a3c1ae0a9974',
  'c99b6471e25191c0432609bb02f1858cb57e24ce8e2cdffd6f3f2465df122054',
  '737341ae9ccb6897eb184b6251825a7308e44c71dc062bcd71954bb63a530e7e',
  'e7b45f88ee87882badb8ada9e66fc9f4322703e2be728b018601bf85eca39d0d',
  '0a3d92daa679fd4b14087d745b9e7ac7c115cbf808cb7eb47903f6cc06d2f595',
  '447817f63c794d64a3d609cf14a7e3c7eebd71c6c350bd8c12d15c35e547dd6e',
  '3043b84375dd34ba417f7149fd3fe99da19afbd484c5b491880dd54956cecc3a',
  '81673cf2dddae5fa7b8c5967b56c51b576b6fea339b229cfd7c591f3f3ae129d',
  '50c1ca01aef0897232299192ee9b62b9dc22dae4e037599ffc1193e506eae118',
  'f2dc1edc870435fff67e48b7b4479cd88a937f5073bbc0fd982e4501880bfd0b',
  '17e7f19fefe7bdff5cee6c245720e8d057c58fc9ecacdc4a52c5a0d03eafb062',
  'c50788f4b95c2df6537eed50f934b468bcccee3015ca72663be9fb740c769afc',
  '643c3fb8432ac420673e16d7fd28c852b2cac4ee1c3c97629f4d0becd9263c9b',
  'f94c5fbe3b31c9e86ba17d7fe85236e58757016dd311a363638c641529c47dce',
  '5491cab79b29facbd0aa3846bf2b75598669983bcac87f84518a1d567f4c14ab',
  '217afce71b593ce4728cb80d4095c64aa9a9c194dfde2c17b8229ae89e8c490e',
  '021090e740e0681c5c93d2657933b129b85378b53af3e01f06c7cb60cf349e07',
};

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
    test('18 PNG, 1920x1280 (2x of 960x640), <=150 KB, registered, listed in provenance', () {
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
          expect(bd.getUint32(16), 1920, reason: '$path width');
          expect(bd.getUint32(20), 1280, reason: '$path height');
          final digest = sha256.convert(bytes).toString();
          expect(doc, contains(digest), reason: '$path sha256 missing in doc');
          expect(doc, contains(path.split('/').last), reason: path);
          // Eski (muallifi noma'lum) rasm qaytib kelmasin.
          expect(_retired, isNot(contains(digest)), reason: '$path is retired');
          // Jadval qatori: fayl nomi, PNG sha, SVG manba sha, holat.
          final name = path.split('/').last;
          final row = doc
              .split('\n')
              .firstWhere(
                (l) => l.startsWith('| `$name`') && l.contains(digest),
                orElse: () => '',
              );
          expect(row, contains('ORIGINAL_CREATED_IN_REPO'), reason: name);
          final svg = File(
            'tool/diagrams/svg/${name.replaceAll('.png', '.svg')}',
          );
          expect(svg.existsSync(), isTrue, reason: svg.path);
          final svgDigest = sha256.convert(svg.readAsBytesSync()).toString();
          expect(row, contains(svgDigest), reason: '${svg.path} sha256');
        }
      }
    });

    test('provenance: original status, retired list, content sources doc', () {
      final doc = File('docs/DIAGRAMS_PROVENANCE.md').readAsStringSync();
      expect(doc, contains('ORIGINAL_CREATED_IN_REPO'));
      expect(doc, contains('tool/diagrams/gen_diagrams.py'));
      expect(doc, contains('docs/DIAGRAMS_CONTENT_SOURCES.md'));
      // Eski 18 ta sha qayd uchun saqlangan; egasi nomidan tasdiq yozilmagan.
      for (final h in _retired) {
        expect(doc, contains(h));
      }
      expect(doc, isNot(contains('APPROVED')));
      final sources = File('docs/DIAGRAMS_CONTENT_SOURCES.md');
      expect(sources.existsSync(), isTrue);
      final text = sources.readAsStringSync();
      for (final t in DiagramTopic.values) {
        expect(text, contains('## ${t.file}'), reason: t.file);
      }
      expect(text, contains('NEEDS_EXPERT'));
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
