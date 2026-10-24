import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:labguide/app/app_scope.dart';
import 'package:labguide/features/settings/settings_controller.dart';
import 'package:labguide/l10n/gen/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/harness.dart';

/// katalog.json'ga marketing manbali karta, yangi yo‘nalishli karta va stub qo‘shadi.
class _CatalogBundle extends CachingAssetBundle {
  _CatalogBundle(this._inner);
  final AssetBundle _inner;
  static const key = 'assets/instruments/catalog.json';

  @override
  Future<ByteData> load(String k) async {
    if (k != key) return _inner.load(k);
    final j = jsonDecode(await _inner.loadString(key)) as Map<String, Object?>;
    (j['sources']! as List).add({
      'id': 'mk-test',
      'title': 'MK Test page',
      'url': 'https://www.cepheid.com/x',
      'doc_ref': 'v1',
      'accessed': '2026-10-24',
      'type': 'manufacturer_marketing',
    });
    Map<String, String> t(String s) => {'uz': s, 'ru': s, 'en': s};
    (j['lab_cards']! as List)
      ..add({
        'id': 'mol-test',
        'lab_direction': 'molecular',
        'card_kind': 'method',
        'name': t('Mol test'),
        'tasks': [
          {
            'text': t('Task'),
            'sources': ['mk-test', 'cdc-xpert-mtb-rif'],
          },
        ],
        'sources': ['mk-test', 'cdc-xpert-mtb-rif'],
      })
      ..add({
        'id': 'gen-stub',
        'lab_direction': 'genetics',
        'card_kind': 'method',
        'name': t('Genetics stub'),
        'audit_status': 'NEEDS_SOURCE',
        'needs_source_reason': 'none',
      });
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(jsonEncode(j))));
  }
}

Future<void> _load(WidgetTester tester, AppServices s) async {
  await tester.runAsync(s.instruments.ensureCatalog);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  for (final lang in AppLanguage.values) {
    testWidgets('karta ekranida xom NEEDS_ tokeni yo‘q (${lang.name})', (
      tester,
    ) async {
      final services = await makeServices(
        tester,
        language: lang,
        bundle: _CatalogBundle(rootBundle),
      );
      await _load(tester, services);
      await pumpApp(tester, services);
      final catalog = services.instruments.catalog!;
      expect(catalog.publicLabCards, isNotEmpty);
      for (final c in catalog.publicLabCards) {
        await goTo(tester, '/lab/instruments/lc/${c.id}');
        final texts = tester
            .widgetList<Text>(find.byType(Text))
            .map((w) => w.data ?? w.textSpan?.toPlainText() ?? '')
            .join('\n');
        expect(texts.contains('NEEDS_'), isFalse, reason: c.id);
        final l = lookupAppLocalizations(lang.locale);
        expect(texts, contains(l.labDirStatusNeedsReview), reason: c.id);
      }
    });
  }

  testWidgets('NEEDS_SOURCE karta: chuqur havola bo‘sh holat, ro‘yxatda yo‘q', (
    tester,
  ) async {
    final services = await makeServices(
      tester,
      bundle: _CatalogBundle(rootBundle),
    );
    await _load(tester, services);
    await pumpApp(tester, services);
    final l = lookupAppLocalizations(const Locale('uz'));
    await goTo(tester, '/lab/instruments/lc/gen-stub');
    expect(find.text('Genetics stub'), findsNothing);
    expect(find.text(l.instNoResultsTitle), findsOneWidget);
    await goTo(tester, '/lab/instruments/lc/hiv-rna-viral-load');
    expect(find.text(l.instNoResultsTitle), findsOneWidget);
    // Yo‘nalish ekrani: faqat stubli yo‘nalish bo‘sh.
    await goTo(tester, '/lab/instruments/d/genetics');
    expect(find.text('Genetics stub'), findsNothing);
    expect(find.text(l.labDirEmpty), findsOneWidget);
    // Ommaviy kartali yangi yo‘nalish ko‘rinadi.
    await goTo(tester, '/lab/instruments/d/molecular');
    expect(find.text('Mol test'), findsOneWidget);
  });

  testWidgets('marketing manba kartada “ishlab chiqaruvchi sahifasi” belgisi', (
    tester,
  ) async {
    final services = await makeServices(
      tester,
      bundle: _CatalogBundle(rootBundle),
    );
    await _load(tester, services);
    await pumpApp(tester, services);
    final l = lookupAppLocalizations(const Locale('uz'));
    await goTo(tester, '/lab/instruments/lc/mol-test');
    await tester.scrollUntilVisible(
      find.textContaining(l.labDirManufacturerNote),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining(l.labDirManufacturerNote), findsOneWidget);
  });
}
